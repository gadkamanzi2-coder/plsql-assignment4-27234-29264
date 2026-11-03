
CREATE OR REPLACE PROCEDURE update_student_status (
  p_student_id   IN  students.student_id%TYPE,
  p_new_status   IN  students.status%TYPE,
  p_rows_updated OUT NUMBER
)
IS
  e_invalid_status EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_invalid_status, -2290);
BEGIN
  UPDATE students
  SET    status = UPPER(p_new_status)
  WHERE  student_id = p_student_id;

  p_rows_updated := SQL%ROWCOUNT;

  IF SQL%NOTFOUND THEN
    RAISE_APPLICATION_ERROR(-20111,
      'Student ' || p_student_id || ' does not exist. Nothing was updated.');
  END IF;

  IF SQL%FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Student ' || p_student_id || ' status set to ' ||
      UPPER(p_new_status) || '. Rows updated: ' || p_rows_updated);
  END IF;

  COMMIT;
EXCEPTION
  WHEN e_invalid_status THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20112,
      'Invalid status ' || p_new_status ||
      '. Allowed: ACTIVE, SUSPENDED, GRADUATED.');
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END update_student_status;
/
