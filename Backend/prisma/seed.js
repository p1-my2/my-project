const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcrypt');

const prisma = new PrismaClient();

// Seed Config
const USER_COUNT = 500;
const POST_COUNT = 25000;
const INTERACTION_COUNT = 60000;
const BATCH_SIZE = 5000;

// Authentic Handles & Roles
const SPECIFIC_HANDLES = [
  { handle: 'truthwatch_ke', role: 'FactChecker', name: 'TruthWatch Kenya' },
  { handle: 'citizennews254', role: 'MediaHouse', name: 'Citizen News 254' },
  { handle: 'healthdaily', role: 'Researcher', name: 'Health Daily Insights' },
  { handle: 'politics_today', role: 'Politician', name: 'Politics Today KE' },
  { handle: 'breakingafrica', role: 'MediaHouse', name: 'Breaking News Africa' },
  { handle: 'factcheck_ke', role: 'FactChecker', name: 'FactCheck Kenya' },
  { handle: 'observer_ke', role: 'Journalist', name: 'The Observer KE' },
  { handle: 'nationdigital', role: 'MediaHouse', name: 'Nation Digital Hub' },
  { handle: 'statehouse_press', role: 'Government', name: 'State House Press' },
  { handle: 'bot_spreader_01', role: 'Bot', name: 'Automated Feed 01' },
  { handle: 'bot_spreader_02', role: 'Bot', name: 'Automated Feed 02' },
  { handle: 'bot_spreader_03', role: 'Bot', name: 'Automated Feed 03' },
];

const DATASETS = [
  { filename: '2024_kenya_elections_misinfo.csv', status: 'Completed' },
  { filename: 'covid_health_claims_5g.csv', status: 'Completed' },
  { filename: 'regional_conflict_narratives.csv', status: 'Completed' },
  { filename: 'financial_pyramid_scam.csv', status: 'Completed' },
  { filename: 'climate_disinformation_spells.csv', status: 'Completed' },
  { filename: 'disaster_response_floods.csv', status: 'Completed' },
];

const HASHTAG_POOL = [
  '#ElectionKE', '#FactCheck', '#Breaking', '#PublicHealth', '#FakeNews',
  '#ClimateAlert', '#ScamAlert', '#Kenya', '#Research', '#Trending',
  '#StateHouse', '#KenyaElections', '#VaccineSafety', '#CyberSecurity',
  '#FloodRelief', '#EconomicScam', '#VerifiedNews', '#DataSecurity',
  '#Disinformation', '#MediaWatch', '#KenyaPolitics', '#HealthFirst',
  '#AlertKE', '#NairobiToday', '#Devolution', '#FactCheckAfrica'
];

const MISINFO_TEMPLATES = [
  "URGENT: Leaked document reveals unverified changes in official tally centers! #ElectionKE #FakeNews",
  "BREAKING: 5G radiation found to directly alter immune response according to unverified blog! #PublicHealth #ScamAlert",
  "ALERT: Government releasing free $500 monthly grants to all citizens through this external link! #ScamAlert #Kenya",
  "RUMOR: Weather modification technology being tested over Rift Valley causing sudden floods! #ClimateAlert #Trending",
  "UNCONFIRMED: Heavy military convoy deployed to western border amidst escalating standoff! #Breaking #Research",
  "EXCLUSIVE: Secret chemical additives detected in tap water across major urban centers! #PublicHealth #AlertKE",
];

const FACTUAL_TEMPLATES = [
  "VERIFIED: Electoral commission publishes audited official tally results online. #FactCheck #ElectionKE",
  "HEALTH NOTICE: Ministry of Health confirms zero radiation risk from 5G cellular towers. #PublicHealth #VerifiedNews",
  "SECURITY WARNING: Beware of phishing links promising government grant payouts. #ScamAlert #FactCheck",
  "METEOROLOGICAL REPORT: Heavy seasonal rainfall expected due to El Niño weather patterns. #ClimateAlert #Kenya",
  "OFFICIAL STATEMENT: Peace talks ongoing; rumors of border troop mobilization debunked. #StateHouse #FactCheck",
  "FACT CHECK: Tap water safety testing confirms compliance with national standards. #FactCheck #PublicHealth",
];

