import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    var isGuideMode: Bool = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Background Color
            Color(red: 0.96, green: 0.97, blue: 0.99)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Main Content Card
                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 40) {
                            // Title Inside Card
                            Text("Get Ready for Form Detection")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.top, 40)
                                .padding(.horizontal, 24)
                                .multilineTextAlignment(.leading)
                            
                            // Instruction Points with Icons
                            VStack(alignment: .leading, spacing: 30) {
                                onboardingItem(
                                    icon: "iphone.landscape",
                                    text: "Rotate the phone to landscape for better body tracking accuracy"
                                )
                                
                                onboardingItem(
                                    icon: "person.fill.viewfinder",
                                    text: "Place phone aligned with your body"
                                )
                                
                                onboardingItem(
                                    icon: "stopwatch.fill",
                                    text: "Real-time feedback starts once we detect your plank form in the frame."
                                )
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.bottom, 40)
                    }
                    
                    // Get Started Button
                    Button(action: {
                        if isGuideMode {
                            dismiss()
                        } else {
                            hasSeenOnboarding = true
                        }
                    }) {
                        Text(isGuideMode ? "Close" : "Get Started")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .background(Color("limeGreen"))
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 48))
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private func onboardingItem(icon: String, text: String) -> some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(Color("secondaryAccent"))
                .frame(width: 40)
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(Color(uiColor: .systemGray6).opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    OnboardingView(hasSeenOnboarding: .constant(false))
}
