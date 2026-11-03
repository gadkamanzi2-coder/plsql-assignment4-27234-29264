
CREATE OR REPLACE FUNCTION fn_course_average (
  p_course_id IN courses.course_id%TYPE,
  p_semester  IN enrollments.semester%TYPE
) RETURN NUMBER
IS
  v_course_name courses.course_name%TYPE;
  v_avg         NUMBER;
BEGIN
  SELECT course_name INTO v_course_name
  FROM   courses
  WHERE  course_id = p_course_id;

  SELECT AVG(g.score) INTO v_avg
  FROM   grades g
         JOIN enrollments e ON e.enrollment_id = g.enrollment_id
  WHERE  e.course_id = p_course_id
  AND    e.semester  = p_semester;

  RETURN ROUND(v_avg, 2);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20022,
      'Course ' || p_course_id || ' does not exist.');
END fn_course_average;
/
