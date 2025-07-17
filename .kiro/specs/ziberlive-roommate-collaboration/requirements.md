# ZiberLive Roommate Collaboration App - Requirements Document

## Introduction

ZiberLive is a free roommate collaboration app designed to help people who share rooms manage their living situation effectively while working towards financial independence. The app focuses on fair bill splitting, task coordination, community cooking management, and investment opportunities to help users eventually cover their room expenses without relying on their salary. This is the foundational version that emphasizes offline-first functionality with P2P synchronization, gamification, and comprehensive roommate management tools.

The app targets roommates, students, and young professionals living in shared accommodations (1-2 apartments, 10-50 users) with Roommate-Admins who live in the space and share expenses equally with other residents.

## Requirements

### Requirement 1: User Management and Role System

**User Story:** As a Roommate-Admin, I want to manage users in my apartment and assign appropriate roles and subscriptions, so that everyone has the right access and billing arrangements.

#### Acceptance Criteria

1. WHEN a Roommate-Admin adds a new user THEN the system SHALL allow assignment of role (User or Roommate-Admin) and subscriptions (Community Cooking, drinking water, room rent, utilities)
2. WHEN a user requests to opt-out of a service THEN the system SHALL require admin approval before processing the change
3. WHEN a new user joins THEN the system SHALL generate a QR code invite for easy onboarding
4. WHEN viewing users THEN the system SHALL display payment status with green/red indicators for each user
5. WHEN a user's subscription changes THEN the system SHALL automatically recalculate all affected bill splits
6. WHEN managing users THEN the system SHALL support both residents and Community Cooking-only subscribers

### Requirement 2: Offline-First P2P Synchronization

**User Story:** As a user, I want the app to work completely offline and sync with my roommates' devices directly, so that I can manage my living situation even without internet access.

#### Acceptance Criteria

1. WHEN the app starts THEN the system SHALL function fully offline using local storage (SQLite)
2. WHEN devices are on the same Wi-Fi network THEN the system SHALL automatically discover and sync with other ZiberLive devices using P2P connections
3. WHEN data conflicts occur during sync THEN the system SHALL resolve conflicts using timestamp-based last-writer-wins strategy
4. WHEN sync occurs THEN the system SHALL display exactly 2 banner ads per sync operation
5. WHEN sync fails THEN the system SHALL queue changes and retry automatically when connection is restored
6. WHEN sync status is requested THEN the system SHALL show "Last synced: X minutes ago" with current sync health

### Requirement 3: Dynamic Bill Management and Splitting

**User Story:** As a Roommate-Admin, I want to input bills and have them automatically split fairly among subscribed users, so that everyone pays their fair share based on their chosen services.

#### Acceptance Criteria

1. WHEN a bill is entered THEN the system SHALL automatically split it among users subscribed to that service
2. WHEN a user joins or leaves THEN the system SHALL immediately recalculate all bill splits and notify affected users
3. WHEN bills are created THEN the system SHALL support custom naming (e.g., "Community Cooking" instead of generic terms)
4. WHEN viewing bills THEN the system SHALL display payment status with green/red indicators and send nudges to unpaid users
5. WHEN bill templates are used THEN the system SHALL allow saving recurring bills for quick entry
6. WHEN Roommate-Admin payment role is configured THEN the system SHALL include or exclude admin from bill splits based on settings

### Requirement 4: Community Cooking Management

**User Story:** As a user, I want to participate in community cooking with fair cost sharing and organized meal planning, so that I can save money on food while building community with my roommates.

#### Acceptance Criteria

1. WHEN Community Cooking is enabled THEN the system SHALL allow menu planning with daily/weekly schedules
2. WHEN grocery teams are formed THEN the system SHALL assign users to weekly teams and track spending through manual entry
3. WHEN billing mode is selected THEN the system SHALL support both fixed ($100/user) and variable billing with excess credited as Co-Living Credits
4. WHEN chef system is enabled THEN the system SHALL allow posting chef details for voting and managing recruitment/demotion
5. WHEN no chef is available THEN the system SHALL assign cooking tasks to users on rotation
6. WHEN meal schedules are set THEN the system SHALL notify users of meal times and menu updates

