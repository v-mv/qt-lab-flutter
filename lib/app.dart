import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'quantum.dart';

class QuantumWaveLab extends StatelessWidget {
  const QuantumWaveLab({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF006A6A);
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        ColorScheme light;
        ColorScheme dark;

        if (lightDynamic != null && darkDynamic != null) {
          light = lightDynamic.harmonized();
          dark = darkDynamic.harmonized();
        } else {
          light = ColorScheme.fromSeed(
            seedColor: seed,
            brightness: Brightness.light,
          );
          dark = ColorScheme.fromSeed(
            seedColor: seed,
            brightness: Brightness.dark,
          );
        }

        return MaterialApp(
          title: 'QT Lab',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.system,
          theme: _theme(light),
          darkTheme: _theme(dark),
          home: const QuantumShell(),
        );
      },
    );
  }
}

ThemeData _theme(ColorScheme colors) => ThemeData(
  useMaterial3: true,
  colorScheme: colors,
  scaffoldBackgroundColor: colors.surface,
  cardTheme: CardThemeData(
    elevation: 0,
    color: colors.surfaceContainerLow,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
  ),
  navigationBarTheme: NavigationBarThemeData(
    height: 76,
    indicatorColor: colors.secondaryContainer,
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  ),
);

class QuantumShell extends StatefulWidget {
  const QuantumShell({super.key});

  @override
  State<QuantumShell> createState() => _QuantumShellState();
}

