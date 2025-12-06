-- =============================================
-- 07_seed_test_data.sql - Test/Demo data
-- Run this file ONLY for development/testing
-- DO NOT run in production!
-- =============================================

-- =============================================
-- 1. TÀI KHOẢN ADMIN & MANAGER
-- =============================================
INSERT INTO users (user_id, email, password_hash, fullname, role, status, verified)
VALUES 
    ('a0000000-0000-0000-0000-000000000001', 'admin@kogu.vn', '$argon2id$v=19$m=65536,t=3,p=4$gEAayhU8JFMuCdWrHdBtmQ$KJ5yfJLGcvzlDjLusiKP8atkkvA2Ot6szG3WiY3aayQ', 'Admin Kogu', 'admin', 'active', TRUE),
    ('a0000000-0000-0000-0000-000000000002', 'manager@kogu.vn', '$argon2id$v=19$m=65536,t=3,p=4$gEAayhU8JFMuCdWrHdBtmQ$KJ5yfJLGcvzlDjLusiKP8atkkvA2Ot6szG3WiY3aayQ', 'Quản Lý Kogu', 'manager', 'active', TRUE),
    ('a0000000-0000-0000-0000-000000000003', 'accountant@kogu.vn', '$argon2id$v=19$m=65536,t=3,p=4$gEAayhU8JFMuCdWrHdBtmQ$KJ5yfJLGcvzlDjLusiKP8atkkvA2Ot6szG3WiY3aayQ', 'Kế Toán Kogu', 'accountant', 'active', TRUE)
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
    ('d0000000-0000-0000-0000-000000000001', 'nguyenvanan@gmail.com', '$argon2id$v=19$m=65536,t=3,p=4$gEAayhU8JFMuCdWrHdBtmQ$KJ5yfJLGcvzlDjLusiKP8atkkvA2Ot6szG3WiY3aayQ', 'Nguyễn Văn An', 'resident', 'active', TRUE, 'c0000000-0000-0000-0000-000000000001'),
    ('d0000000-0000-0000-0000-000000000002', 'tranthibinh@gmail.com', '$argon2id$v=19$m=65536,t=3,p=4$gEAayhU8JFMuCdWrHdBtmQ$KJ5yfJLGcvzlDjLusiKP8atkkvA2Ot6szG3WiY3aayQ', 'Trần Thị Bình', 'resident', 'active', TRUE, 'c0000000-0000-0000-0000-000000000003'),
    ('d0000000-0000-0000-0000-000000000003', 'levancuong@gmail.com', '$argon2id$v=19$m=65536,t=3,p=4$gEAayhU8JFMuCdWrHdBtmQ$KJ5yfJLGcvzlDjLusiKP8atkkvA2Ot6szG3WiY3aayQ', 'Lê Văn Cường', 'resident', 'active', TRUE, 'c0000000-0000-0000-0000-000000000004')
ON CONFLICT (email) DO NOTHING;

-- =============================================
-- 5. USER PENDING (chờ duyệt - có resident)
-- =============================================
INSERT INTO users (user_id, email, password_hash, fullname, role, status, verified, resident_id)
VALUES 
    ('d0000000-0000-0000-0000-000000000004', 'pending1@test.com', '$argon2id$v=19$m=65536,t=3,p=4$gEAayhU8JFMuCdWrHdBtmQ$KJ5yfJLGcvzlDjLusiKP8atkkvA2Ot6szG3WiY3aayQ', 'Phạm Thị Dung', 'resident', 'pending', TRUE, 'c0000000-0000-0000-0000-000000000005'),
    ('d0000000-0000-0000-0000-000000000005', 'pending2@test.com', '$argon2id$v=19$m=65536,t=3,p=4$gEAayhU8JFMuCdWrHdBtmQ$KJ5yfJLGcvzlDjLusiKP8atkkvA2Ot6szG3WiY3aayQ', 'Võ Văn Hoàng', 'resident', 'pending', TRUE, 'c0000000-0000-0000-0000-000000000007'),
    ('d0000000-0000-0000-0000-000000000006', 'pending3@test.com', '$argon2id$v=19$m=65536,t=3,p=4$gEAayhU8JFMuCdWrHdBtmQ$KJ5yfJLGcvzlDjLusiKP8atkkvA2Ot6szG3WiY3aayQ', 'Hoàng Văn Em', 'resident', 'pending', TRUE, 'c0000000-0000-0000-0000-000000000011')
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
    ('f0000000-0000-0000-0000-000000000001', 'Thông báo bảo trì thang máy', 'Thang máy tòa A sẽ được bảo trì vào ngày 01/12/2025 từ 8h-12h. Cư dân vui lòng sử dụng thang máy tòa B trong thời gian này.', 'general', 'all', TRUE, 'a0000000-0000-0000-0000-000000000002'),
    ('f0000000-0000-0000-0000-000000000002', 'Nhắc nhở thanh toán phí tháng 11', 'Kính gửi quý cư dân, phí quản lý tháng 11/2025 đã được phát hành. Vui lòng thanh toán trước ngày 15/12/2025 để tránh phát sinh phí trễ hạn.', 'payment', 'all', FALSE, 'a0000000-0000-0000-0000-000000000002'),
    ('f0000000-0000-0000-0000-000000000003', 'Lễ hội Giáng Sinh 2025', 'Chung cư Kogu Express tổ chức lễ hội Giáng Sinh vào ngày 24/12/2025 lúc 18h tại sảnh tầng 1. Mời tất cả cư dân tham gia cùng nhiều hoạt động vui nhộn và quà tặng hấp dẫn!', 'event', 'all', FALSE, 'a0000000-0000-0000-0000-000000000002'),
    ('f0000000-0000-0000-0000-000000000004', 'Cảnh báo: Kiểm tra PCCC định kỳ', 'Lực lượng PCCC sẽ kiểm tra định kỳ vào ngày 05/12/2025. Cư dân vui lòng đảm bảo lối thoát hiểm thông thoáng và không để vật cản trước cửa phòng.', 'general', 'all', TRUE, 'a0000000-0000-0000-0000-000000000002'),
    ('f0000000-0000-0000-0000-000000000005', 'Cập nhật giờ hoạt động phòng gym', 'Từ ngày 01/12/2025, phòng gym sẽ hoạt động từ 5h30 - 22h00 hàng ngày (kể cả cuối tuần và ngày lễ).', 'general', 'all', FALSE, 'a0000000-0000-0000-0000-000000000002')
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
