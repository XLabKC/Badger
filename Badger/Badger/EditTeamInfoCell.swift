import UIKit

protocol EditTeamInfoCellDelegate: class {
    func editTeamInfoCellLogoClicked(cell: EditTeamInfoCell)
    func editTeamInfoCellHeaderBackgroundClicked(cell: EditTeamInfoCell)
}

class EditTeamInfoCell: BorderedCell {
    private var hasAwakened = false
    private var nameInternal = ""

    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!

    weak var delegate: EditTeamInfoCellDelegate?

    var name: String {
        get {
            return self.nameInternal
        }
        set (value) {
            self.nameInternal = value
            if self.hasAwakened {
                self.nameTextField.text = value
            }
        }
    }

    override func awakeFromNib() {
        self.hasAwakened = true
        self.nameTextField.text = self.nameInternal
    }

    @IBAction func logoClicked(sender: AnyObject) {
        if let delegate = self.delegate? {
            delegate.editTeamInfoCellLogoClicked(self)
        }
    }

    @IBAction func headerClicked(sender: AnyObject) {
        if let delegate = self.delegate? {
            delegate.editTeamInfoCellHeaderBackgroundClicked(self)
        }
    }
}
