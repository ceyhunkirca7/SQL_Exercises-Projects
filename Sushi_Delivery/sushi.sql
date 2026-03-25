-- 1. LOCATION & ADDRESS
CREATE TABLE City (
  city_id SERIAL PRIMARY KEY,
  name VARCHAR NOT NULL
);
CREATE TABLE District (
  district_id SERIAL PRIMARY KEY,
  city_id INT REFERENCES City(city_id),
  name VARCHAR NOT NULL
);
CREATE TABLE Customer (
  customer_id SERIAL PRIMARY KEY,
  first_name VARCHAR NOT NULL,
  last_name VARCHAR NOT NULL,
  phone VARCHAR UNIQUE NOT NULL,
  email VARCHAR
);
CREATE TABLE Address (
  address_id SERIAL PRIMARY KEY,
  customer_id INT REFERENCES Customer(customer_id),
  district_id INT REFERENCES District(district_id),
  street_name VARCHAR,
  building_number VARCHAR,
  apartment_number VARCHAR,
  postal_code VARCHAR
);
-- 2. RESTAURANT MENU
CREATE TABLE Menu_Category (
  category_id SERIAL PRIMARY KEY,
  name VARCHAR NOT NULL,
  description TEXT
);
CREATE TABLE Menu_Item (
  menu_item_id SERIAL PRIMARY KEY,
  category_id INT REFERENCES Menu_Category(category_id),
  name VARCHAR NOT NULL,
  description TEXT,
  current_price DECIMAL NOT NULL,
  is_available BOOLEAN DEFAULT true
);
CREATE TABLE Ingredient (
  ingredient_id SERIAL PRIMARY KEY,
  name VARCHAR NOT NULL,
  unit_of_measure VARCHAR
);
CREATE TABLE Menu_Item_Ingredient (
  item_ingredient_id SERIAL PRIMARY KEY,
  menu_item_id INT REFERENCES Menu_Item(menu_item_id),
  ingredient_id INT REFERENCES Ingredient(ingredient_id),
  quantity DECIMAL
);
-- 3. ORDER MANAGEMENT
CREATE TABLE Order_Status (
  status_id SERIAL PRIMARY KEY,
  status_name VARCHAR UNIQUE NOT NULL
);
CREATE TABLE Orders (
  order_id SERIAL PRIMARY KEY,
  customer_id INT REFERENCES Customer(customer_id),
  status_id INT REFERENCES Order_Status(status_id),
  order_time TIMESTAMP NOT NULL,
  expected_delivery_time TIMESTAMP,
  special_instructions TEXT
);
CREATE TABLE Order_Item (
  order_item_id SERIAL PRIMARY KEY,
  order_id INT REFERENCES Orders(order_id),
  menu_item_id INT REFERENCES Menu_Item(menu_item_id),
  quantity INT NOT NULL,
  unit_price_at_order DECIMAL NOT NULL
);
-- 4. DELIVERY & COURIER
CREATE TABLE Courier (
  courier_id SERIAL PRIMARY KEY,
  first_name VARCHAR NOT NULL,
  last_name VARCHAR NOT NULL,
  phone VARCHAR UNIQUE NOT NULL,
  vehicle_type VARCHAR,
  is_active BOOLEAN DEFAULT true
);
CREATE TABLE Delivery (
  delivery_id SERIAL PRIMARY KEY,
  order_id INT UNIQUE REFERENCES Orders(order_id), -- One-to-One
  courier_id INT REFERENCES Courier(courier_id),
  address_id INT REFERENCES Address(address_id),
  dispatch_time TIMESTAMP,
  actual_delivery_time TIMESTAMP
);
-- 5. PAYMENT
CREATE TABLE Payment_Method (
  payment_method_id SERIAL PRIMARY KEY,
  method_name VARCHAR UNIQUE NOT NULL
);
CREATE TABLE Payment (
  payment_id SERIAL PRIMARY KEY,
  order_id INT REFERENCES Orders(order_id),
  payment_method_id INT REFERENCES Payment_Method(payment_method_id),
  amount DECIMAL NOT NULL,
  payment_date TIMESTAMP NOT NULL,
  is_successful BOOLEAN
);

