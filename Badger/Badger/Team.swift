
@objc class Team: DataEntity {
    let id: String
    var name: String
    var activeTaskCount: Int
    var ownerIds: [String] = []
    var memberIds: [String] = []
    var logo: String
    var headerImage: String
    var activeTaskCombinedIds: [String] = []
    var ref: Firebase?

    init(id: String, name: String, activeTaskCount: Int)
    {
        self.id = id
        self.name = name
        self.activeTaskCount = activeTaskCount
        self.headerImage = "DefaultBackground"
        self.logo = ""
    }

    func getMeta() -> String {
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

    func getRef() -> Firebase {
        if let ref = self.ref {
            return ref
        }
        self.ref = Firebase(url: Global.FirebaseTeamsUrl).childByAppendingPath(self.id)
        return self.ref!
    }

    class func createFromSnapshot(snapshot: FDataSnapshot) -> DataEntity {
        let id = snapshot.key
        let name = Helpers.getString(snapshot.value, key: "name", backup: "No Name")
        let activeTaskCount = Helpers.getInt(snapshot.value, key: "active_task_count", backup: 0)
        let team = Team(id: id, name: name, activeTaskCount: activeTaskCount)

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

        if let taskData = Helpers.getDictionary(snapshot.value, key: "active_tasks")? {
            for (uid, value) in taskData {
                if let combinedTaskId = uid as? String {
                    team.activeTaskCombinedIds.append(combinedTaskId)
                }
            }
        }

        team.ref = snapshot.ref
        return team
    }    
}