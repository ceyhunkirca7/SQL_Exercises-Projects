-- 1. Mevcut tabloları silmek için
DROP TABLE IF EXISTS Reviews CASCADE;
DROP TABLE IF EXISTS Orders CASCADE;
DROP TABLE IF EXISTS Products CASCADE;
DROP TABLE IF EXISTS Users CASCADE;

-- 2. Users tablosu
CREATE TABLE Users (
    kullanici_id SERIAL PRIMARY KEY, -- Sequence kullanılıyor
    ad_soyad VARCHAR(100) NOT NULL,
    eposta VARCHAR(100) UNIQUE NOT NULL,
    satici_mi BOOLEAN NOT NULL
);

-- 3. Products tablosu
CREATE TABLE Products (
    urun_id SERIAL PRIMARY KEY,
    satici_id INT NOT NULL,
    urun_adi VARCHAR(100) NOT NULL,
    kategori VARCHAR(50),
    fiyat NUMERIC(10, 2) CHECK (fiyat > 0), -- Sayı kısıtı
    stok INT CHECK (stok >= 0), -- Sayı kısıtı
    FOREIGN KEY (satici_id) REFERENCES Users(kullanici_id) ON DELETE CASCADE -- Silme kısıtı
);

-- 4. Orders tablosu
CREATE TABLE Orders (
    siparis_id SERIAL PRIMARY KEY,
    alici_id INT NOT NULL,
    urun_id INT NOT NULL,
    miktar INT CHECK (miktar > 0),
    FOREIGN KEY (alici_id) REFERENCES Users(kullanici_id) ON DELETE CASCADE,
    FOREIGN KEY (urun_id) REFERENCES Products(urun_id) ON DELETE CASCADE
);

-- 5. Reviews tablosu
CREATE TABLE Reviews (
    yorum_id SERIAL PRIMARY KEY,
    urun_id INT NOT NULL,
    kullanici_id INT NOT NULL,
    puan INT CHECK (puan BETWEEN 1 AND 5), -- Sayı kısıtı
    yorum TEXT,
    FOREIGN KEY (urun_id) REFERENCES Products(urun_id) ON DELETE CASCADE,
    FOREIGN KEY (kullanici_id) REFERENCES Users(kullanici_id) ON DELETE CASCADE
);

-- Users tablosuna örnek veriler
INSERT INTO Users (ad_soyad, eposta, satici_mi)
VALUES
('Ali Yılmaz', 'ali.yilmaz@yildiz.edu.tr', TRUE),
('Ayşe Demir', 'ayse.demir@yildiz.edu.tr', FALSE),
('Mehmet Kaya', 'mehmet.kaya@yildiz.edu.tr', TRUE),
('Fatma Çelik', 'fatma.celik@yildiz.edu.tr', FALSE),
('Hasan Özkan', 'hasan.ozkan@yildiz.edu.tr', TRUE),
('Emine Arslan', 'emine.arslan@yildiz.edu.tr', TRUE),
('Ahmet Koç', 'ahmet.koc@yildiz.edu.tr', FALSE),
('Zeynep Doğan', 'zeynep.dogan@yildiz.edu.tr', FALSE),
('Halil Şahin', 'halil.sahin@yildiz.edu.tr', TRUE),
('Selin Kurt', 'selin.kurt@yildiz.edu.tr', FALSE);

-- Products tablosuna örnek veriler
INSERT INTO Products (satici_id, urun_adi, kategori, fiyat, stok)
VALUES
(1, 'El Yapımı Kolye', 'Takı', 500.00, 10),
(1, 'Örgü Bere', 'Giyim', 200.00, 18),
(3, 'Ahşap Masa', 'Mobilya', 2000.00, 3),
(3, 'Resim Seti', 'Sanat', 400.00, 8),
(5, 'Seramik Vazo', 'Dekorasyon', 350.00, 20),
(5, 'Cam Kase', 'Dekorasyon', 300.00, 10),
(5, 'Deri Çanta', 'Aksesuar', 800.00, 7),
(1, 'Örgü Atkı', 'Giyim', 250.00, 15),
(3, 'Ahşap Sandalye', 'Mobilya', 1500.00, 5),
(1, 'El Yapımı Yüzük', 'Takı', 450.00, 12);

