-- migrate:up
ALTER TABLE users
    ADD COLUMN country VARCHAR(100),
    ADD COLUMN state VARCHAR(100),
    ADD COLUMN address VARCHAR(255);

-- migrate:down
ALTER TABLE users
    DROP COLUMN IF EXISTS address,
    DROP COLUMN IF EXISTS state,
    DROP COLUMN IF EXISTS country;
