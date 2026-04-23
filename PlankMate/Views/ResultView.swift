import SwiftUI

struct ResultView: View {
    @StateObject private var viewModel = ResultViewModel()
    
    // Input dari Camera View
    var totalTime: TimeInterval
    var accuracy: Double
    
    @State private var backToHome = false
    
    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.97, blue: 0.99)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Text("Result")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                // Total Time via ViewModel
                VStack(spacing: 8) {
                    Text("Total Time")
                        .font(.title3)
                    Text(viewModel.timeString(time: totalTime))
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
                            .stroke(Color("limeGreen"), style: StrokeStyle(lineWidth: 15, lineCap: .round))
                            .rotationEffect(Angle(degrees: -90))
                        
                        Text("\(Int(accuracy))%")
                            .font(.system(size: 48, weight: .bold))
                    }
                    .frame(width: 180, height: 180)
                }
                .padding(.vertical, 32)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, 44)
                
                Spacer()
                
                Button(action: {
                    viewModel.saveSession(duration: totalTime, accuracy: accuracy)
                    backToHome = true
                }) {
                    Text("Back to Home")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .background(Color("limeGreen"))
                        .clipShape(RoundedRectangle(cornerRadius: 30))
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
}
