use hospital
GO

/* 3.1(�) ��� �������� ������ �����*/
INSERT INTO child VALUES ('������', '���������', '���������', '2005-05-14', 1, '�� ������� � 10', '1230400136');
GO

SELECT * FROM child;
GO

/* 3.1(b) INSERT � ��������� ������ �����*/
INSERT INTO vaccination (name, type, dosage) VALUES ('������� �����', '�������', 0.5, '2025-02-14');
SELECT * FROM vaccination
GO

/* 3.1(c) � ������� �������� �� ������ ������� */
CREATE TABLE test_table (
	id INT PRIMARY KEY IDENTITY(1,1),
    name nvarchar(255) NOT NULL,
    type nvarchar(255) NOT NULL,
    dosage float NOT NULL
);

INSERT INTO test_table VALUES ('��������� ����', '�������', 0.75);
INSERT INTO vaccination(name, type, dosage) 
SELECT name, type, dosage FROM test_table;
SELECT * FROM test_table
SELECT * FROM vaccination

/* 3.2(a) DELETE ���� �������*/
DELETE FROM child
SELECT * FROM child
GO

/* 3.2(b) DELETE �� �������*/
INSERT INTO child VALUES ('������', '���������', '���������', '2005-05-14', 1, '�� ������� � 10', 1230400136);
INSERT INTO child VALUES ('������', '���������', '����������', '2005-05-16', 1, '�� ������� � 10', 1230400137);
INSERT INTO child VALUES ('������', '��������', '���������', '2005-03-14', 1, '�� ������� � 10', 1230400138);
SELECT * FROM child
DELETE FROM child WHERE name = '������';
SELECT * FROM child
GO

/* 3.3(a) UPDATE ���� �������*/
INSERT INTO child VALUES ('������', '���������', '���������', '2005-05-14', 1, '�� ������� � 10', 1230400136);
SELECT * FROM child
UPDATE child SET name = 'Liuba', last_name = 'Nikolaeva', middle_name = 'Sergeevna', birthday = '2005-05-15', gender = 2, address = '�� ������� 1030', medical_card = 12345678;
SELECT * FROM child
GO

/* 3.3(b) �� ������� �������� ���� �������*/
SELECT * FROM child
UPDATE child SET gender = 1 WHERE medical_card = 12345678;
SELECT * FROM child
GO

/* 3.3(c) �� ������� �������� ��������� ���������*/
SELECT * FROM child
UPDATE child SET gender = 2, birthday = '2005-05-14' WHERE medical_card = 12345678;
SELECT * FROM child
GO

/* 3.4(a) SELECT � ������� ����������� ��������� (SELECT atr1, atr2 FROM...)*/
SELECT name, last_name FROM child
GO

/* 3.4(b) �� ����� ���������� (SELECT * FROM...)*/
SELECT * FROM child
GO

/* 3.4(c) � �������� �� �������� (SELECT * FROM ... WHERE atr1 = value)*/
SELECT * FROM child WHERE id = 7
GO

/* 3.5(a) SELECT ORDER BY + TOP (LIMIT) � ����������� �� ����������� ASC + ����������� ������ ���������� �������*/
SELECT TOP 2 * FROM child ORDER BY id ASC 
GO

/* 3.5(b) SELECT ORDER BY + TOP (LIMIT) � ����������� �� �������� DESC*/
SELECT * FROM child ORDER BY id DESC
GO

/* 3.5(c) SELECT ORDER BY + TOP � ����������� �� ���� ��������� + ����������� ������ ���������� �������*/
SELECT TOP 2 * FROM child ORDER BY medical_card, name
GO

/* 3.5(d) SELECT ORDER BY + TOP � ����������� �� ������� ��������, �� ������ �����������*/
SELECT medical_card FROM child ORDER BY name
GO

/* 3.6(a) ������ � ������. WHERE �� ����*/
SELECT * FROM child WHERE birthday = '2002-04-10'
GO

/* 3.6(b) ������ � ������. WHERE ���� � ���������*/
SELECT * FROM child WHERE birthday BETWEEN '2005-01-01' AND '2006-01-01';
GO

