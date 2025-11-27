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
