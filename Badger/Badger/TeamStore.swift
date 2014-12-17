@objc protocol TeamObserver: class {
    func teamUpdated(newTeam: Team)
}

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
    private let dataStore: ObservableDataStore<Team>

    init() {
        self.dataStore = ObservableDataStore<Team>({ (team, observer:AnyObject) in
            if let teamObserver = observer as? TeamObserver {
                teamObserver.teamUpdated(team)
            }
        })
    }

    func getTeam(id: String, withBlock: Team -> ()) -> Team? {
        return self.dataStore.getEntity(self.createTeamRef(id), withBlock: withBlock)
    }

    func getTeams(ids: [String], withBlock: [Team] -> ()) {
        self.dataStore.getEntities(ids.map(self.createTeamRef), withBlock: withBlock)
    }

    func addObserver(observer: TeamObserver, id: String) {
        self.dataStore.addObserver(observer, ref: self.createTeamRef(id))
    }

    func addObserver(observer: TeamObserver, ids: [String]) {
        for id in ids {
            self.addObserver(observer, id: id)
        }
    }

    func removeObserver(observer: TeamObserver, id: String) {
        self.dataStore.removeObserver(observer, ref: self.createTeamRef(id))
    }

    class func addActiveTask(teamId: String, combinedId: String) {
        let childPath = "\(teamId)/active_tasks/\(combinedId)"
        Firebase(url: Global.FirebaseTeamsUrl).childByAppendingPath(childPath).setValue(true)
        TeamStore.adjustActiveTaskCount(teamId, delta: 1)
    }

    class func removeActiveTask(teamId: String, combinedId: String) {
        let childPath = "\(teamId)/active_tasks/\(combinedId)"
        Firebase(url: Global.FirebaseTeamsUrl).childByAppendingPath(childPath).removeValue()
        TeamStore.adjustActiveTaskCount(teamId, delta: -1)
    }

    class func adjustActiveTaskCount(id: String, delta: Int) {
        let ref = Firebase(url: Global.FirebaseTeamsUrl).childByAppendingPath("\(id)/active_task_count")
        FirebaseUtil.adjustValueForRef(ref, delta: delta)
    }

    private func createTeamRef(uid: String) -> Firebase {
        return self.ref.childByAppendingPath(uid)
    }
}