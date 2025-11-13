import SwiftUI
import Charts

struct GrowthTrackingView: View {
    @EnvironmentObject var babyDataManager: BabyDataManager
    @EnvironmentObject var growthDataManager: GrowthDataManager
    @State private var showingAddRecord = false
    @State private var selectedTab = 0
    @State private var animateContent = false
    
    private var baby: Baby {
        babyDataManager.currentBaby
    }
    
    // Gender-based color scheme
    private var genderColorScheme: GenderColorScheme {
        GenderColorScheme.forGender(baby.gender)
    }
    
    var body: some View {
        ZStack {
            // Beautiful gradient background
            genderColorScheme.gradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                if baby.isPregnancy {
                    ModernPregnancyGrowthInfoView(colorScheme: genderColorScheme)
                        .opacity(animateContent ? 1.0 : 0)
                        .offset(y: animateContent ? 0 : 30)
                        .animation(.easeOut(duration: 0.8).delay(0.2), value: animateContent)
                } else {
                    VStack(spacing: 0) {
                        // Modern Header with Add Button
                        ModernGrowthTrackingHeader(
                            baby: baby,
                            records: growthDataManager.growthRecords,
                            colorScheme: genderColorScheme,
                            onAddRecord: {
                                showingAddRecord = true
                            }
                        )
                        .opacity(animateContent ? 1.0 : 0)
                        .offset(y: animateContent ? 0 : -30)
                        .animation(.easeOut(duration: 0.8).delay(0.1), value: animateContent)
                        
                        // Modern Tab Selector
                        ModernGrowthTabSelector(
                            selectedTab: $selectedTab,
                            colorScheme: genderColorScheme
                        )
                        .opacity(animateContent ? 1.0 : 0)
                        .offset(y: animateContent ? 0 : -20)
                        .animation(.easeOut(duration: 0.8).delay(0.2), value: animateContent)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        
                        // Content
                        TabView(selection: $selectedTab) {
                            // Height Chart
                            ModernHeightChartsView(
                                baby: baby,
                                records: growthDataManager.growthRecords,
                                colorScheme: genderColorScheme
                            )
                            .tag(0)
                            
                            // Weight Chart
                            ModernWeightChartsView(
                                baby: baby,
                                records: growthDataManager.growthRecords,
                                colorScheme: genderColorScheme
                            )
                            .tag(1)
                            
                            // Records List
                            ModernGrowthRecordsList(
                                baby: baby,
                                records: growthDataManager.growthRecords,
                                colorScheme: genderColorScheme
                            )
                            .tag(2)
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .opacity(animateContent ? 1.0 : 0)
                        .animation(.easeOut(duration: 0.8).delay(0.3), value: animateContent)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddRecord) {
            ModernAddGrowthRecordView(baby: baby)
                .environmentObject(growthDataManager)
        }
        .onAppear {
            animateContent = true
        }
    }
}

// Modern Growth Tracking Header
struct ModernGrowthTrackingHeader: View {
    let baby: Baby
    let records: [GrowthRecord]
    let colorScheme: GenderColorScheme
    let onAddRecord: () -> Void
    
    @State private var animateIcon = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("📊 Büyüme Takibi")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                    
                    Text("Boy ve kilo gelişimini izleyin")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                // Add Record Button
                Button(action: {
                    HapticFeedback.lightImpact()
                    onAddRecord()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.white)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 44, height: 44)
                        )
                        .scaleEffect(animateIcon ? 1.0 : 0.8)
                        .rotationEffect(.degrees(animateIcon ? 0 : -15))
                }
            }
            
            // Latest Stats if available
            if let latestRecord = records.last {
                ModernLatestStatsCard(
                    record: latestRecord,
                    baby: baby
                )
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
            withAnimation(.spring(response: 1.0, dampingFraction: 0.6).delay(0.5)) {
                animateIcon = true
            }
        }
    }
}

// Modern Latest Stats Card
struct ModernLatestStatsCard: View {
    let record: GrowthRecord
    let baby: Baby
    
