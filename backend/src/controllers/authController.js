import argon2 from 'argon2';
import { User } from '../models/User.js';
import jwt from 'jsonwebtoken';
import crypto from 'crypto';
import { Session } from '../models/Session.js';
import { Otp } from '../models/Otp.js';
import { EmailService } from '../services/EmailService.js';
import { OtpService } from '../services/OtpService.js';
import { validateEmail, validatePassword, validateFullname, validateOtp } from '../validations/validation.js';
import { ResetToken } from '../models/ResetToken.js';

const ACCESS_TOKEN_TTL = '15m';
const REFRESH_TOKEN_TTL = 7 * 24 * 3600 * 1000;
const RESET_TOKEN_TTL = 10 * 60 * 1000;

export const register = async (req, res) => {
    try {
        const { email, password, fullname } = req.body;

        let check = validateEmail(email);
        if (!check.valid) return res.status(400).json({ message: check.message });
        check = validatePassword(password);
        if (!check.valid) return res.status(400).json({ message: check.message });
        check = validateFullname(fullname);
        if (!check.valid) return res.status(400).json({ message: check.message });

        const duplicate = await User.isExists({ email: email });
        if (duplicate) {
            return res.status(409).json({
                message: 'Email đã tồn tại'
            });
        }

        const password_hash = await argon2.hash(password);

        await User.create({ email, password_hash, fullname });

        const { plain_otp, otp, expires_at } = await OtpService.createOtp();

        const insert = await Otp.create({
            email: email,
            otp: otp,
            expires_at: expires_at,
        });
        if (!insert) {
            return res.status(500).json({ message: 'Lỗi khi tạo OTP' });
        }

        res.status(200).json({ message: 'Đăng kí thành công' });

        (async () => {
            try {
                await new EmailService().sendOtpEmail(email, plain_otp);
                console.log(`Gửi OTP đến ${email}`);
            } catch (err) {
                console.error(`Lỗi khi gửi OTP:`, err);
            }
        })();
    } catch (error) {
        console.error('Lỗi khi gọi resgister', error);
        return res.status(500).json({ message: 'Lỗi hệ thống' });
    }
};

export const login = async (req, res) => {
    try {
        const { email, password } = req.body;

        let check = validateEmail(email);
        if (!check.valid) return res.status(400).json({ message: check.message });
        check = validatePassword(password);
        if (!check.valid) return res.status(400).json({ message: check.message });

        const user = await User.findOne({ email: email });
        if (!user) {
            return res.status(401).json({
                message: 'Email hoặc mật khẩu không đúng'
            });
        }

        const match = await argon2.verify(user.password_hash, password);

        if (!match) {
            return res.status(401).json({
                message: 'Email hoặc mật khẩu không đúng'
            });
        }

        const access_token = jwt.sign(
            { user_id: user.user_id, user_role: user.role },
            process.env.ACCESS_TOKEN_SECRET,
            { expiresIn: ACCESS_TOKEN_TTL }
        );

        const refresh_token = crypto.randomBytes(64).toString('hex');
        await Session.create({
            user_id: user.user_id,
            refresh_token,
            expires_at: new Date(Date.now() + REFRESH_TOKEN_TTL),
        });

        res.cookie('refresh_token', refresh_token, {
            httpOnly: true,
            secure: true,
            sameSite: "none",
            maxAge: REFRESH_TOKEN_TTL,
        });

        return res.status(200).json({ message: 'Đăng nhập thành công', access_token });

    } catch (error) {
        console.error('Lỗi khi gọi login', error);
        return res.status(500).json({ message: 'Lỗi hệ thống' });
    }
};

export const logout = async (req, res) => {
    try {
        const token = req.cookies?.refresh_token;

        if (token) {
            await Session.deleteOne({ refresh_token: token });
            res.clearCookie('refresh_token');
        }

        console.log('Đăng xuất thành công');
        

        return res.sendStatus(204);
    } catch (error) {
        console.error('Lỗi khi gọi logout', error);
        return res.status(500).json({ message: 'Lỗi hệ thống' });
    }
};

export const refreshToken = async (req, res) => {
    try {
        const session = req.session;

        const user = await User.findUserById({ user_id: session.user_id });
        if (!user) return res.status(404).json({ message: 'User không tồn tại' });

        const access_token = jwt.sign(
            { user_id: user.user_id, user_role: user.role },
            process.env.ACCESS_TOKEN_SECRET,
            { expiresIn: '15m' }
        );

        return res.status(200).json({ access_token });
    } catch (error) {
        console.error('Lỗi khi gọi refresh token', error);
        return res.status(500).json({ message: 'Lỗi hệ thống' });
    }
};

