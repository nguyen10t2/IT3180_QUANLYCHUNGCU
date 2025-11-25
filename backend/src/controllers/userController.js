import { User } from "../models/User.js";

export const authMe = async (req, res) => {
    try {
        const user_id = req.user?.user_id;

        if (!user_id) {
            return res.status(400).json({ message: 'Không có quyền truy cập' });
        }

        const user = await User.findUserById({user_id: user_id});

        return res.status(200).json(user);
    } catch (error) {
        console.error('Lỗi khi gọi authMe', error);
        return res.status(500).json({ message: 'Lỗi hệ thống' });
    }
};

export const changePass = async (req, res) => {
    try {
        const user_id = req.user?.user_id;
        const { old_password, new_password } = req.body;
        
        let check = validatePassword(old_password);
        if (!check.valid) return res.status(400).json({ message: check.message });
        check = validatePassword(new_password);
        if (!check.valid) return res.status(400).json({ message: check.message });

        const user = await User.findUserById({ user_id });
        if (!user) {
            return res.status(404).json({ message: 'User không tồn tại' });
        }

        const match = await argon2.verify(user.password_hash, old_password);
        if (!match) {
            return res.status(401).json({ message: 'Mật khẩu cũ không đúng' });
        }

        const new_password_hash = await argon2.hash(new_password);
        await User.updateUser({ user_id, new_password: new_password_hash });

        return res.status(200).json({ message: 'Đổi mật khẩu thành công' });
    } catch (error) {
        
    }
};