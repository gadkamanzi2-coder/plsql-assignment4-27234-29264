-- Explicit cursor with a parameter: OPEN / FETCH / CLOSE.
-- Uses a user-defined record type and a %ROWTYPE record.
CREATE OR REPLACE PROCEDURE print_course_roster (
  p_course_id IN courses.course_id%TYPE,
  p_semester  IN enrollments.semester%TYPE
)
IS
  v_course courses%ROWTYPE;

  TYPE t_roster_rec IS RECORD (          -- user-defined record
    student_id   students.student_id%TYPE,
    full_name    VARCHAR2(90),
    score        grades.score%TYPE,
    letter_grade grades.letter_grade%TYPE
  );
  v_row t_roster_rec;

  CURSOR c_roster (cp_course NUMBER, cp_semester VARCHAR2) IS
    SELECT s.student_id,
           s.first_name || ' ' || s.last_name,
           g.score,
           g.letter_grade
    FROM   enrollments e
           JOIN students s     ON s.student_id     = e.student_id
           LEFT JOIN grades g  ON g.enrollment_id  = e.enrollment_id
    WHERE  e.course_id = cp_course
    AND    e.semester  = cp_semester
    ORDER  BY s.last_name;

  v_count        PLS_INTEGER := 0;
  e_empty_roster EXCEPTION;
BEGIN
  BEGIN
    SELECT * INTO v_course FROM courses WHERE course_id = p_course_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20131,
        'Course ' || p_course_id || ' does not exist.');
  END;

  DBMS_OUTPUT.PUT_LINE('ROSTER: ' || v_course.course_code || ' - ' ||
    v_course.course_name || ' (' || p_semester || ')');
  DBMS_OUTPUT.PUT_LINE(RPAD('ID', 8) || RPAD('Student', 28) ||
    RPAD('Score', 8) || 'Grade');
  DBMS_OUTPUT.PUT_LINE(RPAD('-', 50, '-'));

  OPEN c_roster(p_course_id, p_semester);
  LOOP
    FETCH c_roster INTO v_row;
    EXIT WHEN c_roster%NOTFOUND;
    v_count := v_count + 1;
    DBMS_OUTPUT.PUT_LINE(
      RPAD(TO_CHAR(v_row.student_id), 8) ||
      RPAD(v_row.full_name, 28) ||
      RPAD(NVL(TO_CHAR(v_row.score), '-'), 8) ||
      NVL(v_row.letter_grade, 'Not graded'));
  END LOOP;
  CLOSE c_roster;

  IF v_count = 0 THEN
    RAISE e_empty_roster;
  END IF;

  DBMS_OUTPUT.PUT_LINE(RPAD('-', 50, '-'));
  DBMS_OUTPUT.PUT_LINE('Total students: ' || v_count);
EXCEPTION
  WHEN e_empty_roster THEN
    RAISE_APPLICATION_ERROR(-20132,
      'No students are enrolled in course ' || p_course_id ||
      ' for ' || p_semester || '.');
  WHEN OTHERS THEN
    IF c_roster%ISOPEN THEN
      CLOSE c_roster;
    END IF;
    RAISE;
END print_course_roster;
/