class _QuantumShellState extends State<QuantumShell> {
  final controller = QuantumController();
  Timer? timer;
  int page = 0;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
      const Duration(milliseconds: 35),
      (_) => controller.tick(),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        body: SafeArea(
          top: true,
          bottom: false,
          child: AnimatedBuilder(
            animation: controller,
            builder: (_, _) {
              final pages = <Widget>[
                ExplorePage(
                  controller: controller,
                  onOpenLibrary: () => setState(() => page = 1),
                ),
                LibraryPage(
                  controller: controller,
                  onLoad: () => setState(() => page = 0),
                ),
                StatesPage(
                  controller: controller,
                  onApply: () => setState(() => page = 0),
                ),
                LearnPage(controller: controller),
              ];
              return pages[page];
            },
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: page,
            onDestinationSelected: (value) => setState(() => page = value),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.auto_graph_outlined),
                selectedIcon: Icon(Icons.auto_graph),
                label: 'Explore',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book),
                label: 'Library',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_tree_outlined),
                selectedIcon: Icon(Icons.account_tree),
                label: 'States',
              ),
              NavigationDestination(
                icon: Icon(Icons.school_outlined),
                selectedIcon: Icon(Icons.school),
                label: 'Learn',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExplorePage extends StatelessWidget {
  const ExplorePage({
    super.key,
    required this.controller,
    required this.onOpenLibrary,
  });
  final QuantumController controller;
  final VoidCallback onOpenLibrary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final samples = controller.samples;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'QT LAB',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'Explore motion',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            IconButton.filledTonal(
              onPressed: () => _showControls(context, controller),
              icon: const Icon(Icons.tune),
              tooltip: 'Simulation controls',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.circle, size: 11, color: colors.tertiary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.potentialTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        _stateLabel(controller),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  't = ${controller.time.toStringAsFixed(2)}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        WaveChart(samples: samples),
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton.filledTonal(
              onPressed: controller.reset,
              icon: const Icon(Icons.restart_alt),
              tooltip: 'Reset simulation',
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  controller.togglePlayback();
                },
                icon: Icon(controller.playing ? Icons.pause : Icons.play_arrow),
                label: Text(
                  controller.playing ? 'Pause evolution' : 'Play evolution',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'OBSERVABLES',
          style: theme.textTheme.labelSmall?.copyWith(
            letterSpacing: 1.1,
            fontWeight: FontWeight.w800,
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            MetricTile(
              label: '⟨x⟩',
              value: _expectedX(samples).toStringAsFixed(2),
              suffix: 'a.u.',
              accent: colors.primary,
            ),
            MetricTile(
              label: '⟨p⟩',
              value: controller.config.k0.toStringAsFixed(2),
              suffix: 'ℏ / a.u.',
              accent: colors.secondary,
            ),
            MetricTile(
              label: 'Energy',
              value: eigenEnergy(
                controller.config,
                controller.activeN,
              ).toStringAsFixed(3),
              suffix: 'a.u.',
              accent: colors.tertiary,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          color: colors.secondaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NUMERICAL VS. ANALYTICAL',
                        style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 1,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Finite-difference reference',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${controller.numericalError.toStringAsFixed(3)}%',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colors.tertiary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onOpenLibrary,
          icon: const Icon(Icons.menu_book),
          label: const Text('Browse all wave-function cases'),
        ),
      ],
    );
  }
}

class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    required this.suffix,
    required this.accent,
  });
  final String label;
  final String value;
  final String suffix;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.sizeOf(context).width - 56) / 3,
      child: Card(
        child: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(width: 3, color: accent)),
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 11),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(suffix, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class WaveChart extends StatelessWidget {
  const WaveChart({super.key, required this.samples});
  final List<WaveSample> samples;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LIVE WAVE FUNCTION',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: 1,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 224,
              child: CustomPaint(
                painter: WavePainter(samples, Theme.of(context).colorScheme),
                child: const SizedBox.expand(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('x = −5', style: Theme.of(context).textTheme.labelSmall),
                Text('position', style: Theme.of(context).textTheme.labelSmall),
                Text('x = 5', style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  WavePainter(this.samples, this.colors);
  final List<WaveSample> samples;
  final ColorScheme colors;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(18)),
      Paint()..color = colors.surfaceContainerHigh,
    );
    final mid = size.height * .42;
    final grid = Paint()
      ..color = colors.outlineVariant
      ..strokeWidth = 1;
    canvas.drawLine(Offset(10, mid), Offset(size.width - 10, mid), grid);
    canvas.drawLine(
      Offset(10, size.height * .78),
      Offset(size.width - 10, size.height * .78),
      grid,
    );
    _line(canvas, size, (sample) => sample.real, mid, colors.primary, 1.15);
    _line(canvas, size, (sample) => sample.imaginary, mid, colors.error, 1.15);
    _line(
      canvas,
      size,
      (sample) => sample.probability,
      size.height * .8,
      colors.secondary,
      .52,
    );
    _line(
      canvas,
      size,
      (sample) => sample.potential,
      mid,
      colors.tertiary,
      .16,
    );
  }

  void _line(
    Canvas canvas,
    Size size,
    double Function(WaveSample) select,
    double baseline,
    Color color,
    double scale,
  ) {
    final path = Path();
    for (var i = 0; i < samples.length; i++) {
      final x = 10 + i * (size.width - 20) / (samples.length - 1);
      final y =
          baseline -
          select(samples[i]).clamp(-2, 2).toDouble() *
              size.height *
              scale *
              .28;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) => true;
}

class LibraryPage extends StatelessWidget {
  const LibraryPage({
    super.key,
    required this.controller,
    required this.onLoad,
  });
  final QuantumController controller;
  final VoidCallback onLoad;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        Text(
          'WAVE-FUNCTION LIBRARY',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        Text(
          'Textbook cases',
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          'Load packets, stationary eigenstates, and superpositions into the interactive lab.',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        ...List.generate(waveCases.length, (index) {
          final item = waveCases[index];
          final active = controller.selectedCase == index;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              color: active
                  ? Theme.of(context).colorScheme.secondaryContainer
                  : null,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  backgroundColor: item.color,
                  child: const Icon(Icons.functions, color: Colors.white),
                ),
                title: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(item.caption),
                trailing: active
                    ? const Icon(Icons.check_circle)
                    : const Icon(Icons.chevron_right),
                onTap: () {
                  controller.loadCase(index);
                  onLoad();
                },
              ),
            ),
          );
        }),
      ],
    );
  }
}

