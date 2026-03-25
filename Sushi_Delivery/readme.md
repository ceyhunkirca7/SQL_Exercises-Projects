# 🍣 Sushi Delivery - Teslimat Sistemi Veritabanı (PostgreSQL)

Sushi restoranı için müşteri yönetimi, menü, sipariş takibi, kurye ataması ve ödeme süreçlerini kapsayan 3NF uyumlu ilişkisel veritabanı.

## 📂 Project Files

| Dosya | Açıklama |
|-------|----------|
| `sushi.sql` | DDL (CREATE) + örnek veriler (INSERT) |
| `DB_Ceyhun_Kirca_HW_Sushi.png` | ER Diyagramı (dbdiagram.io) |

## 🗂️ Database Schema (14 Tablo)

```
City ──▶ District ──▶ Address ◀── Customer
                         │
Menu_Category ──▶ Menu_Item ──▶ Order_Item ──▶ Orders ──▶ Delivery ──▶ Courier
                     │                          │
              Menu_Item_Ingredient              Payment ──▶ Payment_Method
                     │
                Ingredient
```

### Tablolar

| # | Tablo | Açıklama |
|---|-------|----------|
| 1 | `City` | Şehirler (İstanbul, Ankara, İzmir) |
| 2 | `District` | İlçeler (Kadıköy, Beşiktaş, Çankaya...) |
| 3 | `Customer` | Müşteriler (ad, telefon, email) |
| 4 | `Address` | Teslimat adresleri (FK: customer, district) |
| 5 | `Menu_Category` | Menü kategorileri (Rolls, Nigiri, Sashimi...) |
| 6 | `Menu_Item` | Menü ürünleri (fiyat, açıklama, müsaitlik) |
| 7 | `Ingredient` | Ham malzemeler (pirinç, somon, nori...) |
| 8 | `Menu_Item_Ingredient` | Reçete köprüsü (M2M) |
| 9 | `Order_Status` | Sipariş durumları (Bekliyor, Hazırlanıyor, Yolda, Teslim Edildi, İptal) |
| 10 | `Orders` | Siparişler (müşteri, durum, özel not) |
| 11 | `Order_Item` | Sipariş kalemleri (ürün, miktar, sipariş anı fiyatı) |
| 12 | `Courier` | Kuryeler (ad, telefon, araç tipi) |
| 13 | `Delivery` | Teslimat kaydı (1:1 Orders, kurye, adres, süreler) |
| 14 | `Payment` | Ödeme (miktar, yöntem, başarı durumu) |

## 🚀 Nasıl Çalıştırılır

### Gereksinimler
- **PostgreSQL 12+**

### Adımlar

```bash
# 1. Veritabanı oluştur
psql -U postgres -c "CREATE DATABASE sushi_delivery;"

# 2. SQL dosyasını çalıştır
psql -U postgres -d sushi_delivery -f sushi.sql
```

### pgAdmin ile
1. **Databases** → Sağ tık → **Create → Database** → Ad: `sushi_delivery`
2. `sushi_delivery` → Sağ tık → **Query Tool**
3. `sushi.sql` dosyasını aç → **Execute (▶)**

## ✨ Tasarım Özellikleri

| Özellik | Detay |
|---------|-------|
| **3NF** | Şehir/İlçe/Adres hiyerarşisi ile konum tekrarı önlendi |
| **Tarihsel Fiyat** | `unit_price_at_order` ile sipariş anındaki fiyat korunur |
| **1:1 İlişki** | `Delivery.order_id UNIQUE` — her siparişe tek teslimat |
| **M2M Köprü** | `Menu_Item_Ingredient` — ürün-malzeme reçetesi |
| **UNIQUE** | Telefon numaraları (Customer, Courier) benzersiz |
| **Boolean Flags** | `is_available`, `is_active`, `is_successful` |

## 📊 Örnek Veri Özeti

- **3** Şehir, **8** İlçe
- **4** Müşteri, **4** Adres
- **5** Menü Kategorisi, **11** Ürün, **7** Malzeme
- **4** Kurye
- **5** Sipariş Durumu, **4** Ödeme Yöntemi
- **4** Sipariş (Teslim Edildi / Yolda / Hazırlanıyor / Bekliyor)

## 👤 Author

- **Name:** Ceyhun Kirca
- **Course:** Introduction to DWH and ETL
