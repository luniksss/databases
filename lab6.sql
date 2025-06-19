use hotel_booking
GO

-- 1. �������� ������� ������
ALTER TABLE room ADD FOREIGN KEY (id_hotel) REFERENCES hotel(id_hotel);
ALTER TABLE room ADD FOREIGN KEY (id_room_category) REFERENCES room_category(id_room_category);
ALTER TABLE booking ADD FOREIGN KEY (id_client) REFERENCES client(id_client);
ALTER TABLE room_in_booking ADD FOREIGN KEY (id_booking) REFERENCES booking(id_booking);
ALTER TABLE room_in_booking ADD FOREIGN KEY (id_room) REFERENCES room(id_room);
GO

-- 2. ������ ���������� � �������� ��������� �������, ����������� � ������� ��������� ����� �� 1 ������ 2019�.
SELECT *
FROM client c
	INNER JOIN booking b ON c.id_client = b.id_client
	INNER JOIN room_in_booking rib ON rib.id_booking = b.id_booking
	INNER JOIN room r ON rib.id_room = r.id_room
	INNER JOIN hotel h ON h.id_hotel = r.id_hotel
	INNER JOIN room_category rc ON rc.id_room_category = r.id_room_category
WHERE
	h.name = '������'
	AND rc.name = '����'
	AND rib.checkin_date <= '2019-04-01'
    AND rib.checkout_date > '2019-04-01';
GO

-- 3 ���� ������ ��������� ������� ���� �������� �� 22 ������.
SELECT *
FROM 
    room r
    INNER JOIN hotel h ON r.id_hotel = h.id_hotel
    INNER JOIN room_category rc ON r.id_room_category = rc.id_room_category
WHERE 
    r.id_room NOT IN (
        SELECT rib.id_room
        FROM room_in_booking rib
        WHERE 
            rib.checkin_date <= '2019-04-22'
            AND rib.checkout_date > '2019-04-22'
    );
GO

-- 4 ���� ���������� ����������� � ��������� ������� �� 23 ����� �� ������ ��������� �������
SELECT 
    rc.name AS category_name,
    COUNT(c.id_client) AS total_clients
FROM 
    client c
    INNER JOIN booking b ON c.id_client = b.id_client
    INNER JOIN room_in_booking rib ON b.id_booking = rib.id_booking
    INNER JOIN room r ON rib.id_room = r.id_room
    INNER JOIN hotel h ON r.id_hotel = h.id_hotel
    INNER JOIN room_category rc ON r.id_room_category = rc.id_room_category
WHERE 
    h.name = '������'
    AND rib.checkin_date <= '2019-03-23'
    AND rib.checkout_date > '2019-03-23'
GROUP BY 
    rc.name;
GO

-- 5 ���� ������ ��������� ����������� �������� �� ���� �������� ��������� �������, ��������� � ������ � ��������� ���� ������.
SELECT 
    c.name AS client_name,
    rib.checkout_date AS checkout_date,
    r.id_room AS room_id
FROM 
    client c
    INNER JOIN booking b ON c.id_client = b.id_client
    INNER JOIN room_in_booking rib ON rib.id_booking = b.id_booking
    INNER JOIN room r ON rib.id_room = r.id_room
    INNER JOIN hotel h ON h.id_hotel = r.id_hotel
WHERE
    h.name = '������'
    AND rib.checkout_date >= '2019-04-01'
    AND rib.checkout_date <= '2019-04-30'
    AND rib.id_room IN (
        SELECT 
            id_room 
        FROM 
            room_in_booking 
        WHERE 
            checkout_date >= '2019-04-01' 
            AND checkout_date <= '2019-04-30'
    )
    AND rib.checkout_date = (
        SELECT 
            MAX(checkout_date) 
        FROM 
            room_in_booking rib2
        WHERE 
            rib2.id_room = rib.id_room
            AND rib2.checkout_date >= '2019-04-01' 
            AND rib2.checkout_date <= '2019-04-30'
    )
ORDER BY 
    r.id_room ASC;
GO

-- 6 �������� �� 2 ��� ���� ���������� � ��������� ������� ���� �������� ������ ��������� �������, ������� ���������� 10 ���.
SELECT * 
FROM room_in_booking rib
	INNER JOIN room r ON rib.id_room = r.id_room
	INNER JOIN hotel h ON h.id_hotel = r.id_hotel
	INNER JOIN room_category rc ON rc.id_room_category = r.id_room_category
WHERE 
	h.name = '������'
	AND rc.name = '������'
	AND rib.checkin_date = '2019-05-10';

UPDATE rib
SET rib.checkout_date = DATEADD(day, 2, rib.checkout_date)
FROM room_in_booking rib
	INNER JOIN room r ON rib.id_room = r.id_room
	INNER JOIN hotel h ON h.id_hotel = r.id_hotel
	INNER JOIN room_category rc ON rc.id_room_category = r.id_room_category
WHERE 
	h.name = '������'
	AND rc.name = '������'
	AND rib.checkin_date = '2019-05-10';

/* ����� ������� ������� ���� ���������� ��������������� �������
UPDATE rib
SET rib.checkout_date = DATEADD(day, -2, rib.checkout_date)
FROM room_in_booking rib
WHERE 
	rib.id_room_in_booking = 1495 */

SELECT * 
FROM room_in_booking rib
	INNER JOIN room r ON rib.id_room = r.id_room
	INNER JOIN hotel h ON h.id_hotel = r.id_hotel
	INNER JOIN room_category rc ON rc.id_room_category = r.id_room_category
WHERE 
	h.name = '������'
	AND rc.name = '������'
	AND rib.checkin_date = '2019-05-10';
GO

-- 7 ����� ��� "��������������" �������� ����������. �������������� ������ ������� ������ ��������� ���������� � ���� ������������� �������.
SELECT 
    a.id_room_in_booking AS id1,
    b.id_room_in_booking AS id2,
    a.id_room,
    a.checkin_date AS checkin1,
    a.checkout_date AS checkout1,
    b.checkin_date AS checkin2,
    b.checkout_date AS checkout2
FROM 
    room_in_booking a
    INNER JOIN room_in_booking b 
        ON a.id_room = b.id_room
        AND a.id_room_in_booking < b.id_room_in_booking
WHERE 
    a.checkin_date < b.checkout_date
    AND a.checkout_date > b.checkin_date;
GO

-- 8 ������� ������������ � ����������.
BEGIN TRANSACTION;
DECLARE @booking_id INT;

-- ������� ������������
INSERT INTO booking (id_client, booking_date)
VALUES (1, GETDATE()); -- id_client = 1, ������� ����
SET @booking_id = SCOPE_IDENTITY();

-- �������� ����� � ������������
INSERT INTO room_in_booking (id_booking, id_room, checkin_date, checkout_date)
VALUES (@booking_id, 1, '2024-01-01', '2024-01-05'); -- id_room = 1

COMMIT TRANSACTION;

-- 9. �������� ����������� �������
CREATE INDEX IX_hotel_name ON hotel(name);
CREATE INDEX IX_booking_date ON booking(booking_date);
CREATE INDEX IX_room_checkin_date ON room_in_booking(checkin_date);
CREATE INDEX IX_room_checkout_date ON room_in_booking(checkout_date);