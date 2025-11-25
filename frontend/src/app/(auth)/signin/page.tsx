"use client";

import { SignInForm } from "@/components/auth/signin-form";
import { useAuthStore } from "@/stores/useAuthStore";
import { useRouter } from "next/navigation";
import type { SignInFormValues } from "@/lib/validations/auth";

export default function SignInPage() {
  const { signIn, loading } = useAuthStore();
  const router = useRouter();

  const handleSubmit = async (data: SignInFormValues) => {
    try {
      await signIn(data.email, data.password);
      router.push("/home");
    } catch {
      // Error is handled in the store with toast
    }
  };

  return <SignInForm onSubmit={handleSubmit} isLoading={loading} />;
}
