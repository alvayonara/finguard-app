# finguard-app

Mobile application for personal financial tracking, risk monitoring, and budget management.

The project focuses on:
- Modular feature-based architecture
- Provider-driven state management
- Secure authentication flow
- CI/CD automation

---

## Features Implemented

- Google Sign-In authentication + token refresh flow
- Feature-based modularization (dashboard, transaction, budget, risk, profile)
- REST API integration with Dio + interceptor layer
- CI/CD pipeline with signed APK release

---

## What's Inside?

**Mobile:** Flutter e, Dart

**State Management:** Provider + ChangeNotifier

**Networking:** Dio (with Alice HTTP inspector, debug only)

**Storage:** SharedPreferences

**Authentication:** Google Sign-In + JWT (access & refresh token)

**Charts:** fl_chart

**CI/CD:** GitHub Actions (debug & release pipelines)

**Code Signing:** Android Keystore (via GitHub Secrets)

---

## Project Structure

Split into feature modules:

```
finguard_app/
├── lib/
│   ├── core/                  # Network, storage, theme, utilities, app settings
│   └── features/
│       ├── auth/              # Login, token management
│       ├── dashboard/         # Home dashboard, financial overview
│       ├── transaction/       # Create, edit, delete transactions
│       ├── budget/            # Budget tracking
│       ├── category/          # Category management
│       ├── risk/              # Financial risk evaluation
│       ├── activity/          # Activity feed
│       ├── profile/           # User profile, subscription, app version
│       ├── user/              # User preferences (currency, language)
│       ├── subscription/      # In-app purchase flow
│       ├── app_config/        # Remote app configuration
│       ├── app_version/       # Force update / maintenance gate
│       └── splash/            # Splash & bootstrap
├── assets/
│   └── image/                 # Icons, illustrations
├── android/                   # Android native project
├── ios/                       # iOS native project
└── .github/
    └── workflows/             # GitHub Actions CI/CD pipelines
```

## License
```
Copyright 2026 Alva Yonara Puramandya
All rights reserved.

This repository is provided for portfolio and educational reference.
Commercial use, redistribution, or republishing without prior permission is not permitted.
```

