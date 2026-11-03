
SET SERVEROUTPUT ON SIZE UNLIMITED

DELETE FROM grades WHERE grade_id > 16;
DELETE FROM error_log;
COMMIT;

PROMPT
PROMPT ========== E0: PREDEFINED EXCEPTIONS ==========
DECLARE
  v_name students.first_name%TYPE;
BEGIN
  SELECT first_name INTO v_name FROM students WHERE student_id = 99999;
  DBMS_OUTPUT.PUT_LINE('E00 FAIL - no error raised');
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('E00 PASS | NO_DATA_FOUND caught (no student 99999)');
END;
/
DECLARE
  v_name students.first_name%TYPE;
BEGIN
  SELECT first_name INTO v_name FROM students WHERE dept_id = 10;
  DBMS_OUTPUT.PUT_LINE('E01 FAIL - no error raised');
EXCEPTION
  WHEN TOO_MANY_ROWS THEN
    DBMS_OUTPUT.PUT_LINE('E01 PASS | TOO_MANY_ROWS caught (many students in dept 10)');
END;
/
DECLARE
  v_zero NUMBER := 0;
  v_res  NUMBER;
BEGIN
  v_res := 10 / v_zero;
  DBMS_OUTPUT.PUT_LINE('E02 FAIL - no error raised');
EXCEPTION
  WHEN ZERO_DIVIDE THEN
    DBMS_OUTPUT.PUT_LINE('E02 PASS | ZERO_DIVIDE caught');
END;
/
BEGIN
  INSERT INTO departments VALUES (10, 'Duplicate department id');
  DBMS_OUTPUT.PUT_LINE('E03 FAIL - no error raised');
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    DBMS_OUTPUT.PUT_LINE('E03 PASS | DUP_VAL_ON_INDEX caught');
END;
/

PROMPT
PROMPT ========== E1: FUNCTION ERRORS (RAISE_APPLICATION_ERROR) ==========
DECLARE v VARCHAR2(10);
BEGIN
  v := fn_letter_grade(150);
  DBMS_OUTPUT.PUT_LINE('E10 FAIL - no error raised');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('E10 ' || CASE WHEN SQLCODE = -20020 THEN 'PASS' ELSE 'FAIL' END || ' | ' || SQLERRM);
END;
/
DECLARE v NUMBER;
BEGIN
  v := fn_student_gpa(9999);
  DBMS_OUTPUT.PUT_LINE('E11 FAIL - no error raised');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('E11 ' || CASE WHEN SQLCODE = -20021 THEN 'PASS' ELSE 'FAIL' END || ' | ' || SQLERRM);
END;
/
DECLARE v NUMBER;
BEGIN
  v := fn_course_average(999, '2026-FALL');
  DBMS_OUTPUT.PUT_LINE('E12 FAIL - no error raised');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('E12 ' || CASE WHEN SQLCODE = -20022 THEN 'PASS' ELSE 'FAIL' END || ' | ' || SQLERRM);
END;
/
DECLARE v NUMBER;
BEGIN
  v := fn_find_student_by_last_name('Nobody');
  DBMS_OUTPUT.PUT_LINE('E13 FAIL - no error raised');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('E13 ' || CASE WHEN SQLCODE = -20030 THEN 'PASS' ELSE 'FAIL' END || ' | ' || SQLERRM);
END;
/

-- TOO_MANY_ROWS inside a function: add a second student with the same last name
INSERT INTO students VALUES (1013, 'Alice', 'Uwase', 'alice.uwase@auca.ac.rw', 10, SYSDATE, 'ACTIVE');
DECLARE v NUMBER;
BEGIN
  v := fn_find_student_by_last_name('Uwase');
  DBMS_OUTPUT.PUT_LINE('E14 FAIL - no error raised');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('E14 ' || CASE WHEN SQLCODE = -20031 THEN 'PASS' ELSE 'FAIL' END || ' | ' || SQLERRM);
END;
/
ROLLBACK;

PROMPT
PROMPT ========== E2: PROCEDURE ERRORS ==========
DECLARE v NUMBER;
BEGIN
  register_student_course(9999, 101, '2026-FALL', v);
  DBMS_OUTPUT.PUT_LINE('E20 FAIL - no error raised');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('E20 ' || CASE WHEN SQLCODE = -20101 THEN 'PASS' ELSE 'FAIL' END || ' | ' || SQLERRM);
END;
/
DECLARE v NUMBER;
BEGIN
  register_student_course(1001, 999, '2026-FALL', v);
  DBMS_OUTPUT.PUT_LINE('E21 FAIL - no error raised');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('E21 ' || CASE WHEN SQLCODE = -20102 THEN 'PASS' ELSE 'FAIL' END || ' | ' || SQLERRM);
END;
/
DECLARE v NUMBER;
BEGIN
  register_student_course(1010, 101, '2027-SPRING', v);   -- suspended student
  DBMS_OUTPUT.PUT_LINE('E22 FAIL - no error raised');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('E22 ' || CASE WHEN SQLCODE = -20103 THEN 'PASS' ELSE 'FAIL' END || ' | ' || SQLERRM);
END;
/
DECLARE v NUMBER;
BEGIN
  register_student_course(1001, 101, '2026-FALL', v);     -- already enrolled
  DBMS_OUTPUT.PUT_LINE('E23 FAIL - no error raised');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('E23 ' || CASE WHEN SQLCODE = -20104 THEN 'PASS' ELSE 'FAIL' END || ' | ' || SQLERRM);
