# Investigation Report: DAU Metrics Discrepancy & Heartbeat Mechanism

**Date:** 2026-05-09
**Subject:** Active User Metrics (DAU/WAU/MAU) showing 0 despite active sessions.

## 1. Problem Statement
The Admin Dashboard reports 0 Daily Active Users (DAU), Weekly Active Users (WAU), and Monthly Active Users (MAU). However, user activity is visible in real-time within the app and chat interfaces.

## 2. Root Cause Analysis
The investigation revealed a complete disconnect between the data ingestion path (App) and the data aggregation path (Database).

### Data Flow Mismatch
- **Database Design**: The analytics system depends on the `hourly_active_users` table (time buckets). The logic to populate this table is contained within the `ping_user_presence` RPC function.
- **App Implementation**: In `ProfileRepository.dart`, the app performs a direct `upsert` to the `user_heartbeats` table instead of calling the designated RPC.
- **Failure Point**: Direct table writes do not trigger the aggregation logic needed for analytics. Consequently, the `hourly_active_users` table remains empty, leading to 0 metrics in the dashboard.

## 3. Comparison of Fixes

### Option A: Backend Hotfix (Database Trigger) - RECOMMENDED
- **Implementation**: Add a trigger to the `user_heartbeats` table to automatically update the `hourly_active_users` bucket.
- **Pros**: 
  - **Zero App Update**: Works instantly for all users on all versions.
  - **Data Integrity**: Guaranteed statistics regardless of which client writes the data.
- **Cons**: Slightly increased write overhead on the DB.

### Option B: Frontend Refactor (RPC Call)
- **Implementation**: Change `ProfileRepository.dart` to call the `ping_user_presence` RPC.
- **Pros**: Cleanest architecture; follows the original explicit design.
- **Cons**: Requires a full app release cycle; old versions remain "invisible" to analytics.

## 4. Architectural Rationale
- **Why RPC?** Originally chosen for explicit control and security (Security Definier allows privileged writes without granting direct table permissions to users).
- **Why Trigger now?** To solve the immediate data visibility issue and provide a fail-safe mechanism that works across all future client implementations.

## 5. Conclusion & Recommendations
The current discrepancy is a coordination failure between frontend and backend. 
- **Short-term**: Deploy a database trigger to resume data collection immediately without waiting for an app store release.
- **Long-term**: Standardize the app code to use the RPC for better governance.

---
*End of Report*
