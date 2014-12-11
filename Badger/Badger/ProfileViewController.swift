import UIKit

class ProfileViewController: UITableViewController {

    private let cellHeights: [CGFloat] = [225.0, 100.0, 72.0]
    private let titleLabel = Helpers.createTitleLabel("My Profile")

    private var tasks = [Task]()
    private var isLoadingTasks = true
    private var statusSliderCell: StatusSliderCell?
    private var profileHeaderCell: ProfileHeaderCell?
    private var profileControlsCell: ProfileControlsCell?
    private var user: User?

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        if let nav = self.navigationController? {
            if nav.viewControllers.first as? ProfileViewController == self {
                if let revealVC = self.revealViewController()? {
                    var button = UIBarButtonItem(image: UIImage(named: "MenuIcon"), style: .Plain, target: revealVC, action: "revealToggle:")
                    button.tintColor = Color.colorize(0x929292, alpha: 1.0)
                    self.navigationItem.leftBarButtonItem = button
                    self.view.addGestureRecognizer(revealVC.panGestureRecognizer())
                }
            }
        }

        // Register loading cell.
        let loadingCellNib = UINib(nibName: "LoadingCell", bundle: nil)
        self.tableView.registerNib(loadingCellNib, forCellReuseIdentifier: "LoadingCell")

        // Set up navigation bar.
        self.navigationItem.titleView = self.titleLabel

//        tasks.append(Task(id: "i", author: "A", title: "Fake Task", content: "Some content goes here", priority: .Medium, active: true, timestamp: NSDate()))

        super.viewDidLoad()
        if self.user != nil {
            self.loadUserProfile()
        }
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
        if self.isViewLoaded() {
            loadUserProfile()
        }

//        for family in UIFont.familyNames() as [String] {
//            for font in UIFont.fontNamesForFamilyName(family) {
//                println(font)
//            }
//        }
    }

    private func loadUserProfile() {
        // Load the users tasks.
        if let user = self.user? {
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
                    UserStore.sharedInstance().getUsers(uids, withBlock: { _ in
                        self.isLoadingTasks = false
                        self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Left)
                    })
            }
            if UserStore.sharedInstance().isAuthUser(user.uid) {
                self.titleLabel.text = "My Profile"
            } else {
                self.titleLabel.text = "Profile"
            }
        }
    }

    // TableViewController Overrides

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            // Header + Controls
            return 2
        default:
            return self.tasks.isEmpty ? 1 : self.tasks.count
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return self.cellHeights[indexPath.row]
        default:
            return self.cellHeights.last!
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            // Header Cell
            if indexPath.row == 0 {
                if self.profileHeaderCell == nil {
                    self.profileHeaderCell = (tableView.dequeueReusableCellWithIdentifier("ProfileHeaderCell") as ProfileHeaderCell)
                    if let user = self.user? {
                        self.profileHeaderCell!.setUser(user)
                    }
                }
                return self.profileHeaderCell!
            }
            // Control Cell
            if let user = self.user? {
                if !UserStore.sharedInstance().isAuthUser(user.uid) {
                    return tableView.dequeueReusableCellWithIdentifier("ProfileControlsCell") as UITableViewCell
                }
            }
            if self.statusSliderCell == nil {
                self.statusSliderCell = (tableView.dequeueReusableCellWithIdentifier("StatusSliderCell") as StatusSliderCell)
                if let user = self.user? {
                    self.statusSliderCell!.setUser(user)
                }
            }
            return self.statusSliderCell!
        default:
            if self.isLoadingTasks {
                return tableView.dequeueReusableCellWithIdentifier("LoadingCell") as UITableViewCell
            } else if self.tasks.count == 0 {
                return tableView.dequeueReusableCellWithIdentifier("NoTasksCell") as UITableViewCell
            }
            let cell = (tableView.dequeueReusableCellWithIdentifier("TaskCell") as TaskCell)
            cell.setTask(self.tasks[indexPath.row])
            return cell
        }
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "UserProfileTaskDetail" {
            let taskCell = sender as TaskCell
            let vc = segue.destinationViewController as TaskDetailViewController
            vc.setTask(taskCell.getTask()!)
        } else if segue.identifier == "UserProfileTaskEdit" {
            let vc = segue.destinationViewController as TaskEditViewController
            if let user = self.user? {
                vc.setOwner(user)
            }
        }
    }
}
