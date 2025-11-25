import express from 'express';
import { authMe } from '../controllers/userController.js';
import { verifyJWT } from '../middlewares/authMiddleware.js';

const router = express.Router();

router.use(verifyJWT);

router.get('/me', authMe);

export default router;