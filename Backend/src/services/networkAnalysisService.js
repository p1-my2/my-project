/** Lightweight, dependency-free social network analysis for the prototype. */
function buildNetwork(interactions) {
  const nodes = new Map();
  const edges = [];
  const ensureNode = (id) => {
    if (!nodes.has(id)) nodes.set(id, { id, inDegree: 0, outDegree: 0 });
    return nodes.get(id);
  };
  interactions.forEach((interaction) => {
    const source = String(interaction.sourceUser || '').trim();
    const target = String(interaction.targetUser || '').trim();
    if (!source || !target) return;
    ensureNode(source).outDegree += 1;
    ensureNode(target).inDegree += 1;
    edges.push({ source, target, type: interaction.interactionType, postId: interaction.post?.postId });
  });
  const totalNodes = nodes.size;
  const rankedNodes = [...nodes.values()]
    .map((node) => ({ ...node, degree: node.inDegree + node.outDegree,
      degreeCentrality: totalNodes > 1 ? Number(((node.inDegree + node.outDegree) / (totalNodes - 1)).toFixed(4)) : 0 }))
    .sort((a, b) => b.degree - a.degree || a.id.localeCompare(b.id));
  return { nodes: rankedNodes, edges, summary: {
    totalNodes, totalEdges: edges.length,
    density: totalNodes > 1 ? Number((edges.length / (totalNodes * (totalNodes - 1))).toFixed(4)) : 0,
  }};
}
module.exports = { buildNetwork };
