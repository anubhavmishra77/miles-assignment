# Todo App

A simple Flutter task management app with Firebase backend. Create, update, and manage your personal tasks.

# What it does

This is a personal task manager where you can sign up, create your own todo items, and manage them. Each user has their own private list of tasks.

Features:
- User authentication (sign up/login)
- Create, edit, delete, and complete tasks
- Personal task list for each user
- Real-time updates from Firebase
- Clean Material Design UI
- Works on mobile, web, and desktop

Built with Flutter using **GetX** for state management and Firebase for auth and database.

## Getting it running

You'll need Flutter installed (3.6.0+) and a Firebase project.

1. Clone this repo and run `flutter pub get`

2. Set up Firebase:
   - Create a new project at Firebase console
   - Enable Authentication with Email/Password
   - Enable Firestore Database
   - Add your Firebase config to `lib/main.dart`

3. Run `flutter run`

If you get build errors, try `flutter clean` first.

Also make sure your Firestore rules allow users to read/write only their own todos:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /todos/{document} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.ownerId;
    }
    
    match /todos/{document} {
      allow create: if request.auth != null && 
        request.auth.uid == request.resource.data.ownerId;
    }
    
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## How to use it

Simple - sign up or login, then:
- Add tasks with the + button
- Tap a task to mark it complete/incomplete  
- Swipe left to delete tasks
- All your tasks sync across devices

## Main dependencies

- firebase_core, firebase_auth, cloud_firestore - Firebase integration
- **get** - State management (GetX)
- flutter_slidable - Swipe actions on tasks
- responsive_framework - Better layouts on different screens

## Building for release

```bash
flutter build apk      # Android
flutter build web      # Web
flutter build ios      # iOS (need Xcode)
```

## Architecture

This app uses **GetX** for:
- **State Management**: Reactive programming with `.obs` variables
- **Dependency Injection**: Controllers and services managed by GetX
- **Navigation**: GetX navigation system
- **Snackbars**: Built-in GetX snackbar system

Key files:
- `lib/view_models/todo_view_model.dart` - GetX controller for todo management
- `lib/services/firebase_service.dart` - Firebase operations
- `lib/main.dart` - GetX app setup and dependency injection

