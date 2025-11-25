"use client";

import { DashboardLayout } from "@/components/layout";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { FileText, Download, CreditCard, CheckCircle, Clock } from "lucide-react";

const invoices = [
  {
    id: 1,
    title: "Phí quản lý tháng 11/2025",
    amount: "500,000",
    dueDate: "30/11/2025",
    status: "pending",
  },
  {
    id: 2,
    title: "Phí điện nước tháng 11/2025",
    amount: "1,200,000",
    dueDate: "30/11/2025",
    status: "pending",
  },
  {
    id: 3,
    title: "Phí quản lý tháng 10/2025",
    amount: "500,000",
    dueDate: "30/10/2025",
    status: "paid",
  },
  {
    id: 4,
    title: "Phí điện nước tháng 10/2025",
    amount: "980,000",
    dueDate: "30/10/2025",
    status: "paid",
  },
];

export default function InvoicesPage() {
  const pendingInvoices = invoices.filter((i) => i.status === "pending");
  const paidInvoices = invoices.filter((i) => i.status === "paid");

  const totalPending = pendingInvoices.reduce(
    (sum, i) => sum + parseInt(i.amount.replace(/,/g, "")),
    0
  );

  return (
    <DashboardLayout>
      <div className="space-y-6">
        {/* Header */}
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Hóa đơn</h1>
          <p className="text-muted-foreground">
            Quản lý và thanh toán các hóa đơn của bạn
          </p>
        </div>

        {/* Stats */}
        <div className="grid gap-4 md:grid-cols-3">
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                Tổng chưa thanh toán
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-orange-500">
                {totalPending.toLocaleString("vi-VN")} VNĐ
              </div>
              <p className="text-xs text-muted-foreground mt-1">
                {pendingInvoices.length} hóa đơn
              </p>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                Đã thanh toán tháng này
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-green-500">0 VNĐ</div>
              <p className="text-xs text-muted-foreground mt-1">0 hóa đơn</p>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                Hạn thanh toán gần nhất
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">30/11/2025</div>
              <p className="text-xs text-muted-foreground mt-1">
                Còn 5 ngày nữa
              </p>
            </CardContent>
          </Card>
        </div>

        {/* Pending Invoices */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Clock className="h-5 w-5 text-orange-500" />
              Chưa thanh toán
            </CardTitle>
            <CardDescription>
              Các hóa đơn cần thanh toán
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            {pendingInvoices.map((invoice) => (
              <div
                key={invoice.id}
                className="flex items-center justify-between p-4 rounded-lg border bg-orange-500/5 border-orange-500/20"
              >
                <div className="flex items-center gap-4">
                  <div className="p-2 rounded-lg bg-orange-500/10">
                    <FileText className="h-5 w-5 text-orange-500" />
                  </div>
                  <div>
                    <h4 className="font-medium">{invoice.title}</h4>
                    <p className="text-sm text-muted-foreground">
                      Hạn: {invoice.dueDate}
                    </p>
                  </div>
                </div>
                <div className="flex items-center gap-4">
                  <span className="font-semibold">{invoice.amount} VNĐ</span>
                  <Button size="sm">
                    <CreditCard className="h-4 w-4 mr-2" />
                    Thanh toán
                  </Button>
                </div>
              </div>
            ))}
          </CardContent>
        </Card>

        {/* Paid Invoices */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <CheckCircle className="h-5 w-5 text-green-500" />
              Đã thanh toán
            </CardTitle>
            <CardDescription>Lịch sử thanh toán của bạn</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            {paidInvoices.map((invoice) => (
              <div
                key={invoice.id}
                className="flex items-center justify-between p-4 rounded-lg border"
              >
                <div className="flex items-center gap-4">
                  <div className="p-2 rounded-lg bg-green-500/10">
                    <FileText className="h-5 w-5 text-green-500" />
                  </div>
                  <div>
                    <h4 className="font-medium">{invoice.title}</h4>
                    <p className="text-sm text-muted-foreground">
                      Đã thanh toán: {invoice.dueDate}
                    </p>
                  </div>
                </div>
                <div className="flex items-center gap-4">
                  <span className="font-semibold text-muted-foreground">
                    {invoice.amount} VNĐ
                  </span>
                  <Button variant="outline" size="sm">
                    <Download className="h-4 w-4 mr-2" />
                    Tải hóa đơn
                  </Button>
                </div>
              </div>
            ))}
          </CardContent>
        </Card>
      </div>
    </DashboardLayout>
  );
}
