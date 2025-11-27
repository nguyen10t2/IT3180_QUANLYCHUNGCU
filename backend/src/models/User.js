import pool from '../libs/db.js';

export const User = {

    async getUsersByLastCreatedAndLimit({ lastCreated, limit }) {
        const res = await pool.query(
            `SELECT u.user_id, u.email, u.fullname, u.role, u.status, u.created_at as create_at, u.updated_at,
                    r.resident_id, r.id_card, r.date_of_birth, r.phone_number, r.gender, r.occupation,
                    r.role as resident_role, r.status as resident_status,
                    h.house_hold_id, h.room_number, h.floor
            FROM users u
            LEFT JOIN residents r ON u.resident_id = r.resident_id
            LEFT JOIN house_holds h ON r.house_id = h.house_hold_id
            WHERE u.created_at > $1 AND u.role = 'resident' AND u.resident_id IS NOT NULL
            ORDER BY u.user_id
            LIMIT $2`,
            [lastCreated, limit]
        );
        return res.rows;
    },

    async updateUser({ email, new_password }) {
        const res = await pool.query(
            `UPDATE users
            SET password_hash = $1
            WHERE email = $2
            RETURNING user_id`,
            [new_password, email]
        );
        return res.rows[0];
    },

    async isExists({ email }) {
        const res = await pool.query(
            `SELECT EXISTS(
                SELECT 1 FROM users
                WHERE email = $1
            ) AS "exists"`,
            [email]
        );
        return res.rows[0].exists;
    },

    async findOne({ email }) {
        const res = await pool.query(
            `SELECT * FROM users
            WHERE email = $1`,
            [email]
        );
        return res.rows[0];
    },

    async findUserById({ user_id }) {
        const res = await pool.query(
            `SELECT user_id, email, fullname, role, status, created_at as create_at, updated_at FROM users
            WHERE user_id = $1`,
            [user_id]
        );
        return res.rows[0];
    },

    async create({ email, password_hash, fullname }) {
        const res = await pool.query(
            `INSERT INTO users (email, password_hash, fullname) 
            VALUES ($1, $2, $3)
            RETURNING user_id, email`,
            [email, password_hash, fullname]
        );
        return res.rows[0];
    },

    async verifyUser({ email }) {
        const res = await pool.query(
            `UPDATE users SET verified = TRUE
            WHERE email = $1
            RETURNING *`,
            [email]
        );
        return res.rows[0];
    },

    async updateResidentId({ user_id, resident_id }) {
        const res = await pool.query(
            `UPDATE users SET resident_id = $1
            WHERE user_id = $2
            RETURNING *`,
            [resident_id, user_id]
        );
        return res.rows[0];
    },
    
    async getPendingUsers() {
        // Manager chỉ có thể duyệt users có role = resident VÀ đã có thông tin resident
        const res = await pool.query(
            `SELECT u.user_id, u.email, u.fullname, u.role, u.status, u.created_at as create_at, u.updated_at,
                    r.resident_id, r.id_card, r.date_of_birth, r.phone_number, r.gender, r.occupation,
                    r.role as resident_role, r.status as resident_status,
                    h.house_hold_id, h.room_number, h.floor
            FROM users u
            LEFT JOIN residents r ON u.resident_id = r.resident_id
            LEFT JOIN house_holds h ON r.house_id = h.house_hold_id
            WHERE u.status = 'pending' AND u.role = 'resident' AND u.resident_id IS NOT NULL`,
        );
        return res.rows;
    },

    async getPendingUsersWithoutResident() {
        // Lấy users pending chưa có thông tin resident (chỉ admin mới quản lý được)
        const res = await pool.query(
            `SELECT user_id, email, fullname, role, status, created_at as create_at, updated_at
            FROM users
            WHERE status = 'pending' AND role = 'resident' AND resident_id IS NULL`,
        );
        return res.rows;
    },

    async getUserWithResident({ user_id }) {
        const res = await pool.query(
            `SELECT u.user_id, u.email, u.fullname, u.role, u.status, u.created_at as create_at, u.updated_at,
                    r.resident_id, r.id_card, r.date_of_birth, r.phone_number, r.gender, r.occupation,
                    r.role as resident_role, r.status as resident_status,
                    h.house_hold_id, h.room_number, h.floor
            FROM users u
            LEFT JOIN residents r ON u.resident_id = r.resident_id
            LEFT JOIN house_holds h ON r.house_id = h.house_hold_id
            WHERE u.user_id = $1`,
            [user_id]
        );
        return res.rows[0];
    },

    async approveUser({ user_id, approved_by }) {
        const res = await pool.query(
            `UPDATE users 
            SET status = 'active', approved_by = $2, approved_at = NOW()
            WHERE user_id = $1
            RETURNING *`,
            [user_id, approved_by]
        );
        return res.rows[0];
    },

    async rejectUser({ user_id, rejected_by, rejected_reason }) {
        const res = await pool.query(
            `UPDATE users 
            SET status = 'rejected', approved_by = $2, approved_at = NOW(), rejected_reason = $3
            WHERE user_id = $1
            RETURNING *`,
            [user_id, rejected_by, rejected_reason]
        );
        return res.rows[0];
    }
};