
import Cocoa
import os.log

class AppDelegate: NSObject, NSApplicationDelegate {

    var statusBarItem: NSStatusItem!
    var mouseDebouncer: MouseDebouncer?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the status bar item
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusBarItem.button {
            button.image = NSImage(systemSymbolName: "cursorarrow.click.2", accessibilityDescription: "Mouse Debouncer")
        }

        // Create the menu
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Exit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusBarItem.menu = menu

        // Check for accessibility permissions
        checkPermissions()

        // Start the mouse debouncer
        mouseDebouncer = MouseDebouncer()
        mouseDebouncer?.start()
        
        os_log("Application finished launching", type: .info)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Stop the mouse debouncer
        mouseDebouncer?.stop()
        os_log("Application will terminate", type: .info)
    }

    func checkPermissions() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let accessibilityEnabled = AXIsProcessTrustedWithOptions(options)

        if !accessibilityEnabled {
            let alert = NSAlert()
            alert.messageText = "Accessibility Permissions Required"
            alert.informativeText = "Please grant accessibility permissions to this application in System Preferences."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Open System Preferences")
            alert.addButton(withTitle: "Exit")

            if alert.runModal() == .alertFirstButtonReturn {
                let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
                NSWorkspace.shared.open(url)
            }
            NSApp.terminate(nil)
        }
    }
}
