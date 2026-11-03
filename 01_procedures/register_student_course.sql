
CREATE OR REPLACE PROCEDURE register_student_course (
  p_student_id    IN  students.student_id%TYPE,
  p_course_id     IN  courses.course_id%TYPE,
  p_semester      IN  enrollments.semester%TYPE,
  p_enrollment_id OUT enrollments.enrollment_id%TYPE
)
IS
  v_student students%ROWTYPE;   -- %ROWTYPE record
  v_course  courses%ROWTYPE;    -- %ROWTYPE record
  e_student_not_active EXCEPTION;   -- user-defined exception
BEGIN
  BEGIN
    SELECT * INTO v_student FROM students WHERE student_id = p_student_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20101,
        'Student ' || p_student_id || ' does not exist.');
  END;

  BEGIN
    SELECT * INTO v_course FROM courses WHERE course_id = p_course_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20102,
        'Course ' || p_course_id || ' does not exist.');
  END;

  IF v_student.status <> 'ACTIVE' THEN
    RAISE e_student_not_active;
  END IF;

  INSERT INTO enrollments (enrollment_id, student_id, course_id, semester, enroll_date)
  VALUES (seq_enrollment.NEXTVAL, p_student_id, p_course_id, p_semester, SYSDATE)
  RETURNING enrollment_id INTO p_enrollment_id;

  IF SQL%ROWCOUNT = 1 THEN
    DBMS_OUTPUT.PUT_LINE('Registered ' || v_student.first_name || ' ' ||
      v_student.last_name || ' in ' || v_course.course_code ||
      ' (' || p_semester || '). Enrollment ID = ' || p_enrollment_id);
  END IF;

  COMMIT;
EXCEPTION
  WHEN e_student_not_active THEN
    RAISE_APPLICATION_ERROR(-20103,
      'Student ' || p_student_id || ' has status ' || v_student.status ||
      ' and cannot register for courses.');
  WHEN DUP_VAL_ON_INDEX THEN
    RAISE_APPLICATION_ERROR(-20104,
      'Student ' || p_student_id || ' is already enrolled in course ' ||
      p_course_id || ' for ' || p_semester || '.');
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;   
END register_student_course;
/
