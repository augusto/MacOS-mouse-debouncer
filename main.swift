
import CoreGraphics
import Foundation

// The debounce interval in nanoseconds (150ms = 150,000,000 ns)
let debounceIntervalNanoSeconds: UInt64 = 150_000_000
var lastDownClickTime: UInt64 = 0
var waitiForUpEvent: Bool = false

// The callback function that will be called for each mouse event
func eventTapCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, userInfo: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    // We are only interested in mouse down and mouse up events
    guard type == .leftMouseDown || type == .leftMouseUp else {
        return Unmanaged.passRetained(event)
    }

    let currentTime = event.timestamp
    let elapsedTime = currentTime - lastDownClickTime

    if elapsedTime < debounceIntervalNanoSeconds && type == .leftMouseDown {
        // If the time since the last click is less than our interval,
        // discard the event by returning nil.
        print("Debounced event of type: \(type.rawValue) - \(elapsedTime/1_000_000)ms")
        waitiForUpEvent = true
        return nil
    } else if( waitiForUpEvent && type == .leftMouseUp) {
        waitiForUpEvent = false;
        return nil
    } else if type == .leftMouseDown {
        lastDownClickTime = currentTime
    }

    return Unmanaged.passRetained(event)
}

// --- Main Execution ---

// 1. Create an event mask for the events we want to listen to.
let eventMask = (1 << CGEventType.leftMouseDown.rawValue) |
                (1 << CGEventType.leftMouseUp.rawValue) 

// 2. Create the event tap.
//    - kCGHIDEventTap: Taps into the stream of low-level Human Interface Device events.
//    - kCGHeadInsertEventTap: Inserts the tap at the head of the event stream.
//    - kCGEventTapOptionDefault: The default behavior for the tap.
guard let eventTap = CGEvent.tapCreate(
    tap: .cgSessionEventTap,
    place: .headInsertEventTap,
    options: .defaultTap,
    eventsOfInterest: CGEventMask(eventMask),
    callback: eventTapCallback,
    userInfo: nil
) else {
    print("Failed to create event tap. Please ensure you have granted Accessibility permissions.")
    exit(1)
}

print("Mouse debouncer started. Press Ctrl+C to exit.")

// 3. Create a run loop source and add it to the current run loop.
//    This is what keeps our command-line tool alive and listening for events.
let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)

// 4. Enable the event tap.
CGEvent.tapEnable(tap: eventTap, enable: true)

// 5. Start the run loop to begin processing events.
CFRunLoopRun()
