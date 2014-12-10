import UIKit

class TaskEditViewController: UITableViewController, TaskEditContentCellDelegate, TaskEditSubmitCellDelegate, SelectUserDelegate {
    private let selectTeamCellHeight = CGFloat(72.0)
    private let headerCellHeight = CGFloat(40.0)
    private let titleCellHeight = CGFloat(76.0)
    private let priorityCellHeight = CGFloat(72.0)
    private let assigneeCellHeight = CGFloat(72.0)
    private let submitButtonHeight = CGFloat(80.0)

    private let selectUserSegue = "EditTaskSelectUser"
    private let selectTeamSegue = "EditTaskSelectTeam"

    private var task: Task?
    private var contentCell: TaskEditContentCell?
    private var owner: User?
    private var team: Team?

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        self.navigationItem.titleView = Helpers.createTitleLabel("Task")

        let headerCellNib = UINib(nibName: "HeaderCell", bundle: nil)
        self.tableView.registerNib(headerCellNib, forCellReuseIdentifier: "HeaderCell")

        let userCellNib = UINib(nibName: "UserCell", bundle: nil)
        self.tableView.registerNib(userCellNib, forCellReuseIdentifier: "UserCell")

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
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 7, inSection: 0)], withRowAnimation: .Left)
        }
    }

    func setTeam(team: Team) {
        self.team = team
        if self.isViewLoaded() {
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: .Left)
        }
    }

    // TableViewController Overrides

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Header + Select Team + Header + Title + Content + Priority + Header + Assignee + Submit
        return 9
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch (indexPath.row) {
        case 0, 2, 6:
            return self.headerCellHeight
        case 1:
            return self.selectTeamCellHeight
        case 3:
            return self.titleCellHeight
        case 4:
            let cell = self.getContentCell()
            return cell.calculateCellHeight()
        case 5:
            return self.priorityCellHeight
        case 7:
            return self.assigneeCellHeight
        case 8:
            return self.submitButtonHeight
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (indexPath.row) {
        case 0, 2, 6:
            let cell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as HeaderCell
            cell.labelColor = Color.colorize(0x929292, alpha: 1)
            switch (indexPath.row) {
            case 0:
                cell.title = "TEAM"
            case 2:
                cell.title = "TASK INFO"
            case 6:
                cell.title = "ASSIGN TO"
            default:
                break
            }
            return cell
        case 1:
            if let team = self.team? {
                let cell = tableView.dequeueReusableCellWithIdentifier("TaskEditTeamCell") as TaskEditTeamCell
                cell.setTeam(team)
                return cell
            }
            return tableView.dequeueReusableCellWithIdentifier("SelectTeamCell") as UITableViewCell
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier("TaskEditTitleCell") as TaskEditTitleCell
            if let task = self.task {
                cell.setTask(task)
            }
            return cell
        case 4:
            if let task = self.task {
                let cell = self.getContentCell()
                cell.setTask(task)
                return cell
            }
            return self.getContentCell()
        case 5:
            let cell = tableView.dequeueReusableCellWithIdentifier("TaskEditPriorityCell") as TaskEditPriorityCell
            if let task = self.task {
                cell.setTask(task)
            }
            return cell
        case 7:
            if let owner = self.owner? {
                let cell = tableView.dequeueReusableCellWithIdentifier("UserCell") as UserCell
                cell.setUser(owner)
                return cell
            }
            return tableView.dequeueReusableCellWithIdentifier("SelectUserCell") as UITableViewCell
        default:
            return tableView.dequeueReusableCellWithIdentifier("TaskEditSubmitCell") as UITableViewCell
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 1 {
//            self.performSegueWithIdentifier(self.selectTeamSegue, sender: self)
        } else if indexPath.row == 7 {
            self.performSegueWithIdentifier(self.selectUserSegue, sender: self)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == self.selectTeamSegue {

        } else if segue.identifier == self.selectUserSegue {
            let vc = segue.destinationViewController as SelectUserViewController
            vc.delegate = self
            if let team = self.team {
                vc.setTeams([team])
            } else {
                // Fetch all teams that the auth user's teams.
                UserStore.sharedInstance().getAuthUser({ authUser in
                    TeamStore.sharedInstance().getTeams(authUser.teamIds, withBlock: { teams in
                        vc.setTeams(teams)
                    })
                })
            }
        }
    }

    func editContentCell(cell: TaskEditContentCell, hasChangedHeight: CGFloat) {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }

    func selectedUser(user: User) {
        self.owner = user
        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 7, inSection: 0)], withRowAnimation: .Left)
    }

    func editSubmitCellSubmitted(cell: TaskEditSubmitCell) {
        if (self.owner == nil || self.team == nil) {
            return
        }
        let ref = Firebase(url: Global.FirebaseTasksUrl)
        let taskOwner = self.owner!
        let taskTeam = self.team!
        var taskRef = ref.childByAppendingPath(taskOwner.uid).childByAutoId()
        var timestamp = NSDate.javascriptTimestampNow()
        var isActive = true

        if let task = self.task {
            let oldRef = ref.childByAppendingPath(task.owner).childByAppendingPath(task.id)
            if task.owner == taskOwner.uid {
                taskRef = oldRef
            } else {
                oldRef.removeValue()
                taskTeam.getRef().childByAppendingPath("tasks").childByAppendingPath(task.owner).removeValue()
            }
            timestamp = NSDate.javascriptTimestampFromDate(task.timestamp)
            isActive = task.active
        }

        let taskValues = [
            "author": UserStore.sharedInstance().getAuthUid(),
            "team": self.team!.id,
            "title": self.getTitle(),
            "content": self.getContentCell().getContent(),
            "priority": self.getPriority().rawValue as String,
            "active": isActive,
            "timestamp": timestamp
        ]

        taskRef.setValue(taskValues, withCompletionBlock: { (error, ref) in
            // TODO: handle error
            var combinedKey = "\(taskOwner.uid)_\(taskRef.key)"
            taskTeam.getRef().childByAppendingPath("teams").childByAppendingPath(combinedKey).setValue(true)
            if let nav = self.navigationController? {
                nav.popViewControllerAnimated(true)
            }
        })
    }

    private func getTitle() -> String {
        let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0)) as TaskEditTitleCell
        return cell.getTitle()
    }

    private func getPriority() -> TaskPriority {
        let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 5, inSection: 0)) as TaskEditPriorityCell
        return cell.getPriority()
    }

    private func getContentCell() -> TaskEditContentCell {
        if let cell = self.contentCell? {
            return cell
        }
        self.contentCell = (self.tableView.dequeueReusableCellWithIdentifier("TaskEditContentCell") as TaskEditContentCell)
        self.contentCell!.delegate = self
        return self.contentCell!
    }
}