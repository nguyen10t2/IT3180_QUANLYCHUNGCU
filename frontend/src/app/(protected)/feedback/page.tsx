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
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { MessageSquare, Send, Star } from "lucide-react";
import { useState } from "react";

export default function FeedbackPage() {
  const [rating, setRating] = useState(0);
  const [hoveredRating, setHoveredRating] = useState(0);

  return (
    <DashboardLayout>
      <div className="space-y-6">
        {/* Header */}
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Feedback</h1>
          <p className="text-muted-foreground">
            Gửi ý kiến đóng góp và phản hồi của bạn
          </p>
        </div>

        <div className="grid gap-6 md:grid-cols-2">
          {/* Feedback Form */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <MessageSquare className="h-5 w-5 text-primary" />
                Gửi phản hồi
              </CardTitle>
              <CardDescription>
                Chúng tôi rất mong nhận được ý kiến từ bạn
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="subject">Tiêu đề</Label>
                <Input
                  id="subject"
                  placeholder="Nhập tiêu đề phản hồi..."
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="category">Danh mục</Label>
                <select
                  id="category"
                  className="flex h-10 w-full rounded-lg border border-input bg-background px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
                >
                  <option value="">Chọn danh mục</option>
                  <option value="service">Dịch vụ</option>
                  <option value="facility">Cơ sở vật chất</option>
                  <option value="security">An ninh</option>
                  <option value="other">Khác</option>
                </select>
              </div>

              <div className="space-y-2">
                <Label htmlFor="message">Nội dung</Label>
                <textarea
                  id="message"
                  rows={5}
                  placeholder="Nhập nội dung phản hồi của bạn..."
                  className="flex w-full rounded-lg border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 resize-none"
                />
              </div>

              <div className="space-y-2">
                <Label>Đánh giá trải nghiệm</Label>
                <div className="flex gap-1">
                  {[1, 2, 3, 4, 5].map((star) => (
                    <button
                      key={star}
                      type="button"
                      onClick={() => setRating(star)}
                      onMouseEnter={() => setHoveredRating(star)}
                      onMouseLeave={() => setHoveredRating(0)}
                      className="p-1 transition-colors"
                    >
                      <Star
                        className={`h-6 w-6 ${
                          star <= (hoveredRating || rating)
                            ? "fill-yellow-400 text-yellow-400"
                            : "text-muted-foreground"
                        }`}
                      />
                    </button>
                  ))}
                </div>
              </div>

              <Button className="w-full">
                <Send className="h-4 w-4 mr-2" />
                Gửi phản hồi
              </Button>
            </CardContent>
          </Card>

          {/* Previous Feedbacks */}
          <Card>
            <CardHeader>
              <CardTitle>Phản hồi đã gửi</CardTitle>
              <CardDescription>
                Lịch sử các phản hồi của bạn
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="p-4 rounded-lg border">
                <div className="flex items-start justify-between">
                  <div>
                    <h4 className="font-medium">Về dịch vụ vệ sinh</h4>
                    <p className="text-sm text-muted-foreground mt-1">
                      Dịch vụ vệ sinh rất tốt, nhân viên làm việc chuyên nghiệp.
                    </p>
                  </div>
                  <span className="text-xs bg-green-500/10 text-green-500 px-2 py-1 rounded-full">
                    Đã xử lý
                  </span>
                </div>
                <div className="flex items-center gap-1 mt-2">
                  {[1, 2, 3, 4, 5].map((star) => (
                    <Star
                      key={star}
                      className={`h-4 w-4 ${
                        star <= 5
                          ? "fill-yellow-400 text-yellow-400"
                          : "text-muted-foreground"
                      }`}
                    />
                  ))}
                </div>
                <p className="text-xs text-muted-foreground mt-2">
                  Gửi lúc: 15/11/2025
                </p>
              </div>

              <div className="p-4 rounded-lg border">
                <div className="flex items-start justify-between">
                  <div>
                    <h4 className="font-medium">Đề xuất cải thiện bãi đỗ xe</h4>
                    <p className="text-sm text-muted-foreground mt-1">
                      Mong muốn tăng thêm chỗ đỗ xe ở tầng hầm B2.
                    </p>
                  </div>
                  <span className="text-xs bg-orange-500/10 text-orange-500 px-2 py-1 rounded-full">
                    Đang xử lý
                  </span>
                </div>
                <div className="flex items-center gap-1 mt-2">
                  {[1, 2, 3, 4, 5].map((star) => (
                    <Star
                      key={star}
                      className={`h-4 w-4 ${
                        star <= 4
                          ? "fill-yellow-400 text-yellow-400"
                          : "text-muted-foreground"
                      }`}
                    />
                  ))}
                </div>
                <p className="text-xs text-muted-foreground mt-2">
                  Gửi lúc: 10/11/2025
                </p>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </DashboardLayout>
  );
}
