// lib/pages/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../main.dart';
import '../db/database_helper.dart';
import 'list_page.dart';
import 'report_page.dart';
import 'relatorios_salvos_page.dart';
import 'calculator_page.dart';


class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Toque para falar';
  String _tipoSelecionado = 'À vista';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _verificarPermissaoMicrofone();
  }

  Future<void> _verificarPermissaoMicrofone() async {
    final disponivel = await _speech.initialize();
    if (!disponivel) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permissão de microfone não concedida')),
      );
    }
  }

  Future<void> _listen() async {
    if (!_isListening) {
      final available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() => _text = val.recognizedWords),
        );
      }
    } else {
      _speech.stop();
      setState(() => _isListening = false);
      if (_text.isNotEmpty && _text != 'Toque para falar') {
        await DatabaseHelper.instance.inserirVenda(_text, _tipoSelecionado);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Venda registrada com sucesso!')),
        );
      }
    }
  }

  Future<void> _editText() async {
    final controller = TextEditingController(text: _text);
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar texto reconhecido'),
        content: TextField(
          controller: controller,
          maxLines: null,
          decoration: const InputDecoration(hintText: 'Digite o texto...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _text = controller.text);
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _clearText() => setState(() => _text = '');

  void _abrirRelatorio() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReportPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cCiano = isDark
        ? Colors.grey[400]!
        : const Color(0xFF3EB9A6);
    final headerColor = isDark ? Colors.white : theme.colorScheme.onPrimary;
    final editIconColor = isDark ? Colors.amber : cCiano;
    final secondary = theme.colorScheme.secondary;
    final iconColor = theme.iconTheme.color;

    final micButtonColor =
        _isListening ? Colors.red : (isDark ? Colors.grey[600]! : secondary);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: cCiano,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        elevation: 0,
        centerTitle: false,
        titleSpacing: 16,
        title: Text(
          'GestãoFacil',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
        actions: [
          IconButton(
            icon: Icon(
                isDark ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined),
            color: headerColor,
            onPressed: () {
              themeNotifier.value = themeNotifier.value == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
            },
          ),
          IconButton(
            icon: const Icon(Icons.list_alt),
            color: headerColor,
            tooltip: 'Ver transações',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ListPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart),
            color: headerColor,
            tooltip: 'Relatório',
            onPressed: _abrirRelatorio,
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Relatórios Salvos',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RelatoriosSalvosPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Filtro de tipo no topo
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => _tipoSelecionado = 'À vista'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _tipoSelecionado == 'À vista'
                        ? Colors.green
                        : Colors.green.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: _tipoSelecionado == 'À vista' ? 4 : 0,
                  ),
                  child: Text(
                    'À VISTA',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => setState(() => _tipoSelecionado = 'Fiado'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _tipoSelecionado == 'Fiado'
                        ? Colors.amber
                        : Colors.amber.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: _tipoSelecionado == 'Fiado' ? 4 : 0,
                  ),
                  child: Text(
                    'FIADO',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Caixa de texto reconhecido
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      _text,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        color: editIconColor,
                        onPressed: _editText,
                        tooltip: 'Editar texto',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        color: Colors.red,
                        onPressed: _clearText,
                        tooltip: 'Apagar texto',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Botão de microfone
            GestureDetector(
              onTap: _listen,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: micButtonColor,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 12)
                  ],
                ),
                child: Icon(
                  _isListening ? Icons.stop : Icons.mic,
                  size: 96,
                  color: iconColor,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // BOTÃO GASTOS ABAIXO DO MICROFONE
            ElevatedButton(
              onPressed: () => setState(() => _tipoSelecionado = 'Gastos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _tipoSelecionado == 'Gastos'
                    ? Colors.red
                    : Colors.red.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: _tipoSelecionado == 'Gastos' ? 4 : 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text(
                'GASTOS',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const CalculatorPage()),
  ),
  child: const Icon(Icons.calculate),
),
floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,

    );
  }
}
