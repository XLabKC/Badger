import UIKit

class TaskEditTitleCell: BorderedCell, InputCell, UITextFieldDelegate {
    private var hasAwakened = false
    weak var delegate: InputCellDelegate?

    @IBOutlet weak var titleTextField: UITextField!

    override func awakeFromNib() {
        self.titleTextField.delegate = self
        self.hasAwakened = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow", name: UIKeyboardDidShowNotification, object: nil)
    }

    func getText() -> String {
        return self.titleTextField.text
    }

    func setText(text: String) {
        self.titleTextField.text = text
    }

    func closeKeyboard() {
        self.titleTextField.resignFirstResponder()
    }

    func openKeyboard() {
        self.titleTextField.becomeFirstResponder()
    }

    func keyboardDidShow() {
        if self.titleTextField.editing {
            if let delegate = self.delegate? {
                delegate.cellDidBeginEditing(self)
            }
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let delegate = self.delegate? {
            delegate.shouldSelectNext(self)
        }
        return false
    }
}