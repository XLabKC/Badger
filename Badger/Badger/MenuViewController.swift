import UIKit

class MenuViewController: UITableViewController, HeaderCellDelegate {

    private let logoCellHeight: CGFloat = 46.0
    private let contentCellHeight: CGFloat = 72.0
    private let headerCellHeight: CGFloat = 40.0
    private let settingCellHeight: CGFloat = 144.0
    private let minFooterCellHeight: CGFloat = 72.0

    private var userObserver: FirebaseObserver<User>?
    private var teamsObserver: FirebaseListObserver<Team>?
    private var user: User?
    private var teams = [Team]()

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadData()
    }

    deinit {
        if let observer = self.teamsObserver {
            observer.dispose()
        }
        if let observer = self.userObserver {
            observer.dispose()
        }
    }

    override func viewDidLoad() {
        let userTableNib = UINib(nibName: "HeaderCell", bundle: nil)
        self.tableView.registerNib(userTableNib, forCellReuseIdentifier: "HeaderCell")
    }



    // TableViewController Overrides
    func loadData() {
        // Create team list observer.
        let teamsRef = Firebase(url: Global.FirebaseTeamsUrl)
        self.teamsObserver = FirebaseListObserver<Team>(ref: teamsRef, onChanged: self.teamsUpdated)
        self.teamsObserver!.comparisonFunc = { (a, b) -> Bool in
            return a.name < b.name
        }

        // Create user observer.
        let userRef = User.createRef(UserStore.sharedInstance().getAuthUid())
        self.userObserver = FirebaseObserver<User>(query: userRef, withBlock: { user in
            self.user = user
            self.teamsObserver?.setKeys(user.teamIds.keys.array)

            if self.isViewLoaded() {
                // Update the profile view.
                if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) {
                    if let profileCell = cell as? MyProfileCell {
                        profileCell.setUser(user)
                    }
                }
            }
        })
    }

    private func teamsUpdated(teams: [Team]) {
        let oldTeams = self.teams
        self.teams = teams

        // Check to make sure the view is loaded before reloading table cells.
        if !self.isViewLoaded() {
            return
        }

        if oldTeams.isEmpty {
            self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Left)
        } else {
            // Determine what updates need to be made.
            var updates = Helpers.diffArrays(oldTeams, end: teams, section: 1, compare: { (a, b) -> Bool in
                return a.id == b.id
            })
            // Apply the updates to the table view.
            self.tableView.beginUpdates()
            if !updates.deletes.isEmpty {
                self.tableView.deleteRowsAtIndexPaths(updates.deletes, withRowAnimation: .Left)
            }
            if !updates.inserts.isEmpty {
                self.tableView.insertRowsAtIndexPaths(updates.inserts, withRowAnimation: .Left)
            }
            self.tableView.endUpdates()

            // Update each table cell.
            for (index, team) in enumerate(teams) {
                let indexPath = NSIndexPath(forRow: index, inSection: 1)
                if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? MenuTeamCell {
                    cell.setTeam(team)
                }
            }
        }
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            // Logo + Header + My Profile + Header
            return 4
        case 1:
            // Teams
            return self.teams.isEmpty ? 1 : self.teams.count
        default:
            // Header + Settings + Logo
            return 3
        }
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                return self.logoCellHeight
            case 2:
                return self.contentCellHeight
            default:
                return self.headerCellHeight
            }
        case 1:
            return self.contentCellHeight
        default:
            switch indexPath.row {
            case 0:
                return self.headerCellHeight
            case 1:
                return self.settingCellHeight
            default:
                let teamCount = self.teams.isEmpty ? 1 : self.teams.count
                let contentCellsHeight = self.contentCellHeight * CGFloat(teamCount + 1)
                let headerCellsHeight = self.headerCellHeight * 3
                let contentHeight = self.logoCellHeight + contentCellsHeight + headerCellsHeight + self.settingCellHeight
                var height = tableView.frame.height - contentHeight - 20
                return height < self.minFooterCellHeight ? self.minFooterCellHeight : height
            }
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                return tableView.dequeueReusableCellWithIdentifier("LogoCell") as! UITableViewCell
            case 1, 3:
                let cell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! HeaderCell
                cell.labelColor = Color.colorize(0x929292, alpha: 1)
                cell.title = indexPath.row == 1 ? "MY PROFILE" : "MY TEAMS"
                if indexPath.row == 3 {
                    cell.delegate = self
                    cell.buttonText = "NEW TEAM"
                    cell.showButton = true
                    cell.buttonInset = -68
                }
                return cell
            default:
                let cell = tableView.dequeueReusableCellWithIdentifier("MyProfileCell") as! MyProfileCell
                cell.setUser(UserStore.sharedInstance().getAuthUser())
                return cell
            }
        case 1:
            if self.teams.isEmpty {
                return tableView.dequeueReusableCellWithIdentifier("MenuNoTeamsCell") as! UITableViewCell
            }
            let cell = tableView.dequeueReusableCellWithIdentifier("MenuTeamCell") as! MenuTeamCell
            cell.setTeam(self.teams[indexPath.row])
            cell.setTopBorder(indexPath.row == 0 ? .Full : .None)
            return cell
        default:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! HeaderCell
                cell.labelColor = Color.colorize(0x929292, alpha: 1)
                cell.title = "SETTINGS"
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("MenuSettingsCell") as! MenuSettingsCell
                cell.setUser(UserStore.sharedInstance().getAuthUser())
                return cell
            default:
                return tableView.dequeueReusableCellWithIdentifier("MenuFooterCell") as! UITableViewCell
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "MenuMyProfile" {
            let nav = segue.destinationViewController as! UINavigationController
            let vc = nav.childViewControllers.first as! ProfileViewController
            vc.setUid(UserStore.sharedInstance().getAuthUid())
        } else if segue.identifier == "MenuTeamProfile" {
            let teamCell = sender as! MenuTeamCell
            let team = teamCell.getTeam()!
            let nav = segue.destinationViewController as! UINavigationController
            let vc = nav.topViewController as! TeamProfileViewController
            vc.setTeamId(team.id)
        }
    }

    func headerCellButtonPressed(headerCell: HeaderCell) {
        
    }
}
