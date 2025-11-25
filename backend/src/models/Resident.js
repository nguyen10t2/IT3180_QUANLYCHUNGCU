import { getResidents } from "../controllers/residentController";
import { updateMe } from "../controllers/userController";
import pool from "../libs/db";

export const Resident = {
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

    async getResidentByUserId({user_id}) {
        const res = await pool.query(
            `SELECT r.* FRIM residents r
            INNER JOIN users u ON r.resident_id = u.resident_id
            WHERE u.user_id = $1`,
            [user_id]
        );
        return res?.rows[0];
    },
    async getResidentIdFromUserId({user_id}) {
        const res = await pool.query(
            `SELECT r.resident_id FRIM residents r
            INNER JOIN users u ON r.resident_id = u.resident_id
            WHERE u.user_id = $1`,
            [user_id]
        );
        return res?.rows[0];
    }
};