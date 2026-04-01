import UIKit

enum MenuThumbnailFactory {
    static func makeImage(for item: MenuItemDTO, diameter: CGFloat = 72) -> UIImage {
        let size = CGSize(width: diameter, height: diameter)
        let renderer = UIGraphicsImageRenderer(size: size)
        let palette = palette(for: item)
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: diameter * 0.34, weight: .semibold)
        let symbolImage = UIImage(
            systemName: symbolName(for: item),
            withConfiguration: symbolConfiguration
        )?.withTintColor(.white, renderingMode: .alwaysOriginal)

        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            let drawingContext = context.cgContext
            let symbolBackgroundDiameter = diameter * 0.6
            let symbolBackgroundRect = CGRect(
                x: (diameter - symbolBackgroundDiameter) / 2,
                y: (diameter - symbolBackgroundDiameter) / 2,
                width: symbolBackgroundDiameter,
                height: symbolBackgroundDiameter
            )
            let symbolSize = diameter * 0.38
            let symbolRect = CGRect(
                x: (diameter - symbolSize) / 2,
                y: (diameter - symbolSize) / 2,
                width: symbolSize,
                height: symbolSize
            )

            drawingContext.saveGState()
            UIBezierPath(ovalIn: rect).addClip()

            let colors = [palette.primary.cgColor, palette.secondary.cgColor] as CFArray
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let locations: [CGFloat] = [0, 1]

            if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) {
                drawingContext.drawLinearGradient(
                    gradient,
                    start: CGPoint(x: 0, y: 0),
                    end: CGPoint(x: size.width, y: size.height),
                    options: []
                )
            }

            UIColor.white.withAlphaComponent(0.2).setFill()
            drawingContext.fillEllipse(
                in: CGRect(
                    x: diameter * 0.14,
                    y: diameter * 0.12,
                    width: diameter * 0.48,
                    height: diameter * 0.3
                )
            )

            UIColor.black.withAlphaComponent(0.08).setFill()
            drawingContext.fillEllipse(
                in: CGRect(
                    x: diameter * 0.16,
                    y: diameter * 0.64,
                    width: diameter * 0.52,
                    height: diameter * 0.16
                )
            )

            UIColor.white.withAlphaComponent(0.18).setFill()
            drawingContext.fillEllipse(in: symbolBackgroundRect)

            symbolImage?.draw(in: symbolRect)

            drawingContext.restoreGState()
        }
    }

    private static func symbolName(for item: MenuItemDTO) -> String {
        let categoryName = item.categoryName ?? ""

        if categoryName.contains("티") {
            return "leaf.fill"
        }

        if categoryName.contains("브레드") {
            return "birthday.cake.fill"
        }

        if categoryName.contains("케이크") {
            return "fork.knife"
        }

        if categoryName.contains("에스프레소") {
            return "cup.and.saucer.fill"
        }

        return "takeoutbag.and.cup.and.straw.fill"
    }

    private static func palette(for item: MenuItemDTO) -> (primary: UIColor, secondary: UIColor) {
        let categoryName = item.categoryName ?? ""

        if categoryName.contains("티") {
            return (
                primary: UIColor(red: 0.47, green: 0.64, blue: 0.36, alpha: 1),
                secondary: UIColor(red: 0.84, green: 0.91, blue: 0.67, alpha: 1)
            )
        }

        if categoryName.contains("브레드") {
            return (
                primary: UIColor(red: 0.78, green: 0.55, blue: 0.34, alpha: 1),
                secondary: UIColor(red: 0.95, green: 0.84, blue: 0.67, alpha: 1)
            )
        }

        if categoryName.contains("케이크") {
            return (
                primary: UIColor(red: 0.86, green: 0.48, blue: 0.58, alpha: 1),
                secondary: UIColor(red: 0.98, green: 0.83, blue: 0.86, alpha: 1)
            )
        }

        if categoryName.contains("에스프레소") {
            return (
                primary: UIColor(red: 0.43, green: 0.29, blue: 0.2, alpha: 1),
                secondary: UIColor(red: 0.74, green: 0.58, blue: 0.46, alpha: 1)
            )
        }

        return (
            primary: StarbucksPalette.primaryGreen,
            secondary: UIColor(red: 0.58, green: 0.8, blue: 0.72, alpha: 1)
        )
    }
}
