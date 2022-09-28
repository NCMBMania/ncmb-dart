import 'object.dart';
import 'request.dart';
import 'user.dart';

/// NCMBクラス
/// NCMBクラスは、NCMBの初期化を行うためのクラスです
class NCMB {
  /// アプリケーションキー
  String? applicationKey;

  /// クライアントキー
  String? clientKey;

  /// セッショントークン
  String? sessionToken;

  /// バージョン
  String version = '2.6.6';

  /// NCMBクラスのコンストラクタ
  /// アプリケーションキー、クライアントキーを指定して初期化します
  /// [applicationKey] アプリケーションキー
  /// [clientKey] クライアントキー
  NCMB(String applicationKey, String clientKey) {
    this.applicationKey = applicationKey;
    this.clientKey = clientKey;
    NCMBUser.ncmb = this;
    NCMBObject.ncmb = this;
    NCMBRequest.ncmb = this;
  }
}
