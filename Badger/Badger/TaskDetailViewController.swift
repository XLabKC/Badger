import UIKit

class TaskDetailViewController: UITableViewController, TaskDetailCompleteCellDelegate {
    private let authorCellHeight = CGFloat(72.0)
    private let headerCellHeight = CGFloat(40.0)
    private let titleCellHeight = CGFloat(72.0)
    private let completeButtonHeight = CGFloat(92.0)

    private var task: Task?
    private var contentCell: TaskDetailContentCell?

    override func viewDidLoad() {
        self.navigationItem.titleView = Helpers.createTitleLabel("Task")

        let headerCellNib = UINib(nibName: "HeaderCell", bundle: nil)
        self.tableView.registerNib(headerCellNib, forCellReuseIdentifier: "HeaderCell")

        super.viewDidLoad()
    }

    func setTask(task: Task) {
        self.task = task
        self.getContentCell().setTask(task)
        if (self.isViewLoaded()) {
            self.tableView.reloadData()
        }
    }

    // TableViewController Overrides

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let task = self.task? {
            if UserStore.sharedInstance().isAuthUser(task.owner) {
                // Header + User + Header + Title + Content + Complete Button
                return 6
            }
        }
        // Header + User + Header + Title + Content
        return 5
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch (indexPath.row) {
        case 0, 2:
            return self.headerCellHeight
        case 1:
            return self.authorCellHeight
        case 3:
            return self.titleCellHeight
        case 4:
            let cell = self.getContentCell()
            return cell.calculateCellHeight()
        default:
            return self.completeButtonHeight
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (indexPath.row) {
        case 0, 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as HeaderCell
            cell.labelColor = Color.colorize(0x929292, alpha: 1)
            cell.title = (indexPath.row == 0) ? "ASSIGNED BY" : "TASK INFO"
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("TaskDetailAuthorCell") as TaskDetailAuthorCell
            if let task = self.task? {
                cell.setTask(task)
            }
            return cell
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier("TaskDetailTitleCell") as TaskDetailTitleCell
            if let task = self.task? {
                cell.setTask(task)
            }
            return cell
        case 4:
            return getContentCell()
        default:
            return tableView.dequeueReusableCellWithIdentifier("TaskDetailCompleteCell") as UITableViewCell
        }
    }

    func detailCompleteCellPressed(cell: TaskDetailCompleteCell) {
        if let task = self.task? {
            let combinedId = TaskStore.combineId(task.owner, id: task.id)
            let isActive = !task.active
            let ref = task.getRef()
            ref.childByAppendingPath("active").setValue(isActive)

            // Update Firebase priority.
            let mult = Task.getFirebasePriorityMult(task.priority, isActive: isActive)
            let priority = NSDate.javascriptTimestampFromDate(task.timestamp).doubleValue * mult
            ref.setPriority(priority)

            UserStore.sharedInstance().adjustActiveTaskCount(task.owner, delta: isActive ? 1 : -1)
            UserStore.sharedInstance().adjustCompletedTaskCount(task.owner, delta: isActive ? -1 : 1)

            if isActive {
                TeamStore.sharedInstance().addActiveTask(task.team, combinedId: combinedId)
            } else {
                TeamStore.sharedInstance().removeActiveTask(task.team, combinedId: combinedId)
            }
        }
    }

    private func getContentCell() -> TaskDetailContentCell {
        if let cell = self.contentCell? {
            return cell
        }
        self.contentCell = (self.tableView.dequeueReusableCellWithIdentifier("TaskDetailContentCell") as TaskDetailContentCell)
        return self.contentCell!
    }
}