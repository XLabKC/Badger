import UIKit

class ProfileViewController: UITableViewController, HeaderCellDelegate {

    private let cellHeights: [CGFloat] = [225.0, 100.0, 40.0, 72.0]
    private let titleLabel = Helpers.createTitleLabel("My Profile")

    private let headerSection = 0
    private let activeTaskSection = 1
    private let dividerSection = 2
    private let completedTaskSection = 3

    private var userObserver: FirebaseObserver<User>?
    private var activeObserver: FirebaseObserver<Task>?
    private var completedObserver: FirebaseObserver<Task>?

    private var activeTasks = ArrayRef<Task>()
    private var completedTasks = ArrayRef<Task>()
    private var isShowingCompletedTasks = false
    private var statusSliderCell: StatusSliderCell?
    private var profileHeaderCell: ProfileHeaderCell?
    private var profileControlsCell: ProfileControlsCell?
    private var user: User?
    private var isAuthUser = true

    var hasSetup: Bool {
        return self.activeObserver != nil
    }

    var isLoadingActiveTasks: Bool {
        if let observer = self.activeObserver? {
            return !observer.hasLoadedInitial()
        }
        return true
    }

    var isLoadingCompletedTasks: Bool {
        if let observer = self.completedObserver? {
            return !observer.hasLoadedInitial()
        }
        return false
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    deinit {
        if let observer = self.userObserver? {
            observer.dispose()
        }
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
        if self.user != nil && !self.hasSetup {
            self.loadUserProfile(self.user!.uid)
        }
    }

    func setUid(uid: String) {
        self.isAuthUser = UserStore.sharedInstance().isAuthUser(uid)
        self.userObserver = FirebaseObserver<User>(query: User.createRef(uid), withBlock: { user in
            self.user = user

            // Update table cells if they have already initialized.
            if let profileHeader = self.profileHeaderCell? {
                profileHeader.setUser(user)
            }
            if let statusSlider = self.statusSliderCell? {
                statusSlider.setUser(user)
            }

            if self.isViewLoaded() && !self.hasSetup {
                self.loadUserProfile(uid)
            }

            if !self.isLoadingActiveTasks {
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: self.dividerSection)], withRowAnimation: .None)
            }
        })

        //        for family in UIFont.familyNames() as [String] {
        //            for font in UIFont.fontNamesForFamilyName(family) {
        //                println(font)
        //            }
        //        }
    }

    private func loadUserProfile(uid: String) {
        println("Loading for uid: \(uid))")

        // Load the users tasks.
        let ref = Firebase(url: Global.FirebaseActiveTasksUrl).childByAppendingPath(uid)
        self.activeObserver = FirebaseObserver<Task>(query: ref.queryOrderedByPriority())
        let observer = self.activeObserver!

        // Set up observer for active tasks.
        observer.afterInitial = { _ in
            // Finished loading active tasks but prefetch all the users before reloading table.
            self.prefetchUsers(self.activeTasks, complete: { _ in
                var set = NSMutableIndexSet(index: self.activeTaskSection)
                set.addIndex(self.dividerSection)
                self.tableView.reloadSections(set, withRowAnimation: .Bottom)
            })
        }
        observer.childAdded = self.handleChildAdded(self.activeTasks, section: self.activeTaskSection)
        observer.childChanged = self.handleChildChanged(self.activeTasks, section: self.activeTaskSection)
        observer.childMoved = self.handleChildMoved(self.activeTasks, section: self.activeTaskSection)
        observer.childRemoved = self.handleChildRemoved(self.activeTasks, section: self.activeTaskSection)
        observer.start()

        if UserStore.sharedInstance().isAuthUser(uid) {
            self.titleLabel.text = "My Profile"
        } else {
            self.titleLabel.text = "Profile"
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
            if self.isAuthUser {
                if self.statusSliderCell == nil {
                    self.statusSliderCell = (tableView.dequeueReusableCellWithIdentifier("StatusSliderCell") as StatusSliderCell)
                    if let user = self.user? {
                        self.statusSliderCell!.setUser(user)
                    }
                }
                return self.statusSliderCell!
            }
            return tableView.dequeueReusableCellWithIdentifier("ProfileControlsCell") as UITableViewCell
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
                cell.title = "COMPLETED TASKS (\(user.completedTaskCount))"
                cell.showButton = user.completedTaskCount > 0
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
            let vc = segue.destinationViewController as TaskDetailViewController
            let task = (sender as TaskCell).getTask()!
            vc.setTask(task.owner, id: task.id, active: task.active)
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
                            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 2), atScrollPosition: .Top, animated: true)
                        })
                    }
                    let section = self.completedTaskSection
                    observer.childAdded = self.handleChildAdded(self.completedTasks, section: section)
                    observer.childChanged = self.handleChildChanged(self.completedTasks, section: section)
                    observer.childMoved = self.handleChildMoved(self.completedTasks, section: section)
                    observer.childRemoved = self.handleChildRemoved(self.completedTasks, section: section)
                    observer.start()
                }
            } else {
                // Already observing the completed tasks so just reload the section.
                self.tableView.reloadSections(NSIndexSet(index: self.completedTaskSection), withRowAnimation: .Bottom)
                self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: self.dividerSection), atScrollPosition: .Top, animated: true)
                return
            }
        }
        self.tableView.reloadSections(NSIndexSet(index: self.completedTaskSection), withRowAnimation: .Bottom)
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
            println("added(section \(section)): \(task.id), previous: \(previousId), isInitial: \(isInitial)")
            if isInitial {
                // Kind of a hack.. Requests can come in reverse order, check that the last task
                // is not the same as this one.
                if listRef.array.isEmpty || listRef.array.last!.id != task.id {
                    listRef.array.append(task)
                }
            } else {
                // Make sure this task isn't already in the list.
                let currentIndex = self.findIndexOfTask(listRef, id: task.id)
                if currentIndex >= 0 {
                    // Task already in the list so instead let's just update it.
                    // TODO: actually update the cell.
                    return
                }
                let index = self.findNextIndex(listRef, previousId: previousId)
                let wasEmpty = listRef.array.isEmpty
                listRef.array.insert(task, atIndex: index)

                // If the completed section is closed, make sure not to insert any rows.
                if self.tableView.numberOfRowsInSection(section) == 0 {
                    return
                }

                self.tableView.beginUpdates()

                // If the array is empty, make sure and delete the current (placeholder) cell.
                if wasEmpty {
                    self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: section)], withRowAnimation: .Fade)
                }
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: section)], withRowAnimation: .Left)
                self.tableView.endUpdates()
            }
        }
    }

    private func handleChildChanged(listRef: ArrayRef<Task>, section: Int) -> (Task, previousId: String?) -> () {
        return { (task, previousId) in
            println("changed(section \(section)): \(task.id), previous: \(previousId)")
            let index = self.findIndexOfTask(listRef, id: task.id)
            if index >= 0 {
                let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: section))
                if let taskCell = cell as? TaskCell {
                    taskCell.setTask(task)
                }
            }
        }
    }

    private func handleChildMoved(listRef: ArrayRef<Task>, section: Int) -> (Task, previousId: String?) -> () {
        return { (task, previousId) in
            println("moved(section \(section)): \(task.id), previous: \(previousId)")
            var oldIndex = self.findIndexOfTask(listRef, id: task.id)
            listRef.array.removeAtIndex(oldIndex)
            var newIndex = self.findNextIndex(listRef, previousId: previousId)
            listRef.array.insert(task, atIndex: newIndex)
            self.tableView.moveRowAtIndexPath(NSIndexPath(forRow: oldIndex, inSection: section), toIndexPath: NSIndexPath(forRow: newIndex, inSection: section))
        }
    }

    private func handleChildRemoved(listRef: ArrayRef<Task>, section: Int) -> (Task, previousId: String?) -> () {
        return { (task, previousId) in
            println("removed(section \(section)): \(task.id), previous: \(previousId)")
            var oldIndex = self.findIndexOfTask(listRef, id: task.id)
            listRef.array.removeAtIndex(oldIndex)

            self.tableView.beginUpdates()
            self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: oldIndex, inSection: section)], withRowAnimation: .Left)

            if listRef.array.isEmpty {
                if section == self.activeTaskSection {
                    // The last row was just deleted, make sure to insert the 'no rows' cell.
                    self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: section)], withRowAnimation: .Fade)
                } else {
                    // If there are no rows in the completed section, hide the section.
                    self.isShowingCompletedTasks = false
                }
            }
            self.tableView.endUpdates()
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
