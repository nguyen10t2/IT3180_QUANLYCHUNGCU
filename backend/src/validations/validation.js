import validator from 'validator';

export const validateEmail = (email) => {
    if (!email || !validator.isEmail(email)) {
        return { valid: false, message: 'Email không hợp lệ' };
    }
    return { valid: true };
};

export const validatePassword = (password) => {
    if (!password) {
        return { valid: false, message: 'Password không được để trống' };
    }
    if (password.length < 8) {
        return { valid: false, message: 'Password phải ít nhất 8 ký tự' };
    }
    if (!/[A-Z]/.test(password)) {
        return { valid: false, message: 'Password phải có ít nhất 1 chữ hoa' };
    }
    if (!/[a-z]/.test(password)) {
        return { valid: false, message: 'Password phải có ít nhất 1 chữ thường' };
    }
    if (!/[0-9]/.test(password)) {
        return { valid: false, message: 'Password phải có ít nhất 1 chữ số' };
    }
    if (!/[\W_]/.test(password)) {
        return { valid: false, message: 'Password phải có ít nhất 1 ký tự đặc biệt' };
    }
    return { valid: true };
};

export const validateFullname = (fullname) => {
    if (!fullname || fullname.trim().length < 2) {
        return { valid: false, message: 'Họ tên không hợp lệ' };
    }
    return { valid: true };
};

export const validatePhone = (phone) => {
    if (!phone || !validator.isMobilePhone(phone, 'vi-VN')) {
        return { valid: false, message: 'Số điện thoại không hợp lệ' };
    }
    return { valid: true };
};

export const validateOtp = (otp) => {
    if (!otp) {
        return { valid: false, message: 'OTP không được để trống' };
    }

    if (otp.length !== 6) {
        return { valid: false, message: 'OTP phải đủ 6 ký tự' };
    }

    if (!/^\d{6}$/.test(otp)) {
        return { valid: false, message: 'OTP chỉ được chứa số' };
    }

    return { valid: true };
};