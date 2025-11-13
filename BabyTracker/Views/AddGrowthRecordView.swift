import SwiftUI

struct ModernAddGrowthRecordView: View {
    let baby: Baby
    @EnvironmentObject var growthDataManager: GrowthDataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDate = Date()
    @State private var weight = ""
    @State private var height = ""
    @State private var notes = ""
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    @State private var animateContent = false
    @State private var isLoading = false
    
    // Gender-based color scheme
    private var genderColorScheme: GenderColorScheme {
        GenderColorScheme.forGender(baby.gender)
    }
    
    private var ageInMonthsForDate: Int {
        guard let birthDate = baby.birthDate else { return 0 }
        let calendar = Calendar.current
        let months = calendar.dateComponents([.month], from: birthDate, to: selectedDate).month ?? 0
        return max(0, months)
    }
    
    private var isFormValid: Bool {
        guard !weight.isEmpty,
              !height.isEmpty,
              Double(weight) != nil,
              Double(height) != nil,
              let birthDate = baby.birthDate,
              selectedDate >= birthDate else {
            return false
        }
        return true
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Beautiful gradient background
                genderColorScheme.gradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Modern Header
                        ModernAddRecordHeader(
                            babyName: baby.name,
                            colorScheme: genderColorScheme
                        )
                        .opacity(animateContent ? 1.0 : 0)
                        .offset(y: animateContent ? 0 : -30)
                        .animation(.easeOut(duration: 0.8).delay(0.1), value: animateContent)
                        
                        // Form Cards
                        VStack(spacing: 20) {
                            // Date Selection Card
                            ModernDateSelectionCard(
                                selectedDate: $selectedDate,
                                baby: baby,
                                ageInMonths: ageInMonthsForDate,
                                colorScheme: genderColorScheme
                            )
                            .opacity(animateContent ? 1.0 : 0)
                            .offset(y: animateContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.8).delay(0.2), value: animateContent)
                            
                            // Measurements Card
                            ModernMeasurementsCard(
                                weight: $weight,
                                height: $height,
                                colorScheme: genderColorScheme
                            )
                            .opacity(animateContent ? 1.0 : 0)
                            .offset(y: animateContent ? 0 : 30)
                            .animation(.easeOut(duration: 0.8).delay(0.3), value: animateContent)
                            
                            // Notes Card
                            ModernNotesCard(
                                notes: $notes,
                                colorScheme: genderColorScheme
                            )
                            .opacity(animateContent ? 1.0 : 0)
                            .offset(y: animateContent ? 0 : 40)
                            .animation(.easeOut(duration: 0.8).delay(0.4), value: animateContent)
                            
                            // Percentile Preview Card
                            if isFormValid {
                                ModernPercentilePreviewCard(
                                    baby: baby,
                                    ageInMonths: ageInMonthsForDate,
                                    weightKg: Double(weight) ?? 0,
                                    heightCm: Double(height) ?? 0,
                                    colorScheme: genderColorScheme
                                )
                                .opacity(animateContent ? 1.0 : 0)
                                .offset(y: animateContent ? 0 : 50)
                                .animation(.easeOut(duration: 0.8).delay(0.5), value: animateContent)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Save Button
                        ModernSaveButton(
                            isFormValid: isFormValid,
                            isLoading: isLoading,
                            colorScheme: genderColorScheme,
                            onSave: saveRecord
                        )
                        .opacity(animateContent ? 1.0 : 0)
                        .offset(y: animateContent ? 0 : 60)
                        .animation(.easeOut(duration: 0.8).delay(0.6), value: animateContent)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .overlay(
                // Custom Navigation Bar
                VStack {
                    ModernCustomNavigationBar(
                        title: "Ölçüm Kaydet",
                        onDismiss: {
                            HapticFeedback.lightImpact()
                            dismiss()
                        }
                    )
                    
                    Spacer()
                }
            )
            .alert("Hata", isPresented: $showingValidationAlert) {
                Button("Tamam", role: .cancel) { }
            } message: {
                Text(validationMessage)
            }
        }
        .onAppear {
            animateContent = true
        }
    }
    
    private func saveRecord() {
        guard let weightKg = Double(weight),
              let heightCm = Double(height) else {
            validationMessage = "Lütfen geçerli sayısal değerler giriniz."
            showingValidationAlert = true
            return
        }
        
        guard weightKg > 0 && weightKg < 50 else {
            validationMessage = "Kilo 0-50 kg arasında olmalıdır."
            showingValidationAlert = true
            return
        }
        
        guard heightCm > 0 && heightCm < 200 else {
            validationMessage = "Boy 0-200 cm arasında olmalıdır."
            showingValidationAlert = true
            return
        }
        
        isLoading = true
        HapticFeedback.lightImpact()
        
        // Simulate a slight delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let record = GrowthRecord(
                date: selectedDate,
                weightKg: weightKg,
                heightCm: heightCm,
                ageInMonths: ageInMonthsForDate,
                notes: notes.isEmpty ? nil : notes
            )
            
