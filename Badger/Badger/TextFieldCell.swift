import UIKit

class TextFieldCell: InputCell, UITextFieldDelegate  {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.textField.delegate = self
    }

    override func getText() -> String {
        return self.textField.text
    }

    override func setText(text: String) {
        self.textField.text = text
    }

    override func closeKeyboard() {
        self.textField.resignFirstResponder()
    }

    override func openKeyboard() {
        self.textField.becomeFirstResponder()
    }

    override func keyboardDidShow() {
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