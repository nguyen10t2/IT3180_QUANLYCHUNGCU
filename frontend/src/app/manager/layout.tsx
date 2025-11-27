"use client";

import { useEffect, useState, useRef } from "react";
import { useRouter, usePathname } from "next/navigation";
import { useAuthStore } from "@/stores/useAuthStore";

export default function ManagerLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const router = useRouter();
  const pathname = usePathname();
  const { loading, refreshTokenHandler, fetchMe, user } = useAuthStore();
  const [starting, setStarting] = useState(true);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [isAuthorized, setIsAuthorized] = useState(false);
  const hasInitialized = useRef(false);

  useEffect(() => {
    const init = async () => {
      try {
        const currentState = useAuthStore.getState();
        const currentToken = currentState.accessToken;
        let currentUser = currentState.user;

        if (currentToken) {
          setIsAuthenticated(true);

          if (!currentUser) {
            await fetchMe();
            currentUser = useAuthStore.getState().user;
          }
        } else {
          await refreshTokenHandler();

          const newState = useAuthStore.getState();
          if (newState.accessToken) {
            setIsAuthenticated(true);
            if (!newState.user) {
              await fetchMe();
            }
            currentUser = useAuthStore.getState().user;
          } else {
            setIsAuthenticated(false);
          }
        }

        // Check if user has manager or admin role
        if (currentUser && (currentUser.role === 'manager' || currentUser.role === 'admin')) {
          setIsAuthorized(true);
        } else {
          setIsAuthorized(false);
        }
      } catch (error) {
        console.error("Auth init error:", error);
        setIsAuthenticated(false);
        setIsAuthorized(false);
      } finally {
        setStarting(false);
      }
    };

    if (hasInitialized.current) {
      return;
    }

    hasInitialized.current = true;
    init();
  }, [pathname, refreshTokenHandler, fetchMe]);

  // Loading state
  if (starting || loading) {
    return (
      <div className="flex h-screen items-center justify-center bg-background">
        <div className="flex flex-col items-center gap-4">
          <div className="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent" />
          <p className="text-muted-foreground">Đang tải trang...</p>
        </div>
      </div>
    );
  }

  // Not authenticated
  if (!isAuthenticated) {
    router.replace("/signin");
    return null;
  }

  // Not authorized (not manager/admin)
  if (!isAuthorized) {
    return (
      <div className="flex h-screen items-center justify-center bg-background">
        <div className="flex flex-col items-center gap-4 text-center max-w-md p-8">
          <div className="p-4 rounded-full bg-red-500/10">
            <svg 
              xmlns="http://www.w3.org/2000/svg" 
              className="h-12 w-12 text-red-500" 
              fill="none" 
              viewBox="0 0 24 24" 
              stroke="currentColor"
            >
              <path 
                strokeLinecap="round" 
                strokeLinejoin="round" 
                strokeWidth={2} 
                d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" 
              />
            </svg>
          </div>
          <h1 className="text-2xl font-bold">Không có quyền truy cập</h1>
          <p className="text-muted-foreground">
            Bạn không có quyền truy cập vào khu vực quản lý. 
            Vui lòng liên hệ quản trị viên nếu bạn cho rằng đây là lỗi.
          </p>
          <button
            onClick={() => router.push("/resident/home")}
            className="mt-4 px-6 py-2 bg-primary text-primary-foreground rounded-lg hover:bg-primary/90 transition-colors"
          >
            Quay về trang chủ
          </button>
        </div>
      </div>
    );
  }

  return <>{children}</>;
}
