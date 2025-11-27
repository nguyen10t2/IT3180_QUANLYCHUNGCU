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
-- =============================================
-- 02_tables.sql - Create all tables
-- Run this file after 01_extensions_and_types.sql
-- =============================================

-- =============================================
-- HOUSEHOLDS TABLE (Hộ gia đình)
-- =============================================
CREATE TABLE house_holds (
    house_hold_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    room_number VARCHAR(50) UNIQUE NOT NULL,
    room_type room_type NOT NULL,
    area DECIMAL(10, 2),
    floor INT,
    members_count INT DEFAULT 0,
    house_hold_head VARCHAR(100) NOT NULL,
    head_resident_id UUID,
    has_vehicle BOOLEAN DEFAULT FALSE,
    vehicle_count INT DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

COMMENT ON TABLE house_holds IS 'Bảng hộ gia đình';
COMMENT ON COLUMN house_holds.room_number IS 'Số phòng (unique)';
COMMENT ON COLUMN house_holds.area IS 'Diện tích (m2)';
COMMENT ON COLUMN house_holds.members_count IS 'Số thành viên (auto-calculated)';
COMMENT ON COLUMN house_holds.house_hold_head IS 'Tên chủ hộ (legacy)';
COMMENT ON COLUMN house_holds.head_resident_id IS 'UUID chủ hộ - FK tới residents';

-- =============================================
-- RESIDENTS TABLE (Cư dân)
-- =============================================
CREATE TABLE residents (
    resident_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    house_id UUID,
    fullname VARCHAR(100) NOT NULL,
    id_card VARCHAR(20) UNIQUE,
    date_of_birth DATE NOT NULL,
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    gender gender NOT NULL,
    role house_role NOT NULL,
    status resident_status NOT NULL,
    occupation VARCHAR(100),
    registration_date TIMESTAMP DEFAULT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

COMMENT ON TABLE residents IS 'Bảng cư dân';
COMMENT ON COLUMN residents.id_card IS 'CCCD/CMND';
COMMENT ON COLUMN residents.occupation IS 'Nghề nghiệp';
COMMENT ON COLUMN residents.registration_date IS 'Ngày đăng ký tạm trú/thường trú';

-- =============================================
-- USERS TABLE (Tài khoản)
-- =============================================
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    fullname VARCHAR(100) NOT NULL,
    avatar_url TEXT,
    role user_role DEFAULT 'resident',
    status user_status DEFAULT 'pending',
    verified BOOLEAN DEFAULT FALSE,
    resident_id UUID,
    rejected_reason TEXT,
    approved_by UUID,
    approved_at TIMESTAMP,
    last_login_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

COMMENT ON TABLE users IS 'Bảng tài khoản người dùng';
COMMENT ON COLUMN users.rejected_reason IS 'Lý do từ chối (nếu status = rejected)';
COMMENT ON COLUMN users.approved_by IS 'Người phê duyệt';
COMMENT ON COLUMN users.approved_at IS 'Thời gian phê duyệt';

-- =============================================
-- SESSIONS TABLE (Phiên đăng nhập)
-- =============================================
CREATE TABLE sessions (
    session_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    refresh_token TEXT UNIQUE NOT NULL,
    user_agent TEXT,
    ip_address VARCHAR(45),
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

COMMENT ON TABLE sessions IS 'Bảng phiên đăng nhập';

-- =============================================
-- OTP TOKENS TABLE (Mã OTP)
-- =============================================
CREATE TABLE otp_tokens (
    otp_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(100) NOT NULL,
    otp VARCHAR(255) NOT NULL,
    purpose VARCHAR(50) DEFAULT 'verification',
    attempts INT DEFAULT 0,
    max_attempts INT DEFAULT 5,
    expires_at TIMESTAMP NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

COMMENT ON TABLE otp_tokens IS 'Bảng mã OTP xác thực';
COMMENT ON COLUMN otp_tokens.otp IS 'Mã OTP đã hash (argon2)';
COMMENT ON COLUMN otp_tokens.purpose IS 'Mục đích: verification, reset_password';

-- =============================================
-- RESET TOKENS TABLE (Token đặt lại mật khẩu)
-- =============================================
CREATE TABLE reset_tokens (
    reset_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(100) NOT NULL,
    reset_token TEXT UNIQUE NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW()
);

COMMENT ON TABLE reset_tokens IS 'Bảng token đặt lại mật khẩu';

-- =============================================
-- FEE TYPES TABLE (Loại phí)
-- =============================================
CREATE TABLE fee_types (
    fee_type_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    category fee_category NOT NULL,
    unit_price DECIMAL(15, 2) DEFAULT 0,
    unit VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

COMMENT ON TABLE fee_types IS 'Bảng loại phí';
COMMENT ON COLUMN fee_types.unit_price IS 'Đơn giá (VNĐ)';
COMMENT ON COLUMN fee_types.unit IS 'Đơn vị: m2, kWh, m3, xe/tháng...';

-- =============================================
-- INVOICES TABLE (Hóa đơn)
-- =============================================
CREATE TABLE invoices (
    invoice_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    house_hold_id UUID NOT NULL,
    period_month INT NOT NULL,
    period_year INT NOT NULL,
    invoice_type invoice_type DEFAULT 'other',
    total_amount DECIMAL(15, 2) DEFAULT 0,
    status fee_status DEFAULT 'pending',
    due_date DATE NOT NULL,
    paid_at TIMESTAMP,
    payment_method payment_method,
    notes TEXT,
    created_by UUID,
    confirmed_by UUID,
    confirmed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

COMMENT ON TABLE invoices IS 'Bảng hóa đơn';
COMMENT ON COLUMN invoices.invoice_number IS 'Số hóa đơn (VD: HD-2025-11-001)';
COMMENT ON COLUMN invoices.period_month IS 'Kỳ thanh toán - tháng';
COMMENT ON COLUMN invoices.period_year IS 'Kỳ thanh toán - năm';
COMMENT ON COLUMN invoices.invoice_type IS 'Loại hóa đơn: rent, electricity, water...';
COMMENT ON COLUMN invoices.confirmed_by IS 'Người xác nhận thanh toán';

-- =============================================
-- INVOICE ITEMS TABLE (Chi tiết hóa đơn)
-- =============================================
CREATE TABLE invoice_items (
    item_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_id UUID NOT NULL,
    fee_type_id UUID,
    description VARCHAR(255),
    quantity DECIMAL(10, 2) DEFAULT 1,
    unit_price DECIMAL(15, 2) NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    previous_reading DECIMAL(15, 2),
    current_reading DECIMAL(15, 2),
    created_at TIMESTAMP DEFAULT NOW()
);

COMMENT ON TABLE invoice_items IS 'Bảng chi tiết hóa đơn';
COMMENT ON COLUMN invoice_items.quantity IS 'Số lượng (m2, kWh, số xe...)';
COMMENT ON COLUMN invoice_items.amount IS 'Thành tiền = quantity * unit_price';
COMMENT ON COLUMN invoice_items.previous_reading IS 'Chỉ số cũ (điện/nước)';
COMMENT ON COLUMN invoice_items.current_reading IS 'Chỉ số mới (điện/nước)';

-- =============================================
-- PAYMENT HISTORY TABLE (Lịch sử thanh toán)
-- =============================================
CREATE TABLE payment_history (
    payment_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_id UUID NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    payment_method payment_method NOT NULL,
    transaction_id VARCHAR(100),
    paid_by UUID,
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

COMMENT ON TABLE payment_history IS 'Bảng lịch sử thanh toán';
COMMENT ON COLUMN payment_history.transaction_id IS 'Mã giao dịch từ cổng thanh toán';

-- =============================================
-- NOTIFICATIONS TABLE (Thông báo)
-- =============================================
CREATE TABLE notifications (
    notification_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    type notification_type DEFAULT 'info',
    target notification_target DEFAULT 'all',
    target_id UUID,
    is_pinned BOOLEAN DEFAULT FALSE,
    scheduled_at TIMESTAMP,
    published_at TIMESTAMP DEFAULT NOW(),
    expires_at TIMESTAMP,
    created_by UUID,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

COMMENT ON TABLE notifications IS 'Bảng thông báo';
COMMENT ON COLUMN notifications.target_id IS 'house_hold_id hoặc user_id nếu target != all';
COMMENT ON COLUMN notifications.is_pinned IS 'Ghim thông báo';
COMMENT ON COLUMN notifications.scheduled_at IS 'Thời gian lên lịch gửi';

-- =============================================
-- NOTIFICATION READS TABLE (Đã đọc thông báo)
-- =============================================
CREATE TABLE notification_reads (
    read_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    notification_id UUID NOT NULL,
    user_id UUID NOT NULL,
    read_at TIMESTAMP DEFAULT NOW()
);

COMMENT ON TABLE notification_reads IS 'Bảng theo dõi đã đọc thông báo';

-- =============================================
-- FEEDBACKS TABLE (Phản hồi/Góp ý)
-- =============================================
CREATE TABLE feedbacks (
    feedback_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID,
    house_hold_id UUID,
    type feedback_type NOT NULL,
    priority feedback_priority DEFAULT 'medium',
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    attachments TEXT[],
    status feedback_status DEFAULT 'pending',
    assigned_to UUID,
    resolved_at TIMESTAMP,
    resolution_notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

COMMENT ON TABLE feedbacks IS 'Bảng phản hồi/góp ý';
COMMENT ON COLUMN feedbacks.attachments IS 'Mảng URL file đính kèm';
COMMENT ON COLUMN feedbacks.assigned_to IS 'Nhân viên được giao xử lý';
COMMENT ON COLUMN feedbacks.resolution_notes IS 'Ghi chú xử lý';

-- =============================================
-- FEEDBACK COMMENTS TABLE (Bình luận phản hồi)
-- =============================================
CREATE TABLE feedback_comments (
    comment_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    feedback_id UUID NOT NULL,
    user_id UUID,
    content TEXT NOT NULL,
    is_internal BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW()
);

COMMENT ON TABLE feedback_comments IS 'Bảng bình luận phản hồi';
COMMENT ON COLUMN feedback_comments.is_internal IS 'Ghi chú nội bộ (chỉ staff thấy)';

SELECT 'All tables created successfully!' AS message;
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
-- =============================================
-- 04_triggers_and_functions.sql - Triggers & Functions
-- Run this file after 03_constraints_and_indexes.sql
-- =============================================

-- =============================================
-- FUNCTION: Auto update updated_at column
-- =============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_updated_at_column() IS 'Tự động cập nhật cột updated_at khi UPDATE';

-- =============================================
-- TRIGGERS: Auto update updated_at for all tables
-- =============================================
CREATE TRIGGER update_house_holds_updated_at 
    BEFORE UPDATE ON house_holds
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_residents_updated_at 
    BEFORE UPDATE ON residents
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_sessions_updated_at 
    BEFORE UPDATE ON sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_otp_tokens_updated_at 
    BEFORE UPDATE ON otp_tokens
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_fee_types_updated_at 
    BEFORE UPDATE ON fee_types
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_invoices_updated_at 
    BEFORE UPDATE ON invoices
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notifications_updated_at 
    BEFORE UPDATE ON notifications
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_feedbacks_updated_at 
    BEFORE UPDATE ON feedbacks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================
-- FUNCTION: Auto update members_count in house_holds
-- =============================================
CREATE OR REPLACE FUNCTION update_members_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        IF NEW.house_id IS NOT NULL THEN
            UPDATE house_holds SET members_count = members_count + 1 WHERE house_hold_id = NEW.house_id;
        END IF;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        IF OLD.house_id IS NOT NULL THEN
            UPDATE house_holds SET members_count = members_count - 1 WHERE house_hold_id = OLD.house_id;
        END IF;
        RETURN OLD;
    ELSIF TG_OP = 'UPDATE' AND OLD.house_id IS DISTINCT FROM NEW.house_id THEN
        IF OLD.house_id IS NOT NULL THEN
            UPDATE house_holds SET members_count = members_count - 1 WHERE house_hold_id = OLD.house_id;
        END IF;
        IF NEW.house_id IS NOT NULL THEN
            UPDATE house_holds SET members_count = members_count + 1 WHERE house_hold_id = NEW.house_id;
        END IF;
        RETURN NEW;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_members_count() IS 'Tự động cập nhật số thành viên trong hộ khi INSERT/UPDATE/DELETE residents';

CREATE TRIGGER update_household_members_count
    AFTER INSERT OR UPDATE OR DELETE ON residents
    FOR EACH ROW EXECUTE FUNCTION update_members_count();

-- =============================================
-- FUNCTION: Auto calculate invoice total from items
-- =============================================
CREATE OR REPLACE FUNCTION update_invoice_total()
RETURNS TRIGGER AS $$
DECLARE
    target_invoice_id UUID;
BEGIN
    IF TG_OP = 'DELETE' THEN
        target_invoice_id := OLD.invoice_id;
    ELSE
        target_invoice_id := NEW.invoice_id;
    END IF;

    UPDATE invoices 
    SET total_amount = (
        SELECT COALESCE(SUM(amount), 0) 
        FROM invoice_items 
        WHERE invoice_id = target_invoice_id
    )
    WHERE invoice_id = target_invoice_id;
    
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_invoice_total() IS 'Tự động tính tổng tiền hóa đơn từ invoice_items';

CREATE TRIGGER update_invoice_total_on_item_change
    AFTER INSERT OR UPDATE OR DELETE ON invoice_items
    FOR EACH ROW EXECUTE FUNCTION update_invoice_total();

-- =============================================
-- FUNCTION: Auto check overdue invoices
-- Có thể chạy định kỳ bằng pg_cron hoặc từ backend
-- =============================================
CREATE OR REPLACE FUNCTION check_overdue_invoices()
RETURNS INTEGER AS $$
DECLARE
    updated_count INTEGER;
BEGIN
    UPDATE invoices 
    SET status = 'overdue'
    WHERE status = 'pending' 
      AND due_date < CURRENT_DATE;
    
    GET DIAGNOSTICS updated_count = ROW_COUNT;
    RETURN updated_count;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION check_overdue_invoices() IS 'Cập nhật trạng thái hóa đơn quá hạn. Trả về số hóa đơn được cập nhật.';

-- =============================================
-- FUNCTION: Get user with full details
-- =============================================
CREATE OR REPLACE FUNCTION get_user_details(p_user_id UUID)
RETURNS TABLE (
    user_id UUID,
    email VARCHAR(100),
    fullname VARCHAR(100),
    avatar_url TEXT,
    role user_role,
    status user_status,
    verified BOOLEAN,
    resident_id UUID,
    resident_fullname VARCHAR(100),
    resident_phone VARCHAR(15),
    resident_id_card VARCHAR(20),
    house_hold_id UUID,
    room_number VARCHAR(50),
    created_at TIMESTAMP,
    last_login_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.user_id,
        u.email,
        u.fullname,
        u.avatar_url,
        u.role,
        u.status,
        u.verified,
        u.resident_id,
        r.fullname as resident_fullname,
        r.phone_number as resident_phone,
        r.id_card as resident_id_card,
        h.house_hold_id,
        h.room_number,
        u.created_at,
        u.last_login_at
    FROM users u
    LEFT JOIN residents r ON u.resident_id = r.resident_id
    LEFT JOIN house_holds h ON r.house_id = h.house_hold_id
    WHERE u.user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_user_details(UUID) IS 'Lấy thông tin user đầy đủ bao gồm resident và household';

-- =============================================
-- FUNCTION: Generate invoice number
-- =============================================
CREATE OR REPLACE FUNCTION generate_invoice_number(p_year INT, p_month INT)
RETURNS VARCHAR(50) AS $$
DECLARE
    next_seq INT;
    invoice_num VARCHAR(50);
BEGIN
    SELECT COALESCE(MAX(
        CAST(SPLIT_PART(invoice_number, '-', 4) AS INT)
    ), 0) + 1
    INTO next_seq
    FROM invoices 
    WHERE period_year = p_year AND period_month = p_month;
    
    invoice_num := 'HD-' || p_year || '-' || LPAD(p_month::TEXT, 2, '0') || '-' || LPAD(next_seq::TEXT, 4, '0');
    RETURN invoice_num;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION generate_invoice_number(INT, INT) IS 'Tạo số hóa đơn tự động theo format HD-YYYY-MM-XXXX';

SELECT 'All triggers and functions created successfully!' AS message;
-- =============================================
-- 05_views.sql - Database Views
-- Run this file after 04_triggers_and_functions.sql
-- =============================================

-- =============================================
-- VIEW: Dashboard statistics
-- =============================================
CREATE OR REPLACE VIEW dashboard_stats AS
SELECT 
    (SELECT COUNT(*) FROM users WHERE status = 'pending' AND resident_id IS NOT NULL) AS pending_users,
    (SELECT COUNT(*) FROM users WHERE status = 'active') AS active_users,
    (SELECT COUNT(*) FROM users WHERE status = 'rejected') AS rejected_users,
    (SELECT COUNT(*) FROM invoices WHERE status = 'pending') AS pending_invoices,
    (SELECT COUNT(*) FROM invoices WHERE status = 'paid') AS paid_invoices,
    (SELECT COUNT(*) FROM invoices WHERE status = 'overdue') AS overdue_invoices,
    (SELECT COALESCE(SUM(total_amount), 0) FROM invoices WHERE status = 'pending') AS pending_amount,
    (SELECT COALESCE(SUM(total_amount), 0) FROM invoices WHERE status = 'paid') AS collected_amount,
    (SELECT COUNT(*) FROM feedbacks WHERE status = 'pending') AS pending_feedbacks,
    (SELECT COUNT(*) FROM feedbacks WHERE status = 'in_progress') AS in_progress_feedbacks,
    (SELECT COUNT(*) FROM feedbacks WHERE status = 'resolved') AS resolved_feedbacks,
    (SELECT COUNT(*) FROM house_holds) AS total_households,
    (SELECT COUNT(*) FROM residents) AS total_residents,
    (SELECT COUNT(*) FROM notifications WHERE published_at >= NOW() - INTERVAL '7 days') AS recent_notifications;

COMMENT ON VIEW dashboard_stats IS 'View thống kê nhanh cho dashboard manager/admin';

-- =============================================
-- VIEW: Invoice summary by type
-- =============================================
CREATE OR REPLACE VIEW invoice_summary_by_type AS
SELECT 
    invoice_type,
    COUNT(*) AS total_count,
    SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) AS pending_count,
    SUM(CASE WHEN status = 'paid' THEN 1 ELSE 0 END) AS paid_count,
    SUM(CASE WHEN status = 'overdue' THEN 1 ELSE 0 END) AS overdue_count,
    COALESCE(SUM(total_amount), 0) AS total_amount,
    COALESCE(SUM(CASE WHEN status = 'paid' THEN total_amount ELSE 0 END), 0) AS paid_amount,
    COALESCE(SUM(CASE WHEN status = 'pending' THEN total_amount ELSE 0 END), 0) AS pending_amount
FROM invoices
GROUP BY invoice_type
ORDER BY total_count DESC;

COMMENT ON VIEW invoice_summary_by_type IS 'View tổng hợp hóa đơn theo loại';

-- =============================================
-- VIEW: Invoice summary by month
-- =============================================
CREATE OR REPLACE VIEW invoice_summary_by_month AS
SELECT 
    period_year,
    period_month,
    COUNT(*) AS total_count,
    SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) AS pending_count,
    SUM(CASE WHEN status = 'paid' THEN 1 ELSE 0 END) AS paid_count,
    SUM(CASE WHEN status = 'overdue' THEN 1 ELSE 0 END) AS overdue_count,
    COALESCE(SUM(total_amount), 0) AS total_amount,
    COALESCE(SUM(CASE WHEN status = 'paid' THEN total_amount ELSE 0 END), 0) AS paid_amount
FROM invoices
GROUP BY period_year, period_month
ORDER BY period_year DESC, period_month DESC;

COMMENT ON VIEW invoice_summary_by_month IS 'View tổng hợp hóa đơn theo tháng';

-- =============================================
-- VIEW: Household details with head resident info
-- =============================================
CREATE OR REPLACE VIEW household_details AS
SELECT 
    h.house_hold_id,
    h.room_number,
    h.room_type,
    h.area,
    h.floor,
    h.members_count,
    h.has_vehicle,
    h.vehicle_count,
    h.notes,
    h.created_at,
    h.updated_at,
    r.resident_id AS head_resident_id,
    r.fullname AS head_fullname,
    r.phone_number AS head_phone,
    r.id_card AS head_id_card,
    r.gender AS head_gender,
    (
        SELECT COALESCE(SUM(i.total_amount), 0) 
        FROM invoices i 
        WHERE i.house_hold_id = h.house_hold_id AND i.status = 'pending'
    ) AS pending_amount,
    (
        SELECT COUNT(*) 
        FROM invoices i 
        WHERE i.house_hold_id = h.house_hold_id AND i.status = 'overdue'
    ) AS overdue_count
FROM house_holds h
LEFT JOIN residents r ON h.head_resident_id = r.resident_id;

COMMENT ON VIEW household_details IS 'View thông tin hộ gia đình với thông tin chủ hộ và công nợ';

-- =============================================
-- VIEW: User details with resident info
-- =============================================
CREATE OR REPLACE VIEW user_details AS
SELECT 
    u.user_id,
    u.email,
    u.fullname,
    u.avatar_url,
    u.role,
    u.status,
    u.verified,
    u.last_login_at,
    u.created_at,
    r.resident_id,
    r.fullname AS resident_fullname,
    r.phone_number AS resident_phone,
    r.id_card AS resident_id_card,
    r.gender AS resident_gender,
    r.date_of_birth AS resident_dob,
    r.occupation AS resident_occupation,
    h.house_hold_id,
    h.room_number,
    h.room_type,
    h.floor,
    approver.fullname AS approved_by_name,
    u.approved_at
FROM users u
LEFT JOIN residents r ON u.resident_id = r.resident_id
LEFT JOIN house_holds h ON r.house_id = h.house_hold_id
LEFT JOIN users approver ON u.approved_by = approver.user_id;

COMMENT ON VIEW user_details IS 'View thông tin user đầy đủ với resident và household';

-- =============================================
-- VIEW: Resident details with household info
-- =============================================
CREATE OR REPLACE VIEW resident_details AS
SELECT 
    r.resident_id,
    r.fullname,
    r.id_card,
    r.date_of_birth,
    r.phone_number,
    r.gender,
    r.role,
    r.status,
    r.occupation,
    r.registration_date,
    r.created_at,
    h.house_hold_id,
    h.room_number,
    h.room_type,
    h.floor,
    u.user_id,
    u.email,
    u.status AS user_status
FROM residents r
LEFT JOIN house_holds h ON r.house_id = h.house_hold_id
LEFT JOIN users u ON u.resident_id = r.resident_id;

COMMENT ON VIEW resident_details IS 'View thông tin cư dân với household và user account';

-- =============================================
-- VIEW: Feedback summary
-- =============================================
CREATE OR REPLACE VIEW feedback_summary AS
SELECT 
    f.feedback_id,
    f.title,
    f.type,
    f.priority,
    f.status,
    f.created_at,
    f.resolved_at,
    u.fullname AS submitted_by,
    u.email AS submitted_by_email,
    h.room_number,
    assignee.fullname AS assigned_to_name,
    EXTRACT(DAY FROM (COALESCE(f.resolved_at, NOW()) - f.created_at)) AS days_open
FROM feedbacks f
LEFT JOIN users u ON f.user_id = u.user_id
LEFT JOIN house_holds h ON f.house_hold_id = h.house_hold_id
LEFT JOIN users assignee ON f.assigned_to = assignee.user_id
ORDER BY 
    CASE f.status 
        WHEN 'pending' THEN 1 
        WHEN 'in_progress' THEN 2 
        ELSE 3 
    END,
    CASE f.priority 
        WHEN 'urgent' THEN 1 
        WHEN 'high' THEN 2 
        WHEN 'medium' THEN 3 
        ELSE 4 
    END,
    f.created_at DESC;

COMMENT ON VIEW feedback_summary IS 'View tổng hợp phản hồi với thông tin người gửi và người xử lý';

-- =============================================
-- VIEW: Active sessions
-- =============================================
CREATE OR REPLACE VIEW active_sessions AS
SELECT 
    s.session_id,
    s.user_id,
    u.email,
    u.fullname,
    u.role,
    s.user_agent,
    s.ip_address,
    s.created_at AS login_at,
    s.expires_at,
    (s.expires_at > NOW()) AS is_valid
FROM sessions s
JOIN users u ON s.user_id = u.user_id
WHERE s.expires_at > NOW()
ORDER BY s.created_at DESC;

COMMENT ON VIEW active_sessions IS 'View các phiên đăng nhập đang hoạt động';

SELECT 'All views created successfully!' AS message;
-- =============================================
-- 06_seed_default_data.sql - Default system data
-- Run this file after 05_views.sql
-- This contains default data needed for the system to work
-- =============================================

-- =============================================
-- DEFAULT FEE TYPES (Loại phí mặc định)
-- =============================================
INSERT INTO fee_types (name, description, category, unit_price, unit) VALUES
    ('Phí quản lý', 'Phí quản lý chung cư hàng tháng', 'fixed', 7000, 'm2'),
    ('Phí gửi xe máy', 'Phí gửi xe máy hàng tháng', 'fixed', 100000, 'xe/tháng'),
    ('Phí gửi ô tô', 'Phí gửi ô tô hàng tháng', 'fixed', 1500000, 'xe/tháng'),
    ('Phí gửi xe đạp', 'Phí gửi xe đạp hàng tháng', 'fixed', 30000, 'xe/tháng'),
    ('Phí điện', 'Phí điện sinh hoạt', 'variable', 3500, 'kWh'),
    ('Phí nước', 'Phí nước sinh hoạt', 'variable', 15000, 'm3'),
    ('Phí internet', 'Phí internet chung cư', 'fixed', 200000, 'tháng'),
    ('Phí dọn vệ sinh', 'Phí dọn vệ sinh định kỳ', 'fixed', 100000, 'tháng'),
    ('Phí bảo trì', 'Phí bảo trì thiết bị', 'variable', 0, 'lần'),
    ('Phí dịch vụ khác', 'Phí dịch vụ phát sinh khác', 'variable', 0, 'lần')
ON CONFLICT DO NOTHING;

SELECT 'Default data seeded successfully!' AS message;
-- =============================================
-- 07_seed_test_data.sql - Test/Demo data
-- Run this file ONLY for development/testing
-- DO NOT run in production!
-- =============================================

-- =============================================
-- 1. TÀI KHOẢN ADMIN & MANAGER
-- Password mặc định: Test@123 (cần hash lại bằng argon2)
-- =============================================
INSERT INTO users (user_id, email, password_hash, fullname, role, status, verified)
VALUES 
    ('a0000000-0000-0000-0000-000000000001', 'admin@kogu.vn', '$argon2id$v=19$m=65536,t=3,p=4$salt$hash', 'Admin Kogu', 'admin', 'active', TRUE),
    ('a0000000-0000-0000-0000-000000000002', 'manager@kogu.vn', '$argon2id$v=19$m=65536,t=3,p=4$salt$hash', 'Quản Lý Kogu', 'manager', 'active', TRUE),
    ('a0000000-0000-0000-0000-000000000003', 'accountant@kogu.vn', '$argon2id$v=19$m=65536,t=3,p=4$salt$hash', 'Kế Toán Kogu', 'accountant', 'active', TRUE)
ON CONFLICT (email) DO NOTHING;

-- =============================================
-- 2. HỘ GIA ĐÌNH MẪU
-- =============================================
INSERT INTO house_holds (house_hold_id, room_number, room_type, area, floor, house_hold_head, has_vehicle, vehicle_count, notes)
VALUES 
    ('b0000000-0000-0000-0000-000000000001', 'A101', 'double', 75.5, 1, 'Nguyễn Văn An', TRUE, 2, 'Căn góc, view đẹp'),
    ('b0000000-0000-0000-0000-000000000002', 'A102', 'single', 55.0, 1, 'Trần Thị Bình', TRUE, 1, NULL),
    ('b0000000-0000-0000-0000-000000000003', 'A201', 'studio', 45.0, 2, 'Lê Văn Cường', FALSE, 0, 'Studio view công viên'),
    ('b0000000-0000-0000-0000-000000000004', 'A202', 'double', 80.0, 2, 'Phạm Thị Dung', TRUE, 1, NULL),
    ('b0000000-0000-0000-0000-000000000005', 'A301', 'double', 78.0, 3, 'Võ Văn Hoàng', TRUE, 2, NULL),
    ('b0000000-0000-0000-0000-000000000006', 'A302', 'single', 52.0, 3, 'Đặng Thị Lan', FALSE, 0, NULL),
    ('b0000000-0000-0000-0000-000000000007', 'B101', 'penthouse', 150.0, 10, 'Hoàng Văn Em', TRUE, 3, 'Penthouse tầng thượng'),
    ('b0000000-0000-0000-0000-000000000008', 'B102', 'double', 85.0, 10, 'Ngô Thị Hương', TRUE, 1, NULL)
ON CONFLICT (room_number) DO NOTHING;

-- =============================================
-- 3. CƯ DÂN MẪU
-- =============================================
INSERT INTO residents (resident_id, house_id, fullname, id_card, date_of_birth, phone_number, gender, role, status, occupation)
VALUES
    -- Hộ A101 (2 người)
    ('c0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000001', 'Nguyễn Văn An', '001234567890', '1985-03-15', '0901234501', 'male', 'chuho', 'thuongtru', 'Kỹ sư phần mềm'),
    ('c0000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000001', 'Nguyễn Thị Mai', '001234567891', '1987-06-20', '0901234502', 'female', 'thanhvien', 'thuongtru', 'Giáo viên'),
    
    -- Hộ A102 (1 người)
    ('c0000000-0000-0000-0000-000000000003', 'b0000000-0000-0000-0000-000000000002', 'Trần Thị Bình', '001234567892', '1990-01-10', '0901234503', 'female', 'chuho', 'thuongtru', 'Bác sĩ'),
    
    -- Hộ A201 (1 người - thuê)
    ('c0000000-0000-0000-0000-000000000004', 'b0000000-0000-0000-0000-000000000003', 'Lê Văn Cường', '001234567893', '1995-08-25', '0901234504', 'male', 'nguoithue', 'tamtru', 'Nhân viên văn phòng'),
    
    -- Hộ A202 (2 người)
    ('c0000000-0000-0000-0000-000000000005', 'b0000000-0000-0000-0000-000000000004', 'Phạm Thị Dung', '001234567894', '1988-12-05', '0901234505', 'female', 'chuho', 'thuongtru', 'Doanh nhân'),
    ('c0000000-0000-0000-0000-000000000006', 'b0000000-0000-0000-0000-000000000004', 'Phạm Văn Dũng', '001234567895', '1986-04-18', '0901234506', 'male', 'thanhvien', 'thuongtru', 'Kế toán'),
    
    -- Hộ A301 (3 người)
    ('c0000000-0000-0000-0000-000000000007', 'b0000000-0000-0000-0000-000000000005', 'Võ Văn Hoàng', '001234567896', '1982-11-30', '0901234507', 'male', 'chuho', 'thuongtru', 'Giám đốc'),
    ('c0000000-0000-0000-0000-000000000008', 'b0000000-0000-0000-0000-000000000005', 'Võ Thị Hạnh', '001234567897', '1984-07-22', '0901234508', 'female', 'thanhvien', 'thuongtru', 'Nội trợ'),
    ('c0000000-0000-0000-0000-000000000009', 'b0000000-0000-0000-0000-000000000005', 'Võ Minh Khang', '001234567898', '2010-02-14', '0901234509', 'male', 'thanhvien', 'thuongtru', 'Học sinh'),
    
    -- Hộ A302 (1 người)
    ('c0000000-0000-0000-0000-000000000010', 'b0000000-0000-0000-0000-000000000006', 'Đặng Thị Lan', '001234567899', '1992-09-08', '0901234510', 'female', 'nguoithue', 'tamtru', 'Nhân viên ngân hàng'),
    
    -- Hộ B101 (2 người)
    ('c0000000-0000-0000-0000-000000000011', 'b0000000-0000-0000-0000-000000000007', 'Hoàng Văn Em', '001234567900', '1975-09-30', '0901234511', 'male', 'chuho', 'thuongtru', 'Giám đốc công ty'),
    ('c0000000-0000-0000-0000-000000000012', 'b0000000-0000-0000-0000-000000000007', 'Hoàng Thị Nga', '001234567901', '1978-03-12', '0901234512', 'female', 'thanhvien', 'thuongtru', 'Doanh nhân'),
    
    -- Hộ B102 (1 người)
    ('c0000000-0000-0000-0000-000000000013', 'b0000000-0000-0000-0000-000000000008', 'Ngô Thị Hương', '001234567902', '1989-05-17', '0901234513', 'female', 'chuho', 'thuongtru', 'Bác sĩ')
ON CONFLICT (phone_number) DO NOTHING;

-- Cập nhật head_resident_id cho households
UPDATE house_holds SET head_resident_id = 'c0000000-0000-0000-0000-000000000001' WHERE house_hold_id = 'b0000000-0000-0000-0000-000000000001';
UPDATE house_holds SET head_resident_id = 'c0000000-0000-0000-0000-000000000003' WHERE house_hold_id = 'b0000000-0000-0000-0000-000000000002';
UPDATE house_holds SET head_resident_id = 'c0000000-0000-0000-0000-000000000004' WHERE house_hold_id = 'b0000000-0000-0000-0000-000000000003';
UPDATE house_holds SET head_resident_id = 'c0000000-0000-0000-0000-000000000005' WHERE house_hold_id = 'b0000000-0000-0000-0000-000000000004';
UPDATE house_holds SET head_resident_id = 'c0000000-0000-0000-0000-000000000007' WHERE house_hold_id = 'b0000000-0000-0000-0000-000000000005';
UPDATE house_holds SET head_resident_id = 'c0000000-0000-0000-0000-000000000010' WHERE house_hold_id = 'b0000000-0000-0000-0000-000000000006';
UPDATE house_holds SET head_resident_id = 'c0000000-0000-0000-0000-000000000011' WHERE house_hold_id = 'b0000000-0000-0000-0000-000000000007';
UPDATE house_holds SET head_resident_id = 'c0000000-0000-0000-0000-000000000013' WHERE house_hold_id = 'b0000000-0000-0000-0000-000000000008';

-- =============================================
-- 4. USER TÀI KHOẢN CƯ DÂN (có liên kết resident)
-- =============================================
INSERT INTO users (user_id, email, password_hash, fullname, role, status, verified, resident_id)
VALUES 
    ('d0000000-0000-0000-0000-000000000001', 'nguyenvanan@gmail.com', '$argon2id$v=19$m=65536,t=3,p=4$salt$hash', 'Nguyễn Văn An', 'resident', 'active', TRUE, 'c0000000-0000-0000-0000-000000000001'),
    ('d0000000-0000-0000-0000-000000000002', 'tranthibinh@gmail.com', '$argon2id$v=19$m=65536,t=3,p=4$salt$hash', 'Trần Thị Bình', 'resident', 'active', TRUE, 'c0000000-0000-0000-0000-000000000003'),
    ('d0000000-0000-0000-0000-000000000003', 'levancuong@gmail.com', '$argon2id$v=19$m=65536,t=3,p=4$salt$hash', 'Lê Văn Cường', 'resident', 'active', TRUE, 'c0000000-0000-0000-0000-000000000004')
ON CONFLICT (email) DO NOTHING;

-- =============================================
-- 5. USER PENDING (chờ duyệt - có resident)
-- =============================================
INSERT INTO users (user_id, email, password_hash, fullname, role, status, verified, resident_id)
VALUES 
    ('d0000000-0000-0000-0000-000000000004', 'pending1@test.com', '$argon2id$v=19$m=65536,t=3,p=4$salt$hash', 'Phạm Thị Dung', 'resident', 'pending', TRUE, 'c0000000-0000-0000-0000-000000000005'),
    ('d0000000-0000-0000-0000-000000000005', 'pending2@test.com', '$argon2id$v=19$m=65536,t=3,p=4$salt$hash', 'Võ Văn Hoàng', 'resident', 'pending', TRUE, 'c0000000-0000-0000-0000-000000000007'),
    ('d0000000-0000-0000-0000-000000000006', 'pending3@test.com', '$argon2id$v=19$m=65536,t=3,p=4$salt$hash', 'Hoàng Văn Em', 'resident', 'pending', TRUE, 'c0000000-0000-0000-0000-000000000011')
ON CONFLICT (email) DO NOTHING;

-- =============================================
-- 6. HÓA ĐƠN MẪU
-- =============================================
INSERT INTO invoices (invoice_id, invoice_number, house_hold_id, period_month, period_year, invoice_type, total_amount, status, due_date, notes, created_by)
VALUES
    -- Tháng 11/2025
    ('e0000000-0000-0000-0000-000000000001', 'HD-2025-11-0001', 'b0000000-0000-0000-0000-000000000001', 11, 2025, 'rent', 8000000, 'pending', '2025-12-15', 'Tiền thuê tháng 11', 'a0000000-0000-0000-0000-000000000002'),
    ('e0000000-0000-0000-0000-000000000002', 'HD-2025-11-0002', 'b0000000-0000-0000-0000-000000000001', 11, 2025, 'electricity', 850000, 'pending', '2025-12-15', 'Điện tháng 11 - 243kWh', 'a0000000-0000-0000-0000-000000000002'),
    ('e0000000-0000-0000-0000-000000000003', 'HD-2025-11-0003', 'b0000000-0000-0000-0000-000000000001', 11, 2025, 'water', 180000, 'paid', '2025-12-15', 'Nước tháng 11 - 12m3', 'a0000000-0000-0000-0000-000000000002'),
    ('e0000000-0000-0000-0000-000000000004', 'HD-2025-11-0004', 'b0000000-0000-0000-0000-000000000002', 11, 2025, 'rent', 5500000, 'pending', '2025-12-15', 'Tiền thuê tháng 11', 'a0000000-0000-0000-0000-000000000002'),
    ('e0000000-0000-0000-0000-000000000005', 'HD-2025-11-0005', 'b0000000-0000-0000-0000-000000000003', 11, 2025, 'rent', 4500000, 'paid', '2025-12-15', 'Tiền thuê tháng 11', 'a0000000-0000-0000-0000-000000000002'),
    ('e0000000-0000-0000-0000-000000000006', 'HD-2025-11-0006', 'b0000000-0000-0000-0000-000000000004', 11, 2025, 'electricity', 1200000, 'pending', '2025-12-15', 'Điện tháng 11 - 343kWh', 'a0000000-0000-0000-0000-000000000002'),
    
    -- Tháng 10/2025 (quá hạn)
    ('e0000000-0000-0000-0000-000000000007', 'HD-2025-10-0001', 'b0000000-0000-0000-0000-000000000004', 10, 2025, 'rent', 8000000, 'overdue', '2025-11-15', 'Tiền thuê tháng 10 - QUÁ HẠN', 'a0000000-0000-0000-0000-000000000002'),
    ('e0000000-0000-0000-0000-000000000008', 'HD-2025-10-0002', 'b0000000-0000-0000-0000-000000000005', 10, 2025, 'maintenance', 500000, 'overdue', '2025-11-15', 'Phí bảo trì điều hòa - QUÁ HẠN', 'a0000000-0000-0000-0000-000000000002'),
    
    -- Parking
    ('e0000000-0000-0000-0000-000000000009', 'HD-2025-11-0007', 'b0000000-0000-0000-0000-000000000007', 11, 2025, 'parking', 1700000, 'paid', '2025-12-15', 'Phí gửi xe tháng 11 (1 ô tô + 2 xe máy)', 'a0000000-0000-0000-0000-000000000002')
ON CONFLICT (invoice_number) DO NOTHING;

-- =============================================
-- 7. THÔNG BÁO MẪU
-- =============================================
INSERT INTO notifications (notification_id, title, content, type, target, is_pinned, created_by)
VALUES
    ('f0000000-0000-0000-0000-000000000001', 'Thông báo bảo trì thang máy', 'Thang máy tòa A sẽ được bảo trì vào ngày 01/12/2025 từ 8h-12h. Cư dân vui lòng sử dụng thang máy tòa B trong thời gian này.', 'warning', 'all', TRUE, 'a0000000-0000-0000-0000-000000000002'),
    ('f0000000-0000-0000-0000-000000000002', 'Nhắc nhở thanh toán phí tháng 11', 'Kính gửi quý cư dân, phí quản lý tháng 11/2025 đã được phát hành. Vui lòng thanh toán trước ngày 15/12/2025 để tránh phát sinh phí trễ hạn.', 'info', 'all', FALSE, 'a0000000-0000-0000-0000-000000000002'),
    ('f0000000-0000-0000-0000-000000000003', 'Lễ hội Giáng Sinh 2025', 'Chung cư Kogu Express tổ chức lễ hội Giáng Sinh vào ngày 24/12/2025 lúc 18h tại sảnh tầng 1. Mời tất cả cư dân tham gia cùng nhiều hoạt động vui nhộn và quà tặng hấp dẫn!', 'success', 'all', FALSE, 'a0000000-0000-0000-0000-000000000002'),
    ('f0000000-0000-0000-0000-000000000004', 'Cảnh báo: Kiểm tra PCCC định kỳ', 'Lực lượng PCCC sẽ kiểm tra định kỳ vào ngày 05/12/2025. Cư dân vui lòng đảm bảo lối thoát hiểm thông thoáng và không để vật cản trước cửa phòng.', 'urgent', 'all', TRUE, 'a0000000-0000-0000-0000-000000000002'),
    ('f0000000-0000-0000-0000-000000000005', 'Cập nhật giờ hoạt động phòng gym', 'Từ ngày 01/12/2025, phòng gym sẽ hoạt động từ 5h30 - 22h00 hàng ngày (kể cả cuối tuần và ngày lễ).', 'info', 'all', FALSE, 'a0000000-0000-0000-0000-000000000002')
ON CONFLICT DO NOTHING;

-- =============================================
-- 8. PHẢN HỒI MẪU
-- =============================================
INSERT INTO feedbacks (feedback_id, user_id, house_hold_id, type, priority, title, content, status)
VALUES
    ('g0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000001', 'maintenance', 'high', 'Đèn hành lang tầng 1 bị hỏng', 'Đèn hành lang phía Đông tầng 1 không sáng được 3 ngày nay, rất khó đi lại vào buổi tối. Kính mong ban quản lý sửa chữa sớm.', 'pending'),
    ('g0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000002', 'complaint', 'medium', 'Tiếng ồn từ phòng tập gym', 'Tiếng ồn từ phòng tập gym vào buổi tối (sau 22h) làm ảnh hưởng đến giấc ngủ của gia đình. Đề nghị BQL có biện pháp khắc phục.', 'in_progress'),
    ('g0000000-0000-0000-0000-000000000003', 'd0000000-0000-0000-0000-000000000003', 'b0000000-0000-0000-0000-000000000003', 'suggestion', 'low', 'Đề xuất thêm cây xanh sảnh', 'Đề xuất ban quản lý thêm cây xanh ở sảnh tầng 1 và hành lang các tầng để không gian sống xanh và thoáng mát hơn.', 'pending'),
    ('g0000000-0000-0000-0000-000000000004', 'd0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000001', 'maintenance', 'urgent', 'Ống nước rò rỉ cần sửa gấp', 'Ống nước trong nhà vệ sinh bị rò rỉ nghiêm trọng, nước chảy liên tục. Cần sửa chữa khẩn cấp để tránh hư hại thêm.', 'resolved'),
    ('g0000000-0000-0000-0000-000000000005', NULL, 'b0000000-0000-0000-0000-000000000005', 'other', 'medium', 'Hỏi về quy định nuôi thú cưng', 'Xin hỏi BQL về quy định nuôi thú cưng trong chung cư. Gia đình tôi muốn nuôi một chú mèo nhỏ, không biết có được phép không?', 'pending')
ON CONFLICT DO NOTHING;

-- =============================================
-- 9. BÌNH LUẬN PHẢN HỒI MẪu
-- =============================================
INSERT INTO feedback_comments (comment_id, feedback_id, user_id, content, is_internal)
VALUES
    ('bb000000-0000-0000-0000-000000000001', 'aa000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000002', 'Đã tiếp nhận phản ánh. Chúng tôi sẽ điều chỉnh giờ hoạt động phòng gym để đảm bảo không ảnh hưởng đến cư dân.', FALSE),
    ('bb000000-0000-0000-0000-000000000002', 'aa000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000002', 'Ghi chú nội bộ: Đã họp với đơn vị vận hành gym, sẽ lắp thêm tấm cách âm.', TRUE),
    ('bb000000-0000-0000-0000-000000000003', 'aa000000-0000-0000-0000-000000000004', 'a0000000-0000-0000-0000-000000000002', 'Đã cử thợ đến sửa chữa lúc 14h ngày 25/11. Vấn đề đã được khắc phục.', FALSE)
ON CONFLICT DO NOTHING;

-- =============================================
-- THÔNG BÁO HOÀN TẤT
-- =============================================
SELECT 'Test data seeded successfully!' AS message;
SELECT 'WARNING: This data is for testing only. DO NOT use in production!' AS warning;