    var body: some View {
        HStack(spacing: 20) {
            VStack(spacing: 4) {
                Text("Son Boy")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                
                Text("\(String(format: "%.1f", record.heightCm)) cm")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text("Son Kilo")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                
                Text("\(String(format: "%.2f", record.weightKg)) kg")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text("Yaş")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                
                Text("\(record.ageInMonths) ay")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.2))
                .background(.ultraThinMaterial)
        )
    }
}

// Modern Growth Tab Selector
struct ModernGrowthTabSelector: View {
    @Binding var selectedTab: Int
    let colorScheme: GenderColorScheme
    
    var body: some View {
        HStack(spacing: 8) {
            ModernGrowthTabButton(
                title: "Boy Grafiği",
                icon: "ruler",
                isSelected: selectedTab == 0,
                color: colorScheme.primary
            ) {
                HapticFeedback.selection()
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    selectedTab = 0
                }
            }
            
            ModernGrowthTabButton(
                title: "Kilo Grafiği",
                icon: "scalemass",
                isSelected: selectedTab == 1,
                color: colorScheme.accent
            ) {
                HapticFeedback.selection()
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    selectedTab = 1
                }
            }
            
            ModernGrowthTabButton(
                title: "Kayıtlar",
                icon: "list.bullet.clipboard",
                isSelected: selectedTab == 2,
                color: colorScheme.secondary
            ) {
                HapticFeedback.selection()
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    selectedTab = 2
                }
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.9))
                .shadow(color: colorScheme.primary.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

struct ModernGrowthTabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
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
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { pressing in
            isPressed = pressing
        } perform: {}
    }
}

// MARK: - Chart Data Models
struct PercentileChartData: Identifiable {
    let id = UUID()
    let age: Double
    let value: Double
    let percentile: String
}

struct UserDataPoint: Identifiable {
    let id = UUID()
    let age: Double
    let value: Double
}

// Modern Height Charts View
struct ModernHeightChartsView: View {
    let baby: Baby
    let records: [GrowthRecord]
    let colorScheme: GenderColorScheme
    
    @State private var animateChart = false
    
    private var heightPercentiles: [PercentileData] {
        baby.gender == .male ? MaleHeightPercentiles.data : FemaleHeightPercentiles.data
    }
    
    private var chartColor: Color {
        colorScheme.primary
    }
    
    // Pre-calculated percentile data
    private var percentileChartData: [PercentileChartData] {
        var data: [PercentileChartData] = []
        
        let percentileKeys = ["p3", "p10", "p25", "p50", "p75", "p90", "p97"]
        let keyPaths: [KeyPath<PercentileData, Double>] = [\.p3, \.p10, \.p25, \.p50, \.p75, \.p90, \.p97]
        
        for (index, percentileKey) in percentileKeys.enumerated() {
            let keyPath = keyPaths[index]
            
            for age in stride(from: 0, through: 36, by: 1) {
                if let value = heightPercentiles.interpolateValue(for: age, keyPath: keyPath) {
                    data.append(PercentileChartData(
                        age: Double(age),
                        value: value,
                        percentile: percentileKey
                    ))
                }
            }
        }
        
        return data
    }
    
