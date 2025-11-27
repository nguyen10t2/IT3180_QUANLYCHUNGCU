import { HouseHold } from "../models/HouseHold.js";

export const getHouseHolds = async (req, res) => {
    try {
        const houseHolds = await HouseHold.getAll();
        return res.status(200).json(houseHolds);
    } catch (error) {
        console.error("Lỗi khi lấy danh sách hộ dân:", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
};

export const createHouseHold = async (req, res) => {
    try {
        
        const { room_number, room_type, head_resident_id, floor, area, notes } = req.body;

        if (!room_number || !room_type) {
            return res.status(400).json({ message: "Vui lòng điền đầy đủ thông tin bắt buộc" });
        }

        const newHouseHold = await HouseHold.create({
            room_number,
            room_type,
            head_resident_id: head_resident_id || null,
            floor: floor || null,
            area: area || null,
            notes: notes || null
        });

        return res.status(201).json({
            message: "Tạo hộ dân thành công!",
            houseHold: newHouseHold
        });

    } catch (error) {
        console.error("Lỗi khi tạo hộ dân:", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
};

export const getHouseHoldDetails = async (req, res) => {
    try {
        
        const { id } = req.params;
        
        const houseHold = await HouseHold.getById({ house_hold_id: id });
        if (!houseHold) {
            return res.status(404).json({ message: "Không tìm thấy hộ dân" });
        }
        
        return res.status(200).json({ houseHold });

    } catch (error) {
        console.error("Lỗi khi lấy chi tiết hộ dân:", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
};

export const updateHouseHold = async (req, res) => {
    try {
        
        const { id } = req.params;
        const data = req.body;
        const houseHold = await HouseHold.getById({ house_hold_id: id });
        if (!houseHold) {
            return res.status(404).json({ message: "Không tìm thấy hộ dân" });
        }
        
        await HouseHold.update({
            house_hold_id: id,
            data
        });

        return res.status(200).json({ message: "Cập nhật hộ dân thành công!" });

    } catch (error) {
        console.error("Lỗi khi cập nhật hộ dân:", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
};

export const deleteHouseHold = async (req, res) => {
    try {
        
        const { id } = req.params;
        const houseHold = await HouseHold.getById({ house_hold_id: id });
        if (!houseHold) {
            return res.status(404).json({ message: "Không tìm thấy hộ dân" });
        }

        await HouseHold.delete({ house_hold_id: id });
        
        return res.status(200).json({ message: "Xóa hộ dân thành công!" });
    } catch (error) {
        console.error("Lỗi khi xóa hộ dân:", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
};