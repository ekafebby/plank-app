import SwiftUI

struct ResultView: View {
    var totalTime: TimeInterval
    var accuracy: Double
    
    @State private var backToHome = false
    
    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.97, blue: 0.99)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Header
                VStack(alignment: .center, spacing: 4) {
                    Text("Result")
                        .font(.largeTitle)
                        .fontWeight(.bold)
//                    Text("Session Completed")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                // Total Time
                VStack(spacing: 8) {
                    Text("Total Time")
                        .font(.title3)
                    
                    Text(timeString(time: totalTime))
                        .font(.system(size: 48, weight: .bold))
                }
                
                // Accuracy Card
                VStack {
                    Text("Accuracy")
                        .font(.title3)
                        .padding(.bottom, 16)
                    
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 15)
                        
                        Circle()
                            .trim(from: 0.0, to: CGFloat(min(accuracy / 100, 1.0)))
                            .stroke(Color("limeGreen", bundle: nil), style: StrokeStyle(lineWidth: 15, lineCap: .round))
                            .rotationEffect(Angle(degrees: -90))
                        
                        VStack {
                            Text("\(Int(accuracy))%")
                                .font(.system(size: 48, weight: .bold))
//                            Text("ACCURACY")
//                                .font(.caption)
//                                .fontWeight(.bold)
//                                .foregroundColor(.gray)
//                                .tracking(2)
                        }
                    }
                    .frame(width: 180, height: 180)
                }
                .padding(.vertical, 32)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, 44)
                
                Spacer()
                
                // Buttons
                VStack(spacing: 16) {
                    Button(action: {
                        backToHome = true
                    }) {
                        Text("Back to Home")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .background(Color("limeGreen", bundle: nil))
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $backToHome) {
            HomeView()
        }
    }
    
    func timeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    NavigationStack {
        ResultView(totalTime: 42, accuracy: 76)
    }
}