class StatesPage extends StatelessWidget {
  const StatesPage({
    super.key,
    required this.controller,
    required this.onApply,
  });
  final QuantumController controller;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final oscillator = controller.config.potential == PotentialKind.harmonic;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        Text(
          'INTERFERENCE WORKBENCH',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        Text(
          'Superposition builder',
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 5),
        Text(
          'Choose energy components and tune their relative amplitude and phase.',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Infinite well'),
              selected: !oscillator,
              onSelected: (_) =>
                  controller.setPotential(PotentialKind.infiniteWell),
            ),
            ChoiceChip(
              label: const Text('Oscillator'),
              selected: oscillator,
              onSelected: (_) =>
                  controller.setPotential(PotentialKind.harmonic),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          color: colors.secondaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UNNORMALISED WEIGHT',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      Text(
                        controller.normalizedWeight.toStringAsFixed(2),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Σ|cₙ|² = 1',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...controller.terms.map(
          (term) => StateEditor(
            term: term,
            controller: controller,
            label: oscillator ? 'ψ${term.n - 1}' : 'ψ${term.n}',
          ),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: () {
            controller.applySuperposition();
            onApply();
          },
          icon: const Icon(Icons.auto_graph),
          label: const Text('Apply superposition'),
        ),
      ],
    );
  }
}

