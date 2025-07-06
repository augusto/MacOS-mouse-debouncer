import CoreGraphics
import Foundation
import os.log

// The C-style callback function that will be called for each mouse event
private func eventTapCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, userInfo: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    // The user info is a pointer to the MouseDebouncer instance.
    // We need to cast it back to the correct type.
    if let userInfo = userInfo {
        let mouseDebouncer = Unmanaged<MouseDebouncer>.fromOpaque(userInfo).takeUnretainedValue()
        return mouseDebouncer.handle(proxy: proxy, type: type, event: event)
    }
    return Unmanaged.passRetained(event)
}

class MouseDebouncer {

    let debounceIntervalNanoSeconds: UInt64 = 150_000_000
    var lastDownClickTime: UInt64 = 0
    var waitForMouseUpEvent: Bool = false
    var eventTap: CFMachPort?

    func start() {
        let eventMask = (1 << CGEventType.leftMouseDown.rawValue) |
                        (1 << CGEventType.leftMouseUp.rawValue)

        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: eventTapCallback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        )

        if eventTap == nil {
            os_log("Failed to create event tap", type: .error)
            return
        }

        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap!, enable: true)
        
        os_log("Mouse debouncer started", type: .info)
    }

    func stop() {
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            self.eventTap = nil
            os_log("Mouse debouncer stopped", type: .info)
        }
    }

    func handle(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        guard type == .leftMouseDown || type == .leftMouseUp else {
            return Unmanaged.passRetained(event)
        }

        let currentTime = event.timestamp
        let elapsedTime = currentTime - lastDownClickTime

        if elapsedTime < debounceIntervalNanoSeconds && type == .leftMouseDown {
            os_log("Debounced mouse down event", type: .debug)
            waitForMouseUpEvent = true
            return nil
        } else if( waitForMouseUpEvent && type == .leftMouseUp) {
            os_log("Debounced mouse up event", type: .debug)
            waitForMouseUpEvent = false;
            return nil
        } else if type == .leftMouseDown {
            lastDownClickTime = currentTime
        }

        return Unmanaged.passRetained(event)
    }
}