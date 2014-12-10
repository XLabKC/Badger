import UIKit

protocol TaskEditSubmitCellDelegate: class {
    func editSubmitCellSubmitted(cell: TaskEditSubmitCell)
}

class TaskEditSubmitCell: UITableViewCell {
    var delegate: TaskEditSubmitCellDelegate?
}