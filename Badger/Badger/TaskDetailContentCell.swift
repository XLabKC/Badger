import UIKit

class TaskDetailContentCell: BorderedCell {
    private var hasAwakened = false
    private var task: Task?

    @IBOutlet weak var contentTextView: UITextView!

    override func awakeFromNib() {
        self.hasAwakened = true
        self.updateView()
        self.setBottomBorder(.Full)
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
            contentTextView.text = task.content
        }
    }
}