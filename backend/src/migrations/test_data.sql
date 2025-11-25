-- Test data for user_id: 67821b92-9970-4296-aafd-4e58725ebbb2

-- 1. Tạo hộ gia đình
INSERT INTO house_holds (house_hold_id, room_number, room_type, area, floor, members_count, house_hold_head, has_vehicle, vehicle_count, notes)
VALUES 
('a1b2c3d4-0000-1111-2222-333344445566', 'A-1001', 'double', 75.5, 10, 1, 'Nguyễn Văn A', true, 2, 'Căn hộ góc view đẹp'),
('a1b2c3d4-0000-2222-3333-444455556677', 'A-1002', 'single', 55.0, 10, 2, 'Trần Thị B', true, 1, NULL),
('a1b2c3d4-0000-3333-4444-555566667788', 'B-0501', 'single', 35.0, 5, 1, 'Lê Văn C', false, 0, 'Căn hộ đơn nhỏ')
ON CONFLICT DO NOTHING;

-- 2. Tạo cư dân và liên kết với user đang test (dùng UUID hợp lệ)
INSERT INTO residents (resident_id, house_id, fullname, id_card, date_of_birth, phone_number, gender, role, status, occupation, registration_date)
VALUES 
('a1111111-1111-1111-1111-111111111111', 'a1b2c3d4-0000-1111-2222-333344445566', 'Nguyễn Văn A', '001234567890', '1995-05-15', '0901234567', 'male', 'chuho', 'thuongtru', 'Kỹ sư phần mềm', '2024-01-15'),
('a2222222-2222-2222-2222-222222222222', 'a1b2c3d4-0000-2222-3333-444455556677', 'Trần Thị B', '001234567891', '1998-08-20', '0912345678', 'female', 'chuho', 'thuongtru', 'Giáo viên', '2024-02-20'),
('a3333333-3333-3333-3333-333333333333', 'a1b2c3d4-0000-2222-3333-444455556677', 'Trần Văn C', '001234567892', '2000-12-10', '0923456789', 'male', 'thanhvien', 'tamtru', 'Sinh viên', NULL),
('a4444444-4444-4444-4444-444444444444', 'a1b2c3d4-0000-3333-4444-555566667788', 'Lê Văn D', '001234567893', '1990-03-25', '0934567890', 'male', 'nguoithue', 'tamtru', 'Nhân viên văn phòng', '2024-06-01')
ON CONFLICT DO NOTHING;

-- 3. Cập nhật user với resident_id
UPDATE users SET resident_id = 'a1111111-1111-1111-1111-111111111111' WHERE user_id = '67821b92-9970-4296-aafd-4e58725ebbb2';

-- 4. Cập nhật members_count cho house_holds
UPDATE house_holds SET members_count = 1 WHERE house_hold_id = 'a1b2c3d4-0000-1111-2222-333344445566';
UPDATE house_holds SET members_count = 2 WHERE house_hold_id = 'a1b2c3d4-0000-2222-3333-444455556677';
UPDATE house_holds SET members_count = 1 WHERE house_hold_id = 'a1b2c3d4-0000-3333-4444-555566667788';

-- 5. Tạo các loại phí (nếu chưa có)
INSERT INTO fee_types (fee_type_id, name, description, category, unit_price, unit, is_active)
VALUES 
('f1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1', 'Phí quản lý', 'Phí quản lý chung cư hàng tháng', 'fixed', 7000, 'm2', true),
('f2a2a2a2-a2a2-a2a2-a2a2-a2a2a2a2a2a2', 'Phí gửi xe máy', 'Phí gửi xe máy hàng tháng', 'fixed', 100000, 'xe/tháng', true),
('f3a3a3a3-a3a3-a3a3-a3a3-a3a3a3a3a3a3', 'Phí gửi ô tô', 'Phí gửi ô tô hàng tháng', 'fixed', 1500000, 'xe/tháng', true),
('f4a4a4a4-a4a4-a4a4-a4a4-a4a4a4a4a4a4', 'Phí điện', 'Phí điện sinh hoạt', 'variable', 3500, 'kWh', true),
('f5a5a5a5-a5a5-a5a5-a5a5-a5a5a5a5a5a5', 'Phí nước', 'Phí nước sinh hoạt', 'variable', 15000, 'm3', true)
ON CONFLICT DO NOTHING;

