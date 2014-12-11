
class TeamStore {
    // Accesses the singleton.
    class func sharedInstance() -> TeamStore {
        struct Static {
            static var instance: TeamStore?
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
            Static.instance = TeamStore()
        }
        return Static.instance!
    }

    private let ref = Firebase(url: Global.FirebaseTeamsUrl)

    func getTeam(id: String, withBlock: Team -> ()) -> Team? {
        let teamRef = self.ref.childByAppendingPath(id)
        teamRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            withBlock(Team.createTeamFromSnapshot(snapshot))
        })
        return nil
    }

    func getTeams(ids: [String], withBlock: [Team] -> ()) {
        if ids.isEmpty {
            withBlock([])
            return
        }
        var teams = [Team]()
        let barrier = Barrier(count: ids.count, done: { _ in
            withBlock(teams)
        })
        for id in ids {
            self.getTeam(id, withBlock: { team in
                teams.append(team)
                barrier.decrement()
            })
        }
    }

    func adjustActiveTaskCount(id: String, delta: Int) {
        let activeRef = self.ref.childByAppendingPath(id).childByAppendingPath("active_tasks")
        FirebaseAsync.adjustValueForRef(activeRef, delta: delta)
    }
}