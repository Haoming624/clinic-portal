# Clinic Portal

A Ruby on Rails application for managing patient records in medical clinics with role-based access control.

## Key Features

- **Secure Authentication**  
  Role-based access for receptionists and doctors using Devise

- **Patient Management**  
  - Full CRUD operations for patient records
  - Advanced search & filters (name, status, date of birth)

- **Data Visualization**  
  - Registration trends (line chart)
  - Patient status breakdown (pie chart)

- **Modern UI**  
  - Responsive Bootstrap 5 interface
  - Intuitive navigation
  - Clean, professional design

## Technology Stack

| Category        | Technologies                          |
|-----------------|---------------------------------------|
| Backend         | Ruby on Rails 8                       |
| Database        | PostgreSQL 14+                        |
| Authentication  | Devise                                |
| Frontend        | Bootstrap 5, Chart.js                 |
| UI Components   | Bootstrap Icons                       |
| Pagination      | Kaminari                              |
| JS Bundling     | Importmaps                            |

## 🚀 Getting Started

### Prerequisites
- Ruby 3.3.0+
- PostgreSQL 14+
- Node.js (for asset compilation)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Haoming624/clinic-portal.git
   cd clinic-portal
   ```

2. **Configure environment**  
   Create `.env` file:
   ```bash
   cp .env.example .env
   ```
   Edit with your PostgreSQL credentials.

3. **Install dependencies**
   ```bash
   bundle install
   ```

4. **Set up database**
   ```bash
   bin/rails db:setup
   ```

5. **Start the server**
   ```bash
   bin/rails server
   ```
   Visit: http://localhost:3000

### Demo Accounts
| Role         | Email               | Password     |
|--------------|---------------------|-------------|
| Receptionist | reception@test.com  | password123 |
| Doctor       | doctor@test.com     | password123 |

## Database Management

| Command                | Action                                  |
|------------------------|----------------------------------------|
| `bin/rails db:migrate` | Run pending migrations                 |
| `bin/rails db:seed`    | Load demo data (patients + users)      |
| `bin/rails db:reset`   | **WARNING**: Full database reset       |

## 📂 Project Structure

```
clinic-portal/
├── app/               # Core application code
│   ├── controllers/   # Business logic
│   ├── models/        # Data models
│   ├── views/         # UI templates
│   └── assets/        # Static files
├── config/            # Configuration
└── db/                # Database schema/migrations
```