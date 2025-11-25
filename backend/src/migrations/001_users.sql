-- Active: 1763580614738@@127.0.0.1@5432@mydb
-- =============================================
-- 001_users.sql - Core tables for residents
-- =============================================

-- EXTENSION
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================
-- ENUM TYPES
-- =============================================
CREATE TYPE user_role AS ENUM ('admin', 'manager', 'resident', 'accountant');
CREATE TYPE user_status AS ENUM ('active', 'inactive');
CREATE TYPE gender AS ENUM ('male', 'female', 'other');
CREATE TYPE room_type AS ENUM ('single', 'double', 'studio', 'penthouse');
CREATE TYPE house_role AS ENUM ('chuho', 'nguoidaidien', 'nguoithue', 'thanhvien');
CREATE TYPE resident_status AS ENUM ('tamtru', 'thuongtru', 'tamvang');

-- Fee types
CREATE TYPE fee_category AS ENUM ('fixed', 'variable'); -- cố định, phát sinh
CREATE TYPE fee_status AS ENUM ('pending', 'paid', 'overdue', 'cancelled');
CREATE TYPE payment_method AS ENUM ('cash', 'bank_transfer', 'momo', 'vnpay', 'zalopay');

-- Notification types
CREATE TYPE notification_type AS ENUM ('info', 'warning', 'success', 'urgent');
CREATE TYPE notification_target AS ENUM ('all', 'household', 'individual');

-- Feedback types
CREATE TYPE feedback_type AS ENUM ('complaint', 'suggestion', 'maintenance', 'other');
CREATE TYPE feedback_status AS ENUM ('pending', 'in_progress', 'resolved', 'rejected');
CREATE TYPE feedback_priority AS ENUM ('low', 'medium', 'high', 'urgent');

