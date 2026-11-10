import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());
  runApp(const MaterialApp(home: RadioApp(), debugShowCheckedModeBanner: false));
}

class Station {
  final String name;
  final String country;
  final String url;
  Station({required this.name, required this.country, required this.url});
}

class RadioApp extends StatefulWidget {
  const RadioApp({super.key});
  @override
  State<RadioApp> createState() => _RadioAppState();
}

class _RadioAppState extends State<RadioApp> {
  final AudioPlayer _player = AudioPlayer();
  String? _currentStation;
  bool _isPlaying = false;
  bool _isShuffle = false;
  bool _isLoading = false;

  final List<Station> _stations = [
    // --- AZƏRBAYCAN (RƏSMİ FM) ---
    Station(name: "106.3 FM (Bakı)", country: "AZ", url: "http://stream.aztv.az:8000/1063fm"),
    Station(name: "İctimai FM (90.0)", country: "AZ", url: "https://streaming.ictimaifm.az/ictimaifm"),
    Station(name: "ASAN Radio (100.0)", country: "AZ", url: "https://asanradio.az:8000/stream"),
    Station(name: "Azərbaycan Radiosu (105.0)", country: "AZ", url: "http://stream.aztv.az:8000/radio"),
    Station(name: "Media FM (105.5)", country: "AZ", url: "http://stream.mediafm.az:8000/mediafm"),
    Station(name: "Avto FM (107.7)", country: "AZ", url: "http://stream.autofm.az:8000/autofm"),
    Station(name: "Araz FM (103.3)", country: "AZ", url: "https://stream.zeno.fm/549w7v5v9tzuv"),
    Station(name: "Radio Space (104.0)", country: "AZ", url: "http://stream.spacefm.az:8000/spacefm"),
    Station(name: "Radio Antenn (101.0)", country: "AZ", url: "http://stream.antenn.az:8000/antenn"),
    Station(name: "Radio TMB (100.5)", country: "AZ", url: "https://stream.zeno.fm/v904v2e8c2quv"),

    // --- TÜRKİYE & İZMİR ---
    Station(name: "Diyanet Kur'an Radyo", country: "TR", url: "https://diyanet.radyotvonline.net/kuranradyo/playlist.m3u8"),
    Station(name: "İzmir Radyo Trafik (102.5)", country: "TR", url: "https://stream.radyotrafik.com:8000/radyotrafikizmir"),
    Station(name: "Radyo 35 (İzmir 89.0)", country: "TR", url: "http://yayin.radyo35.com.tr:8035/"),
    Station(name: "TRT FM", country: "TR", url: "https://rad-trt-fm.radyotvonline.net/trtfm/playlist.m3u8"),
    Station(name: "TRT Radyo 1", country: "TR", url: "https://rad-trt-radyo-1.radyotvonline.net/trtradyo1/playlist.m3u8"),
    Station(name: "TRT Türkü", country: "TR", url: "https://rad-trt-turku.radyotvonline.net/trtturku/playlist.m3u8"),
    Station(name: "Power FM", country: "TR", url: "https://listen.powerapp.com.tr/powerfm/mpeg/icecast.audio"),
    Station(name: "Slow Türk", country: "TR", url: "https://radyo.duhnet.tv/slowturk"),
    Station(name: "Kral Pop", country: "TR", url: "https://dygstream.radyotvonline.net/kralpophls/playlist.m3u8"),
  ];

  Future<void> _play(Station station) async {
    try {
      if (_currentStation == station.name && _isPlaying) {
        await _player.pause();
        setState(() => _isPlaying = false);
        return;
      }
      setState(() {
        _currentStation = station.name;
        _isLoading = true;
      });
      await _player.setUrl(station.url);
      _player.play();
      setState(() {
        _isPlaying = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (_isShuffle) _playRandom();
    }
  }

  void _playRandom() {
    if (_stations.isEmpty) return;
    final randomStation = _stations[Random().nextInt(_stations.length)];
    _play(randomStation);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Net Radyo 📻", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.shuffle, color: _isShuffle ? Colors.cyanAccent : Colors.grey),
            tooltip: "Karışık Çal",
            onPressed: () {
              setState(() => _isShuffle = !_isShuffle);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_isShuffle ? "Shuffle Açık 🔀" : "Shuffle Kapalı"), duration: const Duration(seconds: 1)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.casino, color: Colors.amber),
            tooltip: "Rastgele İstasyon",
            onPressed: _playRandom,
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            tooltip: "İstasyon Ekle",
            onPressed: _showAddStationDialog,
          )
        ],
      ),
      body: ListView.builder(
        itemCount: _stations.length,
        itemBuilder: (ctx, i) {
          final s = _stations[i];
          final isCurrent = _currentStation == s.name;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isCurrent ? const Color(0xFF1E293B) : const Color(0xFF131D31),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isCurrent ? Colors.cyanAccent : Colors.transparent, width: 1.2),
            ),
            child: ListTile(
              leading: Text(s.country == "AZ" ? "🇦🇿" : "🇹🇷", style: const TextStyle(fontSize: 26)),
              title: Text(s.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              trailing: _isLoading && isCurrent
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.cyanAccent, strokeWidth: 2))
                  : Icon(
                      isCurrent && _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                      color: isCurrent ? Colors.cyanAccent : Colors.white60,
                      size: 34,
                    ),
              onTap: () => _play(s),
            ),
          );
        },
      ),
    );
  }

  void _showAddStationDialog() {
    final nameC = TextEditingController();
    final urlC = TextEditingController();
    String country = "TR";

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text("Yeni Radyo Ekle", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameC,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: "İstasyon Adı", labelStyle: TextStyle(color: Colors.grey)),
              ),
              TextField(
                controller: urlC,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: "Yayın URL'si", labelStyle: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(height: 15),
              DropdownButton<String>(
                value: country,
                dropdownColor: const Color(0xFF1E293B),
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: "TR", child: Text("🇹🇷 Türkiye", style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: "AZ", child: Text("🇦🇿 Azerbaycan", style: TextStyle(color: Colors.white))),
                ],
                onChanged: (val) => setDialogState(() => country = val!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("İptal")),
            ElevatedButton(
              onPressed: () {
                if (nameC.text.isNotEmpty && urlC.text.isNotEmpty) {
                  setState(() => _stations.insert(0, Station(name: nameC.text, country: country, url: urlC.text)));
                  Navigator.pop(ctx);
                }
              },
              child: const Text("Ekle"),
            )
          ],
        ),
      ),
    );
  }
}
