-- Bulk INSERT with FORALL ... SAVE EXCEPTIONS.
-- Good rows are inserted, bad rows are reported and written to ERROR_LOG
-- instead of stopping the whole load.
CREATE OR REPLACE PROCEDURE bulk_load_grades (
  p_enrollment_ids IN  t_number_list,
  p_scores         IN  t_number_list,
  p_inserted       OUT NUMBER,
  p_failed         OUT NUMBER
)
IS
  TYPE t_letter_list IS TABLE OF VARCHAR2(2);
  TYPE t_int_map     IS TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER;

  v_letters   t_letter_list := t_letter_list();
  v_err_idx   t_int_map;
  v_err_code  t_int_map;
  v_total     PLS_INTEGER;
  v_err_count PLS_INTEGER;
  v_msg       VARCHAR2(500);

  ex_bulk_errors EXCEPTION;
  PRAGMA EXCEPTION_INIT(ex_bulk_errors, -24381);
  e_list_problem EXCEPTION;
BEGIN
  p_inserted := 0;
  p_failed   := 0;

  IF p_enrollment_ids IS NULL OR p_scores IS NULL
     OR p_enrollment_ids.COUNT = 0
     OR p_enrollment_ids.COUNT <> p_scores.COUNT THEN
    RAISE e_list_problem;
  END IF;

  v_total := p_enrollment_ids.COUNT;
  v_letters.EXTEND(v_total);

  FOR i IN 1 .. v_total LOOP
    IF p_scores(i) BETWEEN 0 AND 100 THEN
      v_letters(i) := fn_letter_grade(p_scores(i));
    ELSE
      -- placeholder only: the row is rejected by the CHECK constraint
      -- and reported through SAVE EXCEPTIONS below
      v_letters(i) := 'F';
    END IF;
  END LOOP;

  FORALL i IN 1 .. v_total SAVE EXCEPTIONS
    INSERT INTO grades (grade_id, enrollment_id, score, letter_grade, graded_date)
    VALUES (seq_grade.NEXTVAL, p_enrollment_ids(i), p_scores(i), v_letters(i), SYSDATE);

  p_inserted := v_total;
  DBMS_OUTPUT.PUT_LINE('Bulk load finished: ' || p_inserted || ' rows inserted, 0 failed.');
  COMMIT;
EXCEPTION
  WHEN ex_bulk_errors THEN
    v_err_count := SQL%BULK_EXCEPTIONS.COUNT;
    FOR j IN 1 .. v_err_count LOOP
      v_err_idx(j)  := SQL%BULK_EXCEPTIONS(j).ERROR_INDEX;
      v_err_code(j) := SQL%BULK_EXCEPTIONS(j).ERROR_CODE;
    END LOOP;

    FOR j IN 1 .. v_err_count LOOP
      v_msg := SUBSTR('Row ' || v_err_idx(j) || ' (enrollment ' ||
                 p_enrollment_ids(v_err_idx(j)) || '): ' ||
                 SQLERRM(-v_err_code(j)), 1, 500);
      INSERT INTO error_log (log_id, proc_name, error_code, error_msg)
      VALUES (seq_error_log.NEXTVAL, 'BULK_LOAD_GRADES', -v_err_code(j), v_msg);
      DBMS_OUTPUT.PUT_LINE('  Rejected -> ' || v_msg);
    END LOOP;

    p_failed   := v_err_count;
    p_inserted := v_total - v_err_count;
    DBMS_OUTPUT.PUT_LINE('Bulk load finished: ' || p_inserted ||
      ' rows inserted, ' || p_failed || ' failed (see ERROR_LOG).');
    COMMIT;
  WHEN e_list_problem THEN
    RAISE_APPLICATION_ERROR(-20161,
      'Enrollment and score lists must be non-empty and have the same size.');
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END bulk_load_grades;
/
