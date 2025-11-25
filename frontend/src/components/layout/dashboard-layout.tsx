"use client";

import { Sidebar } from "@/components/layout/sidebar";
import { cn } from "@/lib/utils";

interface DashboardLayoutProps {
  children: React.ReactNode;
  className?: string;
}

export function DashboardLayout({ children, className }: DashboardLayoutProps) {
  return (
    <div className="min-h-screen bg-background">
      <Sidebar />
      <main
        className={cn(
          "ml-64 p-6 transition-all duration-300",
          // Handle collapsed sidebar
          "md:ml-64",
          className
        )}
      >
        {children}
      </main>
    </div>
  );
}
