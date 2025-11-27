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
