import express from 'express';
import { register, login, logout, refreshToken, verifyOtp, resendOtp, forgetPass, resetPass } from '../controllers/authController.js';
import { verifyJWT, verifyRefreshToken } from '../middlewares/authMiddleware.js';

const router = express.Router();

router.post('/register', register);

router.post('/login', login);

router.post('/logout', logout);

router.post('/verify-otp', verifyOtp);

router.post('/resend-otp', resendOtp);

router.post('/forget-password', forgetPass);

router.post('/reset-password', resetPass);

// router.post('/change-password', verifyJWT, changePass);

router.post('/refresh', verifyRefreshToken, refreshToken);

export default router;