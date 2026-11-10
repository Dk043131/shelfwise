import SwiftUI
import UserNotifications

public struct WeeklyReportView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @ObservedObject private var notificationManager = NotificationManager.shared
    
    @State private var showingGoalEditSheet: Bool = false
    @State private var temporaryGoal: Double = 200
    @State private var showingResetConfirmation: Bool = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                NocturneTheme.bgVoid.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Streak & Habit Card
                        streakOverviewCard
                        
                        // Weekly Progress Card
                        weeklyProgressCard
                        
                        // 7-Day Reading Bar Chart
                        weeklyBarChartCard
                        
                        // Scheduled Notifications Control Panel
                        scheduledNotificationsCard
                        
                        // Curriculum Level 1 Overall Progress
                        curriculumSummaryCard
                        
                        // Reset All Progress Button
                        resetDataSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 90) // space for floating bottom bar
                }
            }
            .navigationTitle("Weekly Report")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingGoalEditSheet) {
                weeklyGoalSheet
            }
        }
    }
    
    // MARK: - Streak Overview Card
    private var streakOverviewCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.18))
                    .frame(width: 54, height: 54)
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 26))
                    .foregroundColor(.orange)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .lastTextBaseline, spacing: 6) {
                    Text("\(dataManager.currentStreakDays)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("DAYS STREAK")
                        .font(.caption.bold())
                        .foregroundColor(Color.orange)
                        .tracking(1.1)
                }
                
                Text("Daily Dark Psychology reading habit active. Keep momentum alive!")
                    .font(.caption)
                    .foregroundColor(Color.white.opacity(0.65))
            }
            
            Spacer()
        }
        .padding(18)
        .liquidCard(cornerRadius: 18)
    }
    
    // MARK: - Weekly Progress Card
    private var weeklyProgressCard: some View {
        let weeklyPages = dataManager.pagesReadInCurrentWeek()
        let goal = dataManager.weeklyPageGoal
        let pct = min(100, Int((Double(weeklyPages) / Double(goal)) * 100))
        
        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("THIS WEEK'S READING HABIT")
                        .font(.caption.bold())
                        .foregroundColor(Color.white.opacity(0.5))
                        .tracking(1.1)
                    Text("Weekly Curriculum Target")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Button(action: {
                    temporaryGoal = Double(dataManager.weeklyPageGoal)
                    showingGoalEditSheet = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "slider.horizontal.3")
                        Text("Edit Goal")
                    }
                    .font(.caption.bold())
                }
                .buttonStyle(.glass)
            }
            
            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text("\(weeklyPages)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("/ \(goal) pages")
                    .font(.title3.weight(.medium))
                    .foregroundColor(Color.white.opacity(0.6))
                
                Spacer()
                
                Text("\(pct)% Achieved")
                    .font(.subheadline.bold())
                    .foregroundColor(pct >= 100 ? .green : NocturneTheme.purpleBright)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(NocturneTheme.purplePrimary.opacity(0.18)))
            }
            
            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 8)
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: pct >= 100
                                    ? [Color.green, Color.mint]
                                    : [NocturneTheme.purpleBright, Color.cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(8, geo.size.width * CGFloat(pct) / 100.0), height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding(18)
        .liquidCard(cornerRadius: 18)
    }
    
    // MARK: - Weekly Bar Chart
    private var weeklyBarChartCard: some View {
        let days = dataManager.dailyPagesForPast7Days()
        let maxPages = max(30, days.map { $0.pages }.max() ?? 30)
        
        return VStack(alignment: .leading, spacing: 14) {
            Text("PAST 7 DAYS ACTIVITY")
                .font(.caption.bold())
                .foregroundColor(Color.white.opacity(0.5))
                .tracking(1.1)
            
            HStack(alignment: .bottom, spacing: 10) {
                ForEach(days) { day in
                    VStack(spacing: 6) {
                        Text("\(day.pages)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(day.pages > 0 ? .white : Color.white.opacity(0.3))
                        
                        // Bar
                        let barHeight = max(6, CGFloat(day.pages) / CGFloat(maxPages) * 100.0)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                day.pages > 0
                                    ? LinearGradient(colors: [NocturneTheme.purpleBright, NocturneTheme.purpleDeep], startPoint: .top, endPoint: .bottom)
                                    : LinearGradient(colors: [Color.white.opacity(0.06), Color.white.opacity(0.06)], startPoint: .top, endPoint: .bottom)
                            )
                            .frame(height: barHeight)
                            .frame(maxWidth: .infinity)
                        
                        Text(day.dayName)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.6))
                    }
                }
            }
            .frame(height: 140, alignment: .bottom)
            .padding(.top, 4)
        }
        .padding(18)
        .liquidCard(cornerRadius: 18)
    }
    
    // MARK: - Scheduled Notifications Card
    private var scheduledNotificationsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ZStack {
                    Circle()
                        .fill(NocturneTheme.purplePrimary.opacity(0.2))
                        .frame(width: 36, height: 36)
                    Image(systemName: "bell.badge.fill")
                        .foregroundColor(NocturneTheme.purpleBright)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("STUDY & WEEKLY REMINDERS")
                        .font(.caption.bold())
                        .foregroundColor(Color.white.opacity(0.5))
                        .tracking(1.1)
                    Text("Automated Scheduled Notifications")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
            
            // Authorization Check
            if !notificationManager.isAuthorized {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notifications are not yet authorized.")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Button(action: {
                        Task {
                            _ = await notificationManager.requestAuthorization()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "bell.and.waves.left.and.right")
                            Text("Enable Notifications Permission")
                        }
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.glass(.regular.tint(NocturneTheme.purplePrimary)))
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.orange.opacity(0.1)))
            }
            
            // 1. Daily Study Reminder
            VStack(alignment: .leading, spacing: 10) {
                Toggle(isOn: Binding(
                    get: { notificationManager.dailyReminderEnabled },
                    set: { val in
                        notificationManager.dailyReminderEnabled = val
                        notificationManager.scheduleAllReminders()
                    }
                )) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Daily Study Reminder")
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                        Text("Prompts you every day to read your dark psychology chapter")
                            .font(.caption2)
                            .foregroundColor(Color.white.opacity(0.55))
                    }
                }
                .tint(NocturneTheme.purpleBright)
                
                if notificationManager.dailyReminderEnabled {
                    DatePicker(
                        "Reminder Time",
                        selection: Binding(
                            get: { notificationManager.dailyReminderTime },
                            set: { val in
                                notificationManager.dailyReminderTime = val
                                notificationManager.scheduleDailyStudyReminder()
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.compact)
                    .colorScheme(.dark)
                }
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12).fill(NocturneTheme.bgSurfaceElevated))
            
            // 2. Weekly Report Digest Notification
            VStack(alignment: .leading, spacing: 10) {
                Toggle(isOn: Binding(
                    get: { notificationManager.weeklyReportReminderEnabled },
                    set: { val in
                        notificationManager.weeklyReportReminderEnabled = val
                        notificationManager.scheduleAllReminders()
                    }
                )) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Weekly Report Digest")
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                        Text("Delivered every Sunday at 7:00 PM with your weekly stats")
                            .font(.caption2)
                            .foregroundColor(Color.white.opacity(0.55))
                    }
                }
                .tint(NocturneTheme.purpleBright)
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12).fill(NocturneTheme.bgSurfaceElevated))
            
            // Status message
            if let msg = notificationManager.lastNotificationStatusMessage {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                    Text(msg)
                        .font(.caption2)
                        .foregroundColor(Color.white.opacity(0.7))
                }
                .padding(.top, 2)
            }
            
            // Test Notification Liquid Button
            Button(action: {
                notificationManager.sendImmediateTestNotification()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "paperplane.fill")
                    Text("Send Test Notification Now")
                }
                .font(.subheadline.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.08))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.12), lineWidth: 1))
                )
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .liquidCard(cornerRadius: 18)
    }
    
    // MARK: - Curriculum Level 1 Summary Card
    private var curriculumSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("LEVEL 1 MASTERY SUMMARY")
                .font(.caption.bold())
                .foregroundColor(Color.white.opacity(0.5))
                .tracking(1.1)
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(dataManager.completedBooksCount) / 13")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Text("Books Finished")
                        .font(.caption2)
                        .foregroundColor(Color.white.opacity(0.6))
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(dataManager.readingBooksCount)")
                        .font(.title2.bold())
                        .foregroundColor(NocturneTheme.purpleBright)
                    Text("In Progress")
                        .font(.caption2)
                        .foregroundColor(Color.white.opacity(0.6))
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(dataManager.photoNotes.count)")
                        .font(.title2.bold())
                        .foregroundColor(.cyan)
                    Text("Visual Notes")
                        .font(.caption2)
                        .foregroundColor(Color.white.opacity(0.6))
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(dataManager.overallLevel1ProgressPercent)%")
                        .font(.title2.bold())
                        .foregroundColor(.green)
                    Text("Level Mastered")
                        .font(.caption2)
                        .foregroundColor(Color.white.opacity(0.6))
                }
            }
            .padding(.top, 4)
        }
        .padding(18)
        .liquidCard(cornerRadius: 18)
    }
    

    // MARK: - Reset All Data Section
    private var resetDataSection: some View {
        VStack(spacing: 12) {
            Button(action: { showingResetConfirmation = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                    Text("Reset All Data to Fresh Start")
                }
                .font(.subheadline.bold())
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.red.opacity(0.12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.3), lineWidth: 1))
                )
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .liquidCard(cornerRadius: 18)
        .confirmationDialog("Reset All Reading Data?", isPresented: $showingResetConfirmation, titleVisibility: .visible) {
            Button("Reset Everything to 0%", role: .destructive) {
                dataManager.resetToFreshCurriculum()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will wipe all logged pages, reading streaks, and photo notes, returning all 13 books to 0% fresh state.")
        }
    }

    // MARK: - Goal Edit Sheet
    private var weeklyGoalSheet: some View {
        NavigationStack {
            ZStack {
                NocturneTheme.bgVoid.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("Set Weekly Reading Target")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    Text("\(Int(temporaryGoal)) pages per week")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(NocturneTheme.purpleBright)
                    
                    Slider(value: $temporaryGoal, in: 50...1000, step: 25)
                        .tint(NocturneTheme.purplePrimary)
                        .padding(.horizontal)
                    
                    HStack(spacing: 8) {
                        ForEach([100, 200, 350, 500], id: \.self) { val in
                            Button("\(val) pp.") {
                                temporaryGoal = Double(val)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.08))
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.12), lineWidth: 1))
                            )
                            .buttonStyle(.plain)
                        }
                    }
                    
                    Button(action: {
                        dataManager.weeklyPageGoal = Int(temporaryGoal)
                        showingGoalEditSheet = false
                    }) {
                        Text("Save Target")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(NocturneTheme.purplePrimary)
                            )
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 10)
                    
                    Spacer()
                }
                .padding(24)
            }
            .navigationTitle("Weekly Target")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { showingGoalEditSheet = false }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .bold))
                            Text("Cancel")
                                .font(.subheadline)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.white.opacity(0.12)))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
