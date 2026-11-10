import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'dart:math';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.sametli.radyo.channel.audio',
    androidNotificationChannelName: 'Radyo Calar',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
  );
  runApp(const MaterialApp(home: RadioApp(), debugShowCheckedModeBanner: false));
}

class Station {
  final String id;
  final String name;
  final String country;
  final String url;
  Station({required this.id, required this.name, required this.country, required this.url});
}

class RadioApp extends StatefulWidget {
  const RadioApp({super.key});
  @override
  State<RadioApp> createState() => _RadioAppState();
}

class _RadioAppState extends State<RadioApp> {
  final AudioPlayer _player = AudioPlayer();
  int _currentIndex = -1;
  bool _isPlaying = false;
  bool _isShuffle = false;
  bool _isLoading = false;

  final List<Station> _stations = [
    // --- AZƏRBAYCAN (RƏSMİ FM) ---
    Station(id: "1", name: "106.3 FM (Bakı)", country: "AZ", url: "http://stream.aztv.az:8000/1063fm"),
    Station(id: "2", name: "İctimai FM (90.0)", country: "AZ", url: "https://streaming.ictimaifm.az/ictimaifm"),
    Station(id: "3", name: "ASAN Radio (100.0)", country: "AZ", url: "https://asanradio.az:8000/stream"),
    Station(id: "4", name: "Azərbaycan Radiosu (105.0)", country: "AZ", url: "http://stream.aztv.az:8000/radio"),
    Station(id: "5", name: "Media FM (105.5)", country: "AZ", url: "http://stream.mediafm.az:8000/mediafm"),
    Station(id: "6", name: "Avto FM (107.7)", country: "AZ", url: "http://stream.autofm.az:8000/autofm"),
    Station(id: "7", name: "Araz FM (103.3)", country: "AZ", url: "https://stream.zeno.fm/549w7v5v9tzuv"),
    Station(id: "8", name: "Radio Space (104.0)", country: "AZ", url: "http://stream.spacefm.az:8000/spacefm"),
    Station(id: "9", name: "Radio Antenn (101.0)", country: "AZ", url: "http://stream.antenn.az:8000/antenn"),
    Station(id: "10", name: "Radio TMB (100.5)", country: "AZ", url: "https://stream.zeno.fm/v904v2e8c2quv"),

    // --- TÜRKİYE & İZMİR ---
    Station(id: "11", name: "Diyanet Kur'an Radyo", country: "TR", url: "https://diyanet.radyotvonline.net/kuranradyo/playlist.m3u8"),
    Station(id: "12", name: "İzmir Radyo Trafik (102.5)", country: "TR", url: "https://stream.radyotrafik.com:8000/radyotrafikizmir"),
    Station(id: "13", name: "Radyo 35 (İzmir 89.0)", country: "TR", url: "http://yayin.radyo35.com.tr:8035/"),
    Station(id: "14", name: "TRT FM", country: "TR", url: "https://rad-trt-fm.radyotvonline.net/trtfm/playlist.m3u8"),
    Station(id: "15", name: "TRT Radyo 1", country: "TR", url: "https://rad-trt-radyo-1.radyotvonline.net/trtradyo1/playlist.m3u8"),
    Station(id: "16", name: "TRT Türkü", country: "TR", url: "https://rad-trt-turku.radyotvonline.net/trtturku/playlist.m3u8"),
    Station(id: "17", name: "Power FM", country: "TR", url: "https://listen.powerapp.com.tr/powerfm/mpeg/icecast.audio"),
    Station(id: "18", name: "Slow Türk", country: "TR", url: "https://radyo.duhnet.tv/slowturk"),
    Station(id: "19", name: "Kral Pop", country: "TR", url: "https://dygstream.radyotvonline.net/kralpophls/playlist.m3u8"),
  ];

  @override
  void initState() {
    super.initState();
    _player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
    });
  }

  Future<void> _playIndex(int index) async {
    if (index < 0 || index >= _stations.length) return;
    final station = _stations[index];

    try {
      if (_currentIndex == index && _isPlaying) {
        await _player.pause();
        return;
      }

      setState(() {
        _currentIndex = index;
        _isLoading = true;
      });

      // Bildirim ekranı için MediaItem bilgisi
      final audioSource = AudioSource.uri(
        Uri.parse(station.url),
        tag: MediaItem(
          id: station.id,
          album: station.country == "AZ" ? "Azərbaycan Canlı Radio" : "Türkiye Canlı Radyo",
          title: station.name,
          artUri: Uri.parse(station.country == "AZ"
              ? "https://flagcdn.com/w320/az.png"
              : "https://flagcdn.com/w320/tr.png"),
        ),
      );

      await _player.setAudioSource(audioSource);
      _player.play();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (_isShuffle) _playNext();
    }
  }

  void _playNext() {
    if (_stations.isEmpty) return;
    if (_isShuffle) {
      _playIndex(Random().nextInt(_stations.length));
    } else {
      _playIndex((_currentIndex + 1) % _stations.length);
    }
  }

  void _playPrev() {
    if (_stations.isEmpty) return;
    if (_isShuffle) {
      _playIndex(Random().nextInt(_stations.length));
    } else {
      _playIndex((_currentIndex - 1 + _stations.length) % _stations.length);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentIndex != -1 ? _stations[_currentIndex] : null;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Net Radyo 📻", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.shuffle, color: _isShuffle ? Colors.cyanAccent : Colors.grey),
            tooltip: "Karışık Çalma Modu",
            onPressed: () {
              setState(() => _isShuffle = !_isShuffle);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_isShuffle ? "Shuffle Açık 🔀" : "Shuffle Kapalı"), duration: const Duration(seconds: 1)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.casino, color: Colors.amber),
            tooltip: "Rastgele Aç",
            onPressed: () => _playIndex(Random().nextInt(_stations.length)),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _stations.length,
        itemBuilder: (ctx, i) {
          final s = _stations[i];
          final isCurrent = _currentIndex == i;
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
              onTap: () => _playIndex(i),
            ),
          );
        },
      ),
      bottomNavigationBar: current != null
          ? Container(
              color: const Color(0xFF1E293B),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(current.country == "AZ" ? "🇦🇿" : "🇹🇷", style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      current.name,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_previous, color: Colors.white),
                    onPressed: _playPrev,
                  ),
                  IconButton(
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.cyanAccent, size: 30),
                    onPressed: () => _playIndex(_currentIndex),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next, color: Colors.white),
                    onPressed: _playNext,
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
