// lib/pages/gastos_page.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../main.dart';
import '../db/database_helper.dart';
import '../models/transacao_model.dart';

class GastosPage extends StatefulWidget {
  const GastosPage({super.key});

  @override
  State<GastosPage> createState() => _GastosPageState();
}

class _GastosPageState extends State<GastosPage> {
  List<Transacao> _gastos = [];

  @override
  void initState() {
    super.initState();
    _carregarGastos();
  }

  Future<void> _carregarGastos() async {
    final todas = await DatabaseHelper.instance.listarTransacoes(tipo: 'Gastos');
    setState(() => _gastos = todas);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalGastos = _gastos.fold(0.0, (sum, item) => sum + item.valor);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryCiano,
        title: Text(
          'Relatório de Gastos',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 4,
      ),
      body: Column(
        children: [
          Card(
            color: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(
                        value: totalGastos,
                        title: 'Gastos',
                        color: Colors.red.shade400,
                        titleStyle: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onBackground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _gastos.length,
              itemBuilder: (context, index) {
                final gasto = _gastos[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    leading: const Icon(
                      Icons.shopping_cart,
                      color: Colors.red,
                    ),
                    title: Text(gasto.descricao),
                    subtitle: Text(
                      'R\$ ${gasto.valor.toStringAsFixed(2)}',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
