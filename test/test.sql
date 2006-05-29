
CREATE TABLE person (
    person_id SERIAL, 
    first_name TEXT, 
    last_name TEXT, 
    PRIMARY KEY(person_id)
);

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

CREATE TABLE test_bytea(
    id SERIAL,
    data BYTEA,
    PRIMARY KEY(id)
);

CREATE TABLE test_nodefault (
    id INTEGER,
    data TEXT,
    PRIMARY KEY(id)
);

