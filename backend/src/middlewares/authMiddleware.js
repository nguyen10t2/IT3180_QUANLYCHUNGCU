import jwt from 'jsonwebtoken';
import { Session } from '../models/Session.js';

const hasPermission = (user_role, required_role) => {
    return {
        admin: ['admin', 'manager', 'accountant', 'resident'],
        manager: ['manager', 'resident'],
        accountant: ['accountant'],
        resident: ['resident']
    }[user_role]?.includes(required_role) || false;
};

export const verifyJWT = async (req, res, next) => {
    try {
        const authHeader = req.headers['authorization'];

        const token = authHeader && authHeader.split(' ')[1];
        if (!token) {
            return res.status(401).json({ message: 'Không tìm thấy access_token' });
        }

        const decoded = await new Promise((resolve, reject) => {
            jwt.verify(token, process.env.ACCESS_TOKEN_SECRET, (err, decoded) => {
                if (err) reject(err);
                else resolve(decoded);
            });
        });

        req.user = decoded;

        next();
    } catch (error) {

        console.error('Lỗi khi xác minh JWT', error);

        return res.status(500).json({ message: 'Lỗi hệ thống' });
    }
};

export const authorize = (required_role) => {
    return async (req, res, next) => {
        try {
            const authHeader = req.headers['authorization'];

            const token = authHeader && authHeader.split(' ')[1];
            if (!token) {
                return res.status(401).json({ message: 'Không tìm thấy access_token' });
            }

            const decoded = await new Promise((resolve, reject) => {
                jwt.verify(token, process.env.ACCESS_TOKEN_SECRET, (err, decoded) => {
                    if (err) reject(err);
                    else resolve(decoded);
                });
            });

            const role = decoded.user_role;
            if (!role || !hasPermission(role, required_role)) {
                return res.status(403).json({ message: 'Không đủ quyền truy cập' });
            }

            req.user = decoded;
            next();

        } catch (error) {
            console.error('Lỗi khi xác minh JWT', error);

            return res.status(401).json({ message: 'Access_token không hợp lệ hoặc hết hạn' });
        }
    };
};

export const verifyRefreshToken = async (req, res, next) => {
    try {
        const refresh_token = req.cookies?.refresh_token;

        if (!refresh_token) {
            return res.status(401).json({ message: 'Không có refresh token' });
        }

        const session = await Session.findOne({ refresh_token });
        if (!session || session.expires_at < new Date()) {
            return res.status(401).json({ message: 'Refresh token không hợp lệ hoặc hết hạn' });
        }

        req.session = session;

        next();
    } catch (error) {
        console.error('Lỗi verifyRefreshToken:', error);
        return res.status(500).json({ message: 'Lỗi hệ thống' });
    }
};