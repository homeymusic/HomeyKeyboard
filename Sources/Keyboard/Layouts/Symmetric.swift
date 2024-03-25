import SwiftUI
import Tonic

struct Symmetric<Content>: View where Content: View {
    let content: (Pitch, Bool) -> Content
    var model: KeyboardModel
    var pitchRange: ClosedRange<Pitch>
    var root: NoteClass
    var scale: Scale
    
    var body: some View {
        HStack(spacing: 0) {
            let P1 = pitchRange.startIndex
            let m2 = pitchRange.index(after: P1)
            let M2 = pitchRange.index(after: m2)
            let m3 = pitchRange.index(after: M2)
            let M3 = pitchRange.index(after: m3)
            let P4 = pitchRange.index(after: M3)
            let tt = pitchRange.index(after: P4)
            let P5 = pitchRange.index(after: tt)
            let m6 = pitchRange.index(after: P5)
            let M6 = pitchRange.index(after: m6)
            let m7 = pitchRange.index(after: M6)
            let M7 = pitchRange.index(after: m7)
            let P8 = pitchRange.index(after: M7)
            
            KeyContainer(model: model,
                         pitch: pitchRange[P1],
                         content: content)
            VStack(spacing: 0){
                KeyContainer(model: model,
                             pitch: pitchRange[M2],
                             content: content)
                KeyContainer(model: model,
                             pitch: pitchRange[m2],
                             content: content)
            }
            VStack(spacing: 0){
                KeyContainer(model: model,
                             pitch: pitchRange[M3],
                             content: content)
                KeyContainer(model: model,
                             pitch: pitchRange[m3],
                             content: content)
            }
            KeyContainer(model: model,
                         pitch: pitchRange[P4],
                         content: content)
            KeyContainer(model: model,
                         pitch: pitchRange[P5],
                         content: content)
            .overlay() {
                GeometryReader { proxy in
                    let ttLength = tritoneLength(proxy.size)
                    ZStack {
                        RoundedRectangle(cornerRadius: 0.125 * ttLength)
                            .stroke(.black, lineWidth: 2)
                            .frame(width: ttLength, height: ttLength)
                        KeyContainer(model: model,
                                     pitch: pitchRange[tt],
                                     zIndex: 1,
                                     content: content)
                        .frame(width: ttLength, height: ttLength)
                    }
                    .offset(x: -ttLength / 2.0, y: proxy.size.height / 2.0 - ttLength / 2.0)
                }
            }
            VStack(spacing: 0){
                KeyContainer(model: model,
                             pitch: pitchRange[M6],
                             content: content)
                KeyContainer(model: model,
                             pitch: pitchRange[m6],
                             content: content)
            }
            VStack(spacing: 0){
                KeyContainer(model: model,
                             pitch: pitchRange[M7],
                             content: content)
                KeyContainer(model: model,
                             pitch: pitchRange[m7],
                             content: content)
            }
            KeyContainer(model: model,
                         pitch: pitchRange[P8],
                         content: content)
        }
        .clipShape(Rectangle())
    }
    
    func tritoneLength(_ proxySize: CGSize) -> CGFloat {
        return min(proxySize.height * 0.3125, proxySize.width * 1.0)
    }
    
}
