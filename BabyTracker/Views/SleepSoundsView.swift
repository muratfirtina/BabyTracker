import SwiftUI
import AVFoundation

// Audio Player Manager (assuming this is correctly placed or accessible)
// If it's in another file, ensure it's properly imported or accessible.
class AudioPlayerManager: ObservableObject {
    private var audioPlayer: AVAudioPlayer?

    func playSound(fileName: String) {
        // Gerçek uygulamada bu dosyalar bundle'da olacak
        // Şu anda simüle ediyoruz
        print("Playing: \(fileName)")

        // Simüle edilmiş ses dosyası çalma
        // Gerçek implementasyonda:
        /*
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            print("Ses dosyası bulunamadı: \(fileName)")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Sonsuz döngü
            audioPlayer?.play()
        } catch {
            print("Ses çalma hatası: \(error)")
        }
        */
    }

    func pause() {
        audioPlayer?.pause()
    }

    func resume() {
        audioPlayer?.play()
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}


struct SleepSoundsView: View {
    @State private var selectedCategory: SleepSoundCategory = .whiteNoise
    @State private var isPlaying = false
    @State private var selectedSound: SleepSound?
    @State private var playbackTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var animateContent = false
    @State private var showTimer = false
    @StateObject private var audioPlayer = AudioPlayerManager()

    private var filteredSounds: [SleepSound] {
        sampleSleepSounds.filter { $0.category == selectedCategory }
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Beautiful gradient background
                Color.sleepGradient
                    .ignoresSafeArea()

                VStack {
                    // Category selection with beautiful design
                    // **FIXED: Using renamed SleepSoundsCategorySelectorView**
                    SleepSoundsCategorySelectorView(
                        selectedCategory: $selectedCategory,
                        onSelectionChange: {
                            HapticFeedback.selection()
                            stopPlayback()
                        }
                    )
                    .opacity(animateContent ? 1.0 : 0)
                    .offset(y: animateContent ? 0 : -20)
                    .animation(.easeOut(duration: 0.8).delay(0.1), value: animateContent)

                    // Now Playing Section with stunning design
                    if let currentSound = selectedSound {
                        ModernNowPlayingCard(
                            sound: currentSound,
                            isPlaying: isPlaying,
                            playbackTime: playbackTime,
                            onPlayPause: togglePlayback,
                            onStop: stopPlayback
                        )
                        .opacity(animateContent ? 1.0 : 0)
                        .offset(y: animateContent ? 0 : 30)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3), value: animateContent)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }

                    // Sleep Sounds Grid with beautiful cards
                    ScrollView {
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2),
                            spacing: 16
                        ) {
                            ForEach(Array(filteredSounds.enumerated()), id: \.offset) { index, sound in
                                ModernSleepSoundCard(
                                    sound: sound,
                                    isCurrentlyPlaying: selectedSound?.id == sound.id && isPlaying,
                                    onTap: {
                                        selectSound(sound)
                                    }
                                )
                                .opacity(animateContent ? 1.0 : 0)
                                .offset(y: animateContent ? 0 : 20)
                                .animation(
                                    .easeOut(duration: 0.6).delay(0.4 + Double(index) * 0.1),
                                    value: animateContent
                                )
                            }
                        }
                        .padding(.horizontal, 20)

                        // Sleep Timer Section
                        ModernSleepTimerCard(
                            isActive: timer != nil,
                            showTimer: $showTimer,
                            onSetTimer: setSleepTimer,
                            onCancelTimer: cancelSleepTimer
                        )
                        .opacity(animateContent ? 1.0 : 0)
                        .offset(y: animateContent ? 0 : 30)
                        .animation(.easeOut(duration: 0.8).delay(0.8), value: animateContent)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }

                    Spacer()
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .onAppear {
            animateContent = true
        }
        .onDisappear {
            stopPlayback()
        }
    }

    private func selectSound(_ sound: SleepSound) {
        if selectedSound?.id == sound.id && isPlaying {
            stopPlayback()
        } else {
            selectedSound = sound
            playSound(sound)
        }
    }

    private func playSound(_ sound: SleepSound) {
        HapticFeedback.lightImpact()
        audioPlayer.playSound(fileName: sound.fileName)
        isPlaying = true
        startPlaybackTimer()
    }

    private func togglePlayback() {
        if isPlaying {
            audioPlayer.pause()
            isPlaying = false
            stopPlaybackTimer()
        } else if let sound = selectedSound {
            audioPlayer.resume()
            isPlaying = true
            startPlaybackTimer()
        }
    }

    private func stopPlayback() {
        audioPlayer.stop()
        isPlaying = false
        selectedSound = nil
        playbackTime = 0
        stopPlaybackTimer()
    }

    private func startPlaybackTimer() {
        stopPlaybackTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            playbackTime += 1
        }
    }

    private func stopPlaybackTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func setSleepTimer(minutes: Int) {
        timer?.invalidate() // Invalidate any existing timer first
        stopPlaybackTimer() // Ensure playback timer is also stopped if a new sleep timer is set
        
        // If a sound is selected and playing, update its timer logic
        if let sound = selectedSound, isPlaying {
             // Keep the playbackTime timer running for UI
            if self.timer == nil { // Only restart if it was truly nil (not just sleep timer)
                 startPlaybackTimer()
            }
        }

        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(minutes * 60), repeats: false) { _ in
            stopPlayback()
        }
    }

    private func cancelSleepTimer() {
        timer?.invalidate()
        timer = nil
        // If a sound is selected and was playing, we might want to ensure the playback timer continues if it's not a general stop
        if selectedSound != nil && isPlaying && self.timer == nil { // Check if the playback timer specifically needs restarting
            startPlaybackTimer()
        }
    }
}

