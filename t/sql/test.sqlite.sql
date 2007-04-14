CREATE TABLE user_role (
  user_id UINT NOT NULL,
  role_id UINT NOT NULL,
  PRIMARY KEY (user_id, role_id)
);

CREATE TABLE user (
  id INTEGER PRIMARY KEY NOT NULL,
  username VARCHAR(25) NOT NULL,
  password VARCHAR(255) NOT NULL,
  created DATETIME NOT NULL
);

CREATE UNIQUE INDEX username_user on user (username);

CREATE TABLE cart_item (
  id INTEGER PRIMARY KEY NOT NULL,
  cart_id UINT NOT NULL,
  sku VARCHAR(25) NOT NULL,
  quantity TINYINT(3) NOT NULL DEFAULT '1',
  price DECIMAL(9,2) NOT NULL DEFAULT '0.00',
  description VARCHAR(255),
  created DATETIME NOT NULL
);

CREATE TABLE cart (
  id INTEGER PRIMARY KEY NOT NULL,
  user_id UINT DEFAULT '0',
  created DATETIME NOT NULL
);

CREATE TABLE profile (
  id INTEGER PRIMARY KEY NOT NULL,
  user_id UINT NOT NULL,
  first_name VARCHAR(25),
  last_name VARCHAR(25),
  created DATETIME NOT NULL
);

CREATE UNIQUE INDEX user_id_profile on profile (user_id);

CREATE TABLE role (
  id INTEGER PRIMARY KEY NOT NULL,
  name VARCHAR(25) NOT NULL,
  description VARCHAR(100),
  created DATETIME NOT NULL
);

CREATE UNIQUE INDEX name_role on role (name);

CREATE TABLE wishlist (
  id INTEGER PRIMARY KEY NOT NULL,
  user_id UINT NOT NULL,
  name VARCHAR(50) NOT NULL,
  description VARCHAR(255),
  created DATETIME NOT NULL
);

CREATE TABLE wishlist_item (
  id INTEGER PRIMARY KEY NOT NULL,
  wishlist_id UINT NOT NULL,
  sku VARCHAR(25) NOT NULL,
  quantity TINYINT(3) NOT NULL DEFAULT '1',
  description VARCHAR(255),
  created DATETIME NOT NULL
);
