import UIKit

class AnswerButton: UIButton {
    required init(_ title: String) {
        super.init(frame: CGRect.zero)
        self.clipsToBounds = true
        self.setTitle(title, for: .normal)
        self.setTitleColor(.black, for: .normal)
        self.setTitleColor(.white, for: .highlighted)
        self.contentHorizontalAlignment = .left
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        self.layer.borderColor = UIColor(red: 0.84, green: 0.86, blue: 0.86, alpha: 1).cgColor
        self.layer.cornerRadius = 22
        self.layer.borderWidth = 1
        self.setBackgroundColor(UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1), forState: .normal)
        self.setBackgroundColor(UIColor(red: 1, green: 0.6, blue: 0, alpha: 1), forState: .highlighted)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setBackgroundColor(_ color: UIColor, forState: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, for: forState)
    }
}
