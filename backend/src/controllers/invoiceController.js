import { Invoice } from "../models/Invoice.js";
import { Resident } from "../models/Resident.js";
import { User } from "../models/User.js";

export const getInvoices = async (req, res) => {
    try {
        const user_id = req.user?.user_id;
        if (!user_id) {
            return res.status(401).json({ message: "Unauthorized" });
        }

        const resident = await Resident.getResidentByUserId({ user_id });
        if (!resident?.house_id) {
            return res.status(200).json({ invoices: [] });
        }

        const invoices = await Invoice.getInvoicesByHouseHold({ 
            house_hold_id: resident.house_id 
        });

        return res.status(200).json({ invoices });
    } catch (error) {
        console.error("Lỗi khi lấy hóa đơn:", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
};

export const getInvoiceDetails = async (req, res) => {
    try {
        const user_id = req.user?.user_id;
        const { invoice_id } = req.params;

        if (!user_id) {
            return res.status(401).json({ message: "Unauthorized" });
        }

        const invoice = await Invoice.getInvoiceById({ invoice_id });
        if (!invoice) {
            return res.status(404).json({ message: "Không tìm thấy hóa đơn" });
        }

        const resident = await Resident.getResidentByUserId({ user_id });
        if (invoice.house_hold_id !== resident?.house_id) {
            return res.status(403).json({ message: "Không có quyền truy cập hóa đơn này" });
        }

        const items = await Invoice.getInvoiceDetails({ invoice_id });

        return res.status(200).json({ invoice, items });
    } catch (error) {
        console.error("Lỗi khi lấy chi tiết hóa đơn:", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
};

export const payInvoice = async (req, res) => {
    try {
        const user_id = req.user?.user_id;
        const { invoice_id } = req.params;
        const { payment_method, transaction_id } = req.body;

        if (!user_id) {
            return res.status(401).json({ message: "Unauthorized" });
        }

        // Lấy status từ database thay vì từ JWT
        const user = await User.findUserById({ user_id });
        if (!user || user.status !== 'active') {
            return res.status(403).json({ 
                message: "Tài khoản chưa được kích hoạt. Vui lòng hoàn tất đăng ký thông tin cư dân." 
            });
        }

        const invoice = await Invoice.getInvoiceById({ invoice_id });
        if (!invoice) {
            return res.status(404).json({ message: "Không tìm thấy hóa đơn" });
        }

        const resident = await Resident.getResidentByUserId({ user_id });
        if (invoice.house_hold_id !== resident?.house_id) {
            return res.status(403).json({ message: "Không có quyền thanh toán hóa đơn này" });
        }

        const paidInvoice = await Invoice.payInvoice({ 
            invoice_id, 
            user_id, 
            payment_method: payment_method || 'bank_transfer',
            transaction_id 
        });

        return res.status(200).json({ 
            message: "Thanh toán thành công",
            invoice: paidInvoice 
        });
    } catch (error) {
        console.error("Lỗi khi thanh toán:", error);
        return res.status(500).json({ message: error.message || "Lỗi hệ thống" });
    }
};
