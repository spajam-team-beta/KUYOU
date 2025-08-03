import SwiftUI

struct AnimationConstants {
    static let mokugyoTap = Animation.spring(response: 0.3, dampingFraction: 0.6)
    static let salvationGlow = Animation.easeInOut(duration: 0.8).repeatCount(1)
    static let ascension = Animation.easeOut(duration: 2.0)
    static let cardAppear = Animation.spring(response: 0.5, dampingFraction: 0.8)
    static let fadeIn = Animation.easeIn(duration: 0.3)
}

struct MokugyoTapModifier: ViewModifier {
    @Binding var isPressed: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .animation(AnimationConstants.mokugyoTap, value: isPressed)
    }
}

struct SalvationGlowModifier: ViewModifier {
    @State private var glowAmount: Double = 0
    @Binding var triggerGlow: Bool
    
    func body(content: Content) -> some View {
        content
//            .overlay(
//                Circle()
//                    .stroke(Color.yellow.opacity(0.6), lineWidth: 2)
//                    .scaleEffect(1 + glowAmount)
//                    .opacity(1 - glowAmount)
//                    .animation(AnimationConstants.salvationGlow, value: glowAmount)
//            )
            .onChange(of: triggerGlow) { _, newValue in
                if newValue {
                    glowAmount = 0.5
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        glowAmount = 0
                        triggerGlow = false
                    }
                }
            }
    }
}

struct AscensionModifier: ViewModifier {
    @Binding var isAscending: Bool
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1
    @State private var rotation: Double = 0
    
    func body(content: Content) -> some View {
        content
            .offset(y: offset)
            .opacity(opacity)
            .rotationEffect(.degrees(rotation))
            .onChange(of: isAscending) { _, newValue in
                if newValue {
                    withAnimation(AnimationConstants.ascension) {
                        offset = -500
                        opacity = 0
                        rotation = 360
                    }
                }
            }
    }
}

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}

extension View {
    func mokugyoTap(isPressed: Binding<Bool>) -> some View {
        modifier(MokugyoTapModifier(isPressed: isPressed))
    }
    
    func salvationGlow(trigger: Binding<Bool>) -> some View {
        modifier(SalvationGlowModifier(triggerGlow: trigger))
    }
    
    func ascensionEffect(isAscending: Binding<Bool>) -> some View {
        modifier(AscensionModifier(isAscending: isAscending))
    }
    
    func shake(animatableData: CGFloat) -> some View {
        modifier(ShakeEffect(animatableData: animatableData))
    }
}

struct ParticleView: View {
    let emoji: String
    @State private var offset = CGSize.zero
    @State private var opacity: Double = 1
    
    var body: some View {
        Text(emoji)
            .font(.system(size: 20))
            .offset(offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.linear(duration: 2)) {
                    offset = CGSize(
                        width: Double.random(in: -100...100),
                        height: Double.random(in: -200...(-100))
                    )
                    opacity = 0
                }
            }
    }
}

struct ParticleEmitterView: View {
    @Binding var emit: Bool
    let particleCount: Int = 10
    let emojis = ["✨", "⭐", "🌟", "💫", "🙏"]
    
    var body: some View {
        ZStack {
            if emit {
                ForEach(0..<particleCount, id: \.self) { index in
                    ParticleView(emoji: emojis.randomElement() ?? "✨")
                        .position(x: 0, y: 0)
                }
            }
        }
        .onChange(of: emit) { _, newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    emit = false
                }
            }
        }
    }
}
