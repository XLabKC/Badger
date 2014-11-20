import UIKit

class TaskCell: UITableViewCell {
    private let inactiveColor = Color.colorize(0xCFCFCF, alpha: 1)
    private var task: Task?
    private var hasAwakened = false

    @IBOutlet weak var profileCircle: ProfileCircle!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var metaLabel: UILabel!
    @IBOutlet weak var priorityHighLabel: UILabel!
    @IBOutlet weak var priorityMediumLabel: UILabel!
    @IBOutlet weak var priorityLowLabel: UILabel!

    override func awakeFromNib() {
        self.hasAwakened = true
        self.updateView()
    }

    func setTask(task: Task) {
        self.task = task
        self.updateView()
    }

    func updateView() {
        if self.hasAwakened && self.task != nil {
            self.priorityHighLabel.textColor = inactiveColor
            self.priorityMediumLabel.textColor = inactiveColor
            self.priorityLowLabel.textColor = inactiveColor
            switch self.task!.priority {
            case .High:
                self.priorityHighLabel.textColor = Colors.UnavailableStatus
            case .Medium:
                self.priorityMediumLabel.textColor = Colors.OccupiedStatus
            case .Low:
                self.priorityLowLabel.textColor = Colors.FreeStatus
            default:
                break
            }
            self.titleLabel.text = task!.title
            self.contentLabel.text = task!.content
            self.profileCircle.setUid(task!.author)
        }
    }
}
