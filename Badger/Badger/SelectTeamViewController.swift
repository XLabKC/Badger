import UIKit

protocol SelectTeamDelegate: class {
    func selectedTeam(team: Team)
}

class SelectTeamViewController: UITableViewController {
    private var user: User?
    private var teams = [Team]()
    weak var delegate: SelectTeamDelegate?

    override func viewDidLoad() {
        self.navigationItem.titleView = Helpers.createTitleLabel("Select User")

        let teamCellNib = UINib(nibName: "TeamCell", bundle: nil)
        self.tableView.registerNib(teamCellNib, forCellReuseIdentifier: "TeamCell")

        let loadingCellNib = UINib(nibName: "LoadingCell", bundle: nil)
        self.tableView.registerNib(loadingCellNib, forCellReuseIdentifier: "LoadingCell")

        super.viewDidLoad()
    }

    func setUser(user: User) {
        self.user = user
        UserStore.sharedInstance().getAuthUser({ authUser in
            TeamStore.sharedInstance().getTeams(self.user!.teamIds.keys.array, withBlock: { teams in
                for team in teams {
                    if authUser.teamIds[team.id] != nil {
                        self.teams.append(team)
                    }
                }
                self.teams.sort({ (a, b) -> Bool in
                    return a.name < b.name
                })
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Left)
            })
        })

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
    
}