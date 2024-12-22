//
//  Helper.swift
//  GameCatalog
//
//  Created by Mochamad Ikhsan Nurdiansyah on 11/12/24.
//
import UIKit

extension String {
    func htmlToAttributedString(label: UIView) -> NSAttributedString? {
        guard let data = self.data(using: .utf8) else { return nil }
        do {
            let attributedString = try NSAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue],
                documentAttributes: nil
            )

            if let label = label as? UILabel {
                let mutableString = NSMutableAttributedString(attributedString: attributedString)
                mutableString.addAttribute(.font, value: label.font!, range: NSRange(location: 0, length: attributedString.length))
                mutableString.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: attributedString.length))
                return mutableString
            } else if let textView = label as? UITextView {
                let mutableString = NSMutableAttributedString(attributedString: attributedString)
                mutableString.addAttribute(.font, value: textView.font!, range: NSRange(location: 0, length: attributedString.length))
                mutableString.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: attributedString.length))
                return mutableString
            }
            return attributedString
        } catch {
            print("Error converting HTML to NSAttributedString: \(error)")
            return nil
        }
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
