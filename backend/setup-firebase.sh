#!/bin/bash

# Firebase Admin SDK Quick Setup Script
# This script helps you set up Firebase to sync order data

echo "🔥 Firebase Admin SDK Setup for Cloud Washer"
echo "=============================================="
echo ""

# Check if firebase-admin is installed
if ! npm list firebase-admin &> /dev/null; then
    echo "❌ firebase-admin not found. Installing..."
    npm install firebase-admin
else
    echo "✅ firebase-admin is already installed"
fi

echo ""
echo "📋 Next Steps:"
echo ""
echo "1. Download Firebase Service Account Key:"
echo "   - Go to: https://console.firebase.google.com"
echo "   - Select your project"
echo "   - Click ⚙️ (Settings) → Project settings"
echo "   - Go to 'Service accounts' tab"
echo "   - Click 'Generate new private key'"
echo "   - Save the JSON file as: backend/firebase-admin-key.json"
echo ""
echo "2. Update .gitignore:"
echo "   Add this line to backend/.gitignore:"
echo "   firebase-admin-key.json"
echo ""
echo "3. Set environment variable (Optional):"
echo "   Add to backend/.env:"
echo "   GOOGLE_APPLICATION_CREDENTIALS=./firebase-admin-key.json"
echo ""
echo "4. Restart your backend:"
echo "   Press Ctrl+C and run: npm run dev"
echo ""
echo "5. Test order creation:"
echo "   - Create an order from the app"
echo "   - Check backend logs for: ✅ Order synced to Firebase"
echo "   - Check Firebase Console → Firestore → orders collection"
echo ""
echo "=============================================="
echo "📚 For detailed instructions, see: FIREBASE_SETUP.md"
echo ""
