import UIKit

class TaskCell: BorderedCell {
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
    @IBOutlet weak var checkmarkIcon: UIImageView!

    override func awakeFromNib() {
        self.hasAwakened = true
        self.setBottomBorder(.Full)
        self.setBorderColor(Color.colorize(0xE0E0E0, alpha: 1))
        self.updateView()
    }

    func setTask(task: Task) {
        self.task = task
        self.updateView()
    }

    func getTask() -> Task? {
        return self.task
    }

    func updateView() {
        if self.hasAwakened {
            if let task = self.task? {
                if task.active {
                    self.priorityHighLabel.hidden = false
                    self.priorityMediumLabel.hidden = false
                    self.priorityLowLabel.hidden = false
                    self.checkmarkIcon.hidden = true
                    self.priorityHighLabel.textColor = inactiveColor
                    self.priorityMediumLabel.textColor = inactiveColor
                    self.priorityLowLabel.textColor = inactiveColor
                    switch task.priority {
                    case .High:
                        self.priorityHighLabel.textColor = Colors.UnavailableStatus
                    case .Medium:
                        self.priorityMediumLabel.textColor = Colors.OccupiedStatus
                    case .Low:
                        self.priorityLowLabel.textColor = Colors.FreeStatus
                    default:
                        break
                    }
                } else {
                    self.priorityHighLabel.hidden = true
                    self.priorityMediumLabel.hidden = true
                    self.priorityLowLabel.hidden = true
                    self.checkmarkIcon.hidden = false
                }
                self.titleLabel.text = task.title
                self.contentLabel.text = task.content
                self.profileCircle.setUid(task.author)
                self.metaLabel.text = task.timestampString
            }
        }
    }
}
