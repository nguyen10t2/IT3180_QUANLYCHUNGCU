-- =============================================
-- 03_constraints_and_indexes.sql - Foreign Keys, Indexes & Constraints
-- Run this file after 02_tables.sql
-- =============================================

-- =============================================
-- FOREIGN KEY CONSTRAINTS
-- =============================================

-- house_holds
ALTER TABLE house_holds 
ADD CONSTRAINT fk_household_head_resident 
FOREIGN KEY (head_resident_id) REFERENCES residents(resident_id) ON DELETE SET NULL;

-- residents
ALTER TABLE residents 
ADD CONSTRAINT fk_resident_household 
FOREIGN KEY (house_id) REFERENCES house_holds(house_hold_id) ON DELETE SET NULL;

-- users
ALTER TABLE users 
ADD CONSTRAINT fk_user_resident 
FOREIGN KEY (resident_id) REFERENCES residents(resident_id) ON DELETE SET NULL;

ALTER TABLE users 
ADD CONSTRAINT fk_user_approved_by 
FOREIGN KEY (approved_by) REFERENCES users(user_id) ON DELETE SET NULL;

-- sessions
ALTER TABLE sessions 
ADD CONSTRAINT fk_session_user 
FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;

-- invoices
ALTER TABLE invoices 
ADD CONSTRAINT fk_invoice_household 
FOREIGN KEY (house_hold_id) REFERENCES house_holds(house_hold_id) ON DELETE CASCADE;

ALTER TABLE invoices 
ADD CONSTRAINT fk_invoice_created_by 
FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL;

ALTER TABLE invoices 
ADD CONSTRAINT fk_invoice_confirmed_by 
FOREIGN KEY (confirmed_by) REFERENCES users(user_id) ON DELETE SET NULL;

-- invoice_items
ALTER TABLE invoice_items 
ADD CONSTRAINT fk_invoice_item_invoice 
FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id) ON DELETE CASCADE;

ALTER TABLE invoice_items 
ADD CONSTRAINT fk_invoice_item_fee_type 
FOREIGN KEY (fee_type_id) REFERENCES fee_types(fee_type_id) ON DELETE SET NULL;

-- payment_history
ALTER TABLE payment_history 
ADD CONSTRAINT fk_payment_invoice 
FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id) ON DELETE CASCADE;

ALTER TABLE payment_history 
ADD CONSTRAINT fk_payment_paid_by 
FOREIGN KEY (paid_by) REFERENCES users(user_id) ON DELETE SET NULL;

-- notifications
ALTER TABLE notifications 
ADD CONSTRAINT fk_notification_created_by 
FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL;

-- notification_reads
ALTER TABLE notification_reads 
ADD CONSTRAINT fk_notification_read_notification 
FOREIGN KEY (notification_id) REFERENCES notifications(notification_id) ON DELETE CASCADE;

ALTER TABLE notification_reads 
ADD CONSTRAINT fk_notification_read_user 
FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;

-- feedbacks
ALTER TABLE feedbacks 
ADD CONSTRAINT fk_feedback_user 
FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL;

ALTER TABLE feedbacks 
ADD CONSTRAINT fk_feedback_household 
FOREIGN KEY (house_hold_id) REFERENCES house_holds(house_hold_id) ON DELETE SET NULL;

ALTER TABLE feedbacks 
ADD CONSTRAINT fk_feedback_assigned_to 
FOREIGN KEY (assigned_to) REFERENCES users(user_id) ON DELETE SET NULL;

-- feedback_comments
ALTER TABLE feedback_comments 
ADD CONSTRAINT fk_feedback_comment_feedback 
FOREIGN KEY (feedback_id) REFERENCES feedbacks(feedback_id) ON DELETE CASCADE;

ALTER TABLE feedback_comments 
ADD CONSTRAINT fk_feedback_comment_user 
FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL;

-- =============================================
-- INDEXES - HOUSEHOLDS
-- =============================================
CREATE INDEX idx_household_room ON house_holds(room_number);
CREATE INDEX idx_household_floor ON house_holds(floor);
CREATE INDEX idx_household_created ON house_holds(created_at DESC);
CREATE INDEX idx_household_head_resident ON house_holds(head_resident_id);

-- =============================================
-- INDEXES - RESIDENTS
-- =============================================
CREATE INDEX idx_resident_phone ON residents(phone_number);
CREATE INDEX idx_resident_house ON residents(house_id);
CREATE INDEX idx_resident_id_card ON residents(id_card);
CREATE INDEX idx_resident_created ON residents(created_at DESC);
CREATE INDEX idx_resident_status ON residents(status);

