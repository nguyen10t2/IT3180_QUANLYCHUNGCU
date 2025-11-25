// services/EmailService.js
import nodemailer from 'nodemailer';

export class EmailService {
    constructor() {
        this.smtpEmail = process.env.SMTP_EMAIL;
        this.smtpPassword = process.env.SMTP_PASSWORD;
        this.appUrl = process.env.FRONTEND_URL;

        this.transporter = nodemailer.createTransport({
            service: 'gmail',
            auth: {
                user: this.smtpEmail,
                pass: this.smtpPassword,
            },
            pool: true,
        });
    }

    async sendOtpEmail(to, otp) {
        const htmlBody = `
            <h2>Xác thực email của bạn</h2>
            <p>Mã OTP của bạn là: <strong>${otp}</strong></p>
            <p>Hoặc nhấn <a href="${this.appUrl}/register/otp">vào đây</a> để xác nhận</p>
            <p>OTP của bạn sẽ hết hạn trong 10 phút</p>
        `;

        const mailOptions = {
            from: `"KOGU" <${this.smtpEmail}>`,
            to,
            subject: 'Mã OTP',
            text: `Mã OTP của bạn: ${otp}`,
            html: htmlBody,
        };

        try {
            await this.transporter.sendMail(mailOptions);
            console.log(`OTP đã được gửi đén ${to}`);
        } catch (error) {
            console.error('Lỗi khi gửi OTP:', error);
            throw new Error('Lỗi khi gửi OTP');
        }
    }
}