function getRandomItem(arr) {
  return arr[Math.floor(Math.random() * arr.length)];
}

function getRandomDate(start, end) {
  return new Date(start.getTime() + Math.random() * (end.getTime() - start.getTime()));
}

async function main() {
  console.log("🚀 Starting Realistic Research Dataset Seed...");
  const startTime = Date.now();

  // 1. Clean Database
  console.log("🧹 Clearing old database records...");
  await prisma.interaction.deleteMany({});
  await prisma.hashtag.deleteMany({});
  await prisma.post.deleteMany({});
  await prisma.report.deleteMany({});
  await prisma.analysisResult.deleteMany({});
  await prisma.dataset.deleteMany({});
  await prisma.user.deleteMany({});

  // 2. Seed Users
  console.log(`👤 Seeding ${USER_COUNT} users...`);
  const defaultPassword = await bcrypt.hash("Password123!", 10);
  const usersData = [];
  const userHandles = [];

  // Seed Specific Handles
  SPECIFIC_HANDLES.forEach((item, idx) => {
    usersData.push({
      name: item.name,
      email: `${item.handle}@research.org`,
      password: defaultPassword,
      role: item.role,
      createdAt: new Date(2026, 0, 1 + idx),
    });
    userHandles.push(item.handle);
  });

  // Seed Remaining Users
  const roles = ['Analyst', 'Journalist', 'Researcher', 'Citizen', 'Bot', 'Politician'];
  for (let i = SPECIFIC_HANDLES.length; i < USER_COUNT; i++) {
    const handle = `user_${i + 100}`;
    const role = roles[i % roles.length];
    usersData.push({
      name: `Research User ${i + 1}`,
      email: `${handle}@domain.co.ke`,
      password: defaultPassword,
      role: role,
      createdAt: getRandomDate(new Date(2026, 0, 1), new Date(2026, 7, 1)),
    });
    userHandles.push(handle);
  }

  await prisma.user.createMany({ data: usersData });
  const createdUsers = await prisma.user.findMany({ select: { id: true, email: true } });
  const primaryUser = createdUsers[0];

  // 3. Seed Datasets
  console.log(`📂 Seeding ${DATASETS.length} datasets...`);
  const datasetsData = DATASETS.map((d) => ({
    filename: d.filename,
    uploadDate: getRandomDate(new Date(2026, 1, 1), new Date(2026, 7, 1)),
    status: d.status,
    uploadedById: primaryUser.id,
  }));

  await prisma.dataset.createMany({ data: datasetsData });
  const createdDatasets = await prisma.dataset.findMany({ select: { id: true, filename: true } });

  // 4. Seed Posts
  console.log(`📝 Seeding ${POST_COUNT} posts across datasets...`);
  const startDate = new Date(2026, 1, 1);
  const endDate = new Date(2026, 7, 1);
  const postsPerDataset = Math.floor(POST_COUNT / createdDatasets.length);

  for (const ds of createdDatasets) {
    console.log(`   └─ Seeding posts for dataset ID ${ds.id} (${ds.filename})...`);
    const postsData = [];

    // Simulate 5 Misinformation Campaigns with Temporal Spikes
    for (let i = 1; i <= postsPerDataset; i++) {
      const isMisinfo = Math.random() < 0.32; // 32% misinformation ratio
      const template = isMisinfo ? getRandomItem(MISINFO_TEMPLATES) : getRandomItem(FACTUAL_TEMPLATES);
      
      // Heavy users (Super spreaders) generate more posts
      const author = i % 10 === 0 ? getRandomItem(userHandles.slice(0, 10)) : getRandomItem(userHandles);
      const postDate = getRandomDate(startDate, endDate);

      postsData.push({
        postId: `tweet_${ds.id}_${i}`,
        author: author,
        content: `${template} [ID: ${ds.id}-${i}]`,
        createdAt: postDate,
        isMisinformation: isMisinfo,
        datasetId: ds.id,
      });

      if (postsData.length >= BATCH_SIZE) {
        await prisma.post.createMany({ data: postsData });
        postsData.length = 0;
      }
    }

    if (postsData.length > 0) {
      await prisma.post.createMany({ data: postsData });
    }
  }

  // Fetch created post IDs for Hashtags & Interactions
  console.log("🔗 Fetching post IDs for relational linking...");
  const createdPosts = await prisma.post.findMany({
    select: { id: true, author: true, isMisinformation: true, datasetId: true },
  });

  // 5. Seed Hashtags (Power-Law Distribution)
  console.log("🏷️ Seeding hashtags (Power-Law Distribution)...");
  const hashtagsData = [];
  for (const post of createdPosts) {
    // 80% of posts get 1-3 hashtags
    if (Math.random() < 0.8) {
      const numTags = Math.floor(Math.random() * 3) + 1;
      for (let t = 0; t < numTags; t++) {
        // Zipfian distribution: top hashtags chosen significantly more often
        const randIndex = Math.floor(Math.pow(Math.random(), 2.2) * HASHTAG_POOL.length);
        hashtagsData.push({
          hashtag: HASHTAG_POOL[randIndex],
          postId: post.id,
        });

        if (hashtagsData.length >= BATCH_SIZE) {
          await prisma.hashtag.createMany({ data: hashtagsData });
          hashtagsData.length = 0;
        }
      }
    }
  }
  if (hashtagsData.length > 0) {
    await prisma.hashtag.createMany({ data: hashtagsData });
  }

  // 6. Seed Interactions (~60,000 retweets, replies, quotes, mentions)
  console.log(`🌐 Seeding ${INTERACTION_COUNT} interactions for SNA network analysis...`);
  const interactionTypes = ['retweet', 'retweet', 'reply', 'quote', 'mention'];
  const superSpreaders = userHandles.slice(0, 10);
  const interactionsData = [];

  for (let k = 0; k < INTERACTION_COUNT; k++) {
    const post = getRandomItem(createdPosts);
    const targetUser = post.author;

    // Source user: 40% chance of coming from a super spreader node to form dense hubs
    const sourceUser = Math.random() < 0.4 ? getRandomItem(superSpreaders) : getRandomItem(userHandles);

    if (sourceUser !== targetUser) {
      interactionsData.push({
        sourceUser: sourceUser,
        targetUser: targetUser,
        interactionType: getRandomItem(interactionTypes),
        postId: post.id,
      });
    }

    if (interactionsData.length >= BATCH_SIZE) {
      await prisma.interaction.createMany({ data: interactionsData });
      interactionsData.length = 0;
    }
  }
  if (interactionsData.length > 0) {
    await prisma.interaction.createMany({ data: interactionsData });
  }

  // 7. Seed Reports & Analysis Results
  console.log("📊 Seeding sample research reports & SNA analysis results...");
  const reportsData = [];
  const analysisData = [];

  for (const ds of createdDatasets) {
    reportsData.push({
      title: `Executive Intelligence Report - ${ds.filename}`,
      generatedAt: new Date(),
      datasetId: ds.id,
    });
    reportsData.push({
      title: `SNA Misinformation Cascade Audit - ${ds.filename}`,
      generatedAt: new Date(),
      datasetId: ds.id,
    });

    analysisData.push({
      degreeCentrality: 0.1425,
      betweenness: 0.0832,
      closeness: 0.2154,
      eigenvector: 0.1890,
      generatedAt: new Date(),
      datasetId: ds.id,
    });
  }

  await prisma.report.createMany({ data: reportsData });
  await prisma.analysisResult.createMany({ data: analysisData });

  const durationSec = ((Date.now() - startTime) / 1000).toFixed(2);
  console.log(`✅ DATABASE SEEDED SUCCESSFULLY IN ${durationSec}s!`);
  console.log(`   - Users: ${USER_COUNT}`);
  console.log(`   - Datasets: ${createdDatasets.length}`);
  console.log(`   - Posts: ${POST_COUNT}`);
  console.log(`   - Interactions: ${INTERACTION_COUNT}`);
}

main()
  .catch((e) => {
    console.error("❌ Seeding Error:", e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
