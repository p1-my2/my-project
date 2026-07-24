const prisma = require("../config/prisma");

function parseBoolean(val) {
  const label = String(val ?? "").trim().toLowerCase();
  return ["true", "1", "yes", "misinformation", "fake"].includes(label);
}

function parseDate(val) {
  const date = new Date(val);
  return Number.isNaN(date.getTime()) ? null : date;
}

async function importPosts(datasetId, rows) {
  if (!Array.isArray(rows) || rows.length === 0) {
    return { totalRows: 0, imported: 0, skipped: 0 };
  }

  const validRows = [];
  const seenInBatch = new Set();
  let skipped = 0;

  for (const row of rows) {
    if (!row.postId || !row.author || !row.content || !row.createdAt) {
      skipped++;
      continue;
    }

    const createdAt = parseDate(row.createdAt);
    if (!createdAt) {
      skipped++;
      continue;
    }

    const postIdStr = String(row.postId).trim();
    if (!postIdStr || seenInBatch.has(postIdStr)) {
      skipped++;
      continue;
    }

    seenInBatch.add(postIdStr);
    validRows.push({
      ...row,
      postIdStr,
      createdAt,
    });
  }

  if (validRows.length === 0) {
    return { totalRows: rows.length, imported: 0, skipped };
  }

  const validPostIds = validRows.map((r) => r.postIdStr);
  const existingInDb = await prisma.post.findMany({
    where: {
      datasetId: Number(datasetId),
      postId: { in: validPostIds },
    },
    select: { postId: true },
  });

  const existingSet = new Set(existingInDb.map((p) => p.postId));
  const newRows = validRows.filter((r) => !existingSet.has(r.postIdStr));
  skipped += (validRows.length - newRows.length);

  if (newRows.length === 0) {
    return { totalRows: rows.length, imported: 0, skipped };
  }

  const postCreateData = newRows.map((row) => {
    const rawLabel = row.isMisinformation ?? row.misinformation ?? row.label ?? row.classification;
    const isMisinformation = parseBoolean(rawLabel);
    return {
      postId: row.postIdStr,
      author: String(row.author),
      content: String(row.content),
      createdAt: row.createdAt,
      isMisinformation,
      datasetId: Number(datasetId),
    };
  });

  const importedCount = await prisma.$transaction(async (tx) => {
    await tx.post.createMany({
      data: postCreateData,
    });

    const createdPosts = await tx.post.findMany({
      where: {
        datasetId: Number(datasetId),
        postId: { in: newRows.map((r) => r.postIdStr) },
      },
      select: { id: true, postId: true },
    });

    const postIdToDbIdMap = new Map(createdPosts.map((p) => [p.postId, p.id]));

    const hashtagsToCreate = [];
    const interactionsToCreate = [];

    for (const row of newRows) {
      const dbPostId = postIdToDbIdMap.get(row.postIdStr);
      if (!dbPostId) continue;

      const extractedTags = String(row.content).match(/#[A-Za-z0-9_]+/g) || [];
      for (const tag of extractedTags) {
        hashtagsToCreate.push({
          hashtag: tag,
          postId: dbPostId,
        });
      }

      if (row.sourceUser && row.targetUser && row.interactionType) {
        interactionsToCreate.push({
          sourceUser: String(row.sourceUser),
          targetUser: String(row.targetUser),
          interactionType: String(row.interactionType),
          postId: dbPostId,
        });
      }
    }

    if (hashtagsToCreate.length > 0) {
      await tx.hashtag.createMany({
        data: hashtagsToCreate,
      });
    }

    if (interactionsToCreate.length > 0) {
      await tx.interaction.createMany({
        data: interactionsToCreate,
      });
    }

    return newRows.length;
  });

  return {
    totalRows: rows.length,
    imported: importedCount,
    skipped,
  };
}

module.exports = {
  importPosts,
};