    private var userDataPoints: [UserDataPoint] {
        records.map { record in
            UserDataPoint(
                age: Double(record.ageInMonths),
                value: record.heightCm
            )
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if records.isEmpty {
                    ModernEmptyStateView(
                        icon: "ruler",
                        title: "Henüz Boy Kaydı Yok",
                        description: "Boy ölçümlerini ekleyerek büyüme grafiğini oluşturun",
                        colorScheme: colorScheme
                    )
                } else {
                    // Latest measurement info
                    if let latestRecord = records.last {
                        ModernLatestMeasurementCard(
                            record: latestRecord,
                            percentile: heightPercentiles.getPercentileForValue(
                                latestRecord.heightCm,
                                ageInMonths: latestRecord.ageInMonths
                            ),
                            measurement: "\(String(format: "%.1f", latestRecord.heightCm)) cm",
                            type: "Boy",
                            color: chartColor,
                            icon: "ruler"
                        )
                        .opacity(animateChart ? 1.0 : 0)
                        .offset(y: animateChart ? 0 : 20)
                        .animation(.easeOut(duration: 0.8).delay(0.1), value: animateChart)
                    }
                    
                    // Chart Container
                    ModernChartContainer(
                        title: "Boy Persentil Grafiği",
                        subtitle: "Yaşa göre boy gelişimi",
                        color: chartColor
                    ) {
                        HeightChart(
                            percentileData: percentileChartData,
                            userData: userDataPoints,
                            chartColor: chartColor,
                            getPercentileColor: getPercentileColor,
                            getLineStyle: getLineStyle
                        )
                        .frame(height: 300)
                        .chartXScale(domain: 0...36)
                        .chartYScale(domain: 45...105)
                        .chartXAxis {
                            AxisMarks(values: .stride(by: 3)) { value in
                                AxisGridLine().foregroundStyle(.gray.opacity(0.3))
                                AxisTick().foregroundStyle(chartColor)
                                AxisValueLabel().foregroundStyle(Color.charcoal)
                            }
                        }
                        .chartYAxis {
                            AxisMarks(values: .stride(by: 5)) { value in
                                AxisGridLine().foregroundStyle(.gray.opacity(0.3))
                                AxisTick().foregroundStyle(chartColor)
                                AxisValueLabel().foregroundStyle(Color.charcoal)
                            }
                        }
                    }
                    .opacity(animateChart ? 1.0 : 0)
                    .offset(y: animateChart ? 0 : 30)
                    .animation(.easeOut(duration: 0.8).delay(0.3), value: animateChart)
                    
                    // Legend
                    ModernChartsLegendView(primaryColor: chartColor)
                        .opacity(animateChart ? 1.0 : 0)
                        .offset(y: animateChart ? 0 : 20)
                        .animation(.easeOut(duration: 0.8).delay(0.5), value: animateChart)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .onAppear {
            animateChart = true
        }
    }
    
    private func getPercentileColor(_ percentile: String) -> Color {
        switch percentile {
        case "p3", "p97": return .errorRed.opacity(0.7)
        case "p10", "p90": return .warningOrange.opacity(0.7)
        case "p25", "p75": return .infoBlue.opacity(0.6)
        case "p50": return chartColor
        default: return .coolGray
        }
    }
    
    private func getLineStyle(_ percentile: String) -> StrokeStyle {
        let lineWidth: CGFloat = percentile == "p50" ? 3.0 : 2.0
        let dash: [CGFloat] = (percentile == "p3" || percentile == "p97") ? [4, 4] : []
        
        return StrokeStyle(lineWidth: lineWidth, dash: dash)
    }
}

// Modern Weight Charts View
struct ModernWeightChartsView: View {
    let baby: Baby
    let records: [GrowthRecord]
    let colorScheme: GenderColorScheme
    
    @State private var animateChart = false
    
    private var weightPercentiles: [PercentileData] {
        baby.gender == .male ? MaleWeightPercentiles.data : FemaleWeightPercentiles.data
    }
    
    private var chartColor: Color {
        colorScheme.accent
    }
    
    // Pre-calculated percentile data
    private var percentileChartData: [PercentileChartData] {
        var data: [PercentileChartData] = []
        
        let percentileKeys = ["p3", "p10", "p25", "p50", "p75", "p90", "p97"]
        let keyPaths: [KeyPath<PercentileData, Double>] = [\.p3, \.p10, \.p25, \.p50, \.p75, \.p90, \.p97]
        
        for (index, percentileKey) in percentileKeys.enumerated() {
            let keyPath = keyPaths[index]
            
            for age in stride(from: 0, through: 36, by: 1) {
                if let value = weightPercentiles.interpolateValue(for: age, keyPath: keyPath) {
                    data.append(PercentileChartData(
                        age: Double(age),
                        value: value,
                        percentile: percentileKey
                    ))
                }
            }
        }
        
        return data
    }
    
    private var userDataPoints: [UserDataPoint] {
        records.map { record in
            UserDataPoint(
                age: Double(record.ageInMonths),
                value: record.weightKg
            )
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if records.isEmpty {
                    ModernEmptyStateView(
                        icon: "scalemass",
                        title: "Henüz Kilo Kaydı Yok",
                        description: "Kilo ölçümlerini ekleyerek büyüme grafiğini oluşturun",
                        colorScheme: colorScheme
                    )
                } else {
                    // Latest measurement info
                    if let latestRecord = records.last {
                        ModernLatestMeasurementCard(
                            record: latestRecord,
                            percentile: weightPercentiles.getPercentileForValue(
                                latestRecord.weightKg,
                                ageInMonths: latestRecord.ageInMonths
                            ),
                            measurement: "\(String(format: "%.2f", latestRecord.weightKg)) kg",
                            type: "Kilo",
                            color: chartColor,
                            icon: "scalemass"
                        )
                        .opacity(animateChart ? 1.0 : 0)
                        .offset(y: animateChart ? 0 : 20)
                        .animation(.easeOut(duration: 0.8).delay(0.1), value: animateChart)
                    }
                    
                    // Chart Container
                    ModernChartContainer(
                        title: "Kilo Persentil Grafiği",
                        subtitle: "Yaşa göre kilo gelişimi",
                        color: chartColor
                    ) {
                        WeightChart(
                            percentileData: percentileChartData,
                            userData: userDataPoints,
                            chartColor: chartColor,
                            getPercentileColor: getPercentileColor,
                            getLineStyle: getLineStyle
                        )
                        .frame(height: 300)
                        .chartXScale(domain: 0...36)
                        .chartYScale(domain: 1...20)
                        .chartXAxis {
                            AxisMarks(values: .stride(by: 3)) { value in
                                AxisGridLine().foregroundStyle(.gray.opacity(0.3))
                                AxisTick().foregroundStyle(chartColor)
                                AxisValueLabel().foregroundStyle(Color.charcoal)
                            }
                        }
                        .chartYAxis {
                            AxisMarks(values: .stride(by: 2)) { value in
                                AxisGridLine().foregroundStyle(.gray.opacity(0.3))
                                AxisTick().foregroundStyle(chartColor)
                                AxisValueLabel().foregroundStyle(Color.charcoal)
                            }
                        }
                    }
                    .opacity(animateChart ? 1.0 : 0)
                    .offset(y: animateChart ? 0 : 30)
                    .animation(.easeOut(duration: 0.8).delay(0.3), value: animateChart)
                    
                    // Legend
                    ModernChartsLegendView(primaryColor: chartColor)
                        .opacity(animateChart ? 1.0 : 0)
                        .offset(y: animateChart ? 0 : 20)
                        .animation(.easeOut(duration: 0.8).delay(0.5), value: animateChart)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .onAppear {
            animateChart = true
        }
    }
    
    private func getPercentileColor(_ percentile: String) -> Color {
        switch percentile {
        case "p3", "p97": return .errorRed.opacity(0.7)
        case "p10", "p90": return .warningOrange.opacity(0.7)
        case "p25", "p75": return .infoBlue.opacity(0.6)
        case "p50": return chartColor
        default: return .coolGray
        }
    }
    
    private func getLineStyle(_ percentile: String) -> StrokeStyle {
        let lineWidth: CGFloat = percentile == "p50" ? 3.0 : 2.0
        let dash: [CGFloat] = (percentile == "p3" || percentile == "p97") ? [4, 4] : []
        
        return StrokeStyle(lineWidth: lineWidth, dash: dash)
    }
}

// Modern Chart Container
struct ModernChartContainer<Content: View>: View {
    let title: String
    let subtitle: String
    let color: Color
    let content: Content
    
    init(
        title: String,
        subtitle: String,
        color: Color,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.charcoal)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Chart content
            content
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(color.opacity(0.2), lineWidth: 1)
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
                                colors: [color.opacity(0.3), color.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: color.opacity(0.1), radius: 15, x: 0, y: 8)
        )
    }
}

// Modern Charts Legend View
struct ModernChartsLegendView: View {
    let primaryColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Persentil Açıklaması")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.charcoal)
            
            VStack(spacing: 12) {
                ModernLegendItem(
                    symbol: .circle,
                    color: primaryColor,
                    title: "Girdiğiniz veriler"
                )
                
                ModernLegendItem(
                    symbol: .line,
                    color: primaryColor,
                    title: "50. persentil (ortanca)",
                    lineWidth: 3
                )
                
                ModernLegendItem(
                    symbol: .line,
                    color: .infoBlue.opacity(0.6),
                    title: "25-75. persentil",
                    lineWidth: 2
                )
                
                ModernLegendItem(
                    symbol: .line,
                    color: .warningOrange.opacity(0.7),
                    title: "10-90. persentil",
                    lineWidth: 2
                )
                
                ModernLegendItem(
                    symbol: .dashedLine,
                    color: .errorRed.opacity(0.7),
                    title: "3-97. persentil",
                    lineWidth: 2
                )
            }
            
            Text("Persentil değeri, aynı yaştaki 100 çocuktan kaçının bu değerin altında olduğunu gösterir.")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: primaryColor.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

// Modern Legend Item
struct ModernLegendItem: View {
    enum SymbolType {
        case circle
        case line
        case dashedLine
    }
    
    let symbol: SymbolType
    let color: Color
    let title: String
    let lineWidth: CGFloat
    
    init(symbol: SymbolType, color: Color, title: String, lineWidth: CGFloat = 2) {
        self.symbol = symbol
        self.color = color
        self.title = title
        self.lineWidth = lineWidth
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Symbol
            Group {
                switch symbol {
                case .circle:
                    Circle()
                        .fill(color)
                        .frame(width: 12, height: 12)
                        .shadow(color: color.opacity(0.3), radius: 2, x: 0, y: 1)
                        
                case .line:
                    Rectangle()
                        .fill(color)
                        .frame(width: 20, height: lineWidth)
                        .cornerRadius(lineWidth/2)
                        
                case .dashedLine:
                    HStack(spacing: 2) {
                        ForEach(0..<4, id: \.self) { _ in
                            Rectangle()
                                .fill(color)
                                .frame(width: 4, height: lineWidth)
                                .cornerRadius(lineWidth/2)
                        }
                    }
                }
            }
            .frame(width: 24, height: 12)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.charcoal)
            
            Spacer()
        }
    }
}

// Modern Growth Records List
struct ModernGrowthRecordsList: View {
    let baby: Baby
    let records: [GrowthRecord]
    let colorScheme: GenderColorScheme
    @EnvironmentObject var growthDataManager: GrowthDataManager
    
