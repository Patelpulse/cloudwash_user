# 🚀 Cloudwash — Hostinger VPS Deployment Guide

## Overview
| App | Domain | Server Folder |
|-----|--------|---------------|
| cloud_user | cloudwash.in | `/var/www/cloudwash` |
| cloud_admin | admin.cloudwash.in | `/var/www/cloudwash-admin` |

---

## STEP 1 — GoDaddy DNS Settings (Pehle Karo)

Aapke nameservers abhi `ns1.dns-parking.com` pe hain. **2 options hain:**

### Option A — Sirf A Records Add Karo (Fastest, Recommended) ✅

GoDaddy → `cloudwash.in` → DNS → Add Records:

| Type | Name | Value | TTL |
|------|------|-------|-----|
| A | @ | 72.61.172.182 | 1 Hour |
| A | www | 72.61.172.182 | 1 Hour |
| A | admin | 72.61.172.182 | 1 Hour |

### Option B — Hostinger Nameservers (Agar Hostinger DNS manage karna ho)

GoDaddy → DNS → Nameservers → Change → Custom:
- `ns1.hostinger.com`
- `ns2.hostinger.com`

> ⏳ DNS propagation 1-24 ghante tak le sakta hai. Aage kaam karte raho.

---

## STEP 2 — Flutter Web Build (Local Machine pe)

### cloud_user build:

```bash
cd /Volumes/AmitSinghSSD/Documents/FlutterDev/patelpulseventures/cloud/CLOUD/cloud_user
fvm flutter clean
fvm flutter pub get
fvm flutter build web --release --web-renderer html --base-href /
```

### cloud_admin build:

```bash
cd /Volumes/AmitSinghSSD/Documents/FlutterDev/patelpulseventures/cloud/CLOUD/cloud_admin
fvm flutter clean
fvm flutter pub get
fvm flutter build web --release --web-renderer html --base-href /
```

Output folders:
- `cloud_user/build/web/`
- `cloud_admin/build/web/`

---

## STEP 3 — Server Setup (SSH se)

### Connect:

```bash
ssh root@72.61.172.182
# Password: Gaurav@1411@
```

### 3a. Nginx Install:

```bash
apt update && apt upgrade -y
apt install nginx -y
systemctl start nginx
systemctl enable nginx
```

### 3b. Firewall:

```bash
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw enable
```

### 3c. Web Directories:

```bash
mkdir -p /var/www/cloudwash
mkdir -p /var/www/cloudwash-admin
```

### 3d. Nginx config — cloudwash.in:

```bash
nano /etc/nginx/sites-available/cloudwash
```

**Paste karo (Ctrl+Shift+V):**

```nginx
server {
    listen 80;
    server_name cloudwash.in www.cloudwash.in;
    root /var/www/cloudwash;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml text/javascript;
}
```

**Save: Ctrl+X → Y → Enter**

### 3e. Nginx config — admin.cloudwash.in:

```bash
nano /etc/nginx/sites-available/cloudwash-admin
```

**Paste karo:**

```nginx
server {
    listen 80;
    server_name admin.cloudwash.in;
    root /var/www/cloudwash-admin;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml text/javascript;
}
```

### 3f. Sites Enable & Test:

```bash
ln -s /etc/nginx/sites-available/cloudwash /etc/nginx/sites-enabled/
ln -s /etc/nginx/sites-available/cloudwash-admin /etc/nginx/sites-enabled/

# Test config (koi error nahi aana chahiye)
nginx -t

# Nginx reload
systemctl reload nginx
```

---

## STEP 4 — Files Upload (Local Machine se, New Terminal)

### cloud_user upload:

```bash
scp -r /Volumes/AmitSinghSSD/Documents/FlutterDev/patelpulseventures/cloud/CLOUD/cloud_user/build/web/* \
    root@72.61.172.182:/var/www/cloudwash/
```

### cloud_admin upload:

```bash
scp -r /Volumes/AmitSinghSSD/Documents/FlutterDev/patelpulseventures/cloud/CLOUD/cloud_admin/build/web/* \
    root@72.61.172.182:/var/www/cloudwash-admin/
```

### Permissions fix (Server pe):

```bash
chown -R www-data:www-data /var/www/cloudwash /var/www/cloudwash-admin
chmod -R 755 /var/www/cloudwash /var/www/cloudwash-admin
```

---

## STEP 5 — SSL/HTTPS (Free Let's Encrypt)

DNS propagate hone ke baad yeh karo:

```bash
# Server pe:
apt install certbot python3-certbot-nginx -y

# User domain
certbot --nginx -d cloudwash.in -d www.cloudwash.in

# Admin domain
certbot --nginx -d admin.cloudwash.in
```

> Email enter karo, terms agree karo. HTTP → HTTPS redirect automatic ho jayega.

---

## STEP 6 — Test

IP se (DNS se pehle bhi chalega):
```
http://72.61.172.182
```

DNS propagate hone ke baad:
```
https://cloudwash.in          → User App ✅
https://admin.cloudwash.in    → Admin App ✅
```

DNS check: https://dnschecker.org → `cloudwash.in` → `72.61.172.182`

---

## ⚡ Quick Re-Deploy Script (Future Updates)

`deploy.sh` banao project root mein:

```bash
#!/bin/bash
set -e

echo "🔨 Building User App..."
cd /Volumes/AmitSinghSSD/Documents/FlutterDev/patelpulseventures/cloud/CLOUD/cloud_user
fvm flutter build web --release --web-renderer html --base-href /

echo "🔨 Building Admin App..."
cd /Volumes/AmitSinghSSD/Documents/FlutterDev/patelpulseventures/cloud/CLOUD/cloud_admin
fvm flutter build web --release --web-renderer html --base-href /

echo "📤 Uploading User App..."
scp -r /Volumes/AmitSinghSSD/Documents/FlutterDev/patelpulseventures/cloud/CLOUD/cloud_user/build/web/* \
    root@72.61.172.182:/var/www/cloudwash/

echo "📤 Uploading Admin App..."
scp -r /Volumes/AmitSinghSSD/Documents/FlutterDev/patelpulseventures/cloud/CLOUD/cloud_admin/build/web/* \
    root@72.61.172.182:/var/www/cloudwash-admin/

echo "✅ Deployment complete! Visit https://cloudwash.in"
```

```bash
chmod +x deploy.sh
./deploy.sh
```

---

## Troubleshooting

```bash
# Nginx status check
systemctl status nginx

# Files check
ls -la /var/www/cloudwash/index.html
ls -la /var/www/cloudwash-admin/index.html

# Nginx error logs
tail -f /var/log/nginx/error.log
```
