import express from 'express';
import { getInvoices, getInvoiceDetails, payInvoice } from '../controllers/invoiceController.js';
import { verifyJWT } from '../middlewares/authMiddleware.js';

const router = express.Router();

router.get('/', verifyJWT, getInvoices);

router.get('/:invoice_id', verifyJWT, getInvoiceDetails);

router.post('/:invoice_id/pay', verifyJWT, payInvoice);

export default router;
