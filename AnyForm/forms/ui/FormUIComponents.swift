//
//  FormUIComponents.swift
//  AnyForm
//
//  Created by נדב אבנון on 26/07/2021.
//

import Foundation
import UIKit
import RoundedSwitch
class UITextFieldForm : UITextField {
    var formtextfield:FormTextField?
    convenience init(_ field: FormTextField) {
        self.init()
        self.formtextfield = field
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
class UIDatePickerForm : UIDatePicker {
    var formtextfield:FormTextField?
    convenience init(_ field: FormTextField) {
        self.init()
        self.formtextfield = field
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
struct Line {
    let strokeWidth: Float
    let color: UIColor
    var points: [CGPoint]
}

class AnyFormSignatureField: UIView {

    // public function
    fileprivate var strokeColor = UIColor.black
    fileprivate var strokeWidth: Float = 1

    func setStrokeWidth(width: Float) {
        self.strokeWidth = width
    }

    func setStrokeColor(color: UIColor) {
        self.strokeColor = color
    }

    func undo() {
        _ = lines.popLast()
        setNeedsDisplay()
    }

    func clear() {
        lines.removeAll()
        setNeedsDisplay()
    }

    fileprivate var lines = [Line]()
    fileprivate var context:CGContext!
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        context = UIGraphicsGetCurrentContext()
        lines.forEach { (line) in
            context.setStrokeColor(line.color.cgColor)
            context.setLineWidth(CGFloat(line.strokeWidth))
            context.setLineCap(.round)
            for (i, p) in line.points.enumerated() {
                if i == 0 {
                    context.move(to: p)
                } else {
                    context.addLine(to: p)
                }
            }
            context.strokePath()
        }
    }
    
    func getSignature() -> CGImage? {
       return context.makeImage()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lines.append(Line.init(strokeWidth: strokeWidth, color: strokeColor, points: []))
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        guard var lastLine = lines.popLast() else { return }
        lastLine.points.append(point)
        lines.append(lastLine)
        setNeedsDisplay()
    }
}

class UICheckBoxForm : CheckBox {
    var formcheckbox:FormCheckBox?
    convenience init(_ field: FormCheckBox) {
        self.init()
        self.formcheckbox = field
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
