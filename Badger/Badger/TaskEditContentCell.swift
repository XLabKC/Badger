import UIKit

protocol TaskEditContentCellDelegate: class {
    func editContentCell(cell: TaskEditContentCell, hasChangedHeight: CGFloat);
}

class TaskEditContentCell: BorderedCell, UITextViewDelegate {
    private let minTopBottomPadding: CGFloat = 59.0
    private let minTextHeight: CGFloat = 24.0

    private var hasAwakened = false
    private var task: Task?
    private var currentHeight: CGFloat = 0

    var delegate: TaskEditContentCellDelegate?

    @IBOutlet weak var textView: UITextView!

    override func awakeFromNib() {
        self.hasAwakened = true
        self.updateView()

        self.textView.delegate = self
        self.textViewDidChange(self.textView)
    }

    func calculateCellHeight() -> CGFloat {
        var frame = self.textView.bounds

        // Take account of the padding added around the text.
        var textContainerInsets = self.textView.textContainerInset
        var contentInsets = self.textView.contentInset

        var leftRightPadding = textContainerInsets.left + textContainerInsets.right + self.textView.textContainer.lineFragmentPadding * 2 + contentInsets.left + contentInsets.right

        var topBottomPadding = CGFloat(textContainerInsets.top + textContainerInsets.bottom + contentInsets.top + contentInsets.bottom) + self.textView.superview!.frame.height - frame.height

        frame.size.width -= leftRightPadding;

        var textToMeasure = self.textView.text as NSString
        if textToMeasure.hasSuffix("\n") {
            textToMeasure = "\(textToMeasure)-" as NSString
        }

        // NSString class method: boundingRectWithSize:options:attributes:context is
        // available only on ios7.0 sdk.
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .ByWordWrapping

        var attributes = [
            NSFontAttributeName: self.textView.font,
            NSParagraphStyleAttributeName: paragraphStyle
        ]

        var size = textToMeasure.boundingRectWithSize(CGSizeMake(frame.width, CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributes, context: nil)
        size.size.height = size.height < minTextHeight ? minTextHeight : size.height
        topBottomPadding = topBottomPadding < minTopBottomPadding ? minTopBottomPadding : topBottomPadding

        return ceil(size.height + topBottomPadding)
    }

    func textViewDidChange(textView: UITextView) {
        self.textView.scrollRectToVisible(CGRectMake(0, 0, self.textView.frame.width, 24), animated: true)
        let newHeight = self.calculateCellHeight()
        if self.currentHeight != newHeight {
            self.currentHeight = newHeight
            if let delegate = self.delegate? {
                delegate.editContentCell(self, hasChangedHeight: self.currentHeight)
            }
        }
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

