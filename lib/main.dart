import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .envファイルからLINE CHANNEL IDを読み込んでLINE SDKを初期化する
  await dotenv.load(fileName: ".env");
  final channelId = dotenv.get('LINE_CHANNEL_ID');
  await LineSDK.instance.setup(channelId).then((_) {});

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    );

    return MaterialApp(
      title: 'LINE Login Demo',
      theme: theme,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.colorScheme.inversePrimary,
          title: const Text('LINE Login Demo'),
        ),
        body: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String _displayText = 'ログインしていません';

  Future<void> _signInWithSDK() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // LineSDK の login メソッドをコールする。
      final result = await LineSDK.instance.login();
      final userId = result.userProfile?.userId;
      final displayName = result.userProfile?.displayName;

      setState(() {
        _displayText = 'userId: $userId\ndisplayName: $displayName';
      });
    } finally {
      setState(() {
        _isLoading = false;
        _isLoggedIn = true;
      });
    }
  }

  Future<void> _signOutWithSDK() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await LineSDK.instance.logout();
      setState(() {
        _displayText = 'ログインしていません';
      });
    } on PlatformException catch (e) {
      debugPrint(e.message);
    } finally {
      setState(() {
        _isLoading = false;
        _isLoggedIn = false;
      });
    }
  }

  List<Widget> _buttons() {
    return _isLoggedIn
        ? [
            ElevatedButton(
              onPressed: _isLoading ? null : _signOutWithSDK,
              child: const Text('Logout'),
            )
          ]
        : [
            ElevatedButton(
              onPressed: _isLoading ? null : _signInWithSDK,
              child: const Text('LINE Login with SDK'),
            )
          ];
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            _displayText,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          ..._buttons(),
        ],
      ),
    );
  }
}
