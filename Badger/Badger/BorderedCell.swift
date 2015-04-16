import UIKit

public enum BorderedCellStyle: String {
    case Full = "full"
    case Inset = "inset"
    case None = "none"
}

class BorderedCell: SelectBackgroundCell {
    private var lineColor = Color.colorize(0x28292C, alpha: 1)
    private let inset = CGFloat(30.0)

    private var topBorder = BorderedCellStyle.None
    private var bottomBorder = BorderedCellStyle.None
    private let topView = UIView()
    private let bottomView = UIView()

    @IBInspectable var borderColor: UIColor {
        get {
            return self.lineColor
        }
        set(color) {
            self.lineColor = color
            self.setTopBorder(self.topBorder)
            self.setBottomBorder(self.bottomBorder)
        }
    }
    @IBInspectable var topBorderStyle: String {
        get {
            return self.topBorder.rawValue
        }
        set(style) {
            if let newStyle = BorderedCellStyle(rawValue: style) {
                self.setTopBorder(newStyle)
            }
        }
    }
    @IBInspectable var bottomBorderStyle: String {
        get {
            return self.bottomBorder.rawValue
        }
        set(style) {
            if let newStyle = BorderedCellStyle(rawValue: style) {
                self.setBottomBorder(newStyle)
            }
        }
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.topView.backgroundColor = UIColor.clearColor()
        self.topView.frame = CGRectMake(0, 0, self.frame.width, 0.5)
        self.topView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleBottomMargin
        self.addSubview(self.topView)

        self.bottomView.backgroundColor = UIColor.clearColor()
        self.bottomView.frame = CGRectMake(0, self.frame.height - 0.5, self.frame.width, 0.5)
        self.bottomView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleTopMargin
        self.addSubview(self.bottomView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.setTopBorder(self.topBorder)
        self.setBottomBorder(self.bottomBorder)
    }

    func setTopBorder(style: BorderedCellStyle) {
        self.topBorder = style
        switch style {
        case .Full:
            self.topView.backgroundColor = self.lineColor
            self.topView.frame = CGRectMake(0, 0, self.frame.width, 0.5)
        case .Inset:
            self.topView.backgroundColor = self.lineColor
            self.topView.frame = CGRectMake(self.inset, 0, self.frame.width - self.inset, 0.5)
        case .None:
            self.topView.backgroundColor = UIColor.clearColor()
        }
    }

    func setBottomBorder(style: BorderedCellStyle) {
        self.bottomBorder = style
        switch style {
        case .Full:
            self.bottomView.backgroundColor = self.lineColor
            self.bottomView.frame = CGRectMake(0, self.frame.height - 0.5, self.frame.width, 0.5)
        case .Inset:
            self.bottomView.backgroundColor = self.lineColor
            self.bottomView.frame = CGRectMake(self.inset, self.frame.height - 0.5, self.frame.width - self.inset, 0.5)
        case .None:
            self.bottomView.backgroundColor = UIColor.clearColor()
        }
    }
}