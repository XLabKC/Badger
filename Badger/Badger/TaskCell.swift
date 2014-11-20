import UIKit

class TaskCell: UITableViewCell {
    private var task: Task?

    @IBOutlet weak var profileCircle: ProfileCircle!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: NSLayoutConstraint!
    @IBOutlet weak var metaLabel: UILabel!
    @IBOutlet weak var priorityHighLabel: UILabel!
    @IBOutlet weak var priorityMediumLabel: UILabel!
    @IBOutlet weak var priorityLowLabel: UILabel!

    func setTask(task: Task) {
        self.task = task
        self.updateView()
    }

    func updateView() {
        if let task = self.task {
            task.priority
        }
    }
}
