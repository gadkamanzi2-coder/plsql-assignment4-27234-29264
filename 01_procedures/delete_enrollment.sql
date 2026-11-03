-- Deletes an enrollment and its grade (if any). Shows implicit cursor
-- attributes for DELETE.
CREATE OR REPLACE PROCEDURE delete_enrollment (
  p_enrollment_id IN  enrollments.enrollment_id%TYPE,
  p_grades_deleted OUT NUMBER
)
IS
BEGIN
  DELETE FROM grades WHERE enrollment_id = p_enrollment_id;
  p_grades_deleted := SQL%ROWCOUNT;

  DELETE FROM enrollments WHERE enrollment_id = p_enrollment_id;

  IF SQL%NOTFOUND THEN
    RAISE_APPLICATION_ERROR(-20121,
      'Enrollment ' || p_enrollment_id || ' does not exist. Nothing was deleted.');
  END IF;

  DBMS_OUTPUT.PUT_LINE('Enrollment ' || p_enrollment_id || ' deleted (' ||
    SQL%ROWCOUNT || ' enrollment row, ' || p_grades_deleted || ' grade row).');

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END delete_enrollment;
/
