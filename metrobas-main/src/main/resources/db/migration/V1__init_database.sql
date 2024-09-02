CREATE TABLE IF NOT EXISTS `metrobas`.`agency` (
    agency_id VARCHAR(255) PRIMARY KEY,
    agency_name VARCHAR(255),
    agency_url VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS `metrobas`.`routes` (
    route_id VARCHAR(255) PRIMARY KEY,
    agency_id VARCHAR(255),
    route_short_name VARCHAR(255),
    route_long_name VARCHAR(255),
    rent DECIMAL(5, 2),
    FOREIGN KEY (agency_id) REFERENCES agency(agency_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS `metrobas`.`stops` (
    stop_id VARCHAR(255) PRIMARY KEY,
    stop_name VARCHAR(255),
    stop_lat DOUBLE,
    stop_lon DOUBLE
);

CREATE TABLE IF NOT EXISTS `metrobas`.`transfers` (
    transfer_id INT PRIMARY KEY AUTO_INCREMENT,
    min_transfer_time DOUBLE
);

CREATE TABLE IF NOT EXISTS `metrobas`.`transfers_stops` (
    transfers_stop_id INT PRIMARY KEY AUTO_INCREMENT,
    transfer_id INT,
    stop_id VARCHAR(255),
    sequence INT,
    FOREIGN KEY (stop_id) REFERENCES stops(stop_id) ON DELETE NO ACTION ON UPDATE NO ACTION,
    FOREIGN KEY (transfer_id) REFERENCES transfers(transfer_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS `metrobas`.`trips` (
    trip_id VARCHAR(255) PRIMARY KEY,
    route_id VARCHAR(255),
    direction_id INT CHECK (direction_id IN (0, 1)),
    trip_headsign VARCHAR(255),
    FOREIGN KEY (route_id) REFERENCES routes(route_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS `metrobas`.`trip_points` (
    point_id INT PRIMARY KEY AUTO_INCREMENT,
    trip_id VARCHAR(255),
    pt_lat DOUBLE,
    pt_lon DOUBLE,
    pt_sequence INT,
    FOREIGN KEY (trip_id) REFERENCES trips(trip_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS `metrobas`.`stop_times` (
    stop_time_id INT PRIMARY KEY AUTO_INCREMENT,
    trip_id VARCHAR(255),
    stop_id VARCHAR(255),
    arrive_time TIME,
    departure_time TIME,
    stop_sequence INT,
    FOREIGN KEY (trip_id) REFERENCES trips(trip_id) ON DELETE NO ACTION ON UPDATE NO ACTION,
    FOREIGN KEY (stop_id) REFERENCES stops(stop_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS `metrobas`.`users` (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    email VARCHAR(255),
    password VARCHAR(255),
    phone VARCHAR(255),
    user_name VARCHAR(255),
    role ENUM('USER', 'ADMIN', 'MANAGER'),
    age int,
    is_enabled TINYINT(1),
    gender ENUM('MALE', 'FEMALE')
);

CREATE TABLE IF NOT EXISTS `metrobas`.`saved_places` (
    saved_place_id INT PRIMARY KEY AUTO_INCREMENT,
    label VARCHAR(255),
    name VARCHAR(255),
    stop_lat DOUBLE,
    stop_lon DOUBLE,
    user_id int,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS `metrobas`.`reports` (
    report_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id int,
    content VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS `metrobas`.`messages`  (
    message_id INT  PRIMARY KEY AUTO_INCREMENT,
    message_content VARCHAR(255),
    message_date DATETIME,
    user_id INT,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS `metrobas`.`message_reports`  (
    message_report_id INT  PRIMARY KEY AUTO_INCREMENT,
    report_season VARCHAR(255),
    message_id INT,
    user_id INT,
    FOREIGN KEY (message_id) REFERENCES messages(message_id) ON DELETE NO ACTION ON UPDATE NO ACTION,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