            growthDataManager.addGrowthRecord(record)
            HapticFeedback.success()
            
            withAnimation(.easeOut(duration: 0.3)) {
                isLoading = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                dismiss()
            }
        }
    }
}

// Modern Add Record Header
struct ModernAddRecordHeader: View {
    let babyName: String
    let colorScheme: GenderColorScheme
    
    @State private var animateIcon = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("📏 Yeni Ölçüm")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                    
                    Text("\(babyName) için büyüme kaydı")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                // Icon with animation
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.white)
                    .scaleEffect(animateIcon ? 1.0 : 0.8)
                    .rotationEffect(.degrees(animateIcon ? 0 : -15))
                    .animation(.spring(response: 1.0, dampingFraction: 0.6).delay(0.5), value: animateIcon)
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
        .padding(.top, 60) // Space for custom nav bar
        .onAppear {
            animateIcon = true
        }
    }
}

// Modern Custom Navigation Bar
struct ModernCustomNavigationBar: View {
    let title: String
    let onDismiss: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.charcoal)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    )
            }
            
            Spacer()
            
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.charcoal)
            
            Spacer()
            
            // Invisible spacer for balance
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .background(.ultraThinMaterial)
    }
}

// Modern Date Selection Card
struct ModernDateSelectionCard: View {
    @Binding var selectedDate: Date
    let baby: Baby
    let ageInMonths: Int
    let colorScheme: GenderColorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: "calendar")
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
                    Text("Ölçüm Tarihi")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoal)
                    
                    Text("Ölçümün yapıldığı tarihi seçin")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Date Picker
            VStack(spacing: 16) {
                DatePicker(
                    "Tarih",
                    selection: $selectedDate,
                    in: (baby.birthDate ?? Date())...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .accentColor(colorScheme.primary)
                
                // Age Info
                if ageInMonths > 0 {
                    HStack {
                        Text("Seçilen tarihteki yaş:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(ageInMonths) aylık")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(colorScheme.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(colorScheme.primary.opacity(0.1))
                            )
                    }
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [colorScheme.primary.opacity(0.3), colorScheme.primary.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: colorScheme.primary.opacity(0.1), radius: 15, x: 0, y: 8)
        )
    }
}

// Modern Measurements Card
struct ModernMeasurementsCard: View {
    @Binding var weight: String
    @Binding var height: String
    let colorScheme: GenderColorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: "scalemass")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [colorScheme.accent, colorScheme.accent.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: colorScheme.accent.opacity(0.4), radius: 8, x: 0, y: 4)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ölçümler")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoal)
                    
                    Text("Boy ve kilo değerlerini girin")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Input Fields
            VStack(spacing: 16) {
                // Weight Input
                ModernMeasurementInputField(
                    title: "Kilo",
                    value: $weight,
                    placeholder: "0.00",
                    unit: "kg",
                    icon: "scalemass",
                    color: colorScheme.accent
                )
                
                // Height Input
                ModernMeasurementInputField(
                    title: "Boy",
                    value: $height,
                    placeholder: "0.0",
                    unit: "cm",
                    icon: "ruler",
                    color: colorScheme.primary
                )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [colorScheme.accent.opacity(0.3), colorScheme.accent.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: colorScheme.accent.opacity(0.1), radius: 15, x: 0, y: 8)
        )
    }
}

// Modern Measurement Input Field
struct ModernMeasurementInputField: View {
    let title: String
    @Binding var value: String
    let placeholder: String
    let unit: String
    let icon: String
    let color: Color
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.charcoal)
            }
            
            HStack(spacing: 12) {
                TextField(placeholder, text: $value)
                    .keyboardType(.decimalPad)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.charcoal)
                    .multilineTextAlignment(.trailing)
                    .focused($isFocused)
                
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
    }
}

