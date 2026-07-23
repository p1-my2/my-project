const prisma = require("../config/prisma");
const fs = require("fs");
const csv = require("csv-parser");

/**
 * Upload CSV Dataset
 * Expected CSV columns:
 * postId,author,content,createdAt,sourceUser,targetUser,interactionType
 */
async function uploadDataset(req, res) {
    try {
        // Check if a file was uploaded
        if (!req.file) {
            return res.status(400).json({
                success: false,
                message: "CSV file is required."
            });
        }

        // Check authenticated user
        if (!req.user || !req.user.id) {
            return res.status(401).json({
                success: false,
                message: "Unauthorized."
            });
        }

        // Create dataset record
        const dataset = await prisma.dataset.create({
            data: {
                filename: req.file.filename,
                status: "Uploaded",
                uploadedById: req.user.id
            }
        });

        const rows = [];

        fs.createReadStream(req.file.path)
            .pipe(csv())
            .on("data", (row) => {
                rows.push(row);
            })
            .on("end", async () => {
                try {
                    let imported = 0;
                    let skipped = 0;

                    for (const row of rows) {
                        // Skip duplicate posts
                        const existingPost = await prisma.post.findUnique({
                            where: {
                                postId: String(row.postId)
                            }
                        });

                        if (existingPost) {
                            skipped++;
                            continue;
                        }

                        // Create post
                        const post = await prisma.post.create({
                            data: {
                                postId: String(row.postId),
                                author: row.author,
                                content: row.content,
                                createdAt: new Date(row.createdAt),
                                isMisinformation: false,
                                datasetId: dataset.id
                            }
                        });

                        // Extract hashtags
                        const hashtags = row.content.match(/#\w+/g) || [];

                        for (const tag of hashtags) {
                            await prisma.hashtag.create({
                                data: {
                                    hashtag: tag,
                                    postId: post.id
                                }
                            });
                        }

                        // Create interaction
                        if (
                            row.sourceUser &&
                            row.targetUser &&
                            row.interactionType
                        ) {
                            await prisma.interaction.create({
                                data: {
                                    sourceUser: row.sourceUser,
                                    targetUser: row.targetUser,
                                    interactionType: row.interactionType,
                                    postId: post.id
                                }
                            });
                        }

                        imported++;
                    }

                    // Remove uploaded file after processing
                    fs.unlink(req.file.path, (err) => {
                        if (err) {
                            console.error("Failed to delete uploaded file:", err);
                        }
                    });

                    return res.status(200).json({
                        success: true,
                        message: "Dataset uploaded successfully.",
                        dataset,
                        summary: {
                            totalRows: rows.length,
                            imported,
                            skipped
                        }
                    });
                } catch (error) {
                    console.error(error);

                    return res.status(500).json({
                        success: false,
                        message: error.message
                    });
                }
            })
            .on("error", (error) => {
                console.error(error);

                return res.status(500).json({
                    success: false,
                    message: "Error reading CSV file."
                });
            });

    } catch (error) {
        console.error(error);

        return res.status(500).json({
            success: false,
            message: error.message
        });
    }
}

module.exports = {
    uploadDataset
};