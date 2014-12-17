import UIKit

class TeamProfileViewController: UITableViewController {
    private let cellHeights: [CGFloat] = [225.0, 100.0, 112.0]
    private let memberAltBackground = Color.colorize(0xF6F6F6, alpha: 1.0)

    private var team: Team?
    private var members = [User]()
    private var isLoadingMembers = true
    private var headerCell: TeamHeaderCell?
    private var controlCell: TeamProfileControlCell?

    private var teamObserver: FirebaseObserver<Team>?
    private var membersObserver: FirebaseListObserver<User>?

    @IBOutlet weak var menuButton: UIBarButtonItem!

    deinit {
        if let observer = self.teamObserver? {
            observer.dispose()
        }
        if let observer = self.membersObserver? {
            observer.dispose()
        }
    }

    override func viewDidLoad() {
        if let revealVC = self.revealViewController()? {
            self.menuButton.target = revealVC
            self.menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(revealVC.panGestureRecognizer())
        }

        // Register loading cell.
        let loadingCellNib = UINib(nibName: "LoadingCell", bundle: nil)
        self.tableView.registerNib(loadingCellNib, forCellReuseIdentifier: "LoadingCell")

        // Set up navigation bar.
        let label = Helpers.createTitleLabel("Team Profile")
        self.navigationItem.titleView = label

        super.viewDidLoad()
    }

    func setTeamId(id: String) {
        // Create member list observer.
        let usersRef = Firebase(url: Global.FirebaseUsersUrl)
        self.membersObserver = FirebaseListObserver<User>(ref: usersRef, onChanged: self.membersUpdated)
        self.membersObserver!.comparisonFunc = { (a, b) -> Bool in
            return a.firstName < b.firstName
        }

        // Create user observer.
        let teamRef = Team.createRef(id)
        self.teamObserver = FirebaseObserver<Team>(query: teamRef, withBlock: { team in
            self.team = team
            if let membersObserver = self.membersObserver? {
                membersObserver.setKeys(team.memberIds.keys.array)
            }

//            if !self.isViewLoaded() {
//                self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0))
//                self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 2))
//            }
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
        }
    }

    // TableViewController Overrides

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        default:
            return self.members.isEmpty ? 1 : self.members.count
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return self.cellHeights[indexPath.row]
        default:
            return self.cellHeights.last!
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                if self.headerCell == nil {
                    self.headerCell = (tableView.dequeueReusableCellWithIdentifier("TeamHeaderCell") as TeamHeaderCell)
                    if let team = self.team? {
                        self.headerCell!.setTeam(team)
                    }
                }
                return self.headerCell!
            }
            if self.controlCell == nil {
                self.controlCell = (tableView.dequeueReusableCellWithIdentifier("TeamProfileControlCell") as TeamProfileControlCell)
            }
            return self.controlCell!
        default:
            if self.isLoadingMembers {
                return tableView.dequeueReusableCellWithIdentifier("LoadingCell") as UITableViewCell
            } else if self.members.count == 0 {
                return tableView.dequeueReusableCellWithIdentifier("NoMembersCell") as UITableViewCell
            }
            let cell = (tableView.dequeueReusableCellWithIdentifier("TeamMemberCell") as TeamMemberCell)
            cell.setUser(self.members[indexPath.row])
            cell.backgroundColor = indexPath.row % 2 == 0 ? self.memberAltBackground : UIColor.whiteColor()
            return cell
        }
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TeamProfileUser" {
            let memberCell = sender as TeamMemberCell
            let vc = segue.destinationViewController as ProfileViewController
            vc.setUid(memberCell.getUser()!.uid)
        } else if segue.identifier == "TeamProfileNewTask" {
            let vc = segue.destinationViewController as TaskEditViewController
            if let team = self.team? {
                vc.setTeam(team)
            }
        }
    }
}
