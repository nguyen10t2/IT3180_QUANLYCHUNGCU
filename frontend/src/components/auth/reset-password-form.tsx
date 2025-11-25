"use client";

import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { resetPasswordSchema } from "@/lib/validations/auth";
import type { ResetPasswordFormValues } from "@/lib/validations/auth";
import Link from "next/link";
import Image from "next/image";

type ResetPasswordFormProps = {
  onSubmit: (data: ResetPasswordFormValues) => Promise<void>;
  isLoading?: boolean;
  className?: string;
};

export function ResetPasswordForm({
  className,
  onSubmit,
  isLoading = false,
}: ResetPasswordFormProps) {
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<ResetPasswordFormValues>({
    resolver: zodResolver(resetPasswordSchema),
  });

  return (
    <div className={cn("flex flex-col gap-6", className)}>
      <Card className="overflow-hidden p-0 border-border">
        <CardContent className="grid p-0 md:grid-cols-2">
          <form
            className="p-4 md:p-6 w-full"
            onSubmit={handleSubmit(onSubmit)}
          >
            <div className="flex flex-col gap-4">
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
                <h1 className="text-2xl font-bold">Đặt lại mật khẩu</h1>
                <p className="text-muted-foreground text-balance text-sm">
                  Nhập mật khẩu mới của bạn
                </p>
              </div>

              {/* New Password Input */}
              <div className="grid grid-cols-1 gap-2">
                <div className="space-y-2">
                  <Label htmlFor="newPassword" className="block text-sm">
                    Mật khẩu mới
                  </Label>
                  <Input
                    type="password"
                    id="newPassword"
                    placeholder="••••••••"
                    {...register("newPassword")}
                    disabled={isLoading}
                  />
                  {errors.newPassword && (
                    <p className="text-destructive text-sm">
                      {errors.newPassword.message}
                    </p>
                  )}
                </div>
              </div>

              {/* Confirm Password Input */}
              <div className="grid grid-cols-1 gap-2">
                <div className="space-y-2">
                  <Label htmlFor="confirmPassword" className="block text-sm">
                    Xác nhận mật khẩu
                  </Label>
                  <Input
                    type="password"
                    id="confirmPassword"
                    placeholder="••••••••"
                    {...register("confirmPassword")}
                    disabled={isLoading}
                  />
                  {errors.confirmPassword && (
                    <p className="text-destructive text-sm">
                      {errors.confirmPassword.message}
                    </p>
                  )}
                </div>
              </div>

              {/* Submit Button */}
              <Button type="submit" className="w-full" disabled={isLoading}>
                {isLoading ? "Đang xử lý..." : "Đặt lại mật khẩu"}
              </Button>

              {/* Back to Sign In */}
              <div className="text-center text-sm">
                <Link href="/signin" className="underline underline-offset-4">
                  Quay lại đăng nhập
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