    @State private var animateRecords = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if records.isEmpty {
                    ModernEmptyStateView(
                        icon: "list.bullet.clipboard",
                        title: "Henüz Kayıt Yok",
                        description: "Boy ve kilo ölçümlerini kaydetmeye başlayın",
                        colorScheme: colorScheme
                    )
                } else {
                    ForEach(Array(records.reversed().enumerated()), id: \.offset) { index, record in
                        ModernGrowthRecordRow(
                            record: record,
                            baby: baby,
                            heightPercentile: (baby.gender == .male ? MaleHeightPercentiles.data : FemaleHeightPercentiles.data).getPercentileForValue(record.heightCm, ageInMonths: record.ageInMonths),
                            weightPercentile: (baby.gender == .male ? MaleWeightPercentiles.data : FemaleWeightPercentiles.data).getPercentileForValue(record.weightKg, ageInMonths: record.ageInMonths),
                            colorScheme: colorScheme
                        )
                        .opacity(animateRecords ? 1.0 : 0)
                        .offset(x: animateRecords ? 0 : 50)
                        .animation(
                            .easeOut(duration: 0.6).delay(Double(index) * 0.1),
                            value: animateRecords
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .onAppear {
            animateRecords = true
        }
    }
}

// Modern Growth Record Row
struct ModernGrowthRecordRow: View {
    let record: GrowthRecord
    let baby: Baby
    let heightPercentile: String
    let weightPercentile: String
    let colorScheme: GenderColorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(record.date.toDateString())
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoal)
                    
                    Text("\(record.ageInMonths) aylık")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(formatTimeAgo(record.date))
                    .font(.caption)
                    .foregroundColor(colorScheme.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(colorScheme.primary.opacity(0.1))
                    )
            }
            
