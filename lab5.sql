use pharmacy
GO

-- 1. Добавить внешние включи
ALTER TABLE dealer ADD FOREIGN KEY (id_company) REFERENCES company(id_company);
ALTER TABLE production ADD FOREIGN KEY (id_company) REFERENCES company(id_company);
ALTER TABLE production ADD FOREIGN KEY (id_medicine) REFERENCES medicine(id_medicine);
ALTER TABLE [order] ADD FOREIGN KEY (id_production) REFERENCES production(id_production);
ALTER TABLE [order] ADD FOREIGN KEY (id_dealer) REFERENCES dealer(id_dealer);
ALTER TABLE [order] ADD FOREIGN KEY (id_pharmacy) REFERENCES pharmacy(id_pharmacy);
GO

/* 2. Выдать информацию по всем заказам лекарствам “Кордерон” компании “Аргус” с указанием названий аптек, дат, объема заказов. */
-- JOIN  - по дефолту INNER JOIN
SELECT p.name AS pharmacy_name, o.date AS order_date, o.quantity AS order_quantity
FROM [order] o
JOIN production pr ON o.id_production = pr.id_production
JOIN company c ON pr.id_company = c.id_company
JOIN medicine m ON pr.id_medicine = m.id_medicine
JOIN pharmacy p ON o.id_pharmacy = p.id_pharmacy
WHERE c.name = 'Аргус' AND m.name = 'Кордерон';

-- 3 Дать список лекарств компании “Фарма”, на которые не были сделаны заказы до 25 января.
SELECT m.name AS medicine_name
FROM production pr
JOIN company c ON pr.id_company = c.id_company
JOIN medicine m ON pr.id_medicine = m.id_medicine
LEFT JOIN [order] o ON pr.id_production = o.id_production AND o.date < '2019-01-25'
WHERE c.name = 'Фарма' AND o.id_production IS NULL;

-- 4 Дать минимальный и максимальный баллы лекарств каждой фирмы, которая оформила не менее 120 заказов.
SELECT c.name AS company_name, MIN(pr.rating) AS min_rating, MAX(pr.rating) AS max_rating
FROM company c
JOIN production pr ON c.id_company = pr.id_company
JOIN (
    SELECT pr.id_company FROM [order] o
    JOIN production pr ON o.id_production = pr.id_production
    GROUP BY pr.id_company HAVING COUNT(o.id_order) >= 120
) AS active_companies ON c.id_company = active_companies.id_company
GROUP BY c.name;

-- 5 Дать списки сделавших заказы аптек по всем дилерам компании “AstraZeneca”. Если у дилера нет заказов, в названии аптеки проставить NULL.
-- записи без повторов
SELECT DISTINCT d.name AS dealer_name, ph.name AS pharmacy_name
FROM dealer d
LEFT JOIN [order] o ON d.id_dealer = o.id_dealer
LEFT JOIN pharmacy ph ON o.id_pharmacy = ph.id_pharmacy
WHERE d.id_company = (
    SELECT id_company FROM company c WHERE name = 'AstraZeneca'
);

--записи с повторами (очень неудобно читать)
SELECT d.name AS dealer_name, ph.name AS pharmacy_name
FROM dealer d
LEFT JOIN [order] o ON d.id_dealer = o.id_dealer
LEFT JOIN pharmacy ph ON o.id_pharmacy = ph.id_pharmacy
WHERE d.id_company = (
    SELECT id_company FROM company c WHERE name = 'AstraZeneca'
);

-- 6 Уменьшить на 20% стоимость всех лекарств, если она превышает 3000, а длительность лечения не более 7 дней.
-- как было до
SELECT * FROM production pr
JOIN medicine m ON pr.id_medicine = m.id_medicine
WHERE pr.price > 3000 AND m.cure_duration <= 7;

UPDATE pr
SET pr.price = pr.price * 0.8
FROM production pr
JOIN medicine m ON pr.id_medicine = m.id_medicine
WHERE pr.price > 3000 AND m.cure_duration <= 7;

-- как стало после
SELECT * FROM production pr
JOIN medicine m ON pr.id_medicine = m.id_medicine
WHERE pr.price > 3000 AND m.cure_duration <= 7;

-- 7 Добавить необходимые индексы. (индексы создаются для ускорения запросов к базе данных, которые фильтруют или сортируют данные по указанным столбцам)
CREATE INDEX IX_company_name ON company(name);
CREATE INDEX IX_medicine_name ON medicine(name);
CREATE INDEX IX_order_date ON [order](date);
CREATE INDEX IX_production_price ON production(price);

GO