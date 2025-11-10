import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const CuentoApp());
}

class CuentoApp extends StatelessWidget {
  const CuentoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Generador de Cuentos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const CuentoScreen(),
    );
  }
}

class CuentoScreen extends StatefulWidget {
  const CuentoScreen({super.key});

  @override
  State<CuentoScreen> createState() => _CuentoScreenState();
}

class _CuentoScreenState extends State<CuentoScreen> {
  final _personajesController = TextEditingController();
  final _lugarController = TextEditingController();
  String _palabras = '100';
  bool _conMoraleja = false;
  String _cuento = '';
  bool _isLoading = false;

  Future<void> _generarCuento() async {
    final apiKey = dotenv.env['OPENROUTER_API_KEY'];
    if (apiKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API Key de OpenRouter no encontrada en .env')),
      );
      return;
    }

    final prompt = StringBuffer()
      ..write(
          "Escribe un cuento de $_palabras palabras que contenga los siguientes personajes: ${_personajesController.text}, ")
      ..write("que se desarrolle en ${_lugarController.text}");
    if (_conMoraleja) prompt.write(" y tenga una moraleja.");

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("https://openrouter.ai/api/v1/chat/completions"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
          "HTTP-Referer": "https://example.com",
          "X-Title": "Generador de Cuentos",
        },
        body: jsonEncode({
          "model": "deepseek/deepseek-chat-v3.1:free",
          "messages": [
            {"role": "user", "content": prompt.toString()}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _cuento = data["choices"][0]["message"]["content"];
        });
      } else {
        setState(() {
          _cuento = "Error al generar el cuento: ${response.body}";
          print(response.body);
        });
      }
    } catch (e) {
      setState(() {
        _cuento = "Erroooor: $e";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Generador de Cuentos Cortos")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _personajesController,
              decoration: const InputDecoration(
                labelText: 'Personajes',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _lugarController,
              decoration: const InputDecoration(
                labelText: 'Lugar del cuento',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text("Cantidad de palabras: "),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _palabras,
                  items: const [
                    DropdownMenuItem(value: "100", child: Text("100")),
                    DropdownMenuItem(value: "250", child: Text("250")),
                    DropdownMenuItem(value: "500", child: Text("500")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _palabras = value!;
                    });
                  },
                ),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: _conMoraleja,
                  onChanged: (v) => setState(() => _conMoraleja = v!),
                ),
                const Text("Incluir moraleja"),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _generarCuento,
              icon: const Icon(Icons.auto_stories),
              label: const Text("Generar cuento"),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_cuento.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.teal.shade50,
                ),
                child: Text(
                  _cuento,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
