import { Controller, Body, Post, UseGuards, Request, Get, Delete } from "@nestjs/common";
import { AuthService } from './auth.services'
import { UsersService } from '../users/users.service'

@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService, private usersService: UsersService) { }

  @Post('register')
  async register(@Body() body: { username: string; password: string; role: string; firstname: string; lastname: string; email: string; phone: string}) {
    console.log('REGISTER BODY:', body);
    return this.usersService.createUser(body.username, body.password, body.role, body.firstname, body.lastname, body.email, body.phone);
  }
  @Post('login')
  async login(@Body() body: { username: string; email: string, password: string }) {
    const user = await this.authService.validateUser(body.username,body.email,  body.password);
    if (!user) return { error: 'Invalid Credentials' };
    return this.authService.login(user);
  }
  @Post('logout')
  async logout(@Body() body: { userId: number }) {
    return this.authService.logout(body.userId);
  }
  @Post('refresh')
  async refresh(@Body() body: { refreshToken: string }) {
    return this.authService.refreshToken(body.refreshToken);
  }
}
