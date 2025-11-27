-- =============================================
-- 01_extensions_and_types.sql - Extensions & ENUM Types
-- Run this file first after dropping all objects
-- =============================================

-- =============================================
-- EXTENSION
-- =============================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================
-- USER & AUTH ENUMS
-- =============================================
CREATE TYPE user_role AS ENUM ('admin', 'manager', 'resident', 'accountant');
CREATE TYPE user_status AS ENUM ('active', 'pending', 'rejected');

-- =============================================
-- RESIDENT & HOUSEHOLD ENUMS
-- =============================================
CREATE TYPE gender AS ENUM ('male', 'female', 'other');
CREATE TYPE room_type AS ENUM ('single', 'double', 'studio', 'penthouse');
CREATE TYPE house_role AS ENUM ('chuho', 'nguoidaidien', 'nguoithue', 'thanhvien');
CREATE TYPE resident_status AS ENUM ('tamtru', 'thuongtru', 'tamvang');

-- =============================================
-- INVOICE & PAYMENT ENUMS
-- =============================================
CREATE TYPE invoice_type AS ENUM ('rent', 'electricity', 'water', 'maintenance', 'parking', 'service', 'other');
CREATE TYPE fee_category AS ENUM ('fixed', 'variable');
CREATE TYPE fee_status AS ENUM ('pending', 'paid', 'overdue', 'cancelled');
CREATE TYPE payment_method AS ENUM ('cash', 'bank_transfer', 'momo', 'vnpay', 'zalopay');

-- =============================================
-- NOTIFICATION ENUMS
-- =============================================
CREATE TYPE notification_type AS ENUM ('info', 'warning', 'success', 'urgent');
CREATE TYPE notification_target AS ENUM ('all', 'household', 'individual');

-- =============================================
-- FEEDBACK ENUMS
-- =============================================
CREATE TYPE feedback_type AS ENUM ('complaint', 'suggestion', 'maintenance', 'other');
CREATE TYPE feedback_status AS ENUM ('pending', 'in_progress', 'resolved', 'rejected');
CREATE TYPE feedback_priority AS ENUM ('low', 'medium', 'high', 'urgent');

-- =============================================
-- COMMENTS
-- =============================================
COMMENT ON TYPE user_role IS 'Vai trò người dùng: admin, manager, resident, accountant';
COMMENT ON TYPE user_status IS 'Trạng thái tài khoản: active, pending, rejected';
COMMENT ON TYPE gender IS 'Giới tính: male, female, other';
COMMENT ON TYPE room_type IS 'Loại phòng: single, double, studio, penthouse';
COMMENT ON TYPE house_role IS 'Vai trò trong hộ: chủ hộ, người đại diện, người thuê, thành viên';
COMMENT ON TYPE resident_status IS 'Trạng thái cư trú: tạm trú, thường trú, tạm vắng';
COMMENT ON TYPE invoice_type IS 'Loại hóa đơn: rent, electricity, water, maintenance, parking, service, other';
COMMENT ON TYPE fee_category IS 'Loại phí: cố định (fixed), phát sinh (variable)';
COMMENT ON TYPE fee_status IS 'Trạng thái hóa đơn: pending, paid, overdue, cancelled';
COMMENT ON TYPE payment_method IS 'Phương thức thanh toán: cash, bank_transfer, momo, vnpay, zalopay';
COMMENT ON TYPE notification_type IS 'Loại thông báo: info, warning, success, urgent';
COMMENT ON TYPE notification_target IS 'Đối tượng thông báo: all, household, individual';
COMMENT ON TYPE feedback_type IS 'Loại phản hồi: complaint, suggestion, maintenance, other';
COMMENT ON TYPE feedback_status IS 'Trạng thái xử lý: pending, in_progress, resolved, rejected';
COMMENT ON TYPE feedback_priority IS 'Độ ưu tiên: low, medium, high, urgent';

SELECT 'Extensions and types created successfully!' AS message;
