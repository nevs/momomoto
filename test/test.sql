
CREATE TABLE conference (
    conference_id SERIAL,
    acronym TEXT NOT NULL UNIQUE,
    title TEXT NOT NULL,
    subtitle TEXT,
    description TEXT,
    start_date DATE NOT NULL,
    timeslot_duration INTERVAL NOT NULL DEFAULT '0:30:00',
    default_timeslots INTEGER NOT NULL DEFAULT 1,
    max_timeslots_per_event INTEGER NOT NULL DEFAULT 10,
    day_change TIME WITHOUT TIME ZONE NOT NULL DEFAULT '0:00:00',
    feedback_enabled BOOL NOT NULL DEFAULT FALSE,
    submission_enabled BOOL NOT NULL DEFAULT FALSE,
    visitor_enabled BOOL NOT NULL DEFAULT FALSE,
    reconfirmation_enabled BOOL NOT NULL DEFAULT FALSE,
    PRIMARY KEY(conference_id)
);

CREATE TABLE person (
    person_id SERIAL,
    first_name TEXT,
    last_name TEXT,
    nick_name TEXT,
    PRIMARY KEY(person_id)
);

INSERT INTO person(nick_name) VALUES ('blossom');
INSERT INTO person(nick_name) VALUES ('buttercup');
INSERT INTO person(nick_name) VALUES ('bubbles');
INSERT INTO person(nick_name) VALUES ('mojojojo');

CREATE TABLE event (
    event_id SERIAL,
    title TEXT,
    subtitle TEXT,
    PRIMARY KEY(event_id)
);

CREATE TABLE event_person (
    event_id INTEGER,
    person_id INTEGER,
    description TEXT,
    FOREIGN KEY(event_id) REFERENCES event(event_id),
    FOREIGN KEY(person_id) REFERENCES person(person_id),
    PRIMARY KEY(event_id, person_id, description)
);

CREATE TABLE test_bigint( id SERIAL, data BIGINT, PRIMARY KEY(id));
CREATE TABLE test_boolean( id SERIAL, data BOOLEAN, PRIMARY KEY(id));
CREATE TABLE test_bytea( id SERIAL, data BYTEA, PRIMARY KEY(id));
CREATE TABLE test_character( id SERIAL, data CHARACTER(1000), PRIMARY KEY(id));
CREATE TABLE test_character_varying( id SERIAL, data VARCHAR(1000), PRIMARY KEY(id));
CREATE TABLE test_date( id SERIAL, data DATE, PRIMARY KEY(id));
CREATE TABLE test_inet( id SERIAL, data INET, PRIMARY KEY(id));
CREATE TABLE test_integer( id SERIAL, data INTEGER, PRIMARY KEY(id));
CREATE TABLE test_interval( id SERIAL, data INTERVAL, PRIMARY KEY(id));
CREATE TABLE test_nodefault ( id INTEGER, data TEXT, PRIMARY KEY(id));
CREATE TABLE test_numeric( id SERIAL, data NUMERIC, PRIMARY KEY(id));
CREATE TABLE test_real( id SERIAL, data REAL, PRIMARY KEY(id));
CREATE TABLE test_smallint( id SERIAL, data SMALLINT, PRIMARY KEY(id));
CREATE TABLE test_text( id SERIAL, data TEXT, PRIMARY KEY(id));
CREATE TABLE test_time_with_time_zone( id SERIAL, data TIME WITH TIME ZONE, PRIMARY KEY(id));
CREATE TABLE test_time_without_time_zone( id SERIAL, data TIME WITHOUT TIME ZONE, PRIMARY KEY(id));
CREATE TABLE test_timestamp_with_time_zone( id SERIAL, data TIMESTAMP WITH TIME ZONE, PRIMARY KEY(id));
CREATE TABLE test_timestamp_without_time_zone( id SERIAL, data TIMESTAMP WITHOUT TIME ZONE, PRIMARY KEY(id));
CREATE TABLE test_int_array( id SERIAL, data int[], PRIMARY KEY(id) );
CREATE TABLE test_text_array( id SERIAL, data text[], PRIMARY KEY(id) );


