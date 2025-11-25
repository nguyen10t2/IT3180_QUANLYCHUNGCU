"use client";

import { ForgotPasswordForm } from "@/components/auth/forgot-password-form";
import { authService } from "@/services/authService";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { toast } from "sonner";

export default function ForgotPasswordPage() {
  const router = useRouter();
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (email: string) => {
    try {
      setLoading(true);
      await authService.forgetPassword(email);

      // Save email for OTP verification
      localStorage.setItem("resetEmail", email);

      toast.success("Mã OTP đã được gửi đến email của bạn");
      router.push("/verify-otp-reset");
    } catch (err: unknown) {
      console.error("Forgot password error:", err);
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

  return <ForgotPasswordForm onSubmit={handleSubmit} isLoading={loading} />;
}
