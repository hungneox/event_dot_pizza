import 'package:event_dot_pizza/src/state/meetupPlatformSession.dart';
import 'package:event_dot_pizza/src/platforms/meetupPlatformApi.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';

class MeetupAuthPage extends StatefulWidget {
  @override
  _MeetupAuthPageState createState() => _MeetupAuthPageState();
}

class _MeetupAuthPageState extends State<MeetupAuthPage> {
  bool _loading = true;

  Map<String, String> parseRedirectParams(String url) {
    Map<String, String> paramsMap = Map();
    if (url.startsWith(MeetupPlatformApi.REDIRECT_URI)) {
      String query = url.split('#')[1];
      List<String> params = query.split('&');
      for (String params in params) {
        List<String> pair = params.split('=');
        paramsMap[pair[0]] = pair[1];
      }
    }
    return paramsMap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connect Meetup.Com'),
      ),
      body: SafeArea(
          child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Opacity(
            opacity: _loading ? 0 : 1,
            child: WebView(
              initialUrl: MeetupPlatformApi.authURI,
              javascriptMode: JavascriptMode.unrestricted,
              onPageFinished: (String url) {
                setState(() {
                  _loading = false;
                });
              },
              navigationDelegate: (NavigationRequest request) {
                print(request.url);
                Map<String, String> params = parseRedirectParams(request.url);
                if (params.containsKey('error')) {
                  Navigator.pop(context);
                  return NavigationDecision.prevent;
                } else if (params.containsKey('access_token')) {
                  Provider.of<MeetupPlatformSession>(context).accessToken =
                      params['access_token'];
                  Navigator.pop(context);
                  return NavigationDecision.prevent;
                } else {
                  return NavigationDecision.navigate;
                }
              },
            ),
          ),
          Visibility(
            visible: _loading,
            child: CircularProgressIndicator(),
          )
        ],
      )),
    );
  }
}