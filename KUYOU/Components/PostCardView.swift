import SwiftUI

struct PostCardView: View {
    let blackHistory: BlackHistoryModel
    let onSalvation: () -> Void
    let onTap: () -> Void
    
    @State private var isPressed = false
    @State private var showGlow = false
    @State private var particleEmit = false
    
    private let cardGradient = LinearGradient(
        colors: [
            Color.purple.opacity(0.1),
            Color.purple.opacity(0.05),
            Color.clear
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            cardHeader
            
            Divider()
                .background(Color.purple.opacity(0.3))
            
            cardContent
            
            Divider()
                .background(Color.purple.opacity(0.3))
            
            cardFooter
        }
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(cardGradient)
                
                ofudaPattern
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.purple.opacity(0.3), lineWidth: 2)
        )
        .shadow(color: Color.purple.opacity(0.1), radius: 10, x: 0, y: 5)
        .onTapGesture {
            onTap()
        }
    }
    
    private var cardHeader: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: blackHistory.category.icon)
                    .font(.caption)
                Text(blackHistory.category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.purple.opacity(0.2))
            .foregroundColor(.purple)
            .cornerRadius(12)
            
            Spacer()
            
            if blackHistory.isResolved {
                Label("成仏済", systemImage: "checkmark.seal.fill")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding()
    }
    
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(blackHistory.content)
                .font(.body)
                .lineLimit(5)
                .fixedSize(horizontal: false, vertical: true)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(blackHistory.emotionTags, id: \.self) { tag in
                        Text("#\(tag.rawValue)")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(tag.color).opacity(0.2))
                            .foregroundColor(Color(tag.color))
                            .cornerRadius(10)
                    }
                }
            }
            
            Text(formatDate(blackHistory.createdAt))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    private var cardFooter: some View {
        HStack {
            ZStack {
                mokugyoButton
                    .overlay(
                        GeometryReader { geometry in
                            ParticleEmitterView(emit: $particleEmit)
                                .position(
                                    x: geometry.size.width / 2,
                                    y: geometry.size.height / 2
                                )
                                .allowsHitTesting(false)
                        }
                    )
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "bubble.left")
                    .font(.caption)
                Text("\(blackHistory.isResolved ? "成仏" : "リライト案を見る")")
                    .font(.caption)
                Image(systemName: "chevron.right")
                    .font(.caption2)
            }
            .foregroundColor(.purple)
        }
        .padding()
    }
    
    private var mokugyoButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
                showGlow = true
                particleEmit = true
            }
            
            onSalvation()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                showGlow = false
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: "hands.sparkles.fill")
                    .font(.body)
                Text("\(blackHistory.salvationCount)")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.purple)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Circle()
                    .fill(Color.purple.opacity(0.1))
            )
        }
        .mokugyoTap(isPressed: $isPressed)
        .salvationGlow(trigger: $showGlow)
    }
    
    private var ofudaPattern: some View {
        VStack(spacing: 0) {
            ForEach(0..<3) { _ in
                Rectangle()
                    .fill(Color.purple.opacity(0.03))
                    .frame(height: 1)
                    .padding(.vertical, 20)
            }
        }
        .mask(
            LinearGradient(
                colors: [
                    Color.black.opacity(0),
                    Color.black,
                    Color.black,
                    Color.black.opacity(0)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct PostCardView_Previews: PreviewProvider {
    static var previews: some View {
        PostCardView(
            blackHistory: BlackHistoryModel.mockData[0],
            onSalvation: {},
            onTap: {}
        )
        .padding()
    }
}