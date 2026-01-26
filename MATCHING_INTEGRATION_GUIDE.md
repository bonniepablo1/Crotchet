# Matching Engine Frontend Integration Guide

## Overview

The matching engine has been fully integrated into the frontend application. Users can now browse personalized match recommendations with smart scoring, filtering, and real-time updates.

---

## New Features

### 1. Browse Tab (Smart Matching)

A new **"Browse"** tab has been added to the main navigation with a ✨ sparkle icon. This is powered by the production matching engine.

**Location**: Main navigation bar → Browse

**Key Features**:
- **Grid layout** with beautiful match cards
- **Match scores** (0-100) with color-coded badges
- **Top 3 reasons** why you might match (shared interests, mutual likes, etc.)
- **Smart/Fresh mode toggle**:
  - **Fresh Mode**: Realtime scoring (<300ms)
  - **Smart Mode**: Precomputed recommendations (<100ms)
- **Pagination** with smooth navigation
- **Like/Pass actions** on each card
- **Instant mutual match detection**

### 2. Match Cards

Each match card displays:
- **Profile photo** with fallback to initials
- **Match score badge** with color coding:
  - Green (80-100): Excellent match
  - Blue (60-79): Good match
  - Yellow (40-59): Moderate match
  - Gray (0-39): Lower match
- **Verification badge** for complete profiles (80%+)
- **Name and location**
- **Last active status** (Active now, 2h ago, etc.)
- **Bio preview** (3 lines max)
- **Match reasons** (top 3 scoring factors)
- **Interests** (showing 5, +more indicator)
- **Like/Pass buttons** with smooth animations

### 3. Matching Service

**File**: `src/services/matchingService.ts`

A singleton service that handles all matching API calls:

```typescript
import { matchingService } from '../services/matchingService';

// Get matches with configuration
const response = await matchingService.getMatches({
  page: 1,
  limit: 20,
  usePrecomputed: false
});

// Like a match
await matchingService.likeMatch(matchId);

// Block a user
await matchingService.blockUser(userId, reason);

// Check for mutual match
const isMutual = await matchingService.checkMutualMatch(matchId);

// Trigger batch computation (admin)
await matchingService.triggerBatchComputation(50, 100);
```

---

## User Flow

### Browse Matches Flow

1. **User navigates to Browse tab**
   - API call to `/functions/v1/matches?page=1&limit=12`
   - Loading state with spinner
   - Grid populates with match cards

2. **User reviews match cards**
   - Sees match score and reasons
   - Reads bio and interests
   - Views profile photo

3. **User likes a match**
   - Click "Like" button
   - Card animates with pink ring
   - Like saved to database
   - Check for mutual match
   - If mutual: Show "It's a match!" alert

4. **User passes on a match**
   - Click "Pass" button
   - Card fades out and removes from grid
   - Can continue browsing

5. **User toggles Smart Mode**
   - Switches from Fresh (realtime) to Smart (precomputed)
   - New API call with `usePrecomputed=true`
   - Banner appears explaining Smart Mode
   - Faster response times

6. **User navigates pages**
   - Click "Next" or "Previous"
   - Smooth scroll to top
   - New page loads with stable ordering

### Mutual Match Flow

When users mutually like each other:

1. User A likes User B → saved to `likes` table
2. User B browses and sees User A (if matching filters pass)
3. User B likes User A → saved to `likes` table
4. System detects mutual like
5. Alert shown: "🎉 It's a match! You can now start chatting"
6. Match automatically appears in "Chats" tab

---

## API Integration

### Matches Endpoint

**GET** `/functions/v1/matches`

**Query Parameters**:
- `page`: integer (default: 1)
- `limit`: integer (default: 20, max: 100)
- `precomputed`: boolean (default: false)

**Headers**:
- `Authorization`: Bearer token (from Supabase session)

