// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Keyboard/

import SwiftUI
import Tonic

let goldenRatio: CGFloat = (1.0 + sqrt(5)) / 2

public enum Viewpoint {
    case diatonic
    case intervallic
}

/// A default visual representation for a key.
public struct KeyboardKey: View {
    /// Initialize the keyboard key
    /// - Parameters:
    ///   - pitch: Pitch assigned to the key
    ///   - isActivated: Whether to represent this key in the "down" state
    ///   - text: Label on the key
    ///   - color: Color of the activated key
    ///   - isActivatedExternally: Usually used for representing incoming MIDI
    public init(pitch: Pitch,
                isActivated: Bool,
                viewpoint: Viewpoint = .diatonic,
                tonicPitch: Pitch = Pitch(60),
                text: String = "unset",
                intervallicKeyColors: [CGColor] = IntervalColor.homey,
                intervallicKeySymbols: [any Shape] = IntervalSymbol.homey,
                intervallicSymbolColors: [CGColor] = IntervalColor.homey,
                twoSymbolsOnPerfects: Bool = false,
                whiteKeyColor: Color = .white,
                blackKeyColor: Color = .black,
                pressedColor: Color = .red,
                flatTop: Bool = false,
                alignment: Alignment = .bottom,
                isActivatedExternally: Bool = false)
    {
        self.pitch = pitch
        self.isActivated = isActivated
        self.viewpoint = viewpoint
        self.tonicPitch = tonicPitch
        if text == "unset" {
            var newText = ""
            if pitch.note(in: .C).noteClass.description == "C" {
                newText = pitch.note(in: .C).description
            } else {
                newText = ""
            }
            self.text = newText
        } else {
            self.text = text
        }
        self.intervallicKeyColors = intervallicKeyColors
        self.intervallicKeySymbols = intervallicKeySymbols
        self.intervallicSymbolColors = intervallicSymbolColors
        self.twoSymbolsOnPerfects = twoSymbolsOnPerfects
        self.whiteKeyColor = whiteKeyColor
        self.blackKeyColor = blackKeyColor
        self.pressedColor = pressedColor
        self.flatTop = flatTop
        self.alignment = alignment
        self.isActivatedExternally = isActivatedExternally
    }

    var pitch: Pitch
    var isActivated: Bool
    var viewpoint: Viewpoint
    var tonicPitch: Pitch
    var text: String
    var whiteKeyColor: Color
    var intervallicKeyColors: [CGColor]
    var intervallicKeySymbols: [any Shape]
    var intervallicSymbolColors: [CGColor]
    var twoSymbolsOnPerfects: Bool
    var blackKeyColor: Color
    var pressedColor: Color
    var flatTop: Bool
    var alignment: Alignment
    var isActivatedExternally: Bool

    var keyColor: Color {
        switch viewpoint {
        case .diatonic:
            if isActivatedExternally || isActivated {
                return pressedColor
            } else {
                return pitch.note(in: .C).accidental == .natural ? whiteKeyColor : blackKeyColor
            }
        case .intervallic:
        let color: Color = Color(intervallicKeyColors[Int(pitch.intervalClass(to: tonicPitch))])
           if isActivatedExternally || isActivated {
               return color.adjust(brightness: -0.1)
            } else {
                return color
            }
        }
    }
    
    var keySymbol: any Shape {
        return intervallicKeySymbols[Int(pitch.intervalClass(to: tonicPitch))]
    }
    
    var symbolColor: Color {
        let color: Color = Color(intervallicSymbolColors[Int(pitch.intervalClass(to: tonicPitch))]).adjust(brightness: -0.1)
        if isActivatedExternally || isActivated {
            return color.adjust(brightness: -0.1)
        } else {
            return color
        }
    }
    
    var isWhite: Bool {
        viewpoint == .diatonic ? pitch.note(in: .C).accidental == .natural : false
    }

    var textColor: Color {
        return pitch.note(in: .C).accidental == .natural ? blackKeyColor : whiteKeyColor
    }

