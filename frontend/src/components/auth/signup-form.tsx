"use client";

import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { signUpSchema } from "@/lib/validations/auth";
import type { SignUpFormValues } from "@/lib/validations/auth";
import Link from "next/link";
import Image from "next/image";

type SignUpFormProps = {
  onSubmit: (data: SignUpFormValues) => Promise<void>;
  isLoading?: boolean;
  className?: string;
};

export function SignUpForm({
  className,
  onSubmit,
  isLoading = false,
}: SignUpFormProps) {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<SignUpFormValues>({
    resolver: zodResolver(signUpSchema),
    defaultValues: {
      role: "resident",
    },
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
              {/* Header - Logo */}
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
                <h1 className="text-2xl font-bold">Tạo tài khoản Kogu</h1>
              </div>

              {/* Fullname */}
              <div className="grid grid-cols-1 gap-2">
                <div className="space-y-2">
                  <Label htmlFor="fullname" className="block text-sm">
                    Họ và tên
                  </Label>
                  <Input
                    type="text"
                    id="fullname"
                    placeholder="Nguyễn Văn Kogu"
                    {...register("fullname")}
                  />
                  {errors.fullname && (
                    <p className="text-destructive text-sm">
                      {errors.fullname.message}
                    </p>
                  )}
                </div>
              </div>

              {/* Email */}
              <div className="grid grid-cols-1 gap-2">
                <div className="space-y-2">
                  <Label htmlFor="email" className="block text-sm">
                    Tài khoản email
                  </Label>
                  <Input
                    type="email"
                    id="email"
                    placeholder="kogu@kogu.com"
                    {...register("email")}
                  />
                  {errors.email && (
                    <p className="text-destructive text-sm">
                      {errors.email.message}
                    </p>
                  )}
                </div>
              </div>

              {/* Password */}
              <div className="grid grid-cols-1 gap-2">
                <div className="space-y-2">
                  <Label htmlFor="password" className="block text-sm">
                    Mật khẩu
                  </Label>
                  <Input
                    type="password"
                    id="password"
                    placeholder="••••••••"
                    {...register("password")}
                  />
                  {errors.password && (
                    <p className="text-destructive text-sm">
                      {errors.password.message}
                    </p>
                  )}
                </div>
              </div>

              {/* Submit Button */}
              <Button
                type="submit"
                className="w-full"
                disabled={isSubmitting || isLoading}
              >
                {isSubmitting || isLoading
                  ? "Đang tạo tài khoản..."
                  : "Tạo tài khoản"}
              </Button>

              <div className="text-center text-sm">
                Đã có tài khoản?{" "}
                <Link href="/signin" className="underline underline-offset-4">
                  Đăng nhập
                </Link>
              </div>
            </div>
          </form>

          <div className="bg-muted relative hidden md:block">
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

      <div className="text-xs text-balance px-6 text-center text-muted-foreground">
        Bằng cách tiếp tục, bạn đồng ý với{" "}
        <Link href="#" className="underline underline-offset-4 hover:text-primary">
          Điều khoản dịch vụ
        </Link>{" "}
        và{" "}
        <Link href="#" className="underline underline-offset-4 hover:text-primary">
          Chính sách bảo mật của chúng tôi
        </Link>
        .
      </div>
    </div>
  );
}
