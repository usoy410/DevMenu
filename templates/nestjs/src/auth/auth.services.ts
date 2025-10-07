/*/ in the validateUser i added that
if input is not in the username then check the email
I can now login using email or username*/
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import * as bcrypt from 'bcryptjs';
import { JwtService } from '@nestjs/jwt';
import * as jwt from 'jsonwebtoken';

@Injectable()
export class AuthService {
  constructor(private usersService: UsersService, private jwtService: JwtService) { }

  async validateUser(username: string, email: string, pass: string): Promise<any> {
    let user = await this.usersService.findByUsername(username);
    if (!user) {
      user = await this.usersService.findByEmail(email);
    }
    if (!user) return null;
    if (user && await bcrypt.compare(pass, user.password)) {
      const { password, ...result } = user;
      return result;
    }
    return null;
  }

  async login(user: any) {
    const payload = { sub: user.id, username: user.username, role: user.role };
    const accessToken = this.jwtService.sign(payload);

    // create refresh token using separate secret to revoke access by changing refresh secret
    const refreshToken = jwt.sign(payload, process.env.JWT_REFRESH_TOKEN_SECRET || 'refresh_secret', {
      expiresIn: process.env.REFRESH_TOKEN_EXPIRES_IN || '7d',
    });
    // hash refresh token before storing.
    await this.usersService.setRefreshToken(user.id, refreshToken);

    return {
      accessToken,
      refreshToken,
    };
  }

  async logout(userId: number) {
    await this.usersService.setRefreshToken(userId, null);
    return { ok: true };
  }

  async refreshToken(refreshToken: string) {
    try {
      const decoded: any = jwt.verify(refreshToken, process.env.JWT_REFRESH_TOKEN_SECRET || 'refresh_secret');
      const user = await this.usersService.findById(decoded.sub);
      if (!user) {
        throw new UnauthorizedException('Invalid refresh token');
      }

      // check stored token matches
      const stored = await this.usersService.findById(decoded.sub);
      if (stored.refreshToken !== refreshToken) {
        throw new UnauthorizedException('Invalid refresh token');
      }

      //check stored refresh token
      // const stored = await this.usersService.findById(decoded.sub);
      const found = await this.usersService.findByRefreshToken(refreshToken);
      if (!found) {
        throw new UnauthorizedException('could not refresh token');
      }

      const payload = { sub: found.id, username: found.username, role: found.role };
      const accessToken = this.jwtService.sign(payload);
      const newRefreshToken = jwt.sign(payload, process.env.JWT_REFRESH_TOKEN_SECRET || 'refresh_secret', {
        expiresIn: process.env.REFRESH_TOKEN_EXPIRES_IN || '7d',
      });
      await this.usersService.setRefreshToken(found.id, newRefreshToken);
      return {
        accessToken,
        refreshToken: newRefreshToken,
      };
    } catch (err) {
      throw new UnauthorizedException('could not refresh tokens');
    }
  }
}
