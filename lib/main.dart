import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersive,
  );

  runApp(
    const MaterialApp(
      home: MyWebsite(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class MyWebsite extends StatefulWidget {
  const MyWebsite({Key? key}) : super(key: key);

  @override
  State<MyWebsite> createState() => _MyWebsiteState();
}

class _MyWebsiteState extends State<MyWebsite> {
  double _progress = 0;
  late InAppWebViewController inAppWebViewController;
  bool _isSidebarOpen = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var isLastPage = await inAppWebViewController.canGoBack();

        if (isLastPage) {
          inAppWebViewController.goBack();
          return false;
        }

        return true;
      },
      child: SafeArea(
        child: GestureDetector(
          onHorizontalDragUpdate: (details) {
            if (details.primaryDelta! > 20) {
              setState(() {
                _isSidebarOpen = true;
              });
            } else if (details.primaryDelta! < -20) {
              setState(() {
                _isSidebarOpen = false;
              });
            }
          },
          child: Stack(
            children: [
              InAppWebView(
                initialUrlRequest: URLRequest(
                  url: Uri.parse(
                      "https://provincehospitalbhadrapur.btownitsolution.com.np"),
                ),
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    // Enable JavaScript and autoplay
                    javaScriptEnabled: true,
                    mediaPlaybackRequiresUserGesture: false,
                    cacheEnabled: true,
                  ),
                ),
                onWebViewCreated: (InAppWebViewController controller) {
                  inAppWebViewController = controller;
                },
                onProgressChanged:
                    (InAppWebViewController controller, int progress) {
                  setState(() {
                    _progress = progress / 100;
                  });
                },
                onReceivedServerTrustAuthRequest:
                    (InAppWebViewController controller,
                        URLAuthenticationChallenge challenge) async {
                  return ServerTrustAuthResponse(
                    action: ServerTrustAuthResponseAction.PROCEED,
                  );
                },
              ),
              if (_isSidebarOpen)
                Container(
                  width: 200, // Adjust the width of the sidebar as needed
                  color: Colors.orange,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff051b30),
                        ),
                        onPressed: () {
                          inAppWebViewController.reload();
                          setState(() {
                            _isSidebarOpen = false;
                          });
                        },
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                ),
              if (_progress < 1)
                LinearProgressIndicator(
                  value: _progress,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
