
class TeamStore {

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

    class func deactivateTeam(team: Team) {
        if team.ownerIds[UserStore.sharedInstance().getAuthUid()] != true {
            return
        }
        team.ref.childByAppendingPath("active").setValue(false)
    }

    class func activateTeam(team: Team) {
        if team.ownerIds[UserStore.sharedInstance().getAuthUid()] != true {
            return
        }
        team.ref.childByAppendingPath("active").setValue(true)
    }
}