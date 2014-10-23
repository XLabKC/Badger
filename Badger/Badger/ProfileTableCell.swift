import UIKit

class ProfileTableCell: UITableViewCell {

    let TopPadding = CGFloat(300)

    var panels: [UIView]

    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var label: UILabel!

    required init(coder aDecoder: NSCoder) {
        panels = [UIView(), UIView(), UIView()]
        panels[0].backgroundColor = UIColor.redColor()
        panels[1].backgroundColor = UIColor.yellowColor()
        panels[2].backgroundColor = UIColor.greenColor()

        super.init(coder: aDecoder)

        self.backgroundColor = UIColor.grayColor()
    }

    func setup() {
        self.scrollview.contentInset = UIEdgeInsets(top: -TopPadding, left: 0, bottom: 0, right: 0)

        // Set size of scrollview content.
        let width = UIScreen.mainScreen().bounds.size.width
        let height = UIScreen.mainScreen().bounds.size.height + TopPadding
        self.scrollview.contentSize = CGSize(width: width * 3, height: height)

        // Add panels.
        for (index, panel) in enumerate(panels) {
            panel.frame = CGRectMake(CGFloat(index) * width, 0, width, height)
            self.scrollview.addSubview(panel)
        }
    }
}