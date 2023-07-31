import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';

//辅助配置
import 'options.dart';
import 'interceptor.dart';

class HttpRequest {
  // 单例模式使用Http类，
  static final HttpRequest _instance = HttpRequest._internal();

  factory HttpRequest() => _instance;

  static late final Dio dio;

  /// 内部构造方法
  HttpRequest._internal() {
    /// 初始化dio
    BaseOptions options = BaseOptions(
        connectTimeout: 3000,
        receiveTimeout: 3000,
        sendTimeout: 3000,
        baseUrl: HttpOptions.baseUrl);
    AnimatedIcons.menu_close;

    dio = Dio(options);

    /// 添加各种拦截器
    dio.interceptors.add(ErrorInterceptor());
    // dio.interceptors.add(PrettyDioLogger(
    //     requestHeader: true,
    //     requestBody: true,
    //     responseHeader: true,
    //     responseBody: true));
  }

  /// 封装request方法
  Future request({
    required String path, //接口地址
    required HttpMethod method, //请求方式
    dynamic data, //数据
    Map<String, dynamic>? queryParameters,
    bool showLoading = true, //加载过程
    bool showErrorMessage = true, //返回数据
  }) async {
    const Map methodValues = {
      HttpMethod.get: 'get',
      HttpMethod.post: 'post',
      HttpMethod.put: 'put',
      HttpMethod.delete: 'delete',
      HttpMethod.patch: 'patch',
      HttpMethod.head: 'head'
    };

    //动态添加header头
    Map<String, dynamic> headers = <String, dynamic>{};
    headers["version"] = "1.0.0";

    Options options = Options(
      method: methodValues[method],
      headers: headers,
    ); 

    try {
      if (showLoading) {
        Fluttertoast.showToast(msg: 'load......',gravity: ToastGravity.CENTER);
      }
      Response response = await HttpRequest.dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    }on HttpException catch (error) {
      if (showErrorMessage) {
        EasyLoading.showToast(error.msg);
      }
    } on DioError catch (error) {
      if (showErrorMessage) {
        EasyLoading.showToast(error.message!);
      }
    }  finally {
      if (showLoading) {
        Fluttertoast.cancel();
      }
      EasyLoading.dismiss();
    }
  }
}

enum HttpMethod {
  get,
  post,
  delete,
  put,
  patch,
  head,
}
