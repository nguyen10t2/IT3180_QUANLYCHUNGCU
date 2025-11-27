"use client";

import Link from "next/link";
import Image from "next/image";
import { usePathname, useRouter } from "next/navigation";
import {
  Home,
  Users,
  Building2,
  FileText,
  UserCheck,
  LogOut,
  Settings,
  ChevronLeft,
  ChevronRight,
  Bell,
  MessageSquare,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { useAuthStore } from "@/stores/useAuthStore";
import { useState } from "react";

const navigationItems = [
  {
    name: "Tổng quan",
    href: "/manager/dashboard",
    icon: Home,
  },
  {
    name: "Quản lý người dùng",
    href: "/manager/users",
    icon: Users,
  },
  {
    name: "Quản lý hộ gia đình",
    href: "/manager/households",
    icon: Building2,
  },
  {
    name: "Quản lý cư dân",
    href: "/manager/residents",
    icon: UserCheck,
  },
  {
    name: "Quản lý hóa đơn",
    href: "/manager/invoices",
    icon: FileText,
  },
  {
    name: "Thông báo",
    href: "/manager/notifications",
    icon: Bell,
  },
  {
    name: "Phản hồi",
    href: "/manager/feedbacks",
    icon: MessageSquare,
  },
];

export function ManagerSidebar() {
  const pathname = usePathname();
  const router = useRouter();
  const { user, signOut } = useAuthStore();
  const [collapsed, setCollapsed] = useState(false);

  const handleSignOut = async () => {
    await signOut();
    router.push("/signin");
  };

  const getInitials = (name: string) => {
    return name
      .split(" ")
      .map((n) => n[0])
      .join("")
      .toUpperCase()
      .slice(0, 2);
  };

  return (
    <aside
      className={cn(
        "fixed left-0 top-0 h-screen bg-sidebar border-r border-sidebar-border flex flex-col transition-all duration-300",
        collapsed ? "w-20" : "w-64"
      )}
    >
      {/* Logo */}
      <div className="p-4 border-b border-sidebar-border flex items-center justify-between">
        <Link href="/manager/dashboard" className="flex items-center gap-3">
          <Image
            src="/logo.svg"
            alt="Building Logo"
            width={40}
            height={40}
            className="shrink-0"
          />
          {!collapsed && (
            <div>
              <span className="font-heading font-semibold text-lg text-sidebar-foreground">
                Kogu
              </span>
              <span className="text-xs text-orange-500 ml-1 font-medium">Manager</span>
            </div>
          )}
        </Link>
        <Button
          variant="ghost"
          size="icon"
          onClick={() => setCollapsed(!collapsed)}
          className="hidden md:flex"
        >
          {collapsed ? (
            <ChevronRight className="h-4 w-4" />
          ) : (
            <ChevronLeft className="h-4 w-4" />
          )}
        </Button>
      </div>

      {/* Navigation */}
      <nav className="flex-1 p-4 space-y-2 overflow-y-auto">
        {navigationItems.map((item) => {
          const isActive = pathname === item.href || pathname.startsWith(item.href + "/");
          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                "flex items-center gap-3 px-4 py-3 rounded-lg transition-colors",
                isActive
                  ? "bg-sidebar-accent text-sidebar-accent-foreground font-medium"
                  : "text-sidebar-foreground hover:bg-sidebar-accent hover:text-sidebar-accent-foreground",
                collapsed && "justify-center px-2"
              )}
              title={collapsed ? item.name : undefined}
            >
              <item.icon className="w-5 h-5 shrink-0" />
              {!collapsed && <span>{item.name}</span>}
            </Link>
          );
        })}
      </nav>

      {/* User Section */}
      <div className="p-4 border-t border-sidebar-border">
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <button
              className={cn(
                "flex items-center gap-3 w-full p-2 rounded-lg hover:bg-sidebar-accent transition-colors",
                collapsed && "justify-center"
              )}
            >
              <Avatar className="h-9 w-9 shrink-0">
                <AvatarImage src="" alt={user?.fullname || "User"} />
                <AvatarFallback className="bg-orange-500 text-white">
                  {user?.fullname ? getInitials(user.fullname) : "M"}
                </AvatarFallback>
              </Avatar>
              {!collapsed && (
                <div className="flex-1 text-left min-w-0">
                  <p className="text-sm font-medium text-sidebar-foreground truncate">
                    {user?.fullname || "Manager"}
                  </p>
                  <p className="text-xs text-orange-500 truncate">
                    {user?.role === "admin" ? "Quản trị viên" : "Quản lý"}
                  </p>
                </div>
              )}
            </button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end" className="w-56">
            <DropdownMenuLabel>Tài khoản quản lý</DropdownMenuLabel>
            <DropdownMenuSeparator />
            <DropdownMenuItem asChild>
              <Link href="/manager/settings" className="flex items-center gap-2">
                <Settings className="h-4 w-4" />
                <span>Cài đặt</span>
              </Link>
            </DropdownMenuItem>
            <DropdownMenuSeparator />
            <DropdownMenuItem
              onClick={handleSignOut}
              className="text-destructive focus:text-destructive"
            >
              <LogOut className="h-4 w-4 mr-2" />
              <span>Đăng xuất</span>
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
    </aside>
  );
}
