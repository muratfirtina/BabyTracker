import SwiftUI

struct BabySetupView: View {
    @Binding var baby: Baby
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var selectedDate = Date()
    @State private var isPregnancy = true
    @State private var selectedGender: Gender = .unknown
    @State private var birthWeight: String = ""
    @State private var birthHeight: String = ""
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    @State private var animateContent = false
    @State private var currentStep = 0
    @State private var isLoading = false
    
    private let totalSteps = 4
    
    // Gender-based color scheme
    private var genderColorScheme: GenderColorScheme {
        GenderColorScheme.forGender(selectedGender)
    }
    
    var isFormValid: Bool {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        
        if !isPregnancy {
            guard !birthWeight.isEmpty,
                  !birthHeight.isEmpty,
                  Double(birthWeight) != nil,
                  Double(birthHeight) != nil else {
                return false
            }
        }
        
        return true
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Beautiful gradient background
                genderColorScheme.gradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Modern Header
                    ModernSetupHeader(
                        currentStep: currentStep,
                        totalSteps: totalSteps,
                        isPregnancy: isPregnancy,
                        colorScheme: genderColorScheme
                    )
                    .opacity(animateContent ? 1.0 : 0)
                    .offset(y: animateContent ? 0 : -30)
                    .animation(.easeOut(duration: 0.8).delay(0.1), value: animateContent)
                    
                    // Step Content
                    TabView(selection: $currentStep) {
                        // Step 1: Name
                        ModernNameInputStep(
                            name: $name,
                            colorScheme: genderColorScheme
                        )
                        .tag(0)
                        
                        // Step 2: Gender
                        ModernGenderSelectionStep(
                            selectedGender: $selectedGender,
                            colorScheme: genderColorScheme
                        )
                        .tag(1)
                        
                        // Step 3: Pregnancy/Birth Date
                        ModernDateSelectionStep(
                            isPregnancy: $isPregnancy,
                            selectedDate: $selectedDate,
                            colorScheme: genderColorScheme
                        )
                        .tag(2)
                        
                        // Step 4: Birth Measurements (if not pregnancy)
                        ModernMeasurementsStep(
                            isPregnancy: isPregnancy,
                            birthWeight: $birthWeight,
                            birthHeight: $birthHeight,
                            colorScheme: genderColorScheme
                        )
                        .tag(3)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .opacity(animateContent ? 1.0 : 0)
                    .animation(.easeOut(duration: 0.8).delay(0.3), value: animateContent)
                    
                    // Navigation Buttons
                    ModernNavigationButtons(
                        currentStep: $currentStep,
                        totalSteps: totalSteps,
                        name: name,
                        isPregnancy: isPregnancy,
                        isFormValid: isFormValid,
                        isLoading: isLoading,
                        colorScheme: genderColorScheme,
                        onNext: nextStep,
                        onPrevious: previousStep,
                        onSave: saveBaby,
                        onCancel: { dismiss() }
                    )
                    .opacity(animateContent ? 1.0 : 0)
                    .offset(y: animateContent ? 0 : 30)
                    .animation(.easeOut(duration: 0.8).delay(0.5), value: animateContent)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .alert("Hata", isPresented: $showingValidationAlert) {
                Button("Tamam", role: .cancel) { }
            } message: {
                Text(validationMessage)
            }
        }
        .onAppear {
            loadCurrentBaby()
            animateContent = true
        }
    }
    
    private func loadCurrentBaby() {
        name = baby.name
        selectedGender = baby.gender ?? .unknown
        
        if baby.isPregnancy {
            isPregnancy = true
            selectedDate = baby.dueDate
        } else if let birthDate = baby.birthDate {
            isPregnancy = false
            selectedDate = birthDate
            
            if let weight = baby.birthWeight {
                birthWeight = String(format: "%.2f", weight / 1000) // gram to kg
            }
            
            if let height = baby.birthHeight {
                birthHeight = String(format: "%.1f", height)
            }
        }
    }
    
