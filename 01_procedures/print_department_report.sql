
CREATE OR REPLACE PROCEDURE print_department_report
IS
  CURSOR c_dept IS
    SELECT d.dept_name,
           COUNT(DISTINCT s.student_id) AS student_count,
           ROUND(AVG(g.score), 2)       AS avg_score
    FROM   departments d
           LEFT JOIN students    s ON s.dept_id       = d.dept_id
           LEFT JOIN enrollments e ON e.student_id    = s.student_id
           LEFT JOIN grades      g ON g.enrollment_id = e.enrollment_id
    GROUP  BY d.dept_name
    ORDER  BY d.dept_name;

  v_best  c_dept%ROWTYPE;
  v_count PLS_INTEGER := 0;
BEGIN
  DBMS_OUTPUT.PUT_LINE(RPAD('Department', 36) || RPAD('Students', 10) || 'Avg score');
  DBMS_OUTPUT.PUT_LINE(RPAD('-', 58, '-'));

  FOR r IN c_dept LOOP
    v_count := v_count + 1;
    DBMS_OUTPUT.PUT_LINE(RPAD(r.dept_name, 36) ||
      RPAD(TO_CHAR(r.student_count), 10) ||
      NVL(TO_CHAR(r.avg_score), 'no grades'));

    IF v_best.dept_name IS NULL
       OR NVL(r.avg_score, -1) > NVL(v_best.avg_score, -1) THEN
      v_best := r;
    END IF;
  END LOOP;

  IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20141, 'There are no departments in the database.');
  END IF;

  DBMS_OUTPUT.PUT_LINE(RPAD('-', 58, '-'));
  DBMS_OUTPUT.PUT_LINE('Best average: ' || v_best.dept_name ||
    ' (' || v_best.avg_score || ')');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('print_department_report failed: ' || SQLERRM);
    RAISE;
END print_department_report;
/
