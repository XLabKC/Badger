import UIKit

class ProfileViewController: UITableViewController, HeaderCellDelegate {

    private let cellHeights: [CGFloat] = [225.0, 100.0, 40.0, 72.0]
    private let titleLabel = Helpers.createTitleLabel("My Profile")

    private var activeObserver: FirebaseObserver<Task>?
    private var completedObserver: FirebaseObserver<Task>?
    private var activeTasks = ArrayRef<Task>()
    private var completedTasks = ArrayRef<Task>()
    private var isShowingCompletedTasks = false
    private var statusSliderCell: StatusSliderCell?
    private var profileHeaderCell: ProfileHeaderCell?
    private var profileControlsCell: ProfileControlsCell?
    private var user: User?


    var isLoadingActiveTasks: Bool {
        get {
            if let observer = self.activeObserver? {
                return !observer.hasLoadedInitial()
            }
            return true
        }
    }

    var isLoadingCompletedTasks: Bool {
        get {
            if let observer = self.completedObserver? {
                return !observer.hasLoadedInitial()
            }
            return false
        }
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    deinit {
        if let observer = self.activeObserver? {
            observer.dispose()
        }
        if let observer = self.completedObserver? {
            observer.dispose()
        }
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
            let ref = Firebase(url: Global.FirebaseActiveTasksUrl).childByAppendingPath(user.uid)
            self.activeObserver = FirebaseObserver<Task>(query: ref.queryOrderedByPriority())
            let observer = self.activeObserver!

            // Set up observer for active tasks.
            observer.afterInitial = { _ in
                // Finished loading active tasks but prefetch all the users before reloading table.
                self.prefetchUsers(self.activeTasks, complete: { _ in
                    var set = NSMutableIndexSet(index: 1)
                    set.addIndex(2)
                    self.tableView.reloadSections(set, withRowAnimation: .Bottom)
                })
            }
            observer.childAdded = self.handleChildAdded(self.activeTasks, section: 1)
            observer.childChanged = self.handleChildChanged(self.activeTasks, section: 1)
            observer.childMoved = self.handleChildMoved(self.activeTasks, section: 1)
            observer.childRemoved = self.handleChildRemoved(self.activeTasks, section: 1)
            observer.start()

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
            return self.activeTasks.array.isEmpty ? 1 : self.activeTasks.array.count
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
            return self.completedTasks.array.count
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
            } else if self.activeTasks.array.isEmpty {
                return tableView.dequeueReusableCellWithIdentifier("NoTasksCell") as UITableViewCell
            }
            let cell = (tableView.dequeueReusableCellWithIdentifier("TaskCell") as TaskCell)
            cell.setTask(self.activeTasks.array[indexPath.row])
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
            } else if self.completedTasks.array.isEmpty {
                return tableView.dequeueReusableCellWithIdentifier("NoTasksCell") as UITableViewCell
            }
            let cell = (tableView.dequeueReusableCellWithIdentifier("TaskCell") as TaskCell)
            cell.setTask(self.completedTasks.array[indexPath.row])
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

            // Only start loading if we haven't already.
            if self.completedObserver == nil {
                if let user = self.user? {
                    // Create the completed tasks observer.
                    let ref = Firebase(url: Global.FirebaseCompletedTasksUrl).childByAppendingPath(user.uid)
                    self.completedObserver = FirebaseObserver<Task>(query: ref.queryOrderedByPriority())
                    let observer = self.completedObserver!

                    // Set up observer for completed tasks.
                    observer.afterInitial = { _ in
                        // Finished loading completed tasks but prefetch all the users before reloading table.
                        self.prefetchUsers(self.completedTasks, complete: { _ in
                            self.tableView.reloadSections(NSIndexSet(index: 3), withRowAnimation: .Bottom)
                        })
                    }
                    observer.childAdded = self.handleChildAdded(self.completedTasks, section: 3)
                    observer.childChanged = self.handleChildChanged(self.completedTasks, section: 3)
                    observer.childMoved = self.handleChildMoved(self.completedTasks, section: 3)
                    observer.childRemoved = self.handleChildRemoved(self.completedTasks, section: 3)
                    observer.start()
                }
            }

        }
        self.tableView.reloadSections(NSIndexSet(index: 3), withRowAnimation: .Bottom)
    }

    private func prefetchUsers(listRef: ArrayRef<Task>, complete: () -> ()) {
        var uids = [String: Bool]()
        for task in listRef.array {
            uids[task.author] = true
        }
        UserStore.sharedInstance().getUsers(uids.keys.array, withBlock: { _ in
            complete()
        })
    }

    private func handleChildAdded(listRef: ArrayRef<Task>, section: Int) -> (Task, previousId: String?, isInitial: Bool) -> () {
        return { (task, previousId, isInitial) in
            println("added: \(task.id), previous: \(previousId), isInitial: \(isInitial)")
            if isInitial {
                listRef.array.append(task)
            } else {
                let index = self.findNextIndex(listRef, previousId: previousId)
                listRef.array.insert(task, atIndex: index)
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 1)], withRowAnimation: .Left)
            }
        }
    }

    private func handleChildChanged(listRef: ArrayRef<Task>, section: Int) -> (Task, previousId: String?) -> () {
        return { (task, previousId) in
            println("changed: \(task.id), previous: \(previousId)")
        }
    }

    private func handleChildMoved(listRef: ArrayRef<Task>, section: Int) -> (Task, previousId: String?) -> () {
        return { (task, previousId) in
            println("moved: \(task.id), previous: \(previousId)")
            var oldIndex = self.findIndexOfTask(listRef, id: task.id)
            listRef.array.removeAtIndex(oldIndex)
            var newIndex = self.findNextIndex(listRef, previousId: previousId)
            listRef.array.insert(task, atIndex: newIndex)
            self.tableView.moveRowAtIndexPath(NSIndexPath(forRow: oldIndex, inSection: section), toIndexPath: NSIndexPath(forRow: newIndex, inSection: section))
        }
    }

    private func handleChildRemoved(listRef: ArrayRef<Task>, section: Int) -> (Task, previousId: String?) -> () {
        return { (task, previousId) in
            println("removed: \(task.id), previous: \(previousId)")
            var oldIndex = self.findIndexOfTask(listRef, id: task.id)
            listRef.array.removeAtIndex(oldIndex)
            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: oldIndex, inSection: section)], withRowAnimation: .Left)
        }
    }

    private func findNextIndex(listRef: ArrayRef<Task>, previousId: String?) -> Int {
        if let id = previousId? {
            var index = 0
            index = self.findIndexOfTask(listRef, id: id) + 1
            return index
        }
        return 0
    }

    private func findIndexOfTask(listRef: ArrayRef<Task>, id: String) -> Int {
        for (index, task) in enumerate(listRef.array) {
            if task.id == id {
                return index
            }
        }
        return -1
    }
}
