import SwiftUI

struct ActivitiesView: View {
    @EnvironmentObject var babyDataManager: BabyDataManager
    @State private var selectedCategory: ActivityCategory = .sensory
    @State private var showingActivityDetail = false
    @State private var selectedActivity: Activity?
    @State private var animateContent = false
    
    private var baby: Baby {
        babyDataManager.currentBaby
    }
    
    private var filteredActivities: [Activity] {
        sampleActivities.filter { activity in
            activity.category == selectedCategory &&
            activity.ageRange.contains(baby.ageInMonths)
        }
    }
    
    // Gender-based color scheme
    private var genderColorScheme: GenderColorScheme {
        GenderColorScheme.forGender(baby.gender)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Beautiful gradient background
                genderColorScheme.gradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if baby.isPregnancy {
                        ModernPregnancyActivityView()
                            .opacity(animateContent ? 1.0 : 0)
                            .offset(y: animateContent ? 0 : 30)
                            .animation(.easeOut(duration: 0.8).delay(0.2), value: animateContent)
                    } else {
                        VStack(spacing: 0) {
                            // Modern Header
                            ModernActivitiesHeader(
                                baby: baby,
                                filteredActivities: filteredActivities,
                                colorScheme: genderColorScheme
                            )
                            .opacity(animateContent ? 1.0 : 0)
                            .offset(y: animateContent ? 0 : -30)
                            .animation(.easeOut(duration: 0.8).delay(0.1), value: animateContent)
                            
                            // Modern Category Selector
                            ModernCategorySelector(
                                selectedCategory: $selectedCategory,
                                colorScheme: genderColorScheme
                            )
                            .opacity(animateContent ? 1.0 : 0)
                            .offset(y: animateContent ? 0 : -20)
                            .animation(.easeOut(duration: 0.8).delay(0.2), value: animateContent)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                            
                            // Modern Activities Grid
                            ModernActivitiesGrid(
                                activities: filteredActivities,
                                colorScheme: genderColorScheme
                            ) { activity in
                                selectedActivity = activity
                                showingActivityDetail = true
                            }
                            .opacity(animateContent ? 1.0 : 0)
                            .animation(.easeOut(duration: 0.8).delay(0.3), value: animateContent)
                        }
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingActivityDetail) {
                if let activity = selectedActivity {
                    ModernActivityDetailView(activity: activity)
                }
            }
        }
        .onAppear {
            animateContent = true
        }
    }
}

// Modern Activities Header
struct ModernActivitiesHeader: View {
    let baby: Baby
    let filteredActivities: [Activity]
    let colorScheme: GenderColorScheme
    
    @State private var animateIcon = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("🎮 Aktiviteler")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                    
                    Text("Yaşa uygun gelişim aktiviteleri")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                // Activity icon with animation
                Image(systemName: "gamecontroller.fill")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.white)
                    .scaleEffect(animateIcon ? 1.0 : 0.8)
                    .rotationEffect(.degrees(animateIcon ? 0 : -15))
                    .animation(.spring(response: 1.0, dampingFraction: 0.6).delay(0.5), value: animateIcon)
            }
            
            // Age and Activity Count Info
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("Yaş: \(baby.ageInMonths) ay")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Image(systemName: "list.bullet")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("\(filteredActivities.count) aktivite")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.9))
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [colorScheme.primary, colorScheme.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)
        )
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .onAppear {
            animateIcon = true
        }
    }
}

