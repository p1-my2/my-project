const prisma = require("../config/prisma");

async function importInteractions(postId, row) {

  // Skip if interaction data is missing
  if (!row.sourceUser || !row.targetUser || !row.interactionType) {
    return;
  }

  await prisma.interaction.create({
    data: {
      sourceUser: row.sourceUser,
      targetUser: row.targetUser,
      interactionType: row.interactionType,
      postId
    }
  });

}

module.exports = {
  importInteractions
};