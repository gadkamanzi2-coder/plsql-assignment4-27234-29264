
CREATE OR REPLACE FUNCTION fn_student_gpa (
  p_student_id IN students.student_id%TYPE
) RETURN NUMBER
IS
  v_id       students.student_id%TYPE;
  v_points   NUMBER := 0;
  v_credits  NUMBER := 0;

  CURSOR c_grades IS
    SELECT c.credits, g.letter_grade
    FROM   enrollments e
           JOIN courses c ON c.course_id     = e.course_id
           JOIN grades  g ON g.enrollment_id = e.enrollment_id
    WHERE  e.student_id = p_student_id;
BEGIN
  BEGIN
    SELECT student_id INTO v_id
    FROM   students
    WHERE  student_id = p_student_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20021,
        'Student ' || p_student_id || ' does not exist.');
  END;

  FOR r IN c_grades LOOP
    v_points  := v_points + r.credits *
                 CASE r.letter_grade
                   WHEN 'A' THEN 4
                   WHEN 'B' THEN 3
                   WHEN 'C' THEN 2
                   WHEN 'D' THEN 1
                   ELSE 0
                 END;
    v_credits := v_credits + r.credits;
  END LOOP;

  IF v_credits = 0 THEN
    RETURN NULL;
  END IF;

  RETURN ROUND(v_points / v_credits, 2);
  -- No catch-all handler on purpose: unexpected errors must reach the caller.
END fn_student_gpa;
/
