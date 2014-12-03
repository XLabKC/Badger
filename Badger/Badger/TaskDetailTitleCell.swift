import UIKit

class TaskDetailTitleCell: BorderedCell {
    private let inactiveColor = Color.colorize(0xCFCFCF, alpha: 1)

    private var hasAwakened = false
    private var task: Task?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var mediumLabel: UILabel!
    @IBOutlet weak var lowLabel: UILabel!

    override func awakeFromNib() {
        self.hasAwakened = true
        self.updateView()
        self.setTopBorder(.Full)
        self.setBottomBorder(.Inset)
        self.setBorderColor(Color.colorize(0xE1E1E1, alpha: 1))
    }

    func setTask(task: Task) {
        self.task = task
        if self.hasAwakened {
            self.updateView()
        }
    }

    private func updateView() {
        if let task = self.task? {
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
            self.titleLabel.text = task.title
        }
    }
}