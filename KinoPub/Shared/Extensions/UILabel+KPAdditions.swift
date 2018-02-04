import UIKit

extension UILabel {
    func underlineTextStyle() {
        guard let text = text else { return }
        let textRange = NSMakeRange(0, text.count)
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttribute(NSAttributedStringKey.underlineStyle , value: NSUnderlineStyle.styleSingle.rawValue, range: textRange)
        // Add other attributes if needed
        self.attributedText = attributedText
    }
    
    func addCharactersSpacing(_ value: CGFloat = 1.15) {
        if let textString = text {
            let attrs: [NSAttributedStringKey : Any] = [.kern: value]
            attributedText = NSAttributedString(string: textString, attributes: attrs)
        }
    }
    
    func addLineHeight(min: CGFloat, max: CGFloat) {
        if let textString = text {
            let style = NSMutableParagraphStyle()
            style.minimumLineHeight = min
            style.maximumLineHeight = max
            style.alignment = NSTextAlignment.center
            let attrs: [NSAttributedStringKey : Any] = [.paragraphStyle: style]
            attributedText = NSAttributedString(string: textString, attributes: attrs)
            self.baselineAdjustment = .alignCenters
        }
    }
    
    func setLineHeight(lineHeight: CGFloat) {
        let text = self.text
        if let text = text {
            let attributeString = NSMutableAttributedString(string: text)
            let style = NSMutableParagraphStyle()
            
            style.lineSpacing = lineHeight
            attributeString.addAttribute(NSAttributedStringKey.paragraphStyle, value: style, range: NSMakeRange(0, text.count))
            self.attributedText = attributeString
        }
    }
}
