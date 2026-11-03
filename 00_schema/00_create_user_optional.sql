-- =====================================================================
-- OPTIONAL: create a dedicated schema owner (run as SYSDBA).
-- We used the pluggable database ORCLPDB1 on Oracle 21c.
-- Skip this file if you already have a normal user to run the scripts.
-- =====================================================================
ALTER SESSION SET CONTAINER = ORCLPDB1;

CREATE USER insy_user IDENTIFIED BY Insy#2026
  QUOTA UNLIMITED ON users;

GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE,
      CREATE PROCEDURE, CREATE VIEW, CREATE TYPE TO insy_user;
-- Then connect as INSY_USER (service name ORCLPDB1) and run the other scripts.
