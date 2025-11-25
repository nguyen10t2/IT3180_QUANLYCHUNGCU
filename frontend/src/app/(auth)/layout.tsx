import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Đăng nhập - Kogu Express",
  description: "Đăng nhập vào hệ thống quản lý chung cư Kogu Express",
};

export default function AuthLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="min-h-screen bg-gradient-purple flex items-center justify-center p-4">
      <div className="w-full max-w-4xl animate-fade-in">{children}</div>
    </div>
  );
}
