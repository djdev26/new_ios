import Foundation
import Speech
import AVFoundation
import Combine

struct CommitmentItem: Identifiable, Codable {
    var id: Int
    var title: String
    var scheduled_time: String
    var deadline: String?
    var status: String
    
    var id_val: String { String(id) }
    
    var timeFormatted: String {
        let formatter = ISO8601DateFormatter()
        let cleanTime = scheduled_time.replacingOccurrences(of: " ", with: "T")
        if let date = formatter.date(from: cleanTime) {
            let outputFormatter = DateFormatter()
            outputFormatter.timeStyle = .short
            return outputFormatter.string(from: date)
        }
        return scheduled_time
    }
}

struct ActiveFocusSession: Codable {
    var title: String
    var productivity: String
    var elapsed_seconds: Int
}

class AruviVoiceManager: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
    @Published var isRecording = false
    @Published var statusMessage = "Waiting for connection..."
    @Published var commitments: [CommitmentItem] = []
    @Published var isAccountabilityActive = false
    @Published var activeSession: ActiveFocusSession?
    @Published var elapsedTimeFormatted = "00:00:00"
    
    // Pairing States
    @Published var pairingCode = ""
    @Published var isPaired = false
    
    private var webSocketTask: URLSessionWebSocketTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var focusTimer: Timer?
    
    // Configurable API Host
    private let serverURL = URL(string: "ws://192.168.137.1:8000/ws/chat")!
    
    override init() {
        super.init()
        // Load persistent pairing state from memory
        self.isPaired = UserDefaults.standard.bool(forKey: "aruvi_is_paired")
    }
    
    private var clientId: String {
        if let id = UserDefaults.standard.string(forKey: "aruvi_client_id") {
            return id
        }
        let id = "c_" + UUID().uuidString.prefix(12)
        UserDefaults.standard.set(id, forKey: "aruvi_client_id")
        return id
    }
    
    func connect() {
        let urlWithQuery = URL(string: "ws://192.168.137.1:8000/ws/chat?client_id=\(clientId)")!
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: urlWithQuery)
        webSocketTask?.resume()
        receiveMessage()
        
        statusMessage = "Connected to Aruvi server."
        requestPermissions()
    }
    
    func unpair() {
        let url = URL(string: "http://192.168.137.1:8000/api/unpair")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["client_id": clientId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        // Disconnect WebSocket and clear local memory settings
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        
        UserDefaults.standard.removeObject(forKey: "aruvi_is_paired")
        UserDefaults.standard.removeObject(forKey: "aruvi_client_id")
        
        DispatchQueue.main.async {
            self.isPaired = false
            self.pairingCode = ""
            self.statusMessage = "Unpaired. Waiting for connection..."
        }
        
        // Send unpair signal in background
        URLSession.shared.dataTask(with: request) { [weak self] _, _, _ in
            self?.connect()
        }.resume()
    }
    
    private func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    break
                case .denied, .restricted, .notDetermined:
                    self.statusMessage = "Speech permissions not granted."
                @unknown default:
                    break
                }
            }
        }
        
        AVAudioApplication.requestRecordPermission { granted in
            if !granted {
                DispatchQueue.main.async {
                    self.statusMessage = "Microphone access denied."
                }
            }
        }
    }
    
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            do {
                try startRecording()
            } catch {
                statusMessage = "Error starting: \(error.localizedDescription)"
                stopRecording()
            }
        }
    }
    
    private func startRecording() throws {
        recognitionTask?.cancel()
        recognitionTask = nil
        
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create request")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                DispatchQueue.main.async {
                    self.statusMessage = result.bestTranscription.formattedString
                }
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                DispatchQueue.main.async {
                    self.isRecording = false
                    if let result = result {
                        self.sendTextMessage(result.bestTranscription.formattedString)
                    }
                }
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        isRecording = true
        statusMessage = "Aruvi is listening..."
    }
    
    private func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        isRecording = false
    }
    
    private func sendTextMessage(_ text: String) {
        guard let webSocketTask = webSocketTask else { return }
        
        let payload: [String: String] = ["message": text]
        if let jsonData = try? JSONSerialization.data(withJSONObject: payload),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            let message = URLSessionWebSocketTask.Message.string(jsonString)
            webSocketTask.send(message) { error in
                if let error = error {
                    print("WebSocket send error: \(error)")
                }
            }
        }
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                print("WebSocket receive error: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    self.parseIncomingMessage(text)
                case .data(let data):
                    print("Received data: \(data)")
                @unknown default:
                    break
                }
                self.receiveMessage()
            }
        }
    }
    
    private func parseIncomingMessage(_ jsonString: String) {
        guard let data = jsonString.data(using: .utf8) else { return }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                DispatchQueue.main.async {
                    let msgType = json["type"] as? String ?? ""
                    
                    // 1. Handle pairing code assignment
                    if msgType == "pairing_code" {
                        if let code = json["code"] as? String {
                            self.pairingCode = code
                            self.isPaired = false
                            UserDefaults.standard.set(false, forKey: "aruvi_is_paired")
                            self.statusMessage = "Waiting for laptop agent..."
                        }
                    }
                    
                    // 2. Handle successful pairing confirmation
                    if msgType == "paired" {
                        self.isPaired = true
                        UserDefaults.standard.set(true, forKey: "aruvi_is_paired")
                        self.statusMessage = "Connected to Aruvi server."
                    }
                    
                    // 3. Text Response speak
                    if let text = json["text"] as? String {
                        self.speakText(text)
                        self.statusMessage = text
                    }
                    
                    // 4. Commitments list sync
                    if let commitmentsData = json["schedule"] as? [[String: Any]],
                       let compData = try? JSONSerialization.data(withJSONObject: commitmentsData) {
                        self.commitments = (try? JSONDecoder().decode([CommitmentItem].self, from: compData)) ?? []
                    }
                    
                    // 5. Accountability State sync
                    if let accDict = json["accountability"] as? [String: Any] {
                        let status = accDict["status"] as? String ?? "Idle"
                        if status == "Active" || status == "Distracted" {
                            self.isAccountabilityActive = true
                            if let activeTask = accDict["active_task"] as? [String: Any] {
                                let title = activeTask["title"] as? String ?? "Focus Task"
                                let productivity = accDict["productivity"] as? String ?? "🟢 Productive"
                                let elapsed = accDict["elapsed_seconds"] as? Int ?? 0
                                
                                self.activeSession = ActiveFocusSession(title: title, productivity: productivity, elapsed_seconds: elapsed)
                                self.startFocusTicker()
                            }
                        } else {
                            self.isAccountabilityActive = false
                            self.activeSession = nil
                            self.stopFocusTicker()
                        }
                    }
                    
                    // 6. Proactive voice notification
                    if msgType == "proactive_reminder",
                       let message = json["message"] as? String {
                        self.speakText(message)
                        self.statusMessage = message
                    }
                }
            }
        } catch {
            print("Failed to parse JSON: \(error)")
        }
    }
    
    private func speakText(_ text: String) {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        
        let cleanText = text.replace(/\\[.*?\\]/, with: "")
        let utterance = AVSpeechUtterance(string: cleanText)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-IN") ?? AVSpeechSynthesisVoice(language: "ta-IN")
        utterance.rate = 0.52
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .voicePrompt, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set audio session: \(error)")
        }
        
        speechSynthesizer.speak(utterance)
    }
    
    private func startFocusTicker() {
        focusTimer?.invalidate()
        focusTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, var session = self.activeSession else { return }
            session.elapsed_seconds += 1
            self.activeSession = session
            self.updateTimerLabel(session.elapsed_seconds)
        }
    }
    
    private func stopFocusTicker() {
        focusTimer?.invalidate()
        focusTimer = nil
    }
    
    private func updateTimerLabel(_ sec: Int) {
        let hrs = sec / 3600
        let mins = (sec % 3600) / 60
        let secs = sec % 60
        elapsedTimeFormatted = String(format: "%02d:%02d:%02d", hrs, mins, secs)
    }
}
extension String {
    func replace(_ regexPattern: String, with replacement: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: regexPattern, options: []) else { return self }
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replacement)
    }
}
