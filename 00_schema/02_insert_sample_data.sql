-- =====================================================================
-- File   : 00_schema/02_insert_sample_data.sql
-- Run AFTER 01_create_tables.sql
-- =====================================================================
SET SERVEROUTPUT ON

-- Departments
INSERT INTO departments VALUES (10, 'Computer Science');
INSERT INTO departments VALUES (20, 'Business Information Technology');
INSERT INTO departments VALUES (30, 'Mathematics');

-- Students (12)
INSERT INTO students VALUES (1001,'Aline','Uwase','aline.uwase@auca.ac.rw',10,DATE '2025-09-01','ACTIVE');
INSERT INTO students VALUES (1002,'Eric','Mugisha','eric.mugisha@auca.ac.rw',10,DATE '2025-09-01','ACTIVE');
INSERT INTO students VALUES (1003,'Grace','Ingabire','grace.ingabire@auca.ac.rw',20,DATE '2025-09-01','ACTIVE');
INSERT INTO students VALUES (1004,'Patrick','Nshuti','patrick.nshuti@auca.ac.rw',10,DATE '2025-09-01','ACTIVE');
INSERT INTO students VALUES (1005,'Diane','Mukamana','diane.mukamana@auca.ac.rw',20,DATE '2025-09-01','ACTIVE');
INSERT INTO students VALUES (1006,'Samuel','Habimana','samuel.habimana@auca.ac.rw',30,DATE '2025-09-01','ACTIVE');
INSERT INTO students VALUES (1007,'Claire','Umutoni','claire.umutoni@auca.ac.rw',20,DATE '2025-09-01','ACTIVE');
INSERT INTO students VALUES (1008,'David','Niyonzima','david.niyonzima@auca.ac.rw',10,DATE '2025-09-01','ACTIVE');
INSERT INTO students VALUES (1009,'Esther','Uwimana','esther.uwimana@auca.ac.rw',30,DATE '2025-09-01','ACTIVE');
INSERT INTO students VALUES (1010,'Jean','Bizimana','jean.bizimana@auca.ac.rw',10,DATE '2025-09-01','SUSPENDED');
INSERT INTO students VALUES (1011,'Marie','Kayitesi','marie.kayitesi@auca.ac.rw',30,DATE '2025-09-01','ACTIVE');
INSERT INTO students VALUES (1012,'Olivier','Ndayisaba','olivier.ndayisaba@auca.ac.rw',10,DATE '2025-09-01','GRADUATED');

-- Courses (6)
INSERT INTO courses VALUES (101,'INSY8311','Database Development with PL/SQL',3,10);
INSERT INTO courses VALUES (102,'INSY8312','Web Development',3,10);
INSERT INTO courses VALUES (103,'INSY8313','Systems Analysis and Design',3,20);
INSERT INTO courses VALUES (104,'MATH2101','Discrete Mathematics',4,30);
INSERT INTO courses VALUES (105,'INSY8314','Computer Networks',3,10);
INSERT INTO courses VALUES (106,'BUSI3101','E-Business',2,20);

