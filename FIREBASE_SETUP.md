# Firebase setup (QonaqStay)

## 1) Create Firebase project
- Create a Firebase project in Firebase Console.
- Add iOS app:
  - **Bundle ID** must match your Xcode target bundle id.
  - Download `GoogleService-Info.plist`.

## 2) Add `GoogleService-Info.plist` to Xcode
- Drag `GoogleService-Info.plist` into Xcode Project navigator.
- Ensure **Add to targets**: `qonaqstay`.

## 3) Add Firebase SDK via Swift Package Manager (SPM)
In Xcode:
- `File` → `Add Package Dependencies…`
- Add package: `https://github.com/firebase/firebase-ios-sdk`
- Select products (MVP):
  - `FirebaseAuth`
  - `FirebaseFirestore`
  - `FirebaseStorage` (optional for MVP, needed for avatars)

## 4) Configure Firebase on app start
In `qonaqstayApp.swift` add:

```swift
import FirebaseCore

@main
struct qonaqstayApp: App {
  init() {
    FirebaseApp.configure()
  }
  // ...
}
```

## 5) Replace InMemory repositories with Firebase repositories
### Idea
UI/ViewModels talk only to **Domain protocols**:
- `AuthRepository`
- `UserRepository`
- `HostRepository`
- `ChatRepository`

So migration is:
1) Implement Firebase-backed repos under `qonaqstay/Data/Firebase/`
2) Switch container factory from `liveInMemory()` to `liveFirebase()`

### What to implement first (MVP order)
1) **Auth**: email/password (FirebaseAuth)
2) **Users** collection: profile data (Firestore)
3) **Hosts** collection: host places (Firestore)
4) **Chats**: threads + messages (Firestore)
5) **Storage**: avatars (FirebaseStorage)

## 6) Firestore collections (suggested)
- `users/{userId}`
  - `name`, `city`, `about`, `language`, `isGuest`, `isHost`, `rating`
- `hostPlaces/{placeId}`
  - `userId`, `city`, `placesCount`, `rules`
- `threads/{threadId}`
  - `userAId`, `userBId`, `lastMessageText`, `lastMessageAt`
- `threads/{threadId}/messages/{messageId}`
  - `fromUserId`, `toUserId`, `text`, `sentAt`

## 7) Security rules (MVP baseline)
- Only authenticated users can read/write.
- User can update only their own `users/{uid}` document.
- For chats: only participants can read/write thread + messages.

## 8) QA checklist (before you start building UI polish)
- Can register with email/password
- Profile fields saved to Firestore and loaded after relaunch
- Host list query by city works
- Start chat from host profile creates thread (idempotent)
- Sending messages updates lastMessage fields



