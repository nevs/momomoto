
CREATE OR REPLACE FUNCTION test_parameter_sql( param1 INTEGER ) RETURNS INTEGER AS $$
  SELECT $1;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION test_parameter_sql_strict( param1 INTEGER ) RETURNS INTEGER AS $$
  SELECT $1;
$$ LANGUAGE sql STRICT;

CREATE OR REPLACE FUNCTION test_parameter_plpgsql( param1 INTEGER, param2 TEXT ) RETURNS INTEGER AS $$
  BEGIN
    RETURN param1;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION test_parameter_plpgsql_strict( param1 INTEGER, param2 TEXT ) RETURNS INTEGER AS $$
  BEGIN
    RETURN param1;
  END;
$$ LANGUAGE plpgsql STRICT;

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

CREATE OR REPLACE FUNCTION test_returns_void() RETURNS VOID AS $$
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION test_parameter_inout_sql( IN param1 INTEGER, OUT ret1 INTEGER ) AS $$
  SELECT $1;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION test_parameter_inout_plpgsql( IN param1 INTEGER, IN param2 TEXT, OUT ret1 INTEGER ) AS $$
  BEGIN
    ret1 := param1;
    RETURN;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION test_set_returning_inout( IN param1 INTEGER, OUT ret1 INTEGER, OUT ret2 TEXT ) RETURNS SETOF RECORD AS $$
  BEGIN
    ret1 := param1;
    ret2 := 'chunky';
    RETURN NEXT;
    ret2 := 'bacon';
    RETURN NEXT;
    RETURN;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION test_parameter_inout_unnamed( IN INTEGER, OUT INTEGER ) AS $$
  SELECT $1;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION test_parameter_inout_unnamed2( IN param1 INTEGER, OUT INTEGER ) AS $$
  SELECT $1;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION test_parameter_inout_unnamed3( IN INTEGER, OUT ret1 INTEGER ) AS $$
  SELECT $1;
$$ LANGUAGE sql;


