import UIKit

class TaskEditPriorityCell: BorderedCell {
    private let inactiveColor = Color.colorize(0x929292, alpha: 1.0)
    private var hasAwakened = false
    private var priority = TaskPriority.Low

    @IBOutlet weak var lowButton: UIButton!
    @IBOutlet weak var mediumButton: UIButton!
    @IBOutlet weak var highButton: UIButton!

    override func awakeFromNib() {
        self.hasAwakened = true
        self.updateView()
    }

    func setTask(task: Task) {
        self.priority = task.priority
        self.updateView()
    }

    func getPriority() -> TaskPriority {
        return self.priority
    }

    func setPriority(priority: TaskPriority) {
        self.priority = priority
        self.updateView()
    }

    @IBAction func lowSelected(sender: AnyObject) {
        self.setPriority(.Low)
    }

    @IBAction func mediumSelected(sender: AnyObject) {
        self.setPriority(.Medium)
    }
    
    @IBAction func highSelected(sender: AnyObject) {
        self.setPriority(.High)
    }

    private func updateView() {
        if self.hasAwakened {
            self.lowButton.setTitleColor(self.inactiveColor, forState: .Normal)
            self.mediumButton.setTitleColor(self.inactiveColor, forState: .Normal)
            self.highButton.setTitleColor(self.inactiveColor, forState: .Normal)
            switch self.priority {
            case .High:
                self.highButton.setTitleColor(Colors.UnavailableStatus, forState: .Normal)
                break
            case .Medium:
                self.mediumButton.setTitleColor(Colors.OccupiedStatus, forState: .Normal)
                break
            case .Low:
                self.lowButton.setTitleColor(Colors.FreeStatus, forState: .Normal)
                break
            default:
                break
            }
        }
    }
}