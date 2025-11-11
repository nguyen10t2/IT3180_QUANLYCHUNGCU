import pool from '../libs/db.js';

export const Otp = {
    async create({email, otp, expires_at}) {
        const res = await pool.query(
            `INSERT INTO otp_tokens (email, otp, expires_at, is_used, created_at, updated_at)
            VALUES ($1, $2, $3, FALSE, NOW(), NOW())
            ON CONFLICT (email) DO UPDATE 
            SET otp = $2, expires_at = $3, is_used = FALSE, updated_at = NOW()`,
            [email, otp, expires_at]
        );
        return res.rowCount;
    },

    async getOTPRecord({email}) {
        const res = await pool.query(
            `SELECT otp as stored_otp, expires_at FROM otp_tokens
            WHERE email = $1 AND is_used = FALSE
            ORDER BY created_at DESC LIMIT 1`,
            [email]
        );
        return res.rows[0];
    },

    async getLastOTP({email}) {
        const res = await pool.query(
            `SELECT MAX(created_at) FROM otp_tokens
            WHERE email = $1`,
            [email]
        );
        return res.rows[0];
    },

    async updateOTP({email}) {
        const res = await pool.query(
            `UPDATE otp_tokens
            SET is_used = TRUE, updated_at = NOW()
            WHERE email = $1 AND is_used = FALSE
            RETURNING *`,
            [email]
        );
        return res.rows[0];
    },

    async resendCount({email}) {
        const res = await pool.query(
            `SELECT COUNT(*) FROM otp_tokens 
            WHERE email = $1 AND created_at > NOW() - INTERVAL '1 hour'`,
            [email]
        );
        return res.rows[0];
    },
    
    async deleteOTP() {
        await pool.query(`DELETE FROM otp_tokens
            WHERE expires_at < NOW() - INTERVAL '1 day'
                OR is_used = TRUE`
        );
    }
};