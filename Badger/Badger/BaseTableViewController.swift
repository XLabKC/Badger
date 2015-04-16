import UIKit

class BaseTableViewController: UITableViewController {

    internal let sectionHeaderHeight: CGFloat = 40.0

    func fontForHeader() -> UIFont? {
        return UIFont(name: "BrandonGrotesque-Medium", size: 14.0)
    }

    func textColorForHeader() -> UIColor {
        return Color.colorize(0x929292, alpha: 1)
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, sectionHeaderHeight))
        let label = UILabel(frame: CGRectMake(8, 0, tableView.frame.size.width - 16, sectionHeaderHeight))
        label.font = self.fontForHeader()
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        label.textColor = self.textColorForHeader()
        view.addSubview(label)
        view.backgroundColor = UIColor.clearColor()
        return view
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeaderHeight
    }
}