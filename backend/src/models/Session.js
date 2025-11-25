import pool from "../libs/db.js";

export const Session = {
    async findOne({refresh_token}) {
        const res = await pool.query(
            `SELECT * FROM session
            WHERE refresh_token = $1`,
            [refresh_token]
        );
        return res.rows[0];
    },

    async deleteOne({refresh_token}) {
        const res = await pool.query(
            `DELETE FROM session
            WHERE refresh_token = $1
            RETURNING *`,
            [refresh_token]
        );
        return res.rows;
    },

    async create({user_id, refresh_token, expires_at}) {
        const res = await pool.query(
            `INSERT INTO session (user_id, refresh_token, expires_at)
            VALUES ($1, $2, $3)
            RETURNING *`,
            [user_id, refresh_token, expires_at]
        );
        return res.rows[0];
    },

    async cleanupExpired() {
        await pool.query('DELETE FROM session WHERE expires_at <= NOW() OR user_id = NULL');
    },
};