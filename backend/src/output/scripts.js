import argon2 from 'argon2';

const pass = await argon2.hash("Test@123");

console.log(pass);
