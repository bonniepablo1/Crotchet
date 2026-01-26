# Crotchet Dating App - Operations Runbook

## Table of Contents
1. [Database Migrations](#database-migrations)
2. [Backup and Recovery](#backup-and-recovery)
3. [Deployment](#deployment)
4. [Monitoring and Maintenance](#monitoring-and-maintenance)
5. [Troubleshooting](#troubleshooting)

---

## Database Migrations

### Overview
This application uses Supabase for database management. Migrations are stored in `supabase/migrations/` and contain all database schema changes, indexes, and RLS policies.

### Applying Migrations

#### To Staging/Production (via Supabase Dashboard)

1. **Navigate to Supabase Dashboard**
   - Go to [https://supabase.com/dashboard](https://supabase.com/dashboard)
   - Select your project

2. **Open SQL Editor**
   - Click "SQL Editor" in the left sidebar
   - Click "New query"

3. **Copy Migration SQL**
   - Open the migration file from `supabase/migrations/`
   - Copy the entire contents

4. **Execute Migration**
   - Paste the SQL into the editor
   - Review the migration summary at the top (comments section)
   - Click "Run" to execute
   - Verify success message appears

5. **Verify Migration**
   ```sql
   SELECT * FROM supabase_migrations.schema_migrations
   ORDER BY version DESC LIMIT 10;
   ```

#### Using Supabase CLI (Alternative)

If you have Supabase CLI installed and configured:

```bash
# Link to your project
supabase link --project-ref YOUR_PROJECT_REF

# Apply all pending migrations
supabase db push

# Verify migration status
supabase db remote commit
```

### Rolling Back a Migration

**Important**: Always create a database backup before rollback!

1. **Identify the Migration to Rollback**
   - Check `supabase/migrations/` for the migration file
   - Note the timestamp and changes made

2. **Create Rollback Migration**
   - Create a new migration file with inverse operations
   - Example: If migration created a table, new migration should drop it
   - Name it appropriately: `YYYYMMDDHHMMSS_rollback_previous_change.sql`

3. **Apply Rollback Migration**
   - Follow the same steps as applying a regular migration
   - Test thoroughly after rollback

### Migration Best Practices

- Always review migration summary comments before applying
- Test migrations on staging before production
- Create database backup before applying to production
- Never modify existing migration files - create new ones instead
- Use `IF EXISTS` and `IF NOT EXISTS` clauses for safety
- Include detailed comments in migration files

---

## Backup and Recovery

### Creating a Database Backup (Before Production Migration)

#### Via Supabase Dashboard

1. **Navigate to Database Settings**
   - Go to your project dashboard
   - Click "Database" in the left sidebar
   - Go to "Backups" tab

2. **Create Manual Backup**
   - Click "Create backup"
   - Add a description (e.g., "Before migration YYYYMMDDHHMMSS")
   - Wait for backup to complete

3. **Verify Backup**
   - Ensure backup status shows "Completed"
   - Note the backup timestamp

#### Via pg_dump (Alternative)

```bash
# Export full database
pg_dump "postgresql://postgres:[PASSWORD]@[PROJECT_REF].supabase.co:5432/postgres" > backup_$(date +%Y%m%d_%H%M%S).sql

# Export specific schema only
pg_dump "postgresql://postgres:[PASSWORD]@[PROJECT_REF].supabase.co:5432/postgres" \
  --schema=public > backup_public_$(date +%Y%m%d_%H%M%S).sql
```

### Restoring from Backup

#### Via Supabase Dashboard

1. Navigate to Database > Backups
2. Find the backup to restore
3. Click "Restore" and confirm
4. Wait for restoration to complete
5. Verify data integrity after restoration

#### Via psql (Alternative)

```bash
psql "postgresql://postgres:[PASSWORD]@[PROJECT_REF].supabase.co:5432/postgres" < backup_file.sql
```

---

## Deployment

### Environment Setup

1. **Create Environment File**
   - Copy `.env.example` to `.env`
   - Fill in Supabase credentials from dashboard

2. **Install Dependencies**
   ```bash
   npm install
   ```

3. **Run Type Checking**
   ```bash
   npm run typecheck
   ```

4. **Run Smoke Tests**
   ```bash
   npm test
   ```

5. **Build for Production**
   ```bash
   npm run build
   ```

### Deployment Checklist

- [ ] All migrations applied to production database
- [ ] Database backup created
- [ ] Environment variables configured
- [ ] Type checking passes (`npm run typecheck`)
- [ ] Smoke tests pass (`npm test`)
- [ ] Production build successful (`npm run build`)
- [ ] RLS policies verified
- [ ] Auth configuration verified

### Deployment Platforms

#### Vercel

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel --prod

# Configure environment variables in Vercel dashboard
```

#### Netlify

```bash
# Install Netlify CLI
npm i -g netlify-cli

# Deploy
netlify deploy --prod

# Configure environment variables in Netlify dashboard
```

#### Custom Server

```bash
# Build the app
npm run build

# Serve the dist folder with any static file server
# Example with serve:
npx serve dist -p 3000
```

---

## Monitoring and Maintenance

### Database Performance Monitoring

1. **Via Supabase Dashboard**
   - Navigate to Database > Performance
   - Monitor query performance
   - Check for slow queries
   - Review connection pool usage

2. **Check Active Connections**
   ```sql
   SELECT count(*) FROM pg_stat_activity;
   ```

3. **Monitor Table Sizes**
   ```sql
   SELECT
     schemaname,
     tablename,
     pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
   FROM pg_tables
   WHERE schemaname = 'public'
   ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
   ```

### Regular Maintenance Tasks

#### Weekly
- Review error logs
- Check database performance metrics
- Verify backup completion
- Monitor storage usage

#### Monthly
- Review and optimize slow queries
- Update dependencies (`npm update`)
- Run security audit (`npm audit`)
- Review RLS policies for any needed updates

#### Quarterly
- Review and archive old data if needed
- Optimize database indexes
- Update database statistics
- Review and update documentation

---

## Troubleshooting

### Common Issues

#### Migration Fails to Apply

**Symptoms**: Error when running migration SQL

**Solutions**:
1. Check error message for specific issue
2. Verify syntax of SQL statements
3. Ensure dependencies (other tables/functions) exist
4. Check for naming conflicts
5. Review RLS policies that might block operations

#### Authentication Not Working

**Symptoms**: Users cannot sign up or sign in

**Solutions**:
1. Verify SUPABASE_URL and SUPABASE_ANON_KEY in `.env`
2. Check Supabase project is active
3. Review auth settings in Supabase dashboard
4. Check browser console for CORS errors
5. Verify email confirmation settings

#### RLS Policies Blocking Queries

**Symptoms**: Authorized users cannot access data

**Solutions**:
1. Review RLS policies for affected table
2. Verify `auth.uid()` matches expected user ID
3. Check if user is properly authenticated
4. Test with service role key to bypass RLS (debugging only)
5. Review policy conditions and joins

#### Database Connection Errors

**Symptoms**: Cannot connect to database

**Solutions**:
1. Verify Supabase project is active and not paused
2. Check SUPABASE_URL is correct
3. Verify API keys are valid
4. Check for IP restrictions in Supabase settings
5. Review connection pool limits

### Getting Help

- **Supabase Documentation**: [https://supabase.com/docs](https://supabase.com/docs)
- **Supabase Discord**: [https://discord.supabase.com](https://discord.supabase.com)
- **GitHub Issues**: Create detailed issue reports in project repository

### Emergency Contacts

- Database Administrator: [Add contact info]
- DevOps Lead: [Add contact info]
- Product Owner: [Add contact info]

---

## Appendix

### Useful SQL Queries

#### Check Migration Status
```sql
SELECT * FROM supabase_migrations.schema_migrations
ORDER BY version DESC;
```

#### View All RLS Policies
```sql
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
```

#### Check Table Sizes and Row Counts
```sql
SELECT
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size,
  (SELECT count(*) FROM (SELECT 1 FROM pg_class WHERE relname = tablename LIMIT 1) x) as table_exists
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;
```

#### View Recent Activity
```sql
SELECT * FROM profiles
ORDER BY last_active DESC
LIMIT 10;
```

---

*Last Updated: 2026-01-26*
*Version: 1.0*
