# Group Assignment IV: Advanced Oracle PL/SQL Programming

**Course:** Database Development with PL/SQL (INSY 8311)  
**Instructor:** Eric Maniraguha | **Class group:** B (Tuesday)  
**Topic:** Records, Collections, Cursors, Bulk Processing, Stored Procedures, Functions and Exception Handling

## Group members

| Full name | Student ID |
|---|---|
| Kamanzi Gad | 27234 |
| Ntwazangabo Fabrice | 29264 |

## Application: Student Registration and Grading System

A university database that records departments, students, courses, enrollments (a student taking a course in a semester) and grades. The PL/SQL layer lets staff register students, change student status, remove enrollments, load and adjust grades in bulk, produce rosters and reports, and calculate GPAs.

### Requirements
1. Store departments, students, courses, enrollments and grades with proper keys and constraints.
2. A student can be enrolled in a course only once per semester.
3. Only ACTIVE students can register for courses.
4. Scores are between 0 and 100 and map to a letter grade (A: 80+, B: 70+, C: 60+, D: 50+, F: below 50).
5. Grades can be loaded and curved in bulk, and bad rows must be reported without stopping the whole load.
6. Reports: course roster, department summary, grade distribution, student GPA, course average.
7. Every error produces a clear message; unexpected errors are never silently ignored.

## Database schema

```
DEPARTMENTS (dept_id PK, dept_name UNIQUE)
   | 1                               | 1
   | N                               | N
STUDENTS (student_id PK, ..., dept_id FK, status CHECK)     COURSES (course_id PK, course_code UNIQUE, credits CHECK 1-6, dept_id FK)
   | 1                                                          | 1
   | N                                                          | N
        ENROLLMENTS (enrollment_id PK, student_id FK, course_id FK, semester,
                     UNIQUE (student_id, course_id, semester))
              | 1
              | 0..1
        GRADES (grade_id PK, enrollment_id FK UNIQUE, score CHECK 0-100, letter_grade CHECK A-F)

ERROR_LOG  (log_id PK, proc_name, error_code, error_msg, logged_at)   -- bulk errors
PERF_TEST  (id PK, val, created)                                      -- performance demo
```

Sample data: 3 departments, 12 students, 6 courses, 24 enrollments, 16 grades.

## Where each required concept is demonstrated

| Requirement | Where |
|---|---|
| User-defined records | `print_course_roster` (`t_roster_rec`) |
| `%ROWTYPE` records | `register_student_course`, `print_course_roster`, `print_department_report` (`c_dept%ROWTYPE`) |
| Associative arrays | `grade_distribution`, `apply_curve_bulk`, `compare_bulk_vs_loop` |
| Nested tables | `grade_distribution`, `bulk_load_grades`, schema type `t_number_list` |
| VARRAY | `grade_distribution` (`t_letter_va`) |
| Implicit cursors (`SQL%ROWCOUNT`, `SQL%FOUND`, `SQL%NOTFOUND`) | `register_student_course`, `update_student_status`, `delete_enrollment`, `apply_curve_bulk` |
| Explicit cursors | `print_course_roster` (OPEN/FETCH/CLOSE), `print_department_report` (cursor FOR loop), `fn_student_gpa` |
| `BULK COLLECT` | `grade_distribution`, `apply_curve_bulk` |
| `FORALL` + `SAVE EXCEPTIONS` | `bulk_load_grades`, `apply_curve_bulk`, `compare_bulk_vs_loop` |
| Stored procedures (IN/OUT) | all files in `01_procedures/` |
| Stored functions | all files in `02_functions/` (called from SQL and from PL/SQL blocks in the tests) |
| Predefined exceptions | `NO_DATA_FOUND`, `TOO_MANY_ROWS`, `DUP_VAL_ON_INDEX`, `ZERO_DIVIDE` |
| User-defined exceptions + `RAISE_APPLICATION_ERROR` | all procedures and functions (codes -20020 to -20181) |

## How to run

Use Oracle Database 21c and SQL Developer. Run every script with **Run Script (F5)** as a normal user (we used `INSY_USER` on the pluggable database `ORCLPDB1`; see `00_schema/00_create_user_optional.sql`).

1. `00_schema/01_create_tables.sql`
2. `00_schema/02_insert_sample_data.sql`
3. `00_schema/03_create_types_and_perf_table.sql` (collection type and performance table)
4. Compile the functions in `02_functions/` (the procedures call `fn_letter_grade`, so functions come first)
5. Compile the procedures in `01_procedures/`
6. Run `03_tests/test_success_cases.sql`
7. Run `03_tests/test_error_cases.sql` (every line must start with PASS)
8. Compare with the screenshots in `screenshots/`

The test scripts restore the data they change, so they can be run again.

## Tests and screenshots

| Screenshot | What it shows |
|---|---|
| `schema_and_data_output.png` | Row counts after loading the sample data |
| `s1_functions_output.png` | Functions called from SQL and from a PL/SQL block |
| `s2_implicit_cursors_output.png` | INSERT, UPDATE, DELETE with implicit cursor attributes and OUT parameters |
| `s3_explicit_cursors_output.png` | Explicit cursors: roster and department report |
| `s4_collections_output.png` | Nested table, associative array and VARRAY |
| `s5_bulk_processing_output.png` | BULK COLLECT, FORALL insert and update |
| `s6_performance_output.png` | Row-by-row versus FORALL timing |
| `e0_predefined_exceptions_output.png` | NO_DATA_FOUND, TOO_MANY_ROWS, ZERO_DIVIDE, DUP_VAL_ON_INDEX |
| `e1_function_errors_output.png` | Function error handling |
| `e2_procedure_errors_output.png` | Procedure error handling |
| `e3_bulk_errors_output.png` | Bulk DML errors with SAVE EXCEPTIONS and ERROR_LOG |

Implementation and performance explanation: `docs/IMPLEMENTATION_NOTES.md`.

## Contributions

| Member | Contribution |
|---|---|
| Kamanzi Gad (27234) | Environment setup, schema, PL/SQL code, running all tests, screenshots, documentation and GitHub upload |
| Ntwazangabo Fabrice (29264) | Was unwell during the assignment week and could not take part in the implementation. He will review the submitted work and join the presentation. |

## Use of an AI assistant

We used an AI assistant (Claude, by Anthropic) during this assignment. It helped us to: plan the work step by step; design the Student Registration and Grading scenario; draft the SQL and PL/SQL code and the test scripts; and draft this README and the implementation notes. We installed and ran all scripts ourselves in Oracle, fixed the environment problems (listener, pluggable database, user creation), executed every test, and took the screenshots from our own runs. Both group members are responsible for the submission and are prepared to explain every part of the code individually.
