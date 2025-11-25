import { Notification } from "../models/Notification.js";
import { Resident } from "../models/Resident.js";

export const getNotifications = async (req, res) => {
    try {
        const user_id = req.user?.user_id;
        if (!user_id) {
            return res.status(401).json({ message: "Unauthorized" });
        }

        const resident = await Resident.getResidentByUserId({ user_id });
        const house_hold_id = resident?.house_id || null;

        const notifications = await Notification.getNotificationsForUser({ 
            user_id, 
            house_hold_id 
        });

        return res.status(200).json({ notifications });
    } catch (error) {
        console.error("Lỗi khi lấy thông báo:", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
};

export const markAsRead = async (req, res) => {
    try {
        const user_id = req.user?.user_id;
        const { notification_id } = req.params;

        if (!user_id) {
            return res.status(401).json({ message: "Unauthorized" });
        }

        await Notification.markAsRead({ notification_id, user_id });

        return res.status(200).json({ message: "Đã đánh dấu đã đọc" });
    } catch (error) {
        console.error("Lỗi khi đánh dấu đã đọc:", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
};

export const markAllAsRead = async (req, res) => {
    try {
        const user_id = req.user?.user_id;
        if (!user_id) {
            return res.status(401).json({ message: "Unauthorized" });
        }

        const resident = await Resident.getResidentByUserId({ user_id });
        const house_hold_id = resident?.house_id || null;

        await Notification.markAllAsRead({ user_id, house_hold_id });

        return res.status(200).json({ message: "Đã đánh dấu tất cả đã đọc" });
    } catch (error) {
        console.error("Lỗi khi đánh dấu tất cả đã đọc:", error);
        return res.status(500).json({ message: "Lỗi hệ thống" });
    }
};
