import UIKit

private enum Rows: Int {
    case TeamHeader = 0
    case SelectTeam = 1
    case InfoHeader = 2
    case Title = 3
    case Content = 4
    case Priority = 5
    case AssignToHeader = 6
    case Assignee = 7
    case Submit = 8
}

class TaskEditViewController: UITableViewController, TaskEditContentCellDelegate, TaskEditSubmitCellDelegate, SelectUserDelegate, SelectTeamDelegate, InputCellDelegate {
    private let selectTeamCellHeight = CGFloat(72.0)
    private let headerCellHeight = CGFloat(40.0)
    private let titleCellHeight = CGFloat(76.0)
    private let priorityCellHeight = CGFloat(72.0)
    private let assigneeCellHeight = CGFloat(72.0)
    private let submitButtonHeight = CGFloat(92.0)

    private let selectUserSegue = "EditTaskSelectUser"
    private let selectTeamSegue = "EditTaskSelectTeam"

    private var task: Task?
    private var contentCell: TaskEditContentCell?
    private var owner: User?
    private var team: Team?

    private var cells = [UITableViewCell?](count: 9, repeatedValue: nil)

    override func viewDidLoad() {
        self.navigationItem.titleView = Helpers.createTitleLabel("Task")

        let headerCellNib = UINib(nibName: "HeaderCell", bundle: nil)
        self.tableView.registerNib(headerCellNib, forCellReuseIdentifier: "HeaderCell")

        let userCellNib = UINib(nibName: "UserCell", bundle: nil)
        self.tableView.registerNib(userCellNib, forCellReuseIdentifier: "UserCell")

        let teamCellNib = UINib(nibName: "TeamCell", bundle: nil)
        self.tableView.registerNib(teamCellNib, forCellReuseIdentifier: "TeamCell")

        super.viewDidLoad()
    }

    func setTask(task: Task) {
        self.task = task
        if (self.isViewLoaded()) {
            self.tableView.reloadData()
        }
    }

    func setOwner(owner: User) {
        self.owner = owner
        if self.isViewLoaded() {
            let indexPath = NSIndexPath(forRow: Rows.Assignee.rawValue, inSection: 0)
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
        }
    }

    func setTeam(team: Team) {
        self.team = team
        if self.isViewLoaded() {
            let indexPath = NSIndexPath(forRow: Rows.SelectTeam.rawValue, inSection: 0)
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
        }
    }

