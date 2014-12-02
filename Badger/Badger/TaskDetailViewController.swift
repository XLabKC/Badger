import UIKit

class TaskDetailViewController: UITableViewController {
    private let authorCellHeight = CGFloat(72.0)
    private let headerCellHeight = CGFloat(40.0)
    private let titleCellHeight = CGFloat(72.0)
    private let completeButtonHeight = CGFloat(80.0)
    private let minContentHeight = CGFloat(72.0)

    private var task: Task?

    override func viewDidLoad() {
        // Set up navigation bar.
        let label = UILabel(frame: CGRectMake(0, 0, 100, 30))
        label.backgroundColor = UIColor.clearColor()
        label.font = UIFont(name: "OpenSans", size: 17.0)
        label.textAlignment = .Center
        label.textColor = Colors.NavHeaderTitle
        label.text = "Task"
        self.navigationItem.titleView = label

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
        // Header + User + Header + Title + Content + Complete Button
        return 6
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch (indexPath.row) {
        case 0, 2:
            return self.headerCellHeight
        case 1:
            return self.authorCellHeight
        case 3:
            if let task = self.task? {
                let calculationView = UITextView()
                calculationView.text = task.content
                let size = calculationView.sizeThatFits(CGSizeMake(self.view.frame.width, CGFloat(FLT_MAX)))
                return size.height + 40
            }
            return self.minContentHeight
        case 4:
            return self.completeButtonHeight
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.row == 0 || indexPath.row == 2) {
            let cell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as HeaderCell
            cell.labelColor = Color.colorize(0x929292, alpha: 1)
            switch (indexPath.row) {
            case 0:
                cell.title = "ASSIGNED BY"
            case 2:
                cell.title = "TASK INFO"
            default:
                break
            }
            return cell
        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCellWithIdentifier("TaskDetailAuthorCell") as TaskDetailAuthorCell
            return cell
        } else if (indexPath.row == 3) {
            let cell = tableView.dequeueReusableCellWithIdentifier("TaskDetailTitleCell") as TaskDetailTitleCell
            return cell
        } else if (indexPath.row == 4) {
            let cell = tableView.dequeueReusableCellWithIdentifier("TaskDetailContentCell") as TaskDetailContentCell
            return cell
        }
        return tableView.dequeueReusableCellWithIdentifier("TaskDetailCompleteCell") as UITableViewCell
    }
}