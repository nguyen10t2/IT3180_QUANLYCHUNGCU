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