export const verifyOtp = async (req, res) => {
    const { email, otp } = req.body;

    let check = validateEmail(email);
    if (!check.valid) return res.status(400).json({ message: check.message });
    check = validateOtp(otp);
    if (!check.valid) return res.status(400).json({ message: check.message });

    try {
        const [user, otp_record] = await Promise.all([
            User.isExists({ email }),
            Otp.getOTPRecord({ email })
        ]);

        if (!user) {
            return res.status(400).json({ message: 'Email không tồn tại hoặc đã được xác thực' });
        }

        if (!otp_record) {
            return res.status(400).json({ message: 'Không tìm thấy OTP hợp lệ cho email này' });
        }
        const { stored_otp, expires_at } = otp_record;

        if (new Date() > expires_at) {
            return res.status(400).json({ message: 'OTP không hợp lệ hoặc đã hết hạn' });
        }

        const otp_valid = await argon2.verify(stored_otp, otp);
        if (!otp_valid) {
            return res.status(401).json({ message: 'OTP không hợp lệ hoặc đã hết hạn' });
        }

        await Promise.all([
            User.verifyUser({ email }),
            Otp.updateOTP({ email }),
        ]);

        return res.status(200).json({
            message: 'Xác thực thành công',
            email,
        });
    } catch (error) {
        console.error('Lỗi khi gọi verifyOtp', error);
        return res.status(500).json({ message: 'Lỗi hệ thống' });
    }
};

export const resendOtp = async (req, res) => {
    try {
        const { email } = req.body;

        let check = validateEmail(email);
        if (!check.valid) return res.status(400).json({ message: check.message });

        const user = await User.isExists({ email: email });
        if (!user) {
            return res.status(400).json({ message: 'Email không tồn tại hoặc đã xác thực' });
        }

        const last_otp_time = await Otp.getLastOTP({ email: email });
        if (!last_otp_time) {
            return res.status(500).json({ message: 'Lỗi hệ thống' });
        }

        const elapsed = Math.floor((Date.now() - last_otp_time) / 1000);
        if (elapsed < 30) {
            return res.status(429).json({
                message: 'Hãy đợi trước khi làm mới OTP',
                retry_after: 30 - elapsed
            });
        }

        const resend_count = await Otp.resendCount({ email: email });
        if (resend_count >= 5) {
            return res.status(429).json({ message: 'Quá nhiều yêu cầu. Thử lại ý phút nữa' });
        }

        const { plain_otp, otp, expires_at } = await OtpService.createOtp();

        const insert = await Otp.create({
            email: email,
            otp: otp,
            expires_at: expires_at,
        });
        if (!insert) {
            return res.status(500).json({ message: 'Lỗi khi tạo OTP' });
        }

        res.status(200).json({ message: 'Đã gửi lại OTP' });

        (async () => {
            try {
                await new EmailService().sendOtpEmail(email, plain_otp);
                console.log(`Gửi OTP đến ${email}`);
            } catch (err) {
                console.error(`Lỗi khi gửi OTP:`, err);
            }
        })();
    } catch (error) {
        console.error('Lỗi khi gọi resendOtp', error);
        return res.status(500).json({ message: 'Lỗi hệ thống' });
    }
};

export const forgetPass = async (req, res) => {
    try {
        const { email } = req.body;

        let check = validateEmail(email);
        if (!check.valid) return res.status(400).json({ message: check.message });

        const { plain_otp, otp, expires_at } = await OtpService.createOtp();

        await Otp.create({
            email: email,
            otp: otp,
            expires_at: expires_at,
        });

        const reset_token = crypto.randomBytes(64).toString('hex');
        await ResetToken.create({
            email: email,
            reset_token: reset_token,
            expires_at: new Date(Date.now() + RESET_TOKEN_TTL)
        });
        res.cookie('reset_token', reset_token, {
            httpOnly: true,
            secure: true,
            sameSite: "none",
            maxAge: RESET_TOKEN_TTL,
        });

        (async () => {
            try {
                await new EmailService().sendOtpEmail(email, plain_otp);
                console.log(`Gửi OTP đến ${email}`);
            } catch (err) {
                console.error(`Lỗi khi gửi OTP:`, err);
            }
        })();

        return res.status(200).json({ message: 'Đã gửi OTP' });
    } catch (error) {
        console.error('Lỗi khi gọi forgetPass', error);
        return res.status(500).json({ message: 'Lỗi hệ thống' });
    }
};

export const resetPass = async (req, res) => {
    try {
        const { email, new_password } = req.body;
        
        const reset_token = req.cookies?.reset_token;

        const tokenData = await ResetToken.findOne({ email, reset_token });
        if (!tokenData || tokenData.expires_at < new Date()) {
            return res.status(400).json({ message: 'Token không hợp lệ hoặc đã hết hạn' });
        }

        let check = validateEmail(email);
        if (!check.valid) return res.status(400).json({ message: check.message });
        check = validatePassword(new_password);
        if (!check.valid) return res.status(400).json({ message: check.message });

        const password_hash = await argon2.hash(new_password);
        await User.updateUser({ email: email, new_password: password_hash });
        await ResetToken.deleteOne({ email: email });
        console.log('Đã xoá reset token sau khi đổi mật khẩu thành công');
        
        

        res.clearCookie('reset_token', {
            httpOnly: true,
            secure: true,
            sameSite: 'none'
        });

        return res.status(200).json({ message: 'Cập nhật tài khoản thành công' });
    } catch (error) {
        console.error('Lỗi khi gọi reset password', error);
        return res.status(500).json({ message: 'Lỗi hệ thống' });
    }
};
