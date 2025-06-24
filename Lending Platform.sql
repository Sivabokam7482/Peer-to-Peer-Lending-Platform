CREATE DATABASE IF NOT EXISTS lending;
USE lending;
-- Lending Platform Database Schema (Peer-to-Peer Lending Platform)
-- Author: DevifyX Assignment
-- Description: Schema for managing users, loans, investments, repayments, and transactions

-- -----------------------------
-- 1. USERS TABLE
-- -----------------------------
-- Stores information about all platform users (borrowers, investors, and admins)
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,  -- Unique user identifier
    full_name VARCHAR(100) NOT NULL,         -- Full name of the user
    email VARCHAR(100) UNIQUE NOT NULL,      -- User's email (must be unique)
    password_hash VARCHAR(255) NOT NULL,     -- Hashed password for security
    role ENUM('borrower', 'investor', 'admin') NOT NULL,  -- User role type
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,  -- When the user account was created
    kyc_verified BOOLEAN DEFAULT FALSE,      -- Whether user completed KYC verification
    kyc_document TEXT,                       -- Link or base64 of KYC document
    INDEX (email)                            -- Index to optimize lookup by email
);

INSERT INTO users (full_name, email, password_hash, role, kyc_verified, kyc_document) VALUES
('Alice Kumar', 'alice@example.com', 'hash1', 'borrower', TRUE, 'link_to_doc1'),
('Bob Mehta', 'bob@example.com', 'hash2', 'investor', TRUE, 'link_to_doc2'),
('Carol Singh', 'carol@example.com', 'hash3', 'admin', FALSE, NULL),
('David Roy', 'david@example.com', 'hash4', 'investor', TRUE, 'link_to_doc3'),
('Eva Desai', 'eva@example.com', 'hash5', 'borrower', FALSE, NULL),
('Farhan Ali', 'farhan@example.com', 'hash6', 'investor', TRUE, 'link_to_doc6'),
('Grace Pinto', 'grace@example.com', 'hash7', 'borrower', TRUE, 'link_to_doc7'),
('Hari Patel', 'hari@example.com', 'hash8', 'investor', TRUE, 'link_to_doc8');

SELECT * FROM users;

-- -----------------------------
-- 2. LOANS TABLE
-- -----------------------------
-- Contains loan requests posted by borrowers
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,       -- Unique loan ID
    borrower_id INT NOT NULL,                     -- Reference to the user (borrower)
    amount DECIMAL(12,2) NOT NULL,                -- Requested loan amount
    interest_rate DECIMAL(5,2) NOT NULL,          -- Annual interest rate in percentage
    duration_months INT NOT NULL,                 -- Duration in months for repayment
    purpose TEXT,                                 -- Description of the loan's purpose
    status ENUM('open', 'funded', 'active', 'completed', 'defaulted') DEFAULT 'open', -- Current loan status
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,  -- Timestamp of loan creation
    funded_amount DECIMAL(12,2) DEFAULT 0.00,     -- Total amount already funded by investors
    FOREIGN KEY (borrower_id) REFERENCES users(user_id)  -- Link to borrower
);

INSERT INTO loans (borrower_id, amount, interest_rate, duration_months, purpose, status, funded_amount) VALUES
(1, 100000.00, 12.50, 12, 'Home renovation', 'funded', 100000.00),
(5, 50000.00, 10.00, 6, 'Medical emergency', 'open', 20000.00),
(7, 150000.00, 11.00, 18, 'Small business', 'open', 0.00),
(1, 75000.00, 9.50, 9, 'Car repair', 'active', 75000.00),
(5, 60000.00, 10.25, 6, 'Tuition fees', 'completed', 60000.00),
(7, 85000.00, 12.00, 8, 'Travel loan', 'defaulted', 60000.00);

SELECT * FROM loans;

-- -----------------------------
-- 3. INVESTMENTS TABLE
-- -----------------------------
-- Records how much each investor invests in which loan
CREATE TABLE investments (
    investment_id INT AUTO_INCREMENT PRIMARY KEY,   -- Unique ID per investment
    loan_id INT NOT NULL,                           -- Loan being invested in
    investor_id INT NOT NULL,                       -- User (investor) who is investing
    invested_amount DECIMAL(12,2) NOT NULL,         -- Amount invested
    invested_at DATETIME DEFAULT CURRENT_TIMESTAMP, -- Time of investment
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id), -- Enforce FK loan
    FOREIGN KEY (investor_id) REFERENCES users(user_id),-- Enforce FK user
    UNIQUE KEY (loan_id, investor_id)              -- Prevents duplicate investments in the same loan
);