-- ==========================================
-- 1. LOKASYON VERİLERİ (Şehirler ve İlçeler)
-- ==========================================
INSERT INTO City (name) VALUES 
('İstanbul'), ('Ankara'), ('İzmir');
INSERT INTO District (city_id, name) VALUES 
(1, 'Kadıköy'), (1, 'Beşiktaş'), (1, 'Şişli'), (1, 'Üsküdar'), -- İstanbul İlçeleri (ID: 1-4)
(2, 'Çankaya'), (2, 'Yenimahalle'),                         -- Ankara İlçeleri (ID: 5-6)
(3, 'Karşıyaka'), (3, 'Bornova');                         -- İzmir İlçeleri (ID: 7-8)
-- ==========================================
-- 2. SİSTEM SABİTLERİ (Durumlar ve Ödeme Tipleri)
-- ==========================================
INSERT INTO Order_Status (status_name) VALUES 
('Bekliyor'), ('Hazırlanıyor'), ('Yolda'), ('Teslim Edildi'), ('İptal Edildi');
INSERT INTO Payment_Method (method_name) VALUES 
('Kredi Kartı (Online)'), ('Kredi Kartı (Kapıda)'), ('Nakit'), ('Yemek Kartı (Ticket/Sodexo)');
-- ==========================================
-- 3. ÇALIŞANLAR (Kuryeler)
-- ==========================================
INSERT INTO Courier (first_name, last_name, phone, vehicle_type) VALUES 
('Hasan', 'Şahin', '05001112233', 'Motosiklet'),
('Burak', 'Yıldız', '05002223344', 'Motosiklet'),
('Emre', 'Çelik', '05003334455', 'Elektrikli Bisiklet'),
('Mert', 'Korkmaz', '05004445566', 'Motosiklet');
-- ==========================================
-- 4. MENÜ DÜZENİ (Kategoriler ve Ürünler)
-- ==========================================
INSERT INTO Menu_Category (name, description) VALUES 
('Rolls', '8 parçalı özel yapım sushiler (Uramaki & Maki)'),
('Nigiri', 'Pirinç yatağında taze deniz ürünleri (2 parça)'),
('Sashimi', 'Sadece taze çiğ balık dilimleri (5 parça)'),
('Başlangıçlar', 'Uzak doğu lezzetleri ve çorbalar'),
('İçecekler', 'Soğuk ve sıcak içecekler');
INSERT INTO Menu_Item (category_id, name, description, current_price) VALUES 
(1, 'California Roll', 'Yengeç, avokado, salatalık ve tobiko', 260.00),     -- ID: 1
(1, 'Philadelphia Roll', 'Somon, krem peynir, avokado, susam', 290.00),   -- ID: 2
(1, 'Dragon Roll', 'Yılan balığı, salatalık, üzeri avokado kaplı', 380.00), -- ID: 3
(1, 'Spicy Tuna Roll', 'Acı soslu ton balığı, salatalık', 310.00),          -- ID: 4
(2, 'Sake (Somon) Nigiri', 'Norveç somonu', 160.00),                      -- ID: 5
(2, 'Maguro (Ton) Nigiri', 'Sarı yüzgeçli ton balığı', 180.00),           -- ID: 6
(3, 'Somon Sashimi', 'Özel kesim 5 ince dilim somon', 350.00),            -- ID: 7
(4, 'Edamame', 'Deniz tuzu ile buharda pişmiş soya fasulyesi', 90.00),    -- ID: 8
(4, 'Miso Çorbası', 'Tofu, yosun ve taze soğanlı', 110.00),               -- ID: 9
(5, 'Coca Cola Zero', '330 ml Kutu', 45.00),                              -- ID: 10
(5, 'Asahi Yeşil Çay', 'Buzlu organik yeşil çay', 65.00);                 -- ID: 11
-- ==========================================
-- 5. STOK & İÇERİK (Malzemeler ve Reçeteler)
-- ==========================================
INSERT INTO Ingredient (name, unit_of_measure) VALUES 
('Sushi Pirinci', 'Gram'), ('Nori Yosunu', 'Yaprak'), ('Norveç Somonu', 'Gram'), 
('Ton Balığı', 'Gram'), ('Avokado', 'Adet'), ('Krem Peynir', 'Gram'), ('Yengeç Çubuğu', 'Adet');
-- Örnek Reçete: Philadelphia Roll İçeriği (Item 2)
INSERT INTO Menu_Item_Ingredient (menu_item_id, ingredient_id, quantity) VALUES 
(2, 1, 120),  -- 120 gr pirinç
(2, 2, 0.5),  -- Yarım yaprak nori
(2, 3, 50),   -- 50 gr somon
(2, 5, 0.25), -- Çeyrek avokado
(2, 6, 30);   -- 30 gr krem peynir
-- ==========================================
-- 6. MÜŞTERİLER VE ADRESLERİ
-- ==========================================
INSERT INTO Customer (first_name, last_name, phone, email) VALUES 
('Zeynep', 'Kılıç', '05301110000', 'zeynep.k@mail.com'), -- ID:1
('Can', 'Özkan', '05322220000', 'can.ozkan@mail.com'),   -- ID:2
('Elif', 'Yılmaz', '05333330000', 'elify@mail.com'),     -- ID:3
('Murat', 'Demir', '05344440000', 'mdemir@mail.com');    -- ID:4
INSERT INTO Address (customer_id, district_id, street_name, building_number, apartment_number) VALUES 
(1, 1, 'Moda Caddesi', '12', '4'),       -- Zeynep'in Kadıköy Evi
(2, 2, 'Barbaros Bulvarı', '45', '12'),  -- Can'ın Beşiktaş İş Yeri
(3, 3, 'Halaskargazi Cad.', '88', '2'),  -- Elif'in Şişli Evi
(4, 5, 'Tunalı Hilmi', '105', '8');      -- Murat'ın Çankaya (Ankara) Evi
-- ==========================================
-- 7. SİPARİŞLER (Geçmiş ve Aktif Siparişler)
-- ==========================================
-- SİPARİŞ 1: Zeynep (Geçmiş sipariş, Teslim edilmiş)
INSERT INTO Orders (customer_id, status_id, order_time, special_instructions) VALUES 
(1, 4, CURRENT_TIMESTAMP - INTERVAL '2 hours', 'Lütfen çatal da koyun.');
INSERT INTO Order_Item (order_id, menu_item_id, quantity, unit_price_at_order) VALUES 
(1, 2, 1, 290.00), (1, 8, 1, 90.00);  -- Phila Roll + Edamame
INSERT INTO Payment (order_id, payment_method_id, amount, payment_date, is_successful) VALUES 
(1, 1, 380.00, CURRENT_TIMESTAMP - INTERVAL '2 hours', true); -- Online Kart
INSERT INTO Delivery (order_id, courier_id, address_id, dispatch_time, actual_delivery_time) VALUES 
(1, 1, 1, CURRENT_TIMESTAMP - INTERVAL '1 hour 40 mins', CURRENT_TIMESTAMP - INTERVAL '1 hour 15 mins');
-- SİPARİŞ 2: Can (Şu an Yolda)
INSERT INTO Orders (customer_id, status_id, order_time, special_instructions) VALUES 
(2, 3, CURRENT_TIMESTAMP - INTERVAL '35 mins', 'Zile basmayın bebek uyuyor, arayın.');
INSERT INTO Order_Item (order_id, menu_item_id, quantity, unit_price_at_order) VALUES 
(2, 3, 1, 380.00), (2, 7, 1, 350.00), (2, 10, 2, 45.00); -- Dragon Roll + Sashimi + 2x Kola
INSERT INTO Payment (order_id, payment_method_id, amount, payment_date, is_successful) VALUES 
(2, 3, 820.00, CURRENT_TIMESTAMP - INTERVAL '35 mins', true); -- Nakit (Kapıda ödenecek)
INSERT INTO Delivery (order_id, courier_id, address_id, dispatch_time) VALUES 
(2, 2, 2, CURRENT_TIMESTAMP - INTERVAL '10 mins'); -- 10 dk önce kurye Burak yola çıkmış (Teslim saati henüz yok)
-- SİPARİŞ 3: Elif (Şu an Mutfakta Hazırlanıyor)
INSERT INTO Orders (customer_id, status_id, order_time) VALUES 
(3, 2, CURRENT_TIMESTAMP - INTERVAL '15 mins');
INSERT INTO Order_Item (order_id, menu_item_id, quantity, unit_price_at_order) VALUES 
(3, 1, 2, 260.00), (3, 5, 2, 160.00), (3, 9, 2, 110.00); -- 2x California + 2x Somon Nigiri + 2x Miso
INSERT INTO Payment (order_id, payment_method_id, amount, payment_date, is_successful) VALUES 
(3, 4, 1060.00, CURRENT_TIMESTAMP - INTERVAL '15 mins', true); -- Yemek Kartı
-- SİPARİŞ 4: Murat (Ankara'dan yeni gelmiş sipariş, Bekliyor)
INSERT INTO Orders (customer_id, status_id, order_time, expected_delivery_time) VALUES 
(4, 1, CURRENT_TIMESTAMP - INTERVAL '2 mins', CURRENT_TIMESTAMP + INTERVAL '45 mins');
INSERT INTO Order_Item (order_id, menu_item_id, quantity, unit_price_at_order) VALUES 
(4, 4, 1, 310.00), (4, 11, 1, 65.00); -- Spicy Tuna + Yeşil çay
INSERT INTO Payment (order_id, payment_method_id, amount, payment_date, is_successful) VALUES 
(4, 1, 375.00, CURRENT_TIMESTAMP - INTERVAL '2 mins', true); -- Online Kart
-- (Sipariş henüz onaylanıp yola çıkmadığı için Delivery tablosuna kayıt girilmedi)
