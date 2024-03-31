// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Keyboard/

import SwiftUI
import Tonic

public enum Viewpoint {
    case diatonic
    case intervallic
}

public enum FormFactor {
    case isomorphic
    case symmetric
    case piano
    case guitar
}

public struct KeyboardKey: View {
    public init(pitch: Pitch,
                isActivated: Bool,
                viewpoint: Viewpoint = .intervallic,
                formFactor: FormFactor = .symmetric,
                tonicPitch: Pitch = Pitch(60),
                text: String = "",
                intervallicKeyColors: [CGColor] = IntervalColor.homeySubtle,
                intervallicKeySymbols: [any Shape] = IntervalSymbol.homey,
                intervallicSymbolColors: [CGColor] = IntervalColor.homey,
                intervallicSymbolSize: [CGFloat] = IntervalSymbolSize.homey,
                backgroundColor: Color = .black,
                subtle: Bool = true,
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
        self.formFactor = formFactor
        self.backgroundColor = backgroundColor
        self.subtle = subtle
        self.isActivatedExternally = isActivatedExternally
    }
    
    var pitch: Pitch
    var isActivated: Bool
    var viewpoint: Viewpoint
    var tonicPitch: Pitch
    var text: String
    var intervallicKeyColors: [CGColor]
    var intervallicKeySymbols: [any Shape]
    var intervallicSymbolColors: [CGColor]
    var intervallicSymbolSize: [CGFloat]
    var formFactor: FormFactor
    var backgroundColor: Color
    var subtle: Bool
    var isActivatedExternally: Bool
    
    var activated: Bool {
        isActivatedExternally || isActivated
    }
    
    var keyColor: Color {
        switch viewpoint {
        case .diatonic:
            if activated {
                return Color(intervallicSymbolColors[Int(pitch.intervalClass(to: tonicPitch))])
            } else {
                return isWhite ? .white : .black
            }
        case .intervallic:
            if subtle {
                if activated {
                    return Color(intervallicSymbolColors[Int(pitch.intervalClass(to: tonicPitch))])
                } else {
                    let color = Color(intervallicKeyColors[Int(pitch.intervalClass(to: tonicPitch))])
                    if formFactor == .piano {
                        return isSmall ? color.adjust(brightness: -0.1) : color.adjust(brightness: +0.1)
                    } else {
                        return color
                    }
                    
                }
            } else {
                let color = Color(intervallicKeyColors[Int(pitch.intervalClass(to: tonicPitch))])
                return activated ? color.adjust(brightness: -0.2) : color
            }
        }
    }
    
    var symbolColor: Color {
        if subtle {
            if activated {
                if viewpoint ==  .diatonic {
                    return isWhite ? .white : .black
                } else {
                    return Color(intervallicKeyColors[Int(pitch.intervalClass(to: tonicPitch))])
                }
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
    
    var keySymbol: any Shape {
        return intervallicKeySymbols[Int(pitch.intervalClass(to: tonicPitch))]
    }
    
    func symbolSize(_ size: CGSize) -> CGFloat {
        return minDimension(size) * intervallicSymbolSize[Int(pitch.intervalClass(to: tonicPitch))]
    }
    
    var isWhite: Bool {
        viewpoint == .diatonic && formFactor == .piano && !isSmall
    }
    
    var isSmall: Bool {
        pitch.note(in: .C).accidental != .natural && formFactor == .piano
    }
    
    var textColor: Color {
        return symbolColor
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
        formFactor == .piano ? relativeCornerRadius(in: size) : 0
    }
    
    func leadingPadding(_ size: CGSize) -> CGFloat {
        0
    }
    
    func negativeTopPadding(_ size: CGSize) -> CGFloat {
        formFactor == .piano ? -relativeCornerRadius(in: size) : (isSmall ? 0.5 : 0)
    }
    
    func negativeLeadingPadding(_ size: CGSize) -> CGFloat {
        0.0
    }
    
    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: formFactor == .piano ? .bottom : .center) {
                ZStack(alignment: formFactor == .piano ? .top : .center) {
                    let borderSize = isSmall ? 1.0 : 3.0
                    let borderWidthApparentSize = (formFactor == .symmetric && Int(pitch.intervalClass(to: tonicPitch)) == 6) || isSmall ? 2.0 * borderSize : borderSize
                    let borderHeightApparentSize = formFactor == .piano && viewpoint == .intervallic ? borderWidthApparentSize / 2 : borderWidthApparentSize
                    let outlineTonic: Bool = Int(pitch.intervalClass(to: tonicPitch)) == 0 && viewpoint == .intervallic
                    Rectangle()
                        .fill(backgroundColor)
                        .padding(.top, topPadding(proxy.size))
                        .padding(.leading, leadingPadding(proxy.size))
                        .cornerRadius(relativeCornerRadius(in: proxy.size))
                        .padding(.top, negativeTopPadding(proxy.size))
                        .padding(.leading, negativeLeadingPadding(proxy.size))
                    if outlineTonic {
                        Rectangle()
                            .fill(symbolColor)
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
                .rotationEffect(Angle(degrees: (formFactor == .symmetric && (Int(pitch.intervalClass(to: tonicPitch)) == 6)) ? 45 : 0))
                Text(text)
                    .font(Font(.init(.system, size: relativeFontSize(in: proxy.size))))
                    .foregroundColor(textColor)
                    .padding(relativeFontSize(in: proxy.size) / 3.0)
                let symbolSize = symbolSize(proxy.size) * (isSmall ? 1.25 : 1.0)
                if formFactor == .symmetric && (Int(pitch.intervalClass(to: tonicPitch)) == 0 || Int(pitch.intervalClass(to: tonicPitch)) == 5 || Int(pitch.intervalClass(to: tonicPitch)) == 7) {
                    VStack(spacing: 0) {
                        let offset = proxy.size.height * 0.25 + 0.5 * symbolSize
                        ZStack {
                            AnyShape(keySymbol)
                                .foregroundColor(symbolColor)
                                .aspectRatio(1.0, contentMode: .fit)
                                .frame(width: symbolSize)
                                .offset(y: offset)
                            if pitch == tonicPitch {
                                Door(symbolSize: symbolSize, keyColor: keyColor, offset: offset)
                            }
                        }
                        ZStack {
                            AnyShape(keySymbol)
                                .foregroundColor(symbolColor)
                                .aspectRatio(1.0, contentMode: .fit)
                                .frame(width: symbolSize)
                                .offset(y: -offset)
                            if pitch == tonicPitch {
                                Door(symbolSize: symbolSize, keyColor: keyColor, offset: -offset)
                            }
                        }
                    }
                } else  {
                    let offset = formFactor == .piano ? -proxy.size.height * (isSmall ? 0.3 : 0.2) : 0
                    ZStack {
                        AnyShape(keySymbol)
                            .foregroundColor(symbolColor)
                            .aspectRatio(1.0, contentMode: .fit)
                            .offset(y: offset)
                            .frame(width: symbolSize)
                        if pitch == tonicPitch {
                            Door(symbolSize: symbolSize, keyColor: keyColor, offset: offset + (formFactor == .piano ? 0.1 : 0.0))
                        }
                    }
                }
            }
        }
    }
}

public struct Door: View {
    
    var symbolSize: CGFloat
    var keyColor: Color
    var offset: CGFloat = 0.0
    
    public var body: some View {
        let _foo = print("door offset \(offset)")
        let doorHeight = symbolSize * 0.4
        Rectangle()
            .foregroundColor(keyColor)
            .frame(width: doorHeight * 0.5, height: doorHeight)
            .offset(y: offset + (symbolSize - doorHeight) * 0.5)
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