### Requirement 5: Task Management and Scheduling

**User Story:** As a Roommate-Admin, I want to create and manage cleaning and maintenance tasks with fair rotation, so that apartment upkeep is shared equally among all residents.

#### Acceptance Criteria

1. WHEN creating schedules THEN the system SHALL support weekly/monthly task rotations with drag-and-drop time slots
2. WHEN tasks are assigned THEN the system SHALL notify assignees with specific details and deadlines
3. WHEN tasks are completed THEN the system SHALL award Co-Living Credits and track completion streaks
4. WHEN using templates THEN the system SHALL provide common task templates (e.g., "Weekly Cleaning: Kitchen, Bathroom")
5. WHEN viewing schedules THEN the system SHALL display tasks in calendar format with clear assignments
6. WHEN task swapping is needed THEN the system SHALL allow users to swap tasks with approval

### Requirement 6: Voting and Decision Making

**User Story:** As a user, I want to participate in apartment decisions through a fair voting system, so that everyone has a voice in community choices.

#### Acceptance Criteria

1. WHEN creating polls THEN the system SHALL support quick polls from templates (e.g., "New menu: Pizza?") with anonymous or named voting options
2. WHEN voting is active THEN the system SHALL display live vote counts (e.g., "7/10 voted") with progress visualization
3. WHEN polls have deadlines THEN the system SHALL send FOMO alerts (e.g., "Poll closes in 1 hour!")
4. WHEN votes are cast offline THEN the system SHALL sync votes with 2 ads per sync operation
5. WHEN polls close THEN the system SHALL archive results and notify participants of outcomes
6. WHEN comments are enabled THEN the system SHALL allow anonymous comments on polls

### Requirement 7: Investment Groups for Financial Independence

**User Story:** As a user, I want to join investment groups with my roommates to generate passive income, so that I can eventually cover my rent expenses without using my salary.

#### Acceptance Criteria

1. WHEN creating investment groups THEN the system SHALL allow apartment-specific groups with member management
2. WHEN tracking contributions THEN the system SHALL record individual contributions and calculate returns
3. WHEN showing progress THEN the system SHALL display rent-free progress (e.g., "30% rent covered by investments")
4. WHEN proposing investments THEN the system SHALL allow micro-investment proposals via group chat
5. WHEN meetings are scheduled THEN the system SHALL support investment meeting scheduling with calendar integration
6. WHEN returns are calculated THEN the system SHALL show individual and group ROI with clear visualizations

### Requirement 8: Gamification and Community Building

**User Story:** As a user, I want to earn rewards and see community progress through engaging gamification, so that I stay motivated to contribute to apartment life.

#### Acceptance Criteria

1. WHEN actions are completed THEN the system SHALL award Co-Living Credits for bills, tasks, votes, and community participation
2. WHEN viewing progress THEN the system SHALL display an animated Community Tree that grows with collective contributions
3. WHEN credits are earned THEN the system SHALL allow redemption for ad removal ($1 = 100 credits) or cloud storage ($4 = 400 coins)
4. WHEN achievements are unlocked THEN the system SHALL display milestone celebrations (e.g., "5 weeks on time" for schedule streaks)
5. WHEN sharing progress THEN the system SHALL allow shareable Community Tree screenshots for social engagement
6. WHEN leaderboards are viewed THEN the system SHALL provide anonymous leaderboard options for privacy

### Requirement 9: Rules and Community Guidelines

**User Story:** As a Roommate-Admin, I want to set and enforce apartment rules with community input, so that everyone understands expectations and maintains harmony.

#### Acceptance Criteria

1. WHEN creating rules THEN the system SHALL allow rule creation via polls or direct input with scheduling (e.g., "Quiet hours: 10 PM-6 AM")
2. WHEN rules are violated THEN the system SHALL allow user reports with admin review
3. WHEN compliance is tracked THEN the system SHALL award credits for rule adherence
4. WHEN rules change THEN the system SHALL notify all users of new or updated rules
5. WHEN viewing rules THEN the system SHALL display current rules with clear scheduling and exceptions
6. WHEN rule disputes occur THEN the system SHALL provide resolution workflows through voting or admin decision