    // TableViewController Overrides

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Header + Select Team + Header + Title + Content + Priority + Header + Assignee + Submit
        return 9
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let row = Rows(rawValue: indexPath.row)!
        switch (row) {
        case .TeamHeader, .InfoHeader, .AssignToHeader:
            return self.headerCellHeight
        case .SelectTeam:
            return self.selectTeamCellHeight
        case .Title:
            return self.titleCellHeight
        case .Content:
            let cell = self.getContentCell()
            return cell.calculateCellHeight()
        case .Priority:
            return self.priorityCellHeight
        case .Assignee:
            return self.assigneeCellHeight
        case .Submit:
            return self.submitButtonHeight
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.cellForIndex(indexPath.row)
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.getContentCell().closeKeyboard()
        self.getTitleCell().closeKeyboard()

        if indexPath.row == Rows.SelectTeam.rawValue {
            self.performSegueWithIdentifier(self.selectTeamSegue, sender: self)
        } else if indexPath.row == Rows.Assignee.rawValue {
            self.performSegueWithIdentifier(self.selectUserSegue, sender: self)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == self.selectTeamSegue {
            let vc = segue.destinationViewController as SelectTeamViewController
            vc.delegate = self
            if let owner = self.owner {
                vc.setUid(owner.uid)
            } else {
                vc.setUid(UserStore.sharedInstance().getAuthUid())
            }
        } else if segue.identifier == self.selectUserSegue {
            let vc = segue.destinationViewController as SelectUserViewController
            vc.delegate = self
            if let team = self.team {
                vc.setTeamIds([team.id])
            } else {
                // Fetch all teams that the auth user's teams.
                let teamIds = UserStore.sharedInstance().getAuthUser().teamIds.keys.array
                vc.setTeamIds(teamIds)
            }
        }
    }

    // Adjusts the height of the content cell.
    func editContentCell(cell: TaskEditContentCell, hasChangedHeight: CGFloat) {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }

    func selectedUser(user: User) {
        // Don't do anything if this is the same owner.
        if let cur = self.owner {
            if cur.uid == user.uid {
                return
            }
        }
        self.owner = user
        self.cells[Rows.Assignee.rawValue] = nil
        let indexPath = NSIndexPath(forRow: Rows.Assignee.rawValue, inSection: 0)
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    }

    func selectedTeam(team: Team) {
        // Don't do anything if this is the same team.
        if let cur = self.team {
            if cur.id == team.id {
                return
            }
        }
        self.team = team
        self.cells[Rows.SelectTeam.rawValue] = nil
        let indexPath = NSIndexPath(forRow: Rows.SelectTeam.rawValue, inSection: 0)
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    }

    func editSubmitCellSubmitted(cell: TaskEditSubmitCell) {
        if (self.owner == nil || self.team == nil) {
            return
        }
        let newOwner = self.owner!
        let newTeam = self.team!
        var createdAt = NSDate.javascriptTimestampNow()
        var completedAt: NSNumber? = nil
        var isActive = true
        var isNew = self.task == nil
        var isUpdated = self.task != nil

        var root = Firebase(url: isActive ? Global.FirebaseActiveTasksUrl : Global.FirebaseCompletedTasksUrl)
        var taskRef = root.childByAppendingPath(newOwner.uid).childByAutoId()

        if let task = self.task {
            if task.owner == newOwner.uid {
                taskRef = task.ref
            } else {
                // Task is moving to a different user so delete it from it's current location.
                task.ref.removeValue()
                isNew = true

                if isActive {
                    // Decrement active count if task is moving to a different user.
                    UserStore.adjustActiveTaskCount(task.owner, delta: -1)

                    // The user is going to be different so the combined id needs to be changed.
                    var oldTeamRef = Firebase(url: Global.FirebaseTeamsUrl).childByAppendingPath(task.team)
                    oldTeamRef.childByAppendingPath("tasks/\(task.owner)").removeValue()
                }
                // Keep the same id to be helpful for the UI.
                taskRef = root.childByAppendingPath("\(newOwner.uid)/\(task.id)")
            }
            // This is an active task that's being moved to a different team so decrement the active count.
            if task.team != newTeam.id && task.active {
                TeamStore.adjustActiveTaskCount(task.team, delta: -1)
            }
            // Keep the same timestamps and active state.
            isActive = task.active
            createdAt = NSDate.javascriptTimestampFromDate(task.createdAt)
            if let date = task.completedAt? {
                completedAt = NSDate.javascriptTimestampFromDate(date)
            }
        }

        // Create the task values.
        var taskValues = [
            "author": UserStore.sharedInstance().getAuthUid(),
            "team": self.team!.id,
            "title": self.getTitleCell().getText(),
            "content": self.getContentCell().getText(),
            "priority": self.getPriorityCell().getPriority().rawValue as String,
            "active": isActive,
            "created_at": createdAt,

        ]

        // Date to be used for calculating Firebase priority.
        var dateForPriority = createdAt

        // If there is a completion date, added it to values and change priority.
        if let jsDate = completedAt? {
            taskValues["completed_at"] = jsDate
            dateForPriority = jsDate
        }

        // Calculate what the firebase priority of the task should be.
        let mult = Task.getFirebasePriorityMult(self.getPriorityCell().getPriority(), isActive: isActive)
        var priority = (-1 * dateForPriority.doubleValue) * mult

        // Save the task.
        taskRef.setValue(taskValues, andPriority: priority, withCompletionBlock: { (err, ref) in
            // TODO: handle error
            var combinedKey = "\(newOwner.uid)^\(taskRef.key)"

            // Increment the active tasks count for the user if it's new and active.
            if isActive && isNew {
                UserStore.adjustActiveTaskCount(newOwner.uid, delta: 1)
            }

            // Add the task to the appropriate team and incrememt count.
            if isActive {
                TeamStore.addActiveTask(newTeam.id, combinedId: combinedKey)
            }

            // Add to push message queues if new of updated.
            if isNew && isActive {
                let val = isNew ? "new" : "updated"
                // ENABLE WHEN PUSH NOTIFICATIONS WORK.
                let now = NSDate.javascriptTimestampNow()
                Firebase(url: Global.FirebaseNewTasksUrl).childByAppendingPath(combinedKey).setValue(now)
            }
            if let nav = self.navigationController? {
                nav.popViewControllerAnimated(true)
            }
        })
    }

    // InputCellDelegate: opens the next cell when the "next" key is pressed on the keyboard.
    func shouldSelectNext(cell: InputCell) {
        let cell = self.cellForIndex(Rows.Content.rawValue) as TaskEditContentCell
        cell.openKeyboard()
    }

    func cellDidBeginEditing(cell:InputCell) {
        var indexPath: NSIndexPath
        if cell === self.getTitleCell() {
            indexPath = NSIndexPath(forRow: Rows.InfoHeader.rawValue, inSection: 0)
        } else {
            indexPath = NSIndexPath(forRow: Rows.Content.rawValue, inSection: 0)
        }
        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
    }

    private func cellForIndex(index: Int) -> UITableViewCell {
        if let cell = self.cells[index]? {
            return cell
        }
        // Create new table cells.
        let row = Rows(rawValue: index)!
        switch (row) {
        case .TeamHeader, .InfoHeader, .AssignToHeader:
            let cell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as HeaderCell
            cell.labelColor = Color.colorize(0x929292, alpha: 1)
            switch (row) {
            case .TeamHeader:
                cell.title = "TEAM"
            case .InfoHeader:
                cell.title = "TASK INFO"
            default:
                cell.title = "ASSIGN TO"
            }
            self.cells[index] = cell
            return cell
        case .SelectTeam:
            if let team = self.team? {
                let cell = tableView.dequeueReusableCellWithIdentifier("TeamCell") as TeamCell
                cell.setTeam(team)
                self.cells[index] = cell
            } else {
                self.cells[index] = tableView.dequeueReusableCellWithIdentifier("SelectTeamCell") as? UITableViewCell
            }
            return self.cells[index]!
        case .Title:
            let cell = tableView.dequeueReusableCellWithIdentifier("TaskEditTitleCell") as TaskEditTitleCell
            cell.delegate = self
            if let task = self.task {
                cell.setText(task.title)
            }
            self.cells[index] = cell
            return cell
        case .Content:
            let cell = (self.tableView.dequeueReusableCellWithIdentifier("TaskEditContentCell") as TaskEditContentCell)
            cell.delegate = self
            if let task = self.task {
                cell.setText(task.content)
            }
            self.cells[index] = cell
            return cell
        case .Priority:
            let cell = tableView.dequeueReusableCellWithIdentifier("TaskEditPriorityCell") as TaskEditPriorityCell
            if let task = self.task {
                cell.setTask(task)
            }
            self.cells[index] = cell
            return cell
        case .Assignee:
            if let owner = self.owner? {
                let cell = tableView.dequeueReusableCellWithIdentifier("UserCell") as UserCell
                cell.setUid(owner.uid)
                self.cells[index] = cell
                return cell
            }
            self.cells[index] = (tableView.dequeueReusableCellWithIdentifier("SelectUserCell") as UITableViewCell)
            return self.cells[index]!
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("TaskEditSubmitCell") as TaskEditSubmitCell
            cell.delegate = self
            self.cells[index] = cell
            return cell
        }
    }


    private func getTitleCell() -> TaskEditTitleCell {
        return self.cellForIndex(Rows.Title.rawValue) as TaskEditTitleCell
    }

    private func getContentCell() -> TaskEditContentCell {
        return self.cellForIndex(Rows.Content.rawValue) as TaskEditContentCell
    }

    private func getPriorityCell() -> TaskEditPriorityCell {
        return self.cellForIndex(Rows.Priority.rawValue) as TaskEditPriorityCell
    }
}