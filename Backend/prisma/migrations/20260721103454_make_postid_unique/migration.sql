/*
  Warnings:

  - A unique constraint covering the columns `[postId]` on the table `Post` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateIndex
CREATE UNIQUE INDEX `Post_postId_key` ON `Post`(`postId`);