**Response**:
```json
{
  "matches": [
    {
      "id": "uuid",
      "score": 85,
      "reasons": ["3 shared interests", "Active today", "Complete profile"],
      "profile": {
        "id": "uuid",
        "username": "johndoe123",
        "full_name": "John Doe",
        "gender": "male",
        "bio": "Adventure seeker...",
        "location": "San Francisco",
        "interests": ["hiking", "photography", "coffee"],
        "photos": [{"url": "...", "order": 0}],
        "profile_completeness": 95,
        "last_active": "2024-01-26T10:30:00Z"
      }
    }
  ],
  "page": 1,
  "limit": 20,
  "total": 150,
  "mode": "realtime"
}
```

### Error Handling

The service handles common errors gracefully:

- **401 Unauthorized**: User not authenticated → redirect to login
- **404 Not Found**: User profile missing → prompt to complete profile
- **500 Server Error**: Show error banner with retry button
- **Network Error**: Show error banner with offline message

---

## Performance Optimizations

### 1. Lazy Loading Images

Match card images use lazy loading and error handling:
- Show placeholder while loading
- Fallback to initials on error
- Smooth fade-in transition

### 2. Pagination

Instead of infinite scroll, pagination provides:
- Stable ordering (no duplicates)
- Better perceived performance
- Lower memory usage
- Easier navigation

### 3. Optimistic UI

Actions provide instant feedback:
- Like button shows "Liked!" immediately
- Pass removes card instantly
- No waiting for API confirmation

### 4. Smart Caching

- Session storage for current page
- Reduces redundant API calls
- Fresh data on mode toggle

---

## Styling & UX

### Design Principles

1. **Beautiful First**: Premium, modern aesthetic
   - Gradient backgrounds (pink → purple → blue)
   - Smooth shadows and transitions
   - Color-coded match scores

2. **Clear Hierarchy**:
   - Match score prominent in top-right
   - Name and location easily scannable
   - Bio and interests secondary

3. **Feedback**:
   - Hover states on all interactive elements
   - Animated transitions
   - Loading states with spinners
   - Empty states with helpful messaging

4. **Mobile-First**:
   - Responsive grid (1/2/3 columns)
   - Touch-friendly button sizes
   - Optimized for vertical scrolling

### Color System

**Match Score Colors**:
- Excellent (80-100): Green `bg-green-50` `text-green-600`
- Good (60-79): Blue `bg-blue-50` `text-blue-600`
- Moderate (40-59): Yellow `bg-yellow-50` `text-yellow-600`
- Lower (0-39): Gray `bg-gray-50` `text-gray-600`

**Brand Colors**:
- Primary: Pink-500 to Purple-500 gradient
- Accent: Pink-500
- Success: Green-500
- Error: Red-500

---

## Component Structure

```
src/
├── services/
│   └── matchingService.ts        # API integration service
├── components/
│   └── Matches/
│       ├── MatchCard.tsx          # Individual match card
│       └── MatchesList.tsx        # Browse view with grid + pagination
└── App.tsx                        # Main app with navigation
```

### MatchingService

**Singleton pattern** for centralized configuration:

```typescript
// Set global config
matchingService.setConfig({ usePrecomputed: true });

// Get current config
const config = matchingService.getConfig();

// Override per-request
const matches = await matchingService.getMatches({ page: 2 });
```

### MatchCard

**Props**:
- `match`: Match object with profile and score
- `onLike`: Callback when user likes
- `onPass`: Callback when user passes
- `onViewProfile`: Callback to view full profile

**State Management**:
- Local state for like/pass animations
- Optimistic UI updates
- Image error handling

### MatchesList

**Responsibilities**:
- Fetch matches from API
- Manage pagination state
- Handle mode toggle (Fresh/Smart)
- Display loading/error/empty states
- Coordinate match actions

---

## Testing the Integration

### Manual Testing Checklist

1. **Authentication**:
   - [ ] Login with existing user
   - [ ] Navigate to Browse tab
   - [ ] Verify matches load

2. **Match Display**:
   - [ ] Match cards render correctly
   - [ ] Photos display or show fallback
   - [ ] Match scores visible
   - [ ] Reasons display properly
   - [ ] Interests show correctly

3. **Interactions**:
   - [ ] Like button works
   - [ ] Pass button removes card
   - [ ] Mutual match detection works
   - [ ] Alert shows on mutual match

