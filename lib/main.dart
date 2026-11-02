import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const AppCompromissos());
}

class AppCompromissos extends StatelessWidget {
  const AppCompromissos({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Compromissos',
      theme: _tema(),
      home: const TelaCompromissos(),
    );
  }
}

// Paleta e tipografia do portfólio (Caderno de Campo).
class Paleta {
  static const papel = Color(0xFFF1E8D7);
  static const papelAlto = Color(0xFFF7F0E2);
  static const papelFundo = Color(0xFFE4D9C3);
  static const tinta = Color(0xFF2B2318);
  static const tintaMedia = Color(0xFF5D5140);
  static const tintaFraca = Color(0xFF6F6350);
  static const linha = Color(0x242B2318);
  static const musgo = Color(0xFF4C6741);
  static const cochonilha = Color(0xFFA53A2B);
  static const ocre = Color(0xFFB4832A);
  static const ocreTinta = Color(0xFF8A6414);
}

TextStyle _titulo(
  double tamanho, {
  double peso = 560,
  Color cor = Paleta.tinta,
}) {
  return TextStyle(
    fontFamily: 'Fraunces',
    fontSize: tamanho,
    height: 1.12,
    color: cor,
    fontVariations: [
      FontVariation('wght', peso),
      FontVariation('opsz', tamanho.clamp(9, 144).toDouble()),
    ],
  );
}

TextStyle _texto(
  double tamanho, {
  double peso = 400,
  Color cor = Paleta.tinta,
}) {
  return TextStyle(
    fontFamily: 'Newsreader',
    fontSize: tamanho,
    height: 1.38,
    color: cor,
    fontVariations: [
      FontVariation('wght', peso),
      FontVariation('opsz', tamanho.clamp(6, 72).toDouble()),
    ],
  );
}

TextStyle _mono(
  double tamanho, {
  Color cor = Paleta.tintaFraca,
  bool medio = false,
  double espaco = 0.6,
}) {
  return TextStyle(
    fontFamily: 'PlexMono',
    fontSize: tamanho,
    height: 1.3,
    color: cor,
    letterSpacing: espaco,
    fontWeight: medio ? FontWeight.w500 : FontWeight.w400,
  );
}

ThemeData _tema() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Newsreader',
    scaffoldBackgroundColor: Paleta.papel,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Paleta.tinta,
      primary: Paleta.tinta,
      onPrimary: Paleta.papelAlto,
      surface: Paleta.papelAlto,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Paleta.tinta,
        foregroundColor: Paleta.papelAlto,
        disabledBackgroundColor: Paleta.papelFundo,
        disabledForegroundColor: Paleta.tintaFraca,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: _texto(16.5, peso: 600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Paleta.tinta),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Paleta.papelAlto,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

// ---------------------------------------------------------------------------
// Datas em português
// ---------------------------------------------------------------------------

const _diasDaSemana = [
  'segunda-feira',
  'terça-feira',
  'quarta-feira',
  'quinta-feira',
  'sexta-feira',
  'sábado',
  'domingo',
];
const _meses = [
  'janeiro',
  'fevereiro',
  'março',
  'abril',
  'maio',
  'junho',
  'julho',
  'agosto',
  'setembro',
  'outubro',
  'novembro',
  'dezembro',
];

String _doisDigitos(int valor) => valor.toString().padLeft(2, '0');

String _hora(DateTime data) =>
    '${_doisDigitos(data.hour)}:${_doisDigitos(data.minute)}';

// Ex.: "seg, 02/11"
String _dataCurta(DateTime data) =>
    '${_diasDaSemana[data.weekday - 1].substring(0, 3)}, '
    '${_doisDigitos(data.day)}/${_doisDigitos(data.month)}';

// Ex.: "2 nov"
String _diaEMes(DateTime data) =>
    '${data.day} ${_meses[data.month - 1].substring(0, 3)}';

DateTime _somenteData(DateTime data) =>
    DateTime(data.year, data.month, data.day);

