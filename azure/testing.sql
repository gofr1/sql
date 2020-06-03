CREATE TABLE test (
    id INT IDENTITY(1,1),
    name varchar(512),
    CONSTRAINT PK_test_id PRIMARY KEY  (id)
)

INSERT INTO test (name) VALUES
('John Wick'), ('Sherlock Holmes'), ('Wade Wilson')
