const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');

// Initialize Firebase Admin SDK
try {
    // Check if already initialized
    if (!admin.apps.length) {
        let credential;

        // Try to find service account key in multiple locations
        const possiblePaths = [
            path.join(__dirname, '../../firebase-admin-key.json'),
            path.join(__dirname, '../../serviceAccountKey.json'),
            process.env.GOOGLE_APPLICATION_CREDENTIALS
        ];

        let serviceAccountPath = null;
        for (const filePath of possiblePaths) {
            if (filePath && fs.existsSync(filePath)) {
                serviceAccountPath = filePath;
                break;
            }
        }

        if (serviceAccountPath) {
            // Use service account key file
            const serviceAccount = require(serviceAccountPath);
            credential = admin.credential.cert(serviceAccount);
            console.log('✅ Firebase Admin initialized with service account key');
        } else {
            // Fall back to application default credentials
            credential = admin.credential.applicationDefault();
            console.log('✅ Firebase Admin initialized with default credentials');
        }

        admin.initializeApp({ credential });
    }
} catch (error) {
    console.warn('⚠️ Firebase Admin initialization failed:', error.message);
    console.log('💡 Firebase sync features will be disabled. To enable:');
    console.log('   1. Download service account key from Firebase Console');
    console.log('   2. Save as: backend/firebase-admin-key.json');
    console.log('   3. Restart the backend: npm run dev');

    // Create a mock admin object to prevent crashes
    module.exports = {
        firestore: null
    };
    return;
}

module.exports = admin;
