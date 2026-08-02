import CoreGraphics
import CoreText
import Foundation
import ImageIO
import UniformTypeIdentifiers

guard CommandLine.arguments.count == 3,
      let maximumSize = Int(CommandLine.arguments[2]), maximumSize > 0 else {
    fputs("usage: generate-language-icon.swift OUTPUT MAXIMUM_SIZE\n", stderr)
    exit(2)
}

let outputURL = URL(fileURLWithPath: CommandLine.arguments[1])

func makeImage(size: Int) -> CGImage {
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

// Keep both the small legacy representation used by the menu bar and the
// larger representations used by Keyboard Layouts/System Settings.
let sizes = [16, 32, 64, 128, 256, 512, 1024].filter { $0 <= maximumSize }
let type: CFString = outputURL.pathExtension == "icns"
    ? "com.apple.icns" as CFString
    : UTType.png.identifier as CFString
let destination = CGImageDestinationCreateWithURL(outputURL as CFURL, type, sizes.count, nil)!
for size in sizes {
    CGImageDestinationAddImage(destination, makeImage(size: size), nil)
}
precondition(CGImageDestinationFinalize(destination))
