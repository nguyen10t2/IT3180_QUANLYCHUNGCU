"use client";

import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import {
  InputOTP,
  InputOTPGroup,
  InputOTPSlot,
  InputOTPSeparator,
} from "@/components/ui/input-otp";
import { Label } from "@/components/ui/label";
import { useRouter } from "next/navigation";
import { useState } from "react";
import otpService from "@/services/otpService";
import { authService } from "@/services/authService";
import { toast } from "sonner";
import Image from "next/image";
import Link from "next/link";

type OTPFormProps = {
  mode?: "signup" | "reset";
  className?: string;
};

export function OTPForm({ className, mode = "signup" }: OTPFormProps) {
  const router = useRouter();
  const [otp, setOtp] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  // Get email key and messages based on mode
  const emailKey = mode === "signup" ? "signupEmail" : "resetEmail";
  const errorMessage =
    mode === "signup"
      ? "Không tìm thấy email đăng ký. Vui lòng quay lại trang đăng ký."
      : "Không tìm thấy email. Vui lòng quay lại trang quên mật khẩu.";
  const successRoute = mode === "signup" ? "/signin" : "/reset-password";

  const onSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setError("");
    setLoading(true);

    // Get email from localStorage
    const email = localStorage.getItem(emailKey) || "";
    if (!email) {
      setError(errorMessage);
      setLoading(false);
      return;
    }

    // Validate OTP
    if (!otp || otp.length !== 6) {
      setError("Vui lòng nhập đầy đủ mã 6 chữ số");
      setLoading(false);
      return;
    }

    try {
      // Call service based on mode
      const resp =
        mode === "signup"
          ? await otpService.verifyOtp({ email, otp })
          : await authService.verifyOtpForReset(email, otp);

      toast.success(resp.message || "Xác thực thành công");

      // Only remove email on signup success
      if (mode === "signup") {
        localStorage.removeItem(emailKey);
      }

      router.push(successRoute);
    } catch (err: unknown) {
      const error = err as { response?: { data?: { message?: string } } };
      const errMsg =
        error.response?.data?.message || "Xác thực không thành công";
      setError(errMsg);
      toast.error(errMsg);
      setLoading(false);
    }
  };

  const onResend = async (e: React.MouseEvent) => {
    e.preventDefault();
    setError("");
    setLoading(true);

    const email = localStorage.getItem(emailKey) || "";
    if (!email) {
      setError(errorMessage);
      setLoading(false);
      return;
    }

    try {
      // Call service based on mode
      const resp =
        mode === "signup"
          ? await otpService.resendOtp({ email })
          : await authService.forgetPassword(email);

      toast.success(resp.message || "Mã OTP đã được gửi lại");
    } catch (err: unknown) {
      console.error("Resend OTP error", err);

      const error = err as {
        response?: {
          status?: number;
          data?: { retry_after?: number; error?: string; message?: string };
        };
        message?: string;
      };

      // Handle rate limit (429)
      if (error?.response?.status === 429) {
        const retryAfter = error?.response?.data?.retry_after;
        const msg = retryAfter
          ? `Vui lòng đợi ${retryAfter} giây trước khi gửi lại OTP`
          : error?.response?.data?.error ||
            "Bạn đang gửi yêu cầu quá nhanh. Vui lòng đợi một chút.";
        toast.error(msg);
        return;
      }

      const msg =
        error?.response?.data?.error ||
        error?.message ||
        "Lỗi khi gửi lại mã OTP";
      toast.error(msg);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className={cn("flex flex-col gap-6 md:min-h-[450px]", className)}>
      <Card className="flex-1 overflow-hidden p-0">
        <CardContent className="grid flex-1 p-0 md:grid-cols-2">
          <form
            className="flex flex-col items-center justify-center p-6 md:p-8"
            onSubmit={onSubmit}
          >
            <div className="flex flex-col items-center gap-6 w-full max-w-sm">
              {/* Header */}
              <div className="flex flex-col items-center text-center gap-2">
                <Link href="/" className="mx-auto block w-fit text-center">
                  <Image
                    src="/logo.svg"
                    alt="logo"
                    width={64}
                    height={64}
                    priority
                  />
                </Link>
                <h1 className="text-3xl font-bold">Nhập mã xác thực</h1>
                <p className="text-muted-foreground text-sm text-balance">
                  Chúng tôi đã gửi mã 6 chữ số đến email của bạn
                </p>
              </div>

              {/* OTP Input */}
              <div className="space-y-2 w-full flex flex-col items-center">
                <Label htmlFor="otp" className="sr-only">
                  Verification code
                </Label>
                <InputOTP
                  maxLength={6}
                  id="otp"
                  name="otp"
                  value={otp}
                  onChange={(value) => setOtp(value)}
                  containerClassName="gap-2"
                >
                  <InputOTPGroup>
                    <InputOTPSlot index={0} />
                    <InputOTPSlot index={1} />
                    <InputOTPSlot index={2} />
                  </InputOTPGroup>
                  <InputOTPSeparator />
                  <InputOTPGroup>
                    <InputOTPSlot index={3} />
                    <InputOTPSlot index={4} />
                    <InputOTPSlot index={5} />
                  </InputOTPGroup>
                </InputOTP>

                {error && (
                  <p className="text-destructive text-sm text-center">
                    {error}
                  </p>
                )}

                <p className="text-sm text-muted-foreground">
                  Không nhận được mã?{" "}
                  <button
                    type="button"
                    onClick={onResend}
                    disabled={loading}
                    className="text-primary underline underline-offset-4 hover:text-primary/80"
                  >
                    Gửi lại
                  </button>
                </p>
              </div>

              {/* Submit Button */}
              <Button type="submit" className="w-full" disabled={loading}>
                {loading ? "Đang xác thực..." : "Xác thực"}
              </Button>

              {/* Back Link */}
              <div className="text-center text-sm">
                <Link
                  href={mode === "signup" ? "/signup" : "/forgot-password"}
                  className="underline underline-offset-4"
                >
                  Quay lại
                </Link>
              </div>
            </div>
          </form>

          {/* Right side image */}
          <div className="relative hidden bg-muted md:block">
            <Image
              src="/placeholder.png"
              alt="Image"
              fill
              className="object-cover"
              priority
              unoptimized
            />
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