// **FIXED: Renamed from ModernCategorySelector to SleepSoundsCategorySelectorView**
struct SleepSoundsCategorySelectorView: View {
    @Binding var selectedCategory: SleepSoundCategory
    let onSelectionChange: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text("🌙 Uyku Sesleri")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)

                Text("Rahatlayıcı seslerle tatlı rüyalar")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }

            // Category buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(SleepSoundCategory.allCases, id: \.self) { category in
                        // **FIXED: Using renamed SleepSoundCategoryButtonView**
                        SleepSoundCategoryButtonView(
                            title: category.rawValue,
                            icon: category.icon,
                            isSelected: selectedCategory == category
                        ) {
                            selectedCategory = category
                            onSelectionChange()
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.top, 20)
    }
}

// **FIXED: Renamed from ModernCategoryButton to SleepSoundCategoryButtonView**
struct SleepSoundCategoryButtonView: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .fontWeight(.semibold)

                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .foregroundColor(isSelected ? .lilacPurple : .white.opacity(0.8))
            .frame(width: 80, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isSelected ?
                        Color.white :
                        Color.white.opacity(0.15)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                Color.white.opacity(isSelected ? 0.0 : 0.3),
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: isSelected ? Color.white.opacity(0.3) : Color.clear,
                        radius: isSelected ? 8 : 0,
                        x: 0,
                        y: isSelected ? 4 : 0
                    )
            )
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { pressing in
            isPressed = pressing
        } perform: {}
    }
}

// Modern Now Playing Card
struct ModernNowPlayingCard: View {
    let sound: SleepSound
    let isPlaying: Bool
    let playbackTime: TimeInterval
    let onPlayPause: () -> Void
    let onStop: () -> Void

    @State private var pulseAnimation = false

    var body: some View {
        VStack(spacing: 20) {
            // Sound info
            VStack(spacing: 12) {
                Text("Şu Anda Çalıyor")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                    )

                Text(sound.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text(sound.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }

            // Playback time with beautiful design
            VStack(spacing: 8) {
                Text(formatPlaybackTime(playbackTime))
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)

                // Animated progress indicator
                if isPlaying {
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(Color.white.opacity(0.8))
                                .frame(width: 6, height: 6)
                                .scaleEffect(pulseAnimation ? 1.2 : 0.8)
                                .animation(
                                    .easeInOut(duration: 0.8)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.2),
                                    value: pulseAnimation
                                )
                        }
                    }
                    .onAppear {
                        pulseAnimation = true
                    }
                    .onDisappear { // Stop animation when not visible
                        pulseAnimation = false
                    }
                }
            }

            // Control buttons
            HStack(spacing: 24) {
                Button(action: onPlayPause) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 56))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                }

                Button(action: onStop) {
                    Image(systemName: "stop.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.white.opacity(0.8))
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.2),
                            Color.white.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .background(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.6), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }

    private func formatPlaybackTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// Modern Sleep Sound Card
struct ModernSleepSoundCard: View {
    let sound: SleepSound
    let isCurrentlyPlaying: Bool
    let onTap: () -> Void

    @State private var isPressed = false

