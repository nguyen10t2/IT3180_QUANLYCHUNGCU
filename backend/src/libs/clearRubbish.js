import cron from 'node-cron';
import { Session } from '../models/Session.js';
import { Otp } from '../models/Otp.js';

cron.schedule('0 * * * *', async () => {
    try {
        console.log('Running cleanup...');
        await Session.cleanupExpired();
        await Otp.deleteOTP();
        console.log('Cleanup finished');
    } catch (err) {
        console.error('Error during cleanup', err);
    }
});
