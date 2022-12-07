GRANT
    SHOW DATABASES,
    ALTER,
    CREATE,
    CREATE VIEW,
    INSERT,
    DELETE,
    UPDATE,
    INDEX,
    SELECT,
    REFERENCES,
    SHOW VIEW,
    TRIGGER,
    DROP
ON *.* TO 'username'@'%' IDENTIFIED BY 'userpass';

GRANT
    CREATE,
    CREATE ROUTINE,
    CREATE TEMPORARY TABLES,
    EVENT,
    LOCK TABLES
ON db_glpi.* TO 'username'@'%' IDENTIFIED BY 'userpass';