    private func nextStep() {
        HapticFeedback.lightImpact()
        if currentStep < totalSteps - 1 {
            // Skip measurements step if pregnancy
            if currentStep == 2 && isPregnancy {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    currentStep = totalSteps - 1 // Go to last step
                }
            } else {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    currentStep += 1
                }
            }
        }
    }
    
    private func previousStep() {
        HapticFeedback.lightImpact()
        if currentStep > 0 {
            // Skip measurements step if pregnancy (going backwards)
            if currentStep == totalSteps - 1 && isPregnancy {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    currentStep = 2 // Go back to date step
                }
            } else {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    currentStep -= 1
                }
            }
        }
    }
    
    private func saveBaby() {
        guard validateForm() else { return }
        
        isLoading = true
        HapticFeedback.lightImpact()
        
        // Simulate a slight delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            updateBabyData()
            HapticFeedback.success()
            
            withAnimation(.easeOut(duration: 0.3)) {
                isLoading = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                dismiss()
            }
        }
    }
    
    private func validateForm() -> Bool {
        // Name validation
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            validationMessage = "Lütfen bebek ismini giriniz."
            showingValidationAlert = true
            return false
        }
        
        // Birth measurements validation (if not pregnancy)
        if !isPregnancy {
            guard let weightKg = Double(birthWeight), weightKg > 0, weightKg < 10 else {
                validationMessage = "Lütfen geçerli bir doğum kilosu giriniz (0-10 kg)."
                showingValidationAlert = true
                return false
            }
            
            guard let heightCm = Double(birthHeight), heightCm > 0, heightCm < 100 else {
                validationMessage = "Lütfen geçerli bir doğum boyu giriniz (0-100 cm)."
                showingValidationAlert = true
                return false
            }
        }
        
        return true
    }
    
    private func updateBabyData() {
        baby.name = name
        baby.gender = selectedGender
        
        if isPregnancy {
            baby.dueDate = selectedDate
            baby.birthDate = nil
            baby.birthWeight = nil
            baby.birthHeight = nil
        } else {
            baby.birthDate = selectedDate
            baby.dueDate = selectedDate.addingTimeInterval(40*7*24*60*60) // 40 weeks later
            
            if let weightKg = Double(birthWeight) {
                baby.birthWeight = weightKg * 1000 // kg to gram
            }
            
            if let heightCm = Double(birthHeight) {
                baby.birthHeight = heightCm
            }
        }
    }
}

// MARK: - Setup Header

struct ModernSetupHeader: View {
    let currentStep: Int
    let totalSteps: Int
    let isPregnancy: Bool
    let colorScheme: GenderColorScheme
    
    @State private var animateProgress = false
    
    private var progress: Double {
        let effectiveSteps = isPregnancy ? 3 : 4 // Skip measurements if pregnancy
        let effectiveCurrentStep = currentStep == 3 && isPregnancy ? 3 : currentStep + 1
        return Double(effectiveCurrentStep) / Double(effectiveSteps)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Bebek Bilgileri")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                    
                    let effectiveSteps = isPregnancy ? 3 : 4
                    let effectiveCurrentStep = currentStep == 3 && isPregnancy ? 3 : currentStep + 1
                    Text("Adım \(effectiveCurrentStep) / \(effectiveSteps)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                // Step indicator
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.white)
            }
            
            // Progress bar
            VStack(spacing: 8) {
                HStack {
                    Text("İlerleme")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                    
                    Text("%\(Int(progress * 100))")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .frame(
                                width: animateProgress ? geometry.size.width * progress : 0,
                                height: 8
                            )
                            .animation(.easeInOut(duration: 0.8), value: animateProgress)
                    }
                }
                .frame(height: 8)
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
        .padding(.top, 60) // Space for navigation
        .onChange(of: currentStep) { _ in
            animateProgress = true
        }
        .onAppear {
            animateProgress = true
        }
    }
}

// MARK: - Step 1: Name Input

struct ModernNameInputStep: View {
    @Binding var name: String
    let colorScheme: GenderColorScheme
    
