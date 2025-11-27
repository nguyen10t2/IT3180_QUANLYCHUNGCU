"use client";

import { useEffect, useState, useRef } from "react";
import { useRouter, usePathname } from "next/navigation";
import { useAuthStore } from "@/stores/useAuthStore";

export default function ProtectedLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const router = useRouter();
  const pathname = usePathname();
  const { loading, refreshTokenHandler, fetchMe } = useAuthStore();
  const [starting, setStarting] = useState(true);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const hasInitialized = useRef(false);

  useEffect(() => {
    const init = async () => {
      try {
        // Get latest state from store
        const currentState = useAuthStore.getState();
        const currentToken = currentState.accessToken;
        const currentUser = currentState.user;

        console.log(
          "ProtectedRoute init - current token:",
          currentToken ? "exists" : "null"
        );

        // If token exists (from localStorage), proceed
        if (currentToken) {
          setIsAuthenticated(true);

          // Fetch user if not available
          if (!currentUser) {
            await fetchMe();
          }
        } else {
          console.log("No token found, attempting refresh...");
          await refreshTokenHandler();

          // Check again after refresh
          const newState = useAuthStore.getState();
          if (newState.accessToken) {
            setIsAuthenticated(true);

            if (!newState.user) {
              await fetchMe();
            }
          } else {
            setIsAuthenticated(false);
          }
        }
      } catch (error) {
        console.error("Auth init error:", error);
        setIsAuthenticated(false);
      } finally {
        setStarting(false);
      }
    };

    // Skip auth check for auth pages
    if (
      pathname === "/signin" ||
      pathname === "/signup" ||
      pathname === "/forgot-password"
    ) {
      setStarting(false);
      return;
    }

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

  return <>{children}</>;
}