// Modern Category Selector
struct ModernCategorySelector: View {
    @Binding var selectedCategory: ActivityCategory
    let colorScheme: GenderColorScheme
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ActivityCategory.allCases, id: \.self) { category in
                    ModernCategoryButton(
                        category: category,
                        isSelected: selectedCategory == category,
                        color: colorScheme.primary
                    ) {
                        HapticFeedback.selection()
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.9))
                .shadow(color: colorScheme.primary.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

struct ModernCategoryButton: View {
    let category: ActivityCategory
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(category.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(minWidth: 80)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        isSelected ?
                        LinearGradient(
                            colors: [color, color.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color.clear, Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(
                        color: isSelected ? color.opacity(0.3) : Color.clear,
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

// Modern Activities Grid
struct ModernActivitiesGrid: View {
    let activities: [Activity]
    let colorScheme: GenderColorScheme
    let onActivityTap: (Activity) -> Void
    
    @State private var animateCards = false
    
    var body: some View {
        ScrollView {
            if activities.isEmpty {
                ModernEmptyActivitiesView(colorScheme: colorScheme)
                    .padding(.top, 60)
            } else {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 1),
                    spacing: 16
                ) {
                    ForEach(Array(activities.enumerated()), id: \.offset) { index, activity in
                        ModernActivityCard(
                            activity: activity,
                            colorScheme: colorScheme
                        ) {
                            onActivityTap(activity)
                        }
                        .opacity(animateCards ? 1.0 : 0)
                        .offset(y: animateCards ? 0 : 30)
                        .animation(
                            .easeOut(duration: 0.6).delay(Double(index) * 0.1),
                            value: animateCards
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            animateCards = true
        }
    }
}

struct ModernActivityCard: View {
    let activity: Activity
    let colorScheme: GenderColorScheme
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticFeedback.lightImpact()
            action()
        }) {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    HStack(spacing: 12) {
                        Image(systemName: activity.category.icon)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [activity.category.color, activity.category.color.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: activity.category.color.opacity(0.4), radius: 8, x: 0, y: 4)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(activity.title)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.charcoal)
                                .multilineTextAlignment(.leading)
                            
                            Text(activity.category.rawValue)
                                .font(.caption)
                                .foregroundColor(activity.category.color)
                                .fontWeight(.medium)
                        }
                    }
                    
                    Spacer()
                    
                    ModernDifficultyBadge(difficulty: activity.difficulty)
                }
                
                // Description
                Text(activity.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                // Info Row
                HStack(spacing: 16) {
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(colorScheme.primary)
                        
                        Text("\(activity.duration) dk")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(colorScheme.primary)
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(activity.ageRange.lowerBound)-\(activity.ageRange.upperBound) ay")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [activity.category.color.opacity(0.3), activity.category.color.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: activity.category.color.opacity(0.1),
                        radius: isPressed ? 8 : 12,
                        x: 0,
                        y: isPressed ? 4 : 6
                    )
            )
        }
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { pressing in
            isPressed = pressing
        } perform: {}
    }
}

struct ModernDifficultyBadge: View {
    let difficulty: ActivityDifficulty
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<difficulty.level, id: \.self) { _ in
                Circle()
                    .fill(difficulty.color)
                    .frame(width: 6, height: 6)
            }
            
            ForEach(0..<(3 - difficulty.level), id: \.self) { _ in
                Circle()
                    .fill(difficulty.color.opacity(0.3))
                    .frame(width: 6, height: 6)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(difficulty.color.opacity(0.15))
        )
    }
}

// Modern Empty Activities View
struct ModernEmptyActivitiesView: View {
    let colorScheme: GenderColorScheme
    
    @State private var animateIcon = false
    
    var body: some View {
        VStack(spacing: 32) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [colorScheme.primary.opacity(0.2), colorScheme.primary.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(animateIcon ? 1.0 : 0.8)
                    .opacity(animateIcon ? 1.0 : 0.6)
                
                Image(systemName: "gamecontroller")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundColor(colorScheme.primary)
                    .scaleEffect(animateIcon ? 1.0 : 0.5)
                    .rotationEffect(.degrees(animateIcon ? 0 : -10))
            }
            .animation(.spring(response: 1.0, dampingFraction: 0.6).delay(0.2), value: animateIcon)
            
            VStack(spacing: 16) {
                Text("Bu Kategoride Aktivite Yok")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.charcoal)
                    .multilineTextAlignment(.center)
                
                Text("Bu yaş grubu için seçili kategoride aktivite bulunmuyor. Başka bir kategori seçmeyi deneyin.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            .opacity(animateIcon ? 1.0 : 0)
            .offset(y: animateIcon ? 0 : 20)
            .animation(.easeOut(duration: 0.8).delay(0.5), value: animateIcon)
        }
        .padding(.horizontal, 40)
        .onAppear {
            animateIcon = true
        }
    }
}