            // Measurements
            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "ruler")
                        .font(.title3)
                        .foregroundColor(colorScheme.primary)
                    
                    Text("\(String(format: "%.1f", record.heightCm)) cm")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoal)
                    
                    Text(heightPercentile)
                        .font(.caption)
                        .foregroundColor(colorScheme.primary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colorScheme.primary.opacity(0.1))
                )
                
                VStack(spacing: 8) {
                    Image(systemName: "scalemass")
                        .font(.title3)
                        .foregroundColor(colorScheme.accent)
                    
                    Text("\(String(format: "%.2f", record.weightKg)) kg")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoal)
                    
                    Text(weightPercentile)
                        .font(.caption)
                        .foregroundColor(colorScheme.accent)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colorScheme.accent.opacity(0.1))
                )
            }
            
            // Notes if available
            if let notes = record.notes, !notes.isEmpty {
                HStack {
                    Image(systemName: "note.text")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(notes)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.coolGray.opacity(0.1))
                )
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
                                colors: [colorScheme.primary.opacity(0.2), colorScheme.accent.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: colorScheme.primary.opacity(0.08), radius: 10, x: 0, y: 5)
        )
    }
    
    private func formatTimeAgo(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        // Check if it's today
        if calendar.isDate(date, inSameDayAs: now) {
            return "Bugün"
        }
        
        // Check if it's yesterday
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
           calendar.isDate(date, inSameDayAs: yesterday) {
            return "Dün"
        }
        
        let days = calendar.dateComponents([.day], from: date, to: now).day ?? 0
        if days < 7 {
            return "\(days) gün önce"
        } else if days < 30 {
            let weeks = days / 7
            return "\(weeks) hafta önce"
        } else {
            let months = calendar.dateComponents([.month], from: date, to: now).month ?? 0
            return "\(months) ay önce"
        }
    }
}

