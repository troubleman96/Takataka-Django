CREATE TABLE `regions` (
  `id` serial PRIMARY KEY,
  `code` varchar(10) UNIQUE NOT NULL,
  `name_sw` varchar(100) NOT NULL,
  `name_en` varchar(100) NOT NULL
);

CREATE TABLE `districts` (
  `id` serial PRIMARY KEY,
  `region_id` int NOT NULL,
  `code` varchar(10) UNIQUE NOT NULL,
  `name_sw` varchar(100) NOT NULL,
  `name_en` varchar(100) NOT NULL
);

CREATE TABLE `wards` (
  `id` serial PRIMARY KEY,
  `district_id` int NOT NULL,
  `code` varchar(20) UNIQUE NOT NULL,
  `name_sw` varchar(100) NOT NULL,
  `name_en` varchar(100) NOT NULL,
  `population` int,
  `area_sq_km` decimal(10,2)
);

CREATE TABLE `streets` (
  `id` serial PRIMARY KEY,
  `ward_id` int NOT NULL,
  `name` varchar(200) NOT NULL,
  `description` text
);

CREATE TABLE `users` (
  `id` serial PRIMARY KEY,
  `first_name` varchar(20) NOT NULL,
  `last_name` varchar(20) NOT NULL,
  `phone_number` text UNIQUE NOT NULL,
  `email` varchar(100) UNIQUE NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` varchar(30) NOT NULL,
  `ward_id` int,
  `is_active` boolean,
  `is_verified` boolean,
  `last_login` timestamp
);

CREATE TABLE `households` (
  `id` serial PRIMARY KEY,
  `user_id` int NOT NULL,
  `phone_number` text NOT NULL,
  `house_number` int NOT NULL,
  `ward_id` int,
  `street_id` int
);

CREATE TABLE `house_members` (
  `id` serial PRIMARY KEY,
  `household_id` int NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `date_of_birth` date,
  `gender` varchar(20),
  `relationship` varchar(50),
  `user_id` int,
  `created_by` int NOT NULL
);

CREATE TABLE `collection_points` (
  `id` serial PRIMARY KEY,
  `ward_id` int NOT NULL,
  `name` varchar(100)
);

CREATE TABLE `vehicles` (
  `id` serial PRIMARY KEY,
  `plate_number` varchar(20) UNIQUE NOT NULL,
  `type` varchar(50),
  `capacity` decimal(10,2),
  `status` varchar(30),
  `assigned_to` int,
  `assigned_driver_id` int,
  `ward_id` int
);

CREATE TABLE `vehicle_locations` (
  `id` serial PRIMARY KEY,
  `vehicle_id` int NOT NULL
);

CREATE TABLE `collection_routes` (
  `id` serial PRIMARY KEY,
  `route_number` varchar(50) UNIQUE NOT NULL,
  `ward_id` int NOT NULL,
  `name` varchar(200) NOT NULL
);

CREATE TABLE `route_stops` (
  `id` serial PRIMARY KEY,
  `route_id` int NOT NULL,
  `collection_point_id` int,
  `stop_order` int NOT NULL
);

CREATE TABLE `collection_schedules` (
  `id` serial PRIMARY KEY,
  `route_id` int NOT NULL,
  `day_of_week` varchar(20) NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time,
  `assigned_collector` int,
  `assigned_driver_id` int,
  `vehicle_id` int,
  `is_active` boolean
);

CREATE TABLE `collection_sessions` (
  `id` serial PRIMARY KEY,
  `route_id` int NOT NULL,
  `vehicle_id` int NOT NULL,
  `driver_id` int NOT NULL,
  `scheduled_date` date NOT NULL,
  `scheduled_start_time` time NOT NULL,
  `actual_start_time` timestamp,
  `actual_end_time` timestamp,
  `status` varchar(30),
  `total_amount_collected` decimal(10,2),
  `notes` text
);

CREATE TABLE `payments` (
  `id` serial PRIMARY KEY,
  `household_id` int NOT NULL,
  `amount` int NOT NULL,
  `due_date` date,
  `payment_date` timestamp NOT NULL,
  `payment_method` varchar(20) NOT NULL,
  `status` varchar(20),
  `collected_by` int
);

CREATE TABLE `money_collector_records` (
  `id` serial PRIMARY KEY,
  `ward_id` int NOT NULL,
  `household_id` int NOT NULL,
  `month` int NOT NULL,
  `year` int NOT NULL,
  `paid_amount` int,
  `status` varchar(20)
);

CREATE TABLE `complaints` (
  `id` serial PRIMARY KEY,
  `user_id` int NOT NULL,
  `ward_id` int NOT NULL,
  `household_id` int,
  `description` text NOT NULL,
  `status` varchar(20),
  `resolved_by` int,
  `resolution_notes` text
);

CREATE TABLE `notifications` (
  `id` serial PRIMARY KEY,
  `user_id` int NOT NULL,
  `notification_type` varchar(30) NOT NULL,
  `channel` varchar(20) NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `is_read` boolean,
  `sent_at` timestamp
);

CREATE TABLE `activity_log` (
  `id` serial PRIMARY KEY,
  `user_id` int,
  `action` varchar(100) NOT NULL,
  `entity_type` varchar(50) NOT NULL,
  `entity_id` int NOT NULL,
  `changes` jsonb,
  `ip_address` inet,
  `user_agent` text
);

ALTER TABLE `districts` ADD FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`);

