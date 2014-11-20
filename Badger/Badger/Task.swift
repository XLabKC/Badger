class Task {
    let id: String
    let author: String
    let title: String
    let content: String
    let priority: TaskPriority
    var open: Bool
    var ref: Firebase?

    init(id: String, author: String, title: String, content: String, priority: TaskPriority, open: Bool)
    {
        self.id = id
        self.author = author
        self.title = title
        self.content = content
        self.priority = priority
        self.open = open
    }

    class func createTaskFromSnapshot(snapshot: FDataSnapshot) -> Task {
        let id = snapshot.key
        let author = Helpers.getString(snapshot.value, key: "author", backup: "Unknown")
        let title = Helpers.getString(snapshot.value, key: "title", backup: "No Title")
        let content = Helpers.getString(snapshot.value, key: "content", backup: "No content")
        let priority = Helpers.getString(snapshot.value, key: "priority", backup: "unknown")
        var taskPriority = TaskPriority(rawValue: priority)
        if taskPriority == nil {
            taskPriority = .Unknown
        }
        let open = Helpers.getBool(snapshot.value, key: "open", backup: true)
        let task = Task(id: id, author: author, title: title, content: content, priority: taskPriority!, open: open)
        task.ref = snapshot.ref
        return task
    }
}