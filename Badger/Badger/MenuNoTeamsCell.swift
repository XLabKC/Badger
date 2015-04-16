import UIKit

class MenuNoTeamsCell: BorderedCell {
    private var hasAwakened = false

    override func awakeFromNib() {
        self.hasAwakened = true
        self.setTopBorder(.Full)
        self.setBottomBorder(.Full)
        self.borderColor = Color.colorize(0x0C0C0C, alpha: 1)
    }

}