    // Computed properties to simplify complex expressions
    private var strokeGradient: LinearGradient {
        if isCurrentlyPlaying {
            return LinearGradient(
                colors: [sound.category.color.opacity(0.6), sound.category.color.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color.coolGray.opacity(0.2), Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var shadowColor: Color {
        isCurrentlyPlaying ? sound.category.color.opacity(0.2) : Color.black.opacity(0.05)
    }

    private var shadowRadius: CGFloat {
        isCurrentlyPlaying ? 12 : 6
    }

    private var shadowOffset: CGFloat {
        isCurrentlyPlaying ? 6 : 3
    }

    private var strokeLineWidth: CGFloat {
        isCurrentlyPlaying ? 2 : 1
    }

    var body: some View {
        Button(action: {
            HapticFeedback.lightImpact()
            onTap()
        }) {
            VStack(spacing: 16) {
                // Icon with beautiful background
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    sound.category.color.opacity(0.3),
                                    sound.category.color.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)

                    Image(systemName: isCurrentlyPlaying ? "speaker.wave.2.fill" : sound.category.icon)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(sound.category.color)
                        .scaleEffect(isCurrentlyPlaying ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: isCurrentlyPlaying)
                }

                // Content
                VStack(spacing: 6) {
                    Text(sound.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoal)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)

                    Text(sound.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)

                    // Duration with icon
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)

                        Text(formatDuration(sound.duration))
                            .font(.caption2)
                    }
                    .foregroundColor(sound.category.color.opacity(0.8))
                }

                // Play indicator
                if isCurrentlyPlaying {
                    playingIndicator
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .frame(height: 180) // Fixed height for consistent card size
            .background(cardBackground)
        }
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { pressing in
            isPressed = pressing
        } perform: {}
    }

    // Separate computed properties for complex views
    private var playingIndicator: some View {
        HStack(spacing: 4) {
            Image(systemName: "waveform")
                .font(.caption)

            Text("Çalıyor")
                .font(.caption)
                .fontWeight(.semibold)
        }
        .foregroundColor(Color.successGreen)
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.successGreen.opacity(0.15))
        )
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white)
            .overlay(cardOverlay)
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: 0,
                y: shadowOffset
            )
    }

    private var cardOverlay: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(
                strokeGradient,
                lineWidth: strokeLineWidth
            )
    }

    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

// Modern Sleep Timer Card
struct ModernSleepTimerCard: View {
    let isActive: Bool
    @Binding var showTimer: Bool // This binding seems unused now, consider removing if not needed for future UI changes.
    let onSetTimer: (Int) -> Void
    let onCancelTimer: () -> Void

    @State private var selectedMinutes = 30

    let timerOptions = [15, 30, 45, 60, 90, 120]

    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("⏰ Uyku Zamanlayıcısı")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoal)

                    Text(isActive ? "Zamanlayıcı aktif" : "Müzik otomatik durdurulsun")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Status indicator
                if isActive {
                    StatusBadgeView(
                        "Aktif",
                        color: .successGreen,
                        style: .gradient,
                        size: .medium
                    )
                }
            }

            // Timer options or cancel button
            if isActive {
                Button(action: {
                    HapticFeedback.lightImpact()
                    onCancelTimer()
                }) {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)

                        Text("Zamanlayıcıyı İptal Et")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [.errorRed, .errorRed.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: .errorRed.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
                }
            } else {
                // Timer duration selection
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3),
                    spacing: 12
                ) {
                    ForEach(timerOptions, id: \.self) { minutes in
                        TimerOptionButton(
                            minutes: minutes,
                            isSelected: selectedMinutes == minutes
                        ) {
                            selectedMinutes = minutes
                            HapticFeedback.lightImpact()
                            onSetTimer(minutes)
                        }
                    }
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.lilacPurple.opacity(0.1), radius: 15, x: 0, y: 8)
        )
    }
}

// Timer Option Button
struct TimerOptionButton: View {
    let minutes: Int
    let isSelected: Bool
    let action: () -> Void

    @State private var isPressed = false

    // Computed properties to simplify complex expressions
    private var backgroundGradient: LinearGradient {
        if isSelected {
            return LinearGradient(
                colors: [.lilacPurple, .lilacPurple.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color.lavenderMist.opacity(0.5), Color.lavenderMist.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var strokeColor: Color {
        isSelected ? Color.clear : Color.lilacPurple.opacity(0.3)
    }

    private var shadowColor: Color {
        isSelected ? Color.lilacPurple.opacity(0.4) : Color.clear
    }

    private var shadowRadius: CGFloat {
        isSelected ? 8 : 0
    }

    private var shadowOffset: CGFloat {
        isSelected ? 4 : 0
    }

    private var textColor: Color {
        isSelected ? .white : .lilacPurple
    }

    private var subtitleColor: Color {
        isSelected ? .white.opacity(0.9) : .lilacPurple.opacity(0.7)
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(minutes)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(textColor)

                Text("dakika")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(subtitleColor)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(buttonBackground)
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { pressing in
            isPressed = pressing
        } perform: {}
    }

    private var buttonBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(backgroundGradient)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(strokeColor, lineWidth: 1)
            )
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: 0,
                y: shadowOffset
            )
    }
}

// Enhanced SleepSoundCategory
extension SleepSoundCategory {
    var icon: String {
        switch self {
        case .whiteNoise:
            return "waveform"
        case .nature:
            return "leaf.fill"
        case .lullaby:
            return "music.note"
        case .classical:
            return "pianoforte"
        case .rain:
            return "cloud.rain.fill"
        case .ocean:
            return "water.waves"
        }
    }

