import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack {
            Text("Profile & Settings")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.neoCharcoal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.neoBackground)
    }
}
