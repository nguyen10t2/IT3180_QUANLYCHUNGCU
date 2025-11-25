import { HouseHold } from "../models/HouseHold.js";
import { Resident } from "../models/Resident.js";
import { User } from "../models/User.js";

export const getResidents = async (req, res) => {
    try {

        const user_id = req.user?.user_id;
        if (!user_id) {
            return res.status(401).json({ message: "Lỗi xác thực" });
        }

        const resident = await Resident.getResidentByUserId({ user_id });
        if (!resident) {
            const user = await User.findUserById({ user_id });
            return res.status(200).json({ 
                resident: null,
                isNewResident: true,
                userInfo: {
                    fullname: user?.fullname || "",
                    email: user?.email || ""
                }
            });
        }   

        return res.status(200).json({ resident, isNewResident: false });

    } catch (error) {
        console.error("Lỗi khi gọi getResidents", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
}

export const createResident = async (req, res) => {
    try {
        const user_id = req.user?.user_id;
        const userStatus = req.user?.status;

        if (!user_id) {
            return res.status(401).json({ message: "Lỗi xác thực" });
        }

        const existingResident = await Resident.getResidentIdFromUserId({ user_id });
        if (existingResident) {
            return res.status(400).json({ message: "Bạn đã có thông tin cư dân, không thể tạo mới" });
        }

        const { house_id, fullname, id_card, date_of_birth, phone_number, gender, role, status, occupation } = req.body;

        if (!fullname || !date_of_birth || !phone_number || !gender || !role || !status) {
            return res.status(400).json({ message: "Vui lòng điền đầy đủ thông tin bắt buộc" });
        }

        if (id_card) {
            const idCardExists = await Resident.isIdCardExists({ id_card });
            if (idCardExists) {
                return res.status(400).json({ message: "Số CCCD/CMND đã được sử dụng" });
            }
        }

        const phoneExists = await Resident.isExists({ phone_number });
        if (phoneExists) {
            return res.status(400).json({ message: "Số điện thoại đã được sử dụng" });
        }

        const newResident = await Resident.create({
            house_id: house_id || null,
            fullname,
            id_card: id_card || null,
            date_of_birth,
            phone_number,
            gender,
            role,
            status,
            occupation: occupation || null
        });

        await User.updateResidentId({ user_id, resident_id: newResident.resident_id });

        return res.status(201).json({
            message: "Tạo thông tin cư dân thành công! Vui lòng chờ ban quản lý duyệt.",
            resident: newResident
        });

    } catch (error) {
        console.error("Lỗi khi tạo resident:", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
}

export const getHouseHolds = async (req, res) => {
    try {
        const houseHolds = await HouseHold.getAll();
        return res.status(200).json({ houseHolds });
    } catch (error) {
        console.error("Lỗi khi lấy danh sách hộ:", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
}

export const updateResident = async (req, res) => {
    try {
        const user_id = req.user?.user_id;
        if (!user_id) {
            return res.status(401).json({ message: "Lỗi xác thực" });
        }

        const resident_id = await Resident.getResidentIdFromUserId({ user_id });
        if (!resident_id) {
            return res.status(404).json({ message: "Không tìm thấy cư dân" });
        }

        const allowedFields = ['phone_number', 'occupation'];
        const data = {};
        for (const field of allowedFields) {
            if (req.body[field] !== undefined) {
                data[field] = req.body[field];
            }
        }

        if (Object.keys(data).length === 0) {
            return res.status(400).json({ message: "Không có trường nào để cập nhật" });
        }

        const updated = await Resident.updateResident({ resident_id, data });

        return res.status(200).json({
            message: "Cập nhật thành công",
            resident: updated
        });
    } catch (error) {
        console.error("Lỗi khi gọi updateResident", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
}