import 'package:flutter_test/flutter_test.dart';
import 'package:quantum_wave_lab_flutter/main.dart';

void main() {
  test('all textbook wave-function cases generate finite chart samples', () {
    for (final item in waveCases) {
      final config = QuantumConfig()..potential = item.potential;
      final terms = [
        StateTerm(1, amplitude: 1, enabled: true),
        StateTerm(
          2,
          amplitude: .78,
          enabled: item.mode == WaveMode.superposition,
        ),
      ];
      final samples = buildWaveSamples(config, terms, item.mode, .4);
      expect(samples, hasLength(121));
      expect(
        samples.every(
          (sample) => sample.probability.isFinite && sample.probability >= 0,
        ),
        isTrue,
      );
    }
  });
}
