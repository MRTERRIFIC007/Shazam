import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';

class WebHomePage extends StatefulWidget {
  @override
  _WebHomePageState createState() => _WebHomePageState();
}

class _WebHomePageState extends State<WebHomePage> {
  bool _isRecognizing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF042442),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Shazam Clone',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'The ACRCloud SDK is not supported on web platforms. This app can only identify songs on iOS, Android, and macOS.',
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 40),
            Text(
              'Tap to Simulate Shazam',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(height: 40),
            AvatarGlow(
              endRadius: 200.0,
              animate: _isRecognizing,
              child: GestureDetector(
                onTap: () => _toggleRecognizing(),
                child: Material(
                  shape: CircleBorder(),
                  elevation: 8,
                  child: Container(
                    padding: EdgeInsets.all(40),
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Color(0xFF089af8)),
                    child: Image.asset(
                      'assets/images/shazam-logo.png',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),
            if (_isRecognizing)
              Text(
                'This is a simulation only.\nOn mobile/desktop devices, the app would be listening for music.',
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  void _toggleRecognizing() {
    setState(() {
      _isRecognizing = !_isRecognizing;
    });

    if (_isRecognizing) {
      // Show a message after 3 seconds
      Future.delayed(Duration(seconds: 3), () {
        if (mounted && _isRecognizing) {
          _showMockResult();
        }
      });
    }
  }

  void _showMockResult() {
    setState(() {
      _isRecognizing = false;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Web Limitation'),
        content: Text(
          'In the full app on mobile devices, this would identify a real song using the microphone and the ACRCloud API.\n\n'
          'The web version is limited because browser security prevents direct microphone access in the way needed by the ACRCloud SDK.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
