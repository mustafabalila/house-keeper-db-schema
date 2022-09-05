-- Create read only DB role
DO
$do$
BEGIN
  IF NOT EXISTS (
      SELECT 1 FROM pg_roles
      WHERE  rolname = '${flyway:database}_ro') THEN

      CREATE ROLE ${flyway:database}_ro;
  END IF;
END
$do$;

GRANT CONNECT ON DATABASE ${flyway:database} TO ${flyway:database}_ro;

GRANT USAGE ON SCHEMA ${flyway:database} TO ${flyway:database}_ro;

GRANT SELECT ON ALL TABLES IN SCHEMA ${flyway:database} TO ${flyway:database}_ro;
ALTER DEFAULT PRIVILEGES IN SCHEMA ${flyway:database} GRANT SELECT ON TABLES TO ${flyway:database}_ro;


-- Create read/write DB role
DO
$do$
BEGIN
  IF NOT EXISTS (
      SELECT 1 FROM pg_roles
      WHERE  rolname = '${flyway:database}_rw') THEN

      CREATE ROLE ${flyway:database}_rw;
  END IF;
END
$do$;

GRANT CONNECT ON DATABASE ${flyway:database} TO ${flyway:database}_rw;

GRANT USAGE, CREATE ON SCHEMA ${flyway:database} TO ${flyway:database}_rw;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA ${flyway:database} TO ${flyway:database}_rw;
ALTER DEFAULT PRIVILEGES IN SCHEMA ${flyway:database} GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO ${flyway:database}_rw;

GRANT USAGE ON ALL SEQUENCES IN SCHEMA ${flyway:database} TO ${flyway:database}_rw;
ALTER DEFAULT PRIVILEGES IN SCHEMA ${flyway:database} GRANT USAGE ON SEQUENCES TO ${flyway:database}_rw;
