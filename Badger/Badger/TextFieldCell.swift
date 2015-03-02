import UIKit

class TextFieldCell: BorderedCell, InputCell, UITextFieldDelegate  {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    weak var delegate: InputCellDelegate?

    override func awakeFromNib() {
        self.textField.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow", name: UIKeyboardDidShowNotification, object: nil)
    }

    func getText() -> String {
        return self.textField.text
    }

    func setText(text: String) {
        self.textField.text = text
    }

    func closeKeyboard() {
        self.textField.resignFirstResponder()
    }

    func openKeyboard() {
        self.textField.becomeFirstResponder()
    }

    func keyboardDidShow() {
        if self.textField.editing {
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