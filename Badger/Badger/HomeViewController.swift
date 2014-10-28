import UIKit

class HomeViewController: UITableViewController, UIGestureRecognizerDelegate {

    let profileTableCell: ProfileTableCell
    let uidRef: Firebase

    required init(coder aDecoder: NSCoder) {
        uidRef = Firebase(url: Global.FirebaseUsersUrl).childByAppendingPath(Global.AuthData!.uid)
        let nib = UINib(nibName: "ProfileTableCell", bundle: nil)
        profileTableCell = nib.instantiateWithOwner(nil, options: nil)[0] as ProfileTableCell
        profileTableCell.setup(Global.AuthData!.uid)
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "UserTableCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "UserTableCell")
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
        let cell = tableView.dequeueReusableCellWithIdentifier("UserTableCell", forIndexPath: indexPath) as UITableViewCell
        return cell
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row != 0) {
            // Handle navigating to other people's pages
        }
    }

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
