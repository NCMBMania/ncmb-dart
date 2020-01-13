part of ncmb;

class NCMBInstallation extends NCMBObject {
  NCMBInstallation(NCMB ncmb) : super(ncmb, 'installations');
  
  Future<NCMBInstallation> register() async {
    final plainNotificationToken = PlainNotificationToken();
    if (Platform.isIOS) {
      plainNotificationToken.requestPermission();
      await plainNotificationToken.onIosSettingsRegistered.first;
    }
    final String token = await plainNotificationToken.getToken();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _fields = {
      'applicationName': packageInfo.appName,
      'appVersion': packageInfo.version,
      'deviceType': Platform.isIOS ? 'ios' : 'android',
      'sdkVersion': _ncmb.version,
      'badge': 0,
      'channels': [],
      'deviceToken': token,
      'timeZone': DateTime.now().timeZoneName
    };
    var installation = NCMBInstallation(_ncmb);
    NCMBRequest r = NCMBRequest(_ncmb);
    Map response = await r.post(_name, _fields);
    installation.sets(response);
    return installation;
  }
  
  void receive(void f(String type, Map message)) {
    final reactor = NotificationReactor();
    reactor.setHandlers(
      onLaunch: (Map<String, dynamic> message) => f('launch', message),
      onResume: (Map<String, dynamic> message) => f('resume', message),
      onMessage: (Map<String, dynamic> message) => f('message', message)
    );
  }
}