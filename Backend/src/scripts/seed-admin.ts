/**
 * Bir martalik skript: birinchi Admin foydalanuvchini yaratish yoki
 * mavjud foydalanuvchini Admin qilib belgilash uchun ishlatiladi.
 *
 * Ishlatish:
 *   npm run seed:admin -- --email=admin@sewing.com --password=StrongPass123 --name="Bosh Admin"
 *
 * Agar shu email bilan foydalanuvchi mavjud bo'lsa — uning roli "admin"ga
 * o'zgartiriladi (parol o'zgarmaydi, agar --password berilmasa).
 * Agar mavjud bo'lmasa — yangi Admin foydalanuvchi yaratiladi.
 */
import bcrypt from 'bcrypt';

import { env } from '../config/env';
import { connectDatabase, disconnectDatabase } from '../database/mongoose';
import { UserModel, UserRole } from '../modules/auth/models/user.model';

interface ParsedArgs {
  email?: string;
  password?: string;
  name?: string;
}

const parseArgs = (): ParsedArgs => {
  const result: ParsedArgs = {};
  for (const arg of process.argv.slice(2)) {
    const match = arg.match(/^--([^=]+)=(.*)$/);
    if (!match) continue;
    const [, key, value] = match;
    if (key === 'email' || key === 'password' || key === 'name') {
      result[key] = value;
    }
  }
  return result;
};

const run = async (): Promise<void> => {
  const args = parseArgs();

  const email = (args.email ?? 'admin@sewing.com').toLowerCase().trim();
  const password = args.password ?? 'ChangeMe123!';
  const fullName = args.name ?? 'Bosh Admin';

  if (password.length < 8) {
    console.error('Xato: parol kamida 8 belgidan iborat bo\'lishi kerak.');
    process.exit(1);
  }

  await connectDatabase();

  const existing = await UserModel.findOne({ email });

  if (existing) {
    existing.role = UserRole.Admin;
    if (args.password) {
      existing.password = await bcrypt.hash(password, env.bcryptSaltRounds);
    }
    await existing.save();
    console.log(`✅ Mavjud foydalanuvchi Admin qilindi: ${email}`);
  } else {
    const hashed = await bcrypt.hash(password, env.bcryptSaltRounds);
    await UserModel.create({
      fullName,
      email,
      password: hashed,
      role: UserRole.Admin,
    });
    console.log('✅ Yangi Admin foydalanuvchi yaratildi:');
    console.log(`   Email: ${email}`);
    console.log(`   Parol: ${password}`);
    console.log('   Diqqat: shu parol bilan tizimga kiring va keyin xohlasangiz o\'zgartiring.');
  }

  await disconnectDatabase();
  process.exit(0);
};

run().catch((error) => {
  console.error('Admin yaratishda xatolik:', error);
  process.exit(1);
});
