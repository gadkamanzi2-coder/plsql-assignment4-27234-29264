
CREATE OR REPLACE PROCEDURE apply_curve_bulk (
  p_course_id IN  courses.course_id%TYPE,
  p_semester  IN  enrollments.semester%TYPE,
  p_points    IN  NUMBER,
  p_updated   OUT NUMBER
)
IS
  TYPE t_num_tab IS TABLE OF NUMBER      INDEX BY PLS_INTEGER;
  TYPE t_chr_tab IS TABLE OF VARCHAR2(2) INDEX BY PLS_INTEGER;

  v_ids         t_num_tab;
  v_scores      t_num_tab;
  v_letters     t_chr_tab;
  v_course_name courses.course_name%TYPE;
  e_bad_points  EXCEPTION;
BEGIN
  p_updated := 0;

  IF p_points IS NULL OR p_points < -20 OR p_points > 20 THEN
    RAISE e_bad_points;
  END IF;

  SELECT course_name INTO v_course_name
  FROM   courses
  WHERE  course_id = p_course_id;

  SELECT g.grade_id, g.score
  BULK COLLECT INTO v_ids, v_scores
  FROM   grades g
         JOIN enrollments e ON e.enrollment_id = g.enrollment_id
  WHERE  e.course_id = p_course_id
  AND    e.semester  = p_semester;

  IF v_ids.COUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20172,
      'No grades to adjust for course ' || p_course_id || ' in ' || p_semester || '.');
  END IF;

  FOR i IN 1 .. v_ids.COUNT LOOP
    v_scores(i)  := LEAST(100, GREATEST(0, v_scores(i) + p_points));
    v_letters(i) := fn_letter_grade(v_scores(i));
  END LOOP;

  FORALL i IN 1 .. v_ids.COUNT
    UPDATE grades
    SET    score        = v_scores(i),
           letter_grade = v_letters(i)
    WHERE  grade_id     = v_ids(i);

  p_updated := SQL%ROWCOUNT;
  DBMS_OUTPUT.PUT_LINE('Curve of ' || p_points || ' points applied to ' ||
    v_course_name || ': ' || p_updated || ' grades updated.');
  COMMIT;
EXCEPTION
  WHEN e_bad_points THEN
    RAISE_APPLICATION_ERROR(-20171,
      'Curve must be between -20 and +20 points.');
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20173,
      'Course ' || p_course_id || ' does not exist.');
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END apply_curve_bulk;
/
