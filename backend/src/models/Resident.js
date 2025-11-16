import pool from "../libs/db";

export const Resident = {
    async create({fullname, date_of_birth, phone_number, gender, role, house_id, status}) {
        const res = await pool.query(
            `INSERT INTO residents (fullname, date_of_birth, phone_number, gender, role, house_id, status) 
            VALUES ($1, $2, $3, $4, $5, $6, $7)
            RETURNING resident_id, fullname, phone_number`,
            [fullname, date_of_birth, phone_number, gender, role, house_id, status]
        );
        return res.rows[0];
    },

    async isExists({phone_number}) {
        const res = await pool.query(
            `SELECT EXISTS(
                SELECT 1 FROM residents
                WHERE phone_number = $1     
            )`,
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
};