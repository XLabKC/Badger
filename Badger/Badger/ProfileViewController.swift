import UIKit

class ProfileViewController: UITableViewController {

    let cellHeights: [CGFloat] = [225.0, 100.0, 72.0]

    var handle: UInt = 0
    var tasks = [Task]()
    var isLoadingTasks = true

    var statusSliderCell: StatusSliderCell?
    var profileHeaderCell: ProfileHeaderCell?
    var ref: Firebase?
    var user: User?
    var taskBarrier: Barrier?

    @IBOutlet weak var menuButton: UIBarButtonItem!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

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
        let label = UILabel(frame: CGRectMake(0, 0, 100, 30))
        label.backgroundColor = UIColor.clearColor()
        label.font = UIFont(name: "OpenSans", size: 17.0)
        label.textAlignment = .Center
        label.textColor = Colors.NavHeaderTitle
        label.text = "My Profile"
        self.navigationItem.titleView = label

        UIFont.familyNames()

//        tasks.append(Task(id: "i", author: "A", title: "Fake Task", content: "Some content goes here", priority: .Medium, active: true, timestamp: NSDate()))

        super.viewDidLoad()
    }

    func setUid(uid: String) {
        UserStore.sharedInstance().getUser(uid, withBlock: self.setUser)
    }

    func setUser(user: User) {
        self.user = user
        self.isLoadingTasks = true

        // Update table cells if they have already initialized.
        if let profileHeader = self.profileHeaderCell? {
            profileHeader.setUser(user)
        }
        if let statusSlider = self.statusSliderCell? {
            statusSlider.setUser(user)
        }

        // Load the users tasks.
        let ref = Firebase(url: Global.FirebaseTasksUrl).childByAppendingPath(user.uid)
        FirebaseAsync.observeEventType(ref, eventType: .ChildAdded, forEach: { (snapshot, isNew) -> () in
            if !isNew {
                self.tasks.append(Task.createTaskFromSnapshot(snapshot))
            }
        }) { () -> () in
            // On completion, prefetch users before loading table cells.
            var uids = [String]() // Figure out how to set capacity
            for task in self.tasks {
                uids.append(task.author)
            }
            UserStore.sharedInstance().prefetchUsers(uids, withBlock: { () -> () in
                self.isLoadingTasks = false
                self.tableView.reloadData()
            })
        }

//        for family in UIFont.familyNames() as [String] {
//            for font in UIFont.fontNamesForFamilyName(family) {
//                println(font)
//            }
//        }
    }

    // TableViewController Overrides

//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + (self.tasks.isEmpty ? 1 : self.tasks.count)
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
        } else if self.isLoadingTasks {
            return tableView.dequeueReusableCellWithIdentifier("LoadingCell") as UITableViewCell
        } else if self.tasks.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier("NoTasksCell") as UITableViewCell
        }

        // Reverse the tasks to be in decending chronological order.
        let index = self.tasks.count - 1 - (indexPath.row - 2)
        let cell = (tableView.dequeueReusableCellWithIdentifier("TaskCell") as TaskCell)
        cell.setTask(self.tasks[index])
        return cell
    }
}
