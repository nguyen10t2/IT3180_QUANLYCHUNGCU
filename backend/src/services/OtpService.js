import { Otp } from '../models/Otp.js';
import argon2 from 'argon2';

const OTP_TTL = 10 * 60 * 1000;

export const OtpService = {
    generateOtp() {
        return Array.from({ length: 6 }, () => Math.floor(Math.random() * 10)).join('');
    },

    async createOtp() {
        const plain_otp = OtpService.generateOtp();
        const otp = await argon2.hash(plain_otp);
        const expires_at = new Date(Date.now() + OTP_TTL);
        return { plain_otp, otp, expires_at };
    },
};