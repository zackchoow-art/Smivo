# Deployment Workflow for Smivo Website & Admin Panel

// turbo-all

## When to use this workflow
This workflow must be followed whenever you (the agent) are asked to "push changes", "deploy the site", or if you have modified any files related to the Admin Dashboard (`lib/features/admin/...`) or static website files (`website/...`).

## Deployment Steps
Do NOT run `git push` directly if there are changes to the website or admin panel. 
Instead, always execute the `deploy.sh` script located in the root of the project.

Run the following command:
```bash
./deploy.sh "commit message describing your changes"
```

### What this script does:
1. Runs `flutter build web --base-href /admin/` to compile the Flutter app for the web.
2. Replaces the `website/admin` folder with the newly compiled `build/web` files.
3. Automatically commits the changes and pushes to `origin main`.
4. Vercel will automatically detect the push to GitHub and deploy the updated files.
