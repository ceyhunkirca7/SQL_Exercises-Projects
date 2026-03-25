# 🛍️ CraftMart - El Yapımı Ürün Pazaryeri (PostgreSQL)

Satıcıların el yapımı ürünlerini listeleyebildiği, alıcıların sipariş verebildiği ve yorum bırakabildiği bir e-ticaret veritabanı.

## 📂 Project Files

| Dosya | Açıklama |
|-------|----------|
| `Craftmart.sql` | DDL (CREATE) + örnek veriler (INSERT) + Trigger, View, Fonksiyonlar |

## 🗂️ Database Schema (4 Tablo)

```
Users (kullanici_id, ad_soyad, eposta, satici_mi)
  │
  ├──▶ Products (urun_id, satici_id FK, urun_adi, kategori, fiyat, stok)
  │       │
  │       ├──▶ Orders (siparis_id, alici_id FK, urun_id FK, miktar)
  │       │
  │       └──▶ Reviews (yorum_id, urun_id FK, kullanici_id FK, puan, yorum)
  │
  └──────────────────────┘
```

## ✨ Özellikler

| Özellik | Detay |
|---------|-------|
| **CHECK Constraints** | `fiyat > 0`, `stok >= 0`, `miktar > 0`, `puan BETWEEN 1 AND 5` |
| **UNIQUE** | `Users.eposta` benzersiz |
| **CASCADE Delete** | Kullanıcı silinirse ürünleri, siparişleri ve yorumları da silinir |
| **Trigger** | Sipariş verilince stok otomatik düşer; yetersiz stokta hata fırlatır |
| **View** | `UrunYorumlari`: Ürün adı, puan ve yorum birleşik görünümü |
| **Fonksiyonlar** | `SaticiToplamSatis()`, `EnIyiUrunler()`, `KategoriUrunler()` |

## 🚀 Nasıl Çalıştırılır

### Gereksinimler
- **PostgreSQL 12+**

### Adımlar

```bash
# 1. Veritabanı oluştur
psql -U postgres -c "CREATE DATABASE craftmart;"

# 2. SQL dosyasını çalıştır
psql -U postgres -d craftmart -f Craftmart.sql
```

### pgAdmin ile
1. **Databases** → Sağ tık → **Create → Database** → Ad: `craftmart`
2. `craftmart` → Sağ tık → **Query Tool**
3. `Craftmart.sql` dosyasını aç → **Execute (▶)**

## 🧪 Test Sorguları

```sql
-- Tüm ürün yorumlarını görüntüle
SELECT * FROM UrunYorumlari;

-- Ali Yılmaz'ın (ID:1) toplam satış geliri
SELECT SaticiToplamSatis(1);

-- En yüksek puanlı 3 ürün
SELECT * FROM EnIyiUrunler();

-- Takı kategorisindeki ürünler
SELECT * FROM KategoriUrunler('Takı');
```

## 📊 Örnek Veri Özeti

- **10** Kullanıcı (5 satıcı, 5 alıcı)
- **10** Ürün (Takı, Giyim, Mobilya, Sanat, Dekorasyon, Aksesuar)
- **10** Sipariş
- **10** Yorum (1-5 puan)

## 👤 Author

- **Name:** Ceyhun Kirca
