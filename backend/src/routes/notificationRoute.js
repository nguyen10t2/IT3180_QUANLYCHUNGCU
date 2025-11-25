import express from 'express';
import { getNotifications, markAsRead, markAllAsRead } from '../controllers/notificationController.js';
import { verifyJWT } from '../middlewares/authMiddleware.js';

const router = express.Router();

router.get('/', verifyJWT, getNotifications);

router.put('/:notification_id/read', verifyJWT, markAsRead);

router.put('/read-all', verifyJWT, markAllAsRead);

export default router;
