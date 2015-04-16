import UIKit

class TextFieldCell: InputCell, UITextFieldDelegate  {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.textField.delegate = self
    }

    override func getContent() -> String {
        return self.textField.text
    }

    override func setContent(text: String) {
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
            self.delegate?.cellDidBeginEditing(self)
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.delegate?.shouldSelectNext(self)
        return false
    }
}