import UIKit

class SelectBackgroundCell: UITableViewCell {
    private var backgroundColorView = UIView()

    @IBInspectable var selectedColor: UIColor {
        get {
            return self.backgroundColorView.backgroundColor!
        }
        set(color) {
            self.backgroundColorView.backgroundColor = color
        }
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColorView.backgroundColor = UIColor.clearColor()
        self.selectedBackgroundView = self.backgroundColorView
    }
}