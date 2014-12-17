@objc class Task: DataEntity {
    let id: String
    let owner: String
    let team: String
    let author: String
    let title: String
    let content: String
    let priority: TaskPriority
    let timestamp: NSDate
    let active: Bool
    var ref: Firebase?
    private var timestampString: String?

    init(id: String, owner: String, team: String, author: String, title: String, content: String, priority: TaskPriority, active: Bool, timestamp: NSDate)
    {
        self.id = id
        self.owner = owner
        self.team = team
        self.author = author
        self.title = title
        self.content = content
        self.priority = priority
        self.active = active
        self.timestamp = timestamp
    }

    func getRef() -> Firebase {
        if let ref = self.ref {
            return ref
        }
        self.ref = Task.createRef(self.owner, id: self.id, active: self.active)
        return self.ref!
    }

    func getTimestampString() -> String {
        if let timestamp = self.timestampString? {
            return timestamp
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "'Created at' h:mm a 'on' d/M/yy"
        self.timestampString = dateFormatter.stringFromDate(self.timestamp)
        return self.timestampString!
    }

    class func createFromSnapshot(snapshot: FDataSnapshot) -> DataEntity {
        let id = snapshot.key
        let owner = snapshot.ref.parent.key
        let team = Helpers.getString(snapshot.value, key: "team", backup: "Unknown")
        let author = Helpers.getString(snapshot.value, key: "author", backup: "Unknown")
        let title = Helpers.getString(snapshot.value, key: "title", backup: "No Title")
        let content = Helpers.getString(snapshot.value, key: "content", backup: "No content")
        let priority = Helpers.getString(snapshot.value, key: "priority", backup: "unknown")
        var taskPriority = TaskPriority(rawValue: priority)
        if taskPriority == nil {
            taskPriority = .Unknown
        }
        let active = Helpers.getBool(snapshot.value, key: "active", backup: true)
        let timestamp = Helpers.getDate(snapshot.value, key: "timestamp")
        let task = Task(id: id, owner: owner, team: team, author: author, title: title, content: content, priority: taskPriority!, active: active, timestamp: timestamp)
        task.ref = snapshot.ref
        return task
    }

    class func getFirebasePriorityMult(priority: TaskPriority, isActive: Bool) -> Double {
        if !isActive {
            return 1.0
        }
        switch priority {
        case .High:
            return 1.0 / 8.0
        case .Medium:
            return 1.0 / 4.0
        case .Low:
            return 1.0 / 2.0
        default:
            return 1.0
        }
    }

    class func createRef(owner: String, id: String, active: Bool) -> Firebase {
        var root: Firebase
        if active {
            root = Firebase(url: Global.FirebaseActiveTasksUrl)
        } else {
            root = Firebase(url: Global.FirebaseCompletedTasksUrl)
        }
        return root.childByAppendingPath("\(owner)/\(id)")
    }
}