import UIKit

protocol SelectTeamDelegate: class {
    func selectedTeam(team: Team)
}

class SelectTeamViewController: UITableViewController {

    private var teamsObserver: FirebaseListObserver<Team>?
    private var userObserver: FirebaseObserver<User>?

    private var teams: [Team] = []
    private var user: User?
    private var uid: String?

    weak var delegate: SelectTeamDelegate?

    deinit {
        self.dispose()
    }

    override func viewDidLoad() {
        self.navigationItem.titleView = Helpers.createTitleLabel("Select User")

        let teamCellNib = UINib(nibName: "TeamCell", bundle: nil)
        self.tableView.registerNib(teamCellNib, forCellReuseIdentifier: "TeamCell")

        let loadingCellNib = UINib(nibName: "LoadingCell", bundle: nil)
        self.tableView.registerNib(loadingCellNib, forCellReuseIdentifier: "LoadingCell")

        super.viewDidLoad()
    }

    func setUid(uid: String) {
        self.dispose()

        let teamsRef = Firebase(url: Global.FirebaseTeamsUrl)
        self.teamsObserver = FirebaseListObserver<Team>(ref: teamsRef, onChanged: self.teamsChanged)
        self.teamsObserver!.comparisonFunc = { (a, b) -> Bool in
            return a.name < b.name
        }

        let userRef = User.createRef(uid)
        self.userObserver = FirebaseObserver<User>(query: userRef, withBlock: { user in
            self.user = user
            let authUser = UserStore.sharedInstance().getAuthUser()

            // Filter out teams that the auth user is not a member of.
            var newIds: [String: Bool] = [:]
            for id in user.teamIds.keys {
                if authUser.teamIds[id] != nil {
                    newIds[id] = true
                }
            }
            if let observer = self.teamsObserver? {
                observer.setKeys(newIds.keys.array)
            }
        })
    }

    private func teamsChanged(teams: [Team]) {
        let oldTeams = self.teams
        self.teams = teams

        if !self.isViewLoaded() {
            return
        }

        if oldTeams.isEmpty {
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Left)
        } else {
            var updates = Helpers.diffArrays(oldTeams, end: teams, section: 0, compare: { (a, b) -> Bool in
                return a.id == b.id
            })
            if !updates.inserts.isEmpty || !updates.deletes.isEmpty {
                self.tableView.beginUpdates()
                self.tableView.deleteRowsAtIndexPaths(updates.deletes, withRowAnimation: .Left)
                self.tableView.insertRowsAtIndexPaths(updates.inserts, withRowAnimation: .Left)
                self.tableView.endUpdates()
            }
        }
    }

    // TableViewController Overrides

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.teams.isEmpty ? 1 : self.teams.count
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 72.0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.row == 0 && self.teams.isEmpty) {
            return tableView.dequeueReusableCellWithIdentifier("LoadingCell") as LoadingCell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("TeamCell") as TeamCell
        cell.setTopBorder(indexPath.row == 0 ? .Full : .None)
        cell.setTeam(self.teams[indexPath.row])
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let delegate = self.delegate? {
            delegate.selectedTeam(self.teams[indexPath.row])
        }
        self.navigationController?.popViewControllerAnimated(true)
    }

    private func dispose() {
        if let observer = self.userObserver? {
            observer.dispose()
        }
        if let observer = self.teamsObserver? {
            observer.dispose()
        }
    }
}