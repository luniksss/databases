use hospital
GO

/* 3.1(а) Без указания списка полей*/
INSERT INTO child VALUES ('Любовь', 'Николаева', 'Сергеевна', '2005-05-14', 1, 'ул Мишкино д 10', '1230400136');
GO

SELECT * FROM child;
GO

/* 3.1(b) INSERT С указанием списка полей*/
INSERT INTO vaccination (name, type, dosage) VALUES ('реакция манту', 'реакции', 0.5, '2025-02-14');
SELECT * FROM vaccination
GO

/* 3.1(c) С чтением значения из другой таблицы */
CREATE TABLE test_table (
	id INT PRIMARY KEY IDENTITY(1,1),
    name nvarchar(255) NOT NULL,
    type nvarchar(255) NOT NULL,
    dosage float NOT NULL
);

INSERT INTO test_table VALUES ('Последняя вера', 'реакции', 0.75);
INSERT INTO vaccination(name, type, dosage) 
SELECT name, type, dosage FROM test_table;
SELECT * FROM test_table
SELECT * FROM vaccination

/* 3.2(a) DELETE Всех записей*/
DELETE FROM child
SELECT * FROM child
GO

/* 3.2(b) DELETE По условию*/
INSERT INTO child VALUES ('Любовь', 'Николаева', 'Сергеевна', '2005-05-14', 1, 'ул Мишкино д 10', 1230400136);
INSERT INTO child VALUES ('Лариса', 'Николаева', 'Викторовна', '2005-05-16', 1, 'ул Мишкино д 10', 1230400137);
INSERT INTO child VALUES ('Максим', 'Николаев', 'Сергеевич', '2005-03-14', 1, 'ул Мишкино д 10', 1230400138);
SELECT * FROM child
DELETE FROM child WHERE name = 'Любовь';
SELECT * FROM child
GO

/* 3.3(a) UPDATE Всех записей*/
INSERT INTO child VALUES ('Любовь', 'Николаева', 'Сергеевна', '2005-05-14', 1, 'ул Мишкино д 10', 1230400136);
SELECT * FROM child
UPDATE child SET name = 'Liuba', last_name = 'Nikolaeva', middle_name = 'Sergeevna', birthday = '2005-05-15', gender = 2, address = 'ул Баумана 1030', medical_card = 12345678;
SELECT * FROM child
GO

/* 3.3(b) По условию обновляя один атрибут*/
SELECT * FROM child
UPDATE child SET gender = 1 WHERE medical_card = 12345678;
SELECT * FROM child
GO

/* 3.3(c) По условию обновляя несколько атрибутов*/
SELECT * FROM child
UPDATE child SET gender = 2, birthday = '2005-05-14' WHERE medical_card = 12345678;
SELECT * FROM child
GO

/* 3.4(a) SELECT С набором извлекаемых атрибутов (SELECT atr1, atr2 FROM...)*/
SELECT name, last_name FROM child
GO

/* 3.4(b) Со всеми атрибутами (SELECT * FROM...)*/
SELECT * FROM child
GO

/* 3.4(c) С условием по атрибуту (SELECT * FROM ... WHERE atr1 = value)*/
SELECT * FROM child WHERE id = 7
GO

/* 3.5(a) SELECT ORDER BY + TOP (LIMIT) С сортировкой по возрастанию ASC + ограничение вывода количества записей*/
SELECT TOP 2 * FROM child ORDER BY id ASC 
GO

/* 3.5(b) SELECT ORDER BY + TOP (LIMIT) С сортировкой по убыванию DESC*/
SELECT * FROM child ORDER BY id DESC
GO

/* 3.5(c) SELECT ORDER BY + TOP С сортировкой по двум атрибутам + ограничение вывода количества записей*/
SELECT TOP 2 * FROM child ORDER BY medical_card, name
GO

/* 3.5(d) SELECT ORDER BY + TOP С сортировкой по первому атрибуту, из списка извлекаемых*/
SELECT medical_card FROM child ORDER BY name
GO

/* 3.6(a) Работа с датами. WHERE по дате*/
SELECT * FROM child WHERE birthday = '2002-04-10'
GO

/* 3.6(b) Работа с датами. WHERE дата в диапазоне*/
SELECT * FROM child WHERE birthday BETWEEN '2005-01-01' AND '2006-01-01';
GO

