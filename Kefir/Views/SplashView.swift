import SwiftUI

// Анимированный сплэш на время загрузки данных.
// Показывается поверх ContentView, плавно исчезает когда данные готовы.
struct SplashView: View {
    @State private var scale: CGFloat = 0.6
    @State private var opacity: Double = 0
    @State private var rotation: Double = -10
    @State private var dotsPhase: Int = 0

    private let timer = Timer.publish(every: 0.35, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // Градиентный фон (тот же что launch screen)
            LinearGradient(
                colors: [Color(red: 0.42, green: 0.35, blue: 0.22),
                         Color(red: 0.24, green: 0.19, blue: 0.14)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                ZStack {
                    // Три пульсирующих круга
                    ForEach(0..<3) { i in
                        Circle()
                            .stroke(Color.white.opacity(0.4), lineWidth: 2)
                            .frame(width: 120, height: 120)
                            .scaleEffect(scale + CGFloat(i) * 0.2)
                            .opacity(opacity * 0.5)
                    }
                    // Иконка
                    ZStack {
                        Text("A")
                            .font(.system(size: 92, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .offset(x: -18, y: -8)
                        Text("あ")
                            .font(.system(size: 70, weight: .bold))
                            .foregroundStyle(Color(red: 1.0, green: 0.85, blue: 0.4))
                            .offset(x: 22, y: 12)
                    }
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(rotation))
                }

                VStack(spacing: 6) {
                    Text("MyDict")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .opacity(opacity)
                    Text("Готовлю твои карточки" + String(repeating: ".", count: dotsPhase + 1))
                        .font(.callout)
                        .foregroundStyle(.white.opacity(0.7))
                        .opacity(opacity)
                        .monospacedDigit()
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
                rotation = 0
            }
        }
        .onReceive(timer) { _ in
            dotsPhase = (dotsPhase + 1) % 3
        }
    }
}

#Preview {
    SplashView()
}
