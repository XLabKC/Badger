import UIKit

class TaskEditPriorityCell: BorderedCell {
    private var hasAwakened = false

    override func awakeFromNib() {
        self.hasAwakened = true
        self.updateView()
    }

    private func updateView() {

    }
}