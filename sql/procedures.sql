
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

CREATE OR REPLACE FUNCTION fetch_procedure_parameter( procedure_name TEXT ) RETURNS SETOF procedure_parameter AS $$
DECLARE
  proc RECORD;
  typ RECORD;
  col procedure_parameter%rowtype;
  i INTEGER;
  j INTEGER;
  k INTEGER;
BEGIN
  SELECT INTO proc proargnames, proallargtypes, proargtypes FROM pg_proc WHERE proname = procedure_name;
  IF FOUND THEN
    j = array_lower(proc.proargtypes, 1);
    k = array_upper(proc.proargtypes, 1);
    RAISE WARNING '%', j;
    FOR i IN j .. k
    LOOP
      col.column_name = proc.proargnames[ i + array_lower( proc.proargnames, 1 )];
      col.data_type = format_type( proc.proargtypes[i], NULL );
      RETURN NEXT col;
    END LOOP;
  END IF;
  RETURN;
END;
$$ LANGUAGE plpgsql;