-- =============================================
-- HOUSEHOLDS TABLE
-- =============================================
CREATE TABLE house_holds (
    house_hold_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    room_number VARCHAR(50) UNIQUE NOT NULL,
    room_type room_type NOT NULL,
    area DECIMAL(10, 2), -- diện tích (m2)
    floor INT,
    members_count INT DEFAULT 0,
    house_hold_head VARCHAR(100) NOT NULL,
    has_vehicle BOOLEAN DEFAULT FALSE,
    vehicle_count INT DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_household_room ON house_holds(room_number);
CREATE INDEX idx_household_floor ON house_holds(floor);
CREATE INDEX idx_household_created ON house_holds(created_at DESC);

-- =============================================
-- RESIDENTS TABLE
-- =============================================
CREATE TABLE residents (
    resident_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    house_id UUID REFERENCES house_holds(house_hold_id) ON DELETE SET NULL,
    fullname VARCHAR(100) NOT NULL,
    id_card VARCHAR(20) UNIQUE, -- CCCD/CMND
    date_of_birth DATE NOT NULL,
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    gender gender NOT NULL,
    role house_role NOT NULL,
    status resident_status NOT NULL,
    occupation VARCHAR(100), -- nghề nghiệp
    registration_date TIMESTAMP DEFAULT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_resident_phone ON residents(phone_number);
CREATE INDEX idx_resident_house ON residents(house_id);
CREATE INDEX idx_resident_id_card ON residents(id_card);
CREATE INDEX idx_resident_created ON residents(created_at DESC);

-- =============================================
-- USERS TABLE
-- =============================================
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    fullname VARCHAR(100) NOT NULL,
    avatar_url TEXT,
    role user_role DEFAULT 'resident',
    status user_status DEFAULT 'inactive',
    verified BOOLEAN DEFAULT FALSE,
    resident_id UUID REFERENCES residents(resident_id) ON DELETE SET NULL,
    last_login_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_user_email ON users(email);
CREATE INDEX idx_user_role ON users(role);
CREATE INDEX idx_user_resident ON users(resident_id);
CREATE INDEX idx_user_created ON users(created_at DESC);

-- =============================================
-- SESSION TABLE
-- =============================================
CREATE TABLE sessions (
    session_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    refresh_token TEXT UNIQUE NOT NULL,
    user_agent TEXT,
    ip_address VARCHAR(45),
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_session_user ON sessions(user_id);
CREATE INDEX idx_session_token ON sessions(refresh_token);
CREATE INDEX idx_session_expires ON sessions(expires_at);

-- =============================================
-- OTP TOKENS TABLE
-- =============================================
CREATE TABLE otp_tokens (
    otp_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(100) NOT NULL,
    otp VARCHAR(255) NOT NULL, -- hashed OTP (argon2)
    purpose VARCHAR(50) DEFAULT 'verification', -- verification, reset_password
    attempts INT DEFAULT 0,
    max_attempts INT DEFAULT 5,
    expires_at TIMESTAMP NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_otp_email ON otp_tokens(email);
CREATE INDEX idx_otp_expires ON otp_tokens(expires_at);
CREATE UNIQUE INDEX idx_otp_email_active ON otp_tokens(email) WHERE is_used = FALSE;

-- =============================================
-- RESET TOKENS TABLE
-- =============================================
CREATE TABLE reset_tokens (
    reset_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(100) NOT NULL,
    reset_token TEXT UNIQUE NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_reset_email ON reset_tokens(email);
CREATE INDEX idx_reset_token ON reset_tokens(reset_token);

-- =============================================
-- FEE TYPES TABLE (Loại phí)
-- =============================================
CREATE TABLE fee_types (
    fee_type_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL, -- Phí quản lý, Phí điện, Phí nước, Phí gửi xe...
    description TEXT,
    category fee_category NOT NULL, -- fixed/variable
    unit_price DECIMAL(15, 2) DEFAULT 0, -- đơn giá (VNĐ)
    unit VARCHAR(50), -- m2, kWh, m3, xe/tháng...
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_fee_type_category ON fee_types(category);
CREATE INDEX idx_fee_type_active ON fee_types(is_active);

-- Seed default fee types
INSERT INTO fee_types (name, description, category, unit_price, unit) VALUES
('Phí quản lý', 'Phí quản lý chung cư hàng tháng', 'fixed', 7000, 'm2'),
('Phí gửi xe máy', 'Phí gửi xe máy hàng tháng', 'fixed', 100000, 'xe/tháng'),
('Phí gửi ô tô', 'Phí gửi ô tô hàng tháng', 'fixed', 1500000, 'xe/tháng'),
('Phí điện', 'Phí điện sinh hoạt', 'variable', 3500, 'kWh'),
('Phí nước', 'Phí nước sinh hoạt', 'variable', 15000, 'm3'),
('Phí dịch vụ', 'Phí dịch vụ phát sinh khác', 'variable', 0, 'lần');

-- =============================================
-- INVOICES TABLE (Hóa đơn)
-- =============================================
CREATE TABLE invoices (
    invoice_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_number VARCHAR(50) UNIQUE NOT NULL, -- HD-2025-11-001
    house_hold_id UUID REFERENCES house_holds(house_hold_id) ON DELETE CASCADE,
    period_month INT NOT NULL, -- tháng
    period_year INT NOT NULL, -- năm
    total_amount DECIMAL(15, 2) DEFAULT 0,
    status fee_status DEFAULT 'pending',
    due_date DATE NOT NULL,
    paid_at TIMESTAMP,
    payment_method payment_method,
    notes TEXT,
    created_by UUID REFERENCES users(user_id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_invoice_household ON invoices(house_hold_id);
CREATE INDEX idx_invoice_period ON invoices(period_year, period_month);
CREATE INDEX idx_invoice_status ON invoices(status);
CREATE INDEX idx_invoice_due ON invoices(due_date);
CREATE INDEX idx_invoice_created ON invoices(created_at DESC);
CREATE UNIQUE INDEX idx_invoice_household_period ON invoices(house_hold_id, period_month, period_year);

-- =============================================
-- INVOICE ITEMS TABLE (Chi tiết hóa đơn)
-- =============================================
CREATE TABLE invoice_items (
    item_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_id UUID REFERENCES invoices(invoice_id) ON DELETE CASCADE,
    fee_type_id UUID REFERENCES fee_types(fee_type_id),
    description VARCHAR(255),
    quantity DECIMAL(10, 2) DEFAULT 1, -- số lượng (m2, kWh, số xe...)
    unit_price DECIMAL(15, 2) NOT NULL, -- đơn giá tại thời điểm tạo
    amount DECIMAL(15, 2) NOT NULL, -- thành tiền = quantity * unit_price
    previous_reading DECIMAL(15, 2), -- chỉ số cũ (điện/nước)
    current_reading DECIMAL(15, 2), -- chỉ số mới (điện/nước)
    created_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_invoice_item_invoice ON invoice_items(invoice_id);
CREATE INDEX idx_invoice_item_fee_type ON invoice_items(fee_type_id);

-- =============================================
-- PAYMENT HISTORY TABLE (Lịch sử thanh toán)
-- =============================================
CREATE TABLE payment_history (
    payment_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_id UUID REFERENCES invoices(invoice_id) ON DELETE CASCADE,
    amount DECIMAL(15, 2) NOT NULL,
    payment_method payment_method NOT NULL,
    transaction_id VARCHAR(100), -- mã giao dịch từ cổng thanh toán
    paid_by UUID REFERENCES users(user_id),
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_payment_invoice ON payment_history(invoice_id);
CREATE INDEX idx_payment_created ON payment_history(created_at DESC);

-- =============================================
-- NOTIFICATIONS TABLE (Thông báo)
-- =============================================
CREATE TABLE notifications (
    notification_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    type notification_type DEFAULT 'info',
    target notification_target DEFAULT 'all',
    target_id UUID, -- house_hold_id hoặc user_id nếu target != 'all'
    is_pinned BOOLEAN DEFAULT FALSE, -- ghim thông báo
    published_at TIMESTAMP DEFAULT NOW(),
    expires_at TIMESTAMP, -- thời gian hết hạn hiển thị
    created_by UUID REFERENCES users(user_id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_notification_type ON notifications(type);
CREATE INDEX idx_notification_target ON notifications(target, target_id);
CREATE INDEX idx_notification_published ON notifications(published_at DESC);
CREATE INDEX idx_notification_pinned ON notifications(is_pinned) WHERE is_pinned = TRUE;

-- =============================================
-- NOTIFICATION READS TABLE (Đã đọc thông báo)
-- =============================================
CREATE TABLE notification_reads (
    read_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    notification_id UUID REFERENCES notifications(notification_id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    read_at TIMESTAMP DEFAULT NOW()
);
CREATE UNIQUE INDEX idx_notification_read_unique ON notification_reads(notification_id, user_id);
CREATE INDEX idx_notification_read_user ON notification_reads(user_id);

-- =============================================
-- FEEDBACKS TABLE (Phản hồi/Góp ý)
-- =============================================
CREATE TABLE feedbacks (
    feedback_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(user_id) ON DELETE SET NULL,
    house_hold_id UUID REFERENCES house_holds(house_hold_id) ON DELETE SET NULL,
    type feedback_type NOT NULL,
    priority feedback_priority DEFAULT 'medium',
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    attachments TEXT[], -- array of file URLs
    status feedback_status DEFAULT 'pending',
    assigned_to UUID REFERENCES users(user_id), -- nhân viên xử lý
    resolved_at TIMESTAMP,
    resolution_notes TEXT, -- ghi chú xử lý
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_feedback_user ON feedbacks(user_id);
CREATE INDEX idx_feedback_household ON feedbacks(house_hold_id);
CREATE INDEX idx_feedback_type ON feedbacks(type);
CREATE INDEX idx_feedback_status ON feedbacks(status);
CREATE INDEX idx_feedback_priority ON feedbacks(priority);
CREATE INDEX idx_feedback_created ON feedbacks(created_at DESC);

-- =============================================
-- FEEDBACK COMMENTS TABLE (Bình luận phản hồi)
-- =============================================
CREATE TABLE feedback_comments (
    comment_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    feedback_id UUID REFERENCES feedbacks(feedback_id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(user_id) ON DELETE SET NULL,
    content TEXT NOT NULL,
    is_internal BOOLEAN DEFAULT FALSE, -- ghi chú nội bộ (chỉ staff thấy)
    created_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_feedback_comment_feedback ON feedback_comments(feedback_id);
CREATE INDEX idx_feedback_comment_created ON feedback_comments(created_at DESC);

-- =============================================
-- TRIGGERS: Auto update updated_at
-- =============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_house_holds_updated_at BEFORE UPDATE ON house_holds
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_residents_updated_at BEFORE UPDATE ON residents
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_sessions_updated_at BEFORE UPDATE ON sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_otp_tokens_updated_at BEFORE UPDATE ON otp_tokens
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_fee_types_updated_at BEFORE UPDATE ON fee_types
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_invoices_updated_at BEFORE UPDATE ON invoices
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notifications_updated_at BEFORE UPDATE ON notifications
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_feedbacks_updated_at BEFORE UPDATE ON feedbacks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================
-- TRIGGERS: Auto update members_count in house_holds
-- =============================================
CREATE OR REPLACE FUNCTION update_members_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE house_holds SET members_count = members_count + 1 WHERE house_hold_id = NEW.house_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE house_holds SET members_count = members_count - 1 WHERE house_hold_id = OLD.house_id;
    ELSIF TG_OP = 'UPDATE' AND OLD.house_id IS DISTINCT FROM NEW.house_id THEN
        IF OLD.house_id IS NOT NULL THEN
            UPDATE house_holds SET members_count = members_count - 1 WHERE house_hold_id = OLD.house_id;
        END IF;
        IF NEW.house_id IS NOT NULL THEN
            UPDATE house_holds SET members_count = members_count + 1 WHERE house_hold_id = NEW.house_id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_household_members_count
    AFTER INSERT OR UPDATE OR DELETE ON residents
    FOR EACH ROW EXECUTE FUNCTION update_members_count();

-- =============================================
-- TRIGGERS: Auto calculate invoice total
-- =============================================
CREATE OR REPLACE FUNCTION update_invoice_total()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE invoices 
    SET total_amount = (
        SELECT COALESCE(SUM(amount), 0) 
        FROM invoice_items 
        WHERE invoice_id = COALESCE(NEW.invoice_id, OLD.invoice_id)
    )
    WHERE invoice_id = COALESCE(NEW.invoice_id, OLD.invoice_id);
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_invoice_total_on_item_change
    AFTER INSERT OR UPDATE OR DELETE ON invoice_items
    FOR EACH ROW EXECUTE FUNCTION update_invoice_total();
