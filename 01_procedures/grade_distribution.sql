-- Uses all three collection kinds:
--   nested table  (BULK COLLECT target),
--   associative array indexed by VARCHAR2 (letter -> count),
--   VARRAY (the fixed list of possible letters).
CREATE OR REPLACE PROCEDURE grade_distribution (
  p_course_id IN courses.course_id%TYPE,
  p_semester  IN enrollments.semester%TYPE
)
IS
  TYPE t_letter_list IS TABLE OF grades.letter_grade%TYPE;           -- nested table
  TYPE t_count_map   IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(2);   -- associative array
  TYPE t_letter_va   IS VARRAY(5) OF VARCHAR2(2);                    -- VARRAY

  v_letters     t_letter_list;
  v_counts      t_count_map;
  v_all         t_letter_va := t_letter_va('A', 'B', 'C', 'D', 'F');
  v_course_name courses.course_name%TYPE;
BEGIN
  SELECT course_name INTO v_course_name
  FROM   courses
  WHERE  course_id = p_course_id;

  SELECT g.letter_grade BULK COLLECT INTO v_letters
  FROM   grades g
         JOIN enrollments e ON e.enrollment_id = g.enrollment_id
  WHERE  e.course_id = p_course_id
  AND    e.semester  = p_semester;

  IF v_letters.COUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20151,
      'No grades recorded for course ' || p_course_id || ' in ' || p_semester || '.');
  END IF;

  FOR i IN 1 .. v_all.COUNT LOOP
    v_counts(v_all(i)) := 0;
  END LOOP;

  FOR i IN 1 .. v_letters.COUNT LOOP
    v_counts(v_letters(i)) := v_counts(v_letters(i)) + 1;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('Grade distribution: ' || v_course_name ||
    ' (' || p_semester || '), ' || v_letters.COUNT || ' graded students');
  FOR i IN 1 .. v_all.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE(v_all(i) || ' | ' ||
      RPAD('*', v_counts(v_all(i)), '*') || ' ' || v_counts(v_all(i)));
  END LOOP;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20152,
      'Course ' || p_course_id || ' does not exist.');
  WHEN OTHERS THEN
    RAISE;
END grade_distribution;
/
