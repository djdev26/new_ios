import SwiftUI

struct ContentView: View {
    @StateObject private var voiceManager = AruviVoiceManager()
    
    var body: some View {
        ZStack {
            // Dark Background
            Color(red: 13/255, green: 15/255, blue: 18/255)
                .ignoresSafeArea()
            
            if !voiceManager.isPaired {
                // Phone-First Pairing Screen
                VStack(spacing: 35) {
                    Spacer()
                    
                    Text("Aruvi")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .tracking(5)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 15) {
                        Text("IPHONE PAIRING CODE")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .tracking(2)
                        
                        Text(voiceManager.pairingCode.isEmpty ? "------" : voiceManager.pairingCode)
                            .font(.system(size: 46, weight: .black, design: .monospaced))
                            .foregroundColor(.yellow)
                            .tracking(6)
                    }
                    .padding(35)
                    .background(Color(red: 26/255, green: 29/255, blue: 36/255))
                    .cornerRadius(24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.yellow.opacity(0.3), lineWidth: 1.5)
                    )
                    
                    VStack(spacing: 8) {
                        Text("Enter this code in your laptop agent window to pair your device.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Text(voiceManager.statusMessage)
                            .font(.caption)
                            .bold()
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                }
            } else {
                // Main Focus and Conversation Interface
                VStack(spacing: 25) {
                    // Header
                    HStack {
                        Spacer()
                        VStack(spacing: 5) {
                            Text("Aruvi")
                                .font(.system(size: 26, weight: .bold, design: .default))
                                .tracking(3)
                                .foregroundColor(.white)
                            
                            Text("Good evening, Dijo")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.leading, 40)
                        
                        Spacer()
                        
                        Button(action: {
                            voiceManager.unpair()
                        }) {
                            Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 20)
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Accountability Focus Widget
                    if voiceManager.isAccountabilityActive, let session = voiceManager.activeSession {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Active Focus Session")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .textCase(.uppercase)
                            
                            Text(session.title)
                                .font(.title3)
                                .bold()
                                .foregroundColor(.white)
                            
                            HStack {
                                Text(voiceManager.elapsedTimeFormatted)
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                HStack(spacing: 5) {
                                    Circle()
                                        .fill(productivityColor(session.productivity))
                                        .frame(width: 8, height: 8)
                                    Text(session.productivity)
                                        .font(.caption)
                                        .bold()
                                        .foregroundColor(productivityColor(session.productivity))
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(productivityColor(session.productivity).opacity(0.15))
                                .cornerRadius(6)
                            }
                        }
                        .padding()
                        .background(Color(red: 26/255, green: 29/255, blue: 36/255))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal)
                    }
                    
                    // Pulsing Microphone Button
                    VStack(spacing: 15) {
                        Button(action: {
                            voiceManager.toggleRecording()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(voiceManager.isRecording ? Color.red : Color.blue)
                                    .frame(width: 90, height: 90)
                                    .shadow(color: (voiceManager.isRecording ? Color.red : Color.blue).opacity(0.3), radius: 10, x: 0, y: 5)
                                
                                Image(systemName: voiceManager.isRecording ? "stop.fill" : "mic.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.white)
                            }
                            .scaleEffect(voiceManager.isRecording ? 1.08 : 1.0)
                            .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: voiceManager.isRecording)
                        }
                        
                        Text(voiceManager.statusMessage)
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    Spacer()
                    
                    // Tonight's commitments
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tonight's Schedule")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .textCase(.uppercase)
                            .padding(.horizontal)
                        
                        ScrollView {
                            VStack(spacing: 0) {
                                if voiceManager.commitments.isEmpty {
                                    Text("No commitments today. Talk to Aruvi to schedule tasks.")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .padding(.vertical, 20)
                                        .frame(maxWidth: .infinity)
                                } else {
                                    ForEach(voiceManager.commitments) { task in
                                        HStack {
                                            Circle()
                                                .fill(taskStatusColor(task.status))
                                                .frame(width: 8, height: 8)
                                            
                                            Text(task.title)
                                                .font(.body)
                                                .foregroundColor(.white)
                                                .strikethrough(task.status == "completed")
                                            
                                            Spacer()
                                            
                                            Text(task.timeFormatted)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.vertical, 10)
                                        .padding(.horizontal)
                                        Divider()
                                            .background(Color.white.opacity(0.05))
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 180)
                        .background(Color(red: 26/255, green: 29/255, blue: 36/255))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            voiceManager.connect()
        }
    }
    
    // Helpers
    private func productivityColor(_ status: String) -> Color {
        if status.contains("productive") { return .green }
        if status.contains("Can't tell") { return .yellow }
        return .red
    }
    
    private func taskStatusColor(_ status: String) -> Color {
        switch status {
        case "in_progress": return .green
        case "rescheduled": return .blue
        case "completed": return .gray
        default: return .yellow
        }
    }
}
