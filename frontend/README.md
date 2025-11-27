# Kogu Express Frontend (Next.js)

Hệ thống quản lý chung cư thông minh - Frontend được rebuild bằng Next.js 15 với App Router.

## Tính năng

- **Next.js 15** với App Router
- **React 19** với Server Components
- **TypeScript** để type safety
- **Tailwind CSS** cho styling
- **Zustand** để quản lý state
- **React Hook Form** + **Zod** cho form validation
- **Axios** cho API calls
- **Sonner** cho toast notifications

## Cấu trúc thư mục

```
src/
├── app/                    # Next.js App Router
│   ├── (auth)/            # Auth routes group (signin, signup, otp, etc.)
│   ├── (protected)/       # Protected routes group (home, account, etc.)
│   ├── globals.css        # Global styles
│   ├── layout.tsx         # Root layout
│   └── page.tsx           # Home page (redirect to /signin)
├── components/
│   ├── auth/              # Auth-related components
│   ├── layout/            # Layout components (sidebar, etc.)
│   ├── ui/                # UI components (button, input, card, etc.)
│   └── providers.tsx      # Context providers
├── lib/
│   ├── axios.ts           # Axios instance with interceptors
│   ├── utils.ts           # Utility functions
│   └── validations/       # Zod schemas
├── services/              # API services
├── stores/                # Zustand stores
└── types/                 # TypeScript types
```

## Cài đặt

1. Cài đặt dependencies:

```bash
cd frontend-nextjs
npm install
```

2. Copy file env:

```bash
cp .env.example .env.local
```

3. Chạy development server:

```bash
npm run dev
```

4. Mở [http://localhost:3000](http://localhost:3000) trên trình duyệt.

## Scripts

- `npm run dev` - Chạy development server
- `npm run build` - Build production
- `npm run start` - Chạy production server
- `npm run lint` - Kiểm tra linting

## Authentication Flow

1. **Sign Up** → OTP Verification → Sign In
2. **Sign In** → Home (Protected)
3. **Forgot Password** → OTP Verification → Reset Password → Sign In

## Theme

Sử dụng CSS variables để hỗ trợ dark/light mode. Xem `globals.css` để tùy chỉnh theme.

## Dependencies chính

- `next` - Framework
- `react` & `react-dom` - UI library
- `zustand` - State management
- `axios` - HTTP client
- `zod` - Schema validation
- `react-hook-form` - Form handling
- `@hookform/resolvers` - Form resolvers
- `tailwindcss` - CSS framework
- `lucide-react` - Icons
- `sonner` - Toast notifications
- `@radix-ui/*` - Headless UI components
