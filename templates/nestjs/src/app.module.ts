import { Module } from '@nestjs/common'
import { UsersModule } from './users/users.module'
import { AuthModule } from './auth/auth.modules'
import { DatabaseModule } from './database/database.module'
@Module({
  imports: [DatabaseModule, UsersModule, AuthModule],
})
export class AppModule {}
