import UIKit

protocol SelectUserDelegate: class {
    func selectedUser(user: User)
}

class SelectUserViewController: UITableViewController {

    private var teamsObserver: FirebaseListObserver<Team>?
    private var usersObserver: FirebaseListObserver<User>?

    private var users = [User]()
    private var teamIds: [String]?
    weak var delegate: SelectUserDelegate?

    deinit {
        self.dispose()
    }

    override func viewDidLoad() {
        self.navigationItem.titleView = Helpers.createTitleLabel("Select User")

        let userCellNib = UINib(nibName: "UserCell", bundle: nil)
        self.tableView.registerNib(userCellNib, forCellReuseIdentifier: "UserCell")

        let loadingCellNib = UINib(nibName: "LoadingCell", bundle: nil)
        self.tableView.registerNib(loadingCellNib, forCellReuseIdentifier: "LoadingCell")

        super.viewDidLoad()
    }

    func setTeamIds(ids: [String]) {
        self.teamIds = ids
        self.dispose()
        let usersRef = Firebase(url: Global.FirebaseUsersUrl)
        self.usersObserver = FirebaseListObserver<User>(ref: usersRef, onChanged: self.usersChanged)
        self.usersObserver!.comparisonFunc = { (a, b) -> Bool in
            return a.fullName < b.fullName
        }

        let teamsRef = Firebase(url: Global.FirebaseTeamsUrl)
        self.teamsObserver = FirebaseListObserver<Team>(ref: teamsRef, keys: ids, onChanged: self.teamsChanged)
    }

    private func teamsChanged(teams: [Team]) {
        if let observer = self.usersObserver {
            var uids = [String: Bool]()
            for team in teams {
                for member in team.memberIds.keys {
                    uids[member] = true
                }
            }
            observer.setKeys(uids.keys.array)
        }
    }

    private func usersChanged(users: [User]) {
        let oldUsers = self.users
        self.users = users

        if !self.isViewLoaded() {
            return
        }

        if oldUsers.isEmpty {
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
        } else {
            var updates = Helpers.diffArrays(oldUsers, end: users, section: 0, compare: { (a, b) -> Bool in
                return a.uid == b.uid
            })
            if !updates.inserts.isEmpty || !updates.deletes.isEmpty {
                self.tableView.beginUpdates()
                self.tableView.deleteRowsAtIndexPaths(updates.deletes, withRowAnimation: .Fade)
                self.tableView.insertRowsAtIndexPaths(updates.inserts, withRowAnimation: .Fade)
                self.tableView.endUpdates()
            }
            for (index, user) in enumerate(users) {
                let indexPath = NSIndexPath(forRow: index, inSection: 0)
                if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? UserCell {
                    cell.setTopBorder(index == 0 ? .Full : .None)
                    cell.setUid(user.uid)
                }
            }
        }
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
            return tableView.dequeueReusableCellWithIdentifier("LoadingCell") as! LoadingCell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell") as! UserCell
        cell.arrowImage.hidden = true
        cell.setTopBorder(indexPath.row == 0 ? .Full : .None)
        cell.setUid(self.users[indexPath.row].uid)
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let delegate = self.delegate {
            delegate.selectedUser(self.users[indexPath.row])
        }
        self.navigationController?.popViewControllerAnimated(true)
    }

    private func dispose() {
        if let observer = self.teamsObserver {
            observer.dispose()
        }
        if let observer = self.usersObserver {
            observer.dispose()
        }
    }
}