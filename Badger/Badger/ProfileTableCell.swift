import UIKit

protocol ProfileTableCellDelegate {
    func updateUserStatus(user: User, status: String)
    func showMessagesForUser(user: User)
}

class ProfileTableCell: UITableViewCell, UIScrollViewDelegate {

    private let TopPadding = CGFloat(300)
    private let SetDelay = 2.0

    private var panels: [UIView]
    private var user: User?
    private var currentStatus = "green"
    private var editable: Bool {
        get {
            return self.scrollview.scrollEnabled
        }
        set(state) {
            self.scrollview.scrollEnabled = state
        }
    }

    // This is used to simulate cancelling the dispatched block.
    private var activeTimeout = arc4random()

    var delegate: ProfileTableCellDelegate?

    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    required init(coder aDecoder: NSCoder) {
        panels = [UIView(), UIView(), UIView()]
//        panels[0].backgroundColor = UIColor.redColor()
//        panels[1].backgroundColor = UIColor.yellowColor()
//        panels[2].backgroundColor = UIColor.greenColor()

        super.init(coder: aDecoder)

        for panel in panels {
            panel.frame = self.frame
            panel.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
        }

        self.addLabel(panels[0], text: "Unavailable")
        self.addLabel(panels[1], text: "Occupied")
        self.addLabel(panels[2], text: "Free")

//        self.backgroundColor = UIColor.grayColor()
        self.selectionStyle = .None
    }

    // Setup is separate because scrollview is undefined in init.
    func setup(editable: Bool) {
        self.scrollview.contentInset = UIEdgeInsets(top: -TopPadding, left: 0, bottom: 0, right: 0)
        self.scrollview.delegate = self
        self.editable = editable

        // Set size of scrollview content.
        let width = UIScreen.mainScreen().bounds.size.width
        let height = self.frame.size.height + TopPadding
        self.scrollview.contentSize = CGSize(width: width * 3, height: height)

        // Add panels.
        for (index, panel) in enumerate(panels) {
            panel.frame = CGRectMake(CGFloat(index) * width, 0, width, height)
            self.scrollview.addSubview(panel)
        }
    }

    func setUser(user: User) {
        self.user = user
        self.nameLabel.text = "\(user.first_name) \(user.last_name)"
        self.currentStatus = user.status
        self.updateScrollviewForStatus(user.status)
    }

    func updateScrollviewForStatus(status:String) {
        self.updateScrollviewForStatus(self.statusToIndex(status))
    }

    func updateScrollviewForStatus(index:Int) {
        let width = UIScreen.mainScreen().bounds.size.width
        self.scrollview.contentOffset = CGPointMake(CGFloat(index) * width, 0)
    }

    // Convert status string to an index.
    private func statusToIndex(status:String) -> Int {
        switch status {
        case "red":
            return 0
        case "yellow":
            return 1
        default:
            return 2
        }
    }

    private func indexToStatus(index:Int) -> String {
        let values = ["red", "yellow", "green"]
        return values[index]
    }

    private func addLabel(view: UIView, text:String) {
        let height = view.frame.height
        let label = UILabel(frame: CGRectMake(0, height - 200, view.frame.width, 40))
        label.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleTopMargin |
            UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleRightMargin
        label.text = text
        label.textColor = UIColor.whiteColor()
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont(name: "HelveticaNeue-Bold", size: CGFloat(25));
        view.addSubview(label)
        view.layoutSubviews()
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        // Make sure there's a user.
        if self.user == nil {
            return
        }

        let currentActiveTimeout = self.activeTimeout
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(SetDelay * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue(), {

            // Use this to find out if this dispatched event is the most recent.
            if self.activeTimeout != currentActiveTimeout {
                return
            }
            let status = self.indexToStatus(Int(round(self.scrollview.contentOffset.x / self.frame.width)))
            if status != self.currentStatus {
                println("set status from \(self.currentStatus) to \(status)")
                self.currentStatus = status
                if let delegate = self.delegate? {
                    delegate.updateUserStatus(self.user!, status: status)
                }
            }
        })
    }

//    @IBAction func showMessages(sender: AnyObject) {
//        if self.delegate != nil && self.user != nil {
//            self.delegate!.showMessagesForUser(self.user!)
//        }
//    }

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.activeTimeout = arc4random()
    }

    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}