class Message {
    let id: String
    let author: String
    let content: String
    let priority: Int
    var open: Bool
    var messageRef: Firebase?

    init(id: String, author: String, content: String, priority: Int, open: Bool)
    {
        self.id = id
        self.author = author
        self.content = content
        self.priority = priority
        self.open = open
    }

    class func createMessageFromSnapshot(messageSnapshot: FDataSnapshot) -> Message {
        let id = messageSnapshot.name
        let author = messageSnapshot.value.objectForKey("author") as String!
        let content = messageSnapshot.value.objectForKey("content") as String!
        let priority = messageSnapshot.value.objectForKey("priority") as Int!
        let open = messageSnapshot.value.objectForKey("open") as Bool!
        let message = Message(id: id, author: author, content: content, priority: priority, open: open)
        message.messageRef = messageSnapshot.ref
        return message
    }
}