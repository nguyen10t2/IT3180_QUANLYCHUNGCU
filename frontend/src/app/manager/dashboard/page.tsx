"use client";

import { useEffect, useState } from "react";
import { ManagerDashboardLayout } from "@/components/layout";
import { useAuthStore } from "@/stores/useAuthStore";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { 
  Users, 
  Building2, 
  FileText, 
  UserCheck, 
  Loader2,
  ArrowRight,
  Clock,
  AlertCircle
} from "lucide-react";
import { useRouter } from "next/navigation";
import { toast } from "sonner";
import axiosInstance from "@/lib/axios";

interface DashboardStats {
  pendingUsers: number;
  totalHouseholds: number;
  pendingInvoices: number;
  totalResidents: number;
}

export default function ManagerDashboardPage() {
  const { user } = useAuthStore();
  const router = useRouter();
  const [loading, setLoading] = useState(true);
  const [stats, setStats] = useState<DashboardStats>({
    pendingUsers: 0,
    totalHouseholds: 0,
    pendingInvoices: 0,
    totalResidents: 0,
  });
  const [pendingUsers, setPendingUsers] = useState<any[]>([]);

  useEffect(() => {
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    try {
      setLoading(true);
      
      // Fetch pending users (chỉ những user đã có thông tin resident)
      const pendingUsersRes = await axiosInstance.get("/api/manager/users/pending");
      const pendingUsersData = pendingUsersRes.data.users || [];
      setPendingUsers(pendingUsersData.slice(0, 5)); // Show only first 5
      
      // Fetch households
      const householdsRes = await axiosInstance.get("/api/manager/households");
      const householdsData = householdsRes.data.houseHolds || [];
      
      // Fetch residents count
      const residentsRes = await axiosInstance.get("/api/manager/residents");
      const residentsData = residentsRes.data.residents || [];
      
      // Fetch invoices for pending count
      const invoicesRes = await axiosInstance.get("/api/manager/invoices");
      const invoicesData = invoicesRes.data.invoices || [];
      const pendingInvoicesCount = invoicesData.filter((inv: any) => inv.status === 'pending').length;
      
      setStats({
        pendingUsers: pendingUsersData.length,
        totalHouseholds: householdsData.length,
        pendingInvoices: pendingInvoicesCount,
        totalResidents: residentsData.length,
      });
    } catch (error) {
      console.error("Error fetching dashboard data:", error);
      toast.error("Không thể tải dữ liệu dashboard");
    } finally {
      setLoading(false);
    }
  };

  const statsCards = [
    {
      title: "Chờ duyệt",
      value: stats.pendingUsers,
      description: "Người dùng mới",
      icon: UserCheck,
      color: "text-orange-500",
      bgColor: "bg-orange-500/10",
      href: "/manager/users?filter=pending",
    },
    {
      title: "Hộ gia đình",
      value: stats.totalHouseholds,
      description: "Tổng số",
      icon: Building2,
      color: "text-blue-500",
      bgColor: "bg-blue-500/10",
      href: "/manager/households",
    },
    {
      title: "Hóa đơn chưa TT",
      value: stats.pendingInvoices,
      description: "Tháng này",
      icon: FileText,
      color: "text-red-500",
      bgColor: "bg-red-500/10",
      href: "/manager/invoices?filter=pending",
    },
    {
      title: "Cư dân",
      value: stats.totalResidents,
      description: "Đã đăng ký",
      icon: Users,
      color: "text-green-500",
      bgColor: "bg-green-500/10",
      href: "/manager/residents",
    },
  ];

  return (
    <ManagerDashboardLayout>
      <div className="space-y-6">
        {/* Header */}
        <div className="space-y-2">
          <h1 className="text-3xl font-bold tracking-tight">
            Xin chào, {user?.fullname || "Quản lý"}! 👋
          </h1>
          <p className="text-muted-foreground">
            Tổng quan hệ thống quản lý chung cư Kogu Express
          </p>
        </div>

        {loading ? (
          <div className="flex items-center justify-center py-12">
            <Loader2 className="h-8 w-8 animate-spin text-primary" />
          </div>
        ) : (
          <>
            {/* Stats Grid */}
            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
              {statsCards.map((stat) => (
                <Card 
                  key={stat.title} 
                  className="transition-all hover:shadow-md cursor-pointer"
                  onClick={() => router.push(stat.href)}
                >
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

            {/* Pending Users Section */}
            <Card>
              <CardHeader className="flex flex-row items-center justify-between">
                <div>
                  <CardTitle className="flex items-center gap-2">
                    <Clock className="h-5 w-5 text-orange-500" />
                    Người dùng chờ duyệt
                  </CardTitle>
                  <CardDescription>
                    Các tài khoản mới đang chờ phê duyệt
                  </CardDescription>
                </div>
                <Button 
                  variant="outline" 
                  size="sm"
                  onClick={() => router.push("/manager/users?filter=pending")}
                >
                  Xem tất cả
                  <ArrowRight className="h-4 w-4 ml-2" />
                </Button>
              </CardHeader>
              <CardContent>
                {pendingUsers.length === 0 ? (
                  <div className="text-center py-8 text-muted-foreground">
                    <UserCheck className="h-12 w-12 mx-auto mb-4 text-green-500" />
                    <p>Không có người dùng nào đang chờ duyệt 🎉</p>
                  </div>
                ) : (
                  <div className="space-y-4">
                    {pendingUsers.map((pendingUser) => (
                      <div
                        key={pendingUser.user_id}
                        className="flex items-center justify-between p-4 rounded-lg border bg-orange-500/5"
                      >
                        <div className="flex items-center gap-4">
                          <div className="p-2 rounded-full bg-orange-500/10">
                            <Users className="h-5 w-5 text-orange-500" />
                          </div>
                          <div>
                            <h4 className="font-medium">{pendingUser.fullname}</h4>
                            <p className="text-sm text-muted-foreground">
                              {pendingUser.email}
                            </p>
                            {pendingUser.room_number && (
                              <p className="text-xs text-muted-foreground">
                                Phòng {pendingUser.room_number} - Tầng {pendingUser.floor}
                              </p>
                            )}
                          </div>
                        </div>
                        <div className="flex items-center gap-2">
                          <Button
                            size="sm"
                            onClick={() => router.push("/manager/users")}
                          >
                            Xem & Duyệt
                            <ArrowRight className="h-4 w-4 ml-1" />
                          </Button>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </CardContent>
            </Card>

            {/* Quick Actions */}
            <div className="grid gap-6 md:grid-cols-2">
              <Card>
                <CardHeader>
                  <CardTitle>Thao tác nhanh</CardTitle>
                  <CardDescription>
                    Các chức năng quản lý thường sử dụng
                  </CardDescription>
                </CardHeader>
                <CardContent className="grid gap-2">
                  <button 
                    onClick={() => router.push("/manager/users?filter=pending")}
                    className="flex items-center gap-3 p-3 rounded-lg bg-muted/50 hover:bg-muted transition-colors text-left"
                  >
                    <UserCheck className="h-5 w-5 text-orange-500" />
                    <div>
                      <p className="font-medium">Duyệt người dùng mới</p>
                      <p className="text-sm text-muted-foreground">
                        Xem và phê duyệt các tài khoản đang chờ
                      </p>
                    </div>
                  </button>
                  <button 
                    onClick={() => router.push("/manager/households")}
                    className="flex items-center gap-3 p-3 rounded-lg bg-muted/50 hover:bg-muted transition-colors text-left"
                  >
                    <Building2 className="h-5 w-5 text-blue-500" />
                    <div>
                      <p className="font-medium">Quản lý hộ gia đình</p>
                      <p className="text-sm text-muted-foreground">
                        Thêm, sửa, xóa thông tin căn hộ
                      </p>
                    </div>
                  </button>
                  <button 
                    onClick={() => router.push("/manager/invoices")}
                    className="flex items-center gap-3 p-3 rounded-lg bg-muted/50 hover:bg-muted transition-colors text-left"
                  >
                    <FileText className="h-5 w-5 text-primary" />
                    <div>
                      <p className="font-medium">Quản lý hóa đơn</p>
                      <p className="text-sm text-muted-foreground">
                        Tạo và theo dõi thanh toán hóa đơn
                      </p>
                    </div>
                  </button>
                </CardContent>
              </Card>

              {/* System Status */}
              <Card>
                <CardHeader>
                  <CardTitle>Trạng thái hệ thống</CardTitle>
                  <CardDescription>
                    Thông tin tổng quan về hệ thống
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    <div className="flex items-center justify-between p-3 rounded-lg bg-green-500/5">
                      <div className="flex items-center gap-3">
                        <div className="h-3 w-3 rounded-full bg-green-500 animate-pulse" />
                        <span>API Server</span>
                      </div>
                      <span className="text-sm text-green-600">Hoạt động</span>
                    </div>
                    <div className="flex items-center justify-between p-3 rounded-lg bg-green-500/5">
                      <div className="flex items-center gap-3">
                        <div className="h-3 w-3 rounded-full bg-green-500 animate-pulse" />
                        <span>Database</span>
                      </div>
                      <span className="text-sm text-green-600">Hoạt động</span>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </div>
          </>
        )}
      </div>
    </ManagerDashboardLayout>
  );
}
