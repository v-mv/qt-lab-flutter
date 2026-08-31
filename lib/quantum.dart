import 'dart:math' as math;

import 'package:flutter/material.dart';

enum PotentialKind { free, infiniteWell, harmonic, barrier, doubleWell }

enum WaveMode { packet, eigenstate, superposition }

class QuantumConfig {
  QuantumConfig({
    this.potential = PotentialKind.free,
    this.mass = 1,
    this.hbar = 1,
    this.sigma = .7,
    this.x0 = -2.2,
    this.k0 = 1.35,
    this.omega = 1,
    this.barrierHeight = 3.2,
    this.barrierWidth = 1.05,
    this.wellSeparation = 2.8,
  });

  PotentialKind potential;
  double mass;
  double hbar;
  double sigma;
  double x0;
  double k0;
  double omega;
  double barrierHeight;
  double barrierWidth;
  double wellSeparation;
}

class StateTerm {
  StateTerm(this.n, {this.amplitude = 0, this.phase = 0, this.enabled = false});
  final int n;
  double amplitude;
  double phase;
  bool enabled;
}

class WaveCase {
  const WaveCase({
    required this.name,
    required this.caption,
    required this.potential,
    required this.mode,
    required this.state,
    required this.color,
  });
  final String name;
  final String caption;
  final PotentialKind potential;
  final WaveMode mode;
  final int state;
  final Color color;
}

const waveCases = <WaveCase>[
  WaveCase(
    name: 'Free Gaussian packet',
    caption: 'A moving dispersive packet',
    potential: PotentialKind.free,
    mode: WaveMode.packet,
    state: 1,
    color: Color(0xFF006A6A),
  ),
  WaveCase(
    name: 'Infinite well ground state',
    caption: 'Stationary eigenstate ψ₁',
    potential: PotentialKind.infiniteWell,
    mode: WaveMode.eigenstate,
    state: 1,
    color: Color(0xFF5D4A9D),
  ),
  WaveCase(
    name: 'Infinite well first excited',
    caption: 'Stationary eigenstate ψ₂',
    potential: PotentialKind.infiniteWell,
    mode: WaveMode.eigenstate,
    state: 2,
    color: Color(0xFF5D4A9D),
  ),
  WaveCase(
    name: 'Infinite well superposition',
    caption: 'Interference of ψ₁ and ψ₂',
    potential: PotentialKind.infiniteWell,
    mode: WaveMode.superposition,
    state: 1,
    color: Color(0xFF5D4A9D),
  ),
  WaveCase(
    name: 'Oscillator ground state',
    caption: 'Zero-point motion',
    potential: PotentialKind.harmonic,
    mode: WaveMode.eigenstate,
    state: 1,
    color: Color(0xFF166B45),
  ),
  WaveCase(
    name: 'Oscillator first excited',
    caption: 'One stationary node',
    potential: PotentialKind.harmonic,
    mode: WaveMode.eigenstate,
    state: 2,
    color: Color(0xFF166B45),
  ),
  WaveCase(
    name: 'Oscillator superposition',
    caption: 'ψ₀ + ψ₁ oscillation',
    potential: PotentialKind.harmonic,
    mode: WaveMode.superposition,
    state: 1,
    color: Color(0xFF166B45),
  ),
  WaveCase(
    name: 'Barrier tunneling',
    caption: 'Partial reflection and transmission',
    potential: PotentialKind.barrier,
    mode: WaveMode.packet,
    state: 1,
    color: Color(0xFF805A00),
  ),
  WaveCase(
    name: 'Double well packet',
    caption: 'Localized coupled-well packet',
    potential: PotentialKind.doubleWell,
    mode: WaveMode.packet,
    state: 1,
    color: Color(0xFF9B244B),
  ),
];

class WaveSample {
  const WaveSample(
    this.x,
    this.real,
    this.imaginary,
    this.probability,
    this.potential,
  );
  final double x;
  final double real;
  final double imaginary;
  final double probability;
  final double potential;
}

class QuantumController extends ChangeNotifier {
  QuantumConfig config = QuantumConfig();
  WaveMode mode = WaveMode.packet;
  int selectedCase = 0;
  double time = 0;
  bool playing = true;
  final terms = <StateTerm>[
    StateTerm(1, amplitude: 1, enabled: true),
    StateTerm(2, amplitude: .78, enabled: true),
    StateTerm(3),
    StateTerm(4),
  ];

