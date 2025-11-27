"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { useAuthStore } from "@/stores/useAuthStore";

export default function Home() {
  const router = useRouter();
  const { user, accessToken, fetchMe } = useAuthStore();

  useEffect(() => {
    const checkAuth = async () => {
      if (accessToken) {
        // If we have token but no user, fetch user info
        if (!user) {
          await fetchMe();
        }
        
        const currentUser = useAuthStore.getState().user;
        
        // Redirect based on role
        if (currentUser?.role === "manager" || currentUser?.role === "admin") {
          router.replace("/manager/dashboard");
        } else {
          router.replace("/resident/home");
        }
      } else {
        router.replace("/signin");
      }
    };

    checkAuth();
  }, [accessToken, user, fetchMe, router]);

  return (
    <div className="flex h-screen items-center justify-center bg-background">
      <div className="flex flex-col items-center gap-4">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent" />
        <p className="text-muted-foreground">Đang chuyển hướng...</p>
      </div>
    </div>
  );
}
