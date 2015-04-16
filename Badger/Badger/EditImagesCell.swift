import UIKit

protocol EditImagesCellDelegate: class {
    func editImagesCellLogoClicked(cell: EditImagesCell)
    func editImagesCellHeaderBackgroundClicked(cell: EditImagesCell)
}

class EditImagesCell: BorderedCell {
    private var hasAwakened = false
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var logoLabel: UILabel!

    weak var delegate: EditImagesCellDelegate?

    override func awakeFromNib() {
        self.hasAwakened = true

        let borderColor = Color.colorize(0xECECEC, alpha: 1.0).CGColor
        self.logoImage.layer.borderColor = borderColor
        self.logoImage.layer.borderWidth = 1
        self.logoImage.layer.cornerRadius = self.logoImage.frame.height / 2.0
        self.headerImage.layer.borderColor = borderColor
        self.headerImage.layer.borderWidth = 1
    }

    @IBAction func logoClicked(sender: AnyObject) {
        if let delegate = self.delegate {
            delegate.editImagesCellLogoClicked(self)
        }
    }

    @IBAction func headerClicked(sender: AnyObject) {
        if let delegate = self.delegate {
            delegate.editImagesCellHeaderBackgroundClicked(self)
        }
    }
}
