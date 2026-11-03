-- =====================================================================
-- File: 03_tests/test_success_cases.sql
-- Successful executions. Run AFTER schema + all procedures/functions.
-- Safe to re-run: it restores the data it changes.
-- =====================================================================
SET SERVEROUTPUT ON SIZE UNLIMITED

-- ---------- Housekeeping: remove leftovers from earlier runs ----------
DELETE FROM grades      WHERE grade_id > 16;
DELETE FROM enrollments WHERE student_id = 1008 AND course_id = 102;
DELETE FROM error_log;
COMMIT;

PROMPT
PROMPT ==================== S1: FUNCTIONS ====================
PROMPT -- Functions called from a SQL statement
SELECT student_id, first_name, last_name,
       fn_student_gpa(student_id) AS gpa
FROM   students
ORDER  BY student_id;

SELECT course_code, course_name,
       fn_course_average(course_id, '2026-FALL') AS avg_score
FROM   courses
ORDER  BY course_code;

PROMPT -- Functions called from an anonymous PL/SQL block
DECLARE
  v_id NUMBER;
BEGIN
  DBMS_OUTPUT.PUT_LINE('fn_letter_grade(95) = ' || fn_letter_grade(95));
  DBMS_OUTPUT.PUT_LINE('fn_letter_grade(72) = ' || fn_letter_grade(72));
  DBMS_OUTPUT.PUT_LINE('fn_letter_grade(49) = ' || fn_letter_grade(49));
  v_id := fn_find_student_by_last_name('Mugisha');
  DBMS_OUTPUT.PUT_LINE('Student found by last name Mugisha -> ID ' || v_id ||
                       ', GPA ' || fn_student_gpa(v_id));
END;
/

PROMPT
PROMPT ========== S2: IMPLICIT CURSORS, OUT PARAMETERS, RECORDS ==========
DECLARE
  v_enr   NUMBER;
  v_rows  NUMBER;
  v_gr    NUMBER;
BEGIN
  register_student_course(1008, 102, '2026-FALL', v_enr);   -- INSERT
  DBMS_OUTPUT.PUT_LINE('OUT parameter -> new enrollment id = ' || v_enr);

  update_student_status(1010, 'ACTIVE', v_rows);            -- UPDATE
  DBMS_OUTPUT.PUT_LINE('OUT parameter -> rows updated = ' || v_rows);
  update_student_status(1010, 'SUSPENDED', v_rows);         -- restore original status

  delete_enrollment(v_enr, v_gr);                           -- DELETE
  DBMS_OUTPUT.PUT_LINE('OUT parameter -> grades deleted = ' || v_gr);
END;
/

PROMPT
PROMPT ================= S3: EXPLICIT CURSORS =================
BEGIN
  print_course_roster(101, '2026-FALL');       -- OPEN / FETCH / CLOSE
  DBMS_OUTPUT.PUT_LINE(' ');
  print_department_report;                     -- cursor FOR loop
END;
/

PROMPT
PROMPT ============ S4: COLLECTIONS (nested table, assoc. array, VARRAY) ============
BEGIN
  grade_distribution(101, '2026-FALL');
  DBMS_OUTPUT.PUT_LINE(' ');
  grade_distribution(104, '2026-FALL');
END;
/

PROMPT
PROMPT ============ S5: BULK PROCESSING (BULK COLLECT + FORALL) ============
DECLARE
  v_ids    t_number_list := t_number_list(17, 18, 19);
  v_scores t_number_list := t_number_list(66, 84, 58);
  v_ins    NUMBER;
  v_fail   NUMBER;
  v_upd    NUMBER;
BEGIN
  bulk_load_grades(v_ids, v_scores, v_ins, v_fail);          -- FORALL INSERT
  DBMS_OUTPUT.PUT_LINE('Inserted = ' || v_ins || ', failed = ' || v_fail);

  apply_curve_bulk(101, '2026-FALL', 5, v_upd);              -- BULK COLLECT + FORALL UPDATE
  print_course_roster(101, '2026-FALL');

  apply_curve_bulk(101, '2026-FALL', -5, v_upd);             -- undo the curve
END;
/

SELECT g.grade_id, g.enrollment_id, g.score, g.letter_grade
FROM   grades g
WHERE  g.grade_id > 16
ORDER  BY g.grade_id;

PROMPT
PROMPT ============ S6: PERFORMANCE (row-by-row vs FORALL) ============
BEGIN
  compare_bulk_vs_loop(20000);
END;
/

-- ---------- Restore the original data ----------
DELETE FROM grades WHERE grade_id > 16;
COMMIT;
PROMPT
PROMPT All success tests finished. Data restored.
