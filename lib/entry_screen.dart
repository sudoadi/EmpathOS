import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  String _currentVersion = "";
  String _updateStatus = "";
  bool _checkingUpdate = false;
  bool _downloadingUpdate = false;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _initVersionAndCheckForUpdate();
  }

  Future<void> _initVersionAndCheckForUpdate() async {
    // Get the current version using package_info_plus.
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _currentVersion = packageInfo.version;
    });
    await _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    setState(() {
      _checkingUpdate = true;
      _updateStatus = "Checking for updates...";
    });
    try {
      // Replace <owner> and <repo> with your GitHub repository details.
      final url = 'https://api.github.com/repos/sudoadi/empathos/releases/latest';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final release = json.decode(response.body);
        String latestVersion = release['tag_name'].toString();
        if (_isNewerVersion(latestVersion, _currentVersion)) {
          setState(() {
            _updateStatus =
            "New version $latestVersion available. Downloading update...";
          });
          if (release['assets'] != null && release['assets'].isNotEmpty) {
            String assetUrl = release['assets'][0]['browser_download_url'];
            await _downloadAndInstallUpdate(assetUrl);
          } else {
            setState(() {
              _updateStatus = "No downloadable asset found in release.";
            });
          }
        } else {
          setState(() {
            _updateStatus = "App is up to date.";
          });
        }
      } else {
        setState(() {
          _updateStatus = "Update check failed: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _updateStatus = "Error checking update: $e";
      });
    } finally {
      setState(() {
        _checkingUpdate = false;
      });
    }
  }

  // Compare version strings assuming the format x.y.z.
  bool _isNewerVersion(String latest, String current) {
    List<int> latestParts =
    latest.replaceAll("v", "").split('.').map(int.parse).toList();
    List<int> currentParts =
    current.replaceAll("v", "").split('.').map(int.parse).toList();
    for (int i = 0; i < latestParts.length; i++) {
      if (i >= currentParts.length || latestParts[i] > currentParts[i]) {
        return true;
      } else if (latestParts[i] < currentParts[i]) {
        return false;
      }
    }
    return false;
  }

  Future<void> _downloadAndInstallUpdate(String url) async {
    setState(() {
      _downloadingUpdate = true;
      _downloadProgress = 0.0;
    });
    Dio dio = Dio();
    try {
      Directory tempDir = await getTemporaryDirectory();
      String filePath = "${tempDir.path}/update.apk";
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );
      setState(() {
        _updateStatus = "Download complete. Installing update...";
      });
      // Launch the APK installer (ensure installation from unknown sources is allowed on Android).
      await OpenFile.open(filePath);
    } catch (e) {
      setState(() {
        _updateStatus = "Error during update download: $e";
      });
    } finally {
      setState(() {
        _downloadingUpdate = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.self_improvement, size: 80, color: Color(0xFF00695C)),
            const SizedBox(height: 20),
            const Text(
              "🌿EmpathOS",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF004D40),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Your Mental Wellbeing Companion",
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            // Display current version.
            Text(
              "Version: $_currentVersion",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            // Display update status or progress.
            if (_checkingUpdate)
              const CircularProgressIndicator()
            else if (_downloadingUpdate)
              Column(
                children: [
                  const Text("Downloading update...", style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(value: _downloadProgress),
                  const SizedBox(height: 4),
                  Text("${(_downloadProgress * 100).toStringAsFixed(0)}%", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              )
            else
              Text(
                _updateStatus,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            const Spacer(),
            buildPrimaryButton(context, "Login", "/login"),
            const SizedBox(height: 12),
            buildOutlinedButton(context, "Sign Up", "/signup"),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/facecam');
              },
              child: const Text("Continue as Guest", style: TextStyle(color: Colors.teal, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/forgot'),
              child: const Text("Forgot Password?", style: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/help'),
              child: const Text("Need Help?", style: TextStyle(color: Colors.grey)),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget buildPrimaryButton(BuildContext context, String label, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, route),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF004D40),
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget buildOutlinedButton(BuildContext context, String label, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: OutlinedButton(
        onPressed: () => Navigator.pushNamed(context, route),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF004D40),
          minimumSize: const Size.fromHeight(50),
          side: const BorderSide(color: Color(0xFF004D40)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
