USE movieplartform;

-- Create Admin User
CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'admin_password';
GRANT ALL PRIVILEGES ON movieplartform.* TO 'admin_user'@'localhost' WITH GRANT OPTION;

-- Create Normal User
CREATE USER 'normal_user'@'localhost' IDENTIFIED BY 'user_password';

-- Grant privileges to Normal User
GRANT SELECT, INSERT ON movieplartform.Review TO 'normal_user'@'localhost';
GRANT SELECT, UPDATE ON movieplartform.User TO 'normal_user'@'localhost';
GRANT SELECT ON movieplartform.Movie TO 'normal_user'@'localhost';
GRANT SELECT ON movieplartform.CastMember TO 'normal_user'@'localhost';
GRANT SELECT ON movieplartform.Watchlist TO 'normal_user'@'localhost';
GRANT SELECT ON movieplartform.MovieGenre TO 'normal_user'@'localhost';

-- Apply Changes
FLUSH PRIVILEGES;

-- Verify Admin Privileges
SHOW GRANTS FOR 'admin_user'@'localhost';

-- Verify Normal User Privileges
SHOW GRANTS FOR 'normal_user'@'localhost';