---
description: 
---

# Workflow: Generate Tests

Use this after completing a repository or provider file.

## Steps

1. Read the target file in full before writing any tests.
2. Identify: all public methods, all state transitions, all error paths.
3. Create the test file mirroring the lib/ path under test/:
lib/data/repositories/listing_repository.dart
-> test/data/repositories/listing_repository_test.dart
4. Write tests following [testing.md](http://testing.md/) rules:
    - Arrange / Act / Assert structure
    - Use mocktail for all mocks
    - Place mock classes in test/mocks/ if not already there
    - Place fake data in test/fixtures/
    - Cover: success case, empty result, error/exception case
5. Run: flutter test [test_file_path]
Fix any failures before reporting done.
6. Output: number of tests written, coverage of public methods.