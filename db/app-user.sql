/**
 * Create a new user.
 */
CREATE USER IF NOT EXISTS `$USERNAME`@`$HOST` IDENTIFIED BY '$PASSOWRD';

/**
 * Assign permission to view existing database.
 */
GRANT SHOW DATABASES ON *.* TO `$USERNAME`@`$HOST` IDENTIFIED BY '$PASSOWRD';

/**
 * Set "roles".
 */
GRANT
    ALTER,
    CREATE,
    CREATE VIEW,
    DROP,
    CREATE TEMPORARY TABLES,
    CREATE ROUTINE,
    EVENT,
    LOCK TABLES,
    INSERT,
    DELETE,
    UPDATE,
    SELECT,
    INDEX,
    REFERENCES,
    SHOW VIEW,
    TRIGGER
ON $DB_NAME.* TO `$USERNAME`@`$HOST` IDENTIFIED BY '$PASSOWRD';

/**
 * Revoke role to change database structures.
 * Runs only after creating/updating the database.
 */
REVOKE
    ALTER,
    CREATE,
    CREATE VIEW,
    DROP,
    CREATE ROUTINE,
    REFERENCES
ON $DB_NAME.* FROM `$USERNAME`@`$HOST`;