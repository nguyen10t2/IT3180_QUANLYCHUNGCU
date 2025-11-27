import pool from "../libs/db.js";

export const HouseHold = {
    async getAll() {
        const res = await pool.query(
            `SELECT h.house_hold_id, h.room_number, h.room_type, h.floor, h.area, 
                    h.head_resident_id, h.members_count, h.has_vehicle, h.vehicle_count, h.notes,
                    h.created_at, h.updated_at,
                    r.fullname as head_fullname, r.phone_number as head_phone
             FROM house_holds h
             LEFT JOIN residents r ON h.head_resident_id = r.resident_id
             ORDER BY h.room_number`
        );
        return res.rows;
    },

    async create({ room_number, room_type, head_resident_id, floor, area, notes }) {
        // Lấy tên chủ hộ từ resident để lưu vào house_hold_head (legacy support)
        let house_hold_head = null;
        if (head_resident_id) {
            const residentRes = await pool.query(
                `SELECT fullname FROM residents WHERE resident_id = $1`,
                [head_resident_id]
            );
            if (residentRes.rows[0]) {
                house_hold_head = residentRes.rows[0].fullname;
            }
        }

        const res = await pool.query(
            `INSERT INTO house_holds (room_number, room_type, house_hold_head, head_resident_id, floor, area, notes)
            VALUES ($1, $2, $3, $4, $5, $6, $7)
            RETURNING *`,
            [room_number, room_type, house_hold_head, head_resident_id, floor, area, notes]
        );
        return res.rows[0];
    },

    async getById({ house_hold_id }) {
        const res = await pool.query(
            `SELECT h.*, r.fullname as head_fullname, r.phone_number as head_phone
             FROM house_holds h
             LEFT JOIN residents r ON h.head_resident_id = r.resident_id
             WHERE h.house_hold_id = $1`,
            [house_hold_id]
        );
        return res.rows[0];
    },

    async update({ house_hold_id, data }) {
        // Nếu đổi head_resident_id, cập nhật luôn house_hold_head (legacy)
        if (data.head_resident_id) {
            const residentRes = await pool.query(
                `SELECT fullname FROM residents WHERE resident_id = $1`,
                [data.head_resident_id]
            );
            if (residentRes.rows[0]) {
                data.house_hold_head = residentRes.rows[0].fullname;
            }
        }

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
            SET ${fields.join(", ")}, updated_at = NOW()
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