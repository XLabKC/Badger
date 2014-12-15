import UIKit

protocol TaskEditSubmitCellDelegate: class {
    func editSubmitCellSubmitted(cell: TaskEditSubmitCell)
}

class TaskEditSubmitCell: UITableViewCell {
    weak var delegate: TaskEditSubmitCellDelegate?

    @IBAction func submitClicked(sender: AnyObject) {
        if let delegate = self.delegate {
            delegate.editSubmitCellSubmitted(self)
        }
    }
}