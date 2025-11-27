import pool from "../libs/db.js";

export const Invoice = {

    async getAll() {
        const res = await pool.query(
            `SELECT i.*, h.room_number
             FROM invoices i
             JOIN house_holds h ON i.house_hold_id = h.house_hold_id
             ORDER BY i.created_at DESC`
        );
        return res.rows;
    },

    async create({ house_hold_id, period_month, period_year, total_amount, due_date, invoice_type, notes, created_by }) {
        const invoice_number = `HD-${period_year}-${String(period_month).padStart(2, '0')}-${Date.now().toString().slice(-4)}`;
        const res = await pool.query(
            `INSERT INTO invoices (invoice_number, house_hold_id, period_month, period_year, total_amount, due_date, invoice_type, notes, created_by)
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
             RETURNING *`,
            [invoice_number, house_hold_id, period_month, period_year, total_amount, due_date, invoice_type || 'other', notes, created_by]
        );
        return res.rows[0];
    },

    async update({ invoice_id, data }) {
        const fields = [];
        const values = [];
        let index = 1;
        for (const key in data) {
            fields.push(`${key} = $${index}`);
            values.push(data[key]);
            index++;
        }
        values.push(invoice_id);
        const res = await pool.query(
            `UPDATE invoices SET ${fields.join(", ")} WHERE invoice_id = $${index} RETURNING *`,
            values
        );
        return res.rows[0];
    },

    async delete({ invoice_id }) {
        const res = await pool.query(
            `DELETE FROM invoices WHERE invoice_id = $1 RETURNING *`,
            [invoice_id]
        );
        return res.rows[0];
    },

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
    },

    async confirmPayment({ invoice_id, confirmed_by }) {
        const res = await pool.query(
            `UPDATE invoices 
             SET status = 'paid', confirmed_by = $2, confirmed_at = NOW(), paid_at = NOW()
             WHERE invoice_id = $1 AND status = 'pending'
             RETURNING *`,
            [invoice_id, confirmed_by]
        );
        return res.rows[0];
    }
};
