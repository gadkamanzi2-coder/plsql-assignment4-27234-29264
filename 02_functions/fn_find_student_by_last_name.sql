
CREATE OR REPLACE FUNCTION fn_find_student_by_last_name (
  p_last_name IN students.last_name%TYPE
) RETURN NUMBER
IS
  v_id students.student_id%TYPE;
BEGIN
  SELECT student_id INTO v_id
  FROM   students
  WHERE  UPPER(last_name) = UPPER(p_last_name);

  RETURN v_id;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20030,
      'No student found with last name ' || p_last_name || '.');
  WHEN TOO_MANY_ROWS THEN
    RAISE_APPLICATION_ERROR(-20031,
      'More than one student has last name ' || p_last_name ||
      '. Search by student ID instead.');
END fn_find_student_by_last_name;
/