bool _mesmoDia(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

// ---------------------------------------------------------------------------
// Compromisso: um evento já convertido para o horário do aparelho
// ---------------------------------------------------------------------------

class Compromisso {
  Compromisso(Event evento, Calendar calendario)
    : titulo = _semVazio(evento.title) ?? 'Sem título',
      nomeDoCalendario = _semVazio(calendario.name) ?? 'Calendário sem nome',
      corDoCalendario = calendario.color == null
          ? Paleta.ocre
          : Color(calendario.color!).withAlpha(255),
      diaInteiro = evento.allDay ?? false,
      local = _semVazio(evento.location),
      descricao = _textoLimpo(evento.description),
      inicio = _paraLocal(evento.start, evento.allDay ?? false),
      fim = _paraLocal(evento.end, evento.allDay ?? false);

  final String titulo;
  final String nomeDoCalendario;
  final Color corDoCalendario;
  final bool diaInteiro;
  final String? local;
  final String? descricao;

  // Horário local do aparelho. No dia inteiro, guarda só a data, e o fim
  // já é o último dia do evento (o plugin desconta o dia seguinte).
  final DateTime inicio;
  final DateTime fim;

  bool ocorreEntre(DateTime de, DateTime ate) {
    if (!inicio.isBefore(ate)) return false;
    if (diaInteiro) return !fim.isBefore(de);
    return !inicio.isBefore(de) || fim.isAfter(de);
  }

  String get faixaDeHorario {
    if (_mesmoDia(inicio, fim)) return '${_hora(inicio)} → ${_hora(fim)}';
    return '${_hora(inicio)} → ${_dataCurta(fim)} ${_hora(fim)}';
  }

  String get textoDoInicio => diaInteiro
      ? '${_dataCurta(inicio)} · dia inteiro'
      : '${_dataCurta(inicio)} · ${_hora(inicio)}';

  String get textoDoFim =>
      diaInteiro ? _dataCurta(fim) : '${_dataCurta(fim)} · ${_hora(fim)}';

  static DateTime _paraLocal(DateTime? data, bool diaInteiro) {
    if (data == null) return DateTime.now();
    // O evento chega no fuso em que foi criado; para o dia inteiro valem os
    // componentes da data, para o resto vale o instante no fuso do aparelho.
    if (diaInteiro) return DateTime(data.year, data.month, data.day);
    return DateTime.fromMillisecondsSinceEpoch(data.millisecondsSinceEpoch);
  }

  static String? _semVazio(String? texto) {
    final limpo = texto?.trim();
    return (limpo == null || limpo.isEmpty) ? null : limpo;
  }

  // Descrições vindas do Google Agenda podem trazer HTML.
  static String? _textoLimpo(String? texto) {
    if (texto == null) return null;
    final limpo = texto
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return _semVazio(limpo);
  }
}

class DiaDaAgenda {
  DiaDaAgenda(this.data);

  final DateTime data;
  final List<Compromisso> compromissos = [];
}

enum TipoAviso { info, sucesso, alerta, erro }

// ---------------------------------------------------------------------------
// Tela
// ---------------------------------------------------------------------------

class TelaCompromissos extends StatefulWidget {
  const TelaCompromissos({super.key});

  @override
  State<TelaCompromissos> createState() => _TelaCompromissosState();
}

class _TelaCompromissosState extends State<TelaCompromissos> {
  final DeviceCalendarPlugin _calendario = DeviceCalendarPlugin();

  List<DiaDaAgenda> _dias = [];

  bool _carregando = false;

  TipoAviso _tipoAviso = TipoAviso.info;
  String _mensagem = 'Pressione o botão para consultar os compromissos.';

  Future<void> _consultarCompromissos() async {
    if (_carregando) return;

    setState(() {
      _carregando = true;
      _dias = [];
      _tipoAviso = TipoAviso.info;
      _mensagem = 'Verificando acesso ao calendário...';
    });

    try {
      var permissao = await _calendario.hasPermissions();

      if (!mounted) return;

      if (permissao.isSuccess && permissao.data != true) {
        permissao = await _calendario.requestPermissions();
      }

      if (!mounted) return;

      if (!permissao.isSuccess) {
        throw Exception('Falha ao verificar a permissão.');
      }

      if (permissao.data != true) {
        setState(() {
          _tipoAviso = TipoAviso.alerta;
          _mensagem =
              'O acesso ao calendário não foi autorizado. Se o pedido não '
              'aparecer de novo, libere em Configurações › Apps › '
              'Compromissos › Permissões.';
        });

        return;
      }

      setState(() {
        _mensagem = 'Lendo os calendários do dispositivo...';
      });

      final calendarios = await _calendario.retrieveCalendars();

      if (!mounted) return;

      if (!calendarios.isSuccess || calendarios.data == null) {
        throw Exception('Falha ao listar os calendários.');
      }

      if (calendarios.data!.isEmpty) {
        setState(() {
          _tipoAviso = TipoAviso.info;
          _mensagem = 'Nenhum calendário encontrado no dispositivo.';
        });

        return;
      }

      final agora = DateTime.now();
      final hoje = DateTime(agora.year, agora.month, agora.day);
      final limite = DateTime(agora.year, agora.month, agora.day + 7);

      final compromissos = <Compromisso>[];
      var calendariosComFalha = 0;

      for (final calendario in calendarios.data!) {
        final eventos = await _calendario.retrieveEvents(
          calendario.id,
          RetrieveEventsParams(startDate: hoje, endDate: limite),
        );

        if (!mounted) return;

        if (!eventos.isSuccess || eventos.data == null) {
          calendariosComFalha++;
          continue;
        }

        for (final evento in eventos.data!) {
          final compromisso = Compromisso(evento, calendario);

          if (compromisso.ocorreEntre(hoje, limite)) {
            compromissos.add(compromisso);
          }
        }
      }

      if (calendariosComFalha == calendarios.data!.length) {
        throw Exception('Nenhum calendário pôde ser lido.');
      }

      compromissos.sort((a, b) {
        final porInicio = a.inicio.compareTo(b.inicio);
        if (porInicio != 0) return porInicio;
        if (a.diaInteiro != b.diaInteiro) return a.diaInteiro ? -1 : 1;
        return a.titulo.compareTo(b.titulo);
      });

      final dias = List.generate(
        7,
        (i) => DiaDaAgenda(DateTime(hoje.year, hoje.month, hoje.day + i)),
      );

      // Eventos que começaram antes de hoje e ainda continuam ficam em hoje.
      for (final compromisso in compromissos) {
        final dia = _somenteData(compromisso.inicio);
        final destino = dias.firstWhere(
          (d) => _mesmoDia(d.data, dia),
          orElse: () => dias.first,
        );
        destino.compromissos.add(compromisso);
      }

      final lidos = calendarios.data!.length - calendariosComFalha;

      setState(() {
        _dias = dias;

        if (compromissos.isEmpty) {
          _tipoAviso = TipoAviso.info;
          _mensagem =
              'Nenhum compromisso entre hoje e '
              '${_diaEMes(limite.subtract(const Duration(days: 1)))}.';
        } else {
          _tipoAviso = TipoAviso.sucesso;
          _mensagem =
              '${compromissos.length} compromisso(s) em '
              '$lidos calendário(s).';
        }

        if (calendariosComFalha > 0) {
          _tipoAviso = TipoAviso.alerta;
          _mensagem +=
              ' $calendariosComFalha calendário(s) não puderam ser lidos.';
        }
      });
    } catch (erro) {
      if (!mounted) return;

      setState(() {
        _tipoAviso = TipoAviso.erro;
        _mensagem = 'Não foi possível consultar os compromissos.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  void _mostrarCompromisso(Compromisso compromisso) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(compromisso.titulo, style: _titulo(22)),
          content: SingleChildScrollView(
            child: _Ficha(compromisso: compromisso, completa: true),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hoje = DateTime.now();
    final ultimoDia = DateTime(hoje.year, hoje.month, hoje.day + 6);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'AGENDA DE CAMPO',
                  style: _mono(
                    11,
                    cor: Paleta.cochonilha,
                    medio: true,
                    espaco: 2.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text('Compromissos', style: _titulo(36, peso: 600)),
                const SizedBox(height: 4),
                Text(
                  'Hoje e os próximos seis dias · '
                  '${_diaEMes(hoje)} a ${_diaEMes(ultimoDia)}',
                  style: _texto(15.5, cor: Paleta.tintaMedia),
                ),
                const SizedBox(height: 14),
                const _Pauta(),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _carregando ? null : _consultarCompromissos,
                  icon: const Icon(Icons.event_note_outlined, size: 20),
                  label: const Text('Consultar compromissos'),
                ),
                const SizedBox(height: 12),
                _Aviso(tipo: _tipoAviso, mensagem: _mensagem),
                if (_carregando)
                  const Padding(
                    padding: EdgeInsets.only(top: 56),
                    child: Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Paleta.tinta,
                        ),
                      ),
                    ),
                  )
                else if (_dias.isEmpty)
                  const _FolhaEmBranco()
                else
                  for (var i = 0; i < _dias.length; i++)
                    _SecaoDoDia(
                      dia: _dias[i],
                      ehHoje: i == 0,
                      aoTocar: _mostrarCompromisso,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Peças da interface
// ---------------------------------------------------------------------------

// Fio duplo de livro-caixa sob o cabeçalho.
class _Pauta extends StatelessWidget {
  const _Pauta();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 1.4, color: Paleta.tinta),
        const SizedBox(height: 2.5),
        Container(height: 1, color: Paleta.linha),
      ],
    );
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso({required this.tipo, required this.mensagem});

  final TipoAviso tipo;
  final String mensagem;

  @override
  Widget build(BuildContext context) {
    final (cor, icone) = switch (tipo) {
      TipoAviso.info => (Paleta.tintaFraca, Icons.info_outline),
      TipoAviso.sucesso => (Paleta.musgo, Icons.check_circle_outline),
      TipoAviso.alerta => (Paleta.ocre, Icons.lock_outline),
      TipoAviso.erro => (Paleta.cochonilha, Icons.error_outline),
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.09),
        border: Border(left: BorderSide(color: cor, width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icone, size: 18, color: cor),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(mensagem, style: _texto(14.5))),
        ],
      ),
    );
  }
}

