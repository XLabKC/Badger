import UIKit

class TeamEditViewController: UITableViewController {
    private let headerCellHeight: CGFloat = 40.0
    private let contentCellHeight: CGFloat = 72.0

    private var team: Team?
    private var teamObserver: FirebaseObserver<Team>?
    private var members = [User]()
    private var membersObserver: FirebaseListObserver<User>?
    private var isLoadingMembers = true

    private var rightButton = UIBarButtonItem(title: "Delete", style: .Plain, target: nil, action: "deleteTeam")
    private var isConfirmingDelete = false
    private var teamInfoCell: EditTeamInfoCell?

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.rightButton.target = self
        self.rightButton.tintColor = Color.colorize(0xFF5C78, alpha: 1.0)
    }

    deinit {
        if let observer = self.teamObserver? {
            observer.dispose()
        }
        if let observer = self.membersObserver? {
            observer.dispose()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register loading cell.
        let loadingCellNib = UINib(nibName: "LoadingCell", bundle: nil)
        self.tableView.registerNib(loadingCellNib, forCellReuseIdentifier: "LoadingCell")

        // Register edit team info cell.
        let teamInfoCellNib = UINib(nibName: "EditTeamInfoCell", bundle: nil)
        self.tableView.registerNib(teamInfoCellNib, forCellReuseIdentifier: "EditTeamInfoCell")

        // Set up navigation bar.
        self.navigationItem.titleView = Helpers.createTitleLabel("Edit Team")
        self.navigationItem.rightBarButtonItem = rightButton

        // Register loading cell.
        let headerCellNib = UINib(nibName: "HeaderCell", bundle: nil)
        self.tableView.registerNib(headerCellNib, forCellReuseIdentifier: "HeaderCell")
    }

    func setTeamId(teamId: String) {
        // Load the team members.
        let usersRef = Firebase(url: Global.FirebaseUsersUrl)
        self.membersObserver = FirebaseListObserver<User>(ref: usersRef, onChanged: self.membersUpdated)
        self.membersObserver!.comparisonFunc = { (a, b) -> Bool in
            return a.fullName < b.fullName
        }

        let teamRef = Team.createRef(teamId)
        teamRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            let team = Team.createFromSnapshot(snapshot) as Team
            if let membersObserver = self.membersObserver? {
                membersObserver.setKeys(self.team!.memberIds.keys.array)
            }
            self.team = team
        })
    }

    private func membersUpdated(members: [User]) {
        let oldMembers = self.members
        self.members = members
        self.isLoadingMembers = false

        if !self.isViewLoaded() {
            return
        }

        if oldMembers.isEmpty {
            self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Left)
        } else {
            var updates = Helpers.diffArrays(oldMembers, end: members, section: 1, compare: { (a, b) -> Bool in
                return a.uid == b.uid
            })
            if !updates.inserts.isEmpty || !updates.deletes.isEmpty {
                self.tableView.beginUpdates()
                self.tableView.deleteRowsAtIndexPaths(updates.deletes, withRowAnimation: .Left)
                self.tableView.insertRowsAtIndexPaths(updates.inserts, withRowAnimation: .Left)
                self.tableView.endUpdates()
            }
            // Loop through and update the users for each cell.
            for (index, member) in enumerate(members) {
                let indexPath = NSIndexPath(forRow: index, inSection: 1)
                if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? TeamMemberCell {
                    cell.setUser(member)
                }
            }
        }
    }

    // TableViewController Overrides

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Header + Name + Logos
        return  section == 0 ? 1 : self.members.count
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if let cell = self.teamInfoCell? {
                return cell
            }
            self.teamInfoCell = tableView.dequeueReusableCellWithIdentifier("EditTeamInfoCell") as? EditTeamInfoCell
            if let team = self.team? {
                self.teamInfoCell!.name = team.name
            }
            return self.teamInfoCell!
        }

        let cell = tableView.dequeueReusableCellWithIdentifier("TeamEditMemberCell") as TeamEditMemberCell
        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 220
        }
        return 72
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    func saveTeam() {

    }

    func deleteTeam() {
        if self.isConfirmingDelete {
            if let team = self.team? {
                TeamStore.deactivateTeam(team)
                self.navigationController?.popViewControllerAnimated(true)
            }
        } else {
            self.rightButton.title = "Confirm"
            self.isConfirmingDelete = true
            NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "stopConfirmingDelete", userInfo: nil, repeats: false)
        }
    }

    func stopConfirmingDelete() {
        self.isConfirmingDelete = false
        self.rightButton.title = "Delete"
    }
}