// Modern Pregnancy Activity View
struct ModernPregnancyActivityView: View {
    @State private var animateContent = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Hero section
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.pregnancyPrimary.opacity(0.2), Color.pregnancyPrimary.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .scaleEffect(animateContent ? 1.0 : 0.8)
                            .opacity(animateContent ? 1.0 : 0)
                        
                        Image(systemName: "figure.mind.and.body")
                            .font(.system(size: 60, weight: .medium))
                            .foregroundColor(.pregnancyPrimary)
                            .scaleEffect(animateContent ? 1.0 : 0.5)
                    }
                    .animation(.spring(response: 1.0, dampingFraction: 0.6).delay(0.2), value: animateContent)
                    
                    VStack(spacing: 12) {
                        Text("Hamilelik Döneminde Aktiviteler")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.charcoal)
                            .multilineTextAlignment(.center)
                            .opacity(animateContent ? 1.0 : 0)
                            .offset(y: animateContent ? 0 : 20)
                        
                        Text("Bebeğiniz doğduktan sonra yaşına uygun aktiviteler burada görünecek. Şu anda anneler için öneriler:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(4)
                            .padding(.horizontal, 20)
                            .opacity(animateContent ? 1.0 : 0)
                            .offset(y: animateContent ? 0 : 15)
                    }
                    .animation(.easeOut(duration: 0.8).delay(0.4), value: animateContent)
                }
                
                // Pregnancy activities cards
                VStack(spacing: 16) {
                    ForEach(Array(pregnancyActivities.enumerated()), id: \.offset) { index, activity in
                        ModernPregnancyActivityCard(
                            title: activity.title,
                            description: activity.description,
                            icon: activity.icon,
                            color: activity.color
                        )
                        .opacity(animateContent ? 1.0 : 0)
                        .offset(y: animateContent ? 0 : 30)
                        .animation(
                            .easeOut(duration: 0.8).delay(0.6 + Double(index) * 0.2),
                            value: animateContent
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .onAppear {
            animateContent = true
        }
    }
    
    private var pregnancyActivities: [(title: String, description: String, icon: String, color: Color)] {
        [
            (
                title: "Prenatal Yoga",
                description: "Hamilelik için özel olarak tasarlanmış yoga hareketleri",
                icon: "figure.yoga",
                color: .pregnancyPrimary
            ),
            (
                title: "Nefes Egzersizleri",
                description: "Doğuma hazırlık ve rahatlatma teknikleri",
                icon: "lungs",
                color: .oceanBlue
            ),
            (
                title: "Hafif Yürüyüş",
                description: "Günlük 30 dakika hafif tempolu yürüyüş",
                icon: "figure.walk",
                color: .mintGreen
            ),
            (
                title: "Rahatlatcı Müzik",
                description: "Bebek ve anne için sakinleştirici müzik dinleme",
                icon: "music.note",
                color: .coralPink
            )
        ]
    }
}

struct ModernPregnancyActivityCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: icon)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 4)
                )
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.charcoal)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [color.opacity(0.3), color.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: color.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

// Modern Activity Detail View
struct ModernActivityDetailView: View {
    let activity: Activity
    @Environment(\.dismiss) private var dismiss
    
    @State private var animateContent = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [activity.category.color.opacity(0.1), Color.white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Hero Header
                        ModernActivityDetailHeader(activity: activity)
                            .opacity(animateContent ? 1.0 : 0)
                            .offset(y: animateContent ? 0 : -30)
                            .animation(.easeOut(duration: 0.8).delay(0.1), value: animateContent)
                        
                        // Content Sections
                        VStack(spacing: 20) {
                            ModernDetailSection(
                                title: "Açıklama",
                                icon: "doc.text",
                                content: activity.description,
                                color: activity.category.color
                            )
                            
                            ModernDetailListSection(
                                title: "Faydaları",
                                icon: "heart.fill",
                                items: activity.benefits,
                                color: .successGreen
                            )
                            
                            if !activity.materials.isEmpty {
                                ModernDetailListSection(
                                    title: "Gerekli Malzemeler",
                                    icon: "cube.box",
                                    items: activity.materials,
                                    color: .oceanBlue
                                )
                            }
                            
                            ModernDetailStepsSection(
                                title: "Uygulama Adımları",
                                icon: "list.number",
                                steps: activity.steps,
                                color: activity.category.color
                            )
                        }
                        .opacity(animateContent ? 1.0 : 0)
                        .animation(.easeOut(duration: 0.8).delay(0.3), value: animateContent)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .overlay(
                // Custom Close Button
                VStack {
                    HStack {
                        Spacer()
                        
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.charcoal)
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(Color.white)
                                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Spacer()
                }
            )
        }
        .onAppear {
            animateContent = true
        }
    }
}

