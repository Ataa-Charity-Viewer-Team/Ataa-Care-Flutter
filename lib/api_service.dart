import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://ataa-charity-platform.vercel.app';
  static const Duration _timeout = Duration(seconds: 30);

  // ================= TOKEN =================

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('refresh_token', token);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
  }

  // ================= HEADERS =================

  static Future<Map<String, String>> _headers({bool withAuth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (withAuth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 
      'Bearer $token'
      // 'Bearer':token;
    }
    return headers;
  }

  static Map<String, dynamic> _error(dynamic e) =>
      {'success': false, 'message': e.toString()};

  // ================= AUTH =================

  /// POST /auth/login
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: await _headers(),
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(_timeout);

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data['success'] == true) {
        if (data['accessToken'] != null) await saveToken(data['accessToken']);
        if (data['refreshToken'] != null)
          await saveRefreshToken(data['refreshToken']);
        return {
  'success': true,
  'accessToken': data['accessToken'],
  'refreshToken': data['refreshToken'],
};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'فشل تسجيل الدخول'
      };
    } catch (e) {
      return _error(e);
    }
  }

  /// POST /auth/register
  static Future<Map<String, dynamic>> register({
    required String userName,
    required String email,
    required String password,
    required String confirmPassword,
    required String phone,
    required String address,
    required String roleType,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: await _headers(),
            body: jsonEncode({
              'userName': userName,
              'email': email,
              'password': password,
              'confirmPassword': confirmPassword,
              'phone': phone,
              'address': address,
              'roleType': roleType,
            }),
          )
          .timeout(_timeout);

      final data = jsonDecode(res.body);
      return {
        'success': res.statusCode == 200 || res.statusCode == 201,
        'message': data['message'],
      };
    } catch (e) {
      return _error(e);
    }
  }

  /// POST /auth/verifyEmail
  /// ✅ الباك بيقبل OTP مش code
  static Future<Map<String, dynamic>> verifyEmail(
      String email, String otp) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/auth/verifyEmail'),
            headers: await _headers(),
            body: jsonEncode({'email': email, 'OTP': otp}),
          )
          .timeout(_timeout);

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data['success'] == true) {
        if (data['accessToken'] != null) await saveToken(data['accessToken']);
        if (data['refreshToken'] != null)
          await saveRefreshToken(data['refreshToken']);
      }

      return {
        'success': res.statusCode == 200,
        'message': data['message'],
      };
    } catch (e) {
      return _error(e);
    }
  }

  /// POST /auth/forgetPassword
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/auth/forgetPassword'),
            headers: await _headers(),
            body: jsonEncode({'email': email}),
          )
          .timeout(_timeout);

      final data = jsonDecode(res.body);
      return {
        'success': res.statusCode == 200,
        'message': data['message'],
      };
    } catch (e) {
      return _error(e);
    }
  }

  /// POST /auth/resetPassword
  /// ✅ الباك بيقبل OTP و newPassword
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/auth/resetPassword'),
            headers: await _headers(),
            body: jsonEncode({
              'email': email,
              'OTP': otp,
              'newPassword': newPassword,
            }),
          )
          .timeout(_timeout);

      final data = jsonDecode(res.body);
      return {
        'success': res.statusCode == 200,
        'message': data['message'],
      };
    } catch (e) {
      return _error(e);
    }
  }

  /// POST /auth/refreshToken
  static Future<Map<String, dynamic>> refreshToken() async {
    try {
      final refresh = await getRefreshToken();
      if (refresh == null) return {'success': false};

      final res = await http
          .post(
            Uri.parse('$baseUrl/auth/refreshToken'),
            headers: await _headers(),
            body: jsonEncode({'refreshToken': refresh}),
          )
          .timeout(_timeout);

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data['success'] == true) {
        if (data['accessToken'] != null) await saveToken(data['accessToken']);
        if (data['refreshToken'] != null)
          await saveRefreshToken(data['refreshToken']);
      }

      return data;
    } catch (e) {
      return _error(e);
    }
  }

  /// Logout — local only
  static Future<void> logout() async => await clearTokens();

  // ================= USERS =================

  /// GET /users/profile
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/users/profile'),
              headers: await _headers(withAuth: true))
          .timeout(_timeout);
      return jsonDecode(res.body);
    } catch (e) {
      return _error(e);
    }
  }

  /// PATCH /users/profile
  static Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> body) async {
    try {
      final res = await http
          .patch(Uri.parse('$baseUrl/users/profile'),
              headers: await _headers(withAuth: true),
              body: jsonEncode(body))
          .timeout(_timeout);
      return jsonDecode(res.body);
    } catch (e) {
      return _error(e);
    }
  }

  /// PATCH /users/changePassword
  static Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final res = await http
          .patch(Uri.parse('$baseUrl/users/changePassword'),
              headers: await _headers(withAuth: true),
              body: jsonEncode({
                'oldPassword': oldPassword,
                'newPassword': newPassword,
              }))
          .timeout(_timeout);
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) await clearTokens();
      return data;
    } catch (e) {
      return _error(e);
    }
  }

  /// DELETE /users/account
  static Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final res = await http
          .delete(Uri.parse('$baseUrl/users/account'),
              headers: await _headers(withAuth: true))
          .timeout(_timeout);
      await clearTokens();
      return jsonDecode(res.body);
    } catch (e) {
      return _error(e);
    }
  }

  /// GET /users  — Admin
  static Future<Map<String, dynamic>> getAllUsers(
      {int page = 1, int limit = 10}) async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/users?page=$page&limit=$limit'),
              headers: await _headers(withAuth: true))
          .timeout(_timeout);
      return jsonDecode(res.body);
    } catch (e) {
      return _error(e);
    }
  }

  /// GET /users/:id  — Admin
  static Future<Map<String, dynamic>> getUserById(String id) async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/users/$id'),
              headers: await _headers(withAuth: true))
          .timeout(_timeout);
      return jsonDecode(res.body);
    } catch (e) {
      return _error(e);
    }
  }

  /// DELETE /users/:id  — Admin
  static Future<Map<String, dynamic>> deleteUser(String id) async {
    try {
      final res = await http
          .delete(Uri.parse('$baseUrl/users/$id'),
              headers: await _headers(withAuth: true))
          .timeout(_timeout);
      return jsonDecode(res.body);
    } catch (e) {
      return _error(e);
    }
  }

  // ================= CHARITY =================

  /// GET /charity/charities
  static Future<Map<String, dynamic>> getCharities(
      {int page = 1, int limit = 10}) async {
    try {
      final res = await http
          .get(
              Uri.parse(
                  '$baseUrl/charity/charities?page=$page&limit=$limit'),
              headers: await _headers(withAuth: true))
          .timeout(_timeout);
      return jsonDecode(res.body);
    } catch (e) {
      return _error(e);
    }
  }

  /// GET /charity/:id
  static Future<Map<String, dynamic>> getCharity(String id) async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/charity/$id'),
              headers: await _headers(withAuth: true))
          .timeout(_timeout);
      return jsonDecode(res.body);
    } catch (e) {
      return _error(e);
    }
  }

  /// POST /charity  — form-data
  static Future<Map<String, dynamic>> createCharity({
    required String name,
    String? description,
    String? address,
    String? phone,
    String? email,
    File? image,
  }) async {
    try {
      final token = await getToken();
      final request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/charity'));
      if (token != null) request.headers['Authorization'] = token;
      request.headers['Accept'] = 'application/json';
      request.fields['name'] = name;
      if (description != null) request.fields['description'] = description;
      if (address != null) request.fields['address'] = address;
      if (phone != null) request.fields['phone'] = phone;
      if (email != null) request.fields['email'] = email;
      if (image != null)
        request.files
            .add(await http.MultipartFile.fromPath('image', image.path));

      final streamed = await request.send().timeout(_timeout);
      final res = await http.Response.fromStream(streamed);
      return jsonDecode(res.body);
    } catch (e) {
      return _error(e);
    }
  }

  /// PATCH /charity/:id
  static Future<Map<String, dynamic>> updateCharity(
      String id, Map<String, dynamic> body) async {
    try {
      final res = await http
          .patch(Uri.parse('$baseUrl/charity/$id'),
              headers: await _headers(withAuth: true),
              body: jsonEncode(body))
          .timeout(_timeout);
      return jsonDecode(res.body);
    } catch (e) {
      return _error(e);
    }
  }

  /// DELETE /charity/:id
  static Future<Map<String, dynamic>> deleteCharity(String id) async {
    try {
      final res = await http
          .delete(Uri.parse('$baseUrl/charity/$id'),
              headers: await _headers(withAuth: true))
          .timeout(_timeout);
      return jsonDecode(res.body);
    } catch (e) {
      return _error(e);
    }
  }

  // ================= DONATION =================

  /// POST /donor  — form-data
  static Future<Map<String, dynamic>> createDonation({
    required String charityId,
    required String type,
    required String size,
    required int quantity,
    String? description,
    List<File>? images,
  }) async {
    try {
      final token = await getToken();
      final request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/donor'));
      if (token != null) request.headers['Authorization'] = token;
      request.headers['Accept'] = 'application/json';
      request.fields['charityId'] = charityId;
      request.fields['type'] = type;
      request.fields['size'] = size;
      request.fields['quantity'] = quantity.toString();
      if (description != null) request.fields['description'] = description;
      if (images != null) {
        for (final img in images) {
          request.files
              .add(await http.MultipartFile.fromPath('images', img.path));
        }
      }

      final streamed = await request.send().timeout(_timeout);
      final res = await http.Response.fromStream(streamed);
      return jsonDecode(res.body);
    } catch (e) {
      return _error(e);
    }
  }

  /// GET /donor
  static Future<Map<String, dynamic>> getMyDonations(
      {int page = 1, int limit = 10}) async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/donor?page=$page&limit=$limit'),
              headers: await _headers(withAuth: true))
          .timeout(_timeout);
      return jsonDecode(res.body);
    } catch (e) {
      return _error(e);
    }
  }

  // ================= AI =================

  /// POST /ai/chat
  static Future<Map<String, dynamic>> aiChat(String message) async {
    try {
      final res = await http
          .post(Uri.parse('$baseUrl/ai/chat'),
              headers: await _headers(withAuth: true),
              body: jsonEncode({'message': message}))
          .timeout(_timeout);
      return jsonDecode(res.body);
    } catch (e) {
      return _error(e);
    }
  }

  /// POST /ai/analysis
  static Future<Map<String, dynamic>> aiAnalysis(
      Map<String, dynamic> body) async {
    try {
      final res = await http
          .post(Uri.parse('$baseUrl/ai/analysis'),
              headers: await _headers(withAuth: true),
              body: jsonEncode(body))
          .timeout(_timeout);
      return jsonDecode(res.body);
    } catch (e) {
      return _error(e);
    }
  }

  // ================= NOTIFICATIONS =================

  /// GET /notification
  static Future<Map<String, dynamic>> getNotifications() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/notification'),
              headers: await _headers(withAuth: true))
          .timeout(_timeout);
      return jsonDecode(res.body);
    } catch (e) {
      return _error(e);
    }
  }

  /// PATCH /notification/:id
  static Future<Map<String, dynamic>> markNotificationAsRead(
      String id) async {
    try {
      final res = await http
          .patch(Uri.parse('$baseUrl/notification/$id'),
              headers: await _headers(withAuth: true))
          .timeout(_timeout);
      return jsonDecode(res.body);
    } catch (e) {
      return _error(e);
    }
  }

  /// DELETE /notification/:id
  static Future<Map<String, dynamic>> deleteNotification(String id) async {
    try {
      final res = await http
          .delete(Uri.parse('$baseUrl/notification/$id'),
              headers: await _headers(withAuth: true))
          .timeout(_timeout);
      return jsonDecode(res.body);
    } catch (e) {
      return _error(e);
    }
  }

  // ================= DASHBOARD =================

  /// GET /dashboard/stats
  static Future<Map<String, dynamic>> getStats() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/dashboard/stats'),
              headers: await _headers(withAuth: true))
          .timeout(_timeout);
      return jsonDecode(res.body);
    } catch (e) {
      return _error(e);
    }
  }

  /// GET /dashboard/donations
  static Future<Map<String, dynamic>> getDashboardDonations(
      {int page = 1, int limit = 10}) async {
    try {
      final res = await http
          .get(
              Uri.parse(
                  '$baseUrl/dashboard/donations?page=$page&limit=$limit'),
              headers: await _headers(withAuth: true))
          .timeout(_timeout);
      return jsonDecode(res.body);
    } catch (e) {
      return _error(e);
    }
  }

  /// GET /dashboard/requests
  static Future<Map<String, dynamic>> getDashboardRequests(
      {int page = 1, int limit = 10}) async {
    try {
      final res = await http
          .get(
              Uri.parse(
                  '$baseUrl/dashboard/requests?page=$page&limit=$limit'),
              headers: await _headers(withAuth: true))
          .timeout(_timeout);
      return jsonDecode(res.body);
    } catch (e) {
      return _error(e);
    }
  }

  /// PATCH /dashboard/request/:id
  static Future<Map<String, dynamic>> updateRequestStatus(
      String id, String status) async {
    try {
      final res = await http
          .patch(Uri.parse('$baseUrl/dashboard/request/$id'),
              headers: await _headers(withAuth: true),
              body: jsonEncode({'status': status}))
          .timeout(_timeout);
      return jsonDecode(res.body);
    } catch (e) {
      return _error(e);
    }
  }

  // ================= REPORT =================

  /// POST /report
  static Future<Map<String, dynamic>> createReport(
      Map<String, dynamic> body) async {
    try {
      final res = await http
          .post(Uri.parse('$baseUrl/report'),
              headers: await _headers(withAuth: true),
              body: jsonEncode(body))
          .timeout(_timeout);
      return jsonDecode(res.body);
    } catch (e) {
      return _error(e);
    }
  }

  /// GET /report/allReports
  static Future<Map<String, dynamic>> getReports(
      {int page = 1, int limit = 10}) async {
    try {
      final res = await http
          .get(
              Uri.parse(
                  '$baseUrl/report/allReports?page=$page&limit=$limit'),
              headers: await _headers(withAuth: true))
          .timeout(_timeout);
      return jsonDecode(res.body);
    } catch (e) {
      return _error(e);
    }
  }

  // ================= RATING =================

  /// POST /rating/:donationId
  static Future<Map<String, dynamic>> createRating({
    required String donationId,
    required int rating,
    String? comment,
  }) async {
    try {
      final res = await http
          .post(Uri.parse('$baseUrl/rating/$donationId'),
              headers: await _headers(withAuth: true),
              body: jsonEncode({
                'rating': rating,
                if (comment != null) 'comment': comment,
              }))
          .timeout(_timeout);
      return jsonDecode(res.body);
    } catch (e) {
      return _error(e);
    }
  }

  /// GET /rating/:donationId
  static Future<Map<String, dynamic>> getRating(String donationId) async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/rating/$donationId'),
              headers: await _headers(withAuth: true))
          .timeout(_timeout);
      return jsonDecode(res.body);
    } catch (e) {
      return _error(e);
    }
  }
}
