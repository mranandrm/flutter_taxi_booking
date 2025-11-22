class Constants {
  // -----------------------
  // BASE SERVER SETTINGS
  // -----------------------
  static const String SERVER_DOMAIN = "http://192.168.1.98:8000";
  static const String BASE_URL = "$SERVER_DOMAIN/api";

  // -----------------------
  // AUTH ROUTES
  // -----------------------
  static const String LOGIN_ROUTE = "/login";
  static const String USER_ROUTE = "/user";
  static const String LOGOUT_ROUTE = "/logout";
  static const String REGISTER_ROUTE = "/register";
  static const String UPDATE_PROFILE_ROUTE = "/update-profile";

  // -----------------------
  // SOS ROUTES
  // -----------------------
  static const String SOS_INDEX = "/sos";                 // GET
  static const String SOS_STORE = "/sos";                 // POST
  static const String SOS_SHOW = "/sos/";                 // GET with ID
  static const String SOS_UPDATE = "/sos/update/";        // POST with ID
  static const String SOS_DELETE = "/sos/delete/";        // GET with ID
}
