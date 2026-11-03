
CREATE OR REPLACE PROCEDURE compare_bulk_vs_loop (
  p_rows IN PLS_INTEGER DEFAULT 20000
)
IS
  TYPE t_id_tab  IS TABLE OF NUMBER       INDEX BY PLS_INTEGER;
  TYPE t_val_tab IS TABLE OF VARCHAR2(50) INDEX BY PLS_INTEGER;

  v_ids       t_id_tab;
  v_vals      t_val_tab;
  v_start     NUMBER;
  v_loop_cs   NUMBER;
  v_bulk_cs   NUMBER;
  e_invalid_rows EXCEPTION;
BEGIN
  IF p_rows IS NULL OR p_rows < 1 OR p_rows > 100000 THEN
    RAISE e_invalid_rows;
  END IF;

  DELETE FROM perf_test;
  COMMIT;


  v_start := DBMS_UTILITY.GET_TIME;
  FOR i IN 1 .. p_rows LOOP
    INSERT INTO perf_test (id, val) VALUES (i, 'Row ' || i);
  END LOOP;
  v_loop_cs := DBMS_UTILITY.GET_TIME - v_start;
  ROLLBACK;


  FOR i IN 1 .. p_rows LOOP
    v_ids(i)  := i;
    v_vals(i) := 'Row ' || i;
  END LOOP;

  v_start := DBMS_UTILITY.GET_TIME;
  FORALL i IN 1 .. p_rows
    INSERT INTO perf_test (id, val) VALUES (v_ids(i), v_vals(i));
  v_bulk_cs := DBMS_UTILITY.GET_TIME - v_start;
  ROLLBACK;

  DBMS_OUTPUT.PUT_LINE('Rows inserted per method : ' || p_rows);
  DBMS_OUTPUT.PUT_LINE('Row-by-row loop          : ' || (v_loop_cs * 10) || ' ms');
  DBMS_OUTPUT.PUT_LINE('FORALL bulk insert       : ' || (v_bulk_cs * 10) || ' ms');
  IF v_bulk_cs > 0 THEN
    DBMS_OUTPUT.PUT_LINE('Bulk is about ' || ROUND(v_loop_cs / v_bulk_cs, 1) || 'x faster.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Bulk was too fast to measure (under 10 ms).');
  END IF;
EXCEPTION
  WHEN e_invalid_rows THEN
    RAISE_APPLICATION_ERROR(-20181,
      'p_rows must be between 1 and 100000.');
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END compare_bulk_vs_loop;
/
