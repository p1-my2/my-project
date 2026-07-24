const prisma = require("../config/prisma");

async function createDataset({ filename, status = "Uploaded", userId }) {
  return prisma.dataset.create({
    data: {
      filename,
      status,
      uploadedById: userId,
    },
  });
}

async function getDatasets({ search = "" } = {}) {
  return prisma.dataset.findMany({
    where: {
      filename: {
        contains: search,
      },
    },
    include: {
      uploadedBy: {
        select: {
          id: true,
          name: true,
          email: true,
          role: true,
        },
      },
      _count: {
        select: {
          posts: true,
        },
      },
    },
    orderBy: {
      uploadDate: "desc",
    },
  });
}

async function searchDatasets(keyword = "") {
  return prisma.dataset.findMany({
    where: {
      filename: {
        contains: keyword,
      },
    },
    include: {
      uploadedBy: {
        select: {
          id: true,
          name: true,
          email: true,
          role: true,
        },
      },
    },
    orderBy: {
      uploadDate: "desc",
    },
  });
}

async function getDataset(id) {
  return prisma.dataset.findUnique({
    where: {
      id: Number(id),
    },
    include: {
      uploadedBy: {
        select: {
          id: true,
          name: true,
          email: true,
          role: true,
        },
      },
      posts: {
        include: {
          hashtags: true,
          interactions: true,
        },
        orderBy: {
          createdAt: "asc",
        },
      },
      reports: true,
    },
  });
}

async function deleteDataset(id) {
  return prisma.dataset.delete({
    where: {
      id: Number(id),
    },
  });
}

module.exports = {
  createDataset,
  getDatasets,
  searchDatasets,
  getDataset,
  deleteDataset,
};