INSERT INTO investments (loan_id, investor_id, invested_amount) VALUES
(1, 2, 60000.00),
(1, 4, 40000.00),
(2, 4, 20000.00),
(4, 6, 75000.00),
(5, 2, 60000.00),
(6, 6, 30000.00),
(6, 8, 30000.00);

SELECT * FROM investments;

-- -----------------------------
-- 4. REPAYMENT SCHEDULES TABLE
-- -----------------------------
-- Schedules and tracks loan repayments
CREATE TABLE repayments (
    repayment_id INT AUTO_INCREMENT PRIMARY KEY,  -- Unique repayment ID
    loan_id INT NOT NULL,                         -- Loan to which this repayment belongs
    due_date DATE NOT NULL,                       -- Scheduled repayment due date
    amount_due DECIMAL(12,2) NOT NULL,            -- Amount expected to be paid
    amount_paid DECIMAL(12,2) DEFAULT 0.00,       -- Amount actually paid so far
    paid_at DATETIME NULL,                        -- Timestamp when payment was made
    is_paid BOOLEAN DEFAULT FALSE,                -- Flag to indicate if fully paid
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id) ON DELETE CASCADE-- Enforce FK loan
);

INSERT INTO repayments (loan_id, due_date, amount_due, amount_paid, paid_at, is_paid) VALUES
(1, '2025-07-01', 8500.00, 8500.00, '2025-07-01 10:00:00', TRUE),
(1, '2025-08-01', 8500.00, 0.00, NULL, FALSE),
(4, '2025-06-15', 9000.00, 9000.00, '2025-06-14 09:00:00', TRUE),
(5, '2025-05-20', 10000.00, 10000.00, '2025-05-20 08:30:00', TRUE),
(5, '2025-06-20', 10000.00, 10000.00, '2025-06-20 08:00:00', TRUE),
(6, '2025-07-01', 10000.00, 2000.00, '2025-07-02 09:00:00', FALSE);

SELECT * FROM repayments;

-- -----------------------------
-- 5. TRANSACTIONS TABLE  - All Financial Activities
-- -----------------------------
-- Logs all money movements: investments, repayments, disbursements, refunds
CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,     -- Unique transaction ID
    user_id INT NOT NULL,  							   -- User involved in transaction
	loan_id INT NOT NULL,							   -- Loan involved in transaction
    transaction_type ENUM('investment', 'repayment', 'disbursement', 'refund') NOT NULL, -- Type of transaction
    amount DECIMAL(12,2) NOT NULL,                     -- Amount of money moved
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,     -- Timestamp of the transaction
    FOREIGN KEY (user_id) REFERENCES users(user_id)	-- FK to users
);

INSERT INTO transactions (user_id, loan_id, transaction_type, amount) VALUES
(2, 1, 'investment', 60000.00),
(4, 1, 'investment', 40000.00),
(4, 2, 'investment', 20000.00),
(6, 4, 'investment', 75000.00),
(2, 5, 'investment', 60000.00),
(6, 6, 'investment', 30000.00),
(8, 6, 'investment', 30000.00),
(1, 1, 'repayment', 8500.00);

SELECT * FROM transactions;

-- -----------------------------
-- 6. audit_Trail — System Activity Log
-- -----------------------------
-- Logs key system actions for transparency and debugging
CREATE TABLE audit_trail (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,          -- Unique audit entry ID
    user_id INT,                                      -- User who performed the action
    action_type ENUM('loan_created', 'invested', 'repaid', 'status_changed') NOT NULL, -- Category of action
    action_details TEXT,                              -- Extra details or descriptions
    action_time DATETIME DEFAULT CURRENT_TIMESTAMP,   -- When the action occurred
    FOREIGN KEY (user_id) REFERENCES users(user_id)	  -- FK to actor
);

INSERT INTO audit_trail (user_id, action_type, action_details) VALUES
(1, 'loan_created', 'Loan #1 created for home renovation'),
(5, 'loan_created', 'Loan #2 for medical emergency'),
(2, 'invested', 'Bob invested ₹60,000 in Loan #1'),
(4, 'invested', 'David invested ₹20,000 in Loan #2'),
(6, 'invested', 'Farhan invested ₹75,000 in Loan #4'),
(7, 'loan_created', 'Loan #3 for small business expansion'),
(1, 'repaid', 'Alice repaid ₹8,500 for Loan #1');

SELECT * FROM audit_trail;

