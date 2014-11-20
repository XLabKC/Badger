import UIKit

class ProfileViewController: UITableViewController {

    let cellHeights: [CGFloat] = [225.0, 100.0, 72.0]
    var statusSliderCell: StatusSliderCell?
    var profileHeaderCell: ProfileHeaderCell?
    var statusHandle: UInt
    var ref: Firebase?
    var handle: UInt = 0
    var user: User?
    var tasks: [Task] = []

    @IBOutlet weak var menuButton: UIBarButtonItem!

    required init(coder aDecoder: NSCoder) {
        self.statusHandle = 0
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        if let revealVC = self.revealViewController()? {
            self.menuButton.target = revealVC
            self.menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(revealVC.panGestureRecognizer())
        }

//        tasks.append(Task(id: "i", author: "A", title: "Fake Task", content: "A", priority: .Medium, open: true))
//        tasks.append(Task(id: "i", author: "A", title: "Fake Task 2", content: "A", priority: .Low, open: true))
//        tasks.append(Task(id: "i", author: "A", title: "Fake Task 2", content: "A", priority: .Low, open: true))
//        tasks.append(Task(id: "i", author: "A", title: "Fake Task 2", content: "A", priority: .Low, open: true))
//        tasks.append(Task(id: "i", author: "A", title: "Fake Task 2", content: "A", priority: .Low, open: true))

        super.viewDidLoad()
    }

    func setUid(uid: String) {
        UserStore.sharedInstance().getUser(uid, withBlock: self.setUser)
    }

    func setUser(user: User) {
        self.user = user

        // Update table cells if they have already initialized.
        if let profileHeader = self.profileHeaderCell? {
            profileHeader.setUser(user)
        }
        if let statusSlider = self.statusSliderCell? {
            statusSlider.setUser(user)
        }
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
                if let user = self.user? {
                    self.profileHeaderCell!.setUser(user)
                }
            }
            return self.profileHeaderCell!
        } else if indexPath.row == 1 {
            if self.statusSliderCell == nil {
                self.statusSliderCell = (tableView.dequeueReusableCellWithIdentifier("StatusSliderCell") as StatusSliderCell)
                if let user = self.user? {
                    self.statusSliderCell!.setUser(user)
                }
            }
            return self.statusSliderCell!
        }

        let cell = (tableView.dequeueReusableCellWithIdentifier("TaskCell") as TaskCell)
        cell.setTask(self.tasks[self.tasks.count - 1 - (indexPath.row - 2)])
        return cell
    }
}
