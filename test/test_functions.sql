
CREATE OR REPLACE FUNCTION test_parameter_sql( param1 INTEGER ) RETURNS INTEGER AS $$
  SELECT $1;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION test_parameter_plpgsql( param1 INTEGER, param2 TEXT ) RETURNS INTEGER AS $$
  DECLARE
  BEGIN
    RETURN param1;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION test_set_returning( person_id INTEGER ) RETURNS SETOF person AS $$
  DECLARE
    result RECORD;
  BEGIN
    FOR result IN
      SELECT person.* FROM person WHERE person.person_id <> person_id
      LOOP
        RETURN NEXT result;
      END LOOP;
    RETURN;
  END;
$$ LANGUAGE plpgsql;

