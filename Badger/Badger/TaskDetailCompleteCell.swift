import UIKit

protocol TaskDetailCompleteCellDelegate: class {
    func detailCompleteCellPressed(cell: TaskDetailCompleteCell)
}

class TaskDetailCompleteCell: UITableViewCell {
    var delegate: TaskDetailCompleteCellDelegate?

    @IBAction func buttonPressed(sender: AnyObject) {
        if let delegate = self.delegate {
            delegate.detailCompleteCellPressed(self)
        }
    }
}