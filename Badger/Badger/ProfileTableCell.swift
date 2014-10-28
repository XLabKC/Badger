import UIKit

class ProfileTableCell: UITableViewCell, UIScrollViewDelegate {

    private let TopPadding = CGFloat(300)

    private var panels: [UIView]
    private var handle: FirebaseHandle?
    private var uidRef: Firebase?
    private var editable = false

    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    required init(coder aDecoder: NSCoder) {

        panels = [UIView(), UIView(), UIView()]
        panels[0].backgroundColor = UIColor.redColor()
        panels[1].backgroundColor = UIColor.yellowColor()
        panels[2].backgroundColor = UIColor.greenColor()

        super.init(coder: aDecoder)

        for panel in panels {
            panel.frame = self.frame
            panel.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
        }

        self.addLabel(panels[0], text: "Unavailable")
        self.addLabel(panels[1], text: "Occupied")
        self.addLabel(panels[2], text: "Free")

        self.backgroundColor = UIColor.grayColor()
        self.selectionStyle = .None
    }

    deinit {
        if let uidRef = self.uidRef? {
            uidRef.removeAllObservers()
        }
    }

    // Setup is separate because scrollview is undefined in init.
    func setup(uid:String) {
        self.uidRef = Firebase(url: Global.FirebaseUsersUrl).childByAppendingPath(uid)
        self.editable = Global.AuthData!.uid == uid

        self.scrollview.contentInset = UIEdgeInsets(top: -TopPadding, left: 0, bottom: 0, right: 0)
        self.scrollview.scrollEnabled = self.editable

        // Set size of scrollview content.
        let width = UIScreen.mainScreen().bounds.size.width
        let height = self.frame.size.height + TopPadding
        self.scrollview.contentSize = CGSize(width: width * 3, height: height)

        // Add panels.
        for (index, panel) in enumerate(panels) {
            panel.frame = CGRectMake(CGFloat(index) * width, 0, width, height)
            self.scrollview.addSubview(panel)
        }

        // Pull Firebase data.
        let uidRef = self.uidRef!
        uidRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            let index = self.statusToIndex(snapshot.value.objectForKey("status") as String)
            self.updateScrollviewForStatus(index)

            let firstName = snapshot.value.objectForKey("first_name") as String!
            let lastName = snapshot.value.objectForKey("last_name") as String!
            self.nameLabel.text = "\(firstName) \(lastName)"
        })
        if self.editable {
            let statusRef = uidRef.childByAppendingPath("status")
            statusRef.observeEventType(.Value, withBlock: { snapshot in
                self.updateScrollviewForStatus(snapshot.value as String)
            })
        }
    }

    func updateScrollviewForStatus(status:String) {
        self.updateScrollviewForStatus(self.statusToIndex(status))
    }

    func updateScrollviewForStatus(index:Int) {
        let width = UIScreen.mainScreen().bounds.size.width
        self.scrollview.contentOffset = CGPointMake(CGFloat(index) * width, 0)
    }

    // Convert status string to an index.
    func statusToIndex(status:String) -> Int {
        switch status {
        case "red":
            return 0
        case "yellow":
            return 1
        default:
            return 2
        }
    }

    func addLabel(view: UIView, text:String) {
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

    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}