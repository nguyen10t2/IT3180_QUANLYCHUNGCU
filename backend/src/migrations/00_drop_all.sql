-- =============================================
-- 00_drop_all.sql - Drop all database objects
-- Run this file to reset the database completely
-- WARNING: This will delete ALL data!
-- =============================================

-- =============================================
-- DROP VIEWS
-- =============================================
DROP VIEW IF EXISTS dashboard_stats CASCADE;
DROP VIEW IF EXISTS invoice_summary_by_type CASCADE;
DROP VIEW IF EXISTS household_details CASCADE;

-- =============================================
-- DROP FUNCTIONS
-- =============================================
DROP FUNCTION IF EXISTS get_user_details(UUID) CASCADE;
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;
DROP FUNCTION IF EXISTS update_members_count() CASCADE;
DROP FUNCTION IF EXISTS update_invoice_total() CASCADE;

-- =============================================
-- DROP TABLES (theo thứ tự phụ thuộc)
-- =============================================
-- Bảng con trước
DROP TABLE IF EXISTS feedback_comments CASCADE;
DROP TABLE IF EXISTS feedbacks CASCADE;
DROP TABLE IF EXISTS notification_reads CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS payment_history CASCADE;
DROP TABLE IF EXISTS invoice_items CASCADE;
DROP TABLE IF EXISTS invoices CASCADE;
DROP TABLE IF EXISTS fee_types CASCADE;
DROP TABLE IF EXISTS reset_tokens CASCADE;
DROP TABLE IF EXISTS otp_tokens CASCADE;
DROP TABLE IF EXISTS sessions CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS residents CASCADE;
DROP TABLE IF EXISTS house_holds CASCADE;

-- =============================================
-- DROP ENUM TYPES
-- =============================================
DROP TYPE IF EXISTS invoice_type CASCADE;
DROP TYPE IF EXISTS feedback_priority CASCADE;
DROP TYPE IF EXISTS feedback_status CASCADE;
DROP TYPE IF EXISTS feedback_type CASCADE;
DROP TYPE IF EXISTS notification_target CASCADE;
DROP TYPE IF EXISTS notification_type CASCADE;
DROP TYPE IF EXISTS payment_method CASCADE;
DROP TYPE IF EXISTS fee_status CASCADE;
DROP TYPE IF EXISTS fee_category CASCADE;
DROP TYPE IF EXISTS resident_status CASCADE;
DROP TYPE IF EXISTS house_role CASCADE;
DROP TYPE IF EXISTS room_type CASCADE;
DROP TYPE IF EXISTS gender CASCADE;
DROP TYPE IF EXISTS user_status CASCADE;
DROP TYPE IF EXISTS user_role CASCADE;

-- =============================================
-- DROP EXTENSION
-- =============================================
-- DROP EXTENSION IF EXISTS "uuid-ossp"; -- Uncomment nếu muốn xóa extension

SELECT 'All database objects dropped successfully!' AS message;
