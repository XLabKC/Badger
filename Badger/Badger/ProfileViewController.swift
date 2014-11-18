import UIKit

class ProfileViewController: UITableViewController {

    let cellHeights: [CGFloat] = [225.0, 100.0, 72.0]
    var statusSliderCell: StatusSliderCell?
    var profileHeaderCell: ProfileHeaderCell?
    var statusHandle: UInt
    var statusRef: Firebase?
    var user: User?
    var tasks: [Task] = []

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    required init(coder aDecoder: NSCoder) {
        self.statusHandle = 0
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        tasks.append(Task(id: "i", author: "A", content: "A", priority: 1, open: true))
        super.viewDidLoad()
    }

    func setUid(uid: String) {
        let uidRef = Firebase(url: Global.FirebaseUsersUrl).childByAppendingPath(uid)
        uidRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            self.setUser(User.createUserFromSnapshot(snapshot))
        })
    }

    func setUser(user: User) {

    }

    // TableViewController Overrides

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + self.tasks.count
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.row >= self.cellHeights.count - 1) {
            return self.cellHeights.last!
        }
        return self.cellHeights[indexPath.row]
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            if self.profileHeaderCell == nil {
                self.profileHeaderCell = (tableView.dequeueReusableCellWithIdentifier("ProfileHeaderCell") as ProfileHeaderCell)
            }
            return self.profileHeaderCell!
        } else if indexPath.row == 1 {
            if self.statusSliderCell == nil {
                self.statusSliderCell = (tableView.dequeueReusableCellWithIdentifier("StatusSliderCell") as StatusSliderCell)
            }
            return self.statusSliderCell!
        }

        let cell = (tableView.dequeueReusableCellWithIdentifier("TaskCell") as TaskCell)
        return cell
    }
}
