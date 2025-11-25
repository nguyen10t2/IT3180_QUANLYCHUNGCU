import pool from "../libs/db.js";

export const Feedback = {
    async getFeedbacksByUser({ user_id }) {
        const res = await pool.query(
            `SELECT f.*, 
                    (SELECT COUNT(*) FROM feedback_comments fc WHERE fc.feedback_id = f.feedback_id AND fc.is_internal = false) as comment_count
             FROM feedbacks f
             WHERE f.user_id = $1
             ORDER BY f.created_at DESC`,
            [user_id]
        );
        return res.rows;
    },

    async create({ user_id, house_hold_id, type, priority, title, content }) {
        const res = await pool.query(
            `INSERT INTO feedbacks (user_id, house_hold_id, type, priority, title, content)
             VALUES ($1, $2, $3, $4, $5, $6)
             RETURNING *`,
            [user_id, house_hold_id, type, priority, title, content]
        );
        return res.rows[0];
    },

    async getFeedbackWithComments({ feedback_id, user_id }) {
        const feedback = await pool.query(
            `SELECT * FROM feedbacks WHERE feedback_id = $1 AND user_id = $2`,
            [feedback_id, user_id]
        );

        if (feedback.rows.length === 0) return null;

        const comments = await pool.query(
            `SELECT fc.*, u.fullname as commenter_name
             FROM feedback_comments fc
             LEFT JOIN users u ON fc.user_id = u.user_id
             WHERE fc.feedback_id = $1 AND fc.is_internal = false
             ORDER BY fc.created_at ASC`,
            [feedback_id]
        );

        return {
            ...feedback.rows[0],
            comments: comments.rows
        };
    }
};
