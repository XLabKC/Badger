import UIKit

class ProfileViewController: UITableViewController, HeaderCellDelegate {

    private let cellHeights: [CGFloat] = [225.0, 100.0, 40.0, 72.0]
    private let titleLabel = Helpers.createTitleLabel("My Profile")

    private var activeTasks = [Task]()
    private var completedTasks = [Task]()
    private var isLoadingActiveTasks = true
    private var isLoadingCompletedTasks = false
    private var isShowingCompletedTasks = false
    private var hasLoadedCompletedTasks = false
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

        // Register cells.
        let loadingCellNib = UINib(nibName: "LoadingCell", bundle: nil)
        self.tableView.registerNib(loadingCellNib, forCellReuseIdentifier: "LoadingCell")

        let headerCellNib = UINib(nibName: "HeaderCell", bundle: nil)
        self.tableView.registerNib(headerCellNib, forCellReuseIdentifier: "HeaderCell")

        // Set up navigation bar.
        self.navigationItem.titleView = self.titleLabel

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
        self.isLoadingActiveTasks = true

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
            TaskStore.sharedInstance().getActiveTasksForUser(user, withBlock: { tasks in
                // On completion, prefetch users before loading table cells.
                self.activeTasks = tasks
                var uids = [String: Bool]()
                for task in self.activeTasks {
                    uids[task.author] = true
                }
                UserStore.sharedInstance().getUsers(uids.keys.array, withBlock: { _ in
                    self.isLoadingActiveTasks = false
                    var set = NSMutableIndexSet(index: 1)
                    set.addIndex(2)
                    self.tableView.reloadSections(set, withRowAnimation: .Bottom)
                })
            })

            if UserStore.sharedInstance().isAuthUser(user.uid) {
                self.titleLabel.text = "My Profile"
            } else {
                self.titleLabel.text = "Profile"
            }
        }
    }

    // TableViewController Overrides

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            // Header + Controls.
            return 2
        case 1:
            // Active tasks.
            return self.activeTasks.isEmpty ? 1 : self.activeTasks.count
        case 2:
            // Show completed tasks header only if we aren't loading the active tasks.
            if self.isLoadingActiveTasks {
                return 0
            }
            return 1
        default:
            // Completed tasks.
            if !self.isShowingCompletedTasks {
                return 0
            }
            if self.isLoadingCompletedTasks {
                return 1
            }
            return self.completedTasks.count
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return self.cellHeights[indexPath.row]
        case 2:
            return self.cellHeights[2]
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
        case 1:
            if self.isLoadingActiveTasks {
                return tableView.dequeueReusableCellWithIdentifier("LoadingCell") as UITableViewCell
            } else if self.activeTasks.isEmpty {
                return tableView.dequeueReusableCellWithIdentifier("NoTasksCell") as UITableViewCell
            }
            let cell = (tableView.dequeueReusableCellWithIdentifier("TaskCell") as TaskCell)
            cell.setTask(self.activeTasks[indexPath.row])
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as HeaderCell
            cell.delegate = self
            cell.buttonText = self.isShowingCompletedTasks ? "HIDE" : "SHOW"
            cell.setBottomBorder(.Full)
            cell.setBorderColor(Color.colorize(0xE0E0E0, alpha: 1.0))
            if let user = self.user? {
                cell.title = "COMPLETED TASKS (\(user.completedTasks))"
                cell.showButton = user.completedTasks > 0
            }
            return cell
        default:
            if self.isLoadingCompletedTasks {
                return tableView.dequeueReusableCellWithIdentifier("LoadingCell") as UITableViewCell
            } else if self.completedTasks.isEmpty {
                return tableView.dequeueReusableCellWithIdentifier("NoTasksCell") as UITableViewCell
            }
            let cell = (tableView.dequeueReusableCellWithIdentifier("TaskCell") as TaskCell)
            cell.setTask(self.completedTasks[indexPath.row])
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

    func headerCellButtonPressed(cell: HeaderCell) {
        if self.isShowingCompletedTasks {
            self.isShowingCompletedTasks = false
            cell.buttonText = "SHOW"
        } else {
            self.isShowingCompletedTasks = true
            cell.buttonText = "HIDE"
            if !self.hasLoadedCompletedTasks {
                self.isLoadingCompletedTasks = true
                // Load completed tasks
                if let user = self.user? {
                    TaskStore.sharedInstance().getCompletedTasksForUser(user, withBlock: { tasks in
                        self.isLoadingCompletedTasks = false
                        self.hasLoadedCompletedTasks = true
                        self.completedTasks = tasks
                        self.tableView.reloadSections(NSIndexSet(index: 3), withRowAnimation: .Bottom)
                    })
                }
            }

        }
        self.tableView.reloadSections(NSIndexSet(index: 3), withRowAnimation: .Bottom)
    }
}
