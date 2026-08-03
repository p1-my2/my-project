# Research Intelligence Dashboard Architecture

## 1. System Overview
The **Research Intelligence Dashboard for Misinformation Diffusion Analysis** is an academic Design Science Research (DSR) artifact. It combines a **mobile-first Flutter frontend** with a **Node.js/Express backend** and a **MySQL relational database (Prisma ORM)**.

```
+-----------------------------------------------------------------------+
|                    Research Intelligence Dashboard                    |
|                        Flutter 3.x (Dart SDK)                         |
+-----------------------------------------------------------------------+
|  DashboardProvider (Centralized Reactive State via ChangeNotifier)   |
|  - Active Dataset Selection                                           |
|  - Network Graph Data Model (Nodes & Edges)                           |
|  - Timeline Velocity Data                                             |
|  - Top Spreaders & Hashtags Metrics                                   |
+-----------------------------------------------------------------------+
                                   |
                         HTTP REST API (JSON)
                                   |
+-----------------------------------------------------------------------+
|                    Express.js Backend API Engine                      |
|  - Middleware: Structured JSON Request Logger                         |
|  - Utils: Standardized API Envelopes ({ success, data, meta })         |
|  - Services: SNA Processing, Timeline Analytics, PDF/CSV Reports      |
+-----------------------------------------------------------------------+
                                   |
                              Prisma ORM
                                   |
+-----------------------------------------------------------------------+
|                         MySQL 8.4 Database                            |
|  - Datasets, Posts, Users, Hashtags, Interactions, Reports            |
+-----------------------------------------------------------------------+
```

## 2. Key SNA & Amplification Metrics

1. **Degree Centrality ($C_D$)**: Direct user interaction connectivity relative to graph size.
   $$C_D(v) = \frac{\text{inDegree}(v) + \text{outDegree}(v)}{N - 1}$$

2. **Reach Score ($R_S$)**: Amplification potential metric combining network position and interaction volume.
   $$R_S(v) = C_D(v) \times 1000 + \text{outDegree}(v) \times 50$$

3. **Propagation Velocity**: Count of misinformation vs factual posts aggregated over temporal windows.

## 3. Responsive Layout Grid Breakpoints

- **Phone (< 600px)**: Single column touch layout with navigation drawer, top swipeable metric tiles, full-screen graph canvas, and bottom sheet inspectors.
- **Tablet (600px - 1024px)**: 2-panel split view (Graph canvas 70%, Inspector/Analytics panel 30%).
- **Desktop (> 1024px)**: 12-column research intelligence grid where the **Network Graph is the central research artifact (60% width)**, flanked by Timeline & Top Spreaders leaderboards (40% width).

## 4. Design System Tokens (`ResearchTheme`)

- **Light Mode Surface**: `#FFFFFF`, Background: `#F8FAFC`, Border: `#E2E8F0`, Primary: `#4F46E5` (Indigo).
- **Dark Mode Surface**: `#1E293B`, Background: `#0F172A`, Border: `#334155`, Primary: `#38BDF8` (Sky Blue).
- **Risk Classification Tokens**:
  - High Risk / Misinformation Hub: Crimson `#EF4444`
  - Moderate Risk / Warning: Amber `#F59E0B`
  - Low Risk / Verified Factual: Emerald `#10B981`
  - Neutral Node: Slate `#64748B`
