import UIKit

class TaskEditViewController: UITableViewController {
    private let selectTeamCellHeight = CGFloat(72.0)
    private let headerCellHeight = CGFloat(40.0)
    private let titleCellHeight = CGFloat(72.0)
    private let minContentHeight = CGFloat(80.0)
    private let priorityCellHeight = CGFloat(72.0)
    private let assigneeCellHeight = CGFloat(72.0)
    private let submitButtonHeight = CGFloat(80.0)

    private var task: Task?

    override func viewDidLoad() {
        self.navigationItem.titleView = Helpers.createTitleLabel("Task")

        let headerCellNib = UINib(nibName: "HeaderCell", bundle: nil)
        self.tableView.registerNib(headerCellNib, forCellReuseIdentifier: "HeaderCell")

        super.viewDidLoad()
    }


    func setTask(task: Task) {
        self.task = task
        if (self.isViewLoaded()) {
            self.tableView.reloadData()
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
            if let task = self.task? {
                let calculationView = UITextView()
                calculationView.text = task.content
                let size = calculationView.sizeThatFits(CGSizeMake(self.view.frame.width, CGFloat(FLT_MAX)))
                let height = size.height + 38
                return height < self.minContentHeight ? self.minContentHeight : height
            }
            return self.minContentHeight
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
        if (indexPath.row == 0 || indexPath.row == 2 || indexPath.row == 6) {
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
        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCellWithIdentifier("TaskEditTeamCell") as TaskEditTeamCell
            return cell
        } else if (indexPath.row == 3) {
            let cell = tableView.dequeueReusableCellWithIdentifier("TaskEditTitleCell") as TaskEditTitleCell
            return cell
        } else if (indexPath.row == 4) {
            let cell = tableView.dequeueReusableCellWithIdentifier("TaskEditContentCell") as TaskEditContentCell
            return cell
        } else if (indexPath.row == 5) {
            let cell = tableView.dequeueReusableCellWithIdentifier("TaskEditPriorityCell") as TaskEditPriorityCell
            return cell
        } else if (indexPath.row == 7) {
            let cell = tableView.dequeueReusableCellWithIdentifier("TaskEditUserCell") as TaskEditUserCell
            return cell
        }
        return tableView.dequeueReusableCellWithIdentifier("TaskEditSubmitCell") as UITableViewCell
    }
}