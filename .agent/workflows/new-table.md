---
description: 
---

# Workflow: New Database Table

Use this when adding a new table to Supabase.

## Steps

1. Ask the user: "这张表存储什么数据？有哪些字段和关联关系？"
2. Output the SQL migration for review before anything else:
    - Table with id (uuid, default gen_random_uuid()), created_at, updated_at
    - All columns with correct types and NOT NULL constraints
    - Foreign key references with ON DELETE behavior specified
    - Row Level Security enabled (ALTER TABLE ... ENABLE ROW LEVEL SECURITY)
    - RLS policies for: SELECT, INSERT, UPDATE, DELETE
    
    Wait for user to confirm SQL before proceeding.
    
3. Create the Dart model in lib/data/models/[name].dart using freezed.
Run: dart run build_runner build
4. Create the repository in lib/data/repositories/[name]_repository.dart
with CRUD methods matching the table's use case.
5. Add the repository as a Riverpod provider in lib/core/.
6. Output a summary: table name, columns, RLS policies, files created.