-- ==========================================
-- AUCTION HOUSE - PostgreSQL Database Schema
-- ==========================================

-- ==========================================
-- 0. CUSTOM ENUM TYPES
-- ==========================================
CREATE TYPE lot_status_enum AS ENUM ('Upcoming', 'Active', 'Sold', 'Unsold');
CREATE TYPE payment_method_enum AS ENUM ('Credit_Card', 'Bank_Transfer', 'Cash', 'Cheque');
CREATE TYPE transfer_source_enum AS ENUM ('Initial_Registration', 'Auction_Sale', 'Private_Transfer');

-- ==========================================
-- 1. ACTORS & LOCATION
-- ==========================================
CREATE TABLE Participant (
  participant_id SERIAL PRIMARY KEY,
  first_name VARCHAR NOT NULL,
  last_name VARCHAR NOT NULL,
  email VARCHAR UNIQUE NOT NULL,
  phone VARCHAR UNIQUE NOT NULL,
  registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Employee (
  employee_id SERIAL PRIMARY KEY,
  first_name VARCHAR NOT NULL,
  last_name VARCHAR NOT NULL,
  job_title VARCHAR NOT NULL,
  hire_date DATE NOT NULL
);

CREATE TABLE Location (
  location_id SERIAL PRIMARY KEY,
  name VARCHAR NOT NULL,
  address VARCHAR NOT NULL,
  city VARCHAR NOT NULL,
  post_code VARCHAR NOT NULL
);

-- ==========================================
-- 2. ITEMS & CATEGORIES
-- ==========================================
CREATE TABLE Category (
  category_id SERIAL PRIMARY KEY,
  parent_category_id INT REFERENCES Category(category_id),  -- Self-referential
  name VARCHAR NOT NULL,
  description TEXT
);

CREATE TABLE Item (
  item_id SERIAL PRIMARY KEY,
  category_id INT NOT NULL REFERENCES Category(category_id),
  title VARCHAR NOT NULL,
  description TEXT
);

CREATE TABLE Item_Submission (
  submission_id SERIAL PRIMARY KEY,
  item_id INT NOT NULL REFERENCES Item(item_id),
  seller_id INT NOT NULL REFERENCES Participant(participant_id),
  submission_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  agreed_starting_price DECIMAL(10,2) NOT NULL CHECK (agreed_starting_price >= 0)
);

-- ==========================================
-- 3. AUCTION EVENTS & LOTS
-- ==========================================
CREATE TABLE Auction_Event (
  auction_id SERIAL PRIMARY KEY,
  location_id INT NOT NULL REFERENCES Location(location_id),
  manager_employee_id INT NOT NULL REFERENCES Employee(employee_id),
  event_name VARCHAR NOT NULL,
  start_time TIMESTAMP NOT NULL,
  end_time TIMESTAMP
);

CREATE TABLE Lot (
  lot_id SERIAL PRIMARY KEY,
  auction_id INT NOT NULL REFERENCES Auction_Event(auction_id),
  lot_number INT NOT NULL,
  status lot_status_enum NOT NULL DEFAULT 'Upcoming',
  UNIQUE (auction_id, lot_number)  -- Aynı müzayedede iki tane Lot 1 olamaz
);

-- Bridge: Submission'ı Lot'a bağlayan M2M köprü tablosu
CREATE TABLE Lot_Submission (
  lot_id INT NOT NULL REFERENCES Lot(lot_id),
  submission_id INT NOT NULL REFERENCES Item_Submission(submission_id),
  PRIMARY KEY (lot_id, submission_id)  -- Composite PK
);

-- ==========================================
-- 4. BIDS, RESULTS & PAYMENTS
-- ==========================================
CREATE TABLE Bid (
  bid_id SERIAL PRIMARY KEY,
  lot_id INT NOT NULL REFERENCES Lot(lot_id),
  bidder_id INT NOT NULL REFERENCES Participant(participant_id),
  amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
  bid_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (lot_id, bid_id)  -- Composite FK için gerekli indeks
);

CREATE TABLE Lot_Result (
  result_id SERIAL PRIMARY KEY,
  lot_id INT UNIQUE NOT NULL,
  winning_bid_id INT NOT NULL,
  closed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  -- Composite FK: Kazanan teklifin aynı lot'a ait olmasını garanti eder
  FOREIGN KEY (lot_id, winning_bid_id) REFERENCES Bid(lot_id, bid_id)
);

CREATE TABLE Payment (
  payment_id SERIAL PRIMARY KEY,
  result_id INT NOT NULL REFERENCES Lot_Result(result_id),
  payer_id INT NOT NULL REFERENCES Participant(participant_id),
  amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
  method payment_method_enum NOT NULL,
  payment_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- 5. OWNERSHIP HISTORY (Provenance Ledger)
-- ==========================================
CREATE TABLE Ownership_History (
  ownership_id SERIAL PRIMARY KEY,
  item_id INT NOT NULL REFERENCES Item(item_id),
  previous_owner_id INT REFERENCES Participant(participant_id),  -- NULL for initial registration
  new_owner_id INT NOT NULL REFERENCES Participant(participant_id),
  transfer_source transfer_source_enum NOT NULL,
  transfer_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  lot_result_id INT REFERENCES Lot_Result(result_id)  -- Only filled for Auction_Sale
);


-- ==========================================================================
-- ==================== VERI GİRİŞLERİ (INSERT INTO) =======================
-- ==========================================================================

-- ==========================================
-- 1. KATILIMCILAR (Alıcılar & Satıcılar)
-- ==========================================
INSERT INTO Participant (first_name, last_name, email, phone) VALUES
('Can', 'Ozkan', 'can.ozkan@mail.com', '05322220000'),       -- ID: 1
('Zeynep', 'Kilic', 'zeynep.kilic@mail.com', '05301110000'), -- ID: 2
('Murat', 'Demir', 'murat.demir@mail.com', '05344440000'),   -- ID: 3
('Elif', 'Yilmaz', 'elif.yilmaz@mail.com', '05333330000'),   -- ID: 4
('Veli', 'Arslan', 'veli.arslan@mail.com', '05355550000');    -- ID: 5

-- ==========================================
-- 2. ÇALIŞANLAR (Müzayedeciler & Yöneticiler)
-- ==========================================
INSERT INTO Employee (first_name, last_name, job_title, hire_date) VALUES
('Ahmet', 'Yilmaz', 'Auctioneer', '2020-05-15'),   -- ID: 1
('Ayse', 'Demir', 'Event Manager', '2021-08-20'),   -- ID: 2
('Mehmet', 'Kaya', 'Appraiser', '2019-01-10');       -- ID: 3

-- ==========================================
-- 3. LOKASYONLAR (Müzayede Mekanları)
-- ==========================================
INSERT INTO Location (name, address, city, post_code) VALUES
('Grand Auction Hall', 'Moda Caddesi No:12', 'Istanbul', '34710'),  -- ID: 1
('Capital Art Center', 'Tunali Hilmi Cad. No:88', 'Ankara', '06700'), -- ID: 2
('Aegean Gallery', 'Kordon Boyu No:5', 'Izmir', '35210');              -- ID: 3

-- ==========================================
-- 4. KATEGORİLER (Self-Referential Hiyerarşi)
-- ==========================================
INSERT INTO Category (parent_category_id, name, description) VALUES
(NULL, 'Fine Arts', 'Paintings, sculptures, and artistic works'),          -- ID: 1
(NULL, 'Antiques', 'Historical objects and collectibles'),                 -- ID: 2
(NULL, 'Jewelry', 'Precious stones and metalwork'),                        -- ID: 3
(1, 'Paintings', 'Oil, watercolor, and acrylic works'),                    -- ID: 4 (Sub of Fine Arts)
(1, 'Sculptures', 'Bronze, marble, and wood sculptures'),                  -- ID: 5 (Sub of Fine Arts)
(2, 'Furniture', 'Antique tables, chairs, and cabinets'),                  -- ID: 6 (Sub of Antiques)
(2, 'Clocks', 'Antique wall and pocket watches'),                         -- ID: 7 (Sub of Antiques)
(4, 'Oil Paintings', 'Classical oil on canvas works');                     -- ID: 8 (Sub of Paintings -> 3 levels deep!)

-- ==========================================
-- 5. EŞYALAR (Müzayedeye Sunulacak Nesneler)
-- ==========================================
INSERT INTO Item (category_id, title, description) VALUES
(8, 'Sunset Over Bosphorus', '19th century oil painting, 80x120cm'),        -- ID: 1
(5, 'Bronze Horse Statue', 'Ottoman era, 2kg, patinated bronze'),           -- ID: 2
(3, 'Emerald Necklace', '18K gold chain with 3 Colombian emeralds'),        -- ID: 3
(7, 'Victorian Wall Clock', '1880s English oak case, pendulum mechanism'),   -- ID: 4
(6, 'Baroque Writing Desk', 'Italian walnut, hand-carved, 18th century'),   -- ID: 5
(4, 'Watercolor Garden Scene', 'Impressionist style, 40x60cm, signed');     -- ID: 6

-- ==========================================
-- 6. EŞYA TESLİMATLARI (Item Submissions)
-- ==========================================
INSERT INTO Item_Submission (item_id, seller_id, agreed_starting_price) VALUES
(1, 1, 25000.00),   -- ID: 1 | Can, Bosphorus tablosunu 25000 TL'den başlatıyor
(2, 1, 8000.00),    -- ID: 2 | Can, Bronz atı 8000 TL'den başlatıyor
(3, 2, 45000.00),   -- ID: 3 | Zeynep, Zümrüt kolyeyi 45000 TL'den başlatıyor
(4, 3, 12000.00),   -- ID: 4 | Murat, Viktorya saatini 12000 TL'den başlatıyor
(5, 3, 18000.00),   -- ID: 5 | Murat, Barok yazı masasını 18000 TL'den başlatıyor
(6, 4, 5000.00);    -- ID: 6 | Elif, Suluboya tabloyu 5000 TL'den başlatıyor

-- ==========================================
-- 7. MÜZAYEDE ETKİNLİKLERİ
-- ==========================================
INSERT INTO Auction_Event (location_id, manager_employee_id, event_name, start_time, end_time) VALUES
(1, 2, 'Winter Antique Gala', '2024-01-15 19:00:00', '2024-01-15 23:00:00'),   -- ID: 1
(2, 2, 'Spring Fine Arts Evening', '2024-04-20 18:30:00', '2024-04-20 22:00:00'), -- ID: 2
(3, 1, 'Summer Jewelry Auction', '2024-07-10 20:00:00', NULL);                    -- ID: 3 (henüz bitmedi)

-- ==========================================
-- 8. LOTLAR (Müzayede Masaları)
-- ==========================================
INSERT INTO Lot (auction_id, lot_number, status) VALUES
(1, 1, 'Sold'),      -- ID: 1 | Kış Galası, Masa 1 - Satıldı
(1, 2, 'Sold'),      -- ID: 2 | Kış Galası, Masa 2 - Satıldı
(1, 3, 'Unsold'),    -- ID: 3 | Kış Galası, Masa 3 - Alıcı bulunamadı
(2, 1, 'Sold'),      -- ID: 4 | Bahar Gecesi, Masa 1 - Satıldı
(2, 2, 'Upcoming'),  -- ID: 5 | Bahar Gecesi, Masa 2 - Henüz başlamadı
(3, 1, 'Active');     -- ID: 6 | Yaz Müzayedesi, Masa 1 - Şu an aktif!

-- ==========================================
-- 9. LOT-SUBMISSION KÖPRÜSÜ (Hangi Lot'ta Hangi Teslimat?)
-- ==========================================
INSERT INTO Lot_Submission (lot_id, submission_id) VALUES
(1, 1),  -- Lot 1 (Kış Galası Masa 1) = Bosphorus Tablosu (Submission 1)
(2, 2),  -- Lot 2 (Kış Galası Masa 2) = Bronz At (Submission 2)
(3, 4),  -- Lot 3 (Kış Galası Masa 3) = Viktorya Saati (Submission 4, alıcısız kaldı)
(4, 5),  -- Lot 4 (Bahar Gecesi Masa 1) = Barok Yazı Masası (Submission 5)
(5, 6),  -- Lot 5 (Bahar Gecesi Masa 2) = Suluboya Tablo (Submission 6)
(6, 3);  -- Lot 6 (Yaz Müzayedesi Masa 1) = Zümrüt Kolye (Submission 3)

-- ==========================================
-- 10. TEKLİFLER (Bid - Tarihi Kayıtlar)
-- ==========================================
-- Lot 1: Bosphorus Tablosu (Başlangıç: 25000 TL)
INSERT INTO Bid (lot_id, bidder_id, amount, bid_time) VALUES
(1, 4, 26000.00, '2024-01-15 19:15:00'),  -- ID: 1 | Elif 26000 veriyor
(1, 5, 28000.00, '2024-01-15 19:17:00'),  -- ID: 2 | Veli 28000'e çıkıyor
(1, 4, 30000.00, '2024-01-15 19:19:00'),  -- ID: 3 | Elif 30000 ile geri dönüyor
(1, 5, 35000.00, '2024-01-15 19:21:00');  -- ID: 4 | Veli son teklif 35000!

-- Lot 2: Bronz At (Başlangıç: 8000 TL)
INSERT INTO Bid (lot_id, bidder_id, amount, bid_time) VALUES
(2, 2, 9000.00, '2024-01-15 19:45:00'),   -- ID: 5 | Zeynep 9000
(2, 4, 10500.00, '2024-01-15 19:47:00'),  -- ID: 6 | Elif 10500
(2, 2, 12000.00, '2024-01-15 19:49:00');  -- ID: 7 | Zeynep son teklif 12000!

-- Lot 3: Viktorya Saati - Kimse açılış fiyatını karşılamadı (UNSOLD)
-- (Teklif yok, masaya hiç teklif gelmedi)

-- Lot 4: Barok Yazı Masası (Başlangıç: 18000 TL)
INSERT INTO Bid (lot_id, bidder_id, amount, bid_time) VALUES
(4, 5, 19000.00, '2024-04-20 19:05:00'),  -- ID: 8  | Veli 19000
(4, 1, 22000.00, '2024-04-20 19:08:00'),  -- ID: 9  | Can 22000
(4, 5, 25000.00, '2024-04-20 19:10:00');  -- ID: 10 | Veli son teklif 25000!

-- Lot 6: Zümrüt Kolye - Aktif müzayede, devam ediyor
INSERT INTO Bid (lot_id, bidder_id, amount, bid_time) VALUES
(6, 4, 46000.00, '2024-07-10 20:10:00'),  -- ID: 11 | Elif 46000
(6, 1, 50000.00, '2024-07-10 20:12:00'),  -- ID: 12 | Can 50000
(6, 4, 55000.00, '2024-07-10 20:14:00');  -- ID: 13 | Elif şu an en yüksek teklif!

-- ==========================================
-- 11. MÜZAYEDE SONUÇLARI (Lot_Result)
-- ==========================================
INSERT INTO Lot_Result (lot_id, winning_bid_id, closed_at) VALUES
(1, 4,  '2024-01-15 19:22:00'),  -- ID: 1 | Bosphorus Tablosu -> Veli kazandı (35000 TL)
(2, 7,  '2024-01-15 19:50:00'),  -- ID: 2 | Bronz At -> Zeynep kazandı (12000 TL)
(4, 10, '2024-04-20 19:11:00');  -- ID: 3 | Barok Masa -> Veli kazandı (25000 TL)
-- Not: Lot 3 satılamadı (Unsold) -> Sonuç kaydı yok!
-- Not: Lot 6 hâlâ aktif (Active) -> Henüz sonuç yok!

-- ==========================================
-- 12. ÖDEMELER (Payment)
-- ==========================================
INSERT INTO Payment (result_id, payer_id, amount, method, payment_time) VALUES
(1, 5, 35000.00, 'Bank_Transfer', '2024-01-16 10:00:00'),  -- ID: 1 | Veli Bosphorus tablosunu banka havalesiyle ödedi
(2, 2, 12000.00, 'Credit_Card', '2024-01-16 11:30:00'),    -- ID: 2 | Zeynep Bronz atı kredi kartıyla ödedi
(3, 5, 25000.00, 'Cheque', '2024-04-21 14:00:00');          -- ID: 3 | Veli Barok masayı çekle ödedi
-- Not: Lot 6 aktif, ödeme henüz yok!

-- ==========================================
-- 13. SAHİPLİK GEÇMİŞİ (Ownership_History - Değişmez Defter)
-- ==========================================
-- İlk Kayıtlar (Satıcılar eşyalarını sisteme ilk teslim ettiğinde)
INSERT INTO Ownership_History (item_id, previous_owner_id, new_owner_id, transfer_source, lot_result_id) VALUES
(1, NULL, 1, 'Initial_Registration', NULL),  -- ID: 1 | Bosphorus Tablosu -> Can'ın mülkü olarak kayıt
(2, NULL, 1, 'Initial_Registration', NULL),  -- ID: 2 | Bronz At -> Can'ın mülkü olarak kayıt
(3, NULL, 2, 'Initial_Registration', NULL),  -- ID: 3 | Zümrüt Kolye -> Zeynep'in mülkü olarak kayıt
(4, NULL, 3, 'Initial_Registration', NULL),  -- ID: 4 | Viktorya Saati -> Murat'ın mülkü olarak kayıt
(5, NULL, 3, 'Initial_Registration', NULL),  -- ID: 5 | Barok Masa -> Murat'ın mülkü olarak kayıt
(6, NULL, 4, 'Initial_Registration', NULL);  -- ID: 6 | Suluboya -> Elif'in mülkü olarak kayıt

-- Müzayede Satışları (Çekiç vurulunca mülkiyet devri)
INSERT INTO Ownership_History (item_id, previous_owner_id, new_owner_id, transfer_source, lot_result_id) VALUES
(1, 1, 5, 'Auction_Sale', 1),  -- ID: 7 | Bosphorus: Can -> Veli (Lot_Result 1 sayesinde)
(2, 1, 2, 'Auction_Sale', 2),  -- ID: 8 | Bronz At: Can -> Zeynep (Lot_Result 2 sayesinde)
(5, 3, 5, 'Auction_Sale', 3);  -- ID: 9 | Barok Masa: Murat -> Veli (Lot_Result 3 sayesinde)

-- Özel Devir (Müzayede dışı - Örnek: Veli tabloyu hediye etti)
INSERT INTO Ownership_History (item_id, previous_owner_id, new_owner_id, transfer_source, lot_result_id) VALUES
(1, 5, 4, 'Private_Transfer', NULL);  -- ID: 10 | Bosphorus: Veli -> Elif'e hediye (müzayede dışı)
