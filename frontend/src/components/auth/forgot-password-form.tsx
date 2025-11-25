"use client";

import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { forgotPasswordSchema } from "@/lib/validations/auth";
import type { ForgotPasswordFormValues } from "@/lib/validations/auth";
import Link from "next/link";
import Image from "next/image";

type ForgotPasswordFormProps = {
  onSubmit: (email: string) => Promise<void>;
  isLoading?: boolean;
  className?: string;
};

export function ForgotPasswordForm({
  className,
  onSubmit,
  isLoading = false,
}: ForgotPasswordFormProps) {
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<ForgotPasswordFormValues>({
    resolver: zodResolver(forgotPasswordSchema),
  });

  const handleFormSubmit = async (data: ForgotPasswordFormValues) => {
    await onSubmit(data.email);
  };

  return (
    <div className={cn("flex flex-col gap-6", className)}>
      <Card className="overflow-hidden p-0 border-border">
        <CardContent className="grid p-0 md:grid-cols-2">
          <form
            className="p-4 md:p-6 w-full"
            onSubmit={handleSubmit(handleFormSubmit)}
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
                <h1 className="text-2xl font-bold">Quên mật khẩu?</h1>
                <p className="text-muted-foreground text-balance text-sm">
                  Nhập email của bạn để nhận mã xác thực
                </p>
              </div>

              {/* Email Input */}
              <div className="grid grid-cols-1 gap-2">
                <div className="space-y-2">
                  <Label htmlFor="email" className="block text-sm">
                    Email
                  </Label>
                  <Input
                    type="email"
                    id="email"
                    placeholder="kogu@example.com"
                    {...register("email")}
                    disabled={isLoading}
                  />
                  {errors.email && (
                    <p className="text-destructive text-sm">
                      {errors.email.message}
                    </p>
                  )}
                </div>
              </div>

              {/* Submit Button */}
              <Button type="submit" className="w-full" disabled={isLoading}>
                {isLoading ? "Đang gửi..." : "Gửi mã xác thực"}
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
