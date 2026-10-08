# Pharmacy Management

NestJS + Prisma 7 + PostgreSQL pharmacy management API.

## Requirements

- Node.js
- PostgreSQL
- npm

## Setup

1. Clone the project and install dependencies:

```bash
npm install
```

2. Create a PostgreSQL database named `pharmacy_management`.

3. Create `.env` from `.env.example` and set your PostgreSQL connection string and JWT secret.

4. Run the database scripts from the project root with `psql`:

```bash
psql "$DATABASE_URL" -f database/run-all.sql
```

On Windows PowerShell:

```powershell
psql "$env:DATABASE_URL" -f database/run-all.sql
```

`run-all.sql` is safe to run again because it drops the existing database objects first and uses `\ir` for relative script paths.

5. Generate Prisma Client:

```bash
npx prisma generate
```

6. Start the API:

```bash
npm run start:dev
```

## Authentication

Login:

```http
POST /auth/login
Content-Type: application/json
```

```json
{
  "email": "pharmacist@example.com",
  "password": "Password123!"
}
```

Use the returned JWT as:

```http
Authorization: Bearer <token>
```

The dispense endpoint requires authentication:

```http
POST /prescriptions/:id/dispense
```

## Prescription dispensing

The dispensing business logic is implemented in PostgreSQL inside `dispense_prescription`.

NestJS only calls:

```sql
SELECT dispense_prescription(<prescription_id>);
```

The database handles:

- concurrency control
- row locking
- FEFO
- expired-batch exclusion
- all-or-nothing dispensing
- stock updates
- prescription status

## Validation

Global `ValidationPipe` is enabled with whitelist, non-whitelisted-field rejection, and transformation.

DTO classes are used for request validation.

## Build

```bash
npm run build
```