    @FocusState private var isNameFocused: Bool
    @State private var animateCard = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Welcome message
                VStack(spacing: 16) {
                    Text("Hoş geldiniz!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoal)
                        .opacity(animateCard ? 1.0 : 0)
                        .offset(y: animateCard ? 0 : 20)
                    
                    Text("Bebeğinizin ismini giriniz")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .opacity(animateCard ? 1.0 : 0)
                        .offset(y: animateCard ? 0 : 15)
                }
                .animation(.easeOut(duration: 0.8).delay(0.2), value: animateCard)
                
                // Name input card
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [colorScheme.primary, colorScheme.primary.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: colorScheme.primary.opacity(0.4), radius: 8, x: 0, y: 4)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Bebek İsmi")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.charcoal)
                            
                            Text("Bebeğinizin adını yazın")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    TextField("Bebek ismini yazın", text: $name)
                        .font(.title3)
                        .fontWeight(.medium)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(colorScheme.primary.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            isNameFocused ? colorScheme.primary : colorScheme.primary.opacity(0.3),
                                            lineWidth: isNameFocused ? 2 : 1
                                        )
                                )
                        )
                        .focused($isNameFocused)
                        .textInputAutocapitalization(.words)
                        .textContentType(.name)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: colorScheme.primary.opacity(0.1), radius: 15, x: 0, y: 8)
                )
                .opacity(animateCard ? 1.0 : 0)
                .offset(y: animateCard ? 0 : 30)
                .animation(.easeOut(duration: 0.8).delay(0.4), value: animateCard)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 40)
        }
        .onAppear {
            animateCard = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                isNameFocused = true
            }
        }
    }
}

// MARK: - Step 2: Gender Selection

struct ModernGenderSelectionStep: View {
    @Binding var selectedGender: Gender
    let colorScheme: GenderColorScheme
    
    @State private var animateCard = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Title
                VStack(spacing: 16) {
                    Text("Cinsiyet Seçimi")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoal)
                        .opacity(animateCard ? 1.0 : 0)
                        .offset(y: animateCard ? 0 : 20)
                    
                    Text("Bebeğinizin cinsiyetini seçin")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .opacity(animateCard ? 1.0 : 0)
                        .offset(y: animateCard ? 0 : 15)
                }
                .animation(.easeOut(duration: 0.8).delay(0.2), value: animateCard)
                
                // Gender selection cards
                VStack(spacing: 16) {
                    ForEach(Gender.allCases, id: \.self) { gender in
                        ModernGenderCard(
                            gender: gender,
                            isSelected: selectedGender == gender,
                            colorScheme: colorScheme
                        ) {
                            HapticFeedback.selection()
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                selectedGender = gender
                            }
                        }
                    }
                }
                .opacity(animateCard ? 1.0 : 0)
                .offset(y: animateCard ? 0 : 30)
                .animation(.easeOut(duration: 0.8).delay(0.4), value: animateCard)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 40)
        }
        .onAppear {
            animateCard = true
        }
    }
}

struct ModernGenderCard: View {
    let gender: Gender
    let isSelected: Bool
    let colorScheme: GenderColorScheme
    let action: () -> Void
    
    @State private var isPressed = false
    
    private var genderColor: Color {
        switch gender {
        case .male:
            return .babyPrimary
        case .female:
            return .roseGold
        case .unknown:
            return .mintGreen
        }
    }
    
    private var genderIcon: String {
        switch gender {
        case .male:
            return "figure.child"
        case .female:
            return "figure.child"
        case .unknown:
            return "questionmark.circle.fill"
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: genderIcon)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [genderColor, genderColor.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: genderColor.opacity(0.4), radius: 8, x: 0, y: 4)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(gender.rawValue)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoal)
                    
                    Text(genderDescription(gender))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? .successGreen : .coolGray)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? genderColor : Color.clear,
                                lineWidth: 2
                            )
                    )
                    .shadow(
                        color: isSelected ? genderColor.opacity(0.2) : Color.black.opacity(0.05),
                        radius: isSelected ? 12 : 8,
                        x: 0,
                        y: isSelected ? 6 : 4
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
    
    private func genderDescription(_ gender: Gender) -> String {
        switch gender {
        case .male:
            return "Erkek bebek"
        case .female:
            return "Kız bebek"
        case .unknown:
            return "Henüz belirli değil"
        }
    }
}

// MARK: - Step 3: Date Selection

struct ModernDateSelectionStep: View {
    @Binding var isPregnancy: Bool
    @Binding var selectedDate: Date
    let colorScheme: GenderColorScheme
    
