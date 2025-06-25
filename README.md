
# Peer-to-Peer Lending Platform (SQL Submission)

## 📌 Objective
This project implements a robust **MySQL-only** backend database for a Peer-to-Peer Lending Platform where borrowers can request loans and investors can fund them. The platform handles user management, loan tracking, investments, repayments, and audit logs—without any frontend/backend implementation.

---

## 🧱 Schema Overview

### ✅ Core Tables
- **`users`**: Stores borrower, investor, and admin details with KYC support.
- **`loans`**: Loan requests from borrowers, including interest and duration.
- **`investments`**: Records which investor funded which loan.
- **`repayments`**: Tracks scheduled and paid installments per loan.
- **`transactions`**: Logs all financial operations (investment, repayment).
- **`audit_trail`**: System activity logs (loan creation, repayments, etc.).
- **`notifications`**: Triggered alerts to users (e.g., loan fully funded).
- **`loan_shares`**: Supports a secondary market for investment transfers.

---

## ⚙️ Functional Highlights

- **Stored Procedures**:
  - `fund_loan(loanId, investorId, amt)`: Invests in a loan and updates funding.
  - `make_repayment(loanId, dueDate, amt)`: Repayment by borrower, updates status.

- **Trigger**:
  - `notify_loan_funded`: Sends a notification to borrower when loan is fully funded.

- **Advanced Queries**:
  - View active loans, upcoming repayments, investor portfolios, repayment status, and audit logs.

---

## 🛠️ How to Run

1. Install MySQL 5.7+ or 8.0+.
2. Open a MySQL client (e.g., MySQL CLI or Workbench).
3. Run the SQL file:
   ```sql
   SOURCE Lending platform.sql;
   ```
4. The database `lending` will be created with sample data, procedures, triggers, and queries.

---

## 🎯 Features Implemented

- ✅ All core features (Users, Loans, Investments, Repayments, Transactions)
- ✅ Bonus: KYC fields, Notification Trigger, Secondary Market (`loan_shares`)
- ✅ Inline documentation and comments
- ✅ 15+ feature queries + 2 stored procedures + 1 trigger

---

## 📄 Notes

- All foreign keys enforce referential integrity.
- ENUM fields used for roles, loan status, and transaction types.
- Unique constraints prevent duplicate investor-loan entries.

---

**Author**: DevifyX SQL Assignment  
**Submission Form**: [https://forms.gle/HZxnwbzDnmLzMsqTA]
