-- =====================================================================
-- File: 00_schema/03_create_types_and_perf_table.sql
-- Schema-level collection type (nested table) used as a procedure
-- parameter, and a table used by the bulk-vs-loop performance test.
-- =====================================================================
CREATE OR REPLACE TYPE t_number_list AS TABLE OF NUMBER;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE perf_test PURGE';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN   -- ignore only "table does not exist"
      RAISE;
    END IF;
END;
/

CREATE TABLE perf_test (
  id       NUMBER        CONSTRAINT pk_perf_test PRIMARY KEY,
  val      VARCHAR2(50),
  created  DATE DEFAULT SYSDATE
);
