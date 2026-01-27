# Security Configuration Guide

This document outlines required security configurations that must be set in the Supabase Dashboard. These settings cannot be automated via migrations and require manual configuration.

## 🔒 Security Status Summary

| Issue | Status | Action Required |
|-------|--------|-----------------|
| Unindexed foreign keys | ✅ FIXED | None - Migration applied |
| SECURITY DEFINER views | ✅ FIXED | None - Using SECURITY INVOKER |
| Unused indexes warning | ℹ️ EXPECTED | None - Will be used in production |
| Leaked Password Protection | ⚠️ MANUAL | Enable in Auth settings |
| Auth DB Connection Strategy | ⚠️ MANUAL | Change to percentage-based |

**Last Updated**: 2026-01-27
**Migration Applied**: `add_matching_engine_schema`

---

## Critical Security Settings

### 1. Enable Leaked Password Protection

**Priority**: HIGH
**Location**: Supabase Dashboard > Authentication > Policies

**What it does**: Prevents users from using compromised passwords by checking against the HaveIBeenPwned.org database.

**Steps to enable**:
1. Navigate to your Supabase project dashboard
2. Go to Authentication > Policies
3. Find "Leaked Password Protection" or "Password Breach Detection"
4. Toggle the setting to **Enabled**

**Recommended**: This should be enabled before going to production.

---

### 2. Configure Auth DB Connection Strategy

**Priority**: MEDIUM
**Location**: Supabase Dashboard > Project Settings > Database

**What it does**: Changes Auth server database connection allocation from a fixed number to a percentage of available connections, allowing it to scale with your instance size.

**Current Issue**: Auth server is configured to use a fixed 10 connections, which won't scale when you increase instance size.

**Steps to configure**:
1. Navigate to your Supabase project dashboard
2. Go to Project Settings > Database
3. Find "Auth Connection Pool" or similar setting
4. Change from "Fixed" (10 connections) to "Percentage" (recommended: 10-15%)
5. Save changes

**Recommended Setting**: 10-15% of total connection pool

---

---

### 3. Performance Indexes (Informational)

**Priority**: INFO
**Status**: ✅ Automatically configured via migration

**Context**: The Supabase dashboard may flag certain indexes as "unused" because they haven't been queried yet. This is expected for a new deployment and these indexes are essential for the matching engine.

**Indexes and Their Purpose**:

| Index Name | Table | Purpose | When Used |
|------------|-------|---------|-----------|
| `idx_profiles_dob` | profiles | Age filtering in matches | Every match query |
| `idx_profiles_gender` | profiles | Gender preference filtering | Every match query |
| `idx_profiles_last_active` | profiles | Recency scoring | Every match query |
| `idx_profiles_is_active` | profiles | Active user filtering | Every match query |
| `idx_profiles_coordinates` | profiles | Distance calculations | Match queries with location |
| `idx_profiles_visibility_active` | profiles | Composite filter optimization | Every match query |
| `idx_likes_liker` | likes | User's sent likes lookup | Like history, mutual checks |
| `idx_likes_likee` | likes | User's received likes lookup | Like history, mutual checks |
| `idx_likes_likee_liker` | likes | Mutual like detection | Instant mutual match checks |
| `idx_likes_created` | likes | Chronological sorting | Recent activity displays |
| `idx_matches_user1` | matches | Match list queries | Matches tab, chat lists |
| `idx_matches_user2` | matches | Reverse match lookups | Match existence checks |
| `idx_conversations_match` | conversations | Conversation lookups | Every chat open |
| `idx_messages_conversation` | messages | Message list queries | Every chat view |
| `idx_messages_sender` | messages | Sender filtering | Message history |
| `idx_blocked_users_blocker` | blocked_users | Block list lookups | Every match query |
| `idx_blocked_users_blocked` | blocked_users | Reverse block checks | Every match query |
| `idx_precomputed_matches_user_score` | precomputed_matches | Sorted match retrieval | Smart Mode browsing |
| `idx_precomputed_matches_candidate` | precomputed_matches | Foreign key coverage | Cascade deletions |
| `idx_match_scores_log_user_created` | match_scores_log | Audit log queries | Admin debugging |

**Action Required**: None. These indexes will show usage once the matching features are actively used.

**Important**: Do NOT delete these indexes even if the dashboard shows them as unused. They are critical for performance at scale.

---

## Security Best Practices

### Database Security

