CREATE TABLE public.operating_systems (id SERIAL PRIMARY KEY,
                              name varchar(255) NOT NULL UNIQUE)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.operating_systems
    OWNER to c5261164;