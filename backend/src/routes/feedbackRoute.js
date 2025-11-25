import express from 'express';
import { getFeedbacks, createFeedback, getFeedbackDetails } from '../controllers/feedbackController.js';
import { verifyJWT } from '../middlewares/authMiddleware.js';

const router = express.Router();

router.get('/', verifyJWT, getFeedbacks);

router.post('/', verifyJWT, createFeedback);

router.get('/:feedback_id', verifyJWT, getFeedbackDetails);

export default router;
