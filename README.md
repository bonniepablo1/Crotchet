# Crotchet Dating App

A production-ready dating application built with React, TypeScript, and Supabase. Features include user authentication, profile management, swipe-based matching, real-time messaging, and secure data handling.

## Features

- **User Authentication**: Email/password authentication with Supabase Auth
- **Profile Management**: Multi-step profile creation with interests, location, and preferences
- **Smart Discovery**: Swipe-based interface for discovering potential matches
- **Mutual Matching**: Automatic match creation when two users like each other
- **Real-time Messaging**: Live chat functionality with conversation management
- **Row Level Security**: Database-level security ensuring users can only access their own data
- **Responsive Design**: Beautiful UI that works on desktop and mobile devices

## Tech Stack

- **Frontend**: React 18, TypeScript, Tailwind CSS
- **Icons**: Lucide React
- **Backend**: Supabase (PostgreSQL database, Authentication, Real-time subscriptions)
- **Build Tool**: Vite

## Database Schema

### Tables

1. **profiles** - User profile information linked to auth.users
2. **likes** - User likes/swipes with unique constraints
3. **matches** - Mutual matches with normalized ordering
4. **conversations** - Chat conversations between matched users
5. **messages** - Individual messages with read status

### Security Features

- Row Level Security (RLS) enabled on all tables
- Users can only view and update their own profiles
- Match and conversation access restricted to participants
- Automated match creation via database triggers
- Secure phone number handling with HMAC hashing

## Setup Instructions

### 1. Environment Variables

Copy `.env.example` to `.env` and fill in your Supabase credentials:

```bash
VITE_SUPABASE_URL=your_supabase_project_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Database Setup

The database migration has already been applied with the following:
- All tables created with proper relationships
- RLS policies configured
- Indexes for performance optimization
- Triggers for automatic match creation

#### Optional: Seed Test Data

To populate the database with test data for development:

1. Open Supabase Dashboard > SQL Editor
2. Open `supabase/seed.sql` from this project
3. Copy and paste the SQL into the editor
4. Click "Run" to execute

This will create 4 test users with profiles, likes, matches, and sample messages.

### 4. Run Development Server

```bash
npm run dev
```

The app will be available at `http://localhost:5173`

### 5. Run Tests

```bash
npm test
```

This runs the smoke tests to verify database schema, authentication, RLS policies, and core functionality.

### 6. Build for Production

```bash
npm run build
```

## Application Flow

### 1. Authentication
- Users can sign up with email and password
- Sign in to existing accounts
- Automatic session management

### 2. Profile Setup
- **Step 1**: Basic information (username, full name, date of birth, location)
- **Step 2**: Gender and preferences (who you're looking for)
- **Step 3**: Bio and interests selection

### 3. Discovery
- Swipe interface showing compatible profiles
- Like or pass on each profile
- Smart filtering based on mutual preferences

### 4. Matching
- Automatic match creation when both users like each other
- Conversation automatically created for each match
- View all matches in one place

### 5. Messaging
- Real-time chat with matched users
- Message history and read status
- Conversation updates via Supabase real-time

## Key Components

### Authentication Components
- `Login.tsx` - User login form
- `Signup.tsx` - User registration form
- `AuthContext.tsx` - Authentication state management

### Profile Components
- `ProfileSetup.tsx` - Multi-step profile creation
- `EditProfile.tsx` - Profile editing modal

### Discovery & Matching
- `Discover.tsx` - Swipe interface for discovering profiles
- `Matches.tsx` - List of all mutual matches

### Messaging
- `Chat.tsx` - Real-time messaging interface

## Security Best Practices

### Database Security
- All tables have RLS enabled
- Policies restrict data access to authorized users only
- Phone numbers stored as HMAC hashes for privacy
- Timestamps track profile activity

### Authentication
- Passwords never stored in plain text (handled by Supabase Auth)
- JWT-based session management
- Automatic token refresh
- Secure password requirements

### Data Privacy
- Users can only see active profiles that match their preferences
- Match visibility restricted to participants
- Messages only accessible within authorized conversations
- Profile updates restricted to profile owners

## API Structure

### Supabase Client
All database operations use the Supabase client with TypeScript types:

```typescript
import { supabase } from './lib/supabase';

// Example: Fetch current user's profile
const { data, error } = await supabase
  .from('profiles')
  .select('*')
  .eq('id', userId)
  .single();
```

### Real-time Subscriptions
Messages use Supabase real-time for instant updates:

```typescript
const channel = supabase
  .channel(`conversation:${conversationId}`)
  .on('postgres_changes', {
    event: 'INSERT',
    schema: 'public',
    table: 'messages'
  }, handleNewMessage)
  .subscribe();
```

## Architecture Notes

### Matching Logic
- Matches use normalized ordering (smaller UUID first) to ensure uniqueness
- Database trigger automatically creates match and conversation on mutual like
- Client-side filtering ensures only compatible profiles are shown

### Performance Optimizations
- Database indexes on foreign keys and frequently queried columns
- Pagination for profile discovery
- Efficient query patterns with Supabase
- Optimized bundle size with Vite

## Future Enhancements

Potential features for future development:
- Photo upload and management
- Video chat integration
- Advanced filtering and search
- Location-based matching
- Push notifications
- Social media authentication
- Profile verification system
- Reporting and blocking functionality

## Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm test` - Run smoke tests
- `npm run lint` - Run ESLint
- `npm run typecheck` - Run TypeScript type checking
- `npm run preview` - Preview production build

## Testing

### Smoke Tests

The project includes comprehensive smoke tests in `tests/smoke.js` that verify:

1. Database schema integrity
2. Authentication endpoints
3. Profile read access
4. Row Level Security (RLS) policies
5. Database constraints
6. Performance indexes

Run tests with:
```bash
npm test
```

All tests must pass before deploying to production.

## Database Operations

### Migrations

Database migrations are stored in `supabase/migrations/`. See [RUNBOOK.md](./RUNBOOK.md) for detailed instructions on:
- Applying migrations to staging/production
- Rolling back migrations
- Creating database backups
- Migration best practices

### Seed Data

Test data can be seeded using `supabase/seed.sql`. This creates sample users, profiles, likes, matches, and messages for development and testing.

## Documentation

- **[RUNBOOK.md](./RUNBOOK.md)** - Operations guide for database migrations, backups, deployment, and troubleshooting
- **[.env.example](./.env.example)** - Template for environment variables

## Deployment

See [RUNBOOK.md](./RUNBOOK.md) for detailed deployment instructions including:
- Environment setup
- Deployment checklist
- Platform-specific guides (Vercel, Netlify, custom server)
- Monitoring and maintenance

## License

This project is provided as-is for educational and development purposes.
