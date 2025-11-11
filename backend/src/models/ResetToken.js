import pool from '../libs/db.js';

export const ResetToken = {
    async create({email, reset_token, expires_at}) {
        const res = await pool.query(
            `INSERT INTO reset_tokens (email, reset_token, expires_at)
            VALUE ($1, $2, $3)
            RETURNING *`,
            [email, reset_token, expires_at]
        );
        return res.rows[0];
    },

    async findOne({email}) {
        const res = await pool.query(
            `SELECT reset_token, expires_at FROM reset_tokens
            WHERE email = $1`,
            [email]
        );
        return res.rows[0];
    },

    async deleteOne({email}) {
        await pool.query(
            `DELETE FROM reset_tokens
            WHERE email = $1 expires_at < NOW() - INTERVAL '1 day'`
            [email]
        );
    }
};