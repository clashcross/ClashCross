import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sp_util/sp_util.dart';

import 'options.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    // 根据 DioError 创建 HttpException
    HttpException httpException = HttpException.create(err);

    // dio 默认的错误实例，如果是没有网络，只能得到一个未知错误，无法精确得知是否是无网络的情况
    // 这里对于断网的情况，给一个特殊的 code 和 msg
    if (err.type == DioErrorType.sendTimeout) {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        httpException = HttpException(code: -100, msg: 'None Network.');
      }
    }

    // 执行自定义的错误处理逻辑
    handleCustomError(httpException);

    // 调用父类，回到 Dio 框架
    super.onError(err, handler);
  }

  void handleCustomError(HttpException httpException) {
    // 在这里执行您的自定义错误处理逻辑
    // 可以根据不同的错误类型进行特定处理，如显示错误提示、记录错误日志等
    // 您可以根据具体需求来自定义实现该方法
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.queryParameters.addAll({
      "access-token": SpUtil.getString('access_token'),
      'X-Api-Key': HttpOptions.xApiKey
    });
    // TODO: implement onRequest
    super.onRequest(options, handler);
  }
}

class HttpException implements Exception {
  final int code;
  final String msg;

  HttpException({required this.code, required this.msg});

  factory HttpException.create(DioError error) {
    if (error.response != null) {
      // 如果存在响应，可以从响应中获取更多错误信息
      // 例如，可以从响应的状态码获取错误码，从响应的数据中获取错误消息等
      int statusCode = error.response!.statusCode!;
      // String errorMessage = error.response!.data['message'];

      // 根据具体需求，可以自定义错误码和错误消息的映射关系
      // 这里只是一个示例
      switch (statusCode) {
        case 400:
          return HttpException(code: -400, msg: '无法找到该网页');
        case 401:
          return HttpException(code: -401, msg: '认证错误');
        case 403:
          return HttpException(code: 403, msg: 'Server rejects execution');

        case 404:
          return HttpException(code: 404, msg: 'Unable to connect to server');

        case 405:
          return HttpException(
              code: 405, msg: 'The request method is disabled');

        case 500:
          return HttpException(code: 500, msg: 'Server internal error');

        case 502:
          return HttpException(code: 502, msg: 'Invalid request');

        case 503:
          return HttpException(code: 503, msg: 'The server is down.');

        case 505:
          return HttpException(
              code: 505, msg: 'HTTP requests are not supported');
        default:
          return HttpException(code: -1, msg: 'Unknown Error');
      }
    } else {
      // 如果没有响应，可以根据错误类型进行特定处理
      if (error.type == DioErrorType.connectTimeout) {
        return HttpException(code: -408, msg: 'Connection Timeout');
      } else if (error.type == DioErrorType.sendTimeout) {
        return HttpException(code: -409, msg: 'Send Timeout');
      } else if (error.type == DioErrorType.receiveTimeout) {
        return HttpException(code: -410, msg: 'Receive Timeout');
      } else {
        return HttpException(code: -1, msg: 'Unknown Error');
      }
    }
  }

  @override
  String toString() {
    return 'HttpException: code=$code, msg=$msg';
  }
}
