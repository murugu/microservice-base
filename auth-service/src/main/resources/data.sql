DELETE FROM user;
INSERT INTO user VALUES (1, unix_timestamp(now()), unix_timestamp(now()), 'user@example.com', 'John', 'Doe', 'user', 'password', 1);
INSERT INTO user VALUES (2, unix_timestamp(now()), unix_timestamp(now()), 'user2@email.com', 'Joe', 'Appleseed', 'user2', 'password2', 1);
INSERT INTO user VALUES (3, unix_timestamp(now()), unix_timestamp(now()), 'user3@email.com', 'Bob', 'TheBuilder', 'user3', 'password3', 1);