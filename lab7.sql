USE university
GO

SELECT TABLE_NAME AS university
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_SCHEMA = 'dbo';

SELECT * FROM student


/* 1 Добавить внешние ключи.
ALTER TABLE student ADD FOREIGN KEY (id_group) REFERENCES [group](id_group)
ALTER TABLE lesson ADD FOREIGN KEY (id_teacher) REFERENCES teacher(id_teacher)
ALTER TABLE lesson ADD FOREIGN KEY (id_group) REFERENCES [group](id_group)
ALTER TABLE lesson ADD FOREIGN KEY (id_subject) REFERENCES [subject](id_subject)
ALTER TABLE mark ADD FOREIGN KEY (id_student) REFERENCES student(id_student)
ALTER TABLE mark ADD FOREIGN KEY (id_lesson) REFERENCES lesson(id_lesson) */

-- 2 Выдать оценки студентов по информатике если они обучаются данному предмету. Оформить выдачу данных с использованием view.
CREATE VIEW StudentInformaticGrades AS
SELECT 
    s.[name] AS [Фамилия студента],
    m.mark AS [Оценка]
FROM student s
JOIN mark m ON s.id_student = m.id_student
JOIN lesson l ON m.id_lesson = l.id_lesson
JOIN [subject] sb ON l.id_subject = sb.id_subject
WHERE sb.name = 'Информатика';
GO

SELECT * FROM StudentInformaticGrades;
GO

/* 3 Дать информацию о должниках с указанием фамилии студента и названия
предмета. Должниками считаются студенты, не имеющие оценки по предмету,
который ведется в группе. Оформить в виде процедуры, на входе
идентификатор группы. */

-- удалить процедуру, так как нельзя использовать повторно
-- DROP PROCEDURE IF EXISTS GetDebtorsByGroup;

-- создание процедуры
CREATE PROCEDURE GetDebtorsByGroup
    @id_group INT
AS
BEGIN
    SELECT 
        s.name AS [Фамилия студента],
        sb.name AS [Название предмета]
    FROM student s
    CROSS JOIN subject sb
    JOIN lesson l ON sb.id_subject = l.id_subject AND l.id_group = s.id_group
    LEFT JOIN mark m ON s.id_student = m.id_student AND m.id_lesson = l.id_lesson
    WHERE m.id_mark IS NULL AND s.id_group = @id_group;
END;
GO

EXEC GetDebtorsByGroup @id_group = 3;

-- 4 Дать среднюю оценку студентов по каждому предмету для тех предметов, по которым занимается не менее 35 студентов.
CREATE VIEW AverageMarksBySubject AS
WITH StudentsPerSubject AS (
    SELECT 
        sb.name AS [Название предмета],
        COUNT(DISTINCT s.id_student) AS [Количество студентов]
    FROM student s
    JOIN lesson l ON s.id_group = l.id_group
    JOIN [subject] sb ON l.id_subject = sb.id_subject
    GROUP BY sb.name
),
AverageMarks AS (
    SELECT 
        sb.name AS [Название предмета],
        AVG(m.mark) AS [Средняя оценка]
    FROM student s
    JOIN mark m ON s.id_student = m.id_student
    JOIN lesson l ON m.id_lesson = l.id_lesson
    JOIN [subject] sb ON l.id_subject = sb.id_subject
    GROUP BY sb.name
)
SELECT 
    sps.[Название предмета],
    am.[Средняя оценка]
FROM StudentsPerSubject sps
JOIN AverageMarks am ON sps.[Название предмета] = am.[Название предмета]
WHERE sps.[Количество студентов] >= 35;
GO

SELECT * FROM AverageMarksBySubject;

/* 5 Дать оценки студентов специальности ВМ по всем проводимым предметам с
указанием группы, фамилии, предмета, даты. При отсутствии оценки заполнить
значениями поля оценки. */
SELECT 
    g.[name] AS [Группа],
    s.[name] AS [Фамилия студента],
    sb.[name] AS [Название предмета],
    l.[date] AS [Дата занятия],
	COALESCE(m.mark, 0) AS [Оценка]
FROM student s
JOIN [group] g ON s.id_group = g.id_group
JOIN lesson l ON s.id_group = l.id_group
JOIN [subject] sb ON l.id_subject = sb.id_subject
LEFT JOIN mark m ON s.id_student = m.id_student AND m.id_lesson = l.id_lesson
WHERE g.[name] = 'ВМ';
GO

-- 6 Всем студентам специальности ПС, получившим оценки меньшие 5 по предмету БД до 12.05, повысить эти оценки на 1 балл.
BEGIN TRANSACTION;

UPDATE m
SET m.mark = m.mark + 1
FROM mark m
JOIN lesson l ON m.id_lesson = l.id_lesson
JOIN [subject] sb ON l.id_subject = sb.id_subject
JOIN student s ON m.id_student = s.id_student
JOIN [group] g ON s.id_group = g.id_group
WHERE g.[name] = 'ПС' AND sb.[name] = 'БД' AND l.[date] <= '2019-05-12' AND m.mark < 5;

COMMIT TRANSACTION;
-- ROLLBACK TRANSACTION;


-- 7 Добавить необходимые индексы.
CREATE INDEX IX_group_name ON [group]([name]);
CREATE INDEX IX_subject_name ON [subject]([name]);
CREATE INDEX IX_lesson_date ON lesson([date]);