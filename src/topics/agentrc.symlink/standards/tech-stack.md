# Tech Stack

> Version: 2.0.0
> Last Updated: 2025-01-15

## Context

This file is part of the Agentrc standards system. These global tech stack defaults are referenced by all product codebases when initializing new projects. Individual projects may override these choices in their `.agentrc/product/tech-stack.md` file.

## Core Technologies

### Web Applications

- **Framework:** Next.js
- **Version:** Latest stable (App Router)
- **Language:** TypeScript
- **Node Version:** 22 LTS

### Mobile Applications

- **Framework:** React Native
- **Version:** Latest stable
- **Language:** TypeScript
- **Platform:** iOS & Android

### Shared Foundation

- **Language:** TypeScript
- **Package Manager:** Yarn
- **Runtime:** Node.js 22 LTS

## Database & Backend

### Database

- **Primary:** Supabase (PostgreSQL)
- **Features:** Real-time subscriptions, Auth, Storage
- **ORM:** Supabase Client / Prisma (when needed)

### Authentication

- **Provider:** Supabase Auth
- **Methods:** Email, OAuth (Google, GitHub)
- **Session Management:** JWT with refresh tokens

### API Layer

- **Web:** Next.js API Routes / Server Actions
- **Mobile:** Supabase REST API / GraphQL

## Frontend Stack

### Styling

- **Framework:** TailwindCSS
- **Version:** Latest stable
- **Configuration:** Custom design system
- **Mobile:** NativeWind (React Native)

### UI Components

- **Web:** Headless UI / Radix UI
- **Mobile:** React Native Elements / Tamagui
- **Icons:** Lucide React / Lucide React Native

### State Management

- **Client State:** React state / Zustand
- **Server State:** SWR / TanStack Query
- **Real-time:** Supabase subscriptions

## Assets & Media

### Fonts

- **Web:** Inter (Google Fonts, self-hosted)
- **Mobile:** System fonts with Inter fallback

### Images

- **Optimisation:** Next.js Image component
- **Storage:** Supabase Storage
- **CDN:** Supabase CDN

### Icons

- **Library:** Lucide
- **Implementation:** React/React Native components

## Infrastructure

### Application Hosting

- **Platform:** Vercel
- **Features:** Edge Functions, Analytics
- **Regions:** Global edge network

### Database Hosting

- **Provider:** Supabase
- **Region:** Closest to primary user base
- **Backups:** Automatic point-in-time recovery

### File Storage

- **Provider:** Supabase Storage
- **Features:** RLS policies, image transformations
- **CDN:** Built-in global CDN

## Development Tools

### Package Management

- **Package Manager:** Yarn
- **Lock File:** yarn.lock
- **Scripts:** Standardised yarn scripts

### Code Quality

- **Linting:** ESLint with TypeScript rules
- **Formatting:** Prettier
- **Type Checking:** TypeScript strict mode

### Testing

- **Unit Tests:** Jest + React Testing Library
- **E2E Tests:** Playwright (web) / Detox (mobile)
- **Coverage:** Built-in Jest coverage

## Deployment

### CI/CD Pipeline

- **Platform:** Vercel (automatic)
- **Trigger:** Git push to main/develop
- **Preview:** PR-based preview deployments

### Environments

- **Production:** main branch → production.vercel.app
- **Staging:** develop branch → staging.vercel.app
- **Preview:** Feature branches → preview URLs

### Environment Variables

- **Management:** Vercel Environment Variables
- **Local:** .env.local (gitignored)
- **Validation:** Runtime schema validation

---

_Customize this file with your organization's preferred tech stack. These defaults are used when initializing new projects with Agentrc._
