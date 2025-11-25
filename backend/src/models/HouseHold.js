import pool from "../libs/db.js";

export const HouseHold = {
    async getAll() {
        const res = await pool.query(
            `SELECT house_hold_id, room_number, room_type, floor, area, house_hold_head 
             FROM house_holds 
             ORDER BY room_number`
        );
        return res.rows;
    },

    async create({ room_number, room_type, house_hold_head, floor, area, notes}) {
        const res = await pool.query(
            `INSERT INTO house_holds (room_number, room_type, house_hold_head, floor, area, notes)
            VALUES ($1, $2, $3, $4, $5, $6)
            RETURNING *`,
            [room_number, room_type, house_hold_head, floor, area, notes]
        );
        return res.rows[0];
    },

    async getById({ house_hold_id }) {
        const res = await pool.query(
            `SELECT * FROM house_holds
            WHERE house_hold_id = $1`,
            [house_hold_id]
        );
        return res.rows[0];
    },

    async update({ house_hold_id, data }) {
        const fields = [];
        const values = [];
        let index = 1;

        for (const key in data) {
            fields.push(`${key} = $${index}`);
            values.push(data[key]);
            index++;
        }
        values.push(house_hold_id);
        
        const res = await pool.query(
            `UPDATE house_holds
            SET ${fields.join(", ")}
            WHERE house_hold_id = $${index}
            RETURNING *`,
            values
        );
        return res.rows[0];
    },

    async delete({ house_hold_id }) {
        const res = await pool.query(
            `DELETE FROM house_holds
            WHERE house_hold_id = $1
            RETURNING *`,
            [house_hold_id]
        );
        return res.rows[0];
    },
};