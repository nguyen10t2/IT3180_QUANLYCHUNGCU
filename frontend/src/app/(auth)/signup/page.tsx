"use client";

import { SignUpForm } from "@/components/auth/signup-form";
import { useAuthStore } from "@/stores/useAuthStore";
import { useRouter } from "next/navigation";
import type { SignUpFormValues } from "@/lib/validations/auth";

export default function SignUpPage() {
  const { signUp, loading } = useAuthStore();
  const router = useRouter();

  const handleSubmit = async (data: SignUpFormValues) => {
    try {
      await signUp(data.fullname, data.email, data.password, data.role);
      router.push("/otp");
    } catch {
      // Error is handled in the store with toast
    }
  };

  return <SignUpForm onSubmit={handleSubmit} isLoading={loading} />;
}
