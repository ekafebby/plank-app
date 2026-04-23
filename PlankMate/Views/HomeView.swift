import SwiftUI

struct HomeView: View {
    @State private var showGuide = false
    @StateObject private var viewModel = ResultViewModel()
    
    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.97, blue: 0.99)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    
                    // Help Button (Top Right)
                    HStack {
                        Spacer()
                        Button(action: {
                            showGuide = true
                        }) {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.gray.opacity(0.6))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    // 1. Activity Recaps
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Activity Recap")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                            .padding(.top, 10)
                        
                        HStack(spacing: 16) {
                            // 2. Gunakan data dari ViewModel
                            StatCard(title: "Time", value: viewModel.totalMinutes, icon: "clock.fill")
                            StatCard(title: "Streak", value: viewModel.currentStreak, icon: "flame.fill")
                        }
                        .padding(.horizontal)
                    }
                    
                    
                    // 2. Practice Trend (Tampilan Dinamis)
                    VStack(alignment: .leading, spacing: 12) {
                        // Jika ada data, kita bisa tampilkan grafik nanti,
                        // sementara kita update teks empty state-nya
                        VStack(spacing: 12) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color("limeGreen").opacity(0.3))
                            
                            // 3. Update teks berdasarkan jumlah sesi
                            Text(viewModel.practiceCountText)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .padding(.horizontal)
                    }
                    
                    // 3. Daily Insight (Single Box)
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Build Your Core Strength")
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(Color("secondaryAccent"))
                            }
                            
                            Text("Start your session now!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(40)
                        .background(Color("limeGreen").opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .padding(.horizontal)
                    }
                    
                    VStack(spacing:0) {
                        NavigationLink(destination: CameraTrackingView()) {
                            HStack {
                                Text("Start Plank")
                                Image(systemName: "play.fill")
                            }
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
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            // 4. Refresh data setiap kali masuk ke Home
            viewModel.calculateStats()
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            }
        }
        .sheet(isPresented: $showGuide) {
            OnboardView(hasSeenIntro: .constant(true), isGuideMode: true)
        }
    }
    
    // Subviews for clean code
    struct StatCard: View {
        var title: String
        var value: String
        var icon: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(Color("secondaryAccent"))
                    .font(.title3)
                VStack(alignment: .leading, spacing: 2) {
                    Text(value)
                        .font(.title3)
                        .fontWeight(.bold)
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}
//#Preview {
//    NavigationStack {
//        HomeView()
//    }
//}
