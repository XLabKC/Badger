import UIKit

protocol TaskEditContentCellDelegate: class {
    func editContentCell(cell: TaskEditContentCell, hasChangedHeight: CGFloat);
}

class TaskEditContentCell: BorderedCell, UITextViewDelegate {
    private let minVerticalPadding: CGFloat = 59.0
    private let minTextHeight: CGFloat = 24.0

    private var hasAwakened = false
    private var task: Task?
    private var currentHeight: CGFloat = 0

    weak var delegate: TaskEditContentCellDelegate?

    @IBOutlet weak var textView: UITextView!

    override func awakeFromNib() {
        self.hasAwakened = true
        self.updateView()

        self.textView.delegate = self
        self.textViewDidChange(self.textView)
    }

    func textViewDidChange(textView: UITextView) {
        let newHeight = self.calculateCellHeight()
        if self.currentHeight != newHeight {
            self.currentHeight = newHeight
            if let delegate = self.delegate? {
                delegate.editContentCell(self, hasChangedHeight: self.currentHeight)
            }
        }
        self.textView.scrollRectToVisible(CGRectMake(0, 0, self.textView.frame.width, 1), animated: true)
    }

    func calculateCellHeight() -> CGFloat {
        return Helpers.calculateTextViewHeight(self.textView, minVerticalPadding: self.minVerticalPadding, minTextHeight: self.minTextHeight)
    }

    func setTask(task: Task) {
        self.task = task
        if self.hasAwakened {
            self.updateView()
        }
    }

    func getContent() -> String {
        return self.textView.text
    }

    private func updateView() {
        if let task = self.task? {
            self.textView.text = task.content
        }
    }
}

