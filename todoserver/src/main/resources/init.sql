CREATE DATABASE todo_db;
GRANT ALL PRIVILEGES ON DATABASE todo_db TO postgres;

\c todo_db; 

create table todo_priority (
   id  bigserial not null,
    description text not null,
    level int8 not null,
    primary key (id)
);

INSERT INTO todo_priority(id, description, level) values (1, 'HIGH', 1), (2, 'MEDIUM', 2), (3, 'LOW', 3);