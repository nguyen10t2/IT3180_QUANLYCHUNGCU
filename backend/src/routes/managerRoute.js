import express from 'express';
import { verifyJWT, authorize } from '../middlewares/authMiddleware.js';
import { 
    getUsers, 
    getPendingUsers,
    getUserDetail,
    approveUser, 
    rejectUser,
    getHouseHolds,
    createHouseHold,
    getHouseHoldById,
    updateHouseHold,
    deleteHouseHold,
    getHouseHoldMembers,
    getResidents,
    getResidentById,
    updateResident,
    deleteResident,
    getInvoices,
    createInvoice,
    getInvoiceById,
    updateInvoice,
    deleteInvoice,
    confirmInvoicePayment,
    getNotifications,
    createNotification,
    deleteNotification,
    getFeedbacks,
    respondFeedback
} from '../controllers/managerController.js';

const router = express.Router();

// Tất cả các route đều cần xác thực và quyền manager
router.use(verifyJWT, authorize('manager'));

// === User Management ===
router.post('/users', getUsers);

router.get('/users/pending', getPendingUsers);

router.get('/users/:id', getUserDetail);

// Duyệt user
router.patch('/users/:id/approve', approveUser);

router.patch('/users/:id/reject', rejectUser);

// === HouseHold Management ===
router.get('/households', getHouseHolds);

router.post('/households', createHouseHold);

router.get('/households/:id', getHouseHoldById);

router.patch('/households/:id', updateHouseHold);

router.delete('/households/:id', deleteHouseHold);

router.get('/households/:id/members', getHouseHoldMembers);

// === Resident Management ===
router.get('/residents', getResidents);

router.get('/residents/:id', getResidentById);

router.patch('/residents/:id', updateResident);

router.delete('/residents/:id', deleteResident);

// === Invoice Management ===
router.get('/invoices', getInvoices);

router.post('/invoices', createInvoice);

router.get('/invoices/:id', getInvoiceById);

router.patch('/invoices/:id', updateInvoice);

router.delete('/invoices/:id', deleteInvoice);

router.patch('/invoices/:id/confirm', confirmInvoicePayment);

// === Notification Management ===
router.get('/notifications', getNotifications);

router.post('/notifications', createNotification);

router.delete('/notifications/:id', deleteNotification);

// === Feedback Management ===
router.get('/feedbacks', getFeedbacks);

router.patch('/feedbacks/:id/respond', respondFeedback);

export default router;
