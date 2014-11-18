import UIKit

class HomeViewController: UITableViewController, UIGestureRecognizerDelegate, ProfileTableCellDelegate {

    let profileTableCell: ProfileTableCell
    var uidRef: Firebase?
    var user: User?
    var otherUsers: [String: User]

    required init(coder aDecoder: NSCoder) {
        self.otherUsers = [:]
        let profileNib = UINib(nibName: "ProfileTableCell", bundle: nil)
        self.profileTableCell = profileNib.instantiateWithOwner(nil, options: nil)[0] as ProfileTableCell
        self.profileTableCell.setup(true)
        super.init(coder: aDecoder)

        self.profileTableCell.delegate = self
    }

    override func viewDidLoad() {
        let userTableNib = UINib(nibName: "UserTableCell", bundle: nil)
        self.tableView.registerNib(userTableNib, forCellReuseIdentifier: "UserTableCell")
        let ref = Firebase(url: Global.FirebaseUsersUrl)
        self.uidRef = ref.childByAppendingPath(ref.authData.uid)
        self.loadUser()

        super.viewDidLoad()
    }

    // Table View Delegates

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            // Screen height minus the header height
            return UIScreen.mainScreen().bounds.size.height - 20
        }
        return 44
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            return profileTableCell
        }

        let cell = tableView.dequeueReusableCellWithIdentifier("UserTableCell", forIndexPath: indexPath) as UserTableCell

        if let user = self.user? {
            self.loadUserForCell(user.following[indexPath.row - 1], cell: cell)
        }

        return cell
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let user = self.user? {
            return user.following.count + 1
        }
        return 1
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row != 0) {
            // Handle navigating to other people's pages
            if let user = self.user {
                self.performSegueWithIdentifier("SHOW_PROFILE", sender: user.following[indexPath.row - 1])
            }
        }
    }

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    // ProfileTableCellDelegate

    func updateUserStatus(user: User, status: String) {
        user.uidRef!.updateChildValues(["status": status])
    }

    func showMessagesForUser(user: User) {
        self.performSegueWithIdentifier("HOME_SHOW_MESSAGES", sender: user)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.destinationViewController is ProfileViewController && sender is String {
            let vc = segue.destinationViewController as ProfileViewController
            let uid = sender as String
            if let user = self.otherUsers[uid] {
                vc.setUser(user)
            } else {
                vc.setUid(uid)
            }
        } else if segue.destinationViewController is ListMessagesViewController {
            let vc = segue.destinationViewController as ListMessagesViewController
            if let user = self.user? {
                vc.setUser(user)
            }
        }
    }

    private func loadUser() {
        self.uidRef!.observeSingleEventOfType(.Value, withBlock: { snapshot in
            self.user = User.createUserFromSnapshot(snapshot)
            self.profileTableCell.setUser(self.user!)
            self.tableView.reloadData()
        })
    }

    private func loadUserForCell(uid:String, cell:UserTableCell) {
        if let user = self.otherUsers[uid] {
            cell.setUser(user)
            return
        }

        let uidRef = Firebase(url: Global.FirebaseUsersUrl).childByAppendingPath(uid)
        uidRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            let user = User.createUserFromSnapshot(snapshot)
            cell.setUser(user)
            self.otherUsers[uid] = user
        })
    }
}