    @State private var animateCard = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Title
                VStack(spacing: 16) {
                    Text("Tarih Bilgileri")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoal)
                        .opacity(animateCard ? 1.0 : 0)
                        .offset(y: animateCard ? 0 : 20)
                    
                    Text("Hamilelik durumunu ve tarihi belirtin")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .opacity(animateCard ? 1.0 : 0)
                        .offset(y: animateCard ? 0 : 15)
                }
                .animation(.easeOut(duration: 0.8).delay(0.2), value: animateCard)
                
                VStack(spacing: 24) {
                    // Pregnancy toggle
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(spacing: 12) {
                            Image(systemName: "heart.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.pregnancyPrimary, Color.pregnancyPrimary.opacity(0.8)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(color: Color.pregnancyPrimary.opacity(0.4), radius: 8, x: 0, y: 4)
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Hamilelik Durumu")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.charcoal)
                                
                                Text("Şu anda hamile misiniz?")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $isPregnancy)
                                .scaleEffect(1.2)
                                .tint(Color.pregnancyPrimary)
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: Color.pregnancyPrimary.opacity(0.1), radius: 15, x: 0, y: 8)
                    )
                    
                    // Date picker
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(spacing: 12) {
                            Image(systemName: "calendar.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [colorScheme.primary, colorScheme.primary.opacity(0.8)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(color: colorScheme.primary.opacity(0.4), radius: 8, x: 0, y: 4)
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(isPregnancy ? "Doğum Tarihi" : "Doğum Tarihi")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.charcoal)
                                
                                Text(isPregnancy ? "Tahmini doğum tarihi" : "Gerçek doğum tarihi")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if isPregnancy {
                            DatePicker(
                                "",
                                selection: $selectedDate,
                                in: Date()...,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.compact)
                            .accentColor(colorScheme.primary)
                        } else {
                            DatePicker(
                                "",
                                selection: $selectedDate,
                                in: ...Date(),
                                displayedComponents: .date
                            )
                            .datePickerStyle(.compact)
                            .accentColor(colorScheme.primary)
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: colorScheme.primary.opacity(0.1), radius: 15, x: 0, y: 8)
                    )
                }
                .opacity(animateCard ? 1.0 : 0)
                .offset(y: animateCard ? 0 : 30)
                .animation(.easeOut(duration: 0.8).delay(0.4), value: animateCard)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 40)
        }
        .onAppear {
            animateCard = true
        }
    }
}

// MARK: - Step 4: Measurements

struct ModernMeasurementsStep: View {
    let isPregnancy: Bool
    @Binding var birthWeight: String
    @Binding var birthHeight: String
    let colorScheme: GenderColorScheme
    
    @State private var animateCard = false
    @FocusState private var focusedField: MeasurementField?
    
    enum MeasurementField {
        case weight, height
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                if isPregnancy {
                    // Pregnancy info
                    VStack(spacing: 20) {
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 60, weight: .medium))
                            .foregroundColor(.pregnancyPrimary)
                            .opacity(animateCard ? 1.0 : 0)
                            .scaleEffect(animateCard ? 1.0 : 0.8)
                        
                        VStack(spacing: 12) {
                            Text("Hamilelik Takibi")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.charcoal)
                            
