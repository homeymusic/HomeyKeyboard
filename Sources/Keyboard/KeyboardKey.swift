// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Keyboard/

import SwiftUI
import Tonic

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
                intervallicSymbolSize: [CGFloat] = IntervalSymbolSize.homey,
                centeredTritone: Bool = false,
                backgroundColor: Color = .black,
                whiteKeyColor: Color = .white,
                blackKeyColor: Color = .black,
                pressedColor: Color? = nil,
                flatTop: Bool = false,
                alignment: Alignment = .bottom,
                isPianoLayout: Bool = false,
                subtle: Bool = false,
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
        self.intervallicSymbolSize = intervallicSymbolSize
        self.centeredTritone = centeredTritone
        self.backgroundColor = backgroundColor
        self.whiteKeyColor = whiteKeyColor
        self.blackKeyColor = blackKeyColor
        self.pressedColor = pressedColor
        self.flatTop = flatTop
        self.isPianoLayout = isPianoLayout
        self.subtle = subtle
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
    var intervallicSymbolSize: [CGFloat]
    var backgroundColor: Color
    var centeredTritone: Bool
    var blackKeyColor: Color
    var pressedColor: Color?
    var flatTop: Bool
    var isPianoLayout: Bool
    var subtle: Bool
    var alignment: Alignment
    var isActivatedExternally: Bool
    
    var activated: Bool {
        isActivatedExternally || isActivated
    }
    
    var keyColor: Color {
        switch viewpoint {
        case .diatonic:
            let color: Color = isWhite ? whiteKeyColor : blackKeyColor
            if activated {
                if pressedColor == nil {
                    return isWhite ? color.adjust(brightness: -0.3) : color.adjust(brightness: +0.3)
                } else {
                    return pressedColor!
                }
            } else {
                return color
            }
        case .intervallic:
            if subtle {
                if activated {
                    return Color(intervallicSymbolColors[Int(pitch.intervalClass(to: tonicPitch))])
                } else {
                    return Color(intervallicKeyColors[Int(pitch.intervalClass(to: tonicPitch))])
                }
            } else {
                let color = Color(intervallicKeyColors[Int(pitch.intervalClass(to: tonicPitch))])
                return activated ? color.adjust(brightness: -0.2) : color
            }
        }
    }
        
    var symbolColor: Color {
        switch viewpoint {
        case .diatonic:
            return isWhite ? .white.adjust(brightness: -0.1) : .black.adjust(brightness: +0.4)
        case .intervallic:
            if subtle {
                if activated {
                    return Color(intervallicKeyColors[Int(pitch.intervalClass(to: tonicPitch))])
                } else {
                    return Color(intervallicSymbolColors[Int(pitch.intervalClass(to: tonicPitch))])
                }
            } else {
                let color =  Color(intervallicSymbolColors[Int(pitch.intervalClass(to: tonicPitch))])
                if activated {
                    return color.adjust(brightness: +0.2)
                } else {
                    return color.adjust(brightness: -0.10)
                }
            }
        }
    }
    
    var keySymbol: any Shape {
        return intervallicKeySymbols[Int(pitch.intervalClass(to: tonicPitch))]
    }

    func symbolSize(_ size: CGSize) -> CGFloat {
        return minDimension(size) * intervallicSymbolSize[Int(pitch.intervalClass(to: tonicPitch))]
    }
    
    var isWhite: Bool {
        viewpoint == .diatonic && isPianoLayout && !isSmall
    }
    
    var isSmall: Bool {
        pitch.note(in: .C).accidental != .natural && isPianoLayout
    }
    
    var tonicOutlineColor: Color {
        activated ? Color(intervallicSymbolColors[5]).adjust(brightness: 0.1) : Color(intervallicSymbolColors[5])
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
        isSmall ? 0.5 : 0
    }
    
    func negativeLeadingPadding(_ size: CGSize) -> CGFloat {
        flatTop && alignment == .trailing ? -relativeCornerRadius(in: size) :
        isSmall ? 0.5 : 0
    }
    
    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: alignment) {
                ZStack(alignment: isPianoLayout ? .top : alignment) {
                    let borderSize = 3.0
                    let borderWidthApparentSize = (centeredTritone && Int(pitch.intervalClass(to: tonicPitch)) == 6) || isSmall ? 1.0 * borderSize : borderSize
                    let borderHeightApparentSize = isPianoLayout && viewpoint == .intervallic ? borderWidthApparentSize / 2 : borderWidthApparentSize
                    let outlineTonic: Bool = pitch == tonicPitch && viewpoint == .intervallic
                    let _foo = print("pitch", pitch.midiNoteNumber)
                    let _bar = print("outlineTonic", outlineTonic)
                    Rectangle()
                        .fill(backgroundColor)
                        .padding(.top, topPadding(proxy.size))
                        .padding(.leading, leadingPadding(proxy.size))
                        .cornerRadius(relativeCornerRadius(in: proxy.size))
                        .padding(.top, negativeTopPadding(proxy.size))
                        .padding(.leading, negativeLeadingPadding(proxy.size))
                    if outlineTonic {
                        Rectangle()
                            .fill(tonicOutlineColor)
                            .padding(.top, topPadding(proxy.size))
                            .padding(.leading, leadingPadding(proxy.size))
                            .cornerRadius(relativeCornerRadius(in: proxy.size))
                            .padding(.top, negativeTopPadding(proxy.size))
                            .padding(.leading, negativeLeadingPadding(proxy.size))
                            .frame(width: proxy.size.width - borderWidthApparentSize, height: proxy.size.height - borderHeightApparentSize)
                    }
                    Rectangle()
                        .fill(keyColor)
                        .padding(.top, topPadding(proxy.size))
                        .padding(.leading, leadingPadding(proxy.size))
                        .cornerRadius(relativeCornerRadius(in: proxy.size))
                        .padding(.top, negativeTopPadding(proxy.size))
                        .padding(.leading, negativeLeadingPadding(proxy.size))
                        .frame(width: proxy.size.width - (outlineTonic ? 2.0 * borderWidthApparentSize: borderWidthApparentSize), height: proxy.size.height - (outlineTonic ? 2.0 * borderHeightApparentSize: borderHeightApparentSize))
                }
                .rotationEffect(Angle(degrees: (centeredTritone && (Int(pitch.intervalClass(to: tonicPitch)) == 6)) ? 45 : 0))
                Text(text)
                    .font(Font(.init(.system, size: relativeFontSize(in: proxy.size))))
                    .foregroundColor(textColor)
                    .padding(relativeFontSize(in: proxy.size) / 3.0)
                let symbolSize = symbolSize(proxy.size)
                if centeredTritone && (Int(pitch.intervalClass(to: tonicPitch)) == 0 || Int(pitch.intervalClass(to: tonicPitch)) == 5 || Int(pitch.intervalClass(to: tonicPitch)) == 7) {
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
                } else if viewpoint == .intervallic || (isPianoLayout && pitch == tonicPitch) {
                    AnyShape(keySymbol)
                        .foregroundColor(symbolColor)
                        .aspectRatio(1.0, contentMode: .fit)
                        .offset(y: alignment == .bottom ? -proxy.size.height * (isSmall ? 0.3 : 0.2) : 0)
                        .frame(width: symbolSize * (isSmall ? 1.25 : 1.0))
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