4. **Pagination**:
   - [ ] Next button advances page
   - [ ] Previous button goes back
   - [ ] Page numbers update
   - [ ] No duplicate results
   - [ ] Disabled states work

5. **Mode Toggle**:
   - [ ] Switch to Smart Mode
   - [ ] Banner appears
   - [ ] Results update
   - [ ] Performance improves

6. **Error Handling**:
   - [ ] Network error shows banner
   - [ ] Empty state displays correctly
   - [ ] Retry button works

### Automated Testing

See `tests/matching-engine.test.ts` for API tests.

To add frontend tests:

```bash
npm install --save-dev @testing-library/react @testing-library/jest-dom vitest
```

Example test:
```typescript
import { render, screen, fireEvent } from '@testing-library/react';
import MatchCard from './components/Matches/MatchCard';

test('MatchCard displays match information', () => {
  const mockMatch = {
    id: '123',
    score: 85,
    reasons: ['3 shared interests'],
    profile: {
      full_name: 'John Doe',
      location: 'SF',
      // ...
    }
  };

  render(<MatchCard match={mockMatch} onLike={() => {}} onPass={() => {}} />);

  expect(screen.getByText('John Doe')).toBeInTheDocument();
  expect(screen.getByText('85%')).toBeInTheDocument();
});
```

---

## Deployment Considerations

### Environment Variables

Ensure these are set in production:

```bash
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your_anon_key
```

### Edge Functions

Both functions must be deployed:

```bash
supabase functions deploy matches
supabase functions deploy compute-matches
```

### Database Migration

Migration must be applied:

```bash
supabase db push
```

Or via dashboard: SQL Editor → paste migration → execute

### Batch Job Schedule

Set up nightly cron job for precomputed matches:

```bash
# Example: Daily at 3 AM
0 3 * * * curl -X POST https://your-project.supabase.co/functions/v1/compute-matches \
  -H "Authorization: Bearer $SERVICE_ROLE_KEY" \
  -d '{"batchSize": 100, "topN": 100}'
```

Or use a service like GitHub Actions, Vercel Cron, or Cloud Scheduler.

---

## Future Enhancements

### Potential Features

1. **Advanced Filters**:
   - Age range slider
   - Distance radius selector
   - Interest tags filter
   - Online/active filter

2. **Match Actions**:
   - Super like (boost visibility)
   - Save for later (bookmark)
   - Report/block from card

3. **Profile Preview**:
   - Modal with full profile
   - Photo gallery
   - More interests and bio
   - Mutual connections

4. **Notifications**:
   - Real-time match notifications
   - Badge count on Browse tab
   - Push notifications

5. **Analytics**:
   - Track like/pass rates
   - A/B test scoring weights
   - Measure engagement lift

6. **Gamification**:
   - Daily match refresh badge
   - Streak counter
   - Match quality score history

---

## Troubleshooting

### Common Issues

**Issue**: "No matches found"
- **Cause**: No users in database or all users filtered out
- **Solution**: Run seed data script: `npm run seed:matching 500`

**Issue**: "Failed to load matches"
- **Cause**: Edge function not deployed or auth issue
- **Solution**: Deploy functions and check auth token

**Issue**: Slow loading times
- **Cause**: Large dataset without indexes
- **Solution**: Verify indexes are applied from migration

**Issue**: Matches not updating after profile change
- **Cause**: Using precomputed mode (cached results)
- **Solution**: Toggle to Fresh Mode or wait for nightly batch

**Issue**: Mutual match not detected
- **Cause**: Race condition or database trigger issue
- **Solution**: Check `likes` table for both entries

---

## Support

For issues or questions:

1. Check [RUNBOOK_MATCHING.md](./RUNBOOK_MATCHING.md) for operations guide
2. Review [MATCHING_ENGINE_SUMMARY.md](./MATCHING_ENGINE_SUMMARY.md) for implementation details
3. Run tests: `npm run test:matching`
4. Check Edge Function logs in Supabase Dashboard

---

*Last Updated: 2026-01-26*
*Version: 1.0*
