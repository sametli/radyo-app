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
  int _currentIndex = -1;
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
    Station(name: "Slow Türk
