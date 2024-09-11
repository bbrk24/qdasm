public enum Qdeql {
    public private(set) static var program = "-"
    private static var queueSize: Int {
        slots.count
    }
    private static var slots = [QueueSlotClass()]

    public static func reset() {
        program = "-"
        slots = [QueueSlotClass()]
    }

    public static func decrement(_ slot: borrowing QueueSlot, by amount: UInt8 = 1) {
        if amount == 0 { return }

        let idx = slots.firstIndex(of: slot.object)!
        program += String(repeating: "=", count: idx)
        removeRedundantRotation()

        if amount <= 127 {
            program += String(
                repeating: "-" + String(repeating: "=", count: queueSize - 1),
                count: Int(amount) - 1
            )
            program += "-"
            program += String(repeating: "=", count: queueSize - idx - 1)
        } else {
            let number = allocate(initialValue: amount)
            subtract(slot, number)
        }
    }

    // Allocate a new slot.
    public static func allocate(initialValue: UInt8) -> QueueSlot {
        if (1...127).contains(initialValue) {
            let inverse = allocate(initialValue: .max - initialValue + 1)
            let slot = allocate(initialValue: 0)
            subtract(slot, inverse)
            return slot
        }

        program += "\\" + String(repeating: "=", count: queueSize)
        if initialValue == 0 {
            program += "/" + String(repeating: "=", count: queueSize)
        } else {
            program += """
                /\(String(
                    repeating: "-" + String(repeating: "=", count: queueSize),
                    count: Int(.max - initialValue)
                ))-\(String(repeating: "=", count: queueSize - 1))
                """
        }
        let slot = QueueSlot()
        slots.insert(slot.object, at: 1)
        return slot
    }

    public static func readInput() -> QueueSlot {
        program += "&"
        let slot = QueueSlot()
        slots.append(slot.object)
        return slot
    }

    private static func destroy(slot: consuming QueueSlot, with instructions: String) {
        let idx = slots.firstIndex(of: slot.object)!
        program += String(repeating: "=", count: idx)
        removeRedundantRotation()
        program += instructions
        slots.remove(at: idx)
        program += String(repeating: "=", count: queueSize - idx)
    }

    public static func deallocate(_ slot: consuming QueueSlot) {
        destroy(
            slot: slot,
            with: #"""
                \\#(
                    String(repeating: "=", count: queueSize - 1)
                )-\/\/\#(
                    String(repeating: "=", count: queueSize - 1)
                )/
                """#
        )
    }

    public static func print(_ slot: consuming QueueSlot) {
        destroy(slot: slot, with: "*")
    }

    public static func subtract(_ lhs: borrowing QueueSlot, _ rhs: consuming QueueSlot) {
        precondition(rhs.object != lhs.object, "Cannot subtract from self")

        let rhsIdx = slots.firstIndex(of: rhs.object)!
        let lhsIdx = slots.firstIndex(of: lhs.object)!

        if lhsIdx < rhsIdx {
            // Queue: [a] lhs [b] rhs [c]
            let aCount = lhsIdx
            let bCount = rhsIdx - lhsIdx - 1
            let cCount = queueSize - rhsIdx - 1

            program += String(repeating: "=", count: aCount + 1 + bCount)
            removeRedundantRotation()
            // Queue: rhs [c] [a] lhs [b]
            program += "\\"
            // Queue: [c] [a] lhs [b] rhs 0 0
            program += String(repeating: "=", count: cCount + aCount)
            program += "-"
            program += String(repeating: "=", count: bCount)
            program += #"-\/\/"#
            // Queue: [c] [a] lhs [b] rhs
            program += String(repeating: "=", count: queueSize - 1)
            // Queue: rhs [c] [a] lhs [b]
            program += "/"
            // Queue: [c] [a] lhs [b]
            program += String(repeating: "=", count: cCount)
        } else {
            // Queue: [a] rhs [b] lhs [c]
            let aCount = rhsIdx
            let bCount = lhsIdx - rhsIdx - 1
            let cCount = queueSize - lhsIdx - 1

            program += String(repeating: "=", count: aCount)
            removeRedundantRotation()
            // Queue: rhs [b] lhs [c] [a]
            program += "\\"
            // Queue: [b] lhs [c] [a] rhs 0 0
            program += String(repeating: "=", count: bCount)
            program += "-"
            program += String(repeating: "=", count: cCount + aCount)
            program += #"-\/\/"#
            // Queue: [b] lhs [c] [a] rhs
            program += String(repeating: "=", count: queueSize - 1)
            // Queue: rhs [b] lhs [c] [a]
            program += "/"
            // Queue: [b] lhs [c] [a]
            program += String(repeating: "=", count: bCount + 1 + cCount)
        }

        slots.remove(at: rhsIdx)
    }

    public static func ifNotZero(_ slot: consuming QueueSlot, _ body: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let idx = slots.firstIndex(of: slot.object)!
        // Queue: [a] x [b]
        let aCount = idx
        let bCount = queueSize - aCount - 1
        program += String(repeating: "=", count: aCount)
        removeRedundantRotation()
        program += "\\"
        // Queue: [b] [a] x 0 0
        // Restore queue to normal state before continuing
        program += String(repeating: "=", count: queueSize)
        program += #"\/\/"#
        program += String(repeating: "=", count: bCount)

        let beforeSnapshot = slots
        body()
        let afterSnapshot = slots

        precondition(afterSnapshot.count == beforeSnapshot.count, "Cannot change queue size in if", file: file, line: line)
        for (i, (x, y)) in zip(beforeSnapshot, afterSnapshot).enumerated() {
            precondition(
                x == y || (!afterSnapshot.contains(x) && !beforeSnapshot.contains(y)),
                "Cannot rearrange queue in if (moved \(i) to \(afterSnapshot.firstIndex(of: x)!))",
                file: file,
                line: line
            )
        }

        // Queue: [a] x [b]
        program += String(repeating: "=", count: aCount)
        removeRedundantRotation()
        // Queue: x [b] [a]
        program += "\\"
        // Queue: [b] [a] x 0 0
        program += String(repeating: "=", count: queueSize - 1)
        // Queue: x 0 0 [b] [a]
        program += #"""
            \\#(
                String(repeating: "=", count: queueSize + 1)
            )-\/\/\#(
                String(repeating: "=", count: queueSize + 1)
            )/
            """#
        // Queue: 0 0 [b] [a]
        program += "//"

        // Queue: [b] [a]
        program += String(repeating: "=", count: bCount)

        slots.remove(at: idx)
    }

    public static func `while`(
        _ slot: consuming QueueSlot,
        _ body: (borrowing QueueSlot) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let idx = slots.firstIndex(of: slot.object)!
        // Queue: [a] x [b]
        let aCount = idx
        let bCount = queueSize - aCount - 1
        program += String(repeating: "=", count: aCount)
        removeRedundantRotation()
        program += "\\"
        // Queue: [b] [a] x 0 0
        // Restore queue to normal state before continuing
        program += String(repeating: "=", count: queueSize)
        program += #"\/\/"#
        program += String(repeating: "=", count: bCount)

        let beforeSnapshot = slots
        body(slot)
        let afterSnapshot = slots

        precondition(
            afterSnapshot.count == beforeSnapshot.count,
            "Cannot change queue size in while (was \(beforeSnapshot.count), now \(afterSnapshot.count))",
            file: file,
            line: line
        )
        for (i, (x, y)) in zip(beforeSnapshot, afterSnapshot).enumerated() {
            precondition(
                x == y || (!afterSnapshot.contains(x) && !beforeSnapshot.contains(y)),
                "Cannot rearrange queue in while (moved \(i) to \(afterSnapshot.firstIndex(of: x)!))",
                file: file,
                line: line
            )
        }

        // Queue: [a] x [b]
        program += String(repeating: "=", count: idx)
        removeRedundantRotation()
        // Queue: x [b] [a]
        program += "/"
        // Queue: [b] [a]
        program += String(repeating: "=", count: queueSize - idx)
        slots.remove(at: idx)
    }

    private static func removeRedundantRotation() {
        if program.suffix(queueSize).allSatisfy({ $0 == "=" }) {
            program = String(program.prefix(program.count - queueSize) as Substring)
        }
    }

    public static func printAndReread(_ slot: borrowing QueueSlot) {
        let idx = slots.firstIndex(of: slot.object)!
        program += String(repeating: "=", count: idx)
        removeRedundantRotation()
        program += "*&"
        program += String(repeating: "=", count: queueSize - idx - 1)
    }

    public static func duplicate(_ slot: inout QueueSlot) -> QueueSlot {
        let minusX = allocate(initialValue: 0)
        subtract(minusX, slot)
        // Queue: 255 -x ...
        // queueSize = len(...) + 2
        program += "\\"
        // Queue: -x ... 255 x x
        program += String(repeating: "=", count: queueSize - 1)
        // Queue: 255 x x -x ...
        program += "\\=="
        // Queue: -x ... 255 0 0 x x
        program += "\\"
        // Queue: ... 255 0 0 x x -x 0 0
        // Preserve two 0s for later, throw out two 0s in the loop
        program += String(repeating: "=", count: queueSize + 1)
        // Queue: x x -x 0 0 ... 255 0 0
        program += #"---\/\/"#
        // Queue: ... 255 0 0 x x -x
        program += String(repeating: "=", count: queueSize + 3)
        // Queue: -x ... 255 0 0 x x
        program += "/"
        // Queue: ... 255 0 0 x x
        program += String(repeating: "=", count: queueSize - 1)
        // Queue: 0 0 x x ... 255
        program += "//"
        // Queue: x x ... 255
        program += String(repeating: "=", count: queueSize)
        // Queue: 255 x x ...

        slots.remove(at: slots.firstIndex(of: minusX.object)!)
        slot = QueueSlot()
        let newSlot = QueueSlot()
        slots.insert(contentsOf: [slot.object, newSlot.object], at: 1)
        return newSlot
    }

    public static func moveToFront(_ slot: inout QueueSlot) {
        if slot.object == slots[1] { return }

        let minusX = allocate(initialValue: 255)
        subtract(minusX, slot)
        slot = allocate(initialValue: 255)
        subtract(slot, minusX)

        assert(slots[1] == slot.object)
    }

    public static func ifZero(
        _ slot: consuming QueueSlot,
        _ body: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let copy = duplicate(&slot)
        decrement(slot)
        ifNotZero(copy, {
            // This relies on the fact that where `slot` is moved to by `duplicate`
            // is the same position in the queue as where `allocate` puts the 0.
            // Internally, we should be able to know this, but assert it just to be safe.
            let beforeIdx = slots.firstIndex(of: slot.object)
            deallocate(slot)
            slot = allocate(initialValue: 0)
            let afterIdx = slots.firstIndex(of: slot.object)
            assert(beforeIdx == afterIdx)
        }, file: file, line: line)
        // If slot was initially 0, it is now 255, otherwise it is now 0
        ifNotZero(slot, body, file: file, line: line)
    }

    public static func clampingSubtract(_ x: inout QueueSlot, _ y: consuming QueueSlot) {
        var xCopy = duplicate(&x)
        `while`(y) { y in
            decrement(y)
            // This relies on the fact that `x` does not move here.
            // Internally, we should be able to know this, but assert it just to be safe.
            let beforeIdx = slots.firstIndex(of: x.object)
            ifNotZero(xCopy) {
                decrement(x)
            }
            xCopy = duplicate(&x)
            let afterIdx = slots.firstIndex(of: x.object)
            assert(beforeIdx == afterIdx)
        }
        deallocate(xCopy)
    }

    public static func assumingNotMoving(_ slot: borrowing QueueSlot, _ action: (inout QueueSlot) -> Void) {
        let beforeIdx = slots.firstIndex(of: slot.object)!
        var newSlot = QueueSlot()
        slots[beforeIdx] = newSlot.object
        action(&newSlot)
        let afterIdx = slots.firstIndex(of: newSlot.object)!
        precondition(beforeIdx == afterIdx, "Moved object in assumingNotMoving")
        slots[afterIdx] = slot.object
    }

    public static func debugPrintIndex(_ slot: borrowing QueueSlot) {
        if let idx = slots.firstIndex(of: slot.object) {
            Swift.print(idx)
        } else {
            Swift.print("nil")
        }
    }

    public static func debugPrintQueueSize() {
        Swift.print(queueSize)
    }
}

extension Qdeql {
    public static func add(_ lhs: consuming QueueSlot, _ rhs: consuming QueueSlot) -> QueueSlot {
        let diff = allocate(initialValue: 255)
        subtract(diff, lhs)
        subtract(diff, rhs)
        let ans = allocate(initialValue: 255)
        subtract(ans, diff)
        return ans
    }
}
