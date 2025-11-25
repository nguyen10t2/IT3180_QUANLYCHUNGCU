import { create } from "zustand";
import { persist } from "zustand/middleware";

export interface Notification {
  id: number;
  title: string;
  description: string;
  type: "info" | "warning" | "success";
  time: string;
  read: boolean;
}

interface NotificationState {
  notifications: Notification[];
  setNotifications: (notifications: Notification[]) => void;
  markAsRead: (id: number) => void;
  markAllAsRead: () => void;
  getUnreadCount: () => number;
}

// Initial hardcoded data (will be replaced by API later)
const initialNotifications: Notification[] = [
  {
    id: 1,
    title: "Thông báo thu phí tháng 11",
    description:
      "Vui lòng thanh toán các khoản phí tháng 11 trước ngày 30/11/2025",
    type: "info",
    time: "2 giờ trước",
    read: false,
  },
  {
    id: 2,
    title: "Bảo trì thang máy",
    description:
      "Thang máy số 2 sẽ được bảo trì vào ngày 28/11/2025 từ 8:00 - 12:00",
    type: "warning",
    time: "1 ngày trước",
    read: false,
  },
  {
    id: 3,
    title: "Thanh toán thành công",
    description: "Bạn đã thanh toán thành công hóa đơn tháng 10",
    type: "success",
    time: "3 ngày trước",
    read: true,
  },
  {
    id: 4,
    title: "Sự kiện cộng đồng",
    description: "Mời bạn tham gia sự kiện giao lưu cư dân vào cuối tuần này",
    type: "info",
    time: "5 ngày trước",
    read: true,
  },
];

export const useNotificationStore = create<NotificationState>()(
  persist(
    (set, get) => ({
      notifications: initialNotifications,

      setNotifications: (notifications) => set({ notifications }),

      markAsRead: (id) => {
        set((state) => ({
          notifications: state.notifications.map((n) =>
            n.id === id ? { ...n, read: true } : n
          ),
        }));
        // TODO: Call API to mark as read
        // await notificationService.markAsRead(id);
      },

      markAllAsRead: () => {
        set((state) => ({
          notifications: state.notifications.map((n) => ({ ...n, read: true })),
        }));
        // TODO: Call API to mark all as read
        // await notificationService.markAllAsRead();
      },

      getUnreadCount: () => {
        return get().notifications.filter((n) => !n.read).length;
      },
    }),
    {
      name: "notification-storage",
    }
  )
);
