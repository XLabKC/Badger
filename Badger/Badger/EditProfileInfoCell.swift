import UIKit

protocol EditProfileInfoCellDelegate: class {
    func editProfileInfoCellLogoClicked(cell: EditProfileInfoCell)
    func editProfileInfoCellHeaderBackgroundClicked(cell: EditProfileInfoCell)
}

class EditProfileInfoCell: BorderedCell {
    private var hasAwakened = false
    private var nameInternal = ""
    private var showNameCellBackgroundInternal = false

    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var nameBackgroundCell: UIView!

    weak var delegate: EditProfileInfoCellDelegate?

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

    var showNameCellBackground: Bool {
        get {
            return self.showNameCellBackgroundInternal
        }
        set (value) {
            self.showNameCellBackgroundInternal = value
            if self.hasAwakened {
                self.nameBackgroundCell.hidden = !value
            }
        }
    }

    override func awakeFromNib() {
        self.hasAwakened = true
        self.nameTextField.text = self.nameInternal
        self.nameBackgroundCell.hidden = !self.showNameCellBackgroundInternal

        // Create the name background cell's border.
        let frame = self.nameBackgroundCell.frame
        let borderView = UIView(frame: CGRectMake(0, frame.height - 0.5, frame.width, 0.5))
        borderView.backgroundColor = UIColor.clearColor()
        borderView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleTopMargin
        borderView.backgroundColor = Color.colorize(0xE1E1E1, alpha: 1.0)
        self.nameBackgroundCell.addSubview(borderView)
    }

    @IBAction func logoClicked(sender: AnyObject) {
        if let delegate = self.delegate? {
            delegate.editProfileInfoCellLogoClicked(self)
        }
    }

    @IBAction func headerClicked(sender: AnyObject) {
        if let delegate = self.delegate? {
            delegate.editProfileInfoCellHeaderBackgroundClicked(self)
        }
    }
}
