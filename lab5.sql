use pharmacy
GO

-- 1. �������� ������� ������
ALTER TABLE dealer ADD FOREIGN KEY (id_company) REFERENCES company(id_company);
ALTER TABLE production ADD FOREIGN KEY (id_company) REFERENCES company(id_company);
ALTER TABLE production ADD FOREIGN KEY (id_medicine) REFERENCES medicine(id_medicine);
ALTER TABLE [order] ADD FOREIGN KEY (id_production) REFERENCES production(id_production);
ALTER TABLE [order] ADD FOREIGN KEY (id_dealer) REFERENCES dealer(id_dealer);
ALTER TABLE [order] ADD FOREIGN KEY (id_pharmacy) REFERENCES pharmacy(id_pharmacy);
GO

/* 2. ������ ���������� �� ���� ������� ���������� ��������� �������� ������ � ��������� �������� �����, ���, ������ �������. */
-- JOIN  - �� ������� INNER JOIN
SELECT p.name AS pharmacy_name, o.date AS order_date, o.quantity AS order_quantity
FROM [order] o
JOIN production pr ON o.id_production = pr.id_production
JOIN company c ON pr.id_company = c.id_company
JOIN medicine m ON pr.id_medicine = m.id_medicine
JOIN pharmacy p ON o.id_pharmacy = p.id_pharmacy
WHERE c.name = '�����' AND m.name = '��������';

-- 3 ���� ������ �������� �������� �������, �� ������� �� ���� ������� ������ �� 25 ������.
SELECT m.name AS medicine_name
FROM production pr
JOIN company c ON pr.id_company = c.id_company
JOIN medicine m ON pr.id_medicine = m.id_medicine
LEFT JOIN [order] o ON pr.id_production = o.id_production AND o.date < '2019-01-25'
WHERE c.name = '�����' AND o.id_production IS NULL;

-- 4 ���� ����������� � ������������ ����� �������� ������ �����, ������� �������� �� ����� 120 �������.
SELECT c.name AS company_name, MIN(pr.rating) AS min_rating, MAX(pr.rating) AS max_rating
FROM company c
JOIN production pr ON c.id_company = pr.id_company
JOIN (
    SELECT pr.id_company FROM [order] o
    JOIN production pr ON o.id_production = pr.id_production
    GROUP BY pr.id_company HAVING COUNT(o.id_order) >= 120
) AS active_companies ON c.id_company = active_companies.id_company
GROUP BY c.name;

-- 5 ���� ������ ��������� ������ ����� �� ���� ������� �������� �AstraZeneca�. ���� � ������ ��� �������, � �������� ������ ���������� NULL.
-- ������ ��� ��������
SELECT DISTINCT d.name AS dealer_name, ph.name AS pharmacy_name
FROM dealer d
LEFT JOIN [order] o ON d.id_dealer = o.id_dealer
LEFT JOIN pharmacy ph ON o.id_pharmacy = ph.id_pharmacy
WHERE d.id_company = (
    SELECT id_company FROM company c WHERE name = 'AstraZeneca'
);

--������ � ��������� (����� �������� ������)
SELECT d.name AS dealer_name, ph.name AS pharmacy_name
FROM dealer d
LEFT JOIN [order] o ON d.id_dealer = o.id_dealer
LEFT JOIN pharmacy ph ON o.id_pharmacy = ph.id_pharmacy
WHERE d.id_company = (
    SELECT id_company FROM company c WHERE name = 'AstraZeneca'
);

-- 6 ��������� �� 20% ��������� ���� ��������, ���� ��� ��������� 3000, � ������������ ������� �� ����� 7 ����.
-- ��� ���� ��
SELECT * FROM production pr
JOIN medicine m ON pr.id_medicine = m.id_medicine
WHERE pr.price > 3000 AND m.cure_duration <= 7;

UPDATE pr
SET pr.price = pr.price * 0.8
FROM production pr
JOIN medicine m ON pr.id_medicine = m.id_medicine
WHERE pr.price > 3000 AND m.cure_duration <= 7;

-- ��� ����� �����
SELECT * FROM production pr
JOIN medicine m ON pr.id_medicine = m.id_medicine
WHERE pr.price > 3000 AND m.cure_duration <= 7;

-- 7 �������� ����������� �������. (������� ��������� ��� ��������� �������� � ���� ������, ������� ��������� ��� ��������� ������ �� ��������� ��������)
CREATE INDEX IX_company_name ON company(name);
CREATE INDEX IX_medicine_name ON medicine(name);
CREATE INDEX IX_order_date ON [order](date);
CREATE INDEX IX_production_price ON production(price);

GO