import pool from "../libs/db.js";

export const Invoice = {

    async getInvoicesByHouseHold({ house_hold_id }) {
        const res = await pool.query(
            `SELECT i.*, h.room_number
             FROM invoices i
             JOIN house_holds h ON i.house_hold_id = h.house_hold_id
             WHERE i.house_hold_id = $1
             ORDER BY i.period_year DESC, i.period_month DESC`,
            [house_hold_id]
        );
        return res.rows;
    },

    async getInvoiceDetails({ invoice_id }) {
        const res = await pool.query(
            `SELECT ii.*, ft.name as fee_name, ft.category
             FROM invoice_items ii
             JOIN fee_types ft ON ii.fee_type_id = ft.fee_type_id
             WHERE ii.invoice_id = $1
             ORDER BY ft.category, ft.name`,
            [invoice_id]
        );
        return res.rows;
    },

    async payInvoice({ invoice_id, user_id, payment_method, transaction_id }) {
        const client = await pool.connect();
        try {
            await client.query('BEGIN');

            const invoice = await client.query(
                `UPDATE invoices 
                 SET status = 'paid', paid_at = NOW(), payment_method = $2
                 WHERE invoice_id = $1 AND status = 'pending'
                 RETURNING *`,
                [invoice_id, payment_method]
            );

            if (invoice.rows.length === 0) {
                throw new Error('Hóa đơn không tồn tại hoặc đã được thanh toán');
            }

            await client.query(
                `INSERT INTO payment_history (invoice_id, amount, payment_method, transaction_id, paid_by, notes)
                 VALUES ($1, $2, $3, $4, $5, 'Thanh toán online')`,
                [invoice_id, invoice.rows[0].total_amount, payment_method, transaction_id, user_id]
            );

            await client.query('COMMIT');
            return invoice.rows[0];
        } catch (error) {
            await client.query('ROLLBACK');
            throw error;
        } finally {
            client.release();
        }
    },

    async getInvoiceById({ invoice_id }) {
        const res = await pool.query(
            `SELECT i.*, h.room_number
             FROM invoices i
             JOIN house_holds h ON i.house_hold_id = h.house_hold_id
             WHERE i.invoice_id = $1`,
            [invoice_id]
        );
        return res.rows[0];
    }
};