class StateEditor extends StatelessWidget {
  const StateEditor({
    super.key,
    required this.term,
    required this.controller,
    required this.label,
  });
  final StateTerm term;
  final QuantumController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          'Energy component n = ${term.n}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: term.enabled,
                    onChanged: (value) =>
                        controller.updateTerm(term, enabled: value),
                  ),
                ],
              ),
              if (term.enabled) ...[
                const SizedBox(height: 8),
                LabeledSlider(
                  label: 'Amplitude',
                  value: term.amplitude,
                  min: 0,
                  max: 1.4,
                  onChanged: (value) =>
                      controller.updateTerm(term, amplitude: value),
                ),
                LabeledSlider(
                  label: 'Phase',
                  value: term.phase,
                  min: -math.pi,
                  max: math.pi,
                  onChanged: (value) =>
                      controller.updateTerm(term, phase: value),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class LearnPage extends StatelessWidget {
  const LearnPage({super.key, required this.controller});
  final QuantumController controller;

  @override
  Widget build(BuildContext context) {
    final formula = switch (controller.config.potential) {
      PotentialKind.free => 'V(x) = 0',
      PotentialKind.infiniteWell => 'ψₙ(x) = sin(nπx / L)',
      PotentialKind.harmonic => 'Eₙ = ℏω(n + ½)',
      PotentialKind.barrier => 'T ∝ e⁻²κa',
      PotentialKind.doubleWell => 'V(x) ∝ (x² − a²)²',
    };
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        Text(
          'CONCEPT NOTES',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.tertiary,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        Text(
          'Learn by observing',
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        Card(
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT SYSTEM',
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Text(
                  formula,
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Natural units are used in the interactive lab unless a quantity is explicitly labelled otherwise.',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Article(
          title: 'Reading the chart',
          body: 'The primary and error-color curves are the real and imaginary parts of ψ. The secondary curve is probability density |ψ|². The tertiary curve is the rescaled potential V(x).',
        ),
        const Article(
          title: 'Numerical comparison',
          body: 'The lab exposes a finite-difference reference against analytical energy, inviting students to inspect how discretisation choices affect an estimate.',
        ),
        const Article(
          title: 'Try this next',
          body: 'Pause a superposition and adjust the relative phase. Observe how probability density redistributes even though the selected energy levels remain unchanged.',
        ),
      ],
    );
  }
}

class Article extends StatelessWidget {
  const Article({super.key, required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 7),
            Text(
              body,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class LabeledSlider extends StatelessWidget {
  const LabeledSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value.toStringAsFixed(2),
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ],
      ),
      Slider(
        value: value.clamp(min, max).toDouble(),
        min: min,
        max: max,
        onChanged: onChanged,
      ),
    ],
  );
}

void _showControls(BuildContext context, QuantumController controller) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      top: false,
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, _) => DraggableScrollableSheet(
          initialChildSize: .78,
          maxChildSize: .93,
          minChildSize: .5,
          expand: false,
          builder: (_, scrollController) => ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Text(
                'Simulation controls',
                style: Theme.of(sheetContext).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              Text(
                'POTENTIAL',
                style: Theme.of(sheetContext).textTheme.labelSmall
                    ?.copyWith(letterSpacing: 1.1),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PotentialKind.values
                    .map(
                      (kind) => ChoiceChip(
                        label: Text(_potentialLabel(kind)),
                        selected: controller.config.potential == kind,
                        onSelected: (_) => controller.setPotential(kind),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              Text(
                'WAVE FUNCTION',
                style: Theme.of(sheetContext).textTheme.labelSmall
                    ?.copyWith(letterSpacing: 1.1),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: WaveMode.values
                    .map(
                      (mode) => ChoiceChip(
                        label: Text(_modeLabel(mode)),
                        selected: controller.mode == mode,
                        onSelected: (_) => controller.setMode(mode),
                      ),
                    )
                    .toList(),
              ),
              if (controller.mode == WaveMode.eigenstate)
                Wrap(
                  spacing: 8,
                  children: [1, 2, 3, 4]
                      .map(
                        (n) => ChoiceChip(
                          label: Text(
                            controller.config.potential ==
                                    PotentialKind.harmonic
                                ? 'ψ${n - 1}'
                                : 'ψ$n',
                          ),
                          selected: controller.activeN == n,
                          onSelected: (_) => controller.selectEigenstate(n),
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 16),
              LabeledSlider(
                label: 'Mass m',
                value: controller.config.mass,
                min: .25,
                max: 4,
                onChanged: (value) =>
                    controller.updateConfig((config) => config.mass = value),
              ),
              LabeledSlider(
                label: 'Packet width σ',
                value: controller.config.sigma,
                min: .3,
                max: 1.5,
                onChanged: (value) =>
                    controller.updateConfig((config) => config.sigma = value),
              ),
              LabeledSlider(
                label: 'Initial position x₀',
                value: controller.config.x0,
                min: -4.2,
                max: 2,
                onChanged: (value) =>
                    controller.updateConfig((config) => config.x0 = value),
              ),
              LabeledSlider(
                label: 'Wave number k₀',
                value: controller.config.k0,
                min: 0,
                max: 3,
                onChanged: (value) =>
                    controller.updateConfig((config) => config.k0 = value),
              ),
              if (controller.config.potential == PotentialKind.harmonic)
                LabeledSlider(
                  label: 'Angular frequency ω',
                  value: controller.config.omega,
                  min: .4,
                  max: 2.5,
                  onChanged: (value) =>
                      controller.updateConfig((config) => config.omega = value),
                ),
              if (controller.config.potential == PotentialKind.barrier)
                LabeledSlider(
                  label: 'Barrier height',
                  value: controller.config.barrierHeight,
                  min: 1,
                  max: 8,
                  onChanged: (value) => controller.updateConfig(
                    (config) => config.barrierHeight = value,
                  ),
                ),
              if (controller.config.potential == PotentialKind.barrier)
                LabeledSlider(
                  label: 'Barrier width',
                  value: controller.config.barrierWidth,
                  min: .5,
                  max: 2.5,
                  onChanged: (value) => controller.updateConfig(
                    (config) => config.barrierWidth = value,
                  ),
                ),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: () => Navigator.pop(sheetContext),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

String _stateLabel(QuantumController controller) =>
    controller.mode == WaveMode.packet
    ? 'Gaussian wave packet'
    : controller.mode == WaveMode.eigenstate
    ? 'Stationary eigenstate ψ${controller.config.potential == PotentialKind.harmonic ? controller.activeN - 1 : controller.activeN}'
    : 'Superposition of selected eigenstates';
String _potentialLabel(PotentialKind kind) => switch (kind) {
  PotentialKind.free => 'Free',
  PotentialKind.infiniteWell => 'Well',
  PotentialKind.harmonic => 'Oscillator',
  PotentialKind.barrier => 'Barrier',
  PotentialKind.doubleWell => 'Double well',
};
String _modeLabel(WaveMode mode) => switch (mode) {
  WaveMode.packet => 'Packet',
  WaveMode.eigenstate => 'Eigenstate',
  WaveMode.superposition => 'Superposition',
};
double _expectedX(List<WaveSample> samples) {
  final numerator = samples.fold<double>(
    0,
    (sum, item) => sum + item.x * item.probability,
  );
  final denominator = samples.fold<double>(
    0,
    (sum, item) => sum + item.probability,
  );
  return denominator == 0 ? 0 : numerator / denominator;
}
