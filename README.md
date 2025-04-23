# Shazam Clone

A Flutter application that replicates the core functionality of Shazam, allowing users to recognize songs playing around them. Built with modern Flutter architecture using Firebase for authentication and ACRCloud for audio fingerprinting.

## ✨ Features

- **Song Recognition**: Identify songs playing around you in seconds
- **Song History**: View your previously identified songs
- **Music Details**: Access comprehensive song information including artist, album, and cover art
- **User Authentication**: Secure login with email/password or Google Sign-In
- **Profile Management**: Create and manage your user profile

## 🛠️ Technologies Used

- **Frontend**: Flutter 2+
- **Backend Services**:
  - Firebase Authentication
  - Firebase Firestore
  - ACRCloud API for audio fingerprinting
- **State Management**: Riverpod with Hooks
- **APIs**: Deezer API for rich song metadata

## 📋 Prerequisites

- Flutter SDK (2.0 or higher)
- Dart SDK (2.12 or higher)
- iOS 12.0+ / Android 5.0+
- Firebase project
- ACRCloud account and API credentials

## 🚀 Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/yourusername/shazam_clone.git
cd shazam_clone
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

- Create a new Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
- Add iOS and Android apps to your Firebase project
- Download `GoogleService-Info.plist` for iOS and place it in `ios/Runner/`
- Download `google-services.json` for Android and place it in `android/app/`
- Enable Email/Password and Google Sign-In authentication methods

### 4. Configure ACRCloud

- Sign up for ACRCloud and create a project
- Add your ACRCloud credentials to the app configuration

### 5. Run the app

```bash
flutter run
```

## 🔧 Configuration

### Firebase Authentication

This app uses Firebase Authentication with multiple sign-in methods:

- Email/Password authentication
- Google Sign-In

For Google Sign-In on iOS, ensure your `Info.plist` contains the correct URL scheme:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>YOUR_REVERSED_CLIENT_ID</string>
    </array>
  </dict>
</array>
```

## 📱 Usage

1. **Sign In**: Create an account or sign in with Google
2. **Recognize Songs**: Tap the main button to start listening
3. **View Results**: See song details including artist, album, and cover art
4. **History**: Access your previously identified songs
5. **Profile**: Manage your account settings

## ⚠️ Common Issues & Troubleshooting

### iOS Google Sign-In Issues

If you encounter errors with Google Sign-In on iOS, verify:

- Your `GoogleService-Info.plist` contains the correct CLIENT_ID
- Your `Info.plist` URL schemes match the REVERSED_CLIENT_ID from `GoogleService-Info.plist`
- App Check is properly configured in Firebase
- You're using the correct bundle ID for your app

## 🔒 Privacy

This app requires microphone permissions to recognize songs. All audio processing is handled securely, and no audio recordings are stored.

## 🙏 Acknowledgements

- [ACRCloud](https://www.acrcloud.com/) for audio recognition technology
- [Firebase](https://firebase.google.com/) for backend and authentication services
- [Deezer API](https://developers.deezer.com/) for song metadata
- [Flutter](https://flutter.dev/) team for the amazing framework

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

Built with ❤️ by om
