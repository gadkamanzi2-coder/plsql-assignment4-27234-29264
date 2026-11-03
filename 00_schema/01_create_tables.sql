
SET SERVEROUTPUT ON
BEGIN
  FOR t IN (SELECT table_name FROM user_tables
            WHERE table_name IN ('GRADES','ENROLLMENTS','COURSES',
                                 'STUDENTS','DEPARTMENTS','ERROR_LOG')) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
  END LOOP;
  FOR s IN (SELECT sequence_name FROM user_sequences
            WHERE sequence_name IN ('SEQ_STUDENT','SEQ_ENROLLMENT',
                                    'SEQ_GRADE','SEQ_ERROR_LOG')) LOOP
    EXECUTE IMMEDIATE 'DROP SEQUENCE ' || s.sequence_name;
  END LOOP;
END;
/

2.TABLES
CREATE TABLE departments (
  dept_id    NUMBER(3)     CONSTRAINT pk_departments PRIMARY KEY,
  dept_name  VARCHAR2(60)  NOT NULL
                           CONSTRAINT uq_dept_name UNIQUE
);

CREATE TABLE students (
  student_id       NUMBER(6)     CONSTRAINT pk_students PRIMARY KEY,
  first_name       VARCHAR2(40)  NOT NULL,
  last_name        VARCHAR2(40)  NOT NULL,
  email            VARCHAR2(100) NOT NULL
                                 CONSTRAINT uq_student_email UNIQUE,
  dept_id          NUMBER(3)     NOT NULL
                                 CONSTRAINT fk_student_dept
                                 REFERENCES departments(dept_id),
  enrollment_date  DATE          DEFAULT SYSDATE NOT NULL,
  status           VARCHAR2(10)  DEFAULT 'ACTIVE' NOT NULL
                                 CONSTRAINT ck_student_status
                                 CHECK (status IN ('ACTIVE','SUSPENDED','GRADUATED'))
);

CREATE TABLE courses (
  course_id    NUMBER(4)     CONSTRAINT pk_courses PRIMARY KEY,
  course_code  VARCHAR2(10)  NOT NULL
                             CONSTRAINT uq_course_code UNIQUE,
  course_name  VARCHAR2(80)  NOT NULL,
  credits      NUMBER(1)     NOT NULL
                             CONSTRAINT ck_course_credits CHECK (credits BETWEEN 1 AND 6),
  dept_id      NUMBER(3)     NOT NULL
                             CONSTRAINT fk_course_dept
                             REFERENCES departments(dept_id)
);

CREATE TABLE enrollments (
  enrollment_id  NUMBER(8)    CONSTRAINT pk_enrollments PRIMARY KEY,
  student_id     NUMBER(6)    NOT NULL
                              CONSTRAINT fk_enr_student
                              REFERENCES students(student_id),
  course_id      NUMBER(4)    NOT NULL
                              CONSTRAINT fk_enr_course
                              REFERENCES courses(course_id),
  semester       VARCHAR2(12) NOT NULL,
  enroll_date    DATE         DEFAULT SYSDATE NOT NULL,
  CONSTRAINT uq_enrollment UNIQUE (student_id, course_id, semester)
);

CREATE TABLE grades (
  grade_id       NUMBER(8)   CONSTRAINT pk_grades PRIMARY KEY,
  enrollment_id  NUMBER(8)   NOT NULL
                             CONSTRAINT uq_grade_enrollment UNIQUE
                             CONSTRAINT fk_grade_enrollment
                             REFERENCES enrollments(enrollment_id),
  score          NUMBER(5,2) NOT NULL
                             CONSTRAINT ck_grade_score CHECK (score BETWEEN 0 AND 100),
  letter_grade   VARCHAR2(2) NOT NULL
                             CONSTRAINT ck_grade_letter
                             CHECK (letter_grade IN ('A','B','C','D','F')),
  graded_date    DATE        DEFAULT SYSDATE NOT NULL
);

CREATE TABLE error_log (
  log_id      NUMBER(8)      CONSTRAINT pk_error_log PRIMARY KEY,
  proc_name   VARCHAR2(60),
  error_code  NUMBER,
  error_msg   VARCHAR2(500),
  logged_at   DATE DEFAULT SYSDATE
);

CREATE SEQUENCE seq_student    START WITH 1013 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_enrollment START WITH 25   INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_grade      START WITH 17   INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_error_log  START WITH 1    INCREMENT BY 1 NOCACHE;


CREATE INDEX idx_enr_student ON enrollments(student_id);
CREATE INDEX idx_enr_course  ON enrollments(course_id);

PROMPT Tables, constraints, sequences and indexes created successfully.