/* 3.6(c) Извлечь из таблицы не всю дату, а только год. Например, год рождения автора. Для этого используется функция YEAR*/
SELECT YEAR(birthday) AS birthday FROM child;
GO

/* 3.7(a) Посчитать количество записей в таблице*/
SELECT COUNT(*) FROM child;
GO

/* 3.7(b) Посчитать количество уникальных записей в таблице*/
SELECT COUNT(DISTINCT birthday) FROM child;
GO

/* 3.7(c) Вывести уникальные значения столбца*/
SELECT DISTINCT birthday FROM child;
GO

/* 3.7(d) Найти максимальное значение столбца*/
SELECT MAX(medical_card) FROM child;
GO

/* 3.7(e) Найти минимальное значение столбца*/
SELECT MIN(medical_card) FROM child;
GO

/* 3.7(f) Написать запрос COUNT() + GROUP BY*/
SELECT medical_card, COUNT(*) AS vaccination_count FROM child GROUP BY medical_card;
GO

/* 3.8. SELECT GROUP BY + HAVING Написать 3 разных запроса с использованием GROUP BY + HAVING. 
Для каждого запроса  написать комментарий с пояснением, какую информацию извлекает запрос. 
Запрос должен быть осмысленным, т.е. находить информацию, которую можно использовать.*/

/* список organization_id и количество сотрудников в каждой организации, при условии, что в организации работает три или более сотрудников.*/
SELECT organization_id, COUNT(name) FROM medical_worker GROUP BY organization_id HAVING COUNT(name) >= 3
GO

/* список organization_id и количество должностей в каждой организации, при условии, что в организации меньше 2 должностей.*/
SELECT organization_id, COUNT(position) FROM medical_worker GROUP BY organization_id HAVING COUNT(position) < 2
GO

/* список должностей и сколько раз они встречаются*/
SELECT position, COUNT(organization_id) FROM medical_worker GROUP BY position HAVING COUNT(organization_id) > 0
GO

/* 3.9(a) SELECT JOIN LEFT JOIN двух таблиц и WHERE по одному из атрибутов*/
SELECT * FROM medical_worker 
LEFT JOIN medical_organization
ON medical_worker.organization_id = medical_organization.id
WHERE medical_worker.position = 'Медсестра';
GO

/* 3.9(b) RIGHT JOIN. Получить такую же выборку, как и в 3.9(a)*/
SELECT * FROM medical_organization 
RIGHT JOIN medical_worker
ON medical_worker.organization_id = medical_organization.id
WHERE medical_worker.position = 'Медсестра';
GO

/* 3.9(c) LEFT JOIN трех таблиц + WHERE по атрибуту из каждой таблицы*/
SELECT * FROM medical_worker
LEFT JOIN medical_organization
ON medical_worker.organization_id = medical_organization.id
LEFT JOIN completed_vaccination
ON completed_vaccination.worker_id = medical_worker.id
WHERE medical_worker.id = 1
AND medical_organization.id = 2
AND completed_vaccination.child_id = 7;
GO

/* 3.9(d) INNER JOIN двух таблиц*/
SELECT * FROM medical_worker
INNER JOIN completed_vaccination
ON completed_vaccination.worker_id = medical_worker.id;
GO

/* 3.10(a) Написать запрос с условием WHERE IN (подзапрос)*/
SELECT * FROM medical_worker
WHERE id IN (
    SELECT worker_id 
    FROM completed_vaccination 
    WHERE date = '2024-10-12'
);
GO

/* 3.10(b) Написать запрос SELECT atr1, atr2, (подзапрос) FROM*/
l

/* 3.10(c) Написать запрос вида SELECT * FROM (подзапрос)*/
SELECT * FROM (
    SELECT * 
    FROM child 
    WHERE id >= 8
) AS children;
GO

/* 3.10(d) Написать запрос вида SELECT * FROM table JOIN (подзапрос) ON*/
SELECT * FROM child
JOIN (
    SELECT child_id, COUNT(*) AS vaccination_count
    FROM completed_vaccination
    GROUP BY child_id
    HAVING COUNT(*) > 1
) AS frequent_vaccinations
ON child.id = frequent_vaccinations.child_id;
GO