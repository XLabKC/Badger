import UIKit

class TeamProfileViewController: UITableViewController {
    private let cellHeights: [CGFloat] = [225.0, 100.0, 112.0]

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
                self.tableView.reloadData()
            })
        }
    }

    // TableViewController Overrides

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + (self.members.isEmpty ? 1 : self.members.count)
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.row >= self.cellHeights.count - 1) {
            return self.cellHeights.last!
        }
        return self.cellHeights[indexPath.row]
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            if self.headerCell == nil {
                self.headerCell = (tableView.dequeueReusableCellWithIdentifier("TeamHeaderCell") as TeamHeaderCell)
                if let team = self.team? {
                    self.headerCell!.setTeam(team)
                }
            }
            return self.headerCell!
        } else if indexPath.row == 1 {
            if self.controlCell == nil {
                self.controlCell = (tableView.dequeueReusableCellWithIdentifier("TeamProfileControlCell") as TeamProfileControlCell)
            }
            return self.controlCell!
        } else if self.isLoadingMembers {
            return tableView.dequeueReusableCellWithIdentifier("LoadingCell") as UITableViewCell
        } else if self.members.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier("NoMembersCell") as UITableViewCell
        }
        let index = indexPath.row - 2
        let cell = (tableView.dequeueReusableCellWithIdentifier("TeamMemberCell") as TeamMemberCell)
        cell.setUser(self.members[index])
        return cell
    }
}