-- =============================================
-- INDEXES - USERS
-- =============================================
CREATE INDEX idx_user_email ON users(email);
CREATE INDEX idx_user_role ON users(role);
CREATE INDEX idx_user_resident ON users(resident_id);
CREATE INDEX idx_user_created ON users(created_at DESC);
CREATE INDEX idx_user_status_resident ON users(status, resident_id);
CREATE INDEX idx_user_approved_by ON users(approved_by);

-- =============================================
-- INDEXES - SESSIONS
-- =============================================
CREATE INDEX idx_session_user ON sessions(user_id);
CREATE INDEX idx_session_token ON sessions(refresh_token);
CREATE INDEX idx_session_expires ON sessions(expires_at);

-- =============================================
-- INDEXES - OTP & RESET TOKENS
-- =============================================
CREATE INDEX idx_otp_email ON otp_tokens(email);
CREATE INDEX idx_otp_expires ON otp_tokens(expires_at);
CREATE UNIQUE INDEX idx_otp_email_active ON otp_tokens(email) WHERE is_used = FALSE;
CREATE INDEX idx_reset_email ON reset_tokens(email);
CREATE INDEX idx_reset_token ON reset_tokens(reset_token);

-- =============================================
-- INDEXES - FEE TYPES
-- =============================================
CREATE INDEX idx_fee_type_category ON fee_types(category);
CREATE INDEX idx_fee_type_active ON fee_types(is_active);

-- =============================================
-- INDEXES - INVOICES
-- =============================================
CREATE INDEX idx_invoice_household ON invoices(house_hold_id);
CREATE INDEX idx_invoice_period ON invoices(period_year, period_month);
CREATE INDEX idx_invoice_status ON invoices(status);
CREATE INDEX idx_invoice_due ON invoices(due_date);
CREATE INDEX idx_invoice_created ON invoices(created_at DESC);
CREATE INDEX idx_invoice_type ON invoices(invoice_type);
CREATE INDEX idx_invoice_household_status ON invoices(house_hold_id, status);
CREATE INDEX idx_invoice_type_status ON invoices(invoice_type, status);
CREATE INDEX idx_invoice_confirmed_by ON invoices(confirmed_by);
CREATE UNIQUE INDEX idx_invoice_household_period ON invoices(house_hold_id, period_month, period_year);

-- =============================================
-- INDEXES - INVOICE ITEMS
-- =============================================
CREATE INDEX idx_invoice_item_invoice ON invoice_items(invoice_id);
CREATE INDEX idx_invoice_item_fee_type ON invoice_items(fee_type_id);

-- =============================================
-- INDEXES - PAYMENT HISTORY
-- =============================================
CREATE INDEX idx_payment_invoice ON payment_history(invoice_id);
CREATE INDEX idx_payment_created ON payment_history(created_at DESC);

-- =============================================
-- INDEXES - NOTIFICATIONS
-- =============================================
CREATE INDEX idx_notification_type ON notifications(type);
CREATE INDEX idx_notification_target ON notifications(target, target_id);
CREATE INDEX idx_notification_published ON notifications(published_at DESC);
CREATE INDEX idx_notification_pinned ON notifications(is_pinned) WHERE is_pinned = TRUE;
CREATE INDEX idx_notification_scheduled ON notifications(scheduled_at) WHERE scheduled_at IS NOT NULL;

-- =============================================
-- INDEXES - NOTIFICATION READS
-- =============================================
CREATE UNIQUE INDEX idx_notification_read_unique ON notification_reads(notification_id, user_id);
CREATE INDEX idx_notification_read_user ON notification_reads(user_id);

-- =============================================
-- INDEXES - FEEDBACKS
-- =============================================
CREATE INDEX idx_feedback_user ON feedbacks(user_id);
CREATE INDEX idx_feedback_household ON feedbacks(house_hold_id);
CREATE INDEX idx_feedback_type ON feedbacks(type);
CREATE INDEX idx_feedback_status ON feedbacks(status);
CREATE INDEX idx_feedback_priority ON feedbacks(priority);
CREATE INDEX idx_feedback_created ON feedbacks(created_at DESC);
CREATE INDEX idx_feedback_status_priority ON feedbacks(status, priority);

-- =============================================
-- INDEXES - FEEDBACK COMMENTS
-- =============================================
CREATE INDEX idx_feedback_comment_feedback ON feedback_comments(feedback_id);
CREATE INDEX idx_feedback_comment_created ON feedback_comments(created_at DESC);

SELECT 'All constraints and indexes created successfully!' AS message;
