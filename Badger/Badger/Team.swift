class Team {
    let id: String
    var name: String
    var activeTasks: Int
    var ownerIds: [String] = []
    var memberIds: [String] = []
    var logo: String
    var headerImage: String
    //    var taskIds: [String] = []
    var ref: Firebase?

    init(id: String, name: String, activeTasks: Int)
    {
        self.id = id
        self.name = name
        self.activeTasks = activeTasks
        self.headerImage = "DefaultBackground.png"
        self.logo = ""
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
        team.ref = snapshot.ref
        return team
    }
}