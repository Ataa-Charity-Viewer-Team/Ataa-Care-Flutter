class ApiResult {
  final dynamic data;
  final String? message;
  final ApiException? error;
  final bool isSuccess;

  ApiResult.success(this.data, this.message)
      : error = null,
        isSuccess = true;

  ApiResult.failure(this.error)
      : data = null,
        message = null,
        isSuccess = false;

  void when({
    required Function(dynamic data, String? message) success,
    required Function(ApiException error) failure,
  }) {
    if (isSuccess) {
      success(data, message);
    } else {
      failure(error!);
    }
  }
}

class ApiException {
  final String message;

  ApiException(this.message);
}