  void tick() {
    if (!playing) return;
    time = (time + .035) % 18;
    notifyListeners();
  }

  void reset() {
    time = 0;
    playing = true;
    notifyListeners();
  }

  void togglePlayback() {
    playing = !playing;
    notifyListeners();
  }

  void applySuperposition() {
    mode = WaveMode.superposition;
    selectedCase = -1;
    time = 0;
    notifyListeners();
  }

  void setPotential(PotentialKind value) {
    config.potential = value;
    if (value != PotentialKind.infiniteWell &&
        value != PotentialKind.harmonic) {
      mode = WaveMode.packet;
    }
    selectedCase = -1;
    time = 0;
    notifyListeners();
  }

  void setMode(WaveMode value) {
    if (value != WaveMode.packet &&
        config.potential != PotentialKind.infiniteWell &&
        config.potential != PotentialKind.harmonic) {
      config.potential = PotentialKind.infiniteWell;
    }
    mode = value;
    if (value == WaveMode.eigenstate) _selectEigenstate(1);
    selectedCase = -1;
    time = 0;
    notifyListeners();
  }

  void _selectEigenstate(int n) {
    for (final term in terms) {
      term.enabled = term.n == n;
      term.amplitude = term.n == n ? 1 : 0;
      term.phase = 0;
    }
  }

  void selectEigenstate(int n) {
    mode = WaveMode.eigenstate;
    _selectEigenstate(n);
    selectedCase = -1;
    time = 0;
    notifyListeners();
  }

  void loadCase(int index) {
    final item = waveCases[index];
    config.potential = item.potential;
    mode = item.mode;
    selectedCase = index;
    time = 0;
    if (item.mode == WaveMode.eigenstate) {
      _selectEigenstate(item.state);
    } else if (item.mode == WaveMode.superposition) {
      for (final term in terms) {
        term.enabled = term.n <= 2;
        term.amplitude = term.n == 1
            ? 1
            : term.n == 2
            ? .78
            : 0;
        term.phase = 0;
      }
    }
    notifyListeners();
  }

  void updateConfig(void Function(QuantumConfig) update) {
    update(config);
    selectedCase = -1;
    time = 0;
    notifyListeners();
  }

  void updateTerm(
    StateTerm term, {
    bool? enabled,
    double? amplitude,
    double? phase,
  }) {
    term.enabled = enabled ?? term.enabled;
    term.amplitude = amplitude ?? term.amplitude;
    term.phase = phase ?? term.phase;
    mode = WaveMode.superposition;
    selectedCase = -1;
    time = 0;
    notifyListeners();
  }

  String get potentialTitle => switch (config.potential) {
    PotentialKind.free => 'Free particle',
    PotentialKind.infiniteWell => 'Infinite square well',
    PotentialKind.harmonic => 'Harmonic oscillator',
    PotentialKind.barrier => 'Tunneling barrier',
    PotentialKind.doubleWell => 'Double well',
  };

  int get activeN => terms.where((term) => term.enabled).isEmpty
      ? 1
      : terms.firstWhere((term) => term.enabled).n;
  double get normalizedWeight => terms
      .where((term) => term.enabled)
      .fold<double>(0, (sum, term) => sum + term.amplitude * term.amplitude);

  double get numericalError {
    if (mode == WaveMode.packet) return 0;
    final n = activeN;
    final analytical = _eigenEnergy(config, n);
    if (analytical == 0) return 0;

    // Simplified finite difference check for the current grid
    const points = 121;
    const dx = 10 / (points - 1);
    final psi = List.generate(
      points,
      (i) => _eigenfunction(config, n, -5 + i * dx),
    );

    double laplacianSum = 0;
    double norm = 0;
    for (var i = 1; i < points - 1; i++) {
      final d2psi = (psi[i + 1] - 2 * psi[i] + psi[i - 1]) / (dx * dx);
      final energyAtPoint =
          (-config.hbar * config.hbar / (2 * config.mass)) * d2psi +
          _potential(config, -5 + i * dx) * psi[i];
      laplacianSum += psi[i] * energyAtPoint;
      norm += psi[i] * psi[i];
    }

    if (norm == 0) return 0;
    final numerical = laplacianSum / norm;
    return ((numerical - analytical) / analytical).abs() * 100;
  }

