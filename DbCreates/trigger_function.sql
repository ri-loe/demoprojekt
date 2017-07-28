-- FUNCTION: public.update_updated_at_column()

-- DROP FUNCTION public.update_updated_at_column()

CREATE FUNCTION public.update_updated_at_column()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100.0
    VOLATILE NOT LEAKPROOF
AS $BODY$

BEGIN
NEW.updated_at = now();
RETURN NEW;
END;

$BODY$;

ALTER FUNCTION public.update_updated_at_column()
    OWNER TO c5261164;
