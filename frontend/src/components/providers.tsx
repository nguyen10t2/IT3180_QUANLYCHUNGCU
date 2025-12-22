"use client";

import { useEffect, type ReactNode } from "react";
import { ThemeProvider as NextThemesProvider } from "next-themes";
import { useAuthStore } from "@/stores/useAuthStore";

interface ProvidersProps {
  children: ReactNode;
}

export function Providers({ children }: ProvidersProps) {

  return (
    <NextThemesProvider
      attribute="class"
      defaultTheme="system"
      enableSystem
      disableTransitionOnChange
    >
      {children}
    </NextThemesProvider>
  );
}
