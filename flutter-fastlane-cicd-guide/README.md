# Hướng Dẫn Cấu Hình Fastlane & GitHub Actions CI/CD Cho Dự Án Flutter (A-Z)

Tài liệu hướng dẫn chi tiết toàn bộ các bước thiết lập quy trình tự động hóa **CI/CD + Fastlane** để tự động build và upload ứng dụng Flutter lên **Google Play Console** (Internal Testing / Production).

---

## 📋 MỤC LỤC
1. [Phần 1: Cấu hình Google Cloud & Google Play Console](#phần-1-cấu-hình-google-cloud--google-play-console)
2. [Phần 2: Cấu hình GitHub Access Token & Repository Secrets](#phần-2-cấu-hình-github-access-token--repository-secrets)
3. [Phần 3: Cấu hình mã nguồn Flutter & Fastlane trong Repo](#phần-3-cấu-hình-mã-nguồn-flutter--fastlane-trong-repo)
4. [Phần 4: File Workflow GitHub Actions Mẫu (`deploy_android.yml`)](#phần-4-file-workflow-github-actions-mẫu-deploy_androidyml)
5. [Phần 5: Các sự cố thường gặp (Gotchas & Troubleshooting)](#phần-5-các-sự-cố-thường-gặp-gotchas--troubleshooting)

---

## PHẦN 1: CẤU HÌNH GOOGLE CLOUD & GOOGLE PLAY CONSOLE

### Bước 1.1: Tạo Service Account trên Google Cloud Console
1. Truy cập [Google Cloud Console](https://console.cloud.google.com/).
2. Chọn đúng **Project** liên kết với tài khoản Google Play Developer của bạn.
3. Ở menu trái, chọn **IAM & Admin** $\rightarrow$ **Service Accounts**.
4. Bấm **Create Service Account**:
   - **Service account name**: `fastlane-bot`
   - **Service account ID**: (tự động tạo, ví dụ `fastlane-bot@your-project-id.iam.gserviceaccount.com`)
   - Bấm **Create and Continue** $\rightarrow$ **Done**.

![Google Cloud Console - Create Service Account](images/01_google_cloud_create_service_account.png)

5. Trong danh sách Service Accounts, bấm vào email vừa tạo $\rightarrow$ Chuyển sang tab **Keys**.
6. Bấm **Add Key** $\rightarrow$ **Create new key** $\rightarrow$ Chọn định dạng **JSON** $\rightarrow$ Bấm **Create**.
7. Một file `*.json` sẽ được tải về máy của bạn (Hãy lưu lại, đổi tên thành `pc-api-key.json`).

![Google Cloud Console - Add JSON Key](images/02_google_cloud_add_json_key.png)

---

### Bước 1.2: Bật Google Play Android Developer API
1. Trên Google Cloud Console, vào menu **APIs & Services** $\rightarrow$ **Library**.
2. Tìm kiếm từ khóa: `Google Play Android Developer API`.
3. Bấm vào kết quả tìm kiếm và bấm nút **ENABLE** (Bật).

![Google Cloud Console - Enable Google Play Developer API](images/03_google_cloud_enable_api.png)

---

### Bước 1.3: Cấp quyền cho Service Account trên Google Play Console
1. Truy cập [Google Play Console](https://play.google.com/console).
2. Vào mục **Users and permissions** (Người dùng và quyền) ở menu trái.
3. Bấm **Invite new users** (Mời người dùng mới).
4. Dán địa chỉ email Service Account (dạng `fastlane-bot@your-project-id.iam.gserviceaccount.com`) vào ô email.

![Google Play Console - Invite New User](images/04_play_console_invite_user.png)

5. Tại mục **App permissions** (Quyền ứng dụng): Thêm ứng dụng của bạn vào danh sách.
6. Tích chọn các quyền tối thiểu sau:
   - **Draft apps**: *Create, edit, and delete draft apps*
   - **Releases**:
     - *Release to production, exclude devices, and use Play App Signing*
     - *Release apps to testing tracks*
     - *Manage testing tracks and edit tester lists*
   - **Store presence**: *Manage store presence*
7. Bấm **Invite user** (hoặc **Save changes**) ở góc dưới cùng bên phải.

![Google Play Console - Service Account Permissions](images/05_play_console_permissions.png)

> [!IMPORTANT]
> **MẸO QUAN TRỌNG (Upload bản build đầu tiên bằng tay):**
> Google Play Developer API **nghiêm cấm** việc tự động đẩy AAB lên bằng API đối với ứng dụng mới tinh chưa từng có bản build nào.
> Trước khi dùng Fastlane, bạn **BẮT BUỘC phải vào Google Play Console và upload thủ công 1 file AAB đầu tiên bằng tay** vào nhánh Internal testing hoặc Production. Các lần phát hành tiếp theo Fastlane sẽ tự động 100%!

---

## PHẦN 2: CẤU HÌNH GITHUB ACCESS TOKEN & REPOSITORY SECRETS

### Bước 2.1: Tạo Fine-grained Personal Access Token (PAT) cho Private Packages
Nếu dự án của bạn sử dụng các package git private (ví dụ `custom_iap`, `flutter_drive_sync`,...):
1. Trên GitHub, vào **Settings** (Profile) $\rightarrow$ **Developer settings** $\rightarrow$ **Personal access tokens** $\rightarrow$ **Fine-grained tokens**.
2. Bấm **Generate new token**:
   - **Token name**: `CI_CD_PAT`
   - **Expiration**: 1 year (hoặc No expiration)
   - **Repository access**: Chọn **All repositories** (hoặc chọn Repo chính + TẤT CẢ các repo private dependency).
   - **Permissions**:
     - `Contents`: Read-only (hoặc Read and write nếu cần push Tag).
3. Bấm **Generate token** và copy chuỗi token dạng `github_pat_11...`.

![GitHub - Fine-grained PAT Settings](images/07_github_fine_grained_pat.png)

---

### Bước 2.2: Tạo Keystore & Encode Base64 các secret
1. **Tạo Keystore Android (`upload-keystore.jks`):**
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000
   ```
2. **Chuyển Keystore sang mã Base64:**
   ```bash
   openssl base64 -A -in upload-keystore.jks
   ```
3. **Chuyển JSON Key Service Account sang mã Base64:**
   ```bash
   openssl base64 -A -in pc-api-key.json
   ```

---

### Bước 2.3: Thêm Repository Secrets vào GitHub
Vào Repository trên GitHub $\rightarrow$ **Settings** $\rightarrow$ **Secrets and variables** $\rightarrow$ **Actions** $\rightarrow$ **New repository secret**. Thêm 7 secrets sau:

![GitHub Repository - Actions Secrets](images/08_github_repository_secrets.png)

| Secret Name | Mô tả / Giá trị |
| :--- | :--- |
| `GH_PAT` | Chuỗi Fine-grained Token `github_pat_...` vừa tạo ở Bước 2.1 |
| `ANDROID_KEYSTORE_BASE64` | Chuỗi Base64 của file `upload-keystore.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | Mật khẩu của file keystore |
| `ANDROID_KEY_ALIAS` | Alias của key (ví dụ `upload`) |
| `ANDROID_KEY_PASSWORD` | Mật khẩu của alias key |
| `PLAY_STORE_JSON_KEY_BASE64` | Chuỗi Base64 của file JSON key Service Account |
| `TELEGRAM_BOT_TOKEN` | (Tùy chọn) Token Bot Telegram để nhận thông báo |
| `TELEGRAM_CHAT_ID` | (Tùy chọn) ID chat Telegram để nhận thông báo |

---

## PHẦN 3: CẤU HÌNH MÃ NGUỒN FLUTTER & FASTLANE TRONG REPO

### Bước 3.1: Cấu hình Fastlane
1. Tạo thư mục `android/fastlane/` trong dự án.
2. Tạo file **`android/fastlane/Appfile`**:
   ```ruby
   json_key_file("fastlane/pc-api-key.json")
   package_name("com.yourdomain.yourapp") # Thay bằng ApplicationId bản prod của bạn
   ```
3. Tạo file **`android/fastlane/Fastfile`**:
   ```ruby
   require 'yaml'

   default_platform(:android)

   platform :android do
     desc "Upload AAB to Google Play Internal Track"
     lane :deploy_internal do |options|
       aab_path = options[:aab] || Dir[File.expand_path("../../build/app/outputs/bundle/prodRelease/*.aab", __dir__)].first

       upload_to_play_store(
         track: 'internal',
         aab: aab_path,
         package_name: 'com.yourdomain.yourapp', # Thay đúng Package Name bản prod
         json_key: 'fastlane/pc-api-key.json',
         skip_upload_apk: true,
         skip_upload_metadata: true,
         skip_upload_changelogs: true, # Đặt true cho internal track để chạy nhanh & tránh lỗi locale
         skip_upload_images: true,
         skip_upload_screenshots: true
       )
     end

     desc "Upload AAB to Google Play Production Track"
     lane :deploy_prod do |options|
       aab_path = options[:aab] || Dir[File.expand_path("../../build/app/outputs/bundle/prodRelease/*.aab", __dir__)].first
       pubspec_path = File.expand_path("../../pubspec.yaml", __dir__)
       pubspec = YAML.load_file(pubspec_path)
       version = pubspec['version'].to_s
       version_code = version.split('+').last

       upload_to_play_store(
         track: 'production',
         aab: aab_path,
         package_name: 'com.yourdomain.yourapp', # Thay đúng Package Name bản prod
         json_key: 'fastlane/pc-api-key.json',
         version_code: version_code,
         skip_upload_apk: true,
         skip_upload_metadata: true,
         skip_upload_changelogs: false,
         skip_upload_images: true,
         skip_upload_screenshots: true
       )
     end
   end
   ```

### Bước 3.2: Cấu hình `.gitignore`
Thêm các dòng sau vào `.gitignore` để không bao giờ push bí mật lên Git:
```gitignore
# Fastlane & Build Secrets
**/fastlane/pc-api-key.json
**/fastlane/report.xml
**/fastlane/Preview.html
**/fastlane/screenshots
**/fastlane/test_output
**/fastlane/*.json
android/app/upload-keystore.jks
android/key.properties
```

### Bước 3.3: Sửa `android/app/build.gradle` (Bảo vệ môi trường CI)
1. Trong `android/gradle.properties`: **KHÔNG** hardcode `org.gradle.java.home`. Comment dòng đó lại nếu có.
2. Trong `android/app/build.gradle`, nếu có script tự động mở thư mục sau khi build, bọc trong điều kiện CI:
   ```groovy
   if (System.getenv("CI") == null && System.getenv("GITHUB_ACTIONS") == null) {
       try {
           def os = System.getProperty("os.name").toLowerCase()
           if (os.contains("windows")) exec { commandLine 'cmd', '/c', 'start', '', outputDir }
           else if (os.contains("mac")) exec { commandLine 'open', outputDir }
           else if (os.contains("linux")) exec { commandLine 'xdg-open', outputDir; ignoreExitValue = true }
       } catch (Exception e) {}
   }
   ```

---

## PHẦN 4: FILE WORKFLOW GITHUB ACTIONS MẪU (`.github/workflows/deploy_android.yml`)

Tạo file `.github/workflows/deploy_android.yml`:

```yaml
name: Deploy Android to Google Play Internal

on:
  push:
    branches:
      - 'release/android'
      - 'main'
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: write

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4
        with:
          submodules: recursive
          persist-credentials: false

      - name: Set up Java 17
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: Set up Flutter 3.41.9
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.41.9'
          channel: 'stable'
          cache: true

      - name: Set up Ruby & Fastlane
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'

      - name: Install Fastlane
        run: gem install fastlane --no-document

      - name: Restore Caches
        uses: actions/cache@v4
        with:
          path: |
            ~/.gradle/caches
            ~/.gradle/wrapper
            ~/.pub-cache
          key: ${{ runner.os }}-build-${{ hashFiles('**/*.gradle*', 'pubspec.lock') }}
          restore-keys: |
            ${{ runner.os }}-build-

      - name: Setup Keystore & key.properties
        run: |
          echo "$ANDROID_KEYSTORE_BASE64" | base64 -d > android/app/upload-keystore.jks
          cat > android/key.properties <<EOF
          storePassword=${{ secrets.ANDROID_KEYSTORE_PASSWORD }}
          keyPassword=${{ secrets.ANDROID_KEY_PASSWORD }}
          keyAlias=${{ secrets.ANDROID_KEY_ALIAS }}
          storeFile=upload-keystore.jks
          EOF
        env:
          ANDROID_KEYSTORE_BASE64: ${{ secrets.ANDROID_KEYSTORE_BASE64 }}

      - name: Setup Google Play Service Account JSON Key
        run: |
          mkdir -p android/fastlane
          echo "$PLAY_STORE_JSON_KEY_BASE64" | base64 -d > android/fastlane/pc-api-key.json
        env:
          PLAY_STORE_JSON_KEY_BASE64: ${{ secrets.PLAY_STORE_JSON_KEY_BASE64 }}

      - name: Configure Git for Private Dependencies
        run: |
          if [ -z "$GH_PAT" ]; then
            echo "::error::Secret GH_PAT is empty or not set in Repository Secrets!"
            exit 1
          fi
          echo "Configuring git extraheader with GH_PAT..."
          B64_PAT=$(echo -n "${GH_PAT}:" | base64 | tr -d '\n')
          git config --global --unset-all http.https://github.com/.extraheader || true
          git config --global http.https://github.com/.extraheader "AUTHORIZATION: basic ${B64_PAT}"
          git config --global url."https://github.com/".insteadOf "git@github.com:"
        env:
          GH_PAT: ${{ secrets.GH_PAT }}

      - name: Install Flutter Dependencies & Codegen
        run: |
          flutter pub get
          flutter gen-l10n
          flutter pub run build_runner build --delete-conflicting-outputs

      - name: Build Android App Bundle (AAB)
        run: flutter build appbundle --flavor prod -t lib/main.dart

      - name: Create and Push Git Tag
        run: |
          VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
          TAG_NAME="v$VERSION"
          echo "Version from pubspec.yaml: $VERSION"
          echo "Target tag: $TAG_NAME"
          if git ls-remote --tags origin | grep -q "refs/tags/$TAG_NAME"; then
            echo "Tag $TAG_NAME already exists on remote, skipping tag creation."
          else
            git config user.name "github-actions[bot]"
            git config user.email "github-actions[bot]@users.noreply.github.com"
            git tag -a "$TAG_NAME" -m "Release $TAG_NAME"
            git push origin "$TAG_NAME"
          fi

      - name: Deploy to Google Play Internal via Fastlane
        run: |
          cd android
          fastlane deploy_internal

      - name: Send Telegram Notification
        if: always()
        uses: appleboy/telegram-action@master
        with:
          to: ${{ secrets.TELEGRAM_CHAT_ID }}
          token: ${{ secrets.TELEGRAM_BOT_TOKEN }}
          format: markdown
          message: |
            *${{ github.workflow }}*
            *Trạng thái:* ${{ job.status == 'success' && '🟢 THÀNH CÔNG' || '🔴 THẤT BẠI' }}
            *Repository:* `${{ github.repository }}`
            *Branch:* `${{ github.ref_name }}`
            *Commit:* `${{ github.sha }}`
```

---

## PHẦN 5: CÁC SỰ CỐ THƯỜNG GẶP (GOTCHAS & TROUBLESHOOTING)

| Lỗi gặp phải | Nguyên nhân | Cách khắc phục |
| :--- | :--- | :--- |
| `fatal: could not read Username for 'https://github.com'` | Token `GITHUB_TOKEN` mặc định chèn header ghi đè | Thêm `persist-credentials: false` vào `actions/checkout@v4` và dùng `http.extraheader` dạng Base64 với `GH_PAT`. |
| `The caller does not have permission` | Email Service Account chưa được cấp quyền trong Play Console HOẶC Package Name sai. | 1. Kiểm tra lại `package_name` trong `Fastfile` & `Appfile`.<br>2. Thêm email Service Account vào **Users and permissions** trên Google Play Console.<br>3. Upload 1 bản AAB bằng tay lần đầu tiên. |
| `Version code X has already been used` | Version Code trong `pubspec.yaml` trùng với bản đã phát hành trên Play Store. | Tăng version code trong `pubspec.yaml` (ví dụ `1.3.5+1350`). |
| `Process 'command 'xdg-open'' finished with non-zero exit value` | Gradle chạy script mở folder giao diện desktop trên máy Linux CI. | Bọc đoạn script trong `if (System.getenv("CI") == null)` trong `android/app/build.gradle`. |
| `Invalid request - uz-UZ` / `ro-RO` | Mã thư mục ngôn ngữ trong metadata không khớp chuẩn BCP-47 của Google Play API. | 1. Đặt `skip_upload_changelogs: true` cho `deploy_internal`.<br>2. Đổi tên thư mục metadata chuẩn (ví dụ `uz-UZ` $\rightarrow$ `uz`, `ro-RO` $\rightarrow$ `ro`). |
