USE university
GO

SELECT TABLE_NAME AS university
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_SCHEMA = 'dbo';

SELECT * FROM student


/* 1 �������� ������� �����.
ALTER TABLE student ADD FOREIGN KEY (id_group) REFERENCES [group](id_group)
ALTER TABLE lesson ADD FOREIGN KEY (id_teacher) REFERENCES teacher(id_teacher)
ALTER TABLE lesson ADD FOREIGN KEY (id_group) REFERENCES [group](id_group)
ALTER TABLE lesson ADD FOREIGN KEY (id_subject) REFERENCES [subject](id_subject)
ALTER TABLE mark ADD FOREIGN KEY (id_student) REFERENCES student(id_student)
ALTER TABLE mark ADD FOREIGN KEY (id_lesson) REFERENCES lesson(id_lesson) */

-- 2 ������ ������ ��������� �� ����������� ���� ��� ��������� ������� ��������. �������� ������ ������ � �������������� view.
CREATE VIEW StudentInformaticGrades AS
SELECT 
    s.[name] AS [������� ��������],
    m.mark AS [������]
FROM student s
JOIN mark m ON s.id_student = m.id_student
JOIN lesson l ON m.id_lesson = l.id_lesson
JOIN [subject] sb ON l.id_subject = sb.id_subject
WHERE sb.name = '�����������';
GO

SELECT * FROM StudentInformaticGrades;
GO

/* 3 ���� ���������� � ��������� � ��������� ������� �������� � ��������
��������. ���������� ��������� ��������, �� ������� ������ �� ��������,
������� ������� � ������. �������� � ���� ���������, �� �����
������������� ������. */

-- ������� ���������, ��� ��� ������ ������������ ��������
-- DROP PROCEDURE IF EXISTS GetDebtorsByGroup;

-- �������� ���������
CREATE PROCEDURE GetDebtorsByGroup
    @id_group INT
AS
BEGIN
    SELECT 
        s.name AS [������� ��������],
        sb.name AS [�������� ��������]
    FROM student s
    CROSS JOIN subject sb
    JOIN lesson l ON sb.id_subject = l.id_subject AND l.id_group = s.id_group
    LEFT JOIN mark m ON s.id_student = m.id_student AND m.id_lesson = l.id_lesson
    WHERE m.id_mark IS NULL AND s.id_group = @id_group;
END;
GO

EXEC GetDebtorsByGroup @id_group = 3;

-- 4 ���� ������� ������ ��������� �� ������� �������� ��� ��� ���������, �� ������� ���������� �� ����� 35 ���������.
CREATE VIEW AverageMarksBySubject AS
WITH StudentsPerSubject AS (
    SELECT 
        sb.name AS [�������� ��������],
        COUNT(DISTINCT s.id_student) AS [���������� ���������]
    FROM student s
    JOIN lesson l ON s.id_group = l.id_group
    JOIN [subject] sb ON l.id_subject = sb.id_subject
    GROUP BY sb.name
),
AverageMarks AS (
    SELECT 
        sb.name AS [�������� ��������],
        AVG(m.mark) AS [������� ������]
    FROM student s
    JOIN mark m ON s.id_student = m.id_student
    JOIN lesson l ON m.id_lesson = l.id_lesson
    JOIN [subject] sb ON l.id_subject = sb.id_subject
    GROUP BY sb.name
)
SELECT 
    sps.[�������� ��������],
    am.[������� ������]
FROM StudentsPerSubject sps
JOIN AverageMarks am ON sps.[�������� ��������] = am.[�������� ��������]
WHERE sps.[���������� ���������] >= 35;
GO

SELECT * FROM AverageMarksBySubject;

/* 5 ���� ������ ��������� ������������� �� �� ���� ���������� ��������� �
��������� ������, �������, ��������, ����. ��� ���������� ������ ���������
���������� ���� ������. */
SELECT 
    g.[name] AS [������],
    s.[name] AS [������� ��������],
    sb.[name] AS [�������� ��������],
    l.[date] AS [���� �������],
	COALESCE(m.mark, 0) AS [������]
FROM student s
JOIN [group] g ON s.id_group = g.id_group
JOIN lesson l ON s.id_group = l.id_group
JOIN [subject] sb ON l.id_subject = sb.id_subject
LEFT JOIN mark m ON s.id_student = m.id_student AND m.id_lesson = l.id_lesson
WHERE g.[name] = '��';
GO

-- 6 ���� ��������� ������������� ��, ���������� ������ ������� 5 �� �������� �� �� 12.05, �������� ��� ������ �� 1 ����.
BEGIN TRANSACTION;

UPDATE m
SET m.mark = m.mark + 1
FROM mark m
JOIN lesson l ON m.id_lesson = l.id_lesson
JOIN [subject] sb ON l.id_subject = sb.id_subject
JOIN student s ON m.id_student = s.id_student
JOIN [group] g ON s.id_group = g.id_group
WHERE g.[name] = '��' AND sb.[name] = '��' AND l.[date] <= '2019-05-12' AND m.mark < 5;

COMMIT TRANSACTION;
-- ROLLBACK TRANSACTION;


-- 7 �������� ����������� �������.
CREATE INDEX IX_group_name ON [group]([name]);
CREATE INDEX IX_subject_name ON [subject]([name]);
CREATE INDEX IX_lesson_date ON lesson([date]);