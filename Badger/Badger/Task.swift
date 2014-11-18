class Task {
    let id: String
    let author: String
    let content: String
    let priority: Int
    var open: Bool
    var ref: Firebase?

    init(id: String, author: String, content: String, priority: Int, open: Bool)
    {
        self.id = id
        self.author = author
        self.content = content
        self.priority = priority
        self.open = open
    }

    class func createTaskFromSnapshot(snapshot: FDataSnapshot) -> Task {
        let id = snapshot.name
        let author = snapshot.value.objectForKey("author") as String!
        let content = snapshot.value.objectForKey("content") as String!
        let priority = snapshot.value.objectForKey("priority") as Int!
        let open = snapshot.value.objectForKey("open") as Bool!
        let task = Task(id: id, author: author, content: content, priority: priority, open: open)
        task.ref = snapshot.ref
        return task
    }
}