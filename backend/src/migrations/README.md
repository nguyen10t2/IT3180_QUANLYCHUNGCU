# Database Migrations

## Cấu trúc thư mục

```
migrations/
├── 00_drop_all.sql              # Drop toàn bộ database (reset)
├── 01_extensions_and_types.sql  # Extensions & ENUM types
├── 02_tables.sql                # Tạo tất cả bảng
├── 03_constraints_and_indexes.sql # Foreign keys, indexes, constraints
├── 04_triggers_and_functions.sql  # Triggers & Functions
├── 05_views.sql                 # Database views
├── 06_seed_default_data.sql     # Dữ liệu mặc định (fee_types)
├── 07_seed_test_data.sql        # Dữ liệu test (CHỈ dùng cho DEV)
└── README.md                    # File hướng dẫn này
```

## Hướng dẫn sử dụng

### 1. Khởi tạo database mới (Fresh Install)

```bash
# Chạy lần lượt theo thứ tự
psql -d mydb -f 01_extensions_and_types.sql
psql -d mydb -f 02_tables.sql
psql -d mydb -f 03_constraints_and_indexes.sql
psql -d mydb -f 04_triggers_and_functions.sql
psql -d mydb -f 05_views.sql
psql -d mydb -f 06_seed_default_data.sql

# Chỉ chạy trong môi trường development/testing
psql -d mydb -f 07_seed_test_data.sql
```

### 2. Reset database hoàn toàn

```bash
# Xóa tất cả objects
psql -d mydb -f 00_drop_all.sql

# Sau đó chạy lại từ bước 1
```

### 3. Chạy tất cả bằng 1 lệnh

```bash
# Development (có test data)
psql -d mydb -f 00_drop_all.sql \
  -f 01_extensions_and_types.sql \
  -f 02_tables.sql \
  -f 03_constraints_and_indexes.sql \
  -f 04_triggers_and_functions.sql \
  -f 05_views.sql \
  -f 06_seed_default_data.sql \
  -f 07_seed_test_data.sql

# Production (KHÔNG có test data)
psql -d mydb -f 00_drop_all.sql \
  -f 01_extensions_and_types.sql \
  -f 02_tables.sql \
  -f 03_constraints_and_indexes.sql \
  -f 04_triggers_and_functions.sql \
  -f 05_views.sql \
  -f 06_seed_default_data.sql
```

## Mô tả chi tiết

### 01_extensions_and_types.sql
- Extension: `uuid-ossp` cho UUID generation
- ENUM types cho users, residents, invoices, notifications, feedbacks

### 02_tables.sql
- 14 bảng chính: house_holds, residents, users, sessions, otp_tokens, reset_tokens, fee_types, invoices, invoice_items, payment_history, notifications, notification_reads, feedbacks, feedback_comments

### 03_constraints_and_indexes.sql
- Foreign key constraints giữa các bảng
- Indexes tối ưu query (đơn và composite)
- Unique constraints

### 04_triggers_and_functions.sql
- `update_updated_at_column()`: Tự động cập nhật updated_at
- `update_members_count()`: Tự động đếm thành viên hộ gia đình
- `update_invoice_total()`: Tự động tính tổng hóa đơn
- `check_overdue_invoices()`: Cập nhật hóa đơn quá hạn
- `get_user_details()`: Lấy thông tin user đầy đủ
- `generate_invoice_number()`: Tạo số hóa đơn tự động

### 05_views.sql
- `dashboard_stats`: Thống kê cho dashboard
- `invoice_summary_by_type`: Tổng hợp hóa đơn theo loại
- `invoice_summary_by_month`: Tổng hợp hóa đơn theo tháng
- `household_details`: Thông tin hộ với chủ hộ
- `user_details`: Thông tin user với resident
- `resident_details`: Thông tin cư dân với household
- `feedback_summary`: Tổng hợp phản hồi
- `active_sessions`: Phiên đăng nhập đang hoạt động

### 06_seed_default_data.sql
- Các loại phí mặc định (fee_types)

### 07_seed_test_data.sql
- Tài khoản admin, manager, accountant
- 8 hộ gia đình mẫu
- 13 cư dân mẫu
- 6 tài khoản user (3 active, 3 pending)
- 9 hóa đơn mẫu (các loại và trạng thái khác nhau)
- 5 thông báo mẫu
- 5 phản hồi mẫu với comments

## Lưu ý quan trọng

**KHÔNG chạy 07_seed_test_data.sql trong môi trường Production!**

**Chạy 00_drop_all.sql sẽ XÓA TẤT CẢ dữ liệu!**

## Tài khoản test (sau khi chạy 07_seed_test_data.sql)

| Email | Role | Password |
|-------|------|----------|
| admin@kogu.vn | admin | (cần hash) |
| manager@kogu.vn | manager | (cần hash) |
| accountant@kogu.vn | accountant | (cần hash) |
| nguyenvanan@gmail.com | resident | (cần hash) |

*Lưu ý: Password hash trong file test data là placeholder. Cần cập nhật với hash thật từ argon2.*
