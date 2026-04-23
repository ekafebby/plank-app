import SwiftUI

struct OnboardView: View {
    @Binding var hasSeenIntro: Bool
    var isGuideMode: Bool = false
    @Environment(\.dismiss) var dismiss
    @State private var currentStep = 0
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(uiColor: .systemBackground), Color("secondaryAccent").opacity(0.1)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $currentStep) {
                    // Page 1: Set Up Your Camera
                    cameraSetupSlide
                        .tag(0)
                    
                    // Page 2: Position & Auto Timer
                    positionTimerSlide
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                bottomControls
            }
            
            // Back Button Overlay
            if currentStep > 0 {
                VStack {
                    HStack {
                        Button(action: {
                            withAnimation {
                                currentStep -= 1
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title3.bold())
                                .foregroundColor(.primary)
                                .padding(12)
                                .background(Circle().fill(Color(uiColor: .systemBackground)).shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4))
                        }
                        .padding(.leading, 24)
                        .padding(.top, 20)
                        
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
        .onAppear {
            currentStep = 0
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Slides
    
    // MARK: - Slides
    
    
    private var cameraSetupSlide: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                Spacer(minLength: 40)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Ready for Better Plank?")
                        .font(.title.bold())
                        .foregroundColor(.primary)
                        .padding(.bottom, 8)
                    
                    Text("Let's set up your camera.")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Instruction Cards
                VStack(spacing: 28) {
                    setupCard(
                        icon: "iphone.landscape",
                        title: "Landscape Orientation",
                        subtitle: "Place your phone horizontally for the best tracking. "
                    )
                    
                    setupCard(
                        icon: "shippingbox.fill",
                        title: "Stable Placement",
                        subtitle: "Place it on the floor using a stand or lean it against a wall."
                    )
                    
                    setupCard(
                        icon: "person.fill.viewfinder",
                        title: "Full Body Capture",
                        subtitle: "Position your phone 1-2 meters away to capture your entire body in the frame."
                    )
                }
                .padding(.horizontal)
                
                Spacer(minLength: 40)
            }
        }
    }
    
    private var positionTimerSlide: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                Spacer(minLength: 40)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Automatic Tracking")
                        .font(.title.bold())
                    
                    Text("Help you to monitor and improve your form.")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Instruction Cards
                VStack(spacing: 28) {
                    setupCard(
                        icon: "person.fill.viewfinder",
                        title: "Parallel Alignment",
                        subtitle: "Position your body parallel to the camera for accurate posture tracking."
                    )
                    
                    setupCard(
                        icon: "play.circle.fill",
                        title: "Automatic Timer",
                        subtitle: "The timer starts automatically once your plank form is correctly detected."
                    )
                    
                    setupCard(
                        icon: "speaker.wave.2.fill",
                        title: "Voice Feedback",
                        subtitle: "You will hear voice feedback to help you correct your posture if it's incorrect."
                    )
                }
                .padding(.horizontal)
                
                Spacer(minLength: 40)
            }
        }
    }
    
    // MARK: - Components
    
    private var bottomControls: some View {
        VStack(spacing: 24) {
            // Page Indicator
            HStack(spacing: 8) {
                let pageCount = 2
                let startIndex = 0
                ForEach(startIndex..<(startIndex + pageCount), id: \.self) { index in
                    Capsule()
                        .fill(currentStep == index ? Color("secondaryAccent") : Color.gray.opacity(0.3))
                        .frame(width: currentStep == index ? 24 : 8, height: 8)
                }
            }
            
            // Action Button
            Button(action: {
                if currentStep < 1 {
                    withAnimation {
                        currentStep += 1
                    }
                } else {
                    if isGuideMode {
                        dismiss()
                    } else {
                        withAnimation {
                            hasSeenIntro = true
                        }
                    }
                }
            }) {
                Text(currentStep == 1 ? (isGuideMode ? "Close" : "Get Started") : "Next")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 65)
                    .background(Color("limeGreen"))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: Color("limeGreen").opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
        }
    }
    
    @ViewBuilder
    private func setupCard(icon: String, isSystemIcon: Bool = true, title: String, subtitle: String) -> some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.teal.opacity(0.1))
                    .frame(width: 56, height: 56)
                
                if isSystemIcon {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(.teal)
                } else {
                    if UIImage(named: icon) != nil {
                        Image(icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    } else {
                        Image(systemName: "photo")
                            .foregroundColor(.teal)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3)
                
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    @ViewBuilder
    private func benefitLabel(icon: String, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon).foregroundColor(Color("secondaryAccent")).font(.title2)
            Text(text).font(.title3.bold()).foregroundColor(.primary)
        }
    }
}

#Preview {
    OnboardView(hasSeenIntro: .constant(false))
}
