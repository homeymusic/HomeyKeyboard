//
//  SwiftUIView.swift
//  
//
//  Created by Brian McAuliff Mulloy on 3/31/24.
//

import SwiftUI

public struct Symbol: View {
    var keyboardKey: KeyboardKey
    var proxySize: CGSize
    
    public var body: some View {
        let symbolAdjustedLength = keyboardKey.symbolLength(proxySize) * (keyboardKey.isSmall ? 1.25 : 1.0)
        if keyboardKey.formFactor == .symmetric && (Int(keyboardKey.pitch.intervalClass(to: keyboardKey.tonicPitch)) == 0 || Int(keyboardKey.pitch.intervalClass(to: keyboardKey.tonicPitch)) == 5 || Int(keyboardKey.pitch.intervalClass(to: keyboardKey.tonicPitch)) == 7) {
            VStack(spacing: 0) {
                let offset = proxySize.height * 0.25 + 0.5 * symbolAdjustedLength
                ZStack {
                    AnyShape(keyboardKey.keySymbol)
                        .foregroundColor(keyboardKey.symbolColor)
                        .aspectRatio(1.0, contentMode: .fit)
                        .frame(width: symbolAdjustedLength)
                        .offset(y: offset)
                    if keyboardKey.pitch == keyboardKey.tonicPitch {
                        Door(symbolLength: symbolAdjustedLength, keyColor: keyboardKey.keyColor, offset: offset)
                    }
                }
                ZStack {
                    AnyShape(keyboardKey.keySymbol)
                        .foregroundColor(keyboardKey.symbolColor)
                        .aspectRatio(1.0, contentMode: .fit)
                        .frame(width: symbolAdjustedLength)
                        .offset(y: -offset)
                    if keyboardKey.pitch == keyboardKey.tonicPitch {
                        Door(symbolLength: symbolAdjustedLength, keyColor: keyboardKey.keyColor, offset: -offset)
                    }
                }
            }
        } else  {
            let offset = keyboardKey.formFactor == .piano ? -proxySize.height * (keyboardKey.isSmall ? 0.3 : 0.2) : 0
            ZStack {
                AnyShape(keyboardKey.keySymbol)
                    .foregroundColor(keyboardKey.symbolColor)
                    .aspectRatio(1.0, contentMode: .fit)
                    .offset(y: offset)
                    .frame(width: symbolAdjustedLength)
                if keyboardKey.pitch == keyboardKey.tonicPitch {
                    Door(symbolLength: symbolAdjustedLength, keyColor: keyboardKey.keyColor, offset: offset + (keyboardKey.formFactor == .piano ? 0.1 : 0.0))
                }
            }
        }
    }
}

public struct Door: View {
    
    var symbolLength: CGFloat
    var keyColor: Color
    var offset: CGFloat = 0.0
    
    public var body: some View {
        let doorHeight = symbolLength * 0.4
        Rectangle()
            .foregroundColor(keyColor)
            .frame(width: doorHeight * 0.5, height: doorHeight)
            .offset(y: offset + (symbolLength - doorHeight) * 0.5)
    }
}

