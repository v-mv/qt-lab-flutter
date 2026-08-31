# QT Lab

An interactive quantum mechanics simulator built with Flutter and Material 3.

> **Note**: This project is based on an earlier project, [PsiEvolutionKit](https://github.com/v-mv/PsiEvolutionKit), and is in active development.

---

## Overview

**QT Lab** allows students, educators, and physics enthusiasts to explore quantum wave functions through real-time interactive numerical and analytical simulations. 

It provides intuition for quantum phenomena—such as wave-packet dispersion, barrier tunneling, harmonic oscillation, and quantum interference—by rendering complex wave functions $\psi(x,t)$ dynamically on mobile and desktop platforms.

---

## Physics Engine & Mathematical Model

QT Lab models the one-dimensional time-dependent Schrödinger equation (TDSE) in natural units ($\hbar = 1$, $m = 1$ by default):

$$i\hbar \frac{\partial}{\partial t}\psi(x,t) = \hat{H}\psi(x,t) = \left( -\frac{\hbar^2}{2m} \frac{\partial^2}{\partial x^2} + V(x) \right) \psi(x,t)$$

### 1. Complex Wave Function & Probability Density
The quantum state is represented as a complex scalar field $\psi(x,t) = \text{Re}[\psi(x,t)] + i\,\text{Im}[\psi(x,t)]$.
- **Real component ($\text{Re}[\psi]$)**: Visualized in primary theme color.
- **Imaginary component ($\text{Im}[\psi]$)**: Visualized in accent/error color.
- **Probability Density ($P(x,t)$)**: Governed by $P(x,t) = |\psi(x,t)|^2 = \text{Re}[\psi]^2 + \text{Im}[\psi]^2$, shown as a secondary track curve.

### 2. Supported Potentials $V(x)$
- **Free Particle ($V(x) = 0$)**: Unbound motion in free space.
- **Infinite Square Well**:
  $$V(x) = \begin{cases} 0 & |x| \le 4 \\ V_0 & |x| > 4 \end{cases}$$
  Stationary state eigenfunctions:
  $$\psi_n(x) = \frac{1}{2} \sin\left(\frac{n\pi (x+4)}{L}\right), \quad E_n = \frac{n^2 \pi^2 \hbar^2}{2 m L^2} \quad (L = 8)$$
- **Quantum Harmonic Oscillator**:
  $$V(x) = \frac{1}{2} m \omega^2 x^2$$
  Hermite-Gaussian eigenstates with discrete energy spectrum $E_n = \hbar\omega\left(n - \frac{1}{2}\right)$ ($n = 1, 2, 3, \dots$).
- **Tunneling Barrier**:
  $$V(x) = \begin{cases} V_b & |x| < \frac{w}{2} \\ 0 & \text{otherwise} \end{cases}$$
  Simulates partial transmission and reflection across potential barriers.
- **Double Well**:
  $$V(x) = \alpha (x^2 - a^2)^2$$
  Models coupled potential wells and quantum tunneling oscillations between symmetric minima.

### 3. Wave Packet Dynamics & Trajectories
For Gaussian wave packets, the wave function takes the form:

$$\psi(x,t) \propto \exp\left(-\frac{(x - x(t))^2}{2\sigma(t)^2}\right) \exp\left(i\left(k_0 x - \frac{\hbar k_0^2}{2m} t\right)\right)$$

- **Spreading (Dispersion)**: Packet width grows over time according to $\sigma(t) = \sigma_0 \sqrt{1 + \beta t^2}$.
- **Potential Interactivity**:
  - In a **Harmonic Oscillator**, the packet center follows the classical trajectory $x(t) = x_0 \cos(\omega t) + \frac{k_0}{m\omega} \sin(\omega t)$.
  - In an **Infinite Well**, packet center trajectory reflects off rigid boundaries at $x = \pm 4$.

### 4. Quantum Superposition & Phase Evolution
Superpositions of stationary energy states evolve according to:

$$\psi(x,t) = \sum_n c_n \psi_n(x) e^{-i E_n t / \hbar}, \quad c_n = A_n e^{i \phi_n}$$

Users can adjust individual modal amplitudes $A_n$ and phases $\phi_n$ in the **Interference Workbench** to observe non-stationary density oscillations (e.g., beating between ground state $\psi_1$ and first excited state $\psi_2$).

### 5. Expectation Values & Observables
The simulator dynamically calculates quantum expectation values across spatial samples:
- **Position Expectation Value $\langle x \rangle$**:
  $$\langle x \rangle = \frac{\int_{-\infty}^{\infty} x |\psi(x,t)|^2 dx}{\int_{-\infty}^{\infty} |\psi(x,t)|^2 dx}$$
- **Momentum / Wave Number $\langle p \rangle$**: Expressed in units of $\hbar / \text{a.u.}$
- **Energy $E$**: Analytical state energy for active configurations.

### 6. Numerical vs. Analytical Reference Engine
The app incorporates a finite-difference discretization scheme on a 121-point spatial grid ($x \in [-5, 5]$). The kinetic energy operator uses a 3-point central stencil:

$$\frac{\partial^2 \psi_i}{\partial x^2} \approx \frac{\psi_{i+1} - 2\psi_i + \psi_{i-1}}{\Delta x^2}$$

The numerical expectation $\langle H \rangle_{\text{num}} = \frac{\langle \psi | \hat{H} | \psi \rangle}{\langle \psi | \psi \rangle}$ is evaluated and compared against exact analytical eigenvalues $E_{\text{analytical}}$, providing a real-time percentage discretization error.

---

## Features & Tech Stack

- **Framework**: Flutter (Dart 3.x)
- **Material 3 & Material You**: Dynamic color adaptation via `dynamic_color` on Android 12+.
- **Edge-to-Edge Design**: Custom status and navigation bar inset management.
- **Cross-Platform**: Android, iOS, Web, and Desktop support.

---

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.13.1 or newer)
- Android Studio / Xcode for device deployment

### Installation & Run

1. Clone the repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/QT-Lab.git
   cd QT-Lab
   ```

2. Fetch dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

### Project Commands
- **Code Formatting**: `dart format lib test`
- **Linter Check**: `flutter analyze`
- **Unit Tests**: `flutter test`

---

## Build Instructions

### Release APK
```bash
flutter build apk --release
```
Outputs build artifact to `build/app/outputs/flutter-apk/app-release.apk`.

---

## Acknowledgments
- Based on [PsiEvolutionKit](https://github.com/v-mv/PsiEvolutionKit) by [v-mv](https://github.com/v-mv).
- Built with Flutter & Material Design 3.
