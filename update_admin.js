const admin = require('./backend/src/config/firebase');

async function updateAdmin() {
  const email = 'admin@cloudwash.in';
  const password = 'Cloudwash@2026';

  try {
    let user;
    try {
      user = await admin.auth().getUserByEmail(email);
      console.log('Admin user exists. Updating password...');
      await admin.auth().updateUser(user.uid, { password });
      console.log('✅ Password updated for ' + email);
    } catch (e) {
      if (e.code === 'auth/user-not-found') {
        console.log('Admin user does not exist. Creating new one...');
        user = await admin.auth().createUser({
          email,
          password,
          emailVerified: true,
          displayName: 'Administrator'
        });
        console.log('✅ Admin user created: ' + email);
      } else {
        throw e;
      }
    }
  } catch (error) {
    console.error('❌ Error updating admin:', error.message);
  } finally {
    process.exit();
  }
}

updateAdmin();
