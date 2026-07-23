const prisma = require("../config/prisma");
const { importInteractions } = require("./interactionService");

async function importPosts(datasetId, rows) {

  for (const row of rows) {

    // Skip incomplete rows
    if (!row.postId || !row.author || !row.content || !row.createdAt) {
      continue;
    }

    const createdAt = new Date(row.createdAt);
    if (Number.isNaN(createdAt.getTime())) continue;
    const label = String(row.isMisinformation ?? row.misinformation ?? row.label ?? row.classification ?? "").trim().toLowerCase();
    const isMisinformation = ["true", "1", "yes", "misinformation", "fake", "false"].includes(label);

    // Save the post
    const post = await prisma.post.create({
      data: {
        postId: row.postId,
        author: row.author,
        content: row.content,
        createdAt,
        isMisinformation,
        datasetId
      }
    });

    // Save interactions (if present)
    await importInteractions(post.id, row);

    // Extract hashtags
    const hashtags = row.content.match(/#[A-Za-z0-9_]+/g) || [];

    // Save hashtags
    for (const tag of hashtags) {
      await prisma.hashtag.create({
        data: {
          hashtag: tag,
          postId: post.id
        }
      });
    }

  }

}

module.exports = {
  importPosts
};
