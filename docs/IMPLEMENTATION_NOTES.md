# Implementation and Performance Notes

## 1. Design overview

The application is a Student Registration and Grading System with five core tables (`departments`, `students`, `courses`, `enrollments`, `grades`) plus two helper tables (`error_log` for bulk errors, `perf_test` for the performance demo).

Integrity rules live in the database as constraints, so they hold no matter which program writes the data: primary and foreign keys, `UNIQUE (student_id, course_id, semester)`, `CHECK` constraints on status, credits, score and letter grade.

The PL/SQL layer has 4 functions and 9 procedures. Functions are written first because procedures call `fn_letter_grade`.

## 2. Records
- **User-defined record:** `t_roster_rec` in `print_course_roster` holds one cursor row (id, name, score, letter) in a single variable.
- **`%ROWTYPE`:** `students%ROWTYPE` and `courses%ROWTYPE` in `register_student_course` load a whole row with `SELECT *`. `c_dept%ROWTYPE` in `print_department_report` copies the best department row between variables.

## 3. Collections
- **Nested table:** result of `BULK COLLECT` in `grade_distribution`; schema type `t_number_list` carries lists of ids and scores into `bulk_load_grades`.
- **Associative array:** `INDEX BY VARCHAR2` maps a letter to its count in `grade_distribution`; `INDEX BY PLS_INTEGER` holds ids, scores and letters in `apply_curve_bulk`.
- **VARRAY:** `t_letter_va` is the fixed list of 5 possible letters.

## 4. Cursors
- **Implicit:** `SQL%ROWCOUNT` (rows affected), `SQL%FOUND` and `SQL%NOTFOUND` after INSERT, UPDATE and DELETE. `update_student_status` and `delete_enrollment` use `SQL%NOTFOUND` to raise a clear error when nothing matched instead of silently doing nothing.
- **Explicit:** `print_course_roster` uses a parameterised cursor with OPEN, FETCH, `%NOTFOUND` and CLOSE (closed also in the exception handler through `%ISOPEN`). `print_department_report` uses a cursor FOR loop. `fn_student_gpa` loops over a cursor to weight grades by credits.

## 5. Bulk processing and performance

**Row-by-row problem.** A PL/SQL `FOR` loop that runs one `INSERT` per iteration switches between the PL/SQL engine and the SQL engine on every row. With thousands of rows these *context switches* dominate the run time.

**Bulk solution.**
- `BULK COLLECT` fetches all rows into a collection with a single switch.
- `FORALL` sends the whole collection to the SQL engine in one call, which runs the DML for every element.

**Measured result** (`compare_bulk_vs_loop(20000)` on our machine, 20,000 inserted rows per method):

| Method | Time |
|---|---|
| Row-by-row `FOR` loop | 730 ms |
| `FORALL` | 30 ms |
| Speed-up | about 24x (an earlier run gave about 13x; the ratio varies with load) |

**Bulk exception handling.** `bulk_load_grades` uses `FORALL ... SAVE EXCEPTIONS`. Without it, the first bad row aborts the whole statement. With it, Oracle keeps going, inserts all good rows and raises ORA-24381 at the end. The handler reads `SQL%BULK_EXCEPTIONS` (index and error code of each failed row), prints it and writes it to `error_log`. In our test, 4 rows were sent: 1 inserted, 3 rejected (duplicate grade ORA-00001, missing enrollment ORA-02291, score of 150 ORA-02290).

**Trade-offs.** Collections live in session memory, so very large loads should be fetched in chunks with `BULK COLLECT ... LIMIT`. For this assignment the data volume is small.

## 6. Exception-handling strategy

- Predefined exceptions are caught where they are meaningful (`NO_DATA_FOUND`, `TOO_MANY_ROWS`, `DUP_VAL_ON_INDEX`) and converted into a clear `RAISE_APPLICATION_ERROR` message.
- User-defined exceptions (`e_student_not_active`, `e_empty_roster`, `e_bad_points`, `e_list_problem`, `e_invalid_status`, `ex_bulk_errors`) separate business-rule failures from system errors.
- Procedures end with `WHEN OTHERS THEN ROLLBACK; RAISE;`, so unexpected errors are never swallowed. Functions have no catch-all handler on purpose.
- Functions never return misleading values: `fn_student_gpa` and `fn_course_average` return `NULL` (not 0) when nothing is graded, and invalid input raises an error.

| Code | Raised by | Meaning |
|---|---|---|
| -20020 | `fn_letter_grade` | Score outside 0 to 100 |
| -20021 | `fn_student_gpa` | Student does not exist |
| -20022 | `fn_course_average` | Course does not exist |
| -20030 / -20031 | `fn_find_student_by_last_name` | No student / more than one student |
| -20101 / -20102 | `register_student_course` | Student / course does not exist |
| -20103 | `register_student_course` | Student not ACTIVE (user-defined exception) |
| -20104 | `register_student_course` | Already enrolled (`DUP_VAL_ON_INDEX`) |
| -20111 / -20112 | `update_student_status` | Student not found (`SQL%NOTFOUND`) / invalid status (ORA-02290) |
| -20121 | `delete_enrollment` | Enrollment not found |
| -20131 / -20132 | `print_course_roster` | Course not found / empty roster |
| -20141 | `print_department_report` | No departments |
| -20151 / -20152 | `grade_distribution` | No grades / course not found |
| -20161 | `bulk_load_grades` | Lists empty or different sizes |
| -20171 / -20172 / -20173 | `apply_curve_bulk` | Curve out of range / no grades / course not found |
| -20181 | `compare_bulk_vs_loop` | Row count out of range |

## 7. Testing
- `test_success_cases.sql` exercises every object successfully and restores the data afterwards.
- `test_error_cases.sql` triggers 37 error situations. Each prints `PASS` only if the expected error code is raised, and `FAIL` otherwise. All 37 printed PASS.
- Every test is backed by a screenshot in `screenshots/`.

## 8. Limitations
- Procedures commit their own work for simplicity; in a larger system the caller would control the transaction.
- Letter-grade boundaries are fixed in `fn_letter_grade`; a grading-scale table would make them configurable.
