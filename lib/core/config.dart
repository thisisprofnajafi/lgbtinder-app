class Config {
  static const String agoraVcKey = "e320f11253174e7c8dd9db148109668b";

  static const Map<String, dynamic> header = {"Content-Type": "application/json"};

  static const String firebaseKey = '1:677771590404:android:3fdf13cf5ed9919e1dae51';
  static const String notificationUrl = 'https://fcm.googleapis.com/fcm/send';
  static const String baseUrl = "https://lg.abolfazlnajafi.com/";
  static const String baseUrlApi = "${baseUrl}api";

  // Routes with no API equivalents yet (need migration)
  static const String mobileCheck = "/mobile_check"; // Missing in API docs
  static const String homeData = "/home_data"; // Missing in API docs
  static const String mapInfo = "/map_info"; // Missing in API docs
  static const String likeDislike = "/like_dislike"; // Missing in API docs
  static const String likeMe = "/like_me"; // Missing in API docs
  static const String passed = "/passed"; // Missing in API docs
  static const String delUnlike = "/del_unlike"; // Missing in API docs
  static const String profileView = "/profile_view"; // Missing in API docs
  static const String filter = "/filter"; // Missing in API docs
  static const String faq = "/faq"; // Missing in API docs
  static const String pageList = "/pagelist"; // Missing in API docs
  static const String reportapi = "/report"; // Missing in API docs
  static const String identifyapi = "/identity_doc"; // Missing in API docs

  // Modern API endpoints from documentation
  // Auth routes
  static const String login = "/auth/login"; // Replaces userLogin
  static const String register = "/auth/register"; // Replaces regiseruser
  static const String sendOtp = "/auth/send-otp";
  static const String verifyOtp = "/auth/verify-otp";
  static const String resendOtp = "/auth/resend-otp";
  static const String resetPassword = "/auth/reset-password";
  static const String sendVerificationEmail = "/auth/send-verification-email";
  static const String verifyEmail = "/auth/verify-email";
  static const String resendVerificationEmail = "/auth/resend-verification-email";
  static const String forgotPassword = "/auth/forgot-password"; // Replaces forgetPassword
  static const String resendResetLink = "/auth/resend-reset-link";
  static const String updateUserProfile = "/auth/update-profile"; // Alternative to editProfile
  static const String deleteAccount = "/auth/delete-account"; // Replaces accDelete

  // Profile completion endpoint
  static const String profileComplete = "/profile/complete";

  // User routes
  static const String getCurrentUser = "/user"; // Replaces userInfo

  // Matching routes
  static const String getMatches = "/matching/matches"; // Replaces newMatch
  static const String getSuggestions = "/matching/suggestions";
  static const String getFollowSuggestions = "/matching/follow-suggestions";
  // TODO: Add missing matching API endpoints:
  // - like/dislike functionality
  // - passed profiles
  // - match interactions

  // Block routes
  static const String blockUser = "/block/user"; // Replaces profileblock
  static const String unblockUser = "/block/user"; // Replaces unblockapikey
  static const String getBlockedUsers = "/block/list"; // Replaces blocklist and getblockapi
  static const String checkIfBlocked = "/block/check";

  // Plan purchase routes
  static const String getPlanPurchases = "/plan-purchases";
  static const String storePlanPurchase = "/plan-purchases"; // Replaces planPurchase
  static const String getPlanPurchase = "/plan-purchases/";
  static const String getUserPlanHistory = "/plan-purchases/user/";
  static const String getUserActivePlans = "/plan-purchases/user/";
  static const String getUserExpiredPlans = "/plan-purchases/user/";

  // Plan purchase actions routes
  static const String getPlanPurchaseActions = "/plan-purchase-actions";
  static const String storePlanPurchaseAction = "/plan-purchase-actions";
  static const String getPlanActionStatistics = "/plan-purchase-actions/statistics";
  static const String getTodayPlanActions = "/plan-purchase-actions/today";
  static const String getActionsByStatus = "/plan-purchase-actions/status";
  static const String getUserPlanActions = "/plan-purchase-actions/user/";
  static const String getPlanAction = "/plan-purchase-actions/";
  static const String updatePlanActionStatus = "/plan-purchase-actions/";

  // Notification routes
  static const String getNotifications = "/notifications"; // Replaces notificationList
  static const String createNotification = "/notifications";
  static const String getNotificationStats = "/notifications/statistics";
  static const String getTodayNotifications = "/notifications/today";
  static const String getUserNotifications = "/notifications/user/";
  static const String getSingleNotification = "/notifications/";
  static const String updateNotification = "/notifications/";
  static const String deleteNotification = "/notifications/";
  static const String markNotificationAsRead = "/notifications/";
  static const String markAllNotificationsAsRead = "/notifications/mark-all-read";

  // Favorites routes
  static const String addFavorite = "/favorites/add";
  static const String removeFavorite = "/favorites/remove";
  static const String getFavorites = "/favorites/list"; // Replaces favourite
  static const String checkIfFavorited = "/favorites/check";
  static const String updateFavoriteNote = "/favorites/note";

  // Chat routes
  static const String sendMessage = "/chat/send";
  static const String getChatHistory = "/chat/history";
  static const String getChatUsers = "/chat/users";
  static const String deleteMessage = "/chat/message";
  static const String getUnreadCount = "/chat/unread-count";

  // Profile routes
  static const String getProfile = "/profile"; // Replaces profileInfo
  static const String updateProfile = "/profile/update"; // Replaces editProfile
  static const String deletePhoto = "/profile/photos/";
  static const String reorderPhotos = "/profile/photos/reorder";

  // Image routes
  static const String uploadImage = "/images/upload";
  static const String deleteImage = "/images/";
  static const String reorderImages = "/images/reorder";
  static const String setPrimaryImage = "/images/";
  static const String listImages = "/images/list";

  // Profile picture routes
  static const String uploadProfilePicture = "/profile-pictures/upload"; // Replaces pro_pic
  static const String deleteProfilePicture = "/profile-pictures/";
  static const String setPrimaryProfilePicture = "/profile-pictures/";
  static const String listProfilePictures = "/profile-pictures/list";

  // Preference routes
  static const String updateAgePreference = "/preferences/age";
  static const String getAgePreference = "/preferences/age";
  static const String resetAgePreference = "/preferences/age";
  // TODO: Add missing preference API endpoints:
  // - distance preference
  // - gender preference
  // - interest preference

  // Reference data routes
  static const String getJobs = "/jobs";
  static const String getJob = "/jobs/";
  static const String getEducation = "/education";
  static const String getEducationById = "/education/";
  static const String getGenders = "/genders";
  static const String getGenderById = "/genders/";
  static const String getPreferredGenders = "/preferred-genders";
  static const String getPreferredGenderById = "/preferred-genders/";
  static const String getInterests = "/interests"; // Replaces getInterestList
  static const String getInterestById = "/interests/";
  static const String getLanguages = "/languages"; // Replaces languagelist
  static const String getLanguageById = "/languages/";
  static const String getRelationGoals = "/relation-goals"; // Replaces relationGoalList
  static const String getRelationGoalById = "/relation-goals/";
  static const String getMusicGenres = "/music-genres";
  static const String getMusicGenreById = "/music-genres/";
  static const String getPaymentMethods = "/payment-methods"; // Replaces paymentGateway
  static const String getPaymentMethodById = "/payment-methods/";
  static const String getPaymentMethodsByCurrency = "/payment-methods/currency/";
  static const String getPaymentMethodsByType = "/payment-methods/type/";
  static const String validatePaymentAmount = "/payment-methods/validate-amount";
  // TODO: Add missing reference data API endpoints:
  // - zodiac signs
  // - personality types

  // Subscription plan routes
  static const String getSubPlans = "/sub-plans"; // Replaces plan
  static const String createSubPlan = "/sub-plans";
  static const String getSubPlansByDuration = "/sub-plans/duration";
  static const String compareSubPlans = "/sub-plans/compare";
  static const String getPlanSubPlans = "/sub-plans/plan/";
  static const String getUpgradeOptions = "/sub-plans/upgrade-options";
  static const String upgradePlan = "/sub-plans/upgrade";
  static const String getSubPlan = "/sub-plans/";
  static const String updateSubPlan = "/sub-plans/";
  static const String deleteSubPlan = "/sub-plans/";

  // TODO: Add missing API endpoints:
  // - Report user
  // - Identity verification 
  // - Map/location services
  // - FAQ/support
  // - User statistics
  // - User verification

  static String oneSignel = "650e65ed-0d75-4a54-b3e4-7d740716d51c";
}
