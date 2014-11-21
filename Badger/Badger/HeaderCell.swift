import UIKit

class HeaderCell : UITableViewCell {

    @IBOutlet weak var headerLabel: UILabel!

    var title: String? {
        get {
            return self.headerLabel.text
        }
        set(title) {
            self.headerLabel.text = title
        }
    }
}