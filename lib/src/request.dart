import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'main.dart';
import 'query.dart';
import 'relation.dart';
import 'geopoint.dart';
import 'acl.dart';
import 'signature.dart';

/// NCMBリクエストを扱うクラス
class NCMBRequest {
  /// NCMBオブジェクト
  static NCMB? ncmb;

  /// GETリクエストを行う
  /// [name] クラス名
  /// [queries] 検索条件
  /// [multipart] マルチパートリクエストかどうか（ファイルストア用）。省略時はfalse
  Future<List> get(String name, Map queries, {multipart = false}) async {
    try {
      var res = await exec('GET', name, queries: queries, multipart: multipart)
          as Map<String, dynamic>;
      return res['results'] as List;
    } catch (e) {
      throw e;
    }
  }

  /// POSTリクエストを行う
  /// [name] クラス名
  /// [fields] 追加するデータ情報
  /// [multipart] マルチパートリクエストかどうか（ファイルストア用）。省略時はfalse
  Future<Map> post(String name, Map fields, {multipart = false}) async {
    return exec('POST', name, fields: fields, multipart: multipart);
  }

  /// PUTリクエストを行う
  /// [name] クラス名
  /// [objectId] 更新対象のオブジェクトID
  /// [fields] 更新するデータ情報
  Future<Map> put(String name, String objectId, Map fields) async {
    return exec('PUT', name, fields: fields, objectId: objectId);
  }

  /// DELETEリクエストを行う
  /// [name] クラス名
  /// [objectId] 削除対象のオブジェクトID
  Future<Map> delete(String name, String objectId) async {
    return exec('DELETE', name, objectId: objectId);
  }

  /// リクエストを実行する
  /// [method] リクエストメソッド
  /// [name] クラス名
  /// [objectId] オブジェクトID。省略時は空文字。
  /// [fields] データ情報。省略時は空のMap。
  /// [queries] 検索条件。省略時は空のMap。
  /// [multipart] マルチパートリクエストかどうか（ファイルストア用）。省略時はfalse
  /// [path] パス。省略時は空文字。
  /// [additionHeaders] 追加するヘッダー情報。省略時は空のMap。
  /// [isScript] スクリプト実行かどうか。省略時はfalse。
  Future<Map> exec(String method, String name,
      {fields = const {},
      objectId = '',
      queries = const {},
      Map<String, String> additionalHeaders = const {},
      path = '',
      multipart = false,
      isScript = false}) async {
    Signature s = new Signature(NCMBRequest.ncmb!, isScript: isScript);
    DateTime time = DateTime.now();
    final newFields = Map.from(fields)
      ..removeWhere((k, v) => (k == 'objectId' ||
          k == 'createDate' ||
          k == 'updateDate' ||
          (method == 'PUT' && name == 'users' && k == 'authData') ||
          (method == 'PUT' && name == 'users' && k == 'mailAddressConfirm')));
    String signature = s.generate(method, name, time,
        objectId: objectId, queries: queries, definePath: path);
    String url =
        s.url(name, objectId: objectId, queries: queries, definePath: path);
    Map<String, String> headers = {
      "X-NCMB-Application-Key": NCMBRequest.ncmb!.applicationKey!,
      "X-NCMB-Timestamp": time.toUtc().toIso8601String(),
      "X-NCMB-Signature": signature
    };
    headers.addAll(additionalHeaders);
    if (name == 'files') {
      headers.remove('Content-Type');
    }
    var sessionToken = NCMBRequest.ncmb!.sessionToken;
    if (sessionToken != null) {
      headers['X-NCMB-Apps-Session-Token'] = sessionToken;
    }
    try {
      var response = await req(url, method, newFields, headers,
          multipart: multipart, fileName: objectId);
      if (response.data is Uint8List) {
        return {"data": response.data};
      }

      if (!isScript && method == 'DELETE') return {};
      return response.data;
    } on DioError catch (e) {
      throw Exception(e.response!.data);
    }
  }

  /// データをJSON化する
  /// NCMB特有のデータ変換を行う。
  /// [fields] データ情報
  String jsonEncode(Map fields) {
    fields.forEach((k, v) {
      if (v is DateTime) {
        fields[k] = {'__type': 'Date', 'iso': v.toUtc().toIso8601String()};
      }
      if (v is NCMBAcl) {
        fields[k] = v.toJson();
      }
      if (v is NCMBRelation) {
        fields[k] = v.toJson();
      }
      if (v is NCMBQuery) {
        fields[k] = v.toJson();
      }
      if (v is NCMBGeoPoint) {
        fields[k] = v.toJson();
      }
    });
    return json.encode(fields);
  }

  /// データ表示用（デバッグ用）
  /// [text] テキスト
  void printWrapped(String text) {
    final pattern = new RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  /// リクエスト用オブジェクトを返す
  /// [url] URL
  /// [method] リクエストメソッド
  /// [fields] データ情報
  /// [headers] ヘッダー情報
  /// [multipart] マルチパートリクエストかどうか（ファイルストア用）。省略時はfalse
  /// [fileName] ファイル名（ファイルストア用）。省略時は空文字。
  Future<Response> req(
      String url, String method, Map fields, Map<String, dynamic> headers,
      {multipart = false, fileName = ''}) async {
    Response? response;
    var dio = new Dio();
    switch (method) {
      case 'GET':
        {
          if (multipart) {
            response = await dio.get<List<int>>(url,
                options: Options(
                    headers: headers, responseType: ResponseType.bytes));
          } else {
            response = await dio.get(url, options: Options(headers: headers));
          }
        }
        break;

      case 'POST':
        {
          var data;
          if (multipart) {
            FormData formData = FormData.fromMap({
              'acl': fields['acl'].toJson(),
              'file': MultipartFile.fromBytes(fields['file'],
                  filename: fileName, contentType: fields['mimeType'])
            });
            data = formData;
          } else {
            data = jsonEncode(fields);
          }
          response = await dio.post(url,
              data: data, options: Options(headers: headers));
        }
        break;

      case 'PUT':
        {
          response = await dio.put(url,
              data: jsonEncode(fields), options: Options(headers: headers));
        }
        break;

      case 'DELETE':
        {
          response = await dio.delete(url, options: Options(headers: headers));
        }
        break;
    }
    return response!;
  }
}
