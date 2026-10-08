Create TABLE patients(
    patient_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

Create TABLE medicines(
    medicine_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

Create TABLE Batches(
    batch_id SERIAL PRIMARY KEY,
    medicine_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    expire_date DATE NOT NULL,
    CONSTRAINT fk_batches_medicine FOREIGN KEY (medicine_id) 
    REFERENCES medicines(medicine_id) ON DELETE RESTRICT
  );

Create TABLE prescriptions(
    prescription_id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_prescriptions_patient FOREIGN KEY (patient_id)
    REFERENCES patients(patient_id) ON DELETE RESTRICT,
    CONSTRAINT chk_status CHECK (status IN ('pending', 'dispensed'))
);

Create TABLE prescription_items(
    prescription_item_id SERIAL PRIMARY KEY,
    prescription_id INTEGER NOT NULL,
    medicine_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    CONSTRAINT fk_prescription_items_prescription FOREIGN KEY (prescription_id)
    REFERENCES prescriptions(prescription_id) ON DELETE CASCADE,
    CONSTRAINT fk_prescription_items_medicine FOREIGN KEY (medicine_id)
    REFERENCES medicines(medicine_id) ON DELETE RESTRICT,
    CONSTRAINT un_prescription_medicine UNIQUE (prescription_id, medicine_id)
);


CREATE TABLE users(
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL
);
