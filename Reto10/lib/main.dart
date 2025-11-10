import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const CovidApp());
}

class CovidApp extends StatelessWidget {
  const CovidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'COVID Colombia',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CovidHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CovidHomePage extends StatefulWidget {
  const CovidHomePage({super.key});

  @override
  State<CovidHomePage> createState() => _CovidHomePageState();
}

class _CovidHomePageState extends State<CovidHomePage> {
  String? departamento;
  bool fallecido = false;
  bool recuperado = false;
  String? sexo;
  String? rangoEdad;

  bool isLoading = false;
  List<dynamic> resultados = [];

  final List<String> departamentos = [
    'AMAZONAS',
    'ANTIOQUIA',
    'ARAUCA',
    'ATLANTICO',
    'BARRANQUILLA',
    'BOGOTA',
    'BOLIVAR',
    'BOYACA',
    'CALDAS',
    'CAQUETA',
    'CARTAGENA',
    'CASANARE',
    'CAUCA',
    'CESAR',
    'CHOCO',
    'CORDOBA',
    'CUNDINAMARCA',
    'GUAINIA',
    'GUAJIRA',
    'GUAVIARE',
    'HUILA',
    'MAGDALENA',
    'META',
    'NARIÑO',
    'NORTE SANTANDER',
    'PUTUMAYO',
    'QUINDIO',
    'RISARALDA',
    'SAN ANDRES',
    'SANTANDER',
    'STA MARTA D.E.',
    'SUCRE',
    'TOLIMA',
    'VALLE',
    'VAUPES',
    'VICHADA'
  ];

  final List<String> rangosEdad = [
    '1-20',
    '21-40',
    '41-60',
    '61-80',
    '81-100',
    '101-120',
  ];

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      resultados = [];
    });

    final baseUrl = 'https://www.datos.gov.co/resource/gt2j-8ykr.json';

    final Map<String, String> params = {};

    if (departamento != null) {
      params['departamento_nom'] = departamento!;
    }
    if (sexo != null) {
      params['sexo'] = sexo == 'Femenino' ? 'F' : 'M';
    }

    String whereClause = '';
    if (rangoEdad != null) {
      final partes = rangoEdad!.split('-');
      final min = partes[0];
      final max = partes[1];
      whereClause = 'edad >= $min AND edad <= $max';
    }

    if (fallecido) {
      whereClause += (whereClause.isNotEmpty ? ' AND ' : '') + 'fecha_muerte IS NOT NULL';
    } else if (recuperado) {
      whereClause += (whereClause.isNotEmpty ? ' AND ' : '') + 'fecha_recuperado IS NOT NULL';
    }

    if (whereClause.isNotEmpty) {
      params['\$where'] = whereClause;
    }

    params['\$limit'] = '200';

    final uri = Uri.parse(baseUrl).replace(queryParameters: params);

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          resultados = data;
        });
      } else {
        setState(() {
          resultados = [];
        });
      }
    } catch (e) {
      setState(() {
        resultados = [];
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  String getEtnia(String? code) {
    switch (code) {
      case '1':
        return 'Indígena';
      case '2':
        return 'ROM';
      case '3':
        return 'Raizal';
      case '4':
        return 'Palenquero';
      case '5':
        return 'Negro';
      case '6':
        return 'Otro';
      default:
        return 'No registrado';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Casos de COVID en Colombia')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Departamento',
                border: OutlineInputBorder(),
              ),
              value: departamento,
              items: departamentos
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (val) => setState(() => departamento = val),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Sexo',
                      border: OutlineInputBorder(),
                    ),
                    value: sexo,
                    items: ['Femenino', 'Masculino']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) => setState(() => sexo = val),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Edad',
                      border: OutlineInputBorder(),
                    ),
                    value: rangoEdad,
                    items: rangosEdad
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (val) => setState(() => rangoEdad = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Fallecido'),
                    value: fallecido,
                    onChanged: (val) {
                      setState(() {
                        fallecido = val!;
                        if (fallecido) recuperado = false;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Recuperado'),
                    value: recuperado,
                    onChanged: (val) {
                      setState(() {
                        recuperado = val!;
                        if (recuperado) fallecido = false;
                      });
                    },
                  ),
                ),
              ],
            ),

            ElevatedButton.icon(
              onPressed: fetchData,
              icon: const Icon(Icons.search),
              label: const Text('Buscar'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 20),

            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (resultados.isEmpty)
              const Text('No hay resultados')
            else
              ...resultados.map((item) {
                String fechaMuerte = item['fecha_muerte'] ?? 'No registrado';
                String fechaRecuperado = item['fecha_recuperado'] ?? 'No registrado';
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Departamento: ${item['departamento_nom'] ?? 'No registrado'}'),
                        Text('Ciudad: ${item['ciudad_municipio_nom'] ?? 'No registrado'}'),
                        Text('Reportado el: ${item['fecha_reporte_web'] ?? 'No registrado'}'),
                        Text('Sexo: ${item['sexo'] ?? 'No registrado'}'),
                        Text('Edad: ${item['edad'] ?? 'No registrado'}'),
                        Text('Fuente del contagio: ${item['fuente_tipo_contagio'] ?? 'No registrado'}'),
                        Text('Inicio de síntomas el: ${item['fecha_inicio_sintomas'] ?? 'No registrado'}'),
                        Text('Pertenencia étnica: ${getEtnia(item['per_etn_'])}'),
                        if (!recuperado) Text('Fallecido el: $fechaMuerte'),
                        if (!fallecido) Text('Recuperado el: $fechaRecuperado'),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
