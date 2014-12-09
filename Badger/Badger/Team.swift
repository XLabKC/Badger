class Team {
    let id: String
    var name: String
    var activeTasks: Int
    var ownerIds: [String] = []
    var memberIds: [String] = []
    var logo: String
    var headerImage: String
    var combinedTaskIds: [String] = []
    var ref: Firebase?

    init(id: String, name: String, activeTasks: Int)
    {
        self.id = id
        self.name = name
        self.activeTasks = activeTasks
        self.headerImage = "DefaultBackground"
        self.logo = ""
    }

    func getMeta() -> String {
        var taskString: String
        switch self.activeTasks {
        case 0:
            taskString = "No Tasks"
        case 1:
            taskString = "1 Task"
        default:
            taskString = "\(self.activeTasks) Tasks"
        }
        return "\(self.memberIds.count) Members | \(taskString)"
    }

    class func createTeamFromSnapshot(snapshot: FDataSnapshot) -> Team {
        let id = snapshot.key
        let name = Helpers.getString(snapshot.value, key: "name", backup: "No Name")
        let activeTasks = Helpers.getInt(snapshot.value, key: "active_tasks", backup: 0)
        let team = Team(id: id, name: name, activeTasks: activeTasks)

        if let ownerData = Helpers.getDictionary(snapshot.value, key: "owners")? {
            for (uid, value) in ownerData {
                if let uidString = uid as? String {
                    team.ownerIds.append(uidString)
                }
            }
        }

        if let memberData = Helpers.getDictionary(snapshot.value, key: "members")? {
            for (uid, value) in memberData {
                if let uidString = uid as? String {
                    team.memberIds.append(uidString)
                }
            }
        }

        if let taskData = Helpers.getDictionary(snapshot.value, key: "tasks")? {
            for (uid, value) in taskData {
                if let combinedTaskId = uid as? String {
                    team.combinedTaskIds.append(combinedTaskId)
                }
            }
        }

        team.ref = snapshot.ref
        return team
    }

    class func separateUidAndTaskId(taskCombinedId: String) -> (uid: String, taskId: String) {
        let comp = taskCombinedId.componentsSeparatedByString("_")
        return (uid: comp[0], taskId: comp[1])
    }
}