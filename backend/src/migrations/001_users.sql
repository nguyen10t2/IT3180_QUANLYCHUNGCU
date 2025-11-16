-- Active: 1760956445253@@127.0.0.1@5432@mydb
CREATE TYPE user_role AS ENUM ('admin', 'manager', 'resident', 'accountant');
CREATE TYPE user_status AS ENUM ('active', 'inactive');
CREATE TYPE gender AS ENUM ('male', 'female', 'other');
CREATE TYPE room_type AS ENUM ('single', 'double');
CREATE TYPE house_role AS ENUM ('chuho', 'nguoidaidien', 'nguoithue', 'thanhvien');
CREATE TYPE resident_status AS ENUM ('tamtru', 'thuongtru', 'tamvang');

CREATE TABLE IF NOT EXISTS users (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    fullname VARCHAR(100) NOT NULL,
    role user_role DEFAULT 'resident',
    status user_status DEFAULT 'inactive',
    verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS session (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    refresh_token TEXT UNIQUE,
    expires_at TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
CREATE TABLE otp_tokens (
    otp_id SERIAL PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    otp VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP UNIQUE,
    updated_at TIMESTAMP
);
CREATE INDEX idx_otp ON otp_tokens(email, created_at);

CREATE TABLE reset_tokens (
    email VARCHAR(100) NOT NULL UNIQUE,
    reset_token TEXT UNIQUE,
    expires_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_rt ON reset_tokens(email);

CREATE TABLE house_holds (
    house_hold_id SERIAL PRIMARY KEY,
    room_number VARCHAR(50) UNIQUE NOT NULL,
    room_type room_type NOT NULL,
    members_count INT DEFAULT 0,
    house_hold_head VARCHAR(50) NOT NULL,
    has_vehicle BOOLEAN DEFAULT FALSE,
    notes TEXT,
    updated_at TIMESTAMP DEFAULT NOW(),
);

CREATE TABLE residents (
    resident_id SERIAL PRIMARY KEY,
    house_hold_id INT REFERENCES house_holds(house_hold_id),
    fullname VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    gender gender NOT NULL,
    role house_role NOT NULL,
    status resident_status NOT NULL,
    registration_date TIMESTAMP DEFAULT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_resident_phone ON residents(phone_number);