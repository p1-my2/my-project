-- Drop index
DROP INDEX `Post_postId_key` ON `Post`;

-- CreateIndex
CREATE UNIQUE INDEX `Post_datasetId_postId_key` ON `Post`(`datasetId`, `postId`);

-- CreateIndex
CREATE INDEX `Dataset_uploadDate_idx` ON `Dataset`(`uploadDate`);
CREATE INDEX `Dataset_uploadedById_idx` ON `Dataset`(`uploadedById`);

-- CreateIndex
CREATE INDEX `Post_createdAt_idx` ON `Post`(`createdAt`);
CREATE INDEX `Post_datasetId_idx` ON `Post`(`datasetId`);
CREATE INDEX `Post_isMisinformation_idx` ON `Post`(`isMisinformation`);

-- CreateIndex
CREATE INDEX `Hashtag_hashtag_idx` ON `Hashtag`(`hashtag`);
CREATE INDEX `Hashtag_postId_idx` ON `Hashtag`(`postId`);

-- CreateIndex
CREATE INDEX `Interaction_sourceUser_idx` ON `Interaction`(`sourceUser`);
CREATE INDEX `Interaction_targetUser_idx` ON `Interaction`(`targetUser`);
CREATE INDEX `Interaction_postId_idx` ON `Interaction`(`postId`);

-- CreateIndex
CREATE INDEX `AnalysisResult_datasetId_idx` ON `AnalysisResult`(`datasetId`);
CREATE INDEX `Report_datasetId_idx` ON `Report`(`datasetId`);

-- DropForeignKey
ALTER TABLE `Dataset` DROP FOREIGN KEY `Dataset_uploadedById_fkey`;
ALTER TABLE `Post` DROP FOREIGN KEY `Post_datasetId_fkey`;
ALTER TABLE `Hashtag` DROP FOREIGN KEY `Hashtag_postId_fkey`;
ALTER TABLE `Interaction` DROP FOREIGN KEY `Interaction_postId_fkey`;
ALTER TABLE `AnalysisResult` DROP FOREIGN KEY `AnalysisResult_datasetId_fkey`;
ALTER TABLE `Report` DROP FOREIGN KEY `Report_datasetId_fkey`;

-- AddForeignKey
ALTER TABLE `Dataset` ADD CONSTRAINT `Dataset_uploadedById_fkey` FOREIGN KEY (`uploadedById`) REFERENCES `User`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Post` ADD CONSTRAINT `Post_datasetId_fkey` FOREIGN KEY (`datasetId`) REFERENCES `Dataset`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Hashtag` ADD CONSTRAINT `Hashtag_postId_fkey` FOREIGN KEY (`postId`) REFERENCES `Post`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Interaction` ADD CONSTRAINT `Interaction_postId_fkey` FOREIGN KEY (`postId`) REFERENCES `Post`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `AnalysisResult` ADD CONSTRAINT `AnalysisResult_datasetId_fkey` FOREIGN KEY (`datasetId`) REFERENCES `Dataset`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `Report` ADD CONSTRAINT `Report_datasetId_fkey` FOREIGN KEY (`datasetId`) REFERENCES `Dataset`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
