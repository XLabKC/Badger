import UIKit

protocol StatusSliderDelegate: class {
    func sliderChangedStatus(slider: StatusSlider, newStatus: UserStatus)
}

class StatusSlider: UIView, UIGestureRecognizerDelegate {
    let panRecognizer = UIPanGestureRecognizer()
    let tapRecognizer = UITapGestureRecognizer()

    let slider = UIView()
    let unavailableIconView = UIImageView()
    let freeIconView = UIImageView()
    let occupiedIconView = UIImageView()

    // View constants.
    let backgroundColors = [
        Colors.UnavailableStatus,
        Colors.FreeStatus,
        Colors.OccupiedStatus
    ]
    let inactiveIconColor = Color.colorize(0xE0E0E0, alpha: 1)
    let stickyDistance = CGFloat(5.0)

    private var touchStartPosition: CGFloat
    private var touchIsDown = false
    private var status: UserStatus

    weak var delegate: StatusSliderDelegate?

    required init(coder aDecoder: NSCoder) {
        self.status = .Free
        self.touchStartPosition = 0
        super.init(coder: aDecoder)

        let w = self.frame.width
        let h = self.frame.height

        // Set up slider view.
        self.slider.frame = CGRect(x: 0, y: 0, width: h, height: h)
        self.updateBorders()
        self.addSubview(self.slider)

        // Set up icon views.
        self.unavailableIconView.frame = CGRect(x: 0, y: 0, width: h, height: h)
        self.freeIconView.frame = CGRect(x: (w - h) / 2.0, y: 0, width: h, height: h)
        self.occupiedIconView.frame = CGRect(x: (w - h), y: 0, width: h, height: h)
        self.setupIconPair(self.unavailableIconView, image: "UnavailableIcon",
            color: Color.colorize(0xCB2F49, alpha: 1))
        self.setupIconPair(self.freeIconView, image: "FreeIcon",
            color: Color.colorize(0x1BBA96, alpha: 1))
        self.setupIconPair(self.occupiedIconView, image: "OccupiedIcon",
            color: Color.colorize(0xE5B943, alpha: 1))

        // Set up recognizers.
        self.userInteractionEnabled = true
        self.panRecognizer.addTarget(self, action: "panning:")
        self.panRecognizer.delegate = self
        self.slider.addGestureRecognizer(self.panRecognizer)
        self.tapRecognizer.addTarget(self, action: "tap:")
        self.tapRecognizer.delegate = self
        self.addGestureRecognizer(self.tapRecognizer)

        // Make sure everything is properly rendered.
        self.setStatus(.Free, animated: false)
    }

    func panning(recognizer: UIPanGestureRecognizer) {
        if (recognizer.state == .Began) {
            // Save where the touch started.
            let start = recognizer.locationInView(self)
            self.touchStartPosition = start.x
            self.touchIsDown = true
            return
        }

        // Make sure that this is a touch we are tracking.
        if !self.touchIsDown {
            return
        }

        let position = recognizer.locationInView(self).x
        let statePosition = calcPositionForState(self.status)
        let newPosition = self.adjustSlidePosition(statePosition + (position - touchStartPosition))

        if (recognizer.state == .Changed) {
            // Update the position of the slider.
            self.slider.frame.origin.x = newPosition
            self.slider.backgroundColor = calcColorForPosition(newPosition)
            self.setIconAlphaForPosition(newPosition)
            return
        }

        // End the touch.
        self.touchIsDown = false

        // Determine what the closes state is.
        let result = self.calcOffsetAndProgress(newPosition)
        if result.progress < 0.5 {
            self.setStatusInternal((result.offset == 0) ? .Unavailable : .Free, animated: true)
        } else {
            self.setStatusInternal((result.offset == 0) ? .Free : .Occupied, animated: true)
        }
    }

