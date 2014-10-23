import UIKit

class UserTableCell: UITableViewCell {

    @IBOutlet weak internal var label: UILabel!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}