import UIKit

protocol TaskDetailCompleteCellDelegate: class {
    func detailCompleteCellPressed(cell: TaskDetailCompleteCell)
}

class TaskDetailCompleteCell: UITableViewCell {
    weak var delegate: TaskDetailCompleteCellDelegate?

    @IBOutlet weak var button: ResizedImageButton!

    var buttonTitle: String? {
        get {
            return self.button.titleForState(.Normal)
        }
        set(title) {
            self.button.setTitle(title, forState: .Normal)
        }
    }

    @IBAction func buttonPressed(sender: AnyObject) {
        if let delegate = self.delegate {
            delegate.detailCompleteCellPressed(self)
        }
    }
}