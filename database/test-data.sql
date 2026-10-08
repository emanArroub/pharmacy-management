-- ============================================
-- TEST DATA - Pharmacy Management
-- ============================================

-- Patients
INSERT INTO patients (name)
VALUES
    ('Ali'),
    ('Sara'),
    ('Omar'),
    ('Lina');

-- Medicines
INSERT INTO medicines (name)
VALUES
    ('Panadol'),
    ('Amoxicillin');

-- ============================================
-- Batches
-- Today according to the assignment: 2026-10-02
-- ============================================

-- Panadol
INSERT INTO batches (medicine_id, quantity, expire_date)
SELECT medicine_id, 5, '2026-10-15'
FROM medicines
WHERE name = 'Panadol';

INSERT INTO batches (medicine_id, quantity, expire_date)
SELECT medicine_id, 20, '2027-03-01'
FROM medicines
WHERE name = 'Panadol';

-- Expired Panadol batch
INSERT INTO batches (medicine_id, quantity, expire_date)
SELECT medicine_id, 10, '2026-09-01'
FROM medicines
WHERE name = 'Panadol';

-- Amoxicillin
INSERT INTO batches (medicine_id, quantity, expire_date)
SELECT medicine_id, 3, '2027-01-01'
FROM medicines
WHERE name = 'Amoxicillin';


-- ============================================
-- Prescription 1
-- 8 Panadol + 2 Amoxicillin
-- Expected: SUCCESS
-- ============================================

INSERT INTO prescriptions (patient_id)
SELECT patient_id
FROM patients
WHERE name = 'Ali';

INSERT INTO prescription_items
    (prescription_id, medicine_id, quantity)
SELECT
    (SELECT prescription_id
     FROM prescriptions
     WHERE patient_id = (SELECT patient_id FROM patients WHERE name = 'Ali')
     ORDER BY prescription_id DESC
     LIMIT 1),
    medicine_id,
    8
FROM medicines
WHERE name = 'Panadol';

INSERT INTO prescription_items
    (prescription_id, medicine_id, quantity)
SELECT
    (SELECT prescription_id
     FROM prescriptions
     WHERE patient_id = (SELECT patient_id FROM patients WHERE name = 'Ali')
     ORDER BY prescription_id DESC
     LIMIT 1),
    medicine_id,
    2
FROM medicines
WHERE name = 'Amoxicillin';


-- ============================================
-- Prescription 2
-- 10 Panadol + 5 Amoxicillin
-- Expected: REJECT
-- because Amoxicillin available = 3
-- ============================================

INSERT INTO prescriptions (patient_id)
SELECT patient_id
FROM patients
WHERE name = 'Sara';

INSERT INTO prescription_items
    (prescription_id, medicine_id, quantity)
SELECT
    (SELECT prescription_id
     FROM prescriptions
     WHERE patient_id = (SELECT patient_id FROM patients WHERE name = 'Sara')
     ORDER BY prescription_id DESC
     LIMIT 1),
    medicine_id,
    10
FROM medicines
WHERE name = 'Panadol';

INSERT INTO prescription_items
    (prescription_id, medicine_id, quantity)
SELECT
    (SELECT prescription_id
     FROM prescriptions
     WHERE patient_id = (SELECT patient_id FROM patients WHERE name = 'Sara')
     ORDER BY prescription_id DESC
     LIMIT 1),
    medicine_id,
    5
FROM medicines
WHERE name = 'Amoxicillin';


-- ============================================
-- Prescription 3
-- 25 Panadol
-- Expected: REJECT
-- Valid Panadol = 25 before prescription 1,
-- but after prescription 1 it becomes 17.
-- So this is useful AFTER testing prescription 1.
-- ============================================

INSERT INTO prescriptions (patient_id)
SELECT patient_id
FROM patients
WHERE name = 'Omar';

INSERT INTO prescription_items
    (prescription_id, medicine_id, quantity)
SELECT
    (SELECT prescription_id
     FROM prescriptions
     WHERE patient_id = (SELECT patient_id FROM patients WHERE name = 'Omar')
     ORDER BY prescription_id DESC
     LIMIT 1),
    medicine_id,
    25
FROM medicines
WHERE name = 'Panadol';


-- ============================================
-- Prescription 4
-- 2 Amoxicillin
-- Used for concurrency / stock test.
-- ============================================

INSERT INTO prescriptions (patient_id)
SELECT patient_id
FROM patients
WHERE name = 'Lina';INSERT INTO prescription_items
    (prescription_id, medicine_id, quantity)
SELECT
    (SELECT prescription_id
     FROM prescriptions
     WHERE patient_id = (SELECT patient_id FROM patients WHERE name = 'Lina')
     ORDER BY prescription_id DESC
     LIMIT 1),
    medicine_id,
    2
FROM medicines
WHERE name = 'Amoxicillin';

-- Test pharmacist account
-- email: pharmacist@example.com
-- password: password
INSERT INTO users (email, password)
VALUES (
    'pharmacist@example.com',
    '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'
);