    func minDimension(_ size: CGSize) -> CGFloat {
        return min(size.width, size.height)
    }

    func isTall(size: CGSize) -> Bool {
        size.height > size.width
    }

    // How much of the key height to take up with label
    func relativeFontSize(in containerSize: CGSize) -> CGFloat {
        minDimension(containerSize) * 0.333
    }

    let relativeTextPadding = 0.05

    func relativeCornerRadius(in containerSize: CGSize) -> CGFloat {
        minDimension(containerSize) * 0.125
    }

    func topPadding(_ size: CGSize) -> CGFloat {
        flatTop && alignment == .bottom ? relativeCornerRadius(in: size) : 0
    }

    func leadingPadding(_ size: CGSize) -> CGFloat {
        flatTop && alignment == .trailing ? relativeCornerRadius(in: size) : 0
    }

    func negativeTopPadding(_ size: CGSize) -> CGFloat {
        flatTop && alignment == .bottom ? -relativeCornerRadius(in: size) :
            isWhite ? 0.5 : 0
    }

    func negativeLeadingPadding(_ size: CGSize) -> CGFloat {
        flatTop && alignment == .trailing ? -relativeCornerRadius(in: size) :
            isWhite ? 0.5 : 0
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: alignment) {
                ZStack {
                    Rectangle()
                        .fill(.black)
                        .padding(.top, topPadding(proxy.size))
                        .padding(.leading, leadingPadding(proxy.size))
                        .cornerRadius(relativeCornerRadius(in: proxy.size))
                        .padding(.top, negativeTopPadding(proxy.size))
                        .padding(.leading, negativeLeadingPadding(proxy.size))
                    Rectangle()
                        .fill(keyColor)
                        .padding(.top, topPadding(proxy.size))
                        .padding(.leading, leadingPadding(proxy.size))
                        .cornerRadius(relativeCornerRadius(in: proxy.size))
                        .padding(.top, negativeTopPadding(proxy.size))
                        .padding(.leading, negativeLeadingPadding(proxy.size))
                        .frame(width: proxy.size.width - 1, height: proxy.size.height - 1)
                }
                Text(text)
                    .font(Font(.init(.system, size: relativeFontSize(in: proxy.size))))
                    .foregroundColor(textColor)
                    .padding(relativeFontSize(in: proxy.size) / 3.0)
                let symbolSize = proxy.size.width / pow(goldenRatio, 3)
                if twoSymbolsOnPerfects && (Int(pitch.intervalClass(to: tonicPitch)) == 5 || Int(pitch.intervalClass(to: tonicPitch)) == 7) {
                    VStack(spacing: 0) {
                        AnyShape(keySymbol)
                            .foregroundColor(symbolColor)
                            .aspectRatio(1.0, contentMode: .fit)
                            .frame(width: symbolSize)
                            .offset(y: proxy.size.height * 0.25 + 0.5 * symbolSize)
                        AnyShape(keySymbol)
                            .foregroundColor(symbolColor)
                            .aspectRatio(1.0, contentMode: .fit)
                            .frame(width: symbolSize)
                            .offset(y: -proxy.size.height * 0.25 - 0.5 * symbolSize)
                    }
                } else {
                    AnyShape(keySymbol)
                        .foregroundColor(symbolColor)
                        .aspectRatio(1.0, contentMode: .fit)
                        .padding([.top, .bottom], 10)
                        .frame(width: symbolSize)
                }
            }
        }
    }
}

extension Color {
    func adjust(hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, opacity: CGFloat = 1) -> Color {
        let color = UIColor(self)
        var currentHue: CGFloat = 0
        var currentSaturation: CGFloat = 0
        var currentBrigthness: CGFloat = 0
        var currentOpacity: CGFloat = 0

        if color.getHue(&currentHue, saturation: &currentSaturation, brightness: &currentBrigthness, alpha: &currentOpacity) {
            return Color(hue: currentHue + hue, saturation: currentSaturation + saturation, brightness: currentBrigthness + brightness, opacity: currentOpacity + opacity)
        }
        return self
    }
}

