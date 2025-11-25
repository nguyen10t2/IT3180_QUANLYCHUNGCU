import type { Role } from "@/lib/validations/auth";
import type { User } from "./user";

export interface AuthState {
  accessToken: string | null;
  user: User | null;
  loading: boolean;

  setAccessToken: (token: string) => void;
  clearState: () => void;

  signUp: (
    fullname: string,
    email: string,
    password: string,
    role: Role
  ) => Promise<void>;

  signIn: (email: string, password: string) => Promise<void>;
  signOut: () => Promise<void>;
  fetchMe: () => Promise<User | undefined>;
  refreshTokenHandler: () => Promise<void>;
}