### Requirement 10: Community Collaboration Features

**User Story:** As a user, I want to collaborate with roommates on deals, events, and community improvements, so that we can save money and build stronger relationships.

#### Acceptance Criteria

1. WHEN using Community Board THEN the system SHALL allow posting tips (e.g., "Store X: 20% off rice") with upvoting
2. WHEN planning events THEN the system SHALL support apartment event creation (e.g., "Movie night") with RSVP tracking
3. WHEN finding deals THEN the system SHALL cache local deals offline for access without internet
4. WHEN collaborating on purchases THEN the system SHALL allow bulk purchase coordination through group proposals
5. WHEN sharing resources THEN the system SHALL facilitate resource sharing and borrowing between roommates
6. WHEN building community THEN the system SHALL encourage positive interactions through recognition and rewards

### Requirement 11: Bluetooth Messaging and Communication

**User Story:** As a user, I want to communicate with my roommates through secure Bluetooth messaging when Wi-Fi is unavailable, so that I can stay connected and coordinate apartment activities offline.

#### Acceptance Criteria

1. WHEN Bluetooth is enabled THEN the system SHALL discover other ZiberLive devices in the same apartment
2. WHEN connecting to roommate devices THEN the system SHALL establish secure Bluetooth connections for messaging
3. WHEN sending messages THEN the system SHALL encrypt all communications end-to-end
4. WHEN receiving messages THEN the system SHALL display them in real-time chat interface
5. WHEN using messaging THEN the system SHALL support both individual and group conversations
6. WHEN offline THEN the system SHALL queue messages and send when connection is restored

### Requirement 12: Reward System and Gamified Monetization

**User Story:** As a user, I want to earn reward coins through app engagement and redeem them for prizes or ad-free experience, so that I'm incentivized to participate actively while supporting the developer.

#### Acceptance Criteria

1. WHEN viewing ads THEN the system SHALL award reward coins (2 coins per ad viewed)
2. WHEN completing tasks THEN the system SHALL award bonus reward coins (5-10 coins per task)
3. WHEN participating in voting THEN the system SHALL award participation coins (3 coins per vote)
4. WHEN redeeming coins THEN the system SHALL offer ad-free experience (100 coins = 24 hours)
5. WHEN redeeming coins THEN the system SHALL offer lucky draw tickets (50 coins = 1 ticket)
6. WHEN winning lucky draws THEN the system SHALL provide physical rewards (t-shirts, merchandise)
7. WHEN purchasing THEN the system SHALL allow coin top-ups ($1 for 100 coins) for premium features

### Requirement 13: Monetization Through Ads and Micro-transactions

**User Story:** As a user, I want access to core features for free while having options to enhance my experience through small purchases, so that the app remains accessible while sustainable.

#### Acceptance Criteria

1. WHEN syncing data THEN the system SHALL display exactly 2 banner ads per sync operation
2. WHEN accessing settings THEN the system SHALL display one banner ad on the settings page
3. WHEN purchasing credits THEN the system SHALL offer coin top-ups (e.g., $1 for 100 coins) for ad removal and storage
4. WHEN ads are removed THEN the system SHALL provide 24-hour ad-free experience for 100 coins
5. WHEN cloud storage is needed THEN the system SHALL offer cloud storage access for 400 coins ($4 equivalent)
6. WHEN viewing sponsored content THEN the system SHALL show relevant local deals and services

### Requirement 14: Data Security and Privacy

**User Story:** As a user, I want my personal and financial data to be secure and private, so that I can trust the app with sensitive information about my living situation.

#### Acceptance Criteria

1. WHEN storing sensitive data THEN the system SHALL encrypt bills, votes, and user details using end-to-end encryption
2. WHEN syncing data THEN the system SHALL use secure P2P protocols with device authentication
3. WHEN backing up locally THEN the system SHALL create encrypted local backups on admin devices
4. WHEN handling personal information THEN the system SHALL comply with data protection requirements
5. WHEN users request data deletion THEN the system SHALL provide complete data removal capabilities
6. WHEN accessing data THEN the system SHALL implement role-based access controls to protect user privacy