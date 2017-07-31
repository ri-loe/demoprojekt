-- Table: public.storage

-- DROP TABLE public.storage;

CREATE TABLE public.storage
(
    id integer NOT NULL DEFAULT nextval('storage_id_seq'::regclass),
    name character varying(255) COLLATE pg_catalog."default" NOT NULL,
    capacity bigint NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    CONSTRAINT storage_pkey PRIMARY KEY (id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.storage
    OWNER to c5261164;

-- Trigger: update_timestamp_on_update

-- DROP TRIGGER update_timestamp_on_update ON public.storage;

CREATE TRIGGER update_timestamp_on_update
    BEFORE UPDATE
    ON public.storage
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();