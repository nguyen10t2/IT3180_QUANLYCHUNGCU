"use client";

import { ManagerSidebar } from "./manager-sidebar";
import { cn } from "@/lib/utils";

interface ManagerDashboardLayoutProps {
  children: React.ReactNode;
}

export function ManagerDashboardLayout({ children }: ManagerDashboardLayoutProps) {
  return (
    <div className="min-h-screen bg-background">
      <ManagerSidebar />
      <main className={cn("ml-64 min-h-screen transition-all duration-300")}>
        <div className="p-6">{children}</div>
      </main>
    </div>
  );
}