-- -----------------------------
-- 7. NOTIFICATIONS TABLE
-- -----------------------------
-- Stores system-generated messages for users
-- Examples: loan approval, investment confirmation, repayment reminders
CREATE TABLE notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,  -- Unique identifier for each notification
    user_id INT NOT NULL,                            -- The user who receives the notification
    message TEXT NOT NULL,                           -- Notification content/message
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,   -- Timestamp when the notification was created
    FOREIGN KEY (user_id) REFERENCES users(user_id)  -- Links to the recipient user
);

INSERT INTO notifications (user_id, message)
VALUES
(1, 'Your loan request has been approved.'),
(2, 'You have successfully funded a loan.'),
(3, 'New loan listings are available.'),
(4, 'Repayment is due soon.'),
(2, 'One of your loans has been fully funded.');

SELECT * FROM notifications;

-- -----------------------------
-- 8. LOAN SHARES TABLE (Secondary Market Support)
-- -----------------------------
-- Allows investors to sell their investment shares to other investors (secondary market)
CREATE TABLE loan_shares (
    share_id INT AUTO_INCREMENT PRIMARY KEY,         -- Unique identifier for each share listing
    investment_id INT NOT NULL,                      -- Reference to the original investment
    seller_id INT NOT NULL,                          -- User ID of the seller (original investor)
    buyer_id INT NULL,                               -- User ID of the buyer (null if not yet sold)
    share_amount DECIMAL(12,2) NOT NULL,             -- Amount of the investment being sold
    listed_at DATETIME DEFAULT CURRENT_TIMESTAMP,    -- Timestamp when the share was listed
    sold_at DATETIME,                                -- Timestamp when the share was sold (nullable)
    status ENUM('listed', 'sold') DEFAULT 'listed',  -- Current status of the share listing
    FOREIGN KEY (investment_id) REFERENCES investments(investment_id),  -- FK to original investment
    FOREIGN KEY (seller_id) REFERENCES users(user_id),                 -- FK to seller user
    FOREIGN KEY (buyer_id) REFERENCES users(user_id)                   -- FK to buyer user (nullable)
);
INSERT INTO loan_shares (investment_id, seller_id, buyer_id, share_amount, listed_at, sold_at, status)
VALUES
(1, 2, 3, 5000, NOW(), NOW(), 'sold'),
(2, 3, NULL, 10000, NOW(), NULL, 'listed'),
(3, 2, NULL, 4000, NOW(), NULL, 'listed'),
(4, 3, 2, 10000, NOW(), NOW(), 'sold'),
(5, 2, NULL, 5000, NOW(), NULL, 'listed');

SELECT * FROM loan_shares;

-- -----------------------------
--  FEATURE QUERIES
-- -----------------------------
-- Query 1: List active loans
SELECT * FROM loans WHERE status = 'active';

-- Query 2: Show portfolio per investor
SELECT u.full_name, i.loan_id, i.invested_amount
FROM investments i
JOIN users u ON u.user_id = i.investor_id;

-- Query 3: Repayment history for a borrower
SELECT r.*, l.borrower_id, u.full_name
FROM repayments r
JOIN loans l ON r.loan_id = l.loan_id
JOIN users u ON l.borrower_id = u.user_id
WHERE u.user_id = 1;

-- Query 4: Find loans that are fully funded
SELECT loan_id, amount, funded_amount, status
FROM loans
WHERE amount = funded_amount;

-- Query 5: List all transactions for a specific user
SELECT * FROM transactions
WHERE user_id = 1
ORDER BY created_at DESC;

-- Query 6: Show all borrowers and the total amount they borrowed
SELECT u.full_name, SUM(l.amount) AS total_borrowed
FROM users u
JOIN loans l ON u.user_id = l.borrower_id
WHERE u.role = 'borrower'
GROUP BY u.user_id;

-- Query 7: Show loan status distribution
SELECT status, COUNT(*) AS loan_count
FROM loans
GROUP BY status;

-- Query 8: Show total investments per loan
SELECT loan_id, SUM(invested_amount) AS total_invested
FROM investments
GROUP BY loan_id;

-- Query 9: List upcoming repayments
SELECT * FROM repayments
WHERE due_date > CURDATE()
ORDER BY due_date ASC;

-- Query 10: Audit trail for all investment-related actions
SELECT * FROM audit_trail
WHERE action_type = 'invested'
ORDER BY action_time DESC;

