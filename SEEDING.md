# Synthetic Research Dataset Documentation & Seeding Blueprint

## 1. Dataset Overview & Composition

The synthetic research dataset is engineered specifically for the **Misinformation Diffusion Dashboard**. It simulates real-world X (formerly Twitter) social network interaction dynamics, misinformation cascades, viral spikes, and influencer hierarchies across 6 distinct research datasets.

```
                     SYNTHETIC RESEARCH DATASET VOLUMES
  
  ┌─────────────────────────┐     ┌─────────────────────────┐     ┌─────────────────────────┐
  │      500 USERS          │     │    6 RESEARCH DATASETS  │     │      25,000 POSTS       │
  │ • Media Outlets (15%)   │     │ • 2024 Kenya Elections  │     │ • Misinfo Ratio: ~32%   │
  │ • Fact Checkers (10%)   │ ──► │ • COVID Health Claims   │ ──► │ • Factual Ratio: ~68%   │
  │ • Politicians (15%)     │     │ • Regional Conflict     │     │ • Authentic Headlines   │
  │ • Super-spreaders (20%) │     │ • Financial Scams       │     │ • Zipfian Hashtags      │
  │ • Citizens & Bots (40%) │     │ • Climate / Disaster    │     │                         │
  └─────────────────────────┘     └─────────────────────────┘     └─────────────────────────┘
                                                │
                                                ▼
                                  ┌───────────────────────────┐
                                  │   60,000 INTERACTIONS     │
                                  │ • Retweets (50%)          │
                                  │ • Replies (25%)           │
                                  │ • Quotes (15%)            │
                                  │ • Mentions (10%)          │
                                  └───────────────────────────┘
```

---

## 2. Research Network Characteristics

1. **Super-Spreader Hubs**:
   - Accounts like `@truthwatch_ke`, `@citizennews254`, `@politics_today`, and `@breakingafrica` possess high in-degree and out-degree centrality.
   - High **Reach Score** ($\text{Followers} \times \text{Spread Count}$) accounts drive major diffusion trees.

2. **Power-Law Hashtag Distribution**:
   - Follows a natural Zipfian power-law curve: Top hashtags (`#ElectionKE`, `#FactCheck`, `#PublicHealth`, `#FakeNews`) appear in ~40% of posts, mid-tier tags in 35%, and long-tail niche tags in 25%.

3. **Multi-Tier Interaction Cascades**:
   - Interaction paths form multi-hop trees ($A \rightarrow B \rightarrow C \rightarrow D$), demonstrating depth evolution from origin accounts to secondary amplifiers.

---

## 3. Simulated Misinformation Campaigns

| Campaign Name | Target Dataset | Origin Account | Narrative Summary | Peak Window |
| :--- | :--- | :--- | :--- | :--- |
| **Tally Center Alteration Rumor** | `2024_kenya_elections_misinfo.csv` | `@politics_today` | Allegations of unverified tally adjustments at central polling hubs. | Feb 2026 (Day 3-5) |
| **5G Immunity Suppression Claim** | `covid_health_claims_5g.csv` | `@healthdaily` | Claims that cellular tower frequencies suppress human immune responses. | Mar 2026 (Day 2-6) |
| **Fake Government Grant Link** | `financial_pyramid_scam.csv` | `@bot_spreader_01` | Phishing campaign promising $500 monthly payouts to all registered citizens. | Apr 2026 (Day 1-4) |
| **Rift Valley Geoengineering** | `climate_disinformation_spells.csv` | `@observer_ke` | Weather modification experiments blamed for sudden seasonal flooding. | May 2026 (Day 4-8) |
| **Border Troop Mobilization** | `regional_conflict_narratives.csv` | `@breakingafrica` | Unverified rumors of heavy military deployment near regional border. | Jun 2026 (Day 2-5) |

---

## 4. How to Reseed the Database

To wipe existing records and re-seed clean research data:

```bash
cd Backend
npm run seed
```
*Alternatively:*
```bash
node prisma/seed.js
```

Execution takes approximately **15 – 25 seconds** and populates:
- **500 Users** (Password: `Password123!`)
- **6 Datasets**
- **25,000 Posts**
- **60,000 Network Interactions**
- **Sample Reports & SNA Analysis Results**

---

## 5. Expected Dashboard Behavior

Upon launching the Flutter dashboard after seeding:

1. **Dashboard Home**:
   - KPI cards display **500 Users**, **6 Datasets**, **25,000 Posts**, **150 Hashtags**, and **~8,000 Misinformation Posts**.
2. **SNA Graph Canvas**:
   - Concentric force-directed layout renders dense interaction clusters around super-spreader hubs with crimson/amber/emerald risk color tiers.
3. **Propagation Velocity Timeline**:
   - Clear multi-wave line graph showing misinformation volume spikes during campaign peak dates.
4. **Top Spreaders Leaderboard**:
   - Correctly ranks `@truthwatch_ke`, `@citizennews254`, `@politics_today`, and `@breakingafrica` based on Reach Score.
5. **Multi-Dataset Filtering**:
   - Switching datasets reactively updates the network graph, top spreaders, hashtags, and timeline charts.
