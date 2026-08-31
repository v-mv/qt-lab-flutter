# QT Lab

An interactive quantum mechanics simulator built with Flutter and Material 3.

> **Note**: This project is based on an earlier project, [PsiEvolutionKit](https://github.com/v-mv/PsiEvolutionKit), and is currently under active development.

---

## Overview

**QT Lab** is a mobile and desktop application for exploring 1D quantum mechanics through real-time interactive simulations. It translates abstract mathematical concepts—such as wave function phase, dispersion, quantum tunneling, and interference—into visual, intuitive representations.

---

## Quantum Theory & Physics Concepts

The simulator models the physical behavior of a single non-relativistic particle governed by the **Time-Dependent Schrödinger Equation**.

### 1. Wave Functions & Probability Density
In quantum mechanics, a particle's state is completely described by a complex-valued wave function $\psi(x,t)$:
- **Real & Imaginary Parts**: Represented as distinct colored curves to illustrate phase evolution over time.
- **Probability Density ($|\psi|^2$)**: The squared magnitude gives the probability of detecting the particle at position $x$. The total probability across space is normalized to 1.

### 2. Quantum Systems & Potentials
- **Free Particle**: A wave packet moving freely in space without external forces.
- **Infinite Square Well**: A particle confined inside a hard-walled box ($x \in [-4, 4]$). The solutions form standing waves (eigenstates) with quantized energy levels proportional to $n^2$.
- **Harmonic Oscillator**: A quadratic potential well modeling quantum springs and atomic vibrations. Energy levels are equally spaced ($E_n \propto n - 1/2$).
- **Tunneling Barrier**: A finite potential barrier demonstrating **quantum tunneling**, where the wave function exponentially decays inside the barrier and partially transmits through it.
- **Double Well**: Two symmetric potential wells separated by a central barrier, illustrating coupled-well tunneling and energy splitting.

### 3. Wave Packet Trajectories & Dispersion
A localized particle is modeled as a **Gaussian wave packet**. As time progresses:
- **Dispersion**: The packet naturally spreads out, representing increasing uncertainty in position.
- **Classical Alignment**: In a harmonic oscillator, the packet center follows classical simple harmonic motion. In a square well, it reflects off the boundaries.

### 4. Superposition & Interference
When a particle exists in a linear combination of multiple energy eigenstates, the stationary phases interfere. This produces dynamic, time-varying probability distributions—allowing users to observe quantum "beating" and state evolution in real time.

### 5. Numerical Reference Method
To verify theoretical values, QT Lab uses a 3-point **finite-difference discretization** scheme on a 121-point spatial grid. The numerical energy expectation value $\langle H \rangle$ is computed continuously and compared against exact analytical eigenvalues, displaying the real-time discretization error percentage.

---

## Features & Tech Stack

- **Framework**: Flutter (Dart 3.x)
- **Material 3 & Material You**: Dynamic color adaptation on Android 12+ using wallpaper themes.
- **Edge-to-Edge Design**: Native system bar inset handling for modern mobile layouts.
- **Platforms**: Android, iOS, Web, and Desktop.

---

## Getting Started

### Development Setup
1. Install [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.13.1+).
2. Clone the repository and fetch dependencies:
   ```bash
   git clone https://github.com/YOUR_USERNAME/QT-Lab.git
   cd QT-Lab
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

### Project Commands
- **Run Tests**: `flutter test`
- **Analyze Code**: `flutter analyze`
- **Format Code**: `dart format lib test`

---

## Build Instructions

To build a release Android APK:
```bash
flutter build apk --release
```

---

## Acknowledgments

- Based on [PsiEvolutionKit](https://github.com/v-mv/PsiEvolutionKit) by [v-mv](https://github.com/v-mv).
