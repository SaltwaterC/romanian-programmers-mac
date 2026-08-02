import CoreGraphics
import CoreText
import Foundation
import ImageIO
import UniformTypeIdentifiers

enum IconStyle: String {
    case languageCode = "language-code"
    case romanianFlag = "romanian-flag"
}

guard (CommandLine.arguments.count == 3 || CommandLine.arguments.count == 4),
      let maximumSize = Int(CommandLine.arguments[2]), maximumSize > 0,
      let iconStyle = IconStyle(rawValue: CommandLine.arguments.count == 4
          ? CommandLine.arguments[3]
          : IconStyle.languageCode.rawValue) else {
    fputs("usage: generate-language-icon.swift OUTPUT MAXIMUM_SIZE [language-code|romanian-flag]\n", stderr)
    exit(2)
}

let outputURL = URL(fileURLWithPath: CommandLine.arguments[1])

func makeLanguageCodeImage(size: Int) -> CGImage {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let context = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8,
                             bytesPerRow: size * 4, space: colorSpace,
                             bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!

    // macOS' language indicators are wide pills inside a square icon slot.
    // Keep the canvas square for the legacy ICNS representations, but make
    // the visible shape wide and short.
    context.setFillColor(CGColor(colorSpace: colorSpace, components: [0.0, 0.0, 0.0, 1.0])!)
    let horizontalInset = max(1.0, min(16.0, CGFloat(size) * 0.047))
    let pillHeight = CGFloat(size) * 0.72
    let verticalInset = (CGFloat(size) - pillHeight) / 2
    let rect = CGRect(x: horizontalInset, y: verticalInset,
                      width: CGFloat(size) - horizontalInset * 2,
                      height: pillHeight)
    context.addPath(CGPath(roundedRect: rect, cornerWidth: pillHeight * 0.28,
                            cornerHeight: pillHeight * 0.28, transform: nil))
    context.fillPath()

    let font = CTFontCreateWithName("HelveticaNeue-Bold" as CFString, CGFloat(size) * 0.42, nil)
    let attributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key(kCTFontAttributeName as String): font,
        NSAttributedString.Key(kCTForegroundColorAttributeName as String): CGColor.black
    ]
    let line = CTLineCreateWithAttributedString(NSAttributedString(string: "RO", attributes: attributes))
    let bounds = CTLineGetBoundsWithOptions(line, [])
    context.textPosition = CGPoint(x: (CGFloat(size) - bounds.width) / 2 - bounds.origin.x,
                                   y: (CGFloat(size) - bounds.height) / 2 - bounds.origin.y)
    // A template icon is an alpha mask. Cut the label out of the pill so the
    // system can render the icon correctly in each menu-bar appearance.
    context.setBlendMode(.clear)
    CTLineDraw(line, context)

    return context.makeImage()!
}

func makeRomanianFlagImage(size: Int) -> CGImage {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let context = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8,
                            bytesPerRow: size * 4, space: colorSpace,
                            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!

    // Keep the 2:3 proportions of Romania's flag inside the same square ICNS
    // slots used by the language-code icon. Drawing it here keeps every
    // representation generated from source rather than from a third-party
    // bitmap.
    let flagHeight = CGFloat(size) * 0.62
    let flagWidth = flagHeight * 1.5
    let flagRect = CGRect(x: (CGFloat(size) - flagWidth) / 2,
                          y: (CGFloat(size) - flagHeight) / 2,
                          width: flagWidth,
                          height: flagHeight)
    let cornerRadius = max(0.5, flagHeight * 0.055)
    let flagPath = CGPath(roundedRect: flagRect, cornerWidth: cornerRadius,
                          cornerHeight: cornerRadius, transform: nil)

    context.saveGState()
    context.addPath(flagPath)
    context.clip()

    let stripeWidth = flagRect.width / 3
    let stripeColors: [[CGFloat]] = [
        [0.0, 0.17, 0.50, 1.0],   // blue: #002B7F
        [0.99, 0.82, 0.09, 1.0],  // yellow: #FCD116
        [0.81, 0.07, 0.15, 1.0]   // red: #CE1126
    ]
    for (index, components) in stripeColors.enumerated() {
        context.setFillColor(CGColor(colorSpace: colorSpace, components: components)!)
        context.fill(CGRect(x: flagRect.minX + CGFloat(index) * stripeWidth,
                            y: flagRect.minY,
                            width: stripeWidth,
                            height: flagRect.height))
    }
    context.restoreGState()

    // A light outline keeps the flag legible against both light and dark
    // menu-bar backgrounds without changing its three-colour design.
    context.setStrokeColor(CGColor(gray: 0, alpha: 0.28))
    context.setLineWidth(max(0.5, CGFloat(size) * 0.012))
    context.addPath(flagPath)
    context.strokePath()

    return context.makeImage()!
}

// Keep both the small legacy representation used by the menu bar and the
// larger representations used by Keyboard Layouts/System Settings.
let sizes = [16, 32, 64, 128, 256, 512, 1024].filter { $0 <= maximumSize }
let type: CFString = outputURL.pathExtension == "icns"
    ? "com.apple.icns" as CFString
    : UTType.png.identifier as CFString
let destination = CGImageDestinationCreateWithURL(outputURL as CFURL, type, sizes.count, nil)!
for size in sizes {
    let image: CGImage
    switch iconStyle {
    case .languageCode:
        image = makeLanguageCodeImage(size: size)
    case .romanianFlag:
        image = makeRomanianFlagImage(size: size)
    }
    CGImageDestinationAddImage(destination, image, nil)
}
precondition(CGImageDestinationFinalize(destination))