-- 6. Tạo hóa đơn tháng 11/2025 cho hộ của user test
INSERT INTO invoices (invoice_id, invoice_number, house_hold_id, period_month, period_year, total_amount, status, due_date, notes, created_by)
VALUES 
('b1111111-1111-1111-1111-111111111111', 'HD-2025-11-001', 'a1b2c3d4-0000-1111-2222-333344445566', 11, 2025, 0, 'pending', '2025-11-30', 'Hóa đơn tháng 11/2025', NULL),
('b2222222-2222-2222-2222-222222222222', 'HD-2025-10-001', 'a1b2c3d4-0000-1111-2222-333344445566', 10, 2025, 0, 'paid', '2025-10-30', 'Hóa đơn tháng 10/2025', NULL)
ON CONFLICT DO NOTHING;

-- 7. Tạo chi tiết hóa đơn tháng 11
INSERT INTO invoice_items (item_id, invoice_id, fee_type_id, description, quantity, unit_price, amount, previous_reading, current_reading)
VALUES 
-- Hóa đơn tháng 11 (pending)
('c1111111-1111-1111-1111-111111111111', 'b1111111-1111-1111-1111-111111111111', 'f1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1', 'Phí quản lý 75.5m2', 75.5, 7000, 528500, NULL, NULL),
('c2222222-2222-2222-2222-222222222222', 'b1111111-1111-1111-1111-111111111111', 'f2a2a2a2-a2a2-a2a2-a2a2-a2a2a2a2a2a2', 'Phí gửi xe máy (1 xe)', 1, 100000, 100000, NULL, NULL),
('c3333333-3333-3333-3333-333333333333', 'b1111111-1111-1111-1111-111111111111', 'f3a3a3a3-a3a3-a3a3-a3a3-a3a3a3a3a3a3', 'Phí gửi ô tô (1 xe)', 1, 1500000, 1500000, NULL, NULL),
('c4444444-4444-4444-4444-444444444444', 'b1111111-1111-1111-1111-111111111111', 'f4a4a4a4-a4a4-a4a4-a4a4-a4a4a4a4a4a4', 'Phí điện tháng 11', 250, 3500, 875000, 1200, 1450),
('c5555555-5555-5555-5555-555555555555', 'b1111111-1111-1111-1111-111111111111', 'f5a5a5a5-a5a5-a5a5-a5a5-a5a5a5a5a5a5', 'Phí nước tháng 11', 15, 15000, 225000, 100, 115),
-- Hóa đơn tháng 10 (paid)
('c6666666-6666-6666-6666-666666666666', 'b2222222-2222-2222-2222-222222222222', 'f1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1', 'Phí quản lý 75.5m2', 75.5, 7000, 528500, NULL, NULL),
('c7777777-7777-7777-7777-777777777777', 'b2222222-2222-2222-2222-222222222222', 'f2a2a2a2-a2a2-a2a2-a2a2-a2a2a2a2a2a2', 'Phí gửi xe máy (1 xe)', 1, 100000, 100000, NULL, NULL),
('c8888888-8888-8888-8888-888888888888', 'b2222222-2222-2222-2222-222222222222', 'f4a4a4a4-a4a4-a4a4-a4a4-a4a4a4a4a4a4', 'Phí điện tháng 10', 200, 3500, 700000, 1000, 1200),
('c9999999-9999-9999-9999-999999999999', 'b2222222-2222-2222-2222-222222222222', 'f5a5a5a5-a5a5-a5a5-a5a5-a5a5a5a5a5a5', 'Phí nước tháng 10', 12, 15000, 180000, 88, 100)
ON CONFLICT DO NOTHING;

-- 8. Cập nhật tổng tiền hóa đơn
UPDATE invoices SET total_amount = 3228500 WHERE invoice_id = 'b1111111-1111-1111-1111-111111111111';
UPDATE invoices SET total_amount = 1508500, paid_at = '2025-10-28 10:30:00', payment_method = 'bank_transfer' WHERE invoice_id = 'b2222222-2222-2222-2222-222222222222';

