import api from "@/lib/axios";

export interface VerifyOtpPayload {
  email: string;
  otp: string;
}

export interface ResendOtpPayload {
  email: string;
}

export const otpService = {
  verifyOtp: async (payload: VerifyOtpPayload) => {
    const res = await api.post("/api/auth/verify-otp", payload);
    return res.data;
  },

  resendOtp: async (payload: ResendOtpPayload) => {
    const res = await api.post("/api/auth/resend-otp", payload);
    return res.data;
  },
};

export default otpService;
