// Get all notifications
  static Future<Map<String, dynamic>> getNotifications() async {
    try {
      print('========== GET NOTIFICATIONS ==========');
      
      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: await getHeaders(withAuth: true),
      ).timeout(const Duration(seconds: 30));
      
      print('Notifications Status: ${response.statusCode}');
      print('Notifications Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'notifications': data['data'] ?? data['notifications'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': 'فشل في جلب الإشعارات',
          'notifications': [],
        };
      }
    } catch (e) {
      print('Notifications Error: $e');
      return {
        'success': false,
        'message': 'حدث خطأ في الاتصال: $e',
        'notifications': [],
      };
    }
  }

  // Get one notification
  static Future<Map<String, dynamic>> getNotification(String id) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/notifications/$id'),
        headers: await getHeaders(withAuth: true),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'notification': data['data'] ?? data['notification'],
        };
      } else {
        return {
          'success': false,
          'message': 'فشل في جلب الإشعار',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ في الاتصال: $e',
      };
    }
  }

  // Mark notification as read
  static Future<Map<String, dynamic>> markNotificationAsRead(String id) async {
    try {
      print('========== MARK AS READ: $id ==========');
      
      final response = await http.patch(
        Uri.parse('$baseUrl/notifications/$id/read'),
        headers: await getHeaders(withAuth: true),
      ).timeout(const Duration(seconds: 30));
      
      print('Mark Read Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'تم تعليم الإشعار كمقروء',
        };
      } else {
        return {
          'success': false,
          'message': 'فشل في تعليم الإشعار',
        };
      }
    } catch (e) {
      print('Mark Read Error: $e');
      return {
        'success': false,
        'message': 'حدث خطأ في الاتصال: $e',
      };
    }
  }

  // Delete notification
  static Future<Map<String, dynamic>> deleteNotification(String id) async {
    try {
      print('========== DELETE NOTIFICATION: $id ==========');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/notifications/$id'),
        headers: await getHeaders(withAuth: true),
      ).timeout(const Duration(seconds: 30));
      
      print('Delete Status: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'message': 'تم حذف الإشعار بنجاح',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'فشل في حذف الإشعار',
        };
      }
    } catch (e) {
      print('Delete Notification Error: $e');
      return {
        'success': false,
        'message': 'حدث خطأ في الاتصال: $e',
      };
    }
  }