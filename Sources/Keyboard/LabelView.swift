import SwiftUI

struct LabelView: View {
    var keyboardKey: KeyboardKey
    var proxySize: CGSize

    var body: some View {
        
        SymbolView(keyboardKey: keyboardKey, proxySize: proxySize)
    }
}
