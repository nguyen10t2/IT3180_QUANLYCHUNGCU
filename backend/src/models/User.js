import pool from '../libs/db.js';

export const User = {
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
    
    async updateStatus({ user_id, status }) {
        const res = await pool.query(
            `UPDATE users SET status = $1
            WHERE user_id = $2
            RETURNING *`,
            [status, user_id]
        );
        return res.rows[0];
    },
};