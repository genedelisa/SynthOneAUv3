//
//  TimeKnob.swift
//  AudioKitSynthOne
//
//  Created by Matthew Fecher on 8/5/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import UIKit

public class TimeKnob: MIDIKnob {

    static let offset = 4   // twoBars to sixtyFourth

    var limitedRate = Rate.count - offset

    var rate: Rate {
        return Rate(rawValue: TimeKnob.offset + Int(CGFloat(limitedRate) - knobValue * CGFloat(limitedRate))) ?? Rate.sixtyFourth
    }

    //TODO:@MATT This is unused...do you still need this?
    func update() {
        if timeSyncMode {
            // knobValue = CGFloat(Rate.fromTime(_value).time) / CGFloat(limitedRate)
        } else {
            _value = range.clamp(rate.time)
            knobValue = CGFloat(_value.normalized(from: range, taper: taper))
        }
    }

    private var _value: Double = 0

    override public var value: Double {
        get {
            if timeSyncMode {
                return rate.time
            } else {
                return _value
            }
        }
        set(newValue) {
            _value = onlyIntegers ? round(newValue) : newValue
            _value = range.clamp(_value)
            if !timeSyncMode {
                knobValue = CGFloat(_value.normalized(from: range, taper: taper))
            }
        }
    }

    // Init / Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .redraw
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.isUserInteractionEnabled = true
        contentMode = .redraw
    }

    override func setPercentagesWithTouchPoint(_ touchPoint: CGPoint) {
        // Knobs assume up or right is increasing, and down or left is decreasing

        knobValue += (touchPoint.x - lastX) * knobSensitivity
        knobValue -= (touchPoint.y - lastY) * knobSensitivity

        knobValue = (0.0 ... 1.0).clamp(knobValue)

        if timeSyncMode {
            value = rate.time
        } else {
            value = Double(knobValue).denormalized(to: range, taper: taper)
        }

        callback(value)
        lastX = touchPoint.x
        lastY = touchPoint.y
    }
}
