// lib/pages/report_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import '../db/database_helper.dart';
import '../models/transacao_model.dart';
import '../main.dart';
import 'relatorios_salvos_page.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  List<Transacao> _transacoes = [];
  double _totalGeral = 0, _totalAvista = 0, _totalFiado = 0, _totalGastos = 0;
  final _formatter = NumberFormat.simpleCurrency(locale: 'pt_BR');
  final _dateFmt = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final todas = await DatabaseHelper.instance.listarTransacoes();
    final av = todas.where((t) => t.tipo == 'À vista').fold(0.0, (s, t) => s + t.valor);
    final fi = todas.where((t) => t.tipo == 'Fiado').fold(0.0, (s, t) => s + t.valor);
    final ga = todas.where((t) => t.tipo == 'Gastos').fold(0.0, (s, t) => s + t.valor);
    setState(() {
      _transacoes = todas;
      _totalAvista = av;
      _totalFiado = fi;
      _totalGastos = ga;
      _totalGeral = av + fi - ga;
    });
  }

  Future<void> _exportPDF() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        header: (_) => pw.Center(
          child: pw.Text(
            'Relatório de Vendas',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
        ),
        build: (context) => [
          // Tabela com data, descrição e valor
          pw.Table.fromTextArray(
            headers: ['Data', 'Descrição', 'Valor'],
            data: _transacoes.map((t) {
              final date = _dateFmt.format(DateTime.parse(t.data));
              return [date, t.descricao, _formatter.format(t.valor)];
            }).toList(),
            headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
            headerDecoration: pw.BoxDecoration(color: PdfColors.blueGrey),
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: pw.EdgeInsets.all(6),
          ),
          pw.SizedBox(height: 20),
          // Totais resumidos
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total Geral:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Text(_formatter.format(_totalGeral), style: pw.TextStyle(fontSize: 16, color: PdfColors.green900)),
            ],
          ),
        ],
        footer: (_) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Gerado em ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
          ),
        ),
      ),
    );

    // Salvar arquivo direto na pasta interna do app
    final dir = await getApplicationDocumentsDirectory();
    final relDir = Directory('${dir.path}/relatorios');
    if (!await relDir.exists()) await relDir.create(recursive: true);
    final filePath = '${relDir.path}/relatorio_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // Notificar e ir para aba Salvos
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF salvo em: \$filePath')),
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RelatoriosSalvosPage()),
    );
  }

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente apagar todas as transações?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Não')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sim')),
        ],
      ),
    );
    if (ok == true) {
      for (final t in _transacoes) {
        await DatabaseHelper.instance.excluirTransacao(t.id!);
      }
      setState(() {
        _transacoes.clear();
        _totalGeral = _totalAvista = _totalFiado = _totalGastos = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const cAmarelo = Colors.amber;
    const cVermelho = Colors.red;
    final cTotalGeral = Colors.green.shade700;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryCiano,
        title: Text(
          'Relatório',
          style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary),
        ),
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Sobre o Projeto'),
                  content: SingleChildScrollView(
                    child: Text(
                      'Este aplicativo foi desenvolvido para facilitar a gestão financeira, '
                      'permitindo registrar vendas à vista, fiado e controlar gastos. '
                      'Ele utiliza reconhecimento de voz, SQLite para armazenamento local, '
                      'gera relatórios em PDF e CSV.\n'
                      'Principal criador: Welington Matheus A. de Souza\n'
                      'Menções aos demais colaboradores do grupo 4 do talento tech - Imbaú-PR',
                    ),
                  ),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar'))],
                ),
              );
            },
          ),
          IconButton(icon: const Icon(Icons.picture_as_pdf), onPressed: _exportPDF),
          IconButton(icon: const Icon(Icons.delete_forever), onPressed: _confirmClear),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: theme.cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildResumoLinha('Total Geral', _totalGeral, cTotalGeral),
                    const SizedBox(height: 8),
                    _buildResumoLinha('À Vista', _totalAvista, kPrimaryCiano),
                    const SizedBox(height: 8),
                    _buildResumoLinha('Fiado', _totalFiado, cAmarelo),
                    const SizedBox(height: 8),
                    _buildResumoLinha('Gastos', _totalGastos, cVermelho),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      value: _totalAvista,
                      color: kPrimaryCiano,
                      title: 'À Vista',
                      titleStyle: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                    PieChartSectionData(
                      value: _totalFiado,
                      color: cAmarelo,
                      title: 'Fiado',
                      titleStyle: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                    PieChartSectionData(
                      value: _totalGastos,
                      color: cVermelho,
                      title: 'Gastos',
                      titleStyle: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumoLinha(String label, double valor, Color cor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: cor, fontSize: 16)),
        Text(
          _formatter.format(valor),
          style: TextStyle(color: cor, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
