import UIKit

class TaskEditPriorityCell: BorderedCell {
    private var hasAwakened = false

    override func awakeFromNib() {
        self.hasAwakened = true
        self.updateView()
        self.setTopBorder(.Full)
        self.setBottomBorder(.Inset)
        self.setBorderColor(Color.colorize(0xE1E1E1, alpha: 1))
    }

    private func updateView() {

    }
}