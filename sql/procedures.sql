
CREATE OR REPLACE FUNCTION momomoto.fetch_procedure_columns( procedure_name TEXT ) RETURNS SETOF momomoto.procedure_column AS $$
DECLARE
  proc RECORD;
  typ RECORD;
  att RECORD;
  i INTEGER;
  col momomoto.procedure_column%rowtype;
BEGIN
  SELECT INTO proc * FROM pg_proc WHERE proname = procedure_name;
  IF FOUND THEN
    SELECT INTO typ * FROM pg_type WHERE oid = proc.prorettype;

    IF typ.typtype = 'b' THEN
      -- base type
      IF proc.proallargtypes IS NULL THEN
        -- we only got IN arguments
        col.column_name = procedure_name;
        SELECT INTO col.data_type format_type( proc.prorettype, NULL::integer );
        RETURN NEXT col;
      ELSE
        -- we got a named out arguments
        FOR i IN array_lower(proc.proallargtypes, 1) .. array_upper(proc.proallargtypes, 1)
        LOOP
          CONTINUE WHEN proc.proargmodes[ i ] = 'i';
          IF COALESCE( proc.proargnames[ i ], '' ) = '' THEN
            col.column_name = procedure_name;
          ELSE
            col.column_name = proc.proargnames[ i ];
          END IF;
          col.data_type = format_type( proc.proallargtypes[ i ], NULL );
          RETURN NEXT col;
        END LOOP;
      END IF;
    ELSIF typ.typtype = 'c' THEN
      -- composite type
      FOR col IN
        SELECT attname AS column_name, format_type(atttypid, NULL) FROM pg_attribute WHERE attrelid = typ.typrelid AND attnum > 0 ORDER BY attnum
      LOOP
        RETURN NEXT col;
      END LOOP;
    ELSIF typ.typtype = 'p' THEN
      -- pseudo type
      FOR i IN array_lower(proc.proallargtypes, 1) .. array_upper(proc.proallargtypes, 1)
      LOOP
        CONTINUE WHEN proc.proargmodes[ i ] = 'i';
        col.column_name = proc.proargnames[ i ];
        col.data_type = format_type( proc.proallargtypes[ i ], NULL );
        RETURN NEXT col;
      END LOOP;
    ELSE
      RAISE EXCEPTION 'Not yet implemented';
    END IF;
  END IF;
  RETURN;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION momomoto.fetch_procedure_parameters( procedure_name TEXT ) RETURNS SETOF momomoto.procedure_parameter AS $$
DECLARE
  proc RECORD;
  typ RECORD;
  col momomoto.procedure_parameter%rowtype;
  i INTEGER;
BEGIN
  SELECT INTO proc proargnames, proargtypes, proargmodes, proargtypes FROM pg_proc WHERE proname = procedure_name;
  IF FOUND THEN
    FOR i IN array_lower(proc.proargtypes, 1) .. array_upper(proc.proargtypes, 1)
    LOOP
      IF COALESCE( proc.proargnames[ i + array_lower( proc.proargnames, 1 ) ], '' ) = '' THEN
        col.parameter_name = procedure_name;
      ELSE
        col.parameter_name = proc.proargnames[ i + array_lower( proc.proargnames, 1 )];
      END IF;
      col.data_type = format_type( proc.proargtypes[ i ], NULL );
      RETURN NEXT col;
    END LOOP;
  END IF;
  RETURN;
END;
$$ LANGUAGE plpgsql;

