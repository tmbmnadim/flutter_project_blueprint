import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math show min;

import 'package:blueprint/core/error/server_exception.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class ApiServices<T> {
  final String _baseUrl;
  final bool _debug;
  String? _authToken;
  ApiServices({required String baseUrl, bool debug = false, String? authToken})
    : _baseUrl = baseUrl,
      _debug = debug,
      _authToken = authToken;

  /// This is the top request. The other request derives from this one.
  ///
  /// It can return ether a Map\<String, dynamic\> or List\<Map\<String, dynamic\>\>
  /// or something else(depends on server)
  Future<dynamic> _request({
    required Future<http.Response> Function(Uri) request,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    required String path,
    Map<String, dynamic>? query,
    String? fragment,
  }) async {
    if (_debug) debugPrint('BASE URL: $_baseUrl');

    String normalizedBase = _baseUrl;
    if (!normalizedBase.endsWith('/')) {
      normalizedBase += '/';
    }

    // 2. Parse the normalized base
    final Uri? baseUri = Uri.tryParse(normalizedBase);

    // 3. Normalize Path: Ensure it DOES NOT start with '/' so it's treated as relative
    String normalizedPath = path;
    if (normalizedPath.startsWith('/')) {
      normalizedPath = normalizedPath.substring(1);
    }

    if (baseUri == null) throw Exception("Invalid or empty uri");

    final uri = baseUri
        .resolve(normalizedPath)
        .replace(queryParameters: query, fragment: fragment);

    if (_debug) debugPrint('REQ URL: ${uri.toString()}');
    if (_debug) debugPrint('REQ QUERY: $query');
    if (_debug) debugPrint('REQ BODY: $body');
    // Sending a request
    final response = await request(uri);
    if (_debug) {
      final firstEnd = math.min(500, response.body.length);
      log('RESPONSE BODY: ${response.body.substring(0, firstEnd)}');
      debugPrint('RESPONSE BODY: ${response.body.substring(0, firstEnd)}');
    }

    // Extracting the response body
    final result = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (result is List<String>) {
        return result.map((e) => jsonDecode(e) as Map<String, dynamic>);
      } else {
        return result;
      }
    } else {
      throw ServerException(
        code: response.statusCode,
        message: _getErrorMessage(result),
        error: result,
      );
    }
  }

  String _getErrorMessage(dynamic response) {
    if (response is Map<String, dynamic>) {
      if (response.containsKey("message")) {
        return response['message'];
      } else if (response.containsKey("details")) {
        return response['details'];
      }
    }
    return response.toString();
  }

  /// POST: baseUrl/path?queryKey=queryValue&queryKey2=queryValue2
  ///
  /// It can return ether a Map\<String, dynamic\> or List\<Map\<String, dynamic\>\>
  /// or something else(depends on server)
  Future<dynamic> post({
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    required String path,
    Map<String, dynamic>? query,
    String? fragment,
  }) async {
    final result = await _request(
      request: (uri) {
        if (_debug) debugPrint('REQUEST URL: ${uri.toString()}');
        if (headers != null && _debug) log('HEADERS    : $headers');
        if (_debug) log('BODY       : $body');
        if (headers != null && _debug) log('QUERY      : $query');
        return http.post(uri, headers: headers, body: jsonEncode(body));
      },
      path: path,
      headers: headers,
      body: body,
      query: query,
      fragment: fragment,
    );

    return result;
  }

  /// PUT: baseUrl/path?queryKey=queryValue&queryKey2=queryValue2
  ///
  /// It can return ether a Map\<String, dynamic\> or List\<Map\<String, dynamic\>\>
  /// or something else(depends on server)
  Future<dynamic> put({
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    required String path,
    Map<String, dynamic>? query,
    String? fragment,
  }) async {
    final result = await _request(
      request: (uri) {
        if (_debug) debugPrint('REQUEST URL: ${uri.toString()}');
        if (headers != null && _debug) log('HEADERS    : $headers');
        if (_debug) log('BODY       : $body');
        if (headers != null && _debug) log('QUERY      : $query');
        return http.put(uri, headers: headers, body: jsonEncode(body));
      },
      path: path,
      headers: headers,
      body: body,
      query: query,
      fragment: fragment,
    );

    return result;
  }

  /// GET: baseUrl/path?queryKey=queryValue&queryKey2=queryValue2
  ///
  /// It can return ether a Map\<String, dynamic\> or List\<Map\<String, dynamic\>\>
  /// or something else(depends on server)
  Future<dynamic> get({
    Map<String, String>? headers,
    required String path,
    Map<String, dynamic>? query,
    String? fragment,
  }) async {
    final result = await _request(
      request: (uri) {
        return http.get(uri, headers: headers);
      },
      path: path,
      headers: headers,
      query: query,
      fragment: fragment,
    );

    return result;
  }

  /// PATCH: baseUrl/path?queryKey=queryValue&queryKey2=queryValue2
  ///
  /// It can return ether a Map\<String, dynamic\> or List\<Map\<String, dynamic\>\>
  /// or something else(depends on server)
  Future<dynamic> patch({
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    required String path,
    Map<String, dynamic>? query,
    String? fragment,
  }) async {
    final result = await _request(
      request: (uri) {
        return http.patch(uri, headers: headers, body: jsonEncode(body));
      },
      path: path,
      body: body,
      headers: headers,
      query: query,
      fragment: fragment,
    );

    return result;
  }

  /// DELETE: baseUrl/path?queryKey=queryValue&queryKey2=queryValue2
  ///
  /// It can return ether a Map\<String, dynamic\> or List\<Map\<String, dynamic\>\>
  /// or something else(depends on server)
  Future<dynamic> delete({
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    required String path,
    Map<String, dynamic>? query,
    String? fragment,
  }) async {
    final result = await _request(
      request: (uri) =>
          http.delete(uri, headers: headers, body: jsonEncode(body)),
      path: path,
      body: body,
      headers: headers,
      query: query,
      fragment: fragment,
    );

    return result;
  }

  // Multipart Request
  ///
  /// [method]: 'POST', 'PATCH', 'PUT'
  /// [path]: Endpoint path
  /// [data]: Text fields {key: value}
  /// [files]: File paths {field_name: file_path}
  Future<dynamic> multipart({
    required String method,
    required String path,
    Map<String, String>? data,
    Map<String, String>? files,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
  }) async {
    // 1. Prepare URI (Same logic as _request)
    if (_debug) debugPrint('MULTIPART BASE URL: $_baseUrl');

    String normalizedBase = _baseUrl;
    if (!normalizedBase.endsWith('/')) {
      normalizedBase += '/';
    }

    final Uri? baseUri = Uri.tryParse(normalizedBase);

    String normalizedPath = path;
    if (normalizedPath.startsWith('/')) {
      normalizedPath = normalizedPath.substring(1);
    }

    if (baseUri == null) throw Exception("Invalid or empty uri");

    final uri = baseUri.resolve(normalizedPath).replace(queryParameters: query);

    if (_debug) debugPrint('MULTIPART URL: $uri');

    // 2. Prepare Request
    var request = http.MultipartRequest(method, uri);

    // 3. Add Headers
    // Get default headers but REMOVE 'Content-Type' so the boundary is set automatically
    final Map<String, String> finalHeaders = Map.from(this.headers);
    finalHeaders.remove('Content-Type');

    if (headers != null) {
      finalHeaders.addAll(headers);
    }
    request.headers.addAll(finalHeaders);

    if (_debug) log('HEADERS    : ${request.headers}');

    // 4. Add Text Fields
    if (data != null) {
      request.fields.addAll(data);
      if (_debug) log('FIELDS     : $data');
    }

    // 5. Add Files
    if (files != null) {
      for (var entry in files.entries) {
        if (entry.value.isNotEmpty) {
          try {
            var file = await http.MultipartFile.fromPath(
              entry.key,
              entry.value,
            );
            request.files.add(file);
            if (_debug) {
              log('FILE ADDED : Key: ${entry.key}, Path: ${entry.value}');
            }
          } catch (e) {
            debugPrint("Error adding file: $e");
          }
        }
      }
    }

    // 6. Send & Handle Response
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (_debug) {
      final firstEnd = math.min(500, response.body.length);
      debugPrint('RESPONSE BODY: ${response.body.substring(0, firstEnd)}');
    }

    final result = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return result;
    } else {
      throw ServerException(
        code: response.statusCode,
        message: _getErrorMessage(result),
        error: result,
      );
    }
  }

  /// Multipart Request for List of Files
  /// [fileKeyMap]: { 'vehicleImage': ['path/to/img1', 'path/to/img2'] }
  Future<dynamic> multipartList({
    required String method,
    required String path,
    Map<String, String>? fields,
    Map<String, List<String>>? fileKeyMap,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
  }) async {
    if (_debug) debugPrint('MULTIPART LIST BASE URL: $_baseUrl');

    String normalizedBase = _baseUrl;
    if (!normalizedBase.endsWith('/')) {
      normalizedBase += '/';
    }

    final Uri? baseUri = Uri.tryParse(normalizedBase);
    String normalizedPath = path.startsWith('/') ? path.substring(1) : path;

    if (baseUri == null) throw Exception("Invalid or empty uri");

    final uri = baseUri.resolve(normalizedPath).replace(queryParameters: query);

    if (_debug) debugPrint('MULTIPART LIST URL: $uri');

    var request = http.MultipartRequest(method, uri);

    // 1. Headers
    final Map<String, String> finalHeaders = Map.from(this.headers);
    finalHeaders.remove(
      'Content-Type',
    ); // Let MultipartRequest set the boundary
    if (headers != null) {
      finalHeaders.addAll(headers);
    }
    request.headers.addAll(finalHeaders);

    // 2. Fields
    if (fields != null) {
      request.fields.addAll(fields);
      if (_debug) log('FIELDS: $fields');
    }

    // 3. Files (List support)
    if (fileKeyMap != null) {
      for (var entry in fileKeyMap.entries) {
        String key = entry.key;
        List<String> paths = entry.value;

        for (var filePath in paths) {
          if (filePath.isNotEmpty) {
            try {
              var file = await http.MultipartFile.fromPath(key, filePath);
              request.files.add(file);
              if (_debug) log('FILE ADDED: Key: $key, Path: $filePath');
            } catch (e) {
              debugPrint("Error adding file ($filePath): $e");
            }
          }
        }
      }
    }

    // 4. Send
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (_debug) {
      final firstEnd = math.min(500, response.body.length);
      debugPrint('RESPONSE BODY: ${response.body.substring(0, firstEnd)}');
    }

    final result = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return result;
    } else {
      throw ServerException(
        code: response.statusCode,
        message: _getErrorMessage(result),
        error: result,
      );
    }
  }

  void setAuthToken(String token) {
    _authToken ??= token;
  }

  Map<String, String> get headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }
}
