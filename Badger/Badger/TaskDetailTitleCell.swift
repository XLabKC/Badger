import UIKit

class TaskDetailTitleCell: BorderedCell {
    private let inactiveColor = Color.colorize(0xCFCFCF, alpha: 1)

    private var hasAwakened = false
    private var task: Task?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var mediumLabel: UILabel!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var checkmarkIcon: UIImageView!

    override func awakeFromNib() {
        self.hasAwakened = true
        self.updateView()
    }

    func setTask(task: Task) {
        self.task = task
        self.updateView()
    }

    private func updateView() {
        if self.hasAwakened {
            if let task = self.task {
                if task.active {
                    self.highLabel.hidden = false
                    self.mediumLabel.hidden = false
                    self.lowLabel.hidden = false
                    self.checkmarkIcon.hidden = true
                    self.highLabel.textColor = inactiveColor
                    self.mediumLabel.textColor = inactiveColor
                    self.lowLabel.textColor = inactiveColor
                    switch task.priority {
                    case .High:
                        self.highLabel.textColor = Colors.UnavailableStatus
                    case .Medium:
                        self.mediumLabel.textColor = Colors.OccupiedStatus
                    case .Low:
                        self.lowLabel.textColor = Colors.FreeStatus
                    default:
                        break
                    }
                } else {
                    self.highLabel.hidden = true
                    self.mediumLabel.hidden = true
                    self.lowLabel.hidden = true
                    self.checkmarkIcon.hidden = false
                }


                self.titleLabel.text = task.title
            }
        }
    }
}