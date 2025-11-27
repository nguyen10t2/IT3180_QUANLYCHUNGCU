import pool from "../libs/db.js";

export const Notification = {
    async getAll() {
        const res = await pool.query(
            `SELECT n.*, u.fullname as created_by_name
             FROM notifications n
             LEFT JOIN users u ON n.created_by = u.user_id
             ORDER BY n.created_at DESC`
        );
        return res.rows;
    },

    async create({ title, content, type, target, target_id, created_by }) {
        const res = await pool.query(
            `INSERT INTO notifications (title, content, type, target, target_id, published_at, created_by)
             VALUES ($1, $2, $3, $4, $5, NOW(), $6)
             RETURNING *`,
            [title, content, type || 'info', target || 'all', target_id, created_by]
        );
        return res.rows[0];
    },

    async delete({ notification_id }) {
        const res = await pool.query(
            `DELETE FROM notifications WHERE notification_id = $1 RETURNING *`,
            [notification_id]
        );
        return res.rows[0];
    },

    async getNotificationsForUser({ user_id, house_hold_id }) {
        let query = `
            SELECT n.*, 
                   CASE WHEN nr.user_id IS NOT NULL THEN true ELSE false END as read
            FROM notifications n
            LEFT JOIN notification_reads nr ON n.notification_id = nr.notification_id AND nr.user_id = $1
            WHERE n.published_at <= NOW()
              AND (n.expires_at IS NULL OR n.expires_at > NOW())
              AND (
                  n.target = 'all' 
                  OR (n.target = 'household' AND n.target_id = $2)
                  OR (n.target = 'individual' AND n.target_id = $1)
              )
            ORDER BY n.is_pinned DESC, n.published_at DESC
            LIMIT 50
        `;
        const res = await pool.query(query, [user_id, house_hold_id]);
        return res.rows;
    },

    async markAsRead({ notification_id, user_id }) {
        const res = await pool.query(
            `INSERT INTO notification_reads (notification_id, user_id)
             VALUES ($1, $2)
             ON CONFLICT (notification_id, user_id) DO NOTHING
             RETURNING *`,
            [notification_id, user_id]
        );
        return res.rows[0];
    },

    async markAllAsRead({ user_id, house_hold_id }) {
        const res = await pool.query(
            `INSERT INTO notification_reads (notification_id, user_id)
             SELECT n.notification_id, $1
             FROM notifications n
             WHERE n.published_at <= NOW()
               AND (n.expires_at IS NULL OR n.expires_at > NOW())
               AND (
                   n.target = 'all' 
                   OR (n.target = 'household' AND n.target_id = $2)
                   OR (n.target = 'individual' AND n.target_id = $1)
               )
             ON CONFLICT (notification_id, user_id) DO NOTHING`,
            [user_id, house_hold_id]
        );
        return res.rowCount;
    },

    async createScheduledNotification({ title, content, type, target, target_id, scheduled_at, created_by }) {
        const res = await pool.query(
            `INSERT INTO notifications (title, content, type, target, target_id, scheduled_at, published_at, created_by)
             VALUES ($1, $2, $3, $4, $5, $6, $6, $7)
             RETURNING *`,
            [title, content, type || 'info', target || 'all', target_id, scheduled_at, created_by]
        );
        return res.rows[0];
    },

    async getScheduledNotifications() {
        const res = await pool.query(
            `SELECT * FROM notifications
             WHERE scheduled_at IS NOT NULL 
               AND scheduled_at > NOW()
             ORDER BY scheduled_at ASC`
        );
        return res.rows;
    }
};