-- Orders tablosuna örnek veriler
INSERT INTO Orders (alici_id, urun_id, miktar)
VALUES
(2, 1, 2),
(4, 2, 1),
(6, 3, 4),
(8, 5, 1),
(7, 6, 2),
(2, 7, 3),
(4, 8, 2),
(6, 9, 5),
(8, 10, 1),
(7, 4, 2);

-- Reviews tablosuna örnek veriler
INSERT INTO Reviews (urun_id, kullanici_id, puan, yorum)
VALUES
(1, 2, 5, 'Harika bir kolye, çok beğendim.'),
(2, 4, 4, 'Gayet sağlam bir ürün.'),
(3, 6, 5, 'Evime çok yakıştı.'),
(4, 8, 4, 'Kullanışlı bir atkı.'),
(5, 7, 5, 'Mükemmel tasarım.'),
(6, 2, 4, 'Dayanıklı ve şık.'),
(7, 4, 5, 'El işçiliği harika.'),
(8, 6, 5, 'Kaliteli bir masa.'),
(9, 8, 4, 'Şık ve kullanışlı bir cam kase.'),
(10, 7, 5, 'Çok sıcak tutuyor.');



-- Trigger
CREATE OR REPLACE FUNCTION stok_guncelleme() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.miktar > (SELECT stok FROM Products WHERE urun_id = NEW.urun_id) THEN
        RAISE EXCEPTION 'Bu ürün için yeterli stok bulunmamaktadır.';
    END IF;

    UPDATE Products SET stok = stok - NEW.miktar WHERE urun_id = NEW.urun_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER stok_tetikleyici
AFTER INSERT ON Orders
FOR EACH ROW
EXECUTE FUNCTION stok_guncelleme();

-- View
CREATE VIEW UrunYorumlari AS
SELECT p.urun_adi AS UrunAdi, r.puan, r.yorum
FROM Products p
JOIN Reviews r ON p.urun_id = r.urun_id;

-- Fonksiyonlar
-- 1. Toplam Satışlar
CREATE OR REPLACE FUNCTION SaticiToplamSatis(p_satici_id INT) RETURNS NUMERIC AS $$
DECLARE
    toplam_satis NUMERIC := 0;
BEGIN
    SELECT SUM(o.miktar * p.fiyat)
    INTO toplam_satis
    FROM Orders o
    JOIN Products p ON o.urun_id = p.urun_id
    WHERE p.satici_id = p_satici_id;

    RETURN toplam_satis;
END;
$$ LANGUAGE plpgsql;

-- 2. En İyi 3 Ürün
CREATE OR REPLACE FUNCTION EnIyiUrunler() RETURNS TABLE(UrunAdi VARCHAR, OrtalamaPuan NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT p.urun_adi, AVG(r.puan)
    FROM Products p
    JOIN Reviews r ON p.urun_id = r.urun_id
    GROUP BY p.urun_adi
    ORDER BY AVG(r.puan) DESC
    LIMIT 3;
END;
$$ LANGUAGE plpgsql;

-- 3. Kategoriye Göre Ürünler
CREATE OR REPLACE FUNCTION KategoriUrunler(kategori_ad VARCHAR) RETURNS SETOF Products AS $$
BEGIN
    RETURN QUERY SELECT * FROM Products WHERE kategori = kategori_ad;
END;
$$ LANGUAGE plpgsql;

-- Test Sorguları
SELECT * FROM UrunYorumlari;
SELECT SaticiToplamSatis(1);
SELECT * FROM EnIyiUrunler();
SELECT * FROM KategoriUrunler('Takı');