ALTER TABLE `wards` ADD FOREIGN KEY (`district_id`) REFERENCES `districts` (`id`);

ALTER TABLE `streets` ADD FOREIGN KEY (`ward_id`) REFERENCES `wards` (`id`);

ALTER TABLE `users` ADD FOREIGN KEY (`ward_id`) REFERENCES `wards` (`id`);

ALTER TABLE `households` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

ALTER TABLE `households` ADD FOREIGN KEY (`ward_id`) REFERENCES `wards` (`id`);

ALTER TABLE `households` ADD FOREIGN KEY (`street_id`) REFERENCES `streets` (`id`);

ALTER TABLE `house_members` ADD FOREIGN KEY (`household_id`) REFERENCES `households` (`id`);

ALTER TABLE `house_members` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

ALTER TABLE `house_members` ADD FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);

ALTER TABLE `collection_points` ADD FOREIGN KEY (`ward_id`) REFERENCES `wards` (`id`);

ALTER TABLE `vehicles` ADD FOREIGN KEY (`assigned_to`) REFERENCES `users` (`id`);

ALTER TABLE `vehicles` ADD FOREIGN KEY (`assigned_driver_id`) REFERENCES `users` (`id`);

ALTER TABLE `vehicles` ADD FOREIGN KEY (`ward_id`) REFERENCES `wards` (`id`);

ALTER TABLE `vehicle_locations` ADD FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`id`);

ALTER TABLE `collection_routes` ADD FOREIGN KEY (`ward_id`) REFERENCES `wards` (`id`);

ALTER TABLE `route_stops` ADD FOREIGN KEY (`route_id`) REFERENCES `collection_routes` (`id`);

ALTER TABLE `route_stops` ADD FOREIGN KEY (`collection_point_id`) REFERENCES `collection_points` (`id`);

ALTER TABLE `collection_schedules` ADD FOREIGN KEY (`route_id`) REFERENCES `collection_routes` (`id`);

ALTER TABLE `collection_schedules` ADD FOREIGN KEY (`assigned_collector`) REFERENCES `users` (`id`);

ALTER TABLE `collection_schedules` ADD FOREIGN KEY (`assigned_driver_id`) REFERENCES `users` (`id`);

ALTER TABLE `collection_schedules` ADD FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`id`);

ALTER TABLE `collection_sessions` ADD FOREIGN KEY (`route_id`) REFERENCES `collection_routes` (`id`);

ALTER TABLE `collection_sessions` ADD FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`id`);

ALTER TABLE `collection_sessions` ADD FOREIGN KEY (`driver_id`) REFERENCES `users` (`id`);

ALTER TABLE `payments` ADD FOREIGN KEY (`household_id`) REFERENCES `households` (`id`);

ALTER TABLE `payments` ADD FOREIGN KEY (`collected_by`) REFERENCES `users` (`id`);

ALTER TABLE `money_collector_records` ADD FOREIGN KEY (`ward_id`) REFERENCES `wards` (`id`);

ALTER TABLE `money_collector_records` ADD FOREIGN KEY (`household_id`) REFERENCES `households` (`id`);

ALTER TABLE `complaints` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

ALTER TABLE `complaints` ADD FOREIGN KEY (`ward_id`) REFERENCES `wards` (`id`);

ALTER TABLE `complaints` ADD FOREIGN KEY (`household_id`) REFERENCES `households` (`id`);

ALTER TABLE `complaints` ADD FOREIGN KEY (`resolved_by`) REFERENCES `users` (`id`);

ALTER TABLE `notifications` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

ALTER TABLE `activity_log` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);
