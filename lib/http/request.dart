
import 'http_request.dart';

/// 调用底层的request，重新提供get，post等方便方法

class HttpUtils {
  static HttpRequest httpRequest = HttpRequest();

  /// get
  static Future get({
    required String path,
    Map<String, dynamic>? queryParameters,
    bool showLoading = true,
    bool showErrorMessage = true,
  }) {
    return httpRequest.request(
      path: path,
      method: HttpMethod.get,
      queryParameters: queryParameters,
      showLoading: showLoading,
      showErrorMessage: showErrorMessage,
    );
  }

  /// post
  static Future post({
    required String path,
    required HttpMethod method,
    dynamic data,
    bool showLoading = true,
    bool showErrorMessage = true,
  }) {
    return httpRequest.request(
      path: path,
      method: HttpMethod.post,
      data: data,
      showLoading: showLoading,
      showErrorMessage: showErrorMessage,
    );
  }
}