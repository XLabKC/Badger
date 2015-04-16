@objc class Task: DataEntity {
    let id: String
    var owner: String
    var team: String
    let author: String
    var title: String
    var content: String
    var priority: TaskPriority
    let createdAt: NSDate
    var completedAt: NSDate?
    var active: Bool
    private var internalCreatedAtString: String?
    private var internalCompletedAtString: String?

    var ref: Firebase {
        return Task.createRef(self.owner, id: self.id, active: self.active)
    }
    var timestampString: String {
        return self.active ? self.createdAtString : self.completedAtString
    }
    var createdAtString: String {
        if let createdAt = self.internalCreatedAtString {
            return createdAt
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "'Created at' h:mm a 'on' M/d/yy"
        self.internalCreatedAtString = dateFormatter.stringFromDate(self.createdAt)
        return self.internalCreatedAtString!
    }
    var completedAtString: String {
        if let timestamp = self.internalCompletedAtString {
            return timestamp
        }
        if let completedAt = self.completedAt {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "'Completed at' h:mm a 'on' M/d/yy"
            self.internalCompletedAtString = dateFormatter.stringFromDate(self.createdAt)
        } else {
            self.internalCompletedAtString = "Not yet complete!"
        }
        return self.internalCompletedAtString!
    }
    var firebasePriority: Double {
        let mult = Task.getFirebasePriorityMult(self.priority, isActive: self.active)
        var dateForPriority = self.createdAt

        // If there is a completion date and task is not active, use it instead.
        if self.completedAt != nil && !self.active {
            dateForPriority = self.completedAt!
        }
        return (-1 * NSDate.javascriptTimestampFromDate(dateForPriority).doubleValue) * mult
    }

    init(id: String, author: String) {
        self.id = id
        self.author = author
        self.createdAt = NSDate()
        self.owner = ""
        self.team = ""
        self.title = ""
        self.content = ""
        self.priority = .Unknown
        self.active = true
    }

    init(id: String, owner: String, json: Dictionary<String, AnyObject>) {
        self.id = id
        self.owner = owner
        self.team = json["team"] as! String
        self.author = json["author"] as! String
        self.title = json["title"] as! String
        self.content = json["content"] as! String
        self.active = json["active"] as! Bool
        self.createdAt = NSDate(fromJavascriptTimestamp: json["created_at"] as! NSNumber)
        var priority = TaskPriority(rawValue: json["priority"] as! String)
        if priority == nil {
            priority = .Unknown
        }
        self.priority = priority!

        if let completedAt = json["completed_at"] as? NSNumber {
            self.completedAt = NSDate(fromJavascriptTimestamp: completedAt)
        }
    }

    func toJson() -> Dictionary<String, AnyObject> {
        var json = [
            "team": self.team,
            "author": self.author,
            "title": self.title,
            "content": self.content,
            "active": self.active,
            "created_at": NSDate.javascriptTimestampFromDate(self.createdAt),
            "priority": self.priority.rawValue
        ]
        if let completedAt = self.completedAt {
            json["completed_at"] = NSDate.javascriptTimestampFromDate(completedAt)
        }
        return json
    }

    func getKey() -> String {
        return self.id
    }

    class func createFromSnapshot(snapshot: FDataSnapshot) -> DataEntity {
        let id = snapshot.key
        let owner = snapshot.ref.parent.key
        return Task(id: id, owner: owner, json: snapshot.value as! Dictionary<String, AnyObject>)
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
            return 1.0 / 2.0
        case .Medium:
            return 1.0 / 4.0
        case .Low:
            return 1.0 / 8.0
        default:
            return 1.0
        }
    }

    class func combineId(owner: String, id: String) -> String {
        return "\(owner)^\(id)"
    }

    class func separateCombinedId(combinedId: String) -> (uid: String, taskId: String) {
        let comp = combinedId.componentsSeparatedByString("^")
        return (uid: comp[0], taskId: comp[1])
    }
}