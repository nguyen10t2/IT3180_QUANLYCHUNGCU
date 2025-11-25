import express from 'express';
import { getResidents, updateResident, createResident, getHouseHolds } from '../controllers/residentController.js';
import { verifyJWT } from '../middlewares/authMiddleware.js';

const router = express.Router();

router.get('/households', verifyJWT, getHouseHolds);

router.get('/me', verifyJWT, getResidents);

router.post('/me', verifyJWT, createResident);

router.put('/me', verifyJWT, updateResident);

export default router;
