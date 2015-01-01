import UIKit

class StatusViewController: UITableViewController {

    private var userObserver: FirebaseObserver<User>?
    private var followingObserver: FirebaseListObserver<User>?

    private var authUser: User?
    private var following = [User]()

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadData()
    }

    deinit {
        if let observer = self.followingObserver? {
            observer.dispose()
        }
        if let observer = self.userObserver? {
            observer.dispose()
        }
    }

    private func loadData() {
        // Create team list observer.
        let usersRef = Firebase(url: Global.FirebaseUsersUrl)
        self.followingObserver = FirebaseListObserver<User>(ref: usersRef, onChanged: self.followingUpdated)
        self.followingObserver!.comparisonFunc = { (a, b) -> Bool in
            return a.firstName < b.firstName
        }

        // Create user observer.
        let userRef = User.createRef(UserStore.sharedInstance().getAuthUid())
        self.userObserver = FirebaseObserver<User>(query: userRef, withBlock: { user in
            self.authUser = user
            if let observer = self.followingObserver? {
                observer.setKeys(user.followingIds.keys.array)
            }
        })
    }

    private func followingUpdated(following: [User]) {
        let oldFollowing = self.following
        self.following = following

        // Check to make sure the view is loaded before reloading table cells.
        if !self.isViewLoaded() {
            return
        }

        if oldFollowing.isEmpty {
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Left)
        } else {
            // Determine what updates need to be made.
            var updates = Helpers.diffArrays(oldFollowing, end: following, section: 0, compare: { (a, b) -> Bool in
                return a.uid == b.uid
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
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.row == 0 ? 45.0 : 70.0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.following.count + 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return tableView.dequeueReusableCellWithIdentifier("StatusCloseCell") as UITableViewCell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("StatusCell") as StatusCell
        cell.setUser(self.following[indexPath.row - 1])
        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "StatusProfile" {
            if let navVC = segue.destinationViewController as? UINavigationController {
                if let profileVC = navVC.topViewController as? ProfileViewController {
                    if let cell = sender as? StatusCell {
                        profileVC.setUid(cell.getUser()!.uid)
                    }
                }
            }
        }
    }

}