/* 3.6(c) ������� �� ������� �� ��� ����, � ������ ���. ��������, ��� �������� ������. ��� ����� ������������ ������� YEAR*/
SELECT YEAR(birthday) AS birthday FROM child;
GO

/* 3.7(a) ��������� ���������� ������� � �������*/
SELECT COUNT(*) FROM child;
GO

/* 3.7(b) ��������� ���������� ���������� ������� � �������*/
SELECT COUNT(DISTINCT birthday) FROM child;
GO

/* 3.7(c) ������� ���������� �������� �������*/
SELECT DISTINCT birthday FROM child;
GO

/* 3.7(d) ����� ������������ �������� �������*/
SELECT MAX(medical_card) FROM child;
GO

/* 3.7(e) ����� ����������� �������� �������*/
SELECT MIN(medical_card) FROM child;
GO

/* 3.7(f) �������� ������ COUNT() + GROUP BY*/
SELECT medical_card, COUNT(*) AS vaccination_count FROM child GROUP BY medical_card;
GO

/* 3.8. SELECT GROUP BY + HAVING �������� 3 ������ ������� � �������������� GROUP BY + HAVING. 
��� ������� �������  �������� ����������� � ����������, ����� ���������� ��������� ������. 
������ ������ ���� �����������, �.�. �������� ����������, ������� ����� ������������.*/

/* ������ organization_id � ���������� ����������� � ������ �����������, ��� �������, ��� � ����������� �������� ��� ��� ����� �����������.*/
SELECT organization_id, COUNT(name) FROM medical_worker GROUP BY organization_id HAVING COUNT(name) >= 3
GO

/* ������ organization_id � ���������� ���������� � ������ �����������, ��� �������, ��� � ����������� ������ 2 ����������.*/
SELECT organization_id, COUNT(position) FROM medical_worker GROUP BY organization_id HAVING COUNT(position) < 2
GO

/* ������ ���������� � ������� ��� ��� �����������*/
SELECT position, COUNT(organization_id) FROM medical_worker GROUP BY position HAVING COUNT(organization_id) > 0
GO

/* 3.9(a) SELECT JOIN LEFT JOIN ���� ������ � WHERE �� ������ �� ���������*/
SELECT * FROM medical_worker 
LEFT JOIN medical_organization
ON medical_worker.organization_id = medical_organization.id
WHERE medical_worker.position = '���������';
GO

/* 3.9(b) RIGHT JOIN. �������� ����� �� �������, ��� � � 3.9(a)*/
SELECT * FROM medical_organization 
RIGHT JOIN medical_worker
ON medical_worker.organization_id = medical_organization.id
WHERE medical_worker.position = '���������';
GO

/* 3.9(c) LEFT JOIN ���� ������ + WHERE �� �������� �� ������ �������*/
SELECT * FROM medical_worker
LEFT JOIN medical_organization
ON medical_worker.organization_id = medical_organization.id
LEFT JOIN completed_vaccination
ON completed_vaccination.worker_id = medical_worker.id
WHERE medical_worker.id = 1
AND medical_organization.id = 2
AND completed_vaccination.child_id = 7;
GO

/* 3.9(d) INNER JOIN ���� ������*/
SELECT * FROM medical_worker
INNER JOIN completed_vaccination
ON completed_vaccination.worker_id = medical_worker.id;
GO

/* 3.10(a) �������� ������ � �������� WHERE IN (���������)*/
SELECT * FROM medical_worker
WHERE id IN (
    SELECT worker_id 
    FROM completed_vaccination 
    WHERE date = '2024-10-12'
);
GO

/* 3.10(b) �������� ������ SELECT atr1, atr2, (���������) FROM*/
l

/* 3.10(c) �������� ������ ���� SELECT * FROM (���������)*/
SELECT * FROM (
    SELECT * 
    FROM child 
    WHERE id >= 8
) AS children;
GO

/* 3.10(d) �������� ������ ���� SELECT * FROM table JOIN (���������) ON*/
SELECT * FROM child
JOIN (
    SELECT child_id, COUNT(*) AS vaccination_count
    FROM completed_vaccination
    GROUP BY child_id
    HAVING COUNT(*) > 1
) AS frequent_vaccinations
ON child.id = frequent_vaccinations.child_id;
GO