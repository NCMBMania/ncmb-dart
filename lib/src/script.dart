import 'request.dart';

/// スクリプト用クラス
class NCMBScript {
  /// スクリプト名
  final String scriptName;

  /// 追加するヘッダー
  Map<String, String> _headers = {};

  /// 追加するボディ
  Map<String, Object> _body = {};

  /// 追加するクエリー
  Map<String, String> _query = {};

  /// コンストラクター
  /// [scriptName] スクリプト名
  NCMBScript(this.scriptName);

  /// ヘッダーを追加する
  /// [name] ヘッダー名
  /// [value] ヘッダーの値
  NCMBScript header(String name, String value) {
    _headers[name] = value;
    return this;
  }

  /// ボディを追加する
  /// [name] ボディ名
  /// [value] ボディの値
  NCMBScript body(String name, Object value) {
    _body[name] = value;
    return this;
  }

  /// クエリーを追加する
  /// [name] クエリー名
  /// [value] クエリーの値
  NCMBScript query(String name, Object value) {
    _query[name] = value.toString();
    return this;
  }

  /// GETメソッドを実行する
  Future<Object> get() {
    NCMBRequest r = new NCMBRequest();
    return r.exec('GET', scriptName,
        queries: _query, additionalHeaders: _headers, isScript: true);
  }

  /// POSTメソッドを実行する
  Future<Object> post() {
    NCMBRequest r = new NCMBRequest();
    return r.exec('POST', scriptName,
        queries: _query,
        additionalHeaders: _headers,
        fields: _body,
        isScript: true);
  }

  /// PUTメソッドを実行する
  Future<Object> put() {
    NCMBRequest r = new NCMBRequest();
    return r.exec('PUT', scriptName,
        queries: _query,
        additionalHeaders: _headers,
        fields: _body,
        isScript: true);
  }

  /// DELETEメソッドを実行する
  Future<Object> delete() {
    NCMBRequest r = new NCMBRequest();
    return r.exec('DELETE', scriptName,
        queries: _query,
        additionalHeaders: _headers,
        fields: _body,
        isScript: true);
  }
}
