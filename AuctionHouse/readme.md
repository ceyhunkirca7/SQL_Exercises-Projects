# 🔨 Auction House - Logical Data Model (PostgreSQL)

A fully normalized (3NF) relational database for managing auction events, item submissions, live bidding, ownership provenance tracking, and payments.


## 🗂️ Database Schema (13 Tables)

```
Participant ──┐
Employee ─────┤──▶ Auction_Event ──▶ Lot ──▶ Bid ──▶ Lot_Result ──▶ Payment
Location ─────┘                       │                    │
                                      │                    ▼
Category (self-ref) ──▶ Item ──▶ Item_Submission ──▶ Lot_Submission
                                                           │
                                      Ownership_History ◀──┘
```

### Custom ENUM Types
- `lot_status_enum`: Upcoming, Active, Sold, Unsold
- `payment_method_enum`: Credit_Card, Bank_Transfer, Cash, Cheque
- `transfer_source_enum`: Initial_Registration, Auction_Sale, Private_Transfer

## 🚀 How to Run

### Prerequisites
- **PostgreSQL 12+** installed and running

### Steps

```bash
# 1. Create a new database
psql -U postgres -c "CREATE DATABASE auction_house;"

# 2. Run the SQL script
psql -U postgres -d auction_house -f auction_house.sql
```

### pgAdmin Alternative
1. Open **pgAdmin 4**
2. Right-click on Databases → **Create → Database** → Name: `auction_house`
3. Right-click on `auction_house` → **Query Tool**
4. Open `auction_house.sql` → Click **Execute (▶)**

## ✨ Key Design Features

| Feature | Implementation |
|---------|---------------|
| **3NF Normalization** | No redundant attributes; buyer/price derived from Bid via FK |
| **Historical Tracking** | Ownership_History ledger (append-only, no overwrites) |
| **Many-to-Many** | Lot_Submission bridge table (Composite PK) |
| **Self-Referential** | Category.parent_category_id → Category.category_id |
| **Composite FK** | Lot_Result.(lot_id, winning_bid_id) → Bid.(lot_id, bid_id) |
| **ENUM Constraints** | Statuses & methods locked to predefined values |
| **CHECK Constraints** | Bid.amount > 0, Payment.amount > 0 |

## 📊 Sample Data Summary

- **5** Participants (buyers/sellers)
- **3** Employees, **3** Locations
- **8** Categories (3-level hierarchy: Fine Arts → Paintings → Oil Paintings)
- **6** Items, **6** Submissions
- **3** Auction Events, **6** Lots (Sold/Unsold/Active/Upcoming)
- **13** Bids, **3** Results, **3** Payments
- **10** Ownership records (Initial, Auction Sale, Private Transfer)

## 👤 Author

- **Name:** Ceyhun Kirca
- **Course:** Introduction to DWH and ETL
