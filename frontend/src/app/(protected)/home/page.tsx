"use client";

import { DashboardLayout } from "@/components/layout";
import { useAuthStore } from "@/stores/useAuthStore";
import { useNotificationStore } from "@/stores/useNotificationStore";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Bell, FileText, Users, Calendar } from "lucide-react";
import { useRouter } from "next/navigation";

export default function HomePage() {
  const { user } = useAuthStore();
  const router = useRouter();
  const unreadCount = useNotificationStore((state) => 
    state.notifications.filter((n) => !n.read).length
  );

  const stats = [
    {
      title: "Thông báo mới",
      value: unreadCount.toString(),
      description: "Chưa đọc",
      icon: Bell,
      color: "text-blue-500",
      bgColor: "bg-blue-500/10",
    },
    {
      title: "Hóa đơn",
      value: "2",
      description: "Chưa thanh toán",
      icon: FileText,
      color: "text-orange-500",
      bgColor: "bg-orange-500/10",
    },
    {
      title: "Cư dân",
      value: "150",
      description: "Đã đăng ký",
      icon: Users,
      color: "text-green-500",
      bgColor: "bg-green-500/10",
    },
    {
      title: "Sự kiện",
      value: "3",
      description: "Sắp diễn ra",
      icon: Calendar,
      color: "text-purple-500",
      bgColor: "bg-purple-500/10",
    },
  ];

  return (
    <DashboardLayout>
      <div className="space-y-6">
        {/* Welcome Section */}
        <div className="space-y-2">
          <h1 className="text-3xl font-bold tracking-tight">
            Xin chào, {user?.fullname || "Bạn"}! 👋
          </h1>
          <p className="text-muted-foreground">
            Chào mừng bạn đến với hệ thống quản lý chung cư Kogu Express
          </p>
        </div>

        {/* Stats Grid */}
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          {stats.map((stat) => (
            <Card key={stat.title} className="transition-all hover:shadow-md">
              <CardHeader className="flex flex-row items-center justify-between pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground">
                  {stat.title}
                </CardTitle>
                <div className={`p-2 rounded-lg ${stat.bgColor}`}>
                  <stat.icon className={`h-4 w-4 ${stat.color}`} />
                </div>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{stat.value}</div>
                <p className="text-xs text-muted-foreground mt-1">
                  {stat.description}
                </p>
              </CardContent>
            </Card>
          ))}
        </div>

        {/* Quick Actions & Recent Activity */}
        <div className="grid gap-6 md:grid-cols-2">
          {/* Quick Actions */}
          <Card>
            <CardHeader>
              <CardTitle>Thao tác nhanh</CardTitle>
              <CardDescription>
                Các chức năng thường sử dụng
              </CardDescription>
            </CardHeader>
            <CardContent className="grid gap-2">
              <button 
                onClick={() => router.push("/invoices")}
                className="flex items-center gap-3 p-3 rounded-lg bg-muted/50 hover:bg-muted transition-colors text-left"
              >
                <FileText className="h-5 w-5 text-primary" />
                <div>
                  <p className="font-medium">Thanh toán hóa đơn</p>
                  <p className="text-sm text-muted-foreground">
                    Xem và thanh toán các khoản phí
                  </p>
                </div>
              </button>
              <button 
                onClick={() => router.push("/notifications")}
                className="flex items-center gap-3 p-3 rounded-lg bg-muted/50 hover:bg-muted transition-colors text-left"
              >
                <Bell className="h-5 w-5 text-primary" />
                <div>
                  <p className="font-medium">Xem thông báo</p>
                  <p className="text-sm text-muted-foreground">
                    Cập nhật tin tức mới nhất
                  </p>
                </div>
              </button>
            </CardContent>
          </Card>

          {/* Recent Activity */}
          <Card>
            <CardHeader>
              <CardTitle>Hoạt động gần đây</CardTitle>
              <CardDescription>
                Các hoạt động mới nhất của bạn
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div className="flex items-start gap-3">
                  <div className="h-2 w-2 rounded-full bg-green-500 mt-2" />
                  <div>
                    <p className="text-sm font-medium">
                      Thanh toán hóa đơn tháng 11
                    </p>
                    <p className="text-xs text-muted-foreground">2 giờ trước</p>
                  </div>
                </div>
                <div className="flex items-start gap-3">
                  <div className="h-2 w-2 rounded-full bg-blue-500 mt-2" />
                  <div>
                    <p className="text-sm font-medium">
                      Cập nhật thông tin cá nhân
                    </p>
                    <p className="text-xs text-muted-foreground">1 ngày trước</p>
                  </div>
                </div>
                <div className="flex items-start gap-3">
                  <div className="h-2 w-2 rounded-full bg-purple-500 mt-2" />
                  <div>
                    <p className="text-sm font-medium">
                      Đăng ký tham gia sự kiện
                    </p>
                    <p className="text-xs text-muted-foreground">3 ngày trước</p>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </DashboardLayout>
  );
}
