import SwiftUI

// MARK: - Palette

private enum Palette {
    static let idleA = Color(red: 0.40, green: 0.62, blue: 1.00)
    static let idleB = Color(red: 0.42, green: 0.36, blue: 0.95)
    static let lockA = Color(red: 1.00, green: 0.60, blue: 0.38)
    static let lockB = Color(red: 0.93, green: 0.27, blue: 0.45)
}

// MARK: - Main view

/// Drives the breathing glow (an ObservableObject avoids the @State macro, which this toolchain lacks).
final class Beat: ObservableObject { @Published var on = false }

struct ContentView: View {
    @EnvironmentObject var blocker: KeyboardBlocker
    @StateObject private var beat = Beat()
    private var pulse: Bool { beat.on }

    private var locked: Bool { blocker.isLocked }
    private var colors: [Color] { locked ? [Palette.lockA, Palette.lockB] : [Palette.idleA, Palette.idleB] }
    private var progress: Double { locked ? Double(blocker.remaining) / Double(max(blocker.total, 1)) : 1 }

    var body: some View {
        ZStack {
            Background(tint: colors[1])

            VStack(spacing: 26) {
                PowerButton(colors: colors, locked: locked, progress: progress, pulse: pulse,
                            enabled: blocker.hasAccess, action: blocker.toggle)

                ZStack {
                    VStack(spacing: 10) {
                        Text("AUTO-UNLOCK AFTER")
                            .font(.system(size: 10.5, weight: .semibold))
                            .tracking(1.6)
                            .foregroundStyle(.white.opacity(0.4))
                        DurationPicker(selection: $blocker.timeout, accent: colors[0])
                    }
                    .opacity(locked ? 0 : 1)
                    .allowsHitTesting(!locked)

                    VStack(spacing: 6) {
                        Text("UNLOCKS AUTOMATICALLY IN")
                            .font(.system(size: 10.5, weight: .semibold))
                            .tracking(1.6)
                            .foregroundStyle(.white.opacity(0.4))
                        Text(format(blocker.remaining))
                            .font(.system(size: 30, weight: .medium, design: .rounded))
                            .monospacedDigit()
                    }
                    .opacity(locked ? 1 : 0)
                }
                .frame(height: 72)
                .animation(.easeInOut(duration: 0.3), value: locked)
            }
            .padding(.top, 16)

            if !blocker.hasAccess || blocker.errorMessage != nil {
                VStack { Spacer(); notice.padding(16) }
            }
        }
        .frame(width: 340, height: 440)
        .preferredColorScheme(.dark)
        .background(WindowStyler())
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) { beat.on = true }
        }
    }

    @ViewBuilder private var notice: some View {
        VStack(spacing: 10) {
            if !blocker.hasAccess {
                Text("Accessibility access required")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                Text("Allow Keyboard Cleaner in System Settings → Privacy & Security → Accessibility.")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                Button("Open Settings") { blocker.openAccessibilitySettings() }
                    .buttonStyle(.borderedProminent).tint(Palette.idleB).controlSize(.small)
            } else if let msg = blocker.errorMessage {
                Text(msg).font(.system(size: 12, design: .rounded)).foregroundStyle(Palette.lockA)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(.white.opacity(0.1)))
    }

    private func format(_ s: Int) -> String { String(format: "%d:%02d", s / 60, s % 60) }
}

// MARK: - Power button

private struct PowerButton: View {
    let colors: [Color]
    let locked: Bool
    let progress: Double
    let pulse: Bool
    let enabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                // Ambient glow
                Circle()
                    .fill(colors[1])
                    .frame(width: 190, height: 190)
                    .blur(radius: 46)
                    .opacity(locked ? (pulse ? 0.65 : 0.35) : 0.30)
                    .scaleEffect(locked && pulse ? 1.12 : 1)

                // Track + countdown ring
                Circle().strokeBorder(.white.opacity(0.08), lineWidth: 3)
                    .frame(width: 208, height: 208)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 208, height: 208)
                    .animation(.linear(duration: 1), value: progress)

                // Button body
                Circle()
                    .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 170, height: 170)
                    .overlay(
                        Circle().strokeBorder(
                            LinearGradient(colors: [.white.opacity(0.55), .white.opacity(0.02)],
                                           startPoint: .top, endPoint: .bottom), lineWidth: 1.5)
                    )
                    .overlay(
                        Circle().fill(RadialGradient(colors: [.white.opacity(0.28), .clear],
                                                     center: .init(x: 0.3, y: 0.2), startRadius: 0, endRadius: 110))
                    )
                    .shadow(color: colors[1].opacity(0.55), radius: 28, y: 14)

                VStack(spacing: 10) {
                    Image(systemName: locked ? "lock.fill" : "keyboard")
                        .font(.system(size: 46, weight: .light))
                    Text(locked ? "DONE" : "START")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .tracking(2.5)
                }
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                .id(locked)
                .transition(.scale(scale: 0.6).combined(with: .opacity))
            }
            .frame(width: 230, height: 230)
            .animation(.spring(response: 0.5, dampingFraction: 0.75), value: locked)
        }
        .buttonStyle(PressStyle())
        .opacity(enabled ? 1 : 0.4)
        .disabled(!enabled)
    }
}

private struct PressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Duration picker

private struct DurationPicker: View {
    @Binding var selection: Int
    let accent: Color
    @Namespace private var ns
    private let options: [(label: String, secs: Int)] = [("1 min", 60), ("2 min", 120), ("5 min", 300), ("10 min", 600)]

    var body: some View {
        HStack(spacing: 2) {
            ForEach(options, id: \.secs) { opt in
                let on = selection == opt.secs
                Text(opt.label)
                    .font(.system(size: 12, weight: on ? .semibold : .medium, design: .rounded))
                    .foregroundStyle(on ? .white : .white.opacity(0.5))
                    .frame(width: 62, height: 28)
                    .background {
                        if on {
                            Capsule().fill(.white.opacity(0.14))
                                .overlay(Capsule().strokeBorder(.white.opacity(0.12)))
                                .matchedGeometryEffect(id: "sel", in: ns)
                        }
                    }
                    .contentShape(Capsule())
                    .onTapGesture { withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { selection = opt.secs } }
            }
        }
        .padding(3)
        .background(Capsule().fill(.black.opacity(0.25)))
        .overlay(Capsule().strokeBorder(.white.opacity(0.06)))
    }
}

// MARK: - Window chrome

private struct Background: View {
    let tint: Color
    var body: some View {
        ZStack {
            VisualEffect()
            LinearGradient(colors: [tint.opacity(0.22), .black.opacity(0.35)], startPoint: .top, endPoint: .bottom)
                .animation(.easeInOut(duration: 0.6), value: tint)
        }
        .ignoresSafeArea()
    }
}

private struct VisualEffect: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let v = NSVisualEffectView()
        v.material = .underWindowBackground
        v.blendingMode = .behindWindow
        v.state = .active
        return v
    }
    func updateNSView(_ v: NSVisualEffectView, context: Context) {}
}

/// Seamless title bar, draggable body, and always-on-top so Unlock stays reachable.
private struct WindowStyler: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let v = NSView()
        DispatchQueue.main.async {
            guard let w = v.window else { return }
            w.level = .floating
            w.titlebarAppearsTransparent = true
            w.titleVisibility = .hidden
            w.styleMask.insert(.fullSizeContentView)
            w.isMovableByWindowBackground = true
            w.standardWindowButton(.zoomButton)?.isHidden = true
        }
        return v
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}
