
CREATE OR REPLACE FUNCTION fetch_procedure_columns( procedure_name TEXT ) RETURNS SETOF procedure_column AS $$
DECLARE
  proc RECORD;
  typ RECORD;
  att RECORD;
  col procedure_column%rowtype;
BEGIN
  SELECT INTO proc * FROM pg_proc WHERE proname = procedure_name;
  IF FOUND THEN
    SELECT INTO typ * FROM pg_type WHERE oid = proc.prorettype;

    IF typ.typtype = 'b' THEN
      col.column_name = procedure_name;
      SELECT INTO col.data_type format_type( proc.prorettype, NULL::integer );
      RETURN NEXT col;
    ELSIF typ.typtype = 'c' THEN
      FOR col IN
        SELECT attname AS column_name, format_type(atttypid, NULL) FROM pg_attribute WHERE attrelid = typ.typrelid AND attnum > 0 ORDER BY attnum
      LOOP
        RETURN NEXT col;
      END LOOP;
    ELSE
      RAISE EXCEPTION 'Not yet implemented';
    END IF;
  END IF;
  RETURN;
END;
$$ LANGUAGE plpgsql;