    func tap(recognizer: UITapGestureRecognizer) {
        let position = recognizer.locationInView(self).x
        let end = self.frame.width - self.frame.height
        let midpoint = end / 2.0

        if position < self.frame.height {
            self.setStatusInternal(.Unavailable, animated: true)
        } else if (position > midpoint - self.stickyDistance &&
                position < midpoint + self.frame.height + stickyDistance) {
            self.setStatusInternal(.Free, animated: true)
        } else if (position > end - self.stickyDistance) {
            self.setStatusInternal(.Occupied, animated: true)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateBorders()
    }

    // Set the state.
    func setStatus(status: UserStatus, animated animate: Bool) {
        self.status = status
        let action = { () -> Void in
            self.slider.frame.origin.x = self.calcPositionForState(status)
            self.slider.backgroundColor = Helpers.statusToColor(status)
            self.unavailableIconView.alpha = (status == .Unavailable) ? 1 : 0
            self.freeIconView.alpha = (status == .Free) ? 1 : 0
            self.occupiedIconView.alpha = (status == .Occupied) ? 1 : 0
        }

        if animate {
            [UIView.animateWithDuration(0.3, animations: action)];
        } else {
            action()
        }
    }

    func getStatus() -> UserStatus {
        return self.status
    }

    // Sets the status and notifies the delegate.
    private func setStatusInternal(status: UserStatus, animated animate: Bool) {
        if self.status != status {
            if let delegate = self.delegate {
                delegate.sliderChangedStatus(self, newStatus: status)
            }
        }
        self.setStatus(status, animated: animate)
    }

    private func setIconAlphaForPosition(position: CGFloat) {
        self.setImageAlphaForPosition(self.unavailableIconView, position: position)
        self.setImageAlphaForPosition(self.freeIconView, position: position)
        self.setImageAlphaForPosition(self.occupiedIconView, position: position)
    }

    private func setImageAlphaForPosition(imageView: UIImageView, position: CGFloat) {
        let diff = abs(position - imageView.frame.origin.x)
        let range = self.frame.height * 0.25
        if (diff > range) {
            // Not enough overlapping, find icon completely.
            imageView.alpha = 0
        } else {
            // Linear curve to fade in icon.
            imageView.alpha = 1 - (diff / range)
        }
    }

    // Adjusts a slide position to account for bounds and to account for stickiness.
    private func adjustSlidePosition(position: CGFloat) -> CGFloat {
        let end = self.frame.width - self.frame.height
        let midpoint = end / 2.0

        if position < 0 {
            return 0
        } else if position > end {
            return end
        }
        return position
    }

    // Calculate the position for a state.
    private func calcPositionForState(state: UserStatus) -> CGFloat {
        switch state {
        case .Unavailable:
            return 0
        case .Free:
            return (self.frame.width - self.frame.height) / 2.0
        case .Occupied:
            return self.frame.width - self.frame.height
        case .Unknown:
            return (self.frame.width - self.frame.height) / 2.0
        }
    }

    // Calculate the color for a position.
    private func calcColorForPosition(position: CGFloat) -> UIColor {
        let result = self.calcOffsetAndProgress(position)
        let start = self.backgroundColors[result.offset]
        let end = self.backgroundColors[result.offset + 1]
        return Color.interpolateRGBBetween(start, end: end, progress: result.progress);
    }

    // Calculates the offset and progress to be used for interpolating between states.
    private func calcOffsetAndProgress(position: CGFloat) -> (offset: Int, progress: CGFloat) {
        let midpoint = (self.frame.width - self.frame.height) / 2.0
        let offset = (position < midpoint) ? 0 : 1
        let progress = (((offset == 0) ? 0 : -midpoint) + position) / midpoint
        return (offset, progress)
    }

    // Updates the borders to be half the width.
    private func updateBorders() {
        let radius = self.frame.height / 2.0
        self.slider.layer.cornerRadius = radius
        self.layer.cornerRadius = radius
    }

    // Sets the color of the image on an image view.
    private func setIconTransparency(imageView: UIImageView, color: UIColor) {
        if let image = imageView.image {
            imageView.image = Helpers.imageWithColor(image, color: color)
        }
    }

    // Sets up the icon pairs; one in front, one behind the slider.
    private func setupIconPair(imageView: UIImageView, image: String, color: UIColor) {
        imageView.image = Helpers.imageWithColor(UIImage(named: image)!, color: color)
        imageView.contentMode = .Center
        self.addSubview(imageView)

        let backgroundView = UIImageView(frame: imageView.frame)
        backgroundView.image = Helpers.imageWithColor(imageView.image!, color: self.inactiveIconColor)
        backgroundView.contentMode = .Center
        self.insertSubview(backgroundView, belowSubview: self.slider)
    }
}