                            Text("Bebeğiniz doğduktan sonra boy ve kilo bilgileri ekleyebilirsiniz.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .opacity(animateCard ? 1.0 : 0)
                        .offset(y: animateCard ? 0 : 20)
                    }
                    .animation(.easeOut(duration: 0.8).delay(0.2), value: animateCard)
                } else {
                    // Birth measurements
                    VStack(spacing: 32) {
                        VStack(spacing: 16) {
                            Text("Doğum Bilgileri")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.charcoal)
                                .opacity(animateCard ? 1.0 : 0)
                                .offset(y: animateCard ? 0 : 20)
                            
                            Text("Doğum kilosu ve boyunu girin")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .opacity(animateCard ? 1.0 : 0)
                                .offset(y: animateCard ? 0 : 15)
                        }
                        .animation(.easeOut(duration: 0.8).delay(0.2), value: animateCard)
                        
                        VStack(spacing: 20) {
                            // Weight input
                            ModernMeasurementField(
                                title: "Doğum Kilosu",
                                value: $birthWeight,
                                placeholder: "0.00",
                                unit: "kg",
                                icon: "scalemass",
                                color: colorScheme.primary,
                                isFocused: focusedField == .weight
                            ) {
                                focusedField = .weight
                            }
                            .focused($focusedField, equals: .weight)
                            
                            // Height input
                            ModernMeasurementField(
                                title: "Doğum Boyu",
                                value: $birthHeight,
                                placeholder: "0.0",
                                unit: "cm",
                                icon: "ruler",
                                color: colorScheme.accent,
                                isFocused: focusedField == .height
                            ) {
                                focusedField = .height
                            }
                            .focused($focusedField, equals: .height)
                        }
                        .opacity(animateCard ? 1.0 : 0)
                        .offset(y: animateCard ? 0 : 30)
                        .animation(.easeOut(duration: 0.8).delay(0.4), value: animateCard)
                        
                        // Info note
                        HStack(spacing: 12) {
                            Image(systemName: "info.circle.fill")
                                .font(.title3)
                                .foregroundColor(.infoBlue)
                            
                            Text("Bu bilgiler büyüme grafiğinin oluşturulması için kullanılacaktır.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.infoBlue.opacity(0.1))
                        )
                        .opacity(animateCard ? 1.0 : 0)
                        .animation(.easeOut(duration: 0.8).delay(0.6), value: animateCard)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 40)
        }
        .onAppear {
            animateCard = true
        }
    }
}

struct ModernMeasurementField: View {
    let title: String
    @Binding var value: String
    let placeholder: String
    let unit: String
    let icon: String
    let color: Color
    let isFocused: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [color, color.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: color.opacity(0.4), radius: 6, x: 0, y: 3)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoal)
                    
                    Text("Doğum sırasındaki \(title.lowercased())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack(spacing: 12) {
                TextField(placeholder, text: $value)
                    .keyboardType(.decimalPad)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.charcoal)
                    .multilineTextAlignment(.trailing)
                    .onTapGesture {
                        onTap()
                    }
                
                Text(unit)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(color)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isFocused ? color : color.opacity(0.3),
                                lineWidth: isFocused ? 2 : 1
                            )
                    )
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: color.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

// MARK: - Navigation Buttons

struct ModernNavigationButtons: View {
    @Binding var currentStep: Int
    let totalSteps: Int
    let name: String
    let isPregnancy: Bool
    let isFormValid: Bool
    let isLoading: Bool
    let colorScheme: GenderColorScheme
    let onNext: () -> Void
    let onPrevious: () -> Void
    let onSave: () -> Void
    let onCancel: () -> Void
    
    private var isLastStep: Bool {
        if isPregnancy {
            return currentStep == 2 // Last step for pregnancy is date selection
        } else {
            return currentStep == totalSteps - 1 // Last step for birth is measurements
        }
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case 0: // Name step
            return !name.trimmingCharacters(in: .whitespaces).isEmpty
        case 1: // Gender step
            return true // Gender has default value
        case 2: // Date step
            return true // Date has default value
        case 3: // Measurements step
            return isPregnancy || isFormValid
        default:
            return false
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Previous/Cancel button
                Button(action: currentStep > 0 ? onPrevious : onCancel) {
                    HStack(spacing: 8) {
                        Image(systemName: currentStep > 0 ? "chevron.left" : "xmark")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text(currentStep > 0 ? "Geri" : "İptal")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(colorScheme.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(colorScheme.primary, lineWidth: 2)
                            )
                    )
                }
                
                // Next/Save button
                Button(action: isLastStep ? onSave : onNext) {
                    HStack(spacing: 8) {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text(isLastStep ? "Kaydet" : "Devam")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            if !isLastStep {
                                Image(systemName: "chevron.right")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                canProceed && !isLoading ?
                                LinearGradient(
                                    colors: [colorScheme.primary, colorScheme.primary.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ) :
                                LinearGradient(
                                    colors: [Color.coolGray, Color.coolGray.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(
                                color: canProceed ? colorScheme.primary.opacity(0.4) : Color.clear,
                                radius: canProceed ? 12 : 0,
                                x: 0,
                                y: canProceed ? 6 : 0
                            )
                    )
                }
                .disabled(!canProceed || isLoading)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }
}

#Preview {
    BabySetupView(baby: .constant(Baby(name: "")))
}
