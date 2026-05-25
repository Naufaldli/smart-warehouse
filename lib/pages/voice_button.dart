import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../providers/inventory_provider.dart';

class VoiceButton extends StatefulWidget {
  const VoiceButton({super.key});

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _buttonText = "Bicara untuk Update Stok";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  // Mengontrol alur perekaman suara dan pemrosesan perintah NLP
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'notListening' || status == 'done') {
            setState(() {
              _isListening = false;
              _buttonText = "Bicara untuk Update Stok";
            });
          }
        },
        onError: (val) => debugPrint('Error speech: $val'),
      );

      if (available) {
        setState(() {
          _isListening = true;
          _buttonText = "Mendengarkan... Sebutkan perintah";
        });

        _speech.listen(
          onResult: (val) async {
            if (val.finalResult) {
              String hasilTeks = val.recognizedWords;
              
              // Validasi keberadaan konteks widget sebelum interaksi UI
              if (!mounted) return; 

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Didengar: "$hasilTeks"')),
              );

              // Eksekusi pemrosesan teks ke provider inventaris
              String balasanStatus = await context.read<InventoryProvider>().prosesPerintahSuara(hasilTeks);

              // Validasi ulang state setelah operasi asinkronus selesai
              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(balasanStatus),
                  backgroundColor: balasanStatus.startsWith('Berhasil') ? Colors.green : Colors.red,
                ),
              );
            }
          },
        );
      }
    } else {
      setState(() {
        _isListening = false;
        _buttonText = "Bicara untuk Update Stok";
      });
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: ElevatedButton.icon(
        onPressed: _listen,
        icon: Icon(
          _isListening ? Icons.mic : Icons.mic_none, 
          color: Colors.white
        ),
        label: Text(
          _buttonText, 
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isListening ? Colors.red.shade700 : Colors.orange,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: _isListening ? 8 : 2,
        ),
      ),
    );
  }
}