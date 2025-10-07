// I added firstname, lastname, email, phone in the users table
import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../database/database.service';
import { RowDataPacket, OkPacket } from 'mysql2';
import * as bcrypt from 'bcryptjs';

@Injectable()
export class UsersService {
  constructor(private db: DatabaseService) { }

  private pool = () => this.db.getPool();

  async createUser(username: string, password: string, role = 'user', firstname: string, lastname: string, email: string, phone: string) {
    try {
      const hashedPassword = await bcrypt.hash(password, 10);
      const [result] = await this.pool().execute<OkPacket>(
        'INSERT INTO users (username, password, role, firstname, lastname, email, phone) VALUES (?, ?, ?, ?, ?, ?, ?)',
        [username, hashedPassword, role, firstname, lastname, email, phone],
      );
      return { id: result.insertId, username, role, firstname, lastname, email, phone };
    } catch (err: any) {
      if (err.code === 'ER_DUP_ENTRY') {
        throw new Error(`Username "${username}" is already taken. Please Try Again`);
      }
      throw err;
    }
  }

  async findByUsername(username: string) {
    const [rows] = await this.pool().execute<RowDataPacket[]>(
      'SELECT id, username, password, role,firstname, lastname, email, phone,refresh_token FROM users WHERE username = ?',
      [username],
    );

    return rows[0];
  }
  async findByEmail(email: string) {
    const [rows] = await this.pool().execute<RowDataPacket[]>(
      'SELECT id, username, password, role, firstname, lastname, email, phone, refresh_token FROM users WHERE email = ?',
      [email],
    );

    return rows[0];
  }

  async findById(id: number) {
    const [rows] = await this.pool().execute<RowDataPacket[]>(
      'SELECT id, username, role,firstname, lastname, email, phone,created_at FROM users WHERE id = ?',
      [id],
    );

    return rows[0];
  }

  async getAll() {
    const [rows] = await this.pool().execute<RowDataPacket[]>('SELECT id, username, role,firstname, lastname, email, phone,created_at FROM users');
    return rows;
  }

  async update(id: number, partial: { username?: string; password?: string; role?: string, firstname?: string, lastname?: string, email?: string, phone?: string }) {
    const fields: string[] = [];
    const values: any[] = [];

    if (partial.username) {
      fields.push('username = ?');
      values.push(partial.username);
    }

    if (partial.password) {
      const hashedPassword = await bcrypt.hash(partial.password, 10);
      fields.push('password = ?');
      values.push(hashedPassword);
    }

    if (partial.role) {
      fields.push('role = ?');
      values.push(partial.role);
    }
    if (partial.firstname) {
      fields.push('firstname = ?');
      values.push(partial.firstname);
    }
    if (partial.lastname) {
      fields.push('lastname = ?');
      values.push(partial.lastname);
    }
    if (partial.email) {
      fields.push('email = ?');
      values.push(partial.email);
    }
    if (partial.phone) {
      fields.push('phone = ?');
      values.push(partial.phone);
    }
    if (fields.length === 0) {
      return await this.findById(id);
    }

    values.push(id);
    const sql = `Update users SET ${fields.join(', ')} WHERE id = ?`;
    await this.pool().execute(sql, values);
    return this.findById(id);
  }

  async remove(id: number) {
    const [res] = await this.pool().execute<OkPacket>('DELETE FROM users WHERE id = ?', [id]);
    return res.affectedRows > 0;
  }

  async setRefreshToken(id: number, refreshToken: string | null) {
    await this.pool().execute<any>('UPDATE users SET refresh_token = ? WHERE id = ?', [refreshToken, id]);
  }

  async findByRefreshToken(refreshToken: string) {
    const [rows] = await this.pool().execute<RowDataPacket[]>(
      'SELECT id, username, role FROM users WHERE refresh_token = ?',
      [refreshToken],
    );
    return rows[0];
  }
}
