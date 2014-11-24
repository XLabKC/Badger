import UIKit

class HeaderCell : UITableViewCell {

    @IBOutlet weak var headerLabel: UILabel!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.userInteractionEnabled = false
    }

    var title: String? {
        get {
            return self.headerLabel.text
        }
        set(title) {
            self.headerLabel.text = title
        }
    }

    var labelColor: UIColor! {
        get {
            return self.headerLabel.textColor
        }
        set(color) {
            self.headerLabel.textColor = color
        }
    }
}