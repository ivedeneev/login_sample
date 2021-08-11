// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen
import UIKit.UIImage


// swiftlint:disable superfluous_disable_command
// swiftlint:disable identifier_name line_length nesting type_body_length type_name file_length
internal enum Asset {
    internal static var logo: UIImage {
        return image(named: "Logo")
    }
    internal static var applePay: UIImage {
        return image(named: "apple_pay")
    }
    internal static var bentley: UIImage {
        return image(named: "bentley")
    }
    internal static var camera: UIImage {
        return image(named: "camera")
    }
    internal static var cash: UIImage {
        return image(named: "cash")
    }
    internal static var faceId: UIImage {
        return image(named: "faceId")
    }
    internal static var fingerprint: UIImage {
        return image(named: "fingerprint")
    }
    internal static var keypadDelete: UIImage {
        return image(named: "keypad_delete")
    }
    internal static var myLocation: UIImage {
        return image(named: "my_location")
    }
    internal static var plus: UIImage {
        return image(named: "plus")
    }
    internal static var profile: UIImage {
        return image(named: "profile")
    }
    internal static var ridePoints: UIImage {
        return image(named: "ride_points")
    }
    internal static var visa: UIImage {
        return image(named: "visa")
    }

    // swiftlint:disable trailing_comma
    internal static let allImages: [UIImage] = [
        logo,
        applePay,
        bentley,
        camera,
        cash,
        faceId,
        fingerprint,
        keypadDelete,
        myLocation,
        plus,
        profile,
        ridePoints,
        visa,
    ]

    private static func image(named name: String) -> UIImage {
        let bundle = Bundle(for: BundleToken.self)
        guard let image = UIImage(named: name, in: bundle, compatibleWith: nil) else {
            fatalError("Unable to load image named \(name).")
        }
        return image
    }
}

private final class BundleToken {}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name file_length