-- 9. Tạo thông báo
INSERT INTO notifications (notification_id, title, content, type, target, target_id, is_pinned, published_at, expires_at, created_by)
VALUES 
('d1111111-1111-1111-1111-111111111111', 'Thông báo thu phí tháng 11/2025', 'Kính gửi quý cư dân,

Ban quản lý thông báo về việc thu phí dịch vụ tháng 11/2025. Vui lòng thanh toán trước ngày 30/11/2025.

Trân trọng!', 'info', 'all', NULL, true, '2025-11-01 08:00:00', '2025-11-30 23:59:59', NULL),
('d2222222-2222-2222-2222-222222222222', 'Bảo trì thang máy số 2', 'Thang máy số 2 tòa A sẽ được bảo trì định kỳ vào ngày 28/11/2025 từ 8:00 - 12:00. Quý cư dân vui lòng sử dụng thang máy số 1 trong thời gian này.', 'warning', 'all', NULL, false, '2025-11-20 09:00:00', '2025-11-28 12:00:00', NULL),
('d3333333-3333-3333-3333-333333333333', 'Sự kiện giao lưu cư dân cuối năm', 'Ban quản lý trân trọng kính mời quý cư dân tham gia buổi giao lưu cuối năm vào ngày 15/12/2025 tại sảnh tầng 1. Chương trình có nhiều hoạt động vui nhộn và phần quà hấp dẫn!', 'info', 'all', NULL, false, '2025-11-15 10:00:00', '2025-12-15 23:59:59', NULL),
('d4444444-4444-4444-4444-444444444444', 'Nhắc nhở: Hóa đơn sắp đến hạn', 'Hóa đơn tháng 11/2025 của bạn sẽ đến hạn vào ngày 30/11/2025. Vui lòng thanh toán đúng hạn để tránh phí phạt.', 'urgent', 'household', 'a1b2c3d4-0000-1111-2222-333344445566', false, '2025-11-25 08:00:00', '2025-11-30 23:59:59', NULL)
ON CONFLICT DO NOTHING;

-- 10. Tạo feedback
INSERT INTO feedbacks (feedback_id, user_id, house_hold_id, type, priority, title, content, status, created_at)
VALUES 
('e1111111-1111-1111-1111-111111111111', '67821b92-9970-4296-aafd-4e58725ebbb2', 'a1b2c3d4-0000-1111-2222-333344445566', 'maintenance', 'medium', 'Đèn hành lang tầng 10 bị hỏng', 'Đèn hành lang gần căn hộ A-1001 bị hỏng 3 ngày nay, ban đêm rất tối và nguy hiểm. Mong BQL sớm khắc phục.', 'in_progress', '2025-11-20 14:30:00'),
('e2222222-2222-2222-2222-222222222222', '67821b92-9970-4296-aafd-4e58725ebbb2', 'a1b2c3d4-0000-1111-2222-333344445566', 'suggestion', 'low', 'Đề xuất thêm ghế nghỉ ở sảnh', 'Mong BQL bổ sung thêm một số ghế nghỉ ở sảnh tầng 1 để cư dân có chỗ ngồi chờ.', 'pending', '2025-11-22 09:15:00')
ON CONFLICT DO NOTHING;

-- 11. Tạo comment cho feedback
INSERT INTO feedback_comments (comment_id, feedback_id, user_id, content, is_internal, created_at)
VALUES 
('fa111111-1111-1111-1111-111111111111', 'e1111111-1111-1111-1111-111111111111', NULL, 'Đã tiếp nhận phản ánh. Bộ phận kỹ thuật sẽ kiểm tra và khắc phục trong ngày 21/11.', false, '2025-11-20 16:00:00'),
('fa222222-2222-2222-2222-222222222222', 'e1111111-1111-1111-1111-111111111111', NULL, 'Đã mua bóng đèn mới, chuẩn bị thay.', true, '2025-11-21 08:30:00')
ON CONFLICT DO NOTHING;

-- 12. Tạo lịch sử thanh toán cho hóa đơn tháng 10
INSERT INTO payment_history (payment_id, invoice_id, amount, payment_method, transaction_id, paid_by, notes)
VALUES
('aa111111-1111-1111-1111-111111111111', 'b2222222-2222-2222-2222-222222222222', 1508500, 'bank_transfer', 'VCB-20251028-001234', '67821b92-9970-4296-aafd-4e58725ebbb2', 'Thanh toán qua chuyển khoản ngân hàng')
ON CONFLICT DO NOTHING;

SELECT 'Đã thêm dữ liệu test thành công!' as result;