    var color: Color {
        switch self {
        case .whiteNoise:
            return .coolGray
        case .nature:
            return .mintGreen
        case .lullaby:
            return .coralPink
        case .classical:
            return .lilacPurple
        case .rain:
            return .oceanBlue
        case .ocean:
            return .babyPrimary
        }
    }
}


// Sample Sleep Sounds Data
let sampleSleepSounds: [SleepSound] = [
    // White Noise
    SleepSound(
        name: "Klasik Beyaz Gürültü",
        fileName: "white_noise_classic",
        duration: 3600,
        category: .whiteNoise,
        description: "Sakinleştirici beyaz gürültü sesi"
    ),

    SleepSound(
        name: "Pembe Gürültü",
        fileName: "pink_noise",
        duration: 3600,
        category: .whiteNoise,
        description: "Daha yumuşak ve dengeli gürültü"
    ),

    SleepSound(
        name: "Kahverengi Gürültü",
        fileName: "brown_noise",
        duration: 3600,
        category: .whiteNoise,
        description: "Derin ve sakinleştirici gürültü"
    ),

    // Nature Sounds
    SleepSound(
        name: "Orman Sesleri",
        fileName: "forest_sounds",
        duration: 2400,
        category: .nature,
        description: "Kuş sesleri ve yaprak hışırtıları"
    ),

    SleepSound(
        name: "Dere Sesi",
        fileName: "stream_sounds",
        duration: 3000,
        category: .nature,
        description: "Akan suyun sakinleştirici sesi"
    ),

    SleepSound(
        name: "Rüzgar Sesi",
        fileName: "wind_sounds",
        duration: 2700,
        category: .nature,
        description: "Hafif rüzgarın doğal sesi"
    ),

    // Lullabies
    SleepSound(
        name: "Türk Ninnisi",
        fileName: "turkish_lullaby",
        duration: 180,
        category: .lullaby,
        description: "Geleneksel Türk ninnileri"
    ),

    SleepSound(
        name: "Dünya Ninnileri",
        fileName: "world_lullabies",
        duration: 240,
        category: .lullaby,
        description: "Dünyanın farklı ülkelerinden ninniler"
    ),

    SleepSound(
        name: "Enstrümantal Ninni",
        fileName: "instrumental_lullaby",
        duration: 300,
        category: .lullaby,
        description: "Piyano ile çalınan ninni melodileri"
    ),

    // Classical Music
    SleepSound(
        name: "Mozart - Küçük Gece Müziği",
        fileName: "mozart_serenade",
        duration: 600,
        category: .classical,
        description: "Mozart'ın ünlü eseri"
    ),

    SleepSound(
        name: "Bach - Goldberg Variations",
        fileName: "bach_goldberg",
        duration: 900,
        category: .classical,
        description: "Bach'ın sakinleştirici eseri"
    ),

    SleepSound(
        name: "Debussy - Clair de Lune",
        fileName: "debussy_clair",
        duration: 420,
        category: .classical,
        description: "Romantik ve sakin piyano müziği"
    ),

    // Rain Sounds
    SleepSound(
        name: "Hafif Yağmur",
        fileName: "light_rain",
        duration: 3600,
        category: .rain,
        description: "Hafif yağmur damlaları"
    ),

    SleepSound(
        name: "Şiddetli Yağmur",
        fileName: "heavy_rain",
        duration: 3600,
        category: .rain,
        description: "Yoğun yağmur sesi"
    ),

    SleepSound(
        name: "Gök Gürültülü Yağmur",
        fileName: "thunderstorm",
        duration: 2700,
        category: .rain,
        description: "Uzak gök gürültüleri ile yağmur"
    ),

    // Ocean Sounds
    SleepSound(
        name: "Okyanus Dalgaları",
        fileName: "ocean_waves",
        duration: 3600,
        category: .ocean,
        description: "Ritmik dalga sesleri"
    ),

    SleepSound(
        name: "Sahil Sesleri",
        fileName: "beach_sounds",
        duration: 2400,
        category: .ocean,
        description: "Sahilde dalga ve martı sesleri"
    ),

    SleepSound(
        name: "Derin Deniz",
        fileName: "deep_ocean",
        duration: 3000,
        category: .ocean,
        description: "Derin denizin sakin sesleri"
    )
]

struct SleepSoundsView_Previews: PreviewProvider {
    static var previews: some View {
        SleepSoundsView()
    }
}