  List<WaveSample> get samples => buildWaveSamples(config, terms, mode, time);
}

List<WaveSample> buildWaveSamples(
  QuantumConfig config,
  List<StateTerm> terms,
  WaveMode mode,
  double time,
) {
  const points = 121;
  final active = terms.where((term) => term.enabled).toList();
  final weight = active
      .fold<double>(0, (sum, term) => sum + term.amplitude * term.amplitude)
      .clamp(.0001, double.infinity)
      .toDouble();
  return List.generate(points, (index) {
    final x = -5 + index * 10 / (points - 1);
    final potential = _potential(config, x);
    double real;
    double imaginary;
    if (mode == WaveMode.packet) {
      double centre;
      if (config.potential == PotentialKind.harmonic) {
        // Classical harmonic motion
        centre =
            config.x0 * math.cos(config.omega * time) +
            (config.k0 / (config.mass * config.omega)) *
                math.sin(config.omega * time);
      } else if (config.potential == PotentialKind.infiniteWell) {
        // Bouncing logic in 8-unit well (-4 to 4)
        final raw = config.x0 + (config.k0 / config.mass) * time;
        final shifted = (raw + 4) % 16; // Period 16 for full round trip
        centre = shifted < 8 ? shifted - 4 : 12 - shifted;
      } else {
        centre = config.x0 + config.k0 / config.mass * time;
      }

      final width = config.sigma * math.sqrt(1 + .04 * time * time);
      final envelope = math.exp(-math.pow((x - centre) / width, 2) / 2);
      final phase =
          config.k0 * x - (.5 * config.k0 * config.k0 / config.mass) * time;
      final attenuation =
          config.potential == PotentialKind.barrier &&
              x > config.barrierWidth / 2 &&
              time > 1.4
          ? .58
          : 1.0;
      real = envelope * math.cos(phase) * attenuation;
      imaginary = envelope * math.sin(phase) * attenuation;
    } else {
      real = 0;
      imaginary = 0;
      for (final term in active) {
        final basis = _eigenfunction(config, term.n, x);
        final phase =
            term.phase - _eigenEnergy(config, term.n) * time / config.hbar;
        final coefficient = term.amplitude / math.sqrt(weight);
        real += coefficient * basis * math.cos(phase);
        imaginary += coefficient * basis * math.sin(phase);
      }
    }
    return WaveSample(
      x,
      real,
      imaginary,
      real * real + imaginary * imaginary,
      potential,
    );
  });
}

double potentialAt(QuantumConfig config, double x) => _potential(config, x);
double eigenEnergy(QuantumConfig config, int n) => _eigenEnergy(config, n);

double _potential(QuantumConfig config, double x) => switch (config.potential) {
  PotentialKind.free => 0,
  PotentialKind.infiniteWell => x.abs() > 4 ? 3.5 : 0,
  PotentialKind.harmonic => .5 * config.omega * config.omega * x * x,
  PotentialKind.barrier =>
    x.abs() < config.barrierWidth / 2 ? config.barrierHeight : 0,
  PotentialKind.doubleWell => .12 * math.pow(x * x - config.wellSeparation, 2),
};

double _eigenfunction(QuantumConfig config, int n, double x) {
  if (config.potential == PotentialKind.infiniteWell) {
    if (x.abs() > 4) return 0;
    return 0.5 * math.sin(n * math.pi * (x + 4) / 8);
  }
  final y = math.sqrt(config.omega) * x;
  final gaussian =
      math.exp(-y * y / 2) * math.pow(config.omega / math.pi, 0.25);
  return switch (n) {
    1 => gaussian,
    2 => math.sqrt(2) * y * gaussian,
    3 => (2 * y * y - 1) * gaussian / math.sqrt(2),
    _ => (2 * y * y * y - 3 * y) * gaussian / math.sqrt(3),
  };
}

double _eigenEnergy(QuantumConfig config, int n) =>
    config.potential == PotentialKind.infiniteWell
    ? n *
          n *
          math.pi *
          math.pi *
          config.hbar *
          config.hbar /
          (2 * config.mass * 64)
    : config.hbar * config.omega * (n - .5);
