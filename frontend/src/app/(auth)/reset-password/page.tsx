"use client";

import { ResetPasswordForm } from "@/components/auth/reset-password-form";
import { authService } from "@/services/authService";
import { useRouter } from "next/navigation";
import { useState, useEffect } from "react";
import { toast } from "sonner";
import type { ResetPasswordFormValues } from "@/lib/validations/auth";

export default function ResetPasswordPage() {
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [email, setEmail] = useState<string | null>(null);

  useEffect(() => {
    // Get email from localStorage
    const storedEmail = localStorage.getItem("resetEmail");
    if (!storedEmail) {
      toast.error("Không tìm thấy email. Vui lòng thử lại từ đầu.");
      router.push("/forgot-password");
      return;
    }
    setEmail(storedEmail);
  }, [router]);

  const handleSubmit = async (data: ResetPasswordFormValues) => {
    if (!email) {
      toast.error("Không tìm thấy email. Vui lòng thử lại từ đầu.");
      router.push("/forgot-password");
      return;
    }

    try {
      setLoading(true);
      await authService.resetPassword(email, data.newPassword);

      // Clear reset email from localStorage
      localStorage.removeItem("resetEmail");

      toast.success("Đặt lại mật khẩu thành công! Vui lòng đăng nhập.");
      router.push("/signin");
    } catch (err: unknown) {
      console.error("Reset password error:", err);
      const error = err as {
        response?: { data?: { message?: string; error?: string } };
      };
      const errorMessage =
        error.response?.data?.message ||
        error.response?.data?.error ||
        "Có lỗi xảy ra. Vui lòng thử lại.";
      toast.error(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  if (!email) {
    return (
      <div className="flex items-center justify-center">
        <p>Đang tải...</p>
      </div>
    );
  }

  return <ResetPasswordForm onSubmit={handleSubmit} isLoading={loading} />;
}
