import UIKit

class TeamMemberCell: BorderedCell {
    private var hasAwakened = false

    @IBOutlet weak var profileCircle: ProfileCircle!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var metaLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.hasAwakened = true
        self.setBottomBorder(.Full)
        self.setBorderColor(Color.colorize(0xE0E0E0, alpha: 1))
        self.updateView()
    }

    private func updateView() {

    }
}
