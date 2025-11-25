import { Feedback } from "../models/Feedback.js";
import { Resident } from "../models/Resident.js";
import { User } from "../models/User.js";

export const getFeedbacks = async (req, res) => {
    try {
        const user_id = req.user?.user_id;
        if (!user_id) {
            return res.status(401).json({ message: "Lỗi xác thực" });
        }

        const feedbacks = await Feedback.getFeedbacksByUser({ user_id });

        return res.status(200).json({ feedbacks });
    } catch (error) {
        console.error("Lỗi khi lấy feedback:", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
};

export const createFeedback = async (req, res) => {
    try {
        const user_id = req.user?.user_id;

        if (!user_id) {
            return res.status(401).json({ message: "Lỗi xác thực" });
        }

        // Lấy status từ database thay vì từ JWT
        const user = await User.findUserById({ user_id });
        if (!user || user.status !== 'active') {
            return res.status(403).json({ 
                message: "Tài khoản chưa được kích hoạt. Vui lòng hoàn tất đăng ký thông tin cư dân." 
            });
        }

        const { type, priority, title, content } = req.body;

        if (!type || !title || !content) {
            return res.status(400).json({ message: "Vui lòng điền đầy đủ thông tin" });
        }

        const resident = await Resident.getResidentByUserId({ user_id });
        const house_hold_id = resident?.house_id || null;

        const feedback = await Feedback.create({
            user_id,
            house_hold_id,
            type,
            priority: priority || 'medium',
            title,
            content
        });

        return res.status(201).json({ 
            message: "Gửi phản hồi thành công",
            feedback 
        });
    } catch (error) {
        console.error("Lỗi khi tạo feedback:", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
};

export const getFeedbackDetails = async (req, res) => {
    try {
        const user_id = req.user?.user_id;
        const { feedback_id } = req.params;

        if (!user_id) {
            return res.status(401).json({ message: "Lỗi xác thực" });
        }

        const feedback = await Feedback.getFeedbackWithComments({ feedback_id, user_id });
        
        if (!feedback) {
            return res.status(404).json({ message: "Không tìm thấy phản hồi" });
        }

        return res.status(200).json({ feedback });
    } catch (error) {
        console.error("Lỗi khi lấy chi tiết feedback:", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
};
