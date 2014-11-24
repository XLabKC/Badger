protocol BarrierEntry: class {
    func registerBarrier(Barrier)
}

class Barrier {
    private var count: Int
    private let doneBlock: (() -> ())
//    private let waitersLock = dispatch_queue_create("waitersLockQueue", nil)

    init(count: Int, done: (() -> ())) {
        self.count = count
        self.doneBlock = done
    }

    func decrement() {
        // TODO: Some kind of lock.
        if --self.count <= 0 {
            self.doneBlock()
        }
    }
//
//    func register(entry: BarrierEntry) {
//
//    }
}
