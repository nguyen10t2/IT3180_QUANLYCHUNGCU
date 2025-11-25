import Resident from "../models/Resident.js";

export const getResidents = async (req, res) => {
    try {

        const user_id = req.user?.user_id;
        if (!user_id) {
            return res.status(401).json({ message: "Unauthorized" });
        }

        const resident = await Resident.getResidentByUserId({ user_id });
        if (!resident) {
            return res.status(404).json({ message: "Không tìm thấy cư dân" });
        }   

        return res.status(200).json({ resident });

    } catch (error) {
        console.error("Lỗi khi gọi getResidents", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
}

export const updateResident = async (req, res) => {
    try {
        const user_id = req.user?.user_id;
        if (!user_id) {
            return res.status(401).json({ message: "Unauthorized" });
        }

        const resident_id = await Resident.getResidentIdFromUserId({ user_id });
        if (!resident_id) {
            return res.status(404).json({ message: "Không tìm thấy cư dân" });
        }

        const payload = req.body;
        const res = await Resident.updateResident({ resident_id, payload });

        res.status(201).json({
            message: "Cập nhật thành công"
        });
    } catch (error) {
        console.error("Lỗi khi gọi updateResident", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
}