END;
/
DECLARE v NUMBER;
BEGIN
  update_student_status(9999, 'ACTIVE', v);               -- SQL%NOTFOUND
  DBMS_OUTPUT.PUT_LINE('E24 FAIL - no error raised');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('E24 ' || CASE WHEN SQLCODE = -20111 THEN 'PASS' ELSE 'FAIL' END || ' | ' || SQLERRM);
END;
/
DECLARE v NUMBER;
BEGIN
  update_student_status(1001, 'EXPELLED', v);             -- CHECK constraint
  DBMS_OUTPUT.PUT_LINE('E25 FAIL - no error raised');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('E25 ' || CASE WHEN SQLCODE = -20112 THEN 'PASS' ELSE 'FAIL' END || ' | ' || SQLERRM);
END;
/
DECLARE v NUMBER;
BEGIN
  delete_enrollment(9999, v);
  DBMS_OUTPUT.PUT_LINE('E26 FAIL - no error raised');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('E26 ' || CASE WHEN SQLCODE = -20121 THEN 'PASS' ELSE 'FAIL' END || ' | ' || SQLERRM);
END;
/
BEGIN
  print_course_roster(999, '2026-FALL');
  DBMS_OUTPUT.PUT_LINE('E27 FAIL - no error raised');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('E27 ' || CASE WHEN SQLCODE = -20131 THEN 'PASS' ELSE 'FAIL' END || ' | ' || SQLERRM);
END;
/
BEGIN
  print_course_roster(106, '2025-SPRING');                -- nobody enrolled
  DBMS_OUTPUT.PUT_LINE('E28 FAIL - no error raised');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('E28 ' || CASE WHEN SQLCODE = -20132 THEN 'PASS' ELSE 'FAIL' END || ' | ' || SQLERRM);
END;
/
BEGIN
  grade_distribution(101, '2099-FALL');                   -- no grades
  DBMS_OUTPUT.PUT_LINE('E29 FAIL - no error raised');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('E29 ' || CASE WHEN SQLCODE = -20151 THEN 'PASS' ELSE 'FAIL' END || ' | ' || SQLERRM);
END;
/
BEGIN
  grade_distribution(999, '2026-FALL');                   -- unknown course
  DBMS_OUTPUT.PUT_LINE('E30 FAIL - no error raised');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('E30 ' || CASE WHEN SQLCODE = -20152 THEN 'PASS' ELSE 'FAIL' END || ' | ' || SQLERRM);
END;
/

PROMPT
PROMPT ========== E3: BULK PROCESSING ERRORS ==========
DECLARE v NUMBER;
BEGIN
  apply_curve_bulk(101, '2026-FALL', 50, v);              -- curve too large
  DBMS_OUTPUT.PUT_LINE('E31 FAIL - no error raised');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('E31 ' || CASE WHEN SQLCODE = -20171 THEN 'PASS' ELSE 'FAIL' END || ' | ' || SQLERRM);
END;
/
DECLARE v NUMBER;
BEGIN
  apply_curve_bulk(106, '2099-FALL', 5, v);               -- nothing to update
  DBMS_OUTPUT.PUT_LINE('E32 FAIL - no error raised');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('E32 ' || CASE WHEN SQLCODE = -20172 THEN 'PASS' ELSE 'FAIL' END || ' | ' || SQLERRM);
END;
/
DECLARE v NUMBER;
BEGIN
  apply_curve_bulk(999, '2026-FALL', 5, v);               -- unknown course
  DBMS_OUTPUT.PUT_LINE('E33 FAIL - no error raised');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('E33 ' || CASE WHEN SQLCODE = -20173 THEN 'PASS' ELSE 'FAIL' END || ' | ' || SQLERRM);
END;
/
BEGIN
  compare_bulk_vs_loop(0);
  DBMS_OUTPUT.PUT_LINE('E34 FAIL - no error raised');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('E34 ' || CASE WHEN SQLCODE = -20181 THEN 'PASS' ELSE 'FAIL' END || ' | ' || SQLERRM);
END;
/
DECLARE
  v_ids t_number_list := t_number_list(17, 18);
  v_sc  t_number_list := t_number_list(60);               -- lists differ in size
  v_ins NUMBER;
  v_fail NUMBER;
BEGIN
  bulk_load_grades(v_ids, v_sc, v_ins, v_fail);
  DBMS_OUTPUT.PUT_LINE('E35 FAIL - no error raised');
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('E35 ' || CASE WHEN SQLCODE = -20161 THEN 'PASS' ELSE 'FAIL' END || ' | ' || SQLERRM);
END;
/


DECLARE
  v_ids  t_number_list := t_number_list(17, 1, 99999, 18);
  v_sc   t_number_list := t_number_list(66, 70, 80, 150);
  v_ins  NUMBER;
  v_fail NUMBER;
BEGIN
  bulk_load_grades(v_ids, v_sc, v_ins, v_fail);
  DBMS_OUTPUT.PUT_LINE('E36 ' || CASE WHEN v_ins = 1 AND v_fail = 3 THEN 'PASS' ELSE 'FAIL' END ||
                       ' | inserted=' || v_ins || ', failed=' || v_fail);
END;
/

PROMPT -- Errors recorded in ERROR_LOG by the bulk load
SELECT log_id, proc_name, error_code, error_msg FROM error_log ORDER BY log_id;

-- ---------- Restore the original data ----------
DELETE FROM grades WHERE grade_id > 16;
COMMIT;
PROMPT
PROMPT All error tests finished. Every line above should start with PASS.
