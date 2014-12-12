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

    func adjustActiveTaskCount(id: String, delta: Int) {
        let activeRef = self.ref.childByAppendingPath(id).childByAppendingPath("active_tasks")
        FirebaseAsync.adjustValueForRef(activeRef, delta: delta)
    }

    func addObserver(observer: UserObserver, id: String) {
        self.dataStore.addObserver(observer, ref: self.createTeamRef(id))
    }

    func removeObserver(observer: UserObserver, id: String) {
        self.dataStore.removeObserver(observer, ref: self.createTeamRef(id))
    }

    private func createTeamRef(uid: String) -> Firebase {
        return self.ref.childByAppendingPath(uid)
    }
}