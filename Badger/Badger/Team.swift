
@objc class Team: DataEntity {
    let id: String
    var name = ""
    var activeTaskCount = 0
    var ownerIds: [String: Bool] = [:]
    var memberIds: [String: Bool] = [:]
    var logo = "DefaultTeamLogo"
    var headerImage = "DefaultTeamBackground"
    var activeTaskCombinedIds: [String: Bool] = [:]

    var ref: Firebase {
        return Team.createRef(self.id)
    }

    init(id: String)
    {
        self.id = id
    }

    init(id: String, json: Dictionary<String, AnyObject>) {
        self.id = id
        self.name = json["name"] as String
        self.activeTaskCount = json["active_task_count"] as Int
        self.logo = json["logo"] as String
        self.headerImage = json["header_image"] as String

        if let owners = json["owners"] as? Dictionary<String, Bool> {
            self.ownerIds = owners
        }
        if let members = json["members"] as? Dictionary<String, Bool> {
            self.memberIds = members
        }
        if let tasks = json["active_tasks"] as? Dictionary<String, Bool> {
            self.activeTaskCombinedIds = tasks
        }
    }

    func description() -> String {
        var taskString: String
        switch self.activeTaskCount {
        case 0:
            taskString = "No Tasks"
        case 1:
            taskString = "1 Task"
        default:
            taskString = "\(self.activeTaskCount) Tasks"
        }
        return "\(self.memberIds.count) Members | \(taskString)"
    }

    func toJson() -> Dictionary<String, AnyObject> {
        return [
            "name": self.name,
            "active_task_count": self.activeTaskCount,
            "logo": self.logo,
            "header_image": self.headerImage,
            "owners": self.ownerIds,
            "members": self.memberIds,
            "active_tasks": self.activeTaskCombinedIds
        ]
    }

    func getKey() -> String {
        return self.id
    }

    class func createFromSnapshot(snapshot: FDataSnapshot) -> DataEntity {
        return Team(id: snapshot.key, json: snapshot.value as Dictionary<String, AnyObject>)
    }

    class func createRef(id: String) -> Firebase {
        return Firebase(url: Global.FirebaseTeamsUrl).childByAppendingPath(id)
    }
}