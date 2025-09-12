-- Create database
CREATE DATABASE IF NOT EXISTS myapp;

-- Use the database
USE myapp;

-- Create a messages table
CREATE TABLE IF NOT EXISTS messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    message VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert some test data
INSERT INTO messages (message) VALUES 
('Hello from MySQL on EC2!'),
('Welcome to the three-tier app backend'),
('Database successfully initialized.');
