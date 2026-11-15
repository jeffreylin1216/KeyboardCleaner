import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    var blocker: KeyboardBlocker?
    func applicationWillTerminate(_ notification: Notification) { blocker?.unlock() }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }
}

@main
struct KeyboardCleanerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    @StateObject private var blocker = KeyboardBlocker()

    var body: some Scene {
        Window("Keyboard Cleaner", id: "main") {
            ContentView()
                .environmentObject(blocker)
                .onAppear { delegate.blocker = blocker }
        }
        .windowResizability(.contentSize)

        MenuBarExtra("Keyboard Cleaner", systemImage: blocker.isLocked ? "lock.fill" : "keyboard") {
            Button(blocker.isLocked ? "Unlock Keyboard" : "Lock Keyboard") { blocker.toggle() }
                .disabled(!blocker.hasAccess)
            Divider()
            Button("Quit") { NSApplication.shared.terminate(nil) }
        }
    }
}
