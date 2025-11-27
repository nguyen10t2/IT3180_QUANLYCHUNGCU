import pool from "../libs/db.js";

export const Resident = {
    async getAll() {
        const res = await pool.query(
            `SELECT r.*, h.room_number, h.floor
             FROM residents r
             LEFT JOIN house_holds h ON r.house_id = h.house_hold_id
             ORDER BY r.fullname ASC`
        );
        return res.rows;
    },

    async create({ house_id, fullname, id_card, date_of_birth, phone_number, gender, role, status, occupation }) {
        const res = await pool.query(
            `INSERT INTO residents (house_id, fullname, id_card, date_of_birth, phone_number, gender, role, status, occupation)
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
             RETURNING *`,
            [house_id, fullname, id_card, date_of_birth, phone_number, gender, role, status, occupation]
        );
        return res.rows[0];
    },

    async updateResident({resident_id, data}) {
        const fields = [];
        const values = [];
        let index = 1;
        for (const key in data) {
            fields.push(`${key} = $${index}`);
            values.push(data[key]);
            index++;
        }
        values.push(resident_id);

        const res = await pool.query(
            `UPDATE residents
            SET ${fields.join(", ")}
            WHERE resident_id = $${index}
            RETURNING *`,
            values
        );
        return res.rows[0];
    },

    async isExists({phone_number}) {
        const res = await pool.query(
            `SELECT EXISTS(
                SELECT 1 FROM residents
                WHERE phone_number = $1)`,
            [phone_number]
        );
        return res.rows[0].exists;
    },

    async findOne({phone_number}) {
        const res = await pool.query(
            `SELECT * FROM residents
            WHERE phone_number = $1`,   
            [phone_number]
        );
        return res.rows[0];
    },

    async findById({resident_id}) {
        const res = await pool.query(
            `SELECT * FROM residents
            WHERE resident_id = $1`,   
            [resident_id]
        );
        return res.rows[0];
    },

    async updateStatus({resident_id, new_status}) {
        const res = await pool.query(
            `UPDATE residents
            SET status = $1
            WHERE resident_id = $2
            RETURNING *`,
            [new_status, resident_id]
        );
        return res.rows[0];
    },

    async registerResidence({resident_id, registration_date}) {
        const res = await pool.query(
            `UPDATE residents
            SET registration_date = $1
            WHERE resident_id = $2
            RETURNING *`,
            [registration_date, resident_id]
        );
        return res.rows[0];
    },

    async delete({resident_id}) {
        const res = await pool.query(
            `DELETE FROM residents
            WHERE resident_id = $1
            RETURNING resident_id`,
            [resident_id]
        );
        return res.rows[0];
    },

    async getResidentByUserId({user_id}) {
        const res = await pool.query(
            `SELECT r.*, h.room_number, h.floor 
             FROM residents r
             LEFT JOIN house_holds h ON r.house_id = h.house_hold_id
             INNER JOIN users u ON r.resident_id = u.resident_id
             WHERE u.user_id = $1`,
            [user_id]
        );
        return res?.rows[0];
    },
    
    async getResidentIdFromUserId({user_id}) {
        const res = await pool.query(
            `SELECT r.resident_id FROM residents r
             INNER JOIN users u ON r.resident_id = u.resident_id
             WHERE u.user_id = $1`,
            [user_id]
        );
        return res?.rows[0]?.resident_id;
    },

    // Kiểm tra id_card đã tồn tại chưa
    async isIdCardExists({ id_card }) {
        const res = await pool.query(
            `SELECT EXISTS(SELECT 1 FROM residents WHERE id_card = $1)`,
            [id_card]
        );
        return res.rows[0].exists;
    }
};