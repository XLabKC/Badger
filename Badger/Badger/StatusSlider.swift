import UIKit

public enum StatusSliderState: Int {
    case Unavailable = 0, Free, Occupied
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
        Helpers.colorize(0xFF5C78, alpha: 1),
        Helpers.colorize(0x50E3C2, alpha: 1),
        Helpers.colorize(0xFFDB7B, alpha: 1)
    ]
    let inactiveIconColor = Helpers.colorize(0xE0E0E0, alpha: 1)
//    let iconColors = [
//        Helpers.colorize(0xE0E0E0, alpha: 1),
//        Helpers.colorize(0xE0E0E0, alpha: 1),
//        Helpers.colorize(0xE0E0E0, alpha: 1)
//    ]
    let iconColors = [
        Helpers.colorize(0xCB2F49, alpha: 1),
        Helpers.colorize(0x1BBA96, alpha: 1),
        Helpers.colorize(0xE5B943, alpha: 1)
    ]
    let stickyDistance = CGFloat(5.0)

    var touchStartPosition: CGFloat
    var touchIsDown = false
    var state: StatusSliderState

    required init(coder aDecoder: NSCoder) {
        self.state = .Free
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
        self.setupIcon(self.unavailableIconView, image: "UnavailableIcon.png")
        self.setupIcon(self.freeIconView, image: "FreeIcon.png")
        self.setupIcon(self.occupiedIconView, image: "OccupiedIcon.png")

        // Set up recognizers.
        self.userInteractionEnabled = true
        self.panRecognizer.addTarget(self, action: "panning:")
        self.panRecognizer.delegate = self
        self.slider.addGestureRecognizer(self.panRecognizer)
        self.tapRecognizer.addTarget(self, action: "tap:")
        self.tapRecognizer.delegate = self
        self.addGestureRecognizer(self.tapRecognizer)

        // Make sure everything is properly rendered.
        self.setStateInternal(.Free, animated: false)
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
        let statePosition = calcPositionForState(self.state)
        let newPosition = self.adjustSlidePosition(statePosition + (position - touchStartPosition))

        if (recognizer.state == .Changed) {
            // Update the position of the slider.
            self.slider.frame.origin.x = newPosition
            self.slider.backgroundColor = calcColorForPosition(newPosition)
            self.setIconColorsForPosition(newPosition)
            return
        }

        // End the touch.
        self.touchIsDown = false

        // Determine what the closes state is.
        let result = self.calcOffsetAndProgress(newPosition)
        if result.progress < 0.5 {
            self.setStateInternal((result.offset == 0) ? .Unavailable : .Free, animated: true)
        } else {
            self.setStateInternal((result.offset == 0) ? .Free : .Occupied, animated: true)
        }
    }

    func tap(recognizer: UITapGestureRecognizer) {
        let position = recognizer.locationInView(self).x
        let end = self.frame.width - self.frame.height
        let midpoint = end / 2.0

        if position < self.frame.height {
            self.setStateInternal(.Unavailable, animated: true)
        } else if (position > midpoint - self.stickyDistance &&
                position < midpoint + self.frame.height + stickyDistance) {
            self.setStateInternal(.Free, animated: true)
        } else if (position > end - self.stickyDistance) {
            self.setStateInternal(.Occupied, animated: true)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateBorders()
    }

    // Set the state.
    private func setStateInternal(state: StatusSliderState, animated animate: Bool) {
        self.state = state
        let action = { () -> Void in
            self.slider.frame.origin.x = self.calcPositionForState(self.state)
            self.slider.backgroundColor = self.colorForState(self.state)
            self.setImageColor(self.unavailableIconView,
                color: (state == .Unavailable) ? self.iconColors[0] : self.inactiveIconColor)
            self.setImageColor(self.freeIconView,
                color: (state == .Free) ? self.iconColors[1] : self.inactiveIconColor)
            self.setImageColor(self.occupiedIconView,
                color: (state == .Occupied) ? self.iconColors[2] : self.inactiveIconColor)
        }

        if animate {
            [UIView.animateWithDuration(0.3, animations: action)];
        } else {
            action()
        }
    }

    private func setIconColorsForPosition(position: CGFloat) {
        let result = self.calcOffsetAndProgress(position)
        var activeIcons: [UIImageView]

        if (result.offset == 0) {
            activeIcons = [self.unavailableIconView, self.freeIconView]
            self.setImageColor(self.occupiedIconView, color: self.inactiveIconColor)
        } else {
            activeIcons = [self.freeIconView, self.occupiedIconView]
            self.setImageColor(self.unavailableIconView, color: self.inactiveIconColor)
        }

        for index in 0...1 {
            let startColor = self.iconColors[result.offset + index]
            let progress = (index == 0) ? result.progress : 1.0 - result.progress
            let color = Helpers.interpolateColors(startColor, end: self.inactiveIconColor, progress: progress)
            self.setImageColor(activeIcons[index], color: color)
        }
    }

    // Adjusts a slide position to account for bounds and to account for stickiness.
    private func adjustSlidePosition(position: CGFloat) -> CGFloat {
        let end = self.frame.width - self.frame.height
        let midpoint = end / 2.0

        if position < 0 {
            return 0
        }
        else if position > end {
            return end
        }
        return position


        // Check for close to 0.
//        if position <= stickyDistance {
//            return CGFloat(0)
//        }
        // Check for close to the midpoint.
//        if abs(position - midpoint) <= stickyDistance {
//            return midpoint
//        }
        // Check for close to end.
//        if position >= end - stickyDistance {
//            return end
//        }
//        return position
    }

    // Calculate the position for a state.
    private func calcPositionForState(state: StatusSliderState) -> CGFloat {
        switch state {
        case .Unavailable:
            return 0
        case .Free:
            return (self.frame.width - self.frame.height) / 2.0
        case .Occupied:
            return self.frame.width - self.frame.height
        }
    }

    // Returns the color for a given state.
    private func colorForState(state: StatusSliderState) -> UIColor {
        switch state {
        case .Unavailable:
            return self.backgroundColors[0]
        case .Free:
            return self.backgroundColors[1]
        case .Occupied:
            return self.backgroundColors[2]
        }
    }

    // Calculate the color for a position.
    private func calcColorForPosition(position: CGFloat) -> UIColor {
        let result = self.calcOffsetAndProgress(position)
        let start = self.backgroundColors[result.offset]
        let end = self.backgroundColors[result.offset + 1]
        return Helpers.interpolateColors(start, end: end, progress: result.progress);
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
    private func setImageColor(imageView: UIImageView, color: UIColor) {
        if let image = imageView.image? {
            imageView.image = Helpers.imageWithColor(image, color: color)
        }
    }

    private func setupIcon(imageView: UIImageView, image: String) {
        imageView.image = Helpers.imageWithColor(UIImage(named: image)!,
            color: self.inactiveIconColor)
        imageView.contentMode = .Center
        self.addSubview(imageView)
    }
}