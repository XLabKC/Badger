@objc class Task: DataEntity {
    let id: String
    var owner: String
    var team: String
    var author: String
    var title: String
    var content: String
    var priority: TaskPriority
    let timestamp: NSDate
    var active: Bool
    private var internalTimestampString: String?

    var ref: Firebase {
        get {
            return Task.createRef(self.owner, id: self.id, active: self.active)
        }
    }
    var timestampString: String {
        if let timestamp = self.internalTimestampString? {
            return timestamp
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "'Created at' h:mm a 'on' d/M/yy"
        self.internalTimestampString = dateFormatter.stringFromDate(self.timestamp)
        return self.internalTimestampString!
    }
    var firebasePriority: Double {
        get {
            let mult = Task.getFirebasePriorityMult(self.priority, isActive: self.active)
            return NSDate.javascriptTimestampFromDate(self.timestamp).doubleValue * mult
        }
    }

    init(id: String, owner: String, json: Dictionary<String, AnyObject>) {
        self.id = id
        self.owner = owner
        self.team = json["team"] as String
        self.author = json["author"] as String
        self.title = json["title"] as String
        self.content = json["content"] as String
        self.active = json["active"] as Bool
        self.timestamp = NSDate(fromJavascriptTimestamp: json["timestamp"] as NSNumber)
        var priority = TaskPriority(rawValue: json["priority"] as String)
        if priority == nil {
            priority = .Unknown
        }
        self.priority = priority!
    }

    func toJson() -> Dictionary<String, AnyObject> {
        return [
            "team": self.team,
            "author": self.author,
            "title": self.title,
            "content": self.content,
            "active": self.active,
            "timestamp": NSDate.javascriptTimestampFromDate(self.timestamp),
            "priority": self.priority.rawValue
        ]
    }

    class func createFromSnapshot(snapshot: FDataSnapshot) -> DataEntity {
        let id = snapshot.key
        let owner = snapshot.ref.parent.key
        return Task(id: id, owner: owner, json: snapshot.value as Dictionary<String, AnyObject>)
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
}