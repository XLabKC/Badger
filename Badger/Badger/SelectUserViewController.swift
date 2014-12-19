import UIKit

protocol SelectUserDelegate: class {
    func selectedUser(user: User)
}

class SelectUserViewController: UITableViewController {

    private var users = [User]()
    private var teams: [Team]?
    weak var delegate: SelectUserDelegate?

    override func viewDidLoad() {
        self.navigationItem.titleView = Helpers.createTitleLabel("Select User")

        let userCellNib = UINib(nibName: "UserCell", bundle: nil)
        self.tableView.registerNib(userCellNib, forCellReuseIdentifier: "UserCell")

        let loadingCellNib = UINib(nibName: "LoadingCell", bundle: nil)
        self.tableView.registerNib(loadingCellNib, forCellReuseIdentifier: "LoadingCell")

        super.viewDidLoad()
    }

    func setTeams(teams: [Team]) {
        self.teams = teams
        UserStore.sharedInstance().getUsersByTeams(teams, withBlock: { users in
            self.users = users
            self.users.sort({ (a, b) -> Bool in
                return a.fullName < b.fullName
            })
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Left)
        })
    }

    // TableViewController Overrides

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.isEmpty ? 1 : users.count
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 72.0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.row == 0 && self.users.isEmpty) {
            return tableView.dequeueReusableCellWithIdentifier("LoadingCell") as LoadingCell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell") as UserCell
        cell.setTopBorder(indexPath.row == 0 ? .Full : .None)
        cell.setUid(self.users[indexPath.row].uid)
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let delegate = self.delegate? {
            delegate.selectedUser(self.users[indexPath.row])
        }
        self.navigationController?.popViewControllerAnimated(true)
    }

}