// Modern Notes Card
struct ModernNotesCard: View {
    @Binding var notes: String
    let colorScheme: GenderColorScheme
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: "note.text")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [colorScheme.secondary, colorScheme.secondary.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: colorScheme.secondary.opacity(0.4), radius: 8, x: 0, y: 4)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Notlar")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoal)
                    
                    Text("İsteğe bağlı açıklama ekleyin")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Text Editor
            VStack(alignment: .leading, spacing: 8) {
                TextField("Örneğin: Doktor kontrolü, hastalık sonrası ölçüm vb.", text: $notes, axis: .vertical)
                    .font(.subheadline)
                    .foregroundColor(.charcoal)
                    .lineLimit(3...6)
                    .focused($isFocused)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(colorScheme.secondary.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        isFocused ? colorScheme.secondary : colorScheme.secondary.opacity(0.3),
                                        lineWidth: isFocused ? 2 : 1
                                    )
                            )
                    )
                
                Text("Bu alan isteğe bağlıdır. Ölçümle ilgili özel durumları not edebilirsiniz.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [colorScheme.secondary.opacity(0.3), colorScheme.secondary.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: colorScheme.secondary.opacity(0.1), radius: 15, x: 0, y: 8)
        )
    }
}

// Modern Percentile Preview Card
struct ModernPercentilePreviewCard: View {
    let baby: Baby
    let ageInMonths: Int
    let weightKg: Double
    let heightCm: Double
    let colorScheme: GenderColorScheme
    
    @State private var animatePreview = false
    
    private var heightPercentile: String {
        let data = baby.gender == .male ? MaleHeightPercentiles.data : FemaleHeightPercentiles.data
        return data.getPercentileForValue(heightCm, ageInMonths: ageInMonths)
    }
    
    private var weightPercentile: String {
        let data = baby.gender == .male ? MaleWeightPercentiles.data : FemaleWeightPercentiles.data
        return data.getPercentileForValue(weightKg, ageInMonths: ageInMonths)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: "chart.bar.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.successGreen, Color.successGreen.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color.successGreen.opacity(0.4), radius: 8, x: 0, y: 4)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Persentil Önizlemesi")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoal)
                    
                    Text("Yaş grubundaki konumu")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Percentile Values
            HStack(spacing: 20) {
                // Height Percentile
                VStack(spacing: 12) {
                    Image(systemName: "ruler")
                        .font(.title3)
                        .foregroundColor(colorScheme.primary)
                    
                    Text("\(String(format: "%.1f", heightCm)) cm")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoal)
                        .scaleEffect(animatePreview ? 1.0 : 0.8)
                        .opacity(animatePreview ? 1.0 : 0)
                    
                    Text("Boy")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text(heightPercentile)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(colorScheme.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(colorScheme.primary.opacity(0.1))
                        )
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colorScheme.primary.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(colorScheme.primary.opacity(0.2), lineWidth: 1)
                        )
                )
                
                // Weight Percentile
                VStack(spacing: 12) {
                    Image(systemName: "scalemass")
                        .font(.title3)
                        .foregroundColor(colorScheme.accent)
                    
                    Text("\(String(format: "%.2f", weightKg)) kg")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoal)
                        .scaleEffect(animatePreview ? 1.0 : 0.8)
                        .opacity(animatePreview ? 1.0 : 0)
                    
                    Text("Kilo")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text(weightPercentile)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(colorScheme.accent)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(colorScheme.accent.opacity(0.1))
                        )
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colorScheme.accent.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(colorScheme.accent.opacity(0.2), lineWidth: 1)
                        )
                )
            }
            
            // Explanation
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .font(.caption)
                        .foregroundColor(.infoBlue)
                    
                    Text("Persentil Açıklaması")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.charcoal)
                }
                
                Text("Persentil değeri, aynı yaştaki 100 çocuktan kaçının bu değerin altında olduğunu gösterir. Bu bilgiler kayıt sonrası grafiklerde görünecektir.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.infoBlue.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.infoBlue.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Color.successGreen.opacity(0.3), Color.successGreen.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.successGreen.opacity(0.1), radius: 15, x: 0, y: 8)
        )
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3)) {
                animatePreview = true
            }
        }
    }
}

// Modern Save Button
struct ModernSaveButton: View {
    let isFormValid: Bool
    let isLoading: Bool
    let colorScheme: GenderColorScheme
    let onSave: () -> Void
    
    var body: some View {
        Button(action: {
            if isFormValid && !isLoading {
                onSave()
            }
        }) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Text(isLoading ? "Kaydediliyor..." : "Ölçümü Kaydet")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isFormValid && !isLoading ?
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
                        color: isFormValid ? colorScheme.primary.opacity(0.4) : Color.clear,
                        radius: isFormValid ? 12 : 0,
                        x: 0,
                        y: isFormValid ? 6 : 0
                    )
            )
        }
        .disabled(!isFormValid || isLoading)
        .scaleEffect(isFormValid ? 1.0 : 0.98)
        .animation(.easeInOut(duration: 0.2), value: isFormValid)
    }
}

#Preview {
    ModernAddGrowthRecordView(baby: Baby(name: "Test Bebek", birthDate: Date().addingTimeInterval(-6*30*24*60*60)))
        .environmentObject(GrowthDataManager())
}
