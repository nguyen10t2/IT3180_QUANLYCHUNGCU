import pkg from 'pg';
const { Pool } = pkg;
import dotenv from 'dotenv';
dotenv.config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL
});

export const connectDB = async () => {
    try {
        const client = await pool.connect();
        console.log('PostgreSQL đã kết nối');
        client.release();
    }
    catch (err) {
        console.error('Kết nối thất bại', err);
        process.exit(1);
    }
}

export default pool;
