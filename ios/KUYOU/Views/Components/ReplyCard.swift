import SwiftUI

struct ReplyCard: View {
    let reply: Reply
    let isPostOwner: Bool
    let onSelectBest: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "person.crop.circle.badge.checkmark")
                    .font(.title3)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(reply.userNickname)
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Text(formatDate(reply.createdAt))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Best answer indicator
                if reply.isBest {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        Text("ベストアンサー")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(12)
                }
            }
            
            // Content
            Text(reply.content)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
            
            // Actions
            if isPostOwner && !reply.isBest {
                Button(action: onSelectBest) {
                    HStack {
                        Image(systemName: "checkmark.circle")
                        Text("ベストアンサーに選ぶ")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green)
                    .cornerRadius(20)
                }
            }
            
            // Mine indicator
            if reply.isMine ?? false {
                Text("自分のリライト案")
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(
            reply.isBest ? Color.yellow.opacity(0.05) : Color(.systemGray6)
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(reply.isBest ? Color.yellow.opacity(0.5) : Color.clear, lineWidth: 2)
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}