class _FolhaEmBranco extends StatelessWidget {
  const _FolhaEmBranco();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 72, 20, 0),
      child: Column(
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 44,
            color: Paleta.tintaFraca.withValues(alpha: 0.55),
          ),
          const SizedBox(height: 12),
          Text(
            'Folha em branco',
            style: _titulo(21, peso: 500, cor: Paleta.tintaMedia),
          ),
          const SizedBox(height: 6),
          Text(
            'Os compromissos de hoje e dos próximos seis dias aparecem '
            'aqui, separados por dia.',
            textAlign: TextAlign.center,
            style: _texto(14.5, cor: Paleta.tintaFraca),
          ),
        ],
      ),
    );
  }
}

class _SecaoDoDia extends StatelessWidget {
  const _SecaoDoDia({
    required this.dia,
    required this.ehHoje,
    required this.aoTocar,
  });

  final DiaDaAgenda dia;
  final bool ehHoje;
  final void Function(Compromisso) aoTocar;

  @override
  Widget build(BuildContext context) {
    final data = dia.data;
    final quantidade = dia.compromissos.length;

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 54,
                child: Text(
                  _doisDigitos(data.day),
                  style: _titulo(
                    36,
                    peso: 500,
                    cor: ehHoje ? Paleta.cochonilha : Paleta.tinta,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _diasDaSemana[data.weekday - 1],
                          style: _texto(16.5, peso: 600),
                        ),
                        if (ehHoje) ...[
                          const SizedBox(width: 8),
                          const _SeloHoje(),
                        ],
                      ],
                    ),
                    Text('de ${_meses[data.month - 1]}', style: _mono(11.5)),
                  ],
                ),
              ),
              Text(
                quantidade == 0
                    ? 'livre'
                    : quantidade == 1
                    ? '1 item'
                    : '$quantidade itens',
                style: _mono(11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: Paleta.linha),
          if (dia.compromissos.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(54, 10, 0, 2),
              child: Text(
                'Nada marcado.',
                style: _texto(14.5, cor: Paleta.tintaFraca),
              ),
            )
          else
            for (final compromisso in dia.compromissos)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: _CartaoDoCompromisso(
                  compromisso: compromisso,
                  aoTocar: () => aoTocar(compromisso),
                ),
              ),
        ],
      ),
    );
  }
}