// Activity Detail Components
struct ModernActivityDetailHeader: View {
    let activity: Activity
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    Text(activity.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                    
                    Text(activity.category.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                Image(systemName: activity.category.icon)
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            }
            
            // Quick Info
            HStack(spacing: 24) {
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("\(activity.duration) dakika")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("\(activity.ageRange.lowerBound)-\(activity.ageRange.upperBound) ay")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                ModernDifficultyBadge(difficulty: activity.difficulty)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [activity.category.color, activity.category.color.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)
        )
    }
}

struct ModernDetailSection: View {
    let title: String
    let icon: String
    let content: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.charcoal)
            }
            
            Text(content)
                .font(.subheadline)
                .foregroundColor(.charcoal)
                .lineLimit(nil)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: color.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

struct ModernDetailListSection: View {
    let title: String
    let icon: String
    let items: [String]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.charcoal)
            }
            
            VStack(spacing: 12) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(color)
                            .frame(width: 6, height: 6)
                            .padding(.top, 8)
                        
                        Text(item)
                            .font(.subheadline)
                            .foregroundColor(.charcoal)
                            .lineLimit(nil)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: color.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

struct ModernDetailStepsSection: View {
    let title: String
    let icon: String
    let steps: [String]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.charcoal)
            }
            
            VStack(spacing: 16) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 16) {
                        Text("\(index + 1)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                            .background(
                                Circle()
                                    .fill(color)
                            )
                        
                        Text(step)
                            .font(.subheadline)
                            .foregroundColor(.charcoal)
                            .lineLimit(nil)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: color.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

// Extensions
extension ActivityCategory {
    var icon: String {
        switch self {
        case .sensory:
            return "eye.fill"
        case .motor:
            return "figure.walk"
        case .cognitive:
            return "brain.head.profile"
        case .language:
            return "textformat.abc"
        case .social:
            return "person.2.fill"
        case .creative:
            return "paintbrush.fill"
        case .music:
            return "music.note"
        case .reading:
            return "book.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .sensory:
            return .coralPink
        case .motor:
            return .oceanBlue
        case .cognitive:
            return .lilacPurple
        case .language:
            return .mintGreen
        case .social:
            return .roseGold
        case .creative:
            return .warningOrange
        case .music:
            return .babyPrimary
        case .reading:
            return .successGreen
        }
    }
    
    var displayName: String {
        switch self {
        case .sensory:
            return "Duyusal"
        case .motor:
            return "Motor"
        case .cognitive:
            return "Bilişsel"
        case .language:
            return "Dil"
        case .social:
            return "Sosyal"
        case .creative:
            return "Yaratıcı"
        case .music:
            return "Müzik"
        case .reading:
            return "Okuma"
        }
    }
}

extension ActivityDifficulty {
    var color: Color {
        switch self {
        case .easy:
            return .green
        case .medium:
            return .orange
        case .hard:
            return .red
        }
    }
    
    var level: Int {
        switch self {
        case .easy:
            return 1
        case .medium:
            return 2
        case .hard:
            return 3
        }
    }
}

// Sample Activities Data (same as before)
let sampleActivities: [Activity] = [
    // 0-3 months
    Activity(
        title: "Tummy Time",
        description: "Bebeğin yüzüstü pozisyonda geçirdiği süre, boyun ve omuz kaslarını güçlendirir",
        ageRange: 0...3,
        duration: 5,
        category: .motor,
        benefits: ["Boyun kaslarını güçlendirir", "Motor gelişimi destekler", "Düz baş sendromunu önler"],
        materials: ["Yumuşak battaniye", "Renkli oyuncaklar"],
        steps: [
            "Bebeği yumuşak bir yüzeye yüzüstü yatırın",
            "Önüne renkli oyuncaklar koyun",
            "Bebeğin başını kaldırmasını teşvik edin",
            "5 dakika süreyle uygulayın"
        ],
        difficulty: .easy
    ),
    
    Activity(
        title: "Göz Kontakı Oyunu",
        description: "Bebekle göz göze gelip konuşarak sosyal bağ kurma",
        ageRange: 0...6,
        duration: 10,
        category: .social,
        benefits: ["Sosyal bağ kurar", "Dil gelişimini destekler", "Güven oluşturur"],
        materials: [],
        steps: [
            "Bebekle göz göze gelin",
            "Yavaşça konuşun ve gülümseyin",
            "Bebeğin tepkilerini gözlemleyin",
            "Sesi taklit edin"
        ],
        difficulty: .easy
    ),
    
    // 4-6 months
    Activity(
        title: "Renkli Objeler Tanıma",
        description: "Farklı renk ve şekillerdeki oyuncaklarla görsel algıyı geliştirme",
        ageRange: 4...8,
        duration: 15,
        category: .sensory,
        benefits: ["Görsel algıyı geliştirir", "Renk ayırt etmeyi öğretir", "Dikkat süresini artırır"],
        materials: ["Farklı renklerde oyuncaklar", "Ayna", "Renkli kartlar"],
        steps: [
            "Bebeğin önüne farklı renkli objeler yerleştirin",
            "Her objeyi gösterin ve ismini söyleyin",
            "Bebeğin objeleri tutmasına izin verin",
            "Renkleri tekrar ederek öğretin"
        ],
        difficulty: .easy
    ),
    
    Activity(
        title: "Müzikal Oyuncaklar",
        description: "Ses çıkaran oyuncaklarla işitsel gelişimi destekleme",
        ageRange: 3...9,
        duration: 20,
        category: .music,
        benefits: ["İşitsel gelişimi destekler", "Ritim duygusunu geliştirir", "El koordinasyonunu artırır"],
        materials: ["Çıngırak", "Müzik kutusu", "Ses çıkaran oyuncaklar"],
        steps: [
            "Bebeğin yanında farklı sesler çıkarın",
            "Oyuncakları bebeğin tutmasını sağlayın",
            "Müzik eşliğinde sallanın",
            "Bebeğin tepkilerini gözlemleyin"
        ],
        difficulty: .easy
    ),
    
    // 7-12 months
    Activity(
        title: "Neden-Sonuç Oyunları",
        description: "Düğmelere basınca ses çıkan oyuncaklarla neden-sonuç ilişkisini öğretme",
        ageRange: 7...15,
        duration: 25,
        category: .cognitive,
        benefits: ["Neden-sonuç ilişkisini öğretir", "Problem çözme becerisini geliştirir", "İnce motor becerileri artırır"],
        materials: ["Düğmeli oyuncaklar", "Açılıp kapanan kutular", "Şekil yerleştirme oyuncakları"],
        steps: [
            "Bebeğe düğmeli oyuncak verin",
            "Düğmeye bastığınızda çıkan sesi gösterin",
            "Bebeğin kendisi denemesini bekleyin",
            "Başarılarını alkışlayın"
        ],
        difficulty: .medium
    ),
    
    Activity(
        title: "Emekleme Egzersizleri",
        description: "Emekleme hareketlerini destekleyici aktiviteler",
        ageRange: 8...12,
        duration: 30,
        category: .motor,
        benefits: ["Kas gücünü artırır", "Koordinasyonu geliştirir", "Dengeyi sağlar"],
        materials: ["Yumuşak mat", "Oyuncaklar", "Engel parkuru malzemeleri"],
        steps: [
            "Güvenli bir alan hazırlayın",
            "Bebeğin ilgisini çekecek oyuncakları uzağa koyun",
            "Emeklemeyi teşvik edin",
            "Başarılarını ödüllendirin"
        ],
        difficulty: .medium
    ),
    
    // 13-24 months
    Activity(
        title: "İlk Kelimeler Oyunu",
        description: "Basit kelimeler ve sesler ile dil gelişimini destekleme",
        ageRange: 12...24,
        duration: 20,
        category: .language,
        benefits: ["Kelime dağarcığını artırır", "Telaffuzu geliştirir", "İletişim becerisini artırır"],
        materials: ["Resimli kartlar", "Basit hikaye kitapları", "Oyuncak telefon"],
        steps: [
            "Basit kelimeler tekrar edin",
            "Resimli kartları gösterin",
            "Bebeğin taklit etmesini bekleyin",
            "Doğru telaffuzları ödüllendirin"
        ],
        difficulty: .medium
    ),
    
    Activity(
        title: "Şekil ve Renk Eşleştirme",
        description: "Temel şekil ve renkleri tanıma ve eşleştirme oyunu",
        ageRange: 15...30,
        duration: 25,
        category: .cognitive,
        benefits: ["Şekil tanımayı öğretir", "Renk ayırt etmeyi geliştirir", "Problem çözme becerisini artırır"],
        materials: ["Şekil yerleştirme oyuncağı", "Renkli bloklar", "Eşleştirme kartları"],
        steps: [
            "Temel şekilleri tanıtın",
            "Renkleri gösterin ve isimlerini söyleyin",
            "Eşleştirme oyunu oynayın",
            "Başarıları kutlayın"
        ],
        difficulty: .medium
    ),
    
    // 25-36 months
    Activity(
        title: "Basit Sanat Etkinlikleri",
        description: "Parmak boyası ve çizim ile yaratıcılığı geliştirme",
        ageRange: 24...36,
        duration: 30,
        category: .creative,
        benefits: ["Yaratıcılığı geliştirir", "İnce motor becerileri artırır", "Sanat anlayışını oluşturur"],
        materials: ["Parmak boyası", "Büyük kağıtlar", "Fırçalar", "Önlük"],
        steps: [
            "Güvenli çalışma alanı hazırlayın",
            "Boyaları tanıtın",
            "Serbest çizim yapmasına izin verin",
            "Eserini sergileyin"
        ],
        difficulty: .medium
    ),
    
    Activity(
        title: "Hikaye Anlatma",
        description: "Resimli kitaplarla hikaye anlatma ve dinleme",
        ageRange: 18...48,
        duration: 15,
        category: .reading,
        benefits: ["Dil gelişimini destekler", "Hayal gücünü geliştirir", "Dinleme becerisini artırır"],
        materials: ["Resimli hikaye kitapları", "Kuklalar", "Ses efektleri"],
        steps: [
            "Rahat bir okuma köşesi oluşturun",
            "Kitabı birlikte inceleyin",
            "Hikayeyi canlandırarak anlatın",
            "Çocuğun sorularını yanıtlayın"
        ],
        difficulty: .easy
    ),
    
    // 37-48 months
    Activity(
        title: "Rol Yapma Oyunları",
        description: "Farklı karakterler ve meslekler canlandırma",
        ageRange: 36...60,
        duration: 45,
        category: .social,
        benefits: ["Sosyal becerileri geliştirir", "Empati kurmayı öğretir", "Yaratıcılığı artırır"],
        materials: ["Kostümler", "Oyuncak ev eşyaları", "Meslek oyuncakları"],
        steps: [
            "Senaryoyu birlikte belirleyin",
            "Rolleri paylaşın",
            "Oyunu canlandırın",
            "Deneyimleri tartışın"
        ],
        difficulty: .hard
    ),
    
    // 49-60 months
    Activity(
        title: "Sayı ve Matematik Oyunları",
        description: "Temel matematik kavramlarını oyunla öğrenme",
        ageRange: 48...60,
        duration: 30,
        category: .cognitive,
        benefits: ["Sayı kavramını öğretir", "Mantıksal düşünmeyi geliştirir", "Problem çözme becerisini artırır"],
        materials: ["Sayı kartları", "Renkli toplar", "Hesap makinesi oyuncağı"],
        steps: [
            "1'den 10'a kadar sayın",
            "Objelerle sayma yapın",
            "Basit toplama işlemleri gösterin",
            "Oyunla matematik yapın"
        ],
        difficulty: .hard
    )
]

#Preview {
    ActivitiesView()
}