-- Enrollments (24), semester 2026-FALL
INSERT INTO enrollments VALUES (1 ,1001,101,'2026-FALL',DATE '2026-09-05');
INSERT INTO enrollments VALUES (2 ,1001,102,'2026-FALL',DATE '2026-09-05');
INSERT INTO enrollments VALUES (3 ,1001,104,'2026-FALL',DATE '2026-09-05');
INSERT INTO enrollments VALUES (4 ,1002,101,'2026-FALL',DATE '2026-09-05');
INSERT INTO enrollments VALUES (5 ,1002,103,'2026-FALL',DATE '2026-09-05');
INSERT INTO enrollments VALUES (6 ,1002,105,'2026-FALL',DATE '2026-09-05');
INSERT INTO enrollments VALUES (7 ,1003,101,'2026-FALL',DATE '2026-09-06');
INSERT INTO enrollments VALUES (8 ,1003,102,'2026-FALL',DATE '2026-09-06');
INSERT INTO enrollments VALUES (9 ,1004,101,'2026-FALL',DATE '2026-09-06');
INSERT INTO enrollments VALUES (10,1004,104,'2026-FALL',DATE '2026-09-06');
INSERT INTO enrollments VALUES (11,1004,106,'2026-FALL',DATE '2026-09-06');
INSERT INTO enrollments VALUES (12,1005,102,'2026-FALL',DATE '2026-09-07');
INSERT INTO enrollments VALUES (13,1005,103,'2026-FALL',DATE '2026-09-07');
INSERT INTO enrollments VALUES (14,1006,101,'2026-FALL',DATE '2026-09-07');
INSERT INTO enrollments VALUES (15,1006,105,'2026-FALL',DATE '2026-09-07');
INSERT INTO enrollments VALUES (16,1007,103,'2026-FALL',DATE '2026-09-08');
INSERT INTO enrollments VALUES (17,1007,106,'2026-FALL',DATE '2026-09-08');
INSERT INTO enrollments VALUES (18,1008,101,'2026-FALL',DATE '2026-09-08');
INSERT INTO enrollments VALUES (19,1008,104,'2026-FALL',DATE '2026-09-08');
INSERT INTO enrollments VALUES (20,1009,102,'2026-FALL',DATE '2026-09-09');
INSERT INTO enrollments VALUES (21,1009,105,'2026-FALL',DATE '2026-09-09');
INSERT INTO enrollments VALUES (22,1010,101,'2026-FALL',DATE '2026-09-09');
INSERT INTO enrollments VALUES (23,1011,104,'2026-FALL',DATE '2026-09-10');
INSERT INTO enrollments VALUES (24,1012,101,'2026-FALL',DATE '2026-09-10');

-- Grades for enrollments 1-16 (17-24 are intentionally ungraded,
-- so the bulk grading procedures have work to do)
INSERT INTO grades VALUES (1 , 1, 85,'A',DATE '2026-12-10');
INSERT INTO grades VALUES (2 , 2, 72,'B',DATE '2026-12-10');
INSERT INTO grades VALUES (3 , 3, 64,'C',DATE '2026-12-10');
INSERT INTO grades VALUES (4 , 4, 91,'A',DATE '2026-12-10');
INSERT INTO grades VALUES (5 , 5, 55,'D',DATE '2026-12-10');
INSERT INTO grades VALUES (6 , 6, 78,'B',DATE '2026-12-10');
INSERT INTO grades VALUES (7 , 7, 45,'F',DATE '2026-12-10');
INSERT INTO grades VALUES (8 , 8, 67,'C',DATE '2026-12-10');
INSERT INTO grades VALUES (9 , 9, 88,'A',DATE '2026-12-10');
INSERT INTO grades VALUES (10,10, 59,'D',DATE '2026-12-10');
INSERT INTO grades VALUES (11,11, 73,'B',DATE '2026-12-10');
INSERT INTO grades VALUES (12,12, 95,'A',DATE '2026-12-10');
INSERT INTO grades VALUES (13,13, 62,'C',DATE '2026-12-10');
INSERT INTO grades VALUES (14,14, 80,'A',DATE '2026-12-10');
INSERT INTO grades VALUES (15,15, 49,'F',DATE '2026-12-10');
INSERT INTO grades VALUES (16,16, 70,'B',DATE '2026-12-10');

COMMIT;

-- Quick verification
SELECT 'departments' AS tbl, COUNT(*) AS rows_count FROM departments UNION ALL
SELECT 'students',    COUNT(*) FROM students    UNION ALL
SELECT 'courses',     COUNT(*) FROM courses     UNION ALL
SELECT 'enrollments', COUNT(*) FROM enrollments UNION ALL
SELECT 'grades',      COUNT(*) FROM grades;
