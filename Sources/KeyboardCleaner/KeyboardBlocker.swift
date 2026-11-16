import Cocoa
import ApplicationServices

/// Owns the CGEventTap that swallows keyboard events while "locked".
final class KeyboardBlocker: ObservableObject {
    @Published private(set) var isLocked = false
    @Published private(set) var remaining = 0
    @Published private(set) var total = 1
    @Published private(set) var hasAccess = AXIsProcessTrusted()
    @Published var timeout = UserDefaults.standard.object(forKey: "timeout") as? Int ?? 120 {   // seconds until auto-unlock
        didSet { UserDefaults.standard.set(timeout, forKey: "timeout") }
    }
    @Published var errorMessage: String?

    fileprivate var tap: CFMachPort?
    private var source: CFRunLoopSource?
    private var countdown: Timer?
    private var accessPoll: Timer?

    init() {
        if hasAccess {
            // Already set up: start cleaning as soon as the app opens.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in self?.lock() }
        } else {
            requestAccess()
            accessPoll = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                guard let self else { return }
                if AXIsProcessTrusted() {
                    self.hasAccess = true
                    self.accessPoll?.invalidate()
                    self.accessPoll = nil
                }
            }
        }
    }

    func requestAccess() {
        let opts = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        hasAccess = AXIsProcessTrustedWithOptions(opts)
    }

    func openAccessibilitySettings() {
        requestAccess()   // re-registers the app so it appears in the Accessibility list
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }

    func toggle() { isLocked ? unlock() : lock() }

    func lock() {
        guard !isLocked else { return }
        guard AXIsProcessTrusted() else {
            hasAccess = false
            errorMessage = "Accessibility permission is required."
            return
        }
        // keyDown, keyUp, flagsChanged, and NSSystemDefined (14: media/volume/brightness keys)
        let types: [CGEventType] = [.keyDown, .keyUp, .flagsChanged, CGEventType(rawValue: 14)!]
        let mask = types.reduce(CGEventMask(0)) { $0 | (CGEventMask(1) << $1.rawValue) }

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: keyboardTapCallback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            errorMessage = "Couldn't start the keyboard lock. Check Accessibility permission."
            return
        }
        self.tap = tap
        source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)

        errorMessage = nil
        total = timeout
        remaining = timeout
        isLocked = true
        countdown = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            // Watchdog: keep the tap alive, and release the keyboard if permission vanishes.
            if !AXIsProcessTrusted() {
                self.hasAccess = false
                self.unlock()
                return
            }
            if let tap = self.tap, !CGEvent.tapIsEnabled(tap: tap) {
                CGEvent.tapEnable(tap: tap, enable: true)
            }
            self.remaining -= 1
            if self.remaining <= 0 { self.unlock() }
        }
    }

    func unlock() {
        countdown?.invalidate(); countdown = nil
        if let tap { CGEvent.tapEnable(tap: tap, enable: false); CFMachPortInvalidate(tap) }
        if let source { CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes) }
        tap = nil; source = nil
        isLocked = false
        remaining = 0
    }
}

/// Returning nil drops the event. If macOS disables the tap, turn it back on.
private func keyboardTapCallback(
    proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
        if let refcon {
            let blocker = Unmanaged<KeyboardBlocker>.fromOpaque(refcon).takeUnretainedValue()
            if let tap = blocker.tap { CGEvent.tapEnable(tap: tap, enable: true) }
        }
        return Unmanaged.passUnretained(event)
    }
    // System-defined events carry media/volume/brightness/function keys (subtype 8).
    // Only extra mouse buttons (subtype 7) are let through; everything else is dropped.
    if type.rawValue == 14, let ns = NSEvent(cgEvent: event), Int(ns.subtype.rawValue) == 7 {
        return Unmanaged.passUnretained(event)
    }
    return nil
}
