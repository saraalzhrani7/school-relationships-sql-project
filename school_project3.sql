-- =====================================================
-- مشروع: SQL 103 - العلاقات بين الجداول، Procedures، Views، Indexes
-- الوصف: مشروع مكمّل لمشروع SQL 102، يطبّق تصميم العلاقات
--         (One to Many و Many to Many) و Stored Procedures و
--         Views و Indexes على قاعدة بيانات مدرسية
-- إعداد: سارة الزهراني
-- =====================================================

CREATE DATABASE school_project3;
USE school_project3;

-- =====================================================
-- إعداد الجداول الأساسية
-- =====================================================

-- جدول الطلاب
CREATE TABLE students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_name VARCHAR(100),
    birth_date DATE,
    gender CHAR(1),
    enrollment_date DATE,
    email VARCHAR(100),
    level INT,
    track VARCHAR(20),
    gpa DECIMAL(5,2)
);

INSERT INTO students (student_name, birth_date, gender, enrollment_date, email, level, track, gpa)
VALUES
('سارة العتيبي', '2008-05-14', 'F', '2023-09-01', 'sara1@tamayoz.edu.sa', 3, 'علمي', 92.50),
('نورة القحطاني', '2007-03-10', 'F', '2022-09-01', 'noura@tamayoz.edu.sa', 4, 'انساني', 88.75),
('محمد العتيبي', '2008-11-22', 'M', '2023-09-01', 'mohammed@tamayoz.edu.sa', 3, 'علمي', 95.00),
('ريم الحربي', '2009-01-05', 'F', '2024-09-01', 'reem@tamayoz.edu.sa', 2, 'انساني', 79.30),
('فيصل الحربي', '2008-03-13', 'M', '2025-09-01', 'student5@tamayoz.edu.sa', 1, 'علمي', 80.93);

-- جدول المعلمين
CREATE TABLE teachers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    teacher_name VARCHAR(100),
    birth_date DATE,
    gender CHAR(1),
    email VARCHAR(100),
    office_number VARCHAR(10)
);

INSERT INTO teachers (teacher_name, birth_date, gender, email, office_number)
VALUES
('أ. عبدالرحمن السالم', '1980-04-12', 'M', 'teacher1@tamayoz.edu.sa', '101'),
('أ. منى الزهراني', '1987-02-18', 'F', 'teacher6@tamayoz.edu.sa', '201'),
('أ. فهد المالكي', '1985-07-20', 'M', 'teacher2@tamayoz.edu.sa', '102');

-- جدول المواد
CREATE TABLE subjects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    subject_name VARCHAR(100)
);

INSERT INTO subjects (subject_name)
VALUES
('Mathematics'),
('Physics'),
('Arabic');

-- =====================================================
-- المتطلب 1: علاقة Many to Many بين المعلمين والطلاب
-- (معلم يدرّس أكثر من طالب، وطالب يتعلم من أكثر من معلم)
-- =====================================================
CREATE TABLE teacher_student (
    teacher_id INT,
    student_id INT,
    FOREIGN KEY (teacher_id) REFERENCES teachers(id),
    FOREIGN KEY (student_id) REFERENCES students(id)
);

INSERT INTO teacher_student (teacher_id, student_id)
VALUES
(1, 1), (1, 2), (1, 3),
(2, 1), (2, 4),
(3, 2), (3, 5);

-- =====================================================
-- المتطلب 2: علاقة One to Many بين المواد والمعلمين
-- (معلم يدرّس مادة واحدة فقط، والمادة يدرّسها أكثر من معلم)
-- =====================================================
ALTER TABLE teachers
ADD COLUMN subject_id INT,
ADD FOREIGN KEY (subject_id) REFERENCES subjects(id);

UPDATE teachers SET subject_id = 1 WHERE id = 1;
UPDATE teachers SET subject_id = 2 WHERE id = 2;
UPDATE teachers SET subject_id = 1 WHERE id = 3;

-- =====================================================
-- المتطلب 3: علاقة Many to Many بين المواد والطلاب
-- (طالب يدرس أكثر من مادة، والمادة يدرسها أكثر من طالب)
-- =====================================================
CREATE TABLE student_subject (
    student_id INT,
    subject_id INT,
    FOREIGN KEY (student_id) REFERENCES students(id),
    FOREIGN KEY (subject_id) REFERENCES subjects(id)
);

INSERT INTO student_subject (student_id, subject_id)
VALUES
(1, 1), (1, 2),
(2, 1), (2, 3),
(3, 2), (3, 3),
(4, 1),
(5, 2), (5, 3);

-- =====================================================
-- المتطلب 4: إنشاء Procedure باسم student_info
-- يعرض أسماء الطلاب والمواد (البيانات المشتركة بينهم)
-- =====================================================
DELIMITER //

CREATE PROCEDURE student_info()
BEGIN
    SELECT s.student_name, sub.subject_name
    FROM students s
    JOIN student_subject ss ON s.id = ss.student_id
    JOIN subjects sub ON ss.subject_id = sub.id;
END //

DELIMITER ;

CALL student_info();

-- =====================================================
-- المتطلب 5: إنشاء View باسم teacher_info
-- يحتوي اسم المعلم، رقم المكتب، واسم المادة
-- =====================================================
CREATE VIEW teacher_info AS
SELECT t.teacher_name, t.office_number, sub.subject_name
FROM teachers t
JOIN subjects sub ON t.subject_id = sub.id;

-- عرض الـ view
SELECT * FROM teacher_info;

-- حذف الـ view
DROP VIEW teacher_info;

-- =====================================================
-- المتطلب 6: إنشاء Index للبحث بأسماء الطلاب أبجديًا
-- =====================================================
CREATE INDEX idx_student_name
ON students (student_name);

-- عرض الـ index
SHOW INDEX FROM students;

-- حذف الـ index
DROP INDEX idx_student_name ON students;
