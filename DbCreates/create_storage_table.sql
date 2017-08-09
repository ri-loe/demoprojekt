﻿-- Table: public.storages

-- DROP TABLE public.storages;

CREATE TABLE public.storages (id SERIAL PRIMARY KEY, name varchar(255) NOT NULL,
                              capacity bigint NOT NULL, created_at timestamp(0) DEFAULT current_timestamp,
                              updated_at timestamp(0) DEFAULT current_timestamp)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.storages
    OWNER to c5261164;

-- Trigger: update_timestamp_on_update

-- DROP TRIGGER update_timestamp_on_update ON public.storage;

CREATE TRIGGER update_timestamp_on_update
    BEFORE UPDATE
    ON public.storages
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();