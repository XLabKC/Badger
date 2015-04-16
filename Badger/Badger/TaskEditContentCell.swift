import UIKit

protocol TaskEditContentCellDelegate: InputCellDelegate {
    func editContentCell(cell: TaskEditContentCell, hasChangedHeight: CGFloat);
}

class TaskEditContentCell: InputCell, UITextViewDelegate {
    private let minVerticalPadding: CGFloat = 59.0
    private let minTextHeight: CGFloat = 24.0

    private var hasAwakened = false
    private var textToSet: String?
    private var currentHeight: CGFloat = 0

    weak var cellDelegate: TaskEditContentCellDelegate?

    @IBOutlet weak var textView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.hasAwakened = true
        if let text = self.textToSet {
            self.textView.text = text
        }
        self.textView.delegate = self
        self.textViewDidChange(self.textView)
    }

    func textViewDidChange(textView: UITextView) {
        let newHeight = self.calculateCellHeight()
        if self.currentHeight != newHeight {
            self.currentHeight = newHeight
            self.cellDelegate?.editContentCell(self, hasChangedHeight: self.currentHeight)
        }
        self.textView.scrollRectToVisible(CGRectMake(0, 0, self.textView.frame.width, 1), animated: true)
    }

    func textViewDidBeginEditing(textView: UITextView) {
        self.delegate?.cellDidBeginEditing(self)
    }

    func calculateCellHeight() -> CGFloat {
        return Helpers.calculateTextViewHeight(self.textView, minVerticalPadding: self.minVerticalPadding, minTextHeight: self.minTextHeight)
    }

    override func setContent(text: String) {
        if self.hasAwakened {
            self.textView.text = text
        } else {
            self.textToSet = text
        }

    }

    override func getContent() -> String {
        return self.textView.text
    }

    override func closeKeyboard() {
        self.textView.resignFirstResponder()
    }

    override func openKeyboard() {
        self.textView.becomeFirstResponder()
    }
}

