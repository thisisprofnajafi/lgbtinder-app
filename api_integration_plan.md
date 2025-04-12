# API Integration Plan for LGBTQ Dating App

## Current API Configuration
The app currently uses the base URL `https://lg.abolfazlnajafi.com/api` with multiple endpoints defined in `lib/core/config.dart`.

## Required Updates to Config.dart
The following new endpoints need to be added to the Config class:

```dart
// Authentication
static const String sendOtp = "/auth/send-otp";
static const String verifyOtp = "/auth/verify-otp";
static const String resendOtp = "/auth/resend-otp";
static const String sendVerificationEmail = "/auth/send-verification-email";
static const String verifyEmail = "/auth/verify-email";
static const String resendVerificationEmail = "/auth/resend-verification-email";
static const String forgotPassword = "/auth/forgot-password";
static const String resetPassword = "/auth/reset-password";
static const String resendResetLink = "/auth/resend-reset-link";

// User Profile
static const String updateProfile = "/auth/update-profile";
static const String getUserProfile = "/user";

// Matching
static const String getMatches = "/matching/matches";
static const String getSuggestions = "/matching/suggestions";
static const String getFollowSuggestions = "/matching/follow-suggestions";

// Blocking
static const String blockUser = "/block/user";
static const String unblockUser = "/block/user"; // DELETE method
static const String getBlockedUsers = "/block/list";
static const String checkIfBlocked = "/block/check";

// Favorites
static const String addFavorite = "/favorites/add";
static const String removeFavorite = "/favorites/remove";
static const String getFavorites = "/favorites/list";
static const String checkFavorite = "/favorites/check";
static const String updateFavoriteNote = "/favorites/note";

// Chat
static const String sendMessage = "/chat/send";
static const String getChatHistory = "/chat/history";
static const String getChatUsers = "/chat/users";
static const String deleteMessage = "/chat/message"; // DELETE method
static const String getUnreadCount = "/chat/unread-count";

// Images
static const String uploadImage = "/images/upload";
static const String deleteImage = "/images/"; // Append ID and use DELETE
static const String reorderImages = "/images/reorder";
static const String setPrimaryImage = "/images/{id}/set-primary";
static const String listImages = "/images/list";

// Preferences
static const String updateAgePreference = "/preferences/age";
static const String getAgePreference = "/preferences/age";
static const String resetAgePreference = "/preferences/age"; // DELETE method
```

## Service Implementation Plan

1. **Update Auth Service**
   - Implement OTP-based authentication
   - Add email verification methods
   - Add password reset functionality

2. **Update Profile Service**
   - Enhance profile update methods
   - Add photo management functions
   - Implement preference management

3. **Create Matching Service**
   - Implement match retrieval
   - Add suggestion algorithms
   - Handle follow suggestions

4. **Create Block Service**
   - Implement user blocking
   - Add unblocking functionality
   - Handle blocked user list management

5. **Create Favorites Service**
   - Add favorite management functions
   - Implement favorite note features
   - Handle favorite status checking

6. **Enhance Chat Service**
   - Update message sending functions
   - Implement history retrieval
   - Add unread count functionality
   - Handle message deletion

7. **Create Media Service**
   - Implement image upload/download
   - Add reordering functionality
   - Handle primary image setting

## Migration Strategy

1. **Phase 1: Authentication Migration**
   - Implement new OTP-based authentication
   - Update login and registration screens
   - Test compatibility with existing users

2. **Phase 2: Profile Management Migration**
   - Update profile creation/editing flows
   - Implement new photo management
   - Test data integrity with backend

3. **Phase 3: Social Features Migration**
   - Implement matching, blocking, favorites
   - Update UI to handle new features
   - Test user experience

4. **Phase 4: Chat and Messaging Migration**
   - Update chat functionality
   - Implement message deletion
   - Test real-time communication

## Authentication Flow Updates

1. **Login Flow**
   - User enters phone number
   - App calls `/auth/send-otp`
   - User receives OTP via SMS
   - User enters OTP
   - App calls `/auth/verify-otp`
   - App receives auth token and proceeds to main screen

2. **Registration Flow**
   - User enters phone number
   - App calls `/auth/send-otp`
   - User verifies OTP
   - App collects profile information
   - App calls registration endpoint
   - App receives user data and proceeds to main screen

3. **Password Reset Flow**
   - User enters phone number
   - App calls `/auth/send-otp`
   - User verifies OTP
   - User enters new password
   - App calls `/auth/reset-password`
   - User is redirected to login

## Testing Strategy

1. **Unit Tests**
   - Test each API service method
   - Validate request/response handling
   - Test error scenarios

2. **Integration Tests**
   - Test full authentication flows
   - Test profile management
   - Test chat functionality

3. **UI Tests**
   - Validate UI behavior with new API responses
   - Test error handling and user feedback

## Rollout Plan

1. **Alpha Release**
   - Internal testing with test accounts
   - Focus on authentication and critical features

2. **Beta Release**
   - Limited user testing
   - Collect feedback on new features

3. **Production Release**
   - Phased rollout to production users
   - Monitor for any issues or performance bottlenecks

## Security Considerations

1. Implement proper token handling and refresh mechanism
2. Secure storage of user credentials and tokens
3. Input validation before sending to API
4. Implement proper error handling for API failures
5. Add request timeouts and retry mechanisms

This plan should be reviewed and updated as implementation progresses, addressing any unforeseen challenges or changes in requirements. 