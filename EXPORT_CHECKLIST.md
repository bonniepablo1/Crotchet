# Export Checklist for Crotchet Dating App

Use this checklist before pushing to GitHub and deploying to production.

## Pre-Export Verification

### Code Quality
- [x] All TypeScript type checks pass (`npm run typecheck`)
- [x] ESLint passes with no errors (`npm run lint`)
- [x] Production build completes successfully (`npm run build`)
- [x] All smoke tests pass (`npm test`)

### Database
- [x] Database migrations are stored in `supabase/migrations/`
- [x] Seed data file created in `supabase/seed.sql`
- [x] All tables have Row Level Security (RLS) enabled
- [x] Database indexes are properly configured
- [x] Foreign key constraints are in place

### Documentation
- [x] README.md is complete and up-to-date
- [x] RUNBOOK.md contains operations procedures
- [x] .env.example lists all required environment variables
- [x] Code comments are clear and helpful

### Security
- [x] No hardcoded secrets or API keys in code
- [x] .env file is in .gitignore
- [x] RLS policies restrict data access appropriately
- [x] Authentication flows are secure
- [x] Service role keys are not exposed client-side

### Testing
- [x] Smoke tests cover critical functionality
- [x] Database schema integrity verified
- [x] Authentication flows tested
- [x] RLS policies validated

## GitHub Export Steps

### 1. Repository Setup
- [ ] Create new GitHub repository
- [ ] Add appropriate .gitignore (already included)
- [ ] Choose appropriate license
- [ ] Add repository description

### 2. Initial Commit
- [ ] Initialize git if not already done: `git init`
- [ ] Add all files: `git add .`
- [ ] Create initial commit: `git commit -m "Initial commit: Crotchet dating app"`
- [ ] Add remote: `git remote add origin <repository-url>`
- [ ] Push to GitHub: `git push -u origin main`

### 3. Repository Configuration
- [ ] Set up branch protection rules
- [ ] Configure GitHub Actions (optional)
- [ ] Add collaborators if needed
- [ ] Set repository visibility (public/private)

### 4. Documentation Review
- [ ] README.md displays correctly on GitHub
- [ ] Links in documentation work correctly
- [ ] Code examples are properly formatted
- [ ] Images and diagrams are accessible (if any)

## Deployment Preparation

### Environment Configuration
- [ ] Create production Supabase project (if different from staging)
- [ ] Apply all migrations to production database
- [ ] Create database backup before first deployment
- [ ] Configure environment variables in deployment platform

### Staging Verification
- [ ] Deploy to staging environment first
- [ ] Verify all features work in staging
- [ ] Test authentication flows
- [ ] Test profile creation and editing
- [ ] Test matching and messaging
- [ ] Check error handling
- [ ] Verify responsive design on mobile/desktop

### Production Deployment
- [ ] Review deployment checklist in RUNBOOK.md
- [ ] Create database backup
- [ ] Deploy application
- [ ] Verify environment variables
- [ ] Test critical user flows
- [ ] Monitor for errors in first hour
- [ ] Set up monitoring and alerts

## Post-Deployment

### Monitoring
- [ ] Set up error tracking (e.g., Sentry)
- [ ] Configure uptime monitoring
- [ ] Set up performance monitoring
- [ ] Enable database monitoring in Supabase

### Communication
- [ ] Notify team of successful deployment
- [ ] Share access credentials securely
- [ ] Document any deployment-specific notes
- [ ] Update project status/tracker

### Backup Strategy
- [ ] Enable automated Supabase backups
- [ ] Document backup retention policy
- [ ] Test backup restoration procedure
- [ ] Schedule regular backup verification

## Maintenance Plan

### Regular Tasks
- [ ] Weekly: Review error logs and performance metrics
- [ ] Monthly: Update dependencies and run security audit
- [ ] Quarterly: Review and optimize database performance
- [ ] Quarterly: Update documentation as needed

### Emergency Procedures
- [ ] Document rollback procedure
- [ ] Identify emergency contacts
- [ ] Create incident response plan
- [ ] Test disaster recovery process

## Optional Enhancements

### CI/CD Pipeline
- [ ] Set up GitHub Actions for automated testing
- [ ] Configure automatic deployments on merge to main
- [ ] Add automated security scanning
- [ ] Set up automated dependency updates

### Additional Features
- [ ] Set up CDN for static assets
- [ ] Configure custom domain
- [ ] Add analytics tracking
- [ ] Implement error logging service

---

## Sign-off

Before considering the export complete, ensure:

1. ✅ All items in "Pre-Export Verification" are checked
2. ✅ GitHub repository is properly configured
3. ✅ Staging environment is tested and working
4. ✅ Production deployment checklist is ready
5. ✅ Team is informed and documentation is accessible

**Prepared by**: _________________
**Date**: _________________
**Verified by**: _________________
**Date**: _________________

---

## Suggested Git Commit Message

```
feat: finalize migrations, seeds, smoke tests, runbook; ready for export

- Add comprehensive database seed data for testing
- Implement smoke test suite covering schema, auth, RLS
- Create operations runbook with migration and deployment procedures
- Add .env.example template for environment configuration
- Update README with testing and deployment instructions
- Verify production build and all tests passing
- Document export checklist and deployment workflow

All systems verified and ready for production deployment.
```

---

*Last Updated: 2026-01-26*
