import SwiftUI
import AVFoundation

struct CameraTrackingView: View {
    @StateObject private var tracker = PlankTracker()
    @State private var navigateToResult = false
    @State private var showingPrepPopUp = false
    @AppStorage("showPrepPopUp") private var showPrepPopUp: Bool = true
    @State private var dontShowAgain: Bool = false
    @State private var hasStartedSession = false
    @State private var showSettingsAlert = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            if tracker.permissionGranted {
                // Camera Background
                CameraPreview(session: tracker.captureSession)
                    .ignoresSafeArea()
                
                // Timer Overlay
                VStack {
                    Text(timeString(time: tracker.plankDuration))
                        .font(.system(size: 64, weight: .bold))
                        .foregroundColor(tracker.isPlanking ? .green : .white)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(16)
                        .padding(.top, 50)
                    
                    Spacer()
                    
                    // Stop Button
                    Button(action: {
                        tracker.stopTracking()
                        navigateToResult = true
                    }) {
                        Text("Stop")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: 200, minHeight: 60)
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                    }
                    .padding(.bottom, 20)
                }
                
                // Prep Pop-up Overlay
                if showingPrepPopUp {
                    ZStack {
                        Color.black.opacity(0.6)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 0) {
                            // Close Button (X)
                            HStack {
                                Spacer()
                                Button(action: {
                                    showPrepPopUp = false // Never show again after clicking X
                                    withAnimation {
                                        showingPrepPopUp = false
                                        startSessionIfPossible()
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.gray.opacity(0.5))
                                        .padding(16)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 24) {
                                prepItem(text: "Ensure whole body is visible in the frame.")
                                prepItem(text: "Timer starts automatically when form is detected.")
                            }
                            .padding(.horizontal, 30)
                            .padding(.bottom, 40)
                        }
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(32)
                        .padding(.horizontal, 40)
                    }
                }
                
            } else {
                // Permission Denied View (Existing logic)
                permissionDeniedView
            }
        }
        .onAppear {
            setOrientation(.portrait)
            tracker.checkCameraPermission()

            if tracker.permissionStatus == .denied || tracker.permissionStatus == .restricted {
                showSettingsAlert = true
            } else if showPrepPopUp {
                showingPrepPopUp = true
            } else {
                startSessionIfPossible()
            }
        }
        .onChange(of: tracker.permissionStatus) { _, status in
            if status == .denied || status == .restricted {
                showSettingsAlert = true
            }
        }
        .onChange(of: tracker.permissionGranted) { _, permissionGranted in
            guard permissionGranted, !showingPrepPopUp else { return }
            startSessionIfPossible()
        }
        .alert("Camera Access Required", isPresented: $showSettingsAlert) {
            Button("Cancel", role: .cancel) {
                dismiss()
            }
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
                dismiss()
            }
        } message: {
            Text("PlankMate needs camera access to track your posture. Please enable it in Settings.")
        }
        .onDisappear {
            if !navigateToResult {
                tracker.stopTracking()
                setOrientation(.portrait)
            }
        }
        .navigationDestination(isPresented: $navigateToResult) {
            ResultView(totalTime: tracker.plankDuration, accuracy: tracker.accuracy)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
    
    private func startSessionIfPossible() {
        guard tracker.permissionGranted, !hasStartedSession else { return }
        hasStartedSession = true
        setOrientation(.landscapeRight)
        tracker.startTracking()
        tracker.isTrackingEnabled = true
    }

    private func setOrientation(_ orientation: UIInterfaceOrientationMask) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }

        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: orientation))
    }
    
    private var permissionDeniedView: some View {
        ZStack {
            // Blurred Background Only
            Color.black.opacity(0.05)
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
        }
    }
    
    private func prepItem(text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("•")
                .foregroundColor(Color("secondaryAccent"))
                .font(.title3)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    func timeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
