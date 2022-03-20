CREATE TABLE my_table (
  id INT UNSIGNED NOT NULL auto_increment PRIMARY KEY,
  first_name VARCHAR(255) DEFAULT NULL,
  favorite_color ENUM('red', 'green', 'blue', 'purple') DEFAULT NULL,
  created_at DATETIME,
  updated_at DATETIME
);