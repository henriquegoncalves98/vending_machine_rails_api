# README

# Vending Machine API

A complete **Rails 8.0.4 API** for a vending machine with product management, coin change calculation, and stock tracking.

## 🎯 Features

- **Products CRUD** (name, stock, price with decimal support)
- **Purchase endpoint** with exact payment or change calculation
- **Real-time stock updates** for products and coins
- **Bulk refill** endpoints for products and coins
- **Pagination** on product listing
- **Full test coverage** (models, controllers, services)
- **Database constraints** (unique names, non-negative stock/price)

## 🛠️ Tech Stack

- **Rails 8.0.4** | **PostgreSQL** | **RSpec** | **FactoryBot**

## 🚀 Quick Start

```bash
# 1. Clone & Install
git clone <your-repo>
cd vending-machine-api
bundle install

# 2. Start PostgreSQL (macOS)
brew services start postgresql

# 3. Setup Database
rails db:create db:migrate db:seed

# 4. Run Tests
bundle exec rspec

# 5. Start Server
rails s -p 3000
```

## 🧪 Testing

```bash
# All tests
bundle exec rspec

# Specific file
bundle exec rspec spec/controllers/products_controller_spec.rb

# Watch mode  
bundle exec rspec --format documentation
```

**100% coverage** across models, controllers, and services.

## 📋 API Endpoints

| Method | Endpoint | Description | Parameters | Response |
|--------|----------|-------------|------------|----------|
| `GET` | `/products` | **List all products** (paginated) | `?page=1` | `200` JSON w/ data + pagination meta |
| `GET` | `/products/:id` | **Show product** | `-` | `200` Product JSON |
| `POST` | `/products` | **Create product** | `{product: {name, stock, price}}` | `201` Created product |
| `PATCH` | `/products/:id` | **Update product** | `{product: {name, stock, price}}` | `200` Updated product |
| `DELETE` | `/products/:id` | **Delete product** | `-` | `204` No content |
| **`POST`** | `/products/:id/purchase` | **Purchase product** | `{amount: 2.00}` | `200` `{change: [50], total_change: 50, stock: 9}` |
| `POST` | `/products/refill` | **Refill ALL products** | `-` | `200` `{message: "All products refilled", updated_count: 5}` |
| `POST` | `/coins/refill` | **Refill ALL coins** | `-` | `200` `{message: "All coins refilled", updated_count: 8}` |

### 🔍 Example Requests

```bash
# List products (page 1)
curl http://localhost:3000/products

# Purchase Coke (1.50€) with 2.00€
curl -X POST http://localhost:3000/products/1/purchase \
  -H "Content-Type: application/json" \
  -d '{"amount": 2.00}'

# Create new product
curl -X POST http://localhost:3000/products \
  -H "Content-Type: application/json" \
  -d '{"product":{"name":"Chips","stock":20,"price":2.50}}'

# Refill products to 10 stock each
curl -X POST http://localhost:3000/products/refill
```

### 📊 Sample Responses

**Products Index:**
```json
{
  "data": [
    {"id":1,"name":"Coke","price":1.5,"stock":9},
    {"id":2,"name":"Water","price":1.0,"stock":0}
  ],
  "meta": {
    "current_page":1,
    "total_pages":1,
    "total_count":2
  }
}
```

**Purchase Success:**
```json
{
  "change": [50],
  "total_change": 50,
  "stock": 9
}
```

**Purchase Error:**
```json
{
  "error": "You didn't insert enough money"
}
```

## 🗄️ Database Schema

```
coins
├── denomination (unique, int)  → 200,100,50,20,10,5,2,1
├── stock (int ≥ 0)            → Current coin inventory
└── timestamps

products  
├── name (string 200, unique)  → "Coke", "Water"
├── stock (int ≥ 0)            → Current product inventory  
├── price (decimal 10,2 ≥ 0)   → 1.50, 2.99
└── timestamps
```

## 🧩 Key Implementation Details

### Change Algorithm
- **Greedy**: Largest coins first `[200,100,50,20,10,5,2,1]` (cents)
- **Stock-aware**: Only uses available coin inventory
- **Atomic**: Product + coin stock updated in transaction
- **Error handling**: `NotEnoughChange` if coins insufficient

### Error Handling
```
InvalidAmountSubmitted  → 400 (negative/insufficient)
ProductOutOfStock       → 400 
NotEnoughChange         → 422
Product Not Found       → 404
Validation Errors       → 422
```

## 🔧 Development

```bash
# Database
rails db:drop db:create db:migrate db:seed

# Console
rails c

# Routes
rails routes | grep products

# Run specific test
rspec spec/services/purchase_item_service_spec.rb:25
```

## 📈 Seed Data

Run `rails db:seed` for sample data:
- **8 coin denominations** (full stock)
- **5 sample products** (Coke, Water, Chips, Candy, Soda)

## 🚀 Production

```bash
# RAILS_ENV=production bundle exec rails db:migrate
# RAILS_ENV=production rails s -p 3000
```

**Heroku-ready** - just set `DATABASE_URL`.

***

**✅ Ready to deploy!** Full CRUD + purchase flow + tests + error handling + pagination.

**Test all endpoints:** `rails s && open http://localhost:3000/products`
