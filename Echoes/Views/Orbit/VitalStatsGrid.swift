import SwiftUI

struct VitalStatsGrid: View {
    @Bindable var viewModel: OrbitViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Card A: The Pulse
                StatCard(
                    title: "The Pulse",
                    icon: "waveform.path.ecg",
                    value: String(format: "%.1f", viewModel.totalHours),
                    unit: "hrs",
                    subtitle: "Total preserved. Consistent!",
                    bgColor: .white,
                    textColor: .neoCharcoal
                )
                
                // Card B: The Streak
                StatCard(
                    title: "Streak",
                    icon: "flame.fill",
                    value: "\(viewModel.currentStreak)",
                    unit: "weeks",
                    subtitle: "You're on fire! Keep it up.",
                    bgColor: .neoPrimary,
                    textColor: .neoCharcoal
                )
            }
            
            // Card C: Topic Mix
            TopicMixCard(topicMix: viewModel.topicMix)
        }
    }
}

struct StatCard: View {
    var title: String
    var icon: String
    var value: String
    var unit: String
    var subtitle: String
    var bgColor: Color
    var textColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 10, weight: .bold))
                    .textCase(.uppercase)
                    .tracking(1.0)
                    .opacity(0.6)
                
                Spacer()
                
                Image(systemName: icon)
                    .font(.system(size: 14))
            }
            
            Spacer(minLength: 0)
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 48, weight: .bold))
                
                Text(unit)
                    .font(.system(size: 12, weight: .semibold))
                    .opacity(0.7)
            }
            
            Text(subtitle)
                .font(.system(size: 10, weight: .medium))
                .opacity(0.8)
                .lineLimit(1)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(bgColor)
                .shadow(color: .neoCharcoal, radius: 0, x: 4, y: 4)
        )
        .foregroundColor(textColor)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.neoCharcoal, lineWidth: 2)
        )
    }
}

struct TopicMixCard: View {
    var topicMix: [String: Int]
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Topic Mix")
                    .font(.system(size: 10, weight: .bold))
                    .textCase(.uppercase)
                    .tracking(1.0)
                    .foregroundColor(.neoCharcoal.opacity(0.6))
                
                Text("Balanced\nArchives")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.neoCharcoal)
                    .lineSpacing(2)
                
                // Badges
                HStack(spacing: 8) {
                    if let top = topCategories.first {
                        CategoryBadge(title: top.key)
                    }
                    if topCategories.count > 1 {
                        CategoryBadge(title: topCategories[1].key)
                    }
                }
                .padding(.top, 4)
            }
            
            Spacer()
            
            // Minimalist Donut Chart
            ZStack {
                Circle()
                    .stroke(Color.black.opacity(0.1), lineWidth: 12)
                    .frame(width: 80, height: 80)
                
                if totalTopics > 0 {
                    ForEach(Array(topCategories.enumerated()), id: \.element.key) { index, element in
                        let startFraction = categoryStartFraction(for: index)
                        let percent = Double(element.value) / Double(totalTopics)
                        
                        Circle()
                            .trim(from: startFraction, to: startFraction + percent - 0.05) // 0.05 gap
                            .stroke(colorForCategory(element.key), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-90))
                    }
                } else {
                    Circle()
                        .trim(from: 0, to: 0.95)
                        .stroke(Color.neoPrimary, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                }
                
                Text("Mix")
                    .font(.system(size: 12, weight: .bold))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .neoCharcoal, radius: 0, x: 4, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.neoCharcoal, lineWidth: 2)
        )
    }
    
    private var totalTopics: Int {
        topicMix.values.reduce(0, +)
    }
    
    private var topCategories: [(key: String, value: Int)] {
        topicMix.sorted { $0.value > $1.value }
    }
    
    private func categoryStartFraction(for index: Int) -> Double {
        var start: Double = 0
        for i in 0..<index {
            start += Double(topCategories[i].value) / Double(totalTopics)
        }
        return start
    }
    
    private func colorForCategory(_ category: String) -> Color {
        switch category.lowercased() {
        case "childhood": return .neoTangerine
        case "romance": return .neoBubblegum
        case "travel": return .neoTurquoise
        case "family": return .neoLime
        case "home": return .neoMustard
        default: return .neoMint
        }
    }
}

struct CategoryBadge: View {
    var title: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(colorForCategory(title))
                .frame(width: 6, height: 6)
            
            Text(title)
                .font(.system(size: 10, weight: .bold))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(colorForCategory(title).opacity(0.2))
        .cornerRadius(8)
    }
    
    private func colorForCategory(_ category: String) -> Color {
        switch category.lowercased() {
        case "childhood": return .neoTangerine
        case "romance": return .neoBubblegum
        case "travel": return .neoTurquoise
        case "family": return .neoLime
        case "home": return .neoMustard
        default: return .neoMint
        }
    }
}
