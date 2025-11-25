import express from 'express';
import dotenv from 'dotenv';
import { connectDB } from './libs/db.js';
import authRoute from './routes/authRoute.js';
import userRoute from './routes/userRoute.js';
import residentRoute from './routes/residentRoute.js';
import notificationRoute from './routes/notificationRoute.js';
import invoiceRoute from './routes/invoiceRoute.js';
import feedbackRoute from './routes/feedbackRoute.js';
import cookieParser from 'cookie-parser';
import cors from "cors";

dotenv.config();

const app = express();
const IP_ADDRESS = process.env.IP_ADDRESS || 'localhost';
const PORT = process.env.PORT || 8080;

app.use(cors({
    origin: `http://${IP_ADDRESS}:3000`,
    credentials: true,
}));

app.use(express.json());
app.use(cookieParser());

app.use('/api/auth', authRoute);

app.use('/api/users', userRoute);

app.use('/api/residents', residentRoute);

app.use('/api/notifications', notificationRoute);

app.use('/api/invoices', invoiceRoute);

app.use('/api/feedbacks', feedbackRoute);

connectDB().then(() => {
    app.listen(PORT, () => {
        console.log('Đang chạy ở http://' + IP_ADDRESS + ':' + PORT);
    });
});