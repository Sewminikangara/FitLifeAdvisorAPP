import SwiftUI

struct statCard: View { // Keep lowercase as in your code
    let title: String
    let value: String
    let target: String?
    let icon: String
    let color: Color
    let progress: Double? // 0.0 to 1.0
    
    init(title: String, value: String, target: String? = nil, icon: String, color: Color, progress: Double? = nil) {
        self.title = title
        self.value = value
        self.target = target
        self.icon = icon
        self.color = color
        self.progress = progress
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Header with icon and title
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                
                Spacer()
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(Color(uiColor: .systemGray))
            }
            
            // Value and target
            HStack(alignment: .bottom) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color(uiColor: .label))
                
                Spacer()
                
                if let target = target {
                    Text("/ \(target)")
                        .font(.caption)
                        .foregroundColor(Color(uiColor: .systemGray2))
                }
            }
            
            
        }
        .padding(16)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 16) {
        // Example stat cards
        HStack(spacing: 16) {
            statCard(
                title: "Calories",
                value: "1,847",
                target: "2,200",
                icon: "flame.fill",
                color: .orange,
                progress: 0.75
            )
            
            statCard(
                title: "Steps",
                value: "8,432",
                target: "10,000",
                icon: "figure.walk",
                color: .green,
                progress: 0.84
            )
        }
        
        HStack(spacing: 16) {
            statCard(
                title: "Protein",
                value: "78g",
                target: "120g",
                icon: "bolt.fill",
                color: .blue,
                progress: 0.65
            )
            
            statCard(
                title: "Water",
                value: "6",
                target: "8 cups",
                icon: "drop.fill",
                color: .blue,
                progress: 0.75
            )
        }
    }
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
