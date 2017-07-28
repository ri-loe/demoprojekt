﻿-- Trigger: update_timestamp_on_update

-- DROP TRIGGER update_timestamp_on_update ON public.users;

CREATE TRIGGER update_timestamp_on_update
    BEFORE UPDATE
    ON public.<<TABLE>>
    FOR EACH ROW
    EXECUTE PROCEDURE public.update_updated_at_column();