class _SeloHoje extends StatelessWidget {
  const _SeloHoje();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Paleta.cochonilha,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        'HOJE',
        style: _mono(9.5, cor: Paleta.papelAlto, medio: true, espaco: 1.6),
      ),
    );
  }
}

class _CartaoDoCompromisso extends StatelessWidget {
  const _CartaoDoCompromisso({
    required this.compromisso,
    required this.aoTocar,
  });

  final Compromisso compromisso;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final raio = BorderRadius.circular(8);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: raio,
        // Mesma sombra de papel do portfólio (--sombra-papel).
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A2B2318),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
          BoxShadow(
            color: Color(0x592B2318),
            blurRadius: 24,
            spreadRadius: -14,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Paleta.papelAlto,
        shape: RoundedRectangleBorder(
          borderRadius: raio,
          side: const BorderSide(color: Paleta.linha),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: aoTocar,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (compromisso.diaInteiro)
                      const _SeloDiaInteiro()
                    else
                      Text(
                        compromisso.faixaDeHorario,
                        style: _mono(13, cor: Paleta.tinta, medio: true),
                      ),
                    const SizedBox(height: 6),
                    Text(compromisso.titulo, style: _titulo(19)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: compromisso.corDoCalendario,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            compromisso.nomeDoCalendario,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _texto(14, cor: Paleta.tintaMedia),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(height: 1, color: Paleta.linha),
                    const SizedBox(height: 8),
                    _Ficha(compromisso: compromisso, completa: false),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 4,
                child: ColoredBox(color: compromisso.corDoCalendario),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeloDiaInteiro extends StatelessWidget {
  const _SeloDiaInteiro();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Paleta.ocre.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        'DIA INTEIRO',
        style: _mono(10, cor: Paleta.ocreTinta, medio: true, espaco: 1.4),
      ),
    );
  }
}

