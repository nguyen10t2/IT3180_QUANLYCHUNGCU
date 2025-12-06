import { User } from "../models/User.js";
import { HouseHold } from "../models/HouseHold.js";
import { Resident } from "../models/Resident.js";
import { Invoice } from "../models/Invoice.js";
import { Notification } from "../models/Notification.js";
import { Feedback } from "../models/Feedback.js";

export const getUsers = async (req, res) => {
    try {
        
        const { lastCreated, limit } = req.body;

        const data = await User.getUsersByLastCreatedAndLimit({ lastCreated, limit });

        if (!data || data.length === 0) {
            return res.status(200).json({ users: [] });
        }

        return res.status(200).json({ users: data });

    } catch (error) {
        console.error("Lỗi khi gọi getUsers", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
}

export const getPendingUsers = async (req, res) => {
    try {
        const data = await User.getPendingUsers();
        
        if (!data || data.length === 0) {
            return res.status(200).json({ users: [] });
        }

        return res.status(200).json({ users: data });
    } catch (error) {
        console.error("Lỗi khi gọi getPendingUsers", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
}

export const getUserDetail = async (req, res) => {
    try {
        const { id } = req.params;
        const user = await User.getUserWithResident({ user_id: id });
        
        if (!user) {
            return res.status(404).json({ message: "Không tìm thấy user" });
        }

        return res.status(200).json({ user });
    } catch (error) {
        console.error("Lỗi khi gọi getUserDetail", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
}

export const approveUser = async (req, res) => {
    try {
        const { id } = req.params;

        const user = await User.getUserWithResident({ user_id: id });
        if (!user) {
            return res.status(404).json({ message: "Không tìm thấy user" });
        }
        
        if (user.status !== 'pending') {
            return res.status(400).json({ message: "Chỉ có thể duyệt các user đang chờ" });
        }

        // Kiểm tra user đã có thông tin resident chưa
        if (!user.resident_id) {
            return res.status(400).json({ 
                message: "Không thể duyệt user chưa đăng ký thông tin cư dân. Chỉ Admin có quyền quản lý user này." 
            });
        }

        await User.approveUser({ user_id: id, approved_by: req.user.user_id });
        
        return res.status(200).json({ message: "Duyệt user thành công" });
    } catch (error) {
        console.error("Lỗi khi gọi approveUser", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
}

export const rejectUser = async (req, res) => {
    try {
        const { id } = req.params;
        const { rejected_reason } = req.body;
        
        const user = await User.findUserById({ user_id: id });
        if (!user) {
            return res.status(404).json({ message: "Không tìm thấy user" });
        }
        
        if (user.status !== 'pending') {
            return res.status(400).json({ message: "Chỉ có thể từ chối các user đang chờ" });
        }

        await User.rejectUser({ user_id: id, rejected_by: req.user.user_id, rejected_reason });

        return res.status(200).json({ message: "Từ chối user thành công" });
    } catch (error) {
        console.error("Lỗi khi gọi rejectUser", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
}

export const getHouseHolds = async (req, res) => {
    try {
        
        const houseHolds = await HouseHold.getAll();
        if (!houseHolds || houseHolds.length === 0) {
            return res.status(200).json({ houseHolds: [] });
        }
        
        return res.status(200).json({ houseHolds });

    } catch (error) {
        console.error("Lỗi khi gọi getHouseHolds", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
}

export const createHouseHold = async (req, res) => {
    try {
        
        const { room_number, room_type, head_resident_id, floor, area, notes } = req.body;

        if (!room_number || !room_type) {
            return res.status(400).json({ message: "Vui lòng điền đầy đủ thông tin" });
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
            message: "Tạo hộ thành công",
            houseHold: newHouseHold
        });

    } catch (error) {
        console.error("Lỗi khi gọi createHouseHold", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
}

export const getHouseHoldById = async (req, res) => {
    try {
        const { id } = req.params;

        const houseHold = await HouseHold.getById({ house_hold_id: id });
        if (!houseHold) {
            return res.status(404).json({ message: "Không tìm thấy hộ" });
        }

        return res.status(200).json({ houseHold });
    } catch (error) {
        console.error("Lỗi khi gọi getHouseHoldById", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
}

export const updateHouseHold = async (req, res) => {
    try {
        const { id } = req.params;
        const data = req.body;

        const houseHold = await HouseHold.getById({ house_hold_id: id });
        if (!houseHold) {
            return res.status(404).json({ message: "Không tìm thấy hộ" });
        }
        
        const updatedHouseHold = await HouseHold.update({ house_hold_id: id, data });
        
        return res.status(200).json({ message: "Cập nhật hộ thành công", houseHold: updatedHouseHold });
    } catch (error) {
        console.error("Lỗi khi gọi updateHouseHold", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
}

export const deleteHouseHold = async (req, res) => {
    try {
        
        const { id } = req.params;
        
        const houseHold = await HouseHold.getById({ house_hold_id: id });
        if (!houseHold) {
            return res.status(404).json({ message: "Không tìm thấy hộ" });
        }

        await HouseHold.delete({ house_hold_id: id });

        return res.status(200).json({ message: "Xóa hộ thành công", houseHold: houseHold });
    
    } catch (error) {
        console.error("Lỗi khi gọi deleteHouseHold", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
}

export const getHouseHoldMembers = async (req, res) => {
    try {
        const { id } = req.params;
        const members = await Resident.getByHouseId({ house_id: id });
        return res.status(200).json({ members });
    } catch (error) {
        console.error("Lỗi khi gọi getHouseHoldMembers", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
}

// ============ RESIDENTS ============
export const getResidents = async (req, res) => {
    try {
        const residents = await Resident.getAll();
        return res.status(200).json({ residents });
    } catch (error) {
        console.error("Lỗi khi gọi getResidents", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
}

export const getResidentById = async (req, res) => {
    try {
        const { id } = req.params;
        const resident = await Resident.findById({ resident_id: id });
        if (!resident) {
            return res.status(404).json({ message: "Không tìm thấy cư dân" });
        }
        return res.status(200).json({ resident });
    } catch (error) {
        console.error("Lỗi khi gọi getResidentById", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
}

export const updateResident = async (req, res) => {
    try {
        const { id } = req.params;
        const data = req.body;
        const updated = await Resident.updateResident({ resident_id: id, data });
        if (!updated) {
            return res.status(404).json({ message: "Không tìm thấy cư dân" });
        }
        return res.status(200).json({ message: "Cập nhật thành công", resident: updated });
    } catch (error) {
        console.error("Lỗi khi gọi updateResident", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
}

export const deleteResident = async (req, res) => {
    try {
        const { id } = req.params;
        const deleted = await Resident.delete({ resident_id: id });
        if (!deleted) {
            return res.status(404).json({ message: "Không tìm thấy cư dân" });
        }
        return res.status(200).json({ message: "Xóa cư dân thành công" });
    } catch (error) {
        console.error("Lỗi khi gọi deleteResident", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
}

// ============ INVOICES ============
export const getInvoices = async (req, res) => {
    try {
        const invoices = await Invoice.getAll();
        return res.status(200).json({ invoices });
    } catch (error) {
        console.error("Lỗi khi gọi getInvoices", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
}

export const createInvoice = async (req, res) => {
    try {
        const { house_hold_id, period_month, period_year, total_amount, due_date, invoice_type, notes } = req.body;

        if (!house_hold_id || !period_month || !period_year || !total_amount || !due_date) {
            return res.status(400).json({ message: "Vui lòng điền đầy đủ thông tin" });
        }

        const newInvoice = await Invoice.create({
            house_hold_id,
            period_month,
            period_year,
            total_amount,
            due_date,
            invoice_type: invoice_type || 'other',
            notes: notes || null,
            created_by: req.user.user_id
        });

        return res.status(201).json({
            message: "Tạo hóa đơn thành công",
            invoice: newInvoice
        });
    } catch (error) {
        console.error("Lỗi khi gọi createInvoice", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
}

export const getInvoiceById = async (req, res) => {
    try {
        const { id } = req.params;
        const invoice = await Invoice.getInvoiceById({ invoice_id: id });
        if (!invoice) {
            return res.status(404).json({ message: "Không tìm thấy hóa đơn" });
        }
        return res.status(200).json({ invoice });
    } catch (error) {
        console.error("Lỗi khi gọi getInvoiceById", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
}

export const updateInvoice = async (req, res) => {
    try {
        const { id } = req.params;
        const data = req.body;
        const updated = await Invoice.update({ invoice_id: id, data });
        if (!updated) {
            return res.status(404).json({ message: "Không tìm thấy hóa đơn" });
        }
        return res.status(200).json({ message: "Cập nhật hóa đơn thành công", invoice: updated });
    } catch (error) {
        console.error("Lỗi khi gọi updateInvoice", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
}

export const deleteInvoice = async (req, res) => {
    try {
        const { id } = req.params;
        const deleted = await Invoice.delete({ invoice_id: id });
        if (!deleted) {
            return res.status(404).json({ message: "Không tìm thấy hóa đơn" });
        }
        return res.status(200).json({ message: "Xóa hóa đơn thành công" });
    } catch (error) {
        console.error("Lỗi khi gọi deleteInvoice", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
}

export const confirmInvoicePayment = async (req, res) => {
    try {
        const { id } = req.params;
        const invoice = await Invoice.confirmPayment({ invoice_id: id, confirmed_by: req.user.user_id });
        if (!invoice) {
            return res.status(404).json({ message: "Không tìm thấy hóa đơn" });
        }
        return res.status(200).json({ message: "Xác nhận thanh toán thành công", invoice });
    } catch (error) {
        console.error("Lỗi khi gọi confirmInvoicePayment", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
}

// ============ NOTIFICATIONS ============
export const getNotifications = async (req, res) => {
    try {
        const notifications = await Notification.getAll();
        return res.status(200).json({ notifications });
    } catch (error) {
        console.error("Lỗi khi gọi getNotifications", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
}

export const createNotification = async (req, res) => {
    try {
        const { title, content, type } = req.body;

        if (!title || !content) {
            return res.status(400).json({ message: "Vui lòng điền đầy đủ thông tin" });
        }

        const newNotification = await Notification.create({
            title,
            content,
            type: type || 'general',
            created_by: req.user.user_id
        });

        return res.status(201).json({
            message: "Tạo thông báo thành công",
            notification: newNotification
        });
    } catch (error) {
        console.error("Lỗi khi gọi createNotification", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
}

export const deleteNotification = async (req, res) => {
    try {
        const { id } = req.params;
        const deleted = await Notification.delete({ notification_id: id });
        if (!deleted) {
            return res.status(404).json({ message: "Không tìm thấy thông báo" });
        }
        return res.status(200).json({ message: "Xóa thông báo thành công" });
    } catch (error) {
        console.error("Lỗi khi gọi deleteNotification", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
}

// ============ FEEDBACKS ============
export const getFeedbacks = async (req, res) => {
    try {
        const feedbacks = await Feedback.getAll();
        return res.status(200).json({ feedbacks });
    } catch (error) {
        console.error("Lỗi khi gọi getFeedbacks", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
}

export const respondFeedback = async (req, res) => {
    try {
        const { id } = req.params;
        const { response } = req.body;

        if (!response) {
            return res.status(400).json({ message: "Vui lòng nhập nội dung phản hồi" });
        }

        const feedback = await Feedback.respond({
            feedback_id: id,
            response,
            responded_by: req.user.user_id
        });

        if (!feedback) {
            return res.status(404).json({ message: "Không tìm thấy phản hồi" });
        }

        return res.status(200).json({ message: "Phản hồi thành công", feedback });
    } catch (error) {
        console.error("Lỗi khi gọi respondFeedback", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
}