-- -----------------------------
-- STORED PROCEDURE: FUND A LOAN
-- -----------------------------
-- Adds a new investment and updates the loan funding amount
DELIMITER //
CREATE PROCEDURE fund_loan(IN loanId INT, IN investorId INT, IN amt DECIMAL(12,2))
BEGIN
	DECLARE total_needed DECIMAL(12,2);
    DECLARE current_funded DECIMAL(12,2);
    DECLARE borrower INT;
    
	-- Get the loan's total amount and current funded amount
    SELECT amount, funded_amount INTO total_needed, current_funded
    FROM loans WHERE loan_id = loanId;
    
      -- Check for duplicate investment (optional)
    IF EXISTS (
        SELECT 1 FROM investments WHERE loan_id = loanId AND investor_id = investorId
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Duplicate investment not allowed';
    ELSE
		 -- Update the funded amount
		UPDATE loans SET funded_amount = funded_amount + amt WHERE loan_id = loanId;
		
		-- Add investment
		INSERT INTO investments(loan_id, investor_id, invested_amount)
		VALUES (loanId, investorId, amt);
		
		-- Record transaction
		INSERT INTO transactions(user_id, loan_id, transaction_type, amount)
		VALUES (investorId, loanId, 'investment', amt);
		
		-- Audit log
		INSERT INTO audit_trail(user_id, action_type, action_details)
		VALUES (investorId, 'invested', CONCAT('Invested ₹', amt, ' in loan #', loanId));
		
		-- Update loan status if fully funded
		IF (current_funded + amt) >= total_needed THEN
			UPDATE loans SET status = 'funded' WHERE loan_id = loanId;
			-- Insert audit log for status change
			INSERT INTO audit_trail(user_id, action_type, action_details)
			VALUES ((SELECT borrower_id FROM loans WHERE loan_id = loanId),
					'status_changed', CONCAT('Loan #', loanId, ' marked as funded'));
		END IF;
    END IF;
END;
//
DELIMITER ;

-- ------------------------------
-- STORED PROCEDURE: MAKE A REPAYMENT
-- ------------------------------
-- Marks repayment as paid and logs the transaction
DELIMITER //
CREATE PROCEDURE make_repayment(IN loanId INT, IN dueDate DATE, IN amt DECIMAL(12,2))
BEGIN
    UPDATE repayments
    SET amount_paid =amount_paid + amt, 
    is_paid =(amount_paid + amt >= amount_due), 
    paid_at = NOW()
    WHERE loan_id = loanId AND due_date = dueDate AND is_paid = FALSE;
    
	-- Insert repayment transaction
    INSERT INTO transactions(user_id, loan_id, transaction_type, amount)
    VALUES ((SELECT borrower_id FROM loans WHERE loan_id = loanId), loanId, 'repayment', amt);
        
	-- Insert audit 
    INSERT INTO audit_trail(user_id, action_type, action_details)
    VALUES ((SELECT borrower_id FROM loans WHERE loan_id = loanId), 'repaid', CONCAT('Paid ', amt, ' on loan #', loanId));
END;
//
DELIMITER ;

-- -----------------------------
-- TRIGGER: NOTIFY BORROWER ON FULL FUNDING
-- -----------------------------
DELIMITER //
CREATE TRIGGER notify_loan_funded
AFTER UPDATE ON loans
FOR EACH ROW
BEGIN
    IF NEW.status = 'funded' AND OLD.status != 'funded' THEN
        INSERT INTO notifications(user_id, message)
        VALUES (NEW.borrower_id, CONCAT('Your loan #', NEW.loan_id, ' has been fully funded.'));
    END IF;
END;
//
DELIMITER ;

-- Total amount repaid and remaining due per loan
SELECT loan_id,
       SUM(amount_due) AS total_due,
       SUM(amount_paid) AS total_paid,
       SUM(amount_due - amount_paid) AS remaining_due
FROM repayments
GROUP BY loan_id;

-- Number of notifications received by each user
SELECT u.full_name, COUNT(n.notification_id) AS total_notifications
FROM notifications n
JOIN users u ON n.user_id = u.user_id
GROUP BY u.user_id;

-- Show all loans that are not yet fully funded with remaining amount
SELECT loan_id, amount, funded_amount, (amount - funded_amount) AS remaining_to_fund
FROM loans
WHERE funded_amount < amount
AND status IN ('open', 'funded');

-- Show all loans that are defaulted and have pending repayments
SELECT l.loan_id, u.full_name AS borrower_name, r.due_date, r.amount_due, r.amount_paid
FROM loans l
JOIN repayments r ON l.loan_id = r.loan_id
JOIN users u ON l.borrower_id = u.user_id
WHERE l.status = 'defaulted' AND r.is_paid = FALSE;