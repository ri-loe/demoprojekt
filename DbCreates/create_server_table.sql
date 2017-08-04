﻿-- Table: public.servers

-- DROP TABLE public.servers;

CREATE TABLE public.servers (id SERIAL PRIMARY KEY,
                              name varchar(255) NOT NULL UNIQUE,
                              os_id integer REFERENCES operating_systems,
                              storage_id integer REFERENCES storages,
                              checksum varchar(255) NOT NULL,
                              created_at timestamp(0) DEFAULT current_timestamp,
                              updated_at timestamp(0) DEFAULT current_timestamp)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.servers
    OWNER to c5261164;

-- Trigger: update_timestamp_on_update

-- DROP TRIGGER update_timestamp_on_update ON public.storage;

CREATE TRIGGER update_timestamp_on_update
    BEFORE UPDATE
    ON public.servers
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();
