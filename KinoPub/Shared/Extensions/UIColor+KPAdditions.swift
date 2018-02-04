import UIKit

extension UIColor {
    
    public class var kpBackground: UIColor {
        //        return UIColor(red: 0.102, green: 0.114, blue: 0.149, alpha: 1.00)
        return kpBlack
    }
    
    public class var kpLightGreen: UIColor {
        return UIColor(red: 0.380, green: 0.753, blue: 0.490, alpha: 1.00)
    }

	@nonobjc class var kpWhite: UIColor {
		return UIColor(white: 216.0 / 255.0, alpha: 1.0)
	}

	@nonobjc class var kpWhiteTwo: UIColor { 
		return UIColor(white: 230.0 / 255.0, alpha: 1.0)
	}

	@nonobjc class var kpTangerine: UIColor { 
		return UIColor(red: 255.0 / 255.0, green: 152.0 / 255.0, blue: 0.0, alpha: 1.0)
	}

	@nonobjc class var kpBlack: UIColor { 
		return UIColor(white: 30.0 / 255.0, alpha: 1.0)
	}

	@nonobjc class var kpGreyishBrownTwo: UIColor { 
		return UIColor(white: 86.0 / 255.0, alpha: 1.0)
	}

	@nonobjc class var kpMarigold: UIColor { 
		return UIColor(red: 255.0 / 255.0, green: 201.0 / 255.0, blue: 0.0, alpha: 1.0)
	}

	@nonobjc class var kpGreyish: UIColor { 
		return UIColor(white: 184.0 / 255.0, alpha: 1.0)
	}

	@nonobjc class var kpOffWhite: UIColor { 
		return UIColor(red: 255.0 / 255.0, green: 244.0 / 255.0, blue: 228.0 / 255.0, alpha: 1.0)
	}

	@nonobjc class var kpLemonGreen: UIColor { 
		return UIColor(red: 182.0 / 255.0, green: 255.0 / 255.0, blue: 0.0, alpha: 1.0)
	}

	@nonobjc class var kpGreyishTwo: UIColor { 
		return UIColor(red: 172.0 / 255.0, green: 164.0 / 255.0, blue: 152.0 / 255.0, alpha: 1.0)
	}

	@nonobjc class var kpGreyishBrown: UIColor { 
		return UIColor(red: 68.0 / 255.0, green: 65.0 / 255.0, blue: 60.0 / 255.0, alpha: 1.0)
	}

	@nonobjc class var kpWhite10: UIColor { 
		return UIColor(white: 255.0 / 255.0, alpha: 0.1)
	}
    
    @nonobjc class var kpBlackTwo: UIColor {
        return UIColor(red: 43.0 / 255.0, green: 43.0 / 255.0, blue: 43.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var kpBlack30: UIColor {
        return UIColor(white: 0.0, alpha: 0.3)
    }
    
    @nonobjc class var kpOffWhiteSeparator: UIColor {
        return UIColor(red: 255.0 / 255.0, green: 244.0 / 255.0, blue: 228.0 / 255.0, alpha: 0.16)
    }
    
    @nonobjc class var kpBlackForTable: UIColor {
        return UIColor(white: 17.0 / 255.0, alpha: 1.0)
    }
    
    func isLight() -> Bool {
        let components = cgColor.components
        if let components = components {
            let brightness = ((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000
            return brightness > 0.5
        }
        return false
    }
    
    static func averageColor(fromImage image: UIImage?) -> UIColor {
        if let originalImage = image, let cgImage = originalImage.cgImage {
            var bitmap = [UInt8](repeating: 0, count: 4)
            
            let context = CIContext(options: nil)
            let cgImg = context.createCGImage(CoreImage.CIImage(cgImage: cgImage), from: CoreImage.CIImage(cgImage: cgImage).extent)
            
            let inputImage = CIImage(cgImage: cgImg!)
            let extent = inputImage.extent
            let inputExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)
            let filter = CIFilter(name: "CIAreaAverage", withInputParameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: inputExtent])!
            let outputImage = filter.outputImage!
            let outputExtent = outputImage.extent
            assert(outputExtent.size.width == 1 && outputExtent.size.height == 1)
            
            // Render to bitmap.
            context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: kCIFormatRGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
            
            // Compute result.
            let result = UIColor(red: CGFloat(bitmap[0]) / 255.0, green: CGFloat(bitmap[1]) / 255.0, blue: CGFloat(bitmap[2]) / 255.0, alpha: CGFloat(bitmap[3]) / 255.0)
            
            if result == UIColor(red: 0, green: 0, blue: 0, alpha: 0) {
                return UIColor(red: 255, green: 255, blue: 255, alpha: 1)
            } else {
                return result
            }
        }
        return UIColor(red: 255, green: 255, blue: 255, alpha: 1)
    }
}
