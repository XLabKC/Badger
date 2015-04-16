import UIKit

class TaskDetailContentCell: BorderedCell {
    private let minVerticalPadding: CGFloat = 40.0
    private let minTextHeight: CGFloat = 24.0
    
    private var hasAwakened = false
    private var task: Task?

    @IBOutlet weak var contentTextView: UITextView!

    override func awakeFromNib() {
        self.hasAwakened = true
        self.updateView()
    }

    func setTask(task: Task) {
        self.task = task
        self.updateView()
    }

    func calculateCellHeight() -> CGFloat {
        return Helpers.calculateTextViewHeight(self.contentTextView, minVerticalPadding: self.minVerticalPadding, minTextHeight: self.minTextHeight)
    }

    private func updateView() {
        if self.hasAwakened {
            if let task = self.task {
                self.contentTextView.text = task.content
            }
        }
    }
}