// Modern Latest Measurement Card
struct ModernLatestMeasurementCard: View {
    let record: GrowthRecord
    let percentile: String
    let measurement: String
    let type: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Son \(type) Ölçümü")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoal)
                    
                    Text(record.date.toDateString())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [color, color.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 4)
                    )
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(measurement)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                    
                    Text("\(record.ageInMonths) aylık")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Persentil")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(percentile)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(color)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.1), color.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: color.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

// MARK: - Helper Chart Components

// Simplified Height Chart Component
struct HeightChart: View {
    let percentileData: [PercentileChartData]
    let userData: [UserDataPoint]
    let chartColor: Color
    let getPercentileColor: (String) -> Color
    let getLineStyle: (String) -> StrokeStyle
    
    var body: some View {
        Chart {
            // Percentile lines
            ForEach(percentileData, id: \.id) { dataPoint in
                let color = getPercentileColor(dataPoint.percentile)
                let style = getLineStyle(dataPoint.percentile)
                
                LineMark(
                    x: .value("Yaş", dataPoint.age),
                    y: .value("Boy", dataPoint.value)
                )
                .foregroundStyle(color)
                .lineStyle(style)
                .interpolationMethod(.catmullRom)
            }
            
            // User data points
            ForEach(userData, id: \.id) { dataPoint in
                PointMark(
                    x: .value("Yaş", dataPoint.age),
                    y: .value("Boy", dataPoint.value)
                )
                .foregroundStyle(chartColor)
                .symbolSize(80)
            }
        }
    }
}

// Simplified Weight Chart Component
struct WeightChart: View {
    let percentileData: [PercentileChartData]
    let userData: [UserDataPoint]
    let chartColor: Color
    let getPercentileColor: (String) -> Color
    let getLineStyle: (String) -> StrokeStyle
    
    var body: some View {
        Chart {
            // Percentile lines
            ForEach(percentileData, id: \.id) { dataPoint in
                let color = getPercentileColor(dataPoint.percentile)
                let style = getLineStyle(dataPoint.percentile)
                
                LineMark(
                    x: .value("Yaş", dataPoint.age),
                    y: .value("Kilo", dataPoint.value)
                )
                .foregroundStyle(color)
                .lineStyle(style)
                .interpolationMethod(.catmullRom)
            }
            
            // User data points
            ForEach(userData, id: \.id) { dataPoint in
                PointMark(
                    x: .value("Yaş", dataPoint.age),
                    y: .value("Kilo", dataPoint.value)
                )
                .foregroundStyle(chartColor)
                .symbolSize(80)
            }
        }
    }
}

// Modern Empty State View
struct ModernEmptyStateView: View {
    let icon: String
    let title: String
    let description: String
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
                
                Image(systemName: icon)
                    .font(.system(size: 48, weight: .medium))
                    .foregroundColor(colorScheme.primary)
                    .scaleEffect(animateIcon ? 1.0 : 0.5)
                    .rotationEffect(.degrees(animateIcon ? 0 : -10))
            }
            .animation(.spring(response: 1.0, dampingFraction: 0.6).delay(0.2), value: animateIcon)
            
            VStack(spacing: 16) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.charcoal)
                    .multilineTextAlignment(.center)
                
                Text(description)
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
        .padding(.vertical, 60)
        .onAppear {
            animateIcon = true
        }
    }
}

// Modern Pregnancy Growth Info View
struct ModernPregnancyGrowthInfoView: View {
    let colorScheme: GenderColorScheme
    
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
                        
                        Image(systemName: "chart.xyaxis.line")
                            .font(.system(size: 60, weight: .medium))
                            .foregroundColor(.pregnancyPrimary)
                            .scaleEffect(animateContent ? 1.0 : 0.5)
                    }
                    .animation(.spring(response: 1.0, dampingFraction: 0.6).delay(0.2), value: animateContent)
                    
                    VStack(spacing: 12) {
                        Text("Büyüme Takibi")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.charcoal)
                            .multilineTextAlignment(.center)
                            .opacity(animateContent ? 1.0 : 0)
                            .offset(y: animateContent ? 0 : 20)
                        
                        Text("Bebeğiniz doğduktan sonra boy ve kilo ölçümlerini kaydederek büyüme grafiğini takip edebileceksiniz.")
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
                
                // Feature cards
                VStack(spacing: 16) {
                    ForEach(Array(growthFeatures.enumerated()), id: \.offset) { index, feature in
                        ModernGrowthFeatureCard(
                            title: feature.title,
                            description: feature.description,
                            icon: feature.icon,
                            color: feature.color
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
    
    private var growthFeatures: [(title: String, description: String, icon: String, color: Color)] {
        [
            (
                title: "Boy Takibi",
                description: "Persentil grafiği ile boy gelişimini izleyin",
                icon: "ruler",
                color: .babyPrimary
            ),
            (
                title: "Kilo Takibi",
                description: "Kilo artışını persentil eğrileriyle karşılaştırın",
                icon: "scalemass",
                color: .mintGreen
            ),
            (
                title: "Düzenli Kayıt",
                description: "Aylık kontrollerde ölçümleri kaydedin",
                icon: "calendar",
                color: .coralPink
            ),
            (
                title: "Gelişim Analizi",
                description: "Büyüme trendlerini ve sağlıklı gelişimi takip edin",
                icon: "chart.line.uptrend.xyaxis",
                color: .lilacPurple
            )
        ]
    }
}

// Modern Growth Feature Card
struct ModernGrowthFeatureCard: View {
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