// Linhas de etiqueta, como numa ficha de coleta. No cartão a descrição é
// resumida; o diálogo mostra a ficha completa.
class _Ficha extends StatelessWidget {
  const _Ficha({required this.compromisso, required this.completa});

  final Compromisso compromisso;
  final bool completa;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (completa) ...[
          _LinhaDaFicha(rotulo: 'AGENDA', valor: compromisso.nomeDoCalendario),
          if (compromisso.diaInteiro)
            const _LinhaDaFicha(rotulo: 'TIPO', valor: 'Dia inteiro'),
        ],
        _LinhaDaFicha(rotulo: 'INÍCIO', valor: compromisso.textoDoInicio),
        _LinhaDaFicha(rotulo: 'FIM', valor: compromisso.textoDoFim),
        _LinhaDaFicha(
          rotulo: 'LOCAL',
          valor: compromisso.local ?? 'não informado',
          vazio: compromisso.local == null,
        ),
        _LinhaDaFicha(
          rotulo: 'NOTAS',
          valor: compromisso.descricao ?? 'sem descrição',
          vazio: compromisso.descricao == null,
          maxLinhas: completa ? null : 3,
        ),
      ],
    );
  }
}

class _LinhaDaFicha extends StatelessWidget {
  const _LinhaDaFicha({
    required this.rotulo,
    required this.valor,
    this.vazio = false,
    this.maxLinhas,
  });

  final String rotulo;
  final String valor;
  final bool vazio;
  final int? maxLinhas;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          SizedBox(
            width: 62,
            child: Text(rotulo, style: _mono(10, espaco: 1.4)),
          ),
          Expanded(
            child: Text(
              valor,
              maxLines: maxLinhas,
              overflow: maxLinhas == null ? null : TextOverflow.ellipsis,
              style: _texto(
                14.5,
                cor: vazio ? Paleta.tintaFraca : Paleta.tinta,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
