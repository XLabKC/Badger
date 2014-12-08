import UIKit

class TeamProfileViewController: UITableViewController {
    private let cellHeights: [CGFloat] = [225.0, 100.0, 112.0]
    private let memberAltBackground = Color.colorize(0xF6F6F6, alpha: 1.0)

    private var team: Team?
    private var members = [User]()
    private var isLoadingMembers = true
    private var headerCell: TeamHeaderCell?
    private var controlCell: TeamProfileControlCell?

    @IBOutlet weak var menuButton: UIBarButtonItem!

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
        if self.team != nil {
            self.loadTeamProfile()
        }
    }


    func setTeam(team: Team) {
        self.team = team
        self.isLoadingMembers = true

        // Update table cells if they have already initialized.
        if let headerCell = self.headerCell? {
            headerCell.setTeam(team)
        }
        if (self.isViewLoaded()) {
            self.loadTeamProfile()
        }
    }

    private func loadTeamProfile() {
        if let team = self.team? {
            // Prefetch members.
            UserStore.sharedInstance().getUsers(team.memberIds, withBlock: { users in
                self.members = users
                self.isLoadingMembers = false
                self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Left)
            })
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
            vc.setUser(memberCell.getUser()!)
        }
    }
}
