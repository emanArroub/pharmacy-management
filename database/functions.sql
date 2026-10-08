-- functions.sql
-- All dispensing business logic lives in PostgreSQL.
-- NestJS only calls:
-- SELECT dispense_prescription(<prescription_id>);

CREATE OR REPLACE FUNCTION dispense_prescription(
    p_prescription_id INTEGER
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_status VARCHAR(20);
    v_today DATE := CURRENT_DATE;

    v_item RECORD;
    v_batch RECORD;

    v_required INTEGER;
    v_available INTEGER;
    v_take INTEGER;
BEGIN
    ----------------------------------------------------------------
    -- 1. Basic validation
    ----------------------------------------------------------------
    IF p_prescription_id IS NULL THEN
        RAISE EXCEPTION 'رقم الوصفة مطلوب';
    END IF;

    SELECT status
    INTO v_status
    FROM prescriptions
    WHERE prescription_id = p_prescription_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'الوصفة رقم % غير موجودة', p_prescription_id;
    END IF;

    IF v_status = 'dispensed' THEN
        RAISE EXCEPTION 'الوصفة رقم % مصروفة مسبقاً', p_prescription_id;
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM prescription_items
        WHERE prescription_id = p_prescription_id
    ) THEN
        RAISE EXCEPTION 'الوصفة رقم % لا تحتوي على أدوية', p_prescription_id;
    END IF;

    ----------------------------------------------------------------
    -- 2. Lock ALL usable batches needed by this prescription.
    --
    -- Important:
    -- We lock in deterministic order:
    -- medicine_id -> expire_date -> batch_id
    --
    -- This prevents two pharmacists from changing the same stock
    -- at the same time and greatly reduces deadlock risk.
    ----------------------------------------------------------------
    PERFORM 1
    FROM batches b
    JOIN prescription_items pi
      ON pi.medicine_id = b.medicine_id
    WHERE pi.prescription_id = p_prescription_id
      AND b.expire_date >= v_today
    ORDER BY b.medicine_id, b.expire_date, b.batch_id
    FOR UPDATE;

    ----------------------------------------------------------------
    -- 3. Re-check status AFTER acquiring the locks.
    --
    -- This is critical for:
    -- pharmacist A + pharmacist B
    -- pressing "dispense" at the same time.
    ----------------------------------------------------------------
    SELECT status
    INTO v_status
    FROM prescriptions
    WHERE prescription_id = p_prescription_id
    FOR UPDATE;

    IF v_status = 'dispensed' THEN
        RAISE EXCEPTION 'الوصفة رقم % مصروفة مسبقاً', p_prescription_id;
    END IF;

    ----------------------------------------------------------------
    -- 4. FIRST PASS: check every medicine.
    --
    -- Nothing is decreased in this pass.
    -- If even ONE medicine is insufficient, the function raises an
    -- exception and the whole SQL statement is rolled back.
    ----------------------------------------------------------------
    FOR v_item IN
        SELECT
            pi.medicine_id,
            m.name AS medicine_name,
            SUM(pi.quantity)::INTEGER AS required_quantity
        FROM prescription_items pi
        JOIN medicines m
          ON m.medicine_id = pi.medicine_id
        WHERE pi.prescription_id = p_prescription_id
        GROUP BY pi.medicine_id, m.name
        ORDER BY pi.medicine_id
    LOOP
        SELECT COALESCE(SUM(b.quantity), 0)::INTEGER
        INTO v_available
        FROM batches b
        WHERE b.medicine_id = v_item.medicine_id
          AND b.expire_date >= v_today;

        IF v_available < v_item.required_quantity THEN
            RAISE EXCEPTION
                'الدواء "%" غير كافٍ: المطلوب %، والمتاح الصالح %',
                v_item.medicine_name,
                v_item.required_quantity,
                v_available;
        END IF;
    END LOOP;

    ----------------------------------------------------------------
    -- 5. SECOND PASS: actually dispense.
    --
    -- FEFO:
    -- earliest expiration date first.
    --
    -- Expired batches are automatically ignored.
    ----------------------------------------------------------------
    FOR v_item IN
        SELECT
            pi.medicine_id,
            SUM(pi.quantity)::INTEGER AS required_quantity
        FROM prescription_items pi
        WHERE pi.prescription_id = p_prescription_id
        GROUP BY pi.medicine_id
        ORDER BY pi.medicine_id
    LOOP
        v_required := v_item.required_quantity;

        FOR v_batch IN
            SELECT
                b.batch_id,
                b.quantity
            FROM batches b
            WHERE b.medicine_id = v_item.medicine_id
              AND b.expire_date >= v_today
              AND b.quantity > 0
            ORDER BY b.expire_date ASC, b.batch_id ASC
            FOR UPDATE
        LOOP
            EXIT WHEN v_required = 0;

            v_take := LEAST(v_required, v_batch.quantity);

            UPDATE batches
            SET quantity = quantity - v_take
            WHERE batch_id = v_batch.batch_id
              AND quantity >= v_take;

            IF NOT FOUND THEN
                RAISE EXCEPTION
                    'فشل تحديث مخزون الدفعة رقم %',
                    v_batch.batch_id;
            END IF;

            v_required := v_required - v_take;
        END LOOP;

        -- Defensive check: stock must never go negative / incomplete.
        IF v_required > 0 THEN
            RAISE EXCEPTION
                'تعذر صرف الدواء رقم % بالكامل',
                v_item.medicine_id;
        END IF;
    END LOOP;

    ----------------------------------------------------------------
    -- 6. Mark prescription as dispensed.
    ----------------------------------------------------------------
    UPDATE prescriptions
    SET status = 'dispensed'
    WHERE prescription_id = p_prescription_id
      AND status = 'pending';

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'الوصفة رقم % مصروفة مسبقاً',
            p_prescription_id;
    END IF;

    RETURN format(
        'تم صرف الوصفة رقم %s بنجاح',
        p_prescription_id
    );

EXCEPTION
    WHEN OTHERS THEN
        -- The exception propagates to the caller.
        -- Because the function is executed inside the database
        -- transaction, all stock changes from this call are rolled back.
        RAISE;
END;
$$;


-- Optional helper function for NestJS / testing:
-- Returns current valid stock for a medicine.
CREATE OR REPLACE FUNCTION get_available_stock(
    p_medicine_id INTEGER
)
RETURNS INTEGER
LANGUAGE sql
AS $$
    SELECT COALESCE(SUM(quantity), 0)::INTEGER
    FROM batches
    WHERE medicine_id = p_medicine_id
      AND expire_date >= CURRENT_DATE;
$$;
