@objc class Task: DataEntity {
    let id: String
    let owner: String
    let team: String
    let author: String
    let title: String
    let content: String
    let priority: TaskPriority
    let timestamp: NSDate
    var active: Bool
    var ref: Firebase?

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
}