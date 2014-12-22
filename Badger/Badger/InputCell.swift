protocol InputCell: class {
    func openKeyboard()
    func closeKeyboard()
    func setText(text: String)
    func getText() -> String
}

protocol InputCellDelegate: class {
    func shouldSelectNext(cell: InputCell)
    func cellDidBeginEditing(cell: InputCell)
}
