import UIKit

class FadeImageView: UIImageView {

    @IBInspectable
    var fadeDuration: Double = 0.4

    override var image: UIImage? {
        get {
            return super.image
        }
        set(newImage) {
            if let img = newImage {
                CATransaction.begin()
                CATransaction.setAnimationDuration(self.fadeDuration)

                let transition = CATransition()
                transition.type = kCATransitionFade

                super.layer.add(transition, forKey: kCATransition)
                super.image = img

                CATransaction.commit()
            } else {
                super.image = nil
            }
        }
    }

}
