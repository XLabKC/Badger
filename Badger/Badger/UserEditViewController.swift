import UIKit

private enum Rows: Int {
    case ProfileHeader = 0
    case FirstName = 1
    case LastName = 2
    case Email = 3
    case Images = 4
    case StatusHeader = 5
    case FreeStatus = 6
    case OccupiedStatus = 7
    case UnavailableStatus = 8
}

class UserEditViewController: UITableViewController, InputCellDelegate, EditImagesCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLUploaderDelegate {
    private let headerCellHeight: CGFloat = 40.0
    private let editImagesCellHeight: CGFloat = 154.0
    private let normalCellHeight: CGFloat = 72.0
    private let imageDimension = 260

    private var cells = [UITableViewCell?](count: 9, repeatedValue: nil)
    private let picker = UIImagePickerController()
    private var pickerHandler: (UIImage? -> ())?

    private var useDefaultProfile = true
    private var useDefaultHeader = true

    private var editedProfileImage = false
    private var editedHeaderImage = false

    private var saveFunctionsToRun: [() -> ()] = []
    private var isSaving = false

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.picker.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cells.
        let loadingCellNib = UINib(nibName: "LoadingCell", bundle: nil)
        self.tableView.registerNib(loadingCellNib, forCellReuseIdentifier: "LoadingCell")

        let userProfileHeaderCellNib = UINib(nibName: "UserProfileHeaderCell", bundle: nil)
        self.tableView.registerNib(userProfileHeaderCellNib, forCellReuseIdentifier: "UserProfileHeaderCell")

        let headerCellNib = UINib(nibName: "HeaderCell", bundle: nil)
        self.tableView.registerNib(headerCellNib, forCellReuseIdentifier: "HeaderCell")

        let editImagesCellNib = UINib(nibName: "EditImagesCell", bundle: nil)
        self.tableView.registerNib(editImagesCellNib, forCellReuseIdentifier: "EditImagesCell")

        let textFieldCellNib = UINib(nibName: "TextFieldCell", bundle: nil)
        self.tableView.registerNib(textFieldCellNib, forCellReuseIdentifier: "TextFieldCell")

        let user = UserStore.sharedInstance().getAuthUser()
        self.useDefaultHeader = user.headerImage == ""
        self.useDefaultProfile = user.profileImages[.Free] == nil || user.profileImages[.Free] == ""

        // Set up navigation bar.
        self.navigationItem.titleView = Helpers.createTitleLabel("Edit Profile")
    }

    // TableViewController Overrides

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Header + First Name + Last Name + Email + Images + Header + Free + Occupied + Unavailable
        return 9
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.cellForIndex(indexPath.row)
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 || indexPath.row == 5 {
            return self.headerCellHeight
        }
        if indexPath.row == 4 {
            return self.editImagesCellHeight
        }
        return self.normalCellHeight
    }

    @IBAction func cancelClicked(sender: AnyObject) {
        if self.isSaving {
            return
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func doneClicked(sender: AnyObject) {
        if self.isSaving {
            return
        }
        self.isSaving = true

        self.saveFunctionsToRun.removeAll(keepCapacity: true)
        var user = UserStore.sharedInstance().getAuthUser()

        let firstNameCell = self.cells[Rows.FirstName.rawValue] as! TextFieldCell
        let lastNameCell = self.cells[Rows.LastName.rawValue] as! TextFieldCell
        let emailCell = self.cells[Rows.Email.rawValue] as! TextFieldCell
        let freeStatusCell = self.cells[Rows.FreeStatus.rawValue] as! TextFieldCell
        let occupiedStatusCell = self.cells[Rows.OccupiedStatus.rawValue] as! TextFieldCell
        let unavailableStatusCell = self.cells[Rows.UnavailableStatus.rawValue] as! TextFieldCell

        var updates = [
            "first_name": firstNameCell.textField.text,
            "last_name": lastNameCell.textField.text,
            "email": emailCell.textField.text,
            "free_text": freeStatusCell.textField.text,
            "occupied_text": occupiedStatusCell.textField.text,
            "unavailable_text": unavailableStatusCell.textField.text
        ]

        let imagesCell = self.cells[Rows.Images.rawValue] as! EditImagesCell

        // Function to run next in series.
        let startNext: () -> () = {
            let fn = self.saveFunctionsToRun.removeAtIndex(0)
            fn()
        }

        // Function to update profile image.
        let uploadProfileFn: () -> () = {
            let data = UIImageJPEGRepresentation(imagesCell.logoImage.image!, 0.8)
            let uploader = CLUploader(ApiKeys.getCloudinaryInstance(), delegate: self)
            let activityView = self.createActivityView(imagesCell.logoImage)
            
            uploader.upload(data, options: nil,
                withCompletion: { (successResult, errorResult, code, context) in
                    if errorResult != nil {
                        println(errorResult)
                    } else {
                        let publicId = successResult["public_id"] as! String
                        let format = successResult["format"] as! String
                        let url = "\(publicId).\(format)"
                        updates["free_profile_image"] = url
                        updates["occupied_profile_image"] = url
                        updates["unavailable_profile_image"] = url
                    }
                    activityView.stopAnimating()
                    startNext()
                }, andProgress: nil)
        }

        // Function to update header image.
        let uploadHeaderFn: () -> () = {
            let data = UIImageJPEGRepresentation(imagesCell.headerImage.image!, 0.8)
            let uploader = CLUploader(ApiKeys.getCloudinaryInstance(), delegate: self)
            let activityView = self.createActivityView(imagesCell.headerImage)

            uploader.upload(data, options: nil,
                withCompletion: { (successResult, errorResult, code, context) in
                    if errorResult != nil {
                        println(errorResult)
                    } else {
                        let publicId = successResult["public_id"] as! String
                        let format = successResult["format"] as! String
                        updates["header_image"] = "\(publicId).\(format)"
                    }
                    activityView.stopAnimating()
                    startNext()
                }, andProgress: nil)
        }

        // Update profile image.
        if self.editedProfileImage {
            if useDefaultProfile {
                updates["free_profile_image"] = ""
                updates["occupied_profile_image"] = ""
                updates["unavailable_profile_image"] = ""
            } else {
                self.saveFunctionsToRun.append(uploadProfileFn)
            }
        }

        // Update header image.
        if self.editedHeaderImage {
            if useDefaultHeader {
                updates["header_image"] = ""
            } else {
                self.saveFunctionsToRun.append(uploadHeaderFn)
            }
        }

        // Final function to update the Firebase values.
        let updateFn: () -> () = {
            user.ref.updateChildValues(updates) { (error, ref) in
                self.isSaving = false
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }

        self.saveFunctionsToRun.append(updateFn)
        startNext()
    }

    // InputCellDelegate: opens the next cell when the "next" key is pressed on the keyboard.
    func shouldSelectNext(cell: InputCell) {
        cell.closeKeyboard()
    }

    func cellDidBeginEditing(cell: InputCell) {
        var indexPath = NSIndexPath(forRow: self.indexForCell(cell), inSection: 0)
        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
    }

    func editImagesCellLogoClicked(cell: EditImagesCell) {
        self.getNewPhoto() { image in
            self.editedProfileImage = true
            if image == nil {
                self.useDefaultProfile = true
                cell.logoImage.image = UIImage(named: "DefaultUserProfile")
            } else {
                self.useDefaultProfile = false
                cell.logoImage.image = image
            }
        }
    }

    func editImagesCellHeaderBackgroundClicked(cell: EditImagesCell) {
        self.getNewPhoto() { image in
            self.editedHeaderImage = true
            if image == nil {
                self.useDefaultHeader = true
                cell.headerImage.image = UIImage(named: "DefaultBackground")
            } else {
                self.useDefaultHeader = false
                cell.headerImage.image = image
            }
        }
    }

    private func cellForIndex(index: Int) -> UITableViewCell {
        if let cell = self.cells[index] {
            return cell
        }
        let user = UserStore.sharedInstance().getAuthUser()
        let borderColor = Color.colorize(0xE1E1E1, alpha: 1.0)

        let row = Rows(rawValue: index)!
        switch (row) {
        case .ProfileHeader, .StatusHeader:
            let cell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! HeaderCell
            cell.title = index == 0 ? "MY PROFILE" : "STATUSES"
            cell.labelColor = Color.colorize(0x929292, alpha: 1.0)
            self.cells[index] = cell
            return cell
        case .FirstName:
            let cell = tableView.dequeueReusableCellWithIdentifier("TextFieldCell") as! TextFieldCell
            cell.delegate = self
            cell.label.text = "My First Name"
            cell.textField.placeholder = "First Name"
            cell.textField.text = user.firstName
            cell.textField.returnKeyType = .Done
            cell.borderColor = borderColor
            cell.topBorderStyle = "full"
            cell.bottomBorderStyle = "inset"
            self.cells[index] = cell
            return cell
        case .LastName:
            let cell = tableView.dequeueReusableCellWithIdentifier("TextFieldCell") as! TextFieldCell
            cell.delegate = self
            cell.label.text = "My Last Name"
            cell.textField.placeholder = "Last Name"
            cell.textField.text = user.lastName
            cell.textField.returnKeyType = .Done
            cell.borderColor = borderColor
            cell.bottomBorderStyle = "inset"
            self.cells[index] = cell
            return cell
        case .Email:
            let cell = tableView.dequeueReusableCellWithIdentifier("TextFieldCell") as! TextFieldCell
            cell.delegate = self
            cell.label.text = "Email"
            cell.textField.placeholder = "example@gmail.com"
            cell.textField.text = user.email
            cell.textField.returnKeyType = .Done
            self.cells[index] = cell
            return cell
        case .Images:
            let cell = tableView.dequeueReusableCellWithIdentifier("EditImagesCell") as! EditImagesCell
            cell.logoLabel.text = "Profile Photo"
            cell.logoImage.image = UIImage(named: user.profileImages[.Free]!)
            cell.headerImage.image = UIImage(named: user.headerImage)
            cell.delegate = self
            self.cells[index] = cell
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("TextFieldCell") as! TextFieldCell
            let statuses: [UserStatus] = [.Free, .Occupied, .Unavailable]
            let labels = ["Default Available Status", "Default Away Status", "Default Unavailable Status"]
            let statusIndex = index - Rows.FreeStatus.rawValue
            let status = statuses[statusIndex]

            cell.delegate = self
            cell.textField.placeholder = "Status"
            cell.textField.text = user.textStatuses[status]
            cell.textField.textColor = Helpers.statusToColor(status)
            cell.textField.returnKeyType = .Done
            cell.label.text = labels[statusIndex]
            cell.label.textColor = Color.colorize(0x929292, alpha: 1.0)
            cell.borderColor = Color.colorize(0xE1E1E1, alpha: 1.0)

            if row == .UnavailableStatus {
                cell.bottomBorderStyle = "full"
            } else {
                cell.bottomBorderStyle = "inset"
                if row == .FreeStatus {
                    cell.topBorderStyle = "full"
                }
            }

            self.cells[index] = cell
            return cell
        }
    }

    private func indexForCell(cell: UITableViewCell) -> Int {
        let count = tableView.numberOfRowsInSection(0)

        for var i = 0; i < count; i++ {
            let cellToCheck = self.cellForIndex(i)
            if cellToCheck == cell {
                return i
            }
        }
        return -1
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let handler = self.pickerHandler {
            if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
                handler(editedImage)
            }
            else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                handler(originalImage)
            }
            else if let imageUrl = info[UIImagePickerControllerMediaURL] as? String {
                handler(UIImage(named: imageUrl))
            } else {
                handler(nil)
            }
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    private func getNewPhoto(handler: (UIImage?) -> ()) {
        self.pickerHandler = handler
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)

        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))

        let cameraAction = UIAlertAction(title: "Take a Photo", style: .Default) { (action) in
            self.picker.sourceType = .Camera
            self.presentViewController(self.picker, animated: true, completion: nil)
        }
        alertController.addAction(cameraAction)

        let galleryAction = UIAlertAction(title: "Photo Gallery", style: .Default) { (action) in
            self.picker.sourceType = .SavedPhotosAlbum
            self.presentViewController(self.picker, animated: true, completion: nil)
        }
        alertController.addAction(galleryAction)

        let defaultAction = UIAlertAction(title: "Use Default", style: .Default) { (action) in
            handler(nil)
        }
        alertController.addAction(defaultAction)

        self.presentViewController(alertController, animated: true, completion: nil)
    }

    // Not actually used by need to be here for protocol.
    func uploaderSuccess(result: [NSObject : AnyObject]!, context: AnyObject!) {
    }

    private func createActivityView(view: UIView) -> UIActivityIndicatorView {
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)

        activityView.center = CGPointMake(view.frame.width / 2.0, view.frame.height / 2.0)
        activityView.autoresizingMask = .FlexibleLeftMargin | .FlexibleWidth | .FlexibleRightMargin | .FlexibleTopMargin | .FlexibleHeight | .FlexibleBottomMargin
        activityView.startAnimating()
        view.addSubview(activityView)

        return activityView
    }
}
