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
    type notification_type DEFAULT 'general',
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
