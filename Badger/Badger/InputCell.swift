protocol InputCellDelegate: class {
    func shouldSelectNext(cell: InputCell)
    func cellDidBeginEditing(cell: InputCell)
}

class InputCell: BorderedCell {
    weak var delegate: InputCellDelegate?

    override func awakeFromNib() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow", name: UIKeyboardDidShowNotification, object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func openKeyboard() {
    }

    func closeKeyboard() {
    }

    func setContent(text: String) {
    }

    func getContent() -> String {
        return ""
    }

    func keyboardDidShow() {
    }

}
