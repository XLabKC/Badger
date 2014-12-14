
@objc protocol TaskObserver: class {
    func taskUpdated(newTask: Task)
}

class TaskStore {
    // Accesses the singleton.
    class func sharedInstance() -> TaskStore {
        struct Static {
            static var instance: TaskStore?
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
            Static.instance = TaskStore()
        }
        return Static.instance!
    }

    private let ref = Firebase(url: Global.FirebaseTasksUrl)
    private let dataStore: ObservableDataStore<Task>

    init() {
        self.dataStore = ObservableDataStore<Task>({ (task, observer:AnyObject) in
            if let taskObserver = observer as? TaskObserver {
                taskObserver.taskUpdated(task)
            }
        })
    }

    func getTask(combinedId: String, withBlock: Task -> ()) -> Task? {
        let parts = TaskStore.separateCombinedId(combinedId)
        return self.dataStore.getEntity(self.createTaskRef(parts.uid, id: parts.taskId), withBlock: withBlock)
    }

    func getTask(uid: String, id: String, withBlock: Task -> ()) -> Task? {
        return self.dataStore.getEntity(self.createTaskRef(uid, id: id), withBlock: withBlock)
    }

    // Adds an observer for a uid.
//    func addObserver(observer: UserObserver, uid: String) {
//        self.dataStore.addObserver(observer, ref: self.createUserRef(uid))
//    }
//
//    func removeObserver(observer: UserObserver, uid: String) {
//        self.dataStore.removeObserver(observer, ref: self.createUserRef(uid))
//    }

    class func combineId(uid: String, id: String) -> String {
        return "\(uid)^\(id)"
    }

    class func separateCombinedId(combinedId: String) -> (uid: String, taskId: String) {
        let comp = combinedId.componentsSeparatedByString("^")
        return (uid: comp[0], taskId: comp[1])
    }

    private func createTaskRef(uid: String, id: String) -> Firebase {
        return self.ref.childByAppendingPath(uid)
    }
}
