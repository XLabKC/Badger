import UIKit

class ProfileControlsCell: BorderedCell {
    private var hasAwakened = false

    override func awakeFromNib() {
        self.hasAwakened = true
    }

    private func updateView() {
    }
}