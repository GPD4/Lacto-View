import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../../milk_collection/model/model_collection.dart';

class PdfExportService {
  static final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final _dateOnlyFormat = DateFormat('dd/MM/yyyy');

  /// Gera e abre o diálogo de impressão/salvamento do PDF
  static Future<void> exportToPdf(List<MilkCollection> collections) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(context),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildSummary(collections),
          pw.SizedBox(height: 20),
          _buildCollectionsTable(collections),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'relatorio_coletas_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  /// Constrói o cabeçalho do PDF
  static pw.Widget _buildHeader(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'LactoView',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#2E7D32'),
                    ),
                  ),
                  pw.Text(
                    'Relatório de Coletas de Leite',
                    style: const pw.TextStyle(
                      fontSize: 14,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'Gerado em:',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.Text(
                    _dateFormat.format(DateTime.now()),
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Divider(color: PdfColor.fromHex('#2E7D32'), thickness: 2),
        ],
      ),
    );
  }

  /// Constrói o rodapé do PDF
  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'LactoView - Sistema de Gestão de Coletas',
            style: const pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey600,
            ),
          ),
          pw.Text(
            'Página ${context.pageNumber} de ${context.pagesCount}',
            style: const pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói o resumo das coletas
  static pw.Widget _buildSummary(List<MilkCollection> collections) {
    final totalVolume = collections.fold<double>(
      0,
      (sum, c) => sum + c.volumeLt,
    );
    final approvedCount = collections.where((c) => !c.rejection).length;
    final rejectedCount = collections.where((c) => c.rejection).length;
    final avgTemperature = collections.isNotEmpty
        ? collections.fold<double>(0, (sum, c) => sum + c.temperature) /
            collections.length
        : 0.0;
    final avgPh = collections.isNotEmpty
        ? collections.fold<double>(0, (sum, c) => sum + c.ph) /
            collections.length
        : 0.0;

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#E8F5E9'),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Resumo',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#2E7D32'),
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Total de Coletas', '${collections.length}'),
              _buildSummaryItem('Volume Total', '${totalVolume.toStringAsFixed(1)} L'),
              _buildSummaryItem('Aprovadas', '$approvedCount'),
              _buildSummaryItem('Rejeitadas', '$rejectedCount'),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Temp. Média', '${avgTemperature.toStringAsFixed(1)}°C'),
              _buildSummaryItem('pH Médio', avgPh.toStringAsFixed(2)),
              _buildSummaryItem('', ''),
              _buildSummaryItem('', ''),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryItem(String label, String value) {
    if (label.isEmpty) return pw.SizedBox();
    
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#1B5E20'),
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          label,
          style: const pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey700,
          ),
        ),
      ],
    );
  }

  /// Constrói a tabela de coletas
  static pw.Widget _buildCollectionsTable(List<MilkCollection> collections) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Detalhamento das Coletas',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey800,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(2), // Data
            1: const pw.FlexColumnWidth(2.5), // Produtor
            2: const pw.FlexColumnWidth(2.5), // Coletor
            3: const pw.FlexColumnWidth(1.2), // Volume
            4: const pw.FlexColumnWidth(1), // Temp
            5: const pw.FlexColumnWidth(0.8), // pH
            6: const pw.FlexColumnWidth(1.2), // Status
          },
          children: [
            // Cabeçalho
            pw.TableRow(
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#2E7D32'),
              ),
              children: [
                _buildTableHeader('Data'),
                _buildTableHeader('Produtor'),
                _buildTableHeader('Coletor'),
                _buildTableHeader('Volume'),
                _buildTableHeader('Temp.'),
                _buildTableHeader('pH'),
                _buildTableHeader('Status'),
              ],
            ),
            // Linhas de dados
            ...collections.asMap().entries.map((entry) {
              final index = entry.key;
              final collection = entry.value;
              final isEven = index % 2 == 0;
              
              return pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: isEven ? PdfColors.white : PdfColor.fromHex('#F5F5F5'),
                ),
                children: [
                  _buildTableCell(_dateOnlyFormat.format(collection.createdAt)),
                  _buildTableCell(collection.producerName),
                  _buildTableCell(collection.collectorName),
                  _buildTableCell('${collection.volumeLt.toStringAsFixed(1)} L'),
                  _buildTableCell('${collection.temperature.toStringAsFixed(1)}°C'),
                  _buildTableCell(collection.ph.toStringAsFixed(2)),
                  _buildStatusCell(collection.rejection),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTableHeader(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildTableCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 8),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildStatusCell(bool isRejected) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: pw.BoxDecoration(
          color: isRejected
              ? PdfColor.fromHex('#FFEBEE')
              : PdfColor.fromHex('#E8F5E9'),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Text(
          isRejected ? 'Rejeitada' : 'Aprovada',
          style: pw.TextStyle(
            fontSize: 7,
            fontWeight: pw.FontWeight.bold,
            color: isRejected
                ? PdfColor.fromHex('#C62828')
                : PdfColor.fromHex('#2E7D32'),
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }

  /// Exporta uma única coleta para PDF (detalhado)
  static Future<void> exportSingleCollectionToPdf(MilkCollection collection) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildSingleCollectionHeader(collection),
            pw.SizedBox(height: 24),
            _buildSingleCollectionDetails(collection),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'coleta_${collection.id ?? DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  static pw.Widget _buildSingleCollectionHeader(MilkCollection collection) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'LactoView',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#2E7D32'),
                  ),
                ),
                pw.Text(
                  'Comprovante de Coleta de Leite',
                  style: const pw.TextStyle(
                    fontSize: 16,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: pw.BoxDecoration(
                color: collection.rejection
                    ? PdfColor.fromHex('#FFEBEE')
                    : PdfColor.fromHex('#E8F5E9'),
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(
                  color: collection.rejection
                      ? PdfColor.fromHex('#C62828')
                      : PdfColor.fromHex('#2E7D32'),
                ),
              ),
              child: pw.Text(
                collection.rejection ? 'REJEITADA' : 'APROVADA',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: collection.rejection
                      ? PdfColor.fromHex('#C62828')
                      : PdfColor.fromHex('#2E7D32'),
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Divider(color: PdfColor.fromHex('#2E7D32'), thickness: 2),
      ],
    );
  }

  static pw.Widget _buildSingleCollectionDetails(MilkCollection collection) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // ID e Data
        _buildDetailSection('Informações Gerais', [
          _buildDetailRow('ID da Coleta', collection.id ?? 'N/A'),
          _buildDetailRow('Data/Hora', _dateFormat.format(collection.createdAt)),
          _buildDetailRow('Status', collection.status),
        ]),

        pw.SizedBox(height: 16),

        // Produtor
        _buildDetailSection('Dados do Produtor', [
          _buildDetailRow('Nome', collection.producerName),
          _buildDetailRow('Propriedade', collection.propertyName),
          _buildDetailRow('Presença do Produtor', collection.producerPresent ? 'Sim' : 'Não'),
        ]),

        pw.SizedBox(height: 16),

        // Coletor
        _buildDetailSection('Dados do Coletor', [
          _buildDetailRow('Nome', collection.collectorName),
        ]),

        pw.SizedBox(height: 16),

        // Dados da Coleta
        _buildDetailSection('Dados da Coleta', [
          _buildDetailRow('Volume', '${collection.volumeLt.toStringAsFixed(1)} Litros'),
          _buildDetailRow('Temperatura', '${collection.temperature.toStringAsFixed(1)} °C'),
          _buildDetailRow('pH', collection.ph.toStringAsFixed(2)),
          _buildDetailRow('Tanque', collection.numtanque),
          if (collection.sample)
            _buildDetailRow('Número do Tubo', collection.tubeNumber),
        ]),

        if (collection.observation.isNotEmpty) ...[
          pw.SizedBox(height: 16),
          _buildDetailSection('Observações', [
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(
                collection.observation,
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
          ]),
        ],

        if (collection.rejection && collection.rejectionReason.isNotEmpty) ...[
          pw.SizedBox(height: 16),
          _buildDetailSection('Motivo da Rejeição', [
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#FFEBEE'),
                borderRadius: pw.BorderRadius.circular(4),
                border: pw.Border.all(color: PdfColor.fromHex('#C62828')),
              ),
              child: pw.Text(
                collection.rejectionReason,
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColor.fromHex('#C62828'),
                ),
              ),
            ),
          ]),
        ],

        pw.SizedBox(height: 40),

        // Rodapé
        pw.Container(
          padding: const pw.EdgeInsets.only(top: 16),
          decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: PdfColors.grey400)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'LactoView - Sistema de Gestão de Coletas',
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                ),
              ),
              pw.Text(
                'Gerado em: ${_dateFormat.format(DateTime.now())}',
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildDetailSection(String title, List<pw.Widget> children) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#2E7D32'),
            borderRadius: const pw.BorderRadius.only(
              topLeft: pw.Radius.circular(4),
              topRight: pw.Radius.circular(4),
            ),
          ),
          child: pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
        ),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
            borderRadius: const pw.BorderRadius.only(
              bottomLeft: pw.Radius.circular(4),
              bottomRight: pw.Radius.circular(4),
              topRight: pw.Radius.circular(4),
            ),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 140,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}

