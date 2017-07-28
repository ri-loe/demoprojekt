CREATE TABLE storage (
    id SERIAL PRIMARY KEY,
    name varchar(255) NOT NULL,
    capacity bigint NOT NULL,
    created_at timestamp DEFAULT current_timestamp,
    updated_at timestamp DEFAULT current_timestamp
);