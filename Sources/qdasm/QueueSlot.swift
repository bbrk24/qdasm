internal final class QueueSlotClass: Equatable {
    static func == (lhs: QueueSlotClass, rhs: QueueSlotClass) -> Bool {
        lhs === rhs
    }
}

public struct QueueSlot: ~Copyable {
    internal private(set) var object = QueueSlotClass()

    public mutating func swapReference(with other: inout QueueSlot) {
        let ownObject = object
        object = other.object
        other.object = ownObject
    }
}