#### Row Level Security (RLS)
- ✅ All tables have RLS enabled
- ✅ All policies use optimized `(select auth.uid())` syntax for performance
- ✅ No SECURITY DEFINER views (only used in triggers where required)
- ✅ All foreign keys have covering indexes
- ✅ Policies are consolidated to prevent multiple permissive policy warnings
- ✅ All WITH CHECK clauses properly validate ownership/access

#### Function Security
- ✅ All functions have explicit `search_path` set to prevent search path attacks
- ✅ Trigger functions use `SECURITY DEFINER` to ensure proper execution context

### Authentication Security

#### Password Requirements
Configure strong password requirements in Supabase Dashboard > Authentication > Policies:
- Minimum length: 8 characters (recommended: 12+)
- Require uppercase and lowercase letters
- Require numbers
- Require special characters

#### Session Management
- Default session timeout: Review and adjust based on your security needs
- JWT expiration: Consider shorter expiration times for sensitive applications
- Refresh token rotation: Enable for additional security

### API Security

#### API Keys
- ✅ Anon key is used for client-side operations
- ⚠️ Service role key should NEVER be exposed client-side
- ⚠️ Service role key should only be used in secure server environments

#### Rate Limiting
Consider enabling rate limiting in Supabase Dashboard:
- Authentication endpoints: Prevent brute force attacks
- API endpoints: Prevent abuse and DoS attempts

---

## Security Checklist

Use this checklist to ensure all security configurations are properly set:

### Before Production Deployment

- [ ] Leaked Password Protection enabled
- [ ] Auth DB connection strategy set to percentage-based
- [ ] Strong password requirements configured
- [ ] Rate limiting enabled for auth endpoints
- [ ] Service role key is secured and not in client code
- [ ] Email confirmation enabled (if required)
- [ ] MFA options reviewed and configured (if required)
- [ ] Database backups configured and tested
- [ ] RLS policies tested with different user roles
- [ ] Function permissions verified

### Regular Security Audits

Perform these checks quarterly:

- [ ] Review all RLS policies for accuracy
- [ ] Check for unused indexes (normal in early stages, but monitor)
- [ ] Review function security settings
- [ ] Audit user access patterns
- [ ] Check for anomalous database activity
- [ ] Review and rotate API keys if needed
- [ ] Update dependencies (`npm audit` and fix issues)
- [ ] Review Supabase security advisories

---

## Monitoring Security Issues

### Via Supabase Dashboard

1. **Database Advisor**
   - Location: Dashboard > Database > Advisor
   - Frequency: Check weekly
   - Action: Address any critical or high-priority issues

2. **Query Performance**
   - Location: Dashboard > Database > Query Performance
   - Frequency: Check weekly
   - Action: Optimize slow queries affecting security checks

3. **Logs**
   - Location: Dashboard > Logs
   - Frequency: Review daily for suspicious activity
   - Action: Investigate failed auth attempts and unusual patterns

### Automated Monitoring

Set up alerts for:
- Failed authentication attempts (threshold: 5+ failures in 5 minutes)
- Unusual query patterns
- Database connection pool exhaustion
- Slow query performance on RLS policies

---

## Incident Response

### If You Suspect a Security Breach

1. **Immediate Actions**
   - Rotate all API keys immediately
   - Review recent database logs for suspicious activity
   - Check for unauthorized data access
   - Temporarily increase authentication requirements if needed

2. **Investigation**
   - Export relevant logs
   - Check for unauthorized changes to RLS policies
   - Review user accounts for anomalies
   - Document timeline of events

3. **Recovery**
   - Restore from clean backup if needed
   - Implement additional security measures
   - Update credentials for all affected users
   - Notify users if required by regulations

4. **Post-Incident**
   - Document lessons learned
   - Update security procedures
   - Implement additional monitoring
   - Consider security audit by professional

---

## Additional Resources

- [Supabase Security Best Practices](https://supabase.com/docs/guides/platform/security)
- [PostgreSQL Row Level Security](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [HaveIBeenPwned API](https://haveibeenpwned.com/API/v3)

---

## Support

For security concerns or questions:
- Supabase Support: [support.supabase.com](https://support.supabase.com)
- Supabase Security: [security@supabase.io](mailto:security@supabase.io)
- Emergency Security Issues: Follow responsible disclosure process

---

*Last Updated: 2026-01-26*
*Version: 1.0*
