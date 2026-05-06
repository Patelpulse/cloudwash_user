const ImageKit = require('imagekit');

const imagekit = new ImageKit({
    publicKey: process.env.IMAGEKIT_PUBLIC_KEY,
    privateKey: process.env.IMAGEKIT_PRIVATE_KEY,
    urlEndpoint: process.env.IMAGEKIT_URL_ENDPOINT
});

/**
 * Uploads a file to ImageKit
 * @param {Buffer|String} file - The file to upload (Buffer or base64 string)
 * @param {String} fileName - The name of the file
 * @param {String} folder - The folder to upload to
 * @returns {Promise<Object>} - The ImageKit upload response
 */
const uploadToImageKit = async (file, fileName, folder = 'cloud_wash') => {
    try {
        const response = await imagekit.upload({
            file: file,
            fileName: fileName,
            folder: folder
        });
        return response;
    } catch (error) {
        console.error('ImageKit Upload Error:', error);
        throw error;
    }
};

module.exports = { imagekit, uploadToImageKit };
