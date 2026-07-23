# Misinformation Diffusion Dashboard

Prototype dashboard for exploring how labelled misinformation spreads on X (formerly Twitter). It follows the project specification with a Flutter presentation layer, Express REST API, Prisma/MySQL data layer, dataset import, SNA summaries, charts, and downloadable reports.

## Features

- Account registration and JWT-protected sign-in
- CSV dataset upload, validation, hashtag extraction, interaction import, and duplicate/incomplete-row handling
- Dashboard totals, timelines, trending hashtags, and influential-user rankings
- Dataset-scoped API analysis using `?datasetId=<id>`
- Network nodes, edges, density, and degree-centrality calculations
- PDF and CSV report export endpoints

## CSV format

Required columns are `postId`, `author`, `content`, and `createdAt`. Optional interaction columns are `sourceUser`, `targetUser`, and `interactionType`. To mark a record as misinformation, include one of `isMisinformation`, `misinformation`, `label`, or `classification` with values such as `true`, `1`, `yes`, `misinformation`, `fake`, or `false`.

```csv
postId,author,content,createdAt,sourceUser,targetUser,interactionType,isMisinformation
1001,Alice,"Unverified claim #Election",2026-07-20T09:00:00Z,Alice,Bob,Retweet,true
```

## Run locally

1. Create a MySQL database named `misinformation_dashboard`.
2. In `Backend`, copy `.env.example` to `.env`, set a strong `JWT_SECRET`, and set `DATABASE_URL` to your local MySQL connection.
3. Run `npx prisma db push` from `Backend`, then `npm start`.
4. In a second terminal, run `flutter run -d chrome` (or a desktop target) from `frontend`.

The API starts at `http://localhost:5000`; the Flutter app uses that endpoint automatically on web and desktop.

## Key API endpoints

- `POST /api/auth/register`, `POST /api/auth/login`
- `POST /api/datasets/upload` (multipart field: `file`)
- `GET /api/analysis/dashboard?datasetId=1`
- `GET /api/analysis/network?datasetId=1`
- `GET /api/analysis/centrality?datasetId=1`
- `GET /api/reports/pdf/1`, `GET /api/reports/csv/1`
