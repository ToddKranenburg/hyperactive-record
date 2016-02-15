CREATE TABLE plants (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  owner_id INTEGER,

  FOREIGN KEY(owner_id) REFERENCES human(id)
);

CREATE TABLE humans (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL,
  house_id INTEGER,

  FOREIGN KEY(house_id) REFERENCES human(id)
);

CREATE TABLE houses (
  id INTEGER PRIMARY KEY,
  address VARCHAR(255) NOT NULL
);

INSERT INTO
  houses (id, address)
VALUES
  (1, "323 South 5th St"), (2, "1049 Park Ave");

INSERT INTO
  humans (id, fname, lname, house_id)
VALUES
  (1, "Katharine", "Alice", 1),
  (2, "Todd", "Kranenburg", 1),
  (3, "Pam", "Soffer", 2),
  (4, "Hendrik", "Johannes", NULL);

INSERT INTO
  plants (id, name, owner_id)
VALUES
  (1, "Thirsty", 1),
  (2, "Leafy", 2),
  (3, "Stalky", 3),
  (4, "Droopy", 3),
  (5, "Creepy", NULL);
