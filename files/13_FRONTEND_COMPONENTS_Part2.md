#### Psychology Tab

- Jung archetype (visual selector s ikonami)
- MBTI type (4x2 toggle grid)
- Dominant value
- Main frustration
- Neuroticism level (slider: Low/Medium/High)

#### Writing Style Tab

- Vocabulary level (select)
- Sentence preference (select)
- Metaphor usage (select)
- Argument structure (select)
- Preferred writing framework (select)
- Analysis depth (select)
- Topic opening style (select)
- Favorite phrases/keywords (tag input)
- Unique signature ending

#### Visual Style Tab

- Art style name (visual selector)
- Color palette (visual selector)
- Visual atmosphere (select)
- Equipment in photos
- Reference images (file upload)

#### Backstory Tab

- Backstory highlight (textarea)
- Hobby outside work
- Social status in company
- Exaggeration bias (select)

---

### 9.3 `PersonaComparisonComponent`

**Soubor:** `features/personas/components/persona-comparison/`

**Funkce:**

- Výběr 2-3 person pro porovnání
- Tabulka s porovnáním všech atributů
- Highlightování rozdílů

---

### 9.4 `JungArchetypeSelectorComponent`

**Soubor:** `shared/components/jung-archetype-selector/`

**Zobrazení:**

- 12 karet (3x4 grid)
- Každá karta: Ikona + Název + Krátký popis
- Hover: Detailnější popis
- Selected state: Border gradient

---

### 9.5 `MbtiSelectorComponent`

**Soubor:** `shared/components/mbti-selector/`

**Zobrazení:**

- 4 dimenze jako toggle páry:
  - E ←→ I (Extraversion/Introversion)
  - S ←→ N (Sensing/Intuition)
  - T ←→ F (Thinking/Feeling)
  - J ←→ P (Judging/Perceiving)
- Výsledný typ zobrazený dole
- Click na typ = toggle jednotlivé dimenze

---

## 10. Modul: Content Planner

### 10.1 `ContentCalendarComponent`

**Soubor:** `features/content-planner/components/content-calendar/`

**Layout:**

- Toolbar:
  - Month/Year selector
  - View toggle (Calendar / List / Kanban)
  - Filter by persona
  - Filter by platform
  - Filter by status
  - "Generate Topics" button
- Calendar grid:
  - Dny v měsíci
  - Topic cards v jednotlivých dnech
  - Drag & drop mezi dny
  - Click = detail/edit

**TopicCard v kalendáři:**

- Persona avatar (small)
- Topic title (truncated)
- Status badge
- Platform icons

---

### 10.2 `TopicListViewComponent`

**Soubor:** `features/content-planner/components/topic-list-view/`

**Obsah:**

- Grouped by week
- Data table:
  - Date
  - Topic title
  - Persona
  - Status
  - Platforms
  - Actions

---

### 10.3 `TopicKanbanViewComponent`

**Soubor:** `features/content-planner/components/topic-kanban-view/`

**Sloupce:**

- Generated
- Pending Approval
- Approved
- In Progress (Blog post)
- Ready (Social posts)
- Published

**Karta:**

- Topic title
- Persona chip
- Date
- Quick actions

---

### 10.4 `TopicDetailComponent`

**Soubor:** `features/content-planner/components/topic-detail/`

**Layout:** Slide-over panel (zprava)

**Obsah:**

- Header: Status badge, Actions dropdown
- Title (editable)
- Subtitle (editable)
- Description (rich text)
- Keywords (tag input)
- Focus keyword (input)
- Search intent (select)
- Planned date (date picker)
- Assigned persona (select)
- Related event (select, optional)

**Actions:**

- Approve
- Reject (with reason)
- Generate replacement
- Delete
- Regenerate

---

### 10.5 `TopicGeneratorModalComponent`

**Soubor:** `features/content-planner/components/topic-generator-modal/`

**Obsah:**

- Month selector
- Posts per week (number input)
- Equal persona distribution (toggle)
- Focus areas (textarea, optional)
- Include events (toggle)
- Generate button
- Progress view po spuštění:
  - "Analyzing company DNA..."
  - "Generating topics for Week 1..."
  - Success summary

---

### 10.6 `TopicApprovalComponent`

**Soubor:** `features/content-planner/components/topic-approval/`

**Layout:** Split view

**Levá strana:**

- Seznam témat ke schválení
- Filter by persona
- Select all / Deselect

**Pravá strana:**

- Detail vybraného tématu
- Approve / Reject buttons
- Bulk actions toolbar

---

## 11. Modul: Blog Posts

### 11.1 `BlogPostListComponent`

**Soubor:** `features/blog-posts/components/blog-post-list/`

**Obsah:**

- Search
- Filters: Status, Persona, Month
- Data table:
  - Title
  - Persona
  - Topic
  - Word count
  - Status
  - Created/Updated
  - Actions

---

### 11.2 `BlogPostDetailComponent`

**Soubor:** `features/blog-posts/components/blog-post-detail/`

**Layout:** Full page

**Sidebar:**

- Status card
- Metadata:
  - Word count
  - Reading time
  - SEO score
- Persona card (mini)
- Topic link
- Actions:
  - Approve
  - Request changes
  - Regenerate
  - Export

**Main content:**

- Title (H1, editable)
- Meta title (input)
- Meta description (textarea)
- Content sections (collapsible accordion):
  - Each section: Heading + Content (rich text)
  - Reorder sections (drag & drop)
  - Add/Remove sections
- FAQs section
- Sources section

---

### 11.3 `BlogPostEditorComponent`

**Soubor:** `features/blog-posts/components/blog-post-editor/`

**Funkce:**

- Full rich text editor
- Section-based editing
- Real-time word count
- SEO checker (keyword density, meta length)
- Auto-save
- Version history

---

### 11.4 `BlogPostPreviewComponent`

**Soubor:** `features/blog-posts/components/blog-post-preview/`

**Funkce:**

- Rendered preview jako blog článek
- Toggle mobile/desktop view
- Print view

---

### 11.5 `SeoCheckerComponent`

**Soubor:** `features/blog-posts/components/seo-checker/`

**Obsah:**

- Focus keyword status
- Keyword density meter
- Meta title length indicator
- Meta description length indicator
- Headings structure
- Internal links suggestions
- Overall SEO score (0-100)

---

## 12. Modul: Social Posts

### 12.1 `SocialPostListComponent`

**Soubor:** `features/social-posts/components/social-post-list/`

**Obsah:**

- Filters: Platform, Status, Date range
- View toggle: Grid / List
- Bulk actions: Approve, Schedule, Delete

**Grid view:**

- Social post cards showing preview

**List view:**

- Data table with columns

---

### 12.2 `SocialPostCardComponent`

**Soubor:** `features/social-posts/components/social-post-card/`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `post` | `SocialPost` | Data |
| `showActions` | `boolean` | Zobrazit akce |
| `showStats` | `boolean` | Zobrazit metriky |

**Obsah:**

- Platform icon + name
- Post text (truncated)
- Media preview (image/video thumbnail)
- Hashtags
- Scheduled time
- Status badge
- Actions: Edit, Preview, Approve, Delete

---

### 12.3 `SocialPostEditorComponent`

**Soubor:** `features/social-posts/components/social-post-editor/`

**Obsah:**

- Platform selector
- Text editor s character counter
- Platform-specific limits indicator
- Hashtag editor
- Mention editor
- CTA text + URL
- Media selector/uploader
- Schedule picker (date + time)
- Preview button

---

### 12.4 `SocialPostPreviewComponent`

**Soubor:** `features/social-posts/components/social-post-preview/`

**Funkce:**

- Platform-specific mockup (Instagram post, LinkedIn post, Tweet...)
- Shows how the post will look
- Mobile/Desktop toggle

**Platforms:**

- Instagram Feed mockup
- Instagram Story mockup
- LinkedIn mockup
- Facebook mockup
- Twitter/X mockup
- TikTok mockup

---

### 12.5 `PlatformSelectorComponent`

**Soubor:** `shared/components/platform-selector/`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `platforms` | `SocialPlatform[]` | Dostupné platformy |
| `selected` | `SocialPlatform[]` | Vybrané |
| `multiple` | `boolean` | Vícenásobný výběr |
| `showLimits` | `boolean` | Zobrazit limity (char count) |

**Zobrazení:**

- Grid ikon platforem
- Selected state: Border + checkmark
- Disabled state pro nepovolené v subscription

---

### 12.6 `HashtagEditorComponent`

**Soubor:** `shared/components/hashtag-editor/`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `value` | `string[]` | Hashtagy |
| `suggestions` | `string[]` | Návrhy |
| `maxCount` | `number` | Max počet |
| `platformLimits` | `Record<Platform, number>` | Limity dle platformy |

**Funkce:**

- Auto-prefix # pokud chybí
- Návrhy z AI
- Trending hashtags
- Copy all button

---

## 13. Modul: Media Factory

### 13.1 `VisualGeneratorComponent`

**Soubor:** `features/media-factory/components/visual-generator/`

**Obsah:**

- Source selector: Blog post / Topic / Custom
- Platform selector (pro aspect ratio)
- Style selector (authenticity level)
- Preview of generated prompt
- Generate button
- Gallery of generated variants

---

### 13.2 `VisualGalleryComponent`

**Soubor:** `features/media-factory/components/visual-gallery/`

**Obsah:**

- Grid of generated images
- Filter by: Platform, Style, Date
- Search
- Actions: Download, Use in post, Regenerate, Delete

---

### 13.3 `VisualPreviewComponent`

**Soubor:** `features/media-factory/components/visual-preview/`

**Obsah:**

- Full-size image view
- Generation prompt used
- Metadata (model, timestamp)
- Actions: Download (multiple sizes), Edit prompt, Regenerate

---

### 13.4 `VideoGeneratorComponent`

**Soubor:** `features/media-factory/components/video-generator/`

**[ULTIMATE TIER ONLY]**

**Obsah:**

- Source selector: Blog post key takeaways
- Video type: Background loop / Kinetic typography / Talking head
- Duration: 6s / 10s / 15s
- Style settings
- Generate button
- Preview player

---

### 13.5 `MediaLibraryComponent`

**Soubor:** `features/media-factory/components/media-library/`

**Obsah:**

- Tabs: Images / Videos / Uploaded
- Grid view
- Search
- Filters: Type, Platform, Date
- Upload button
- Bulk select + delete

---

### 13.6 `StyleSelectorComponent`

**Soubor:** `features/media-factory/components/style-selector/`

**Obsah:**

- Authenticity slider: Polished ←→ Raw
- Style presets:
  - Editorial Photography
  - Documentary/BTS
  - Flat Vector
  - 3D Render
  - etc.
- Color palette override
- Custom prompt additions

---

## 14. Modul: Approval Center

### 14.1 `ApprovalDashboardComponent`

**Soubor:** `features/approval-center/components/approval-dashboard/`

**Layout:** Kanban-style

**Sekce:**

- Topics awaiting approval
- Blog posts awaiting approval
- Visuals awaiting approval
- Social posts awaiting approval

**Každá sekce:**

- Count badge
- Quick approve all (pokud < 5)
- View all link

---

### 14.2 `ApprovalQueueComponent`

**Soubor:** `features/approval-center/components/approval-queue/`

**Obsah:**

- Tabs: All / Topics / Blog Posts / Visuals / Social Posts
- Filter by company (pro Marketéry)
- Sort: Oldest first / Newest first / Priority
- List view
- Bulk actions

---

### 14.3 `ApprovalItemComponent`

**Soubor:** `features/approval-center/components/approval-item/`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `item` | `ApprovableItem` | Topic/BlogPost/Visual/SocialPost |
| `type` | `'topic' \| 'blogpost' \| 'visual' \| 'socialpost'` | Typ |

**Obsah:**

- Preview based on type
- Company info
- Persona info
- Created date
- Days pending
- Approve / Reject buttons
- View details link

---

### 14.4 `RejectionReasonModalComponent`

**Soubor:** `features/approval-center/components/rejection-reason-modal/`

**Obsah:**

- Predefined reasons (checkboxes):
  - Off-brand
  - Factually incorrect
  - Poor quality
  - Not relevant
  - Other
- Custom reason textarea
- Request regeneration toggle
- Submit button

---

### 14.5 `ApprovalHistoryComponent`

**Soubor:** `features/approval-center/components/approval-history/`

**Obsah:**

- Timeline of all approvals/rejections
- Filter by: Company, Type, User, Date
- Export button

---

## 15. Modul: Analytics

### 15.1 `AnalyticsDashboardComponent`

**Soubor:** `features/analytics/components/analytics-dashboard/`

**Layout:**

- Date range selector
- Company selector (pro Admin/Manager)
- Stat cards row
- Charts grid

**Stat cards:**

- Total posts published
- Total engagement
- Best performing persona
- Average approval time

**Charts:**

- Posts over time (line chart)
- Engagement by platform (bar chart)
- Content by persona (pie chart)
- Approval rate trend (line chart)

---

### 15.2 `PerformanceReportComponent`

**Soubor:** `features/analytics/components/performance-report/`

**Obsah:**

- Period selector
- Metrics breakdown:
  - Posts per platform
  - Engagement rate
  - Best performing topics
  - Worst performing topics
- Export to PDF/Excel

---

### 15.3 `PersonaPerformanceComponent`

**Soubor:** `features/analytics/components/persona-performance/`

**Obsah:**

- Comparison table of all personas
- Metrics: Posts, Engagement, Avg. approval time
- Chart: Performance over time per persona

---

### 15.4 `ContentInsightsComponent`

**Soubor:** `features/analytics/components/content-insights/`

**Obsah:**

- Top performing content
- Content type breakdown
- Optimal posting times
- Hashtag performance

---

## 16. Modul: Settings

### 16.1 `SettingsLayoutComponent`

**Soubor:** `features/settings/components/settings-layout/`

**Sidebar navigace:**

- Profile
- Password & Security
- Notifications
- Integrations
- Billing (Supervisor only)
- Team (Admin/Manager only)

---

### 16.2 `ProfileSettingsComponent`

**Soubor:** `features/settings/components/profile-settings/`

**Obsah:**

- Avatar upload
- Name
- Email (readonly)
- Phone
- Timezone selector
- Language selector

---

### 16.3 `NotificationSettingsComponent`

**Soubor:** `features/settings/components/notification-settings/`

**Obsah:**

- Toggle pro každý typ notifikace:
  - Content ready for approval
  - Content approved/rejected
  - Generation completed
  - Generation failed
  - Weekly summary
- Email preferences
- Push notification toggle

---

### 16.4 `IntegrationSettingsComponent`

**Soubor:** `features/settings/components/integration-settings/`

**Obsah:**

- Connected platforms list
- For each platform:
  - Connection status
  - Account info
  - Reconnect button
  - Disconnect button
- Available integrations to connect

---

### 16.5 `SecuritySettingsComponent`

**Soubor:** `features/settings/components/security-settings/`

**Obsah:**

- Change password form
- Two-factor authentication setup
- Active sessions list
- Login history

---

## 17. Modul: Subscription

### 17.1 `SubscriptionOverviewComponent`

**Soubor:** `features/subscription/components/subscription-overview/`

**Obsah:**

- Current plan card:
  - Plan name + badge
  - Price
  - Renewal date
  - Usage meters (posts, platforms)
- Upgrade button
- Cancel subscription link
- Billing history link

---

### 17.2 `PlanComparisonComponent`

**Soubor:** `features/subscription/components/plan-comparison/`

**Obsah:**

- 3 plan cards side by side:
  - BASIC
  - PRO
  - ULTIMATE
- Feature comparison table
- Price per month/year toggle
- Current plan indicator
- Upgrade/Downgrade buttons

**Feature highlights:**

- Posts per month
- Platforms
- Visuals (Nanobana)
- Videos (Veo 3)
- Priority queue
- Support level

---

### 17.3 `BillingHistoryComponent`

**Soubor:** `features/subscription/components/billing-history/`

**Obsah:**

- Data table:
  - Date
  - Description
  - Amount
  - Status
  - Invoice download

---

### 17.4 `PaymentMethodsComponent`

**Soubor:** `features/subscription/components/payment-methods/`

**Obsah:**

- List of saved cards
- Default indicator
- Add new card button
- Edit/Remove actions

---

### 17.5 `UsageMeterComponent`

**Soubor:** `shared/components/usage-meter/`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `used` | `number` | Použito |
| `limit` | `number` | Limit |
| `label` | `string` | Popisek |
| `showPercentage` | `boolean` | Zobrazit % |
| `warningThreshold` | `number` | Práh pro varování (default: 80) |

**Zobrazení:**

- Progress bar
- "X of Y" label
- Warning color když > threshold

---

## 18. Modul: User Management

### 18.1 `UserListComponent`

**Soubor:** `features/user-management/components/user-list/`

**[ADMIN / MANAGER only]**

**Obsah:**

- Search
- Filter by role
- Filter by status
- Data table:
  - Avatar + Name
  - Email
  - Role (badge)
  - Status (badge)
  - Managed by
  - Companies count
  - Last active
  - Actions

---

### 18.2 `UserDetailComponent`

**Soubor:** `features/user-management/components/user-detail/`

**Obsah:**

- Profile card
- Role info
- Activity timeline
- Assigned companies list
- Performance metrics
- Actions: Edit, Suspend, Delete

---

### 18.3 `UserFormComponent`

**Soubor:** `features/user-management/components/user-form/`

**Pole:**

- Email
- Name
- Role (select, based on creator's role)
- Managed by (select, hierarchical)
- Assign to companies (multi-select)
- Send invitation email (toggle)

---

### 18.4 `UserHierarchyViewComponent`

**Soubor:** `features/user-management/components/user-hierarchy-view/`

**Zobrazení:**

- Tree view of user hierarchy:
  - Admin
    - Manager 1
      - Marketer 1
        - Supervisor A
        - Supervisor B
      - Marketer 2
    - Manager 2
- Expand/Collapse nodes
- Click = user detail

---

### 18.5 `TeamDashboardComponent`

**Soubor:** `features/user-management/components/team-dashboard/`

**[MANAGER only]**

**Obsah:**

- Team overview stats
- Workload distribution chart
- Pending approvals per team member
- Reassign tasks button

---

## Appendix: Enum Values pro Select komponenty

### Subscription Tiers

```typescript
enum SubscriptionTier {
  TRIAL = 'trial',
  BASIC = 'basic',
  PRO = 'pro',
  ULTIMATE = 'ultimate'
}
```

### User Roles

```typescript
enum UserRole {
  ADMIN = 'ADMIN',
  MANAGER = 'MANAGER',
  MARKETER = 'MARKETER',
  SUPERVISOR = 'SUPERVISOR'
}
```

### Content Status

```typescript
enum ContentStatus {
  DRAFT = 'DRAFT',
  GENERATING = 'GENERATING',
  PENDING_APPROVAL = 'PENDING_APPROVAL',
  APPROVED = 'APPROVED',
  PUBLISHED = 'PUBLISHED',
  FAILED = 'FAILED'
}
```

### Social Platforms

```typescript
enum SocialPlatform {
  FACEBOOK = 'facebook',
  INSTAGRAM = 'instagram',
  LINKEDIN = 'linkedin',
  TWITTER = 'twitter',
  TIKTOK = 'tiktok',
  YOUTUBE = 'youtube',
  PINTEREST = 'pinterest'
}
```

### Jung Archetypes

```typescript
enum JungArchetype {
  INNOCENT = 'innocent',
  EVERYMAN = 'everyman',
  HERO = 'hero',
  OUTLAW = 'outlaw',
  EXPLORER = 'explorer',
  CREATOR = 'creator',
  RULER = 'ruler',
  MAGICIAN = 'magician',
  LOVER = 'lover',
  CAREGIVER = 'caregiver',
  JESTER = 'jester',
  SAGE = 'sage'
}
```

### MBTI Types

```typescript
enum MbtiType {
  INTJ = 'INTJ', INTP = 'INTP', ENTJ = 'ENTJ', ENTP = 'ENTP',
  INFJ = 'INFJ', INFP = 'INFP', ENFJ = 'ENFJ', ENFP = 'ENFP',
  ISTJ = 'ISTJ', ISFJ = 'ISFJ', ESTJ = 'ESTJ', ESFJ = 'ESFJ',
  ISTP = 'ISTP', ISFP = 'ISFP', ESTP = 'ESTP', ESFP = 'ESFP'
}
```

### Communication Style

```typescript
enum CommunicationStyle {
  FORMAL = 'formal',
  PROFESSIONAL = 'professional',
  CASUAL = 'casual',
  FRIENDLY = 'friendly',
  HUMOROUS = 'humorous'
}
```

### Brand Voice

```typescript
enum BrandVoice {
  AUTHORITATIVE = 'authoritative',
  PROFESSIONAL = 'professional',
  FRIENDLY = 'friendly',
  PLAYFUL = 'playful',
  INSPIRATIONAL = 'inspirational',
  EDUCATIONAL = 'educational',
  CONVERSATIONAL = 'conversational'
}
```

### Visual Atmosphere

```typescript
enum VisualAtmosphere {
  CHAOTIC = 'chaotic',
  STERILE_CLEAN = 'sterile_clean',
  WARM_HOMEY = 'warm_homey',
  PROFESSIONAL = 'professional',
  PLAYFUL = 'playful',
  DRAMATIC = 'dramatic',
  MINIMALIST = 'minimalist'
}
```

---

## Poznámky k implementaci

### Priorita komponent (MVP)

1. **P0 (Must have):**
   - Button, Input, Select, Badge, Card, Toast, Dialog
   - MainNav, PageLayout, DataTable
   - OnboardingWizard, PersonaCard
   - ContentCalendar, TopicDetail
   - ApprovalDashboard

2. **P1 (Should have):**
   - BlogPostEditor, SocialPostEditor
   - VisualGenerator, MediaLibrary
   - AnalyticsDashboard

3. **P2 (Nice to have):**
   - VideoGenerator
   - Advanced analytics
   - Team management features

### Accessibility požadavky

- Všechny interaktivní elementy musí být keyboard accessible
- ARIA labels pro screen readers
- Focus management v modalech
- Color contrast minimálně 4.5:1
- Form validation messages propojené s inputy

### Performance guidelines

- Lazy loading pro feature moduly
- Virtual scrolling pro seznamy > 50 položek
- Image lazy loading
- Skeleton loading pro async data
- Debounce na search inputy (300ms)

---

*Dokument verze 1.0 — Prosinec 2025*
---

## 📊 IMPLEMENTATION STATUS - KOMPLETNÍ PŘEHLED

### 🎯 KRITICKÁ ZJIŠTĚNÍ

#### 1. **Angular Material NENÍ používán**

```
PLÁN:     Tailwind CSS + Angular Material
REALITA:  Tailwind CSS POUZE

package.json (realita):
{
  "@angular/core": "^19.0.6",          // ✅ Angular 19!
  "tailwindcss": "^3.4.0",             // ✅
  "@tailwindcss/forms": "^0.5.7",      // ✅
  // ❌ Žádný @angular/material
  // ❌ Žádný @angular/cdk
}
```

#### 2. **Angular 19.0.6 (ne 17+)**

- Dokument uvádí Angular 17+
- Realita: Angular **19.0.6** (novější verze!)
- Signals API plně dostupné a pravděpodobně používané

#### 3. **Většina Atomic Components NEEXISTUJE**

Z 15 atomic komponent z dokumentu existuje pouze ~33% (5 komponent).

---

## ✅ EXISTUJÍCÍ SHARED COMPONENTS

### Potvrzené komponenty v `shared/components/`

| Komponenta | Plán | Realita | Status |
|------------|------|---------|--------|
| **button/** | ✅ | ✅ | OK |
| **input/** | ✅ | ✅ | OK |
| **badge/** | ✅ | ✅ | OK |
| **card/** | ✅ | ✅ | OK |
| **loading-spinner/** | Spinner | ✅ | Jiné jméno |
| **toast/** | ❌ | ✅ | NAVÍC! |
| **modal/** | ❌ | ✅ | NAVÍC! |
| **status-badge/** | ❌ | ✅ | NAVÍC! |
| **company-switcher/** | ❌ | ✅ | NAVÍC! |
| **approval-actions/** | ❌ | ✅ | NAVÍC! |

**Skutečná struktura:**

```
src/app/shared/components/
├── button/
│   ├── button.component.ts
│   ├── button.component.html
│   └── button.component.css
├── input/
│   └── input.component.ts
├── badge/
│   └── badge.component.ts
├── card/
│   └── card.component.ts
├── loading-spinner/                    # ✅ Spinner component
│   └── loading-spinner.component.ts
├── toast/                              # ➕ NAVÍC!
│   └── toast.component.ts
├── modal/                              # ➕ NAVÍC!
│   └── modal.component.ts
├── status-badge/                       # ➕ NAVÍC!
│   └── status-badge.component.ts
├── company-switcher/                   # ➕ NAVÍC!
│   └── company-switcher.component.ts
└── approval-actions/                   # ➕ NAVÍC!
    └── approval-actions.component.ts
```

**Nové komponenty (nejsou v dokumentu):**

**Toast Component:**

```typescript
// shared/components/toast/toast.component.ts
@Component({
  selector: 'app-toast',
  standalone: true,
  template: `
    <div class="fixed top-4 right-4 z-50">
      @for (toast of toasts(); track toast.id) {
        <div [class]="getToastClass(toast.type)">
          {{ toast.message }}
        </div>
      }
    </div>
  `
})
export class ToastComponent {
  toasts = signal<Toast[]>([]);
  
  show(message: string, type: 'success' | 'error' | 'info') {
    // ...
  }
}
```

**Modal Component:**

```typescript
// shared/components/modal/modal.component.ts
@Component({
  selector: 'app-modal',
  standalone: true,
  template: `
    <div class="fixed inset-0 bg-black/50 z-40" (click)="close()">
      <div class="fixed inset-0 flex items-center justify-center p-4">
        <div class="bg-slate-800 rounded-xl p-6 max-w-2xl w-full">
          <ng-content></ng-content>
        </div>
      </div>
    </div>
  `
})
export class ModalComponent {
  @Output() closeModal = new EventEmitter();
}
```

**Status Badge Component:**

```typescript
// shared/components/status-badge/status-badge.component.ts
@Component({
  selector: 'app-status-badge',
  standalone: true,
  template: `
    <span [class]="getBadgeClass()">
      {{ status }}
    </span>
  `
})
export class StatusBadgeComponent {
  @Input() status: 'pending' | 'processing' | 'completed' | 'failed';
}
```

**Company Switcher Component:**

```typescript
// shared/components/company-switcher/company-switcher.component.ts
@Component({
  selector: 'app-company-switcher',
  standalone: true,
  template: `
    <button (click)="toggleDropdown()">
      {{ currentCompany()?.name }}
    </button>
    @if (isOpen()) {
      <div class="dropdown">
        @for (company of companies(); track company.id) {
          <div (click)="selectCompany(company)">
            {{ company.name }}
          </div>
        }
      </div>
    }
  `
})
export class CompanySwitcherComponent {
  currentCompany = signal<Company | null>(null);
  companies = signal<Company[]>([]);
}
```

**Approval Actions Component:**

```typescript
// shared/components/approval-actions/approval-actions.component.ts
@Component({
  selector: 'app-approval-actions',
  standalone: true,
  template: `
    <div class="flex gap-2">
      <button (click)="onApprove()" class="btn-success">
        Approve
      </button>
      <button (click)="onReject()" class="btn-danger">
        Reject
      </button>
    </div>
  `
})
export class ApprovalActionsComponent {
  @Output() approve = new EventEmitter();
  @Output() reject = new EventEmitter();
}
```

---

## ❌ NEEXISTUJÍCÍ ATOMIC COMPONENTS (z dokumentu)

Tyto komponenty jsou v dokumentu, ale **NEEXISTUJÍ v realitě**:

| Komponenta | Dokument | Realita |
|------------|----------|---------|
| **TextareaComponent** | ✅ Detailní spec | ❌ Neexistuje |
| **SelectComponent** | ✅ Detailní spec | ❌ Neexistuje |
| **CheckboxComponent** | ✅ Detailní spec | ❌ Neexistuje |
| **ToggleComponent** | ✅ Detailní spec | ❌ Neexistuje |
| **RadioGroupComponent** | ✅ Detailní spec | ❌ Neexistuje |
| **AvatarComponent** | ✅ Detailní spec | ❌ Neexistuje |
| **IconComponent** | ✅ Detailní spec | ❌ Neexistuje |
| **TooltipDirective** | ✅ Detailní spec | ❌ Neexistuje |
| **ChipComponent** | ✅ Detailní spec | ❌ Neexistuje |
| **ProgressBarComponent** | ✅ Detailní spec | ❌ Neexistuje |
| **SkeletonComponent** | ✅ Detailní spec | ❌ Neexistuje |

**Proč tyto komponenty chybí?**

- Možná používají native HTML elements s Tailwind
- Možná nejsou potřeba pro MVP
- Možná budou implementovány později

**Příklad native approach (pravděpodobná realita):**

```html
<!-- Místo custom SelectComponent: -->
<select class="form-select rounded-lg bg-slate-800 border-slate-600">
  <option>Option 1</option>
</select>

<!-- Místo custom CheckboxComponent: -->
<input type="checkbox" class="form-checkbox text-blue-500">

<!-- Místo custom ChipComponent: -->
<span class="inline-block px-3 py-1 bg-blue-500 rounded-full text-sm">
  Chip
</span>
```

---

## ✅ EXISTUJÍCÍ FEATURE MODULES

### Potvrzené moduly v `src/app/`

| Modul | Plán | Realita | Status |
|-------|------|---------|--------|
| **onboarding/** | ✅ | ✅ | OK |
| **companies/** | ✅ | ✅ | OK |
| **personas/** | ✅ | ✅ | OK |
| **content/** | ✅ (3 separátní) | ✅ (1 modul) | Jiná struktura |
| **settings/** | ✅ | ✅ | OK |
| **auth/** | ❌ | ✅ | NAVÍC! |
| **dashboard/** | ❌ | ✅ | NAVÍC! |
| **landing/** | ❌ | ✅ | NAVÍC! |

**Skutečná struktura:**

```
src/app/
├── auth/                               # ➕ NAVÍC!
│   ├── login/
│   ├── register/
│   └── auth.service.ts
├── dashboard/                          # ➕ NAVÍC!
│   └── dashboard.component.ts
├── landing/                            # ➕ NAVÍC!
│   └── landing.component.ts
├── onboarding/                         # ✅
│   ├── step1/
│   ├── step2/
│   └── step3/
├── companies/                          # ✅
│   ├── company-list/
│   ├── company-create/
│   └── company-detail/
├── personas/                           # ✅
│   ├── persona-list/
│   ├── persona-card/
│   └── persona-select/
├── content/                            # ✅ (1 modul, ne 3!)
│   ├── topic-list/
│   ├── blogpost-editor/
│   ├── social-posts/
│   └── content-calendar/
└── settings/                           # ✅
    ├── profile/
    ├── billing/
    └── team/
```

**Nové moduly (nejsou v dokumentu):**

**Auth Module:**

```typescript
// app/auth/login/login.component.ts
@Component({
  selector: 'app-login',
  standalone: true,
  imports: [ReactiveFormsModule],
  template: `
    <form [formGroup]="loginForm" (ngSubmit)="onSubmit()">
      <app-input 
        formControlName="email" 
        type="email" 
        label="Email"
      />
      <app-input 
        formControlName="password" 
        type="password" 
        label="Password"
      />
      <app-button 
        type="submit" 
        [loading]="loading()"
      >
        Sign In
      </app-button>
    </form>
  `
})
export class LoginComponent {
  loginForm = this.fb.group({
    email: ['', [Validators.required, Validators.email]],
    password: ['', Validators.required]
  });
  
  loading = signal(false);
}
```

**Dashboard Module:**

```typescript
// app/dashboard/dashboard.component.ts
@Component({
  selector: 'app-dashboard',
  standalone: true,
  template: `
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
      <app-card>
        <h3>Active Personas</h3>
        <p class="text-3xl">{{ stats().personas }}</p>
      </app-card>
      
      <app-card>
        <h3>Published Posts</h3>
        <p class="text-3xl">{{ stats().posts }}</p>
      </app-card>
      
      <app-card>
        <h3>Pending Approval</h3>
        <p class="text-3xl">{{ stats().pending }}</p>
      </app-card>
    </div>
  `
})
export class DashboardComponent {
  stats = signal({
    personas: 0,
    posts: 0,
    pending: 0
  });
}
```

**Landing Module:**

```typescript
// app/landing/landing.component.ts
@Component({
  selector: 'app-landing',
  standalone: true,
  template: `
    <div class="min-h-screen bg-gradient-to-br from-slate-900 to-slate-800">
      <nav>
        <a routerLink="/auth/login">Sign In</a>
      </nav>
      
      <section class="hero">
        <h1>AI-Powered Content Marketing</h1>
        <p>Generate personas, topics, and posts automatically</p>
        <app-button routerLink="/auth/register" variant="gradient">
          Start Free Trial
        </app-button>
      </section>
    </div>
  `
})
export class LandingComponent {}
```

---

## ❌ NEEXISTUJÍCÍ FEATURE MODULES (z dokumentu)

Tyto moduly jsou v dokumentu, ale **NEEXISTUJÍ v realitě**:

| Modul | Dokument | Realita | Důvod |
|-------|----------|---------|-------|
| **Media Factory** | ✅ Detailní spec | ❌ | Image/Video gen není aktivní |
| **Approval Center** | ✅ Detailní spec | ❌ | Jen approval-actions component |
| **Analytics** | ✅ Detailní spec | ❌ | Není implementováno |
| **Subscription** | ✅ Detailní spec | ❌ | Možná v settings/billing |
| **User Management** | ✅ Detailní spec | ❌ | Není implementováno |

**Proč tyto moduly chybí?**

- **Media Factory** - Nanobana/Veo není aktivní (Phase later)
- **Approval Center** - Content API není implementováno (Phase 6-7)
- **Analytics** - Není priorita pro MVP
- **Subscription** - Možná integrováno do settings/billing
- **User Management** - Možná v settings/team

---

## 🏗️ LAYOUTS STRUKTURA

### Plán vs Realita

**PLÁN:**

```
shared/components/page-layout/page-layout.component.ts
```

**REALITA:**

```
src/app/layouts/
├── auth-layout/                        # ➕ NAVÍC!
│   └── auth-layout.component.ts
└── main-layout/                        # ➕ NAVÍC!
    └── main-layout.component.ts
```

**Auth Layout (realita):**

```typescript
// layouts/auth-layout/auth-layout.component.ts
@Component({
  selector: 'app-auth-layout',
  standalone: true,
  template: `
    <div class="min-h-screen flex">
      <!-- Left side - Branding -->
      <div class="hidden lg:flex lg:w-1/2 bg-gradient-to-br from-blue-600 to-purple-600">
        <div class="flex flex-col justify-center p-12">
          <h1 class="text-4xl font-bold text-white mb-4">
            PostHub.work
          </h1>
          <p class="text-xl text-white/80">
            AI-Powered Content Marketing Platform
          </p>
        </div>
      </div>
      
      <!-- Right side - Content -->
      <div class="flex-1 flex items-center justify-center p-8">
        <div class="w-full max-w-md">
          <router-outlet></router-outlet>
        </div>
      </div>
    </div>
  `
})
export class AuthLayoutComponent {}
```

**Main Layout (realita):**

```typescript
// layouts/main-layout/main-layout.component.ts
@Component({
  selector: 'app-main-layout',
  standalone: true,
  imports: [CompanySwitcherComponent],
  template: `
    <div class="min-h-screen bg-slate-900">
      <!-- Top Nav -->
      <nav class="bg-slate-800 border-b border-slate-700">
        <div class="flex items-center justify-between p-4">
          <div class="flex items-center gap-4">
            <h1>PostHub</h1>
            <app-company-switcher />
          </div>
          
          <div class="flex items-center gap-4">
            <!-- User menu -->
          </div>
        </div>
      </nav>
      
      <!-- Sidebar + Content -->
      <div class="flex">
        <!-- Sidebar -->
        <aside class="w-64 bg-slate-800 min-h-screen">
          <nav class="p-4">
            <a routerLink="/dashboard">Dashboard</a>
            <a routerLink="/personas">Personas</a>
            <a routerLink="/content">Content</a>
            <a routerLink="/settings">Settings</a>
          </nav>
        </aside>
        
        <!-- Main Content -->
        <main class="flex-1 p-6">
          <router-outlet></router-outlet>
        </main>
      </div>
    </div>
  `
})
export class MainLayoutComponent {}
```

**Routing s layouts:**

```typescript
// app.routes.ts
export const routes: Routes = [
  {
    path: '',
    component: LandingComponent
  },
  {
    path: 'auth',
    component: AuthLayoutComponent,
    children: [
      { path: 'login', component: LoginComponent },
      { path: 'register', component: RegisterComponent }
    ]
  },
  {
    path: 'app',
    component: MainLayoutComponent,
    canActivate: [AuthGuard],
    children: [
      { path: 'dashboard', component: DashboardComponent },
      { path: 'personas', loadChildren: () => import('./personas/personas.routes') },
      { path: 'companies', loadChildren: () => import('./companies/companies.routes') },
      { path: 'content', loadChildren: () => import('./content/content.routes') },
      { path: 'settings', loadChildren: () => import('./settings/settings.routes') }
    ]
  }
];
```

---

## 📝 APPENDIX - ENUMS (ROZDÍLY)

### SubscriptionTier

**PLÁN:**

```typescript
export enum SubscriptionTier {
  TRIAL = 'trial',
  BASIC = 'basic',
  PRO = 'pro',
  ULTIMATE = 'ultimate'
}
```

**REALITA:**

```typescript
export enum SubscriptionTier {
  // ❌ TRIAL neexistuje v platebním systému
  BASIC = 'basic',
  PRO = 'pro',
  ENTERPRISE = 'enterprise'  // ❌ Ne ULTIMATE!
}
```

### UserRole

**PLÁN:**

```typescript
export enum UserRole {
  ADMIN = 'ADMIN',
  MANAGER = 'MANAGER',
  MARKETER = 'MARKETER',
  SUPERVISOR = 'SUPERVISOR'
}
```

**REALITA:**

```typescript
export enum UserRole {
  // ✅ lowercase, ne UPPERCASE!
  ADMIN = 'admin',
  MANAGER = 'manager',
  MARKETER = 'marketer',
  SUPERVISOR = 'supervisor'
}
```

### SocialPlatform

**PLÁN:**

```typescript
export enum SocialPlatform {
  FACEBOOK = 'facebook',
  INSTAGRAM = 'instagram',
  LINKEDIN = 'linkedin',
  TWITTER = 'twitter',
  TIKTOK = 'tiktok',
  YOUTUBE = 'youtube',      // ❌
  PINTEREST = 'pinterest'   // ❌
}
```

**REALITA:**

```typescript
export enum SocialPlatform {
  FACEBOOK = 'facebook',
  INSTAGRAM = 'instagram',
  LINKEDIN = 'linkedin',
  TWITTER = 'twitter',
  TIKTOK = 'tiktok'
  // ❌ Žádný YOUTUBE
  // ❌ Žádný PINTEREST
}
```

**Proč jen 5 platforem?**

- MVP focus na hlavní platformy
- YouTube/Pinterest možná později

---

## 📊 STATISTIKA KOMPONENT

### Atomic Components (Shared)

| Kategorie | Plán | Realita | Shoda |
|-----------|------|---------|-------|
| **Form Components** | 8 | 2 | 25% |
| **Button/Badge** | 3 | 3 | 100% |
| **Display Components** | 4 | 7 | 175% (více!) |
| **CELKEM** | 15 | ~10 | 67% |

**Co existuje:**
✅ Button, Input, Badge, Card, Loading Spinner
✅ Toast, Modal, Status Badge, Company Switcher, Approval Actions (NAVÍC!)

**Co chybí:**
❌ Textarea, Select, Checkbox, Toggle, Radio Group
❌ Avatar, Icon, Tooltip, Chip
❌ Progress Bar, Skeleton

### Feature Modules

| Kategorie | Plán | Realita | Shoda |
|-----------|------|---------|-------|
| **Core Modules** | 8 | 8 | 100% |
| **Content API** | 3 | 1 | 33% |
| **Advanced** | 5 | 0 | 0% |
| **CELKEM** | 16 | 9 | 56% |

**Co existuje:**
✅ Onboarding, Companies, Personas, Content (combined), Settings
✅ Auth, Dashboard, Landing (NAVÍC!)

**Co chybí:**
❌ Media Factory, Approval Center, Analytics
❌ Subscription (standalone), User Management

---

## 🎯 IMPLEMENTATION STATUS SUMMARY

### ✅ CO JE IMPLEMENTOVÁNO (HIGH CONFIDENCE)

1. **Core Shared Components:**
   - ✅ Button, Input, Badge, Card
   - ✅ Loading Spinner
   - ✅ Toast, Modal, Status Badge
   - ✅ Company Switcher, Approval Actions

2. **Core Feature Modules:**
   - ✅ Auth (login, register)
   - ✅ Dashboard
   - ✅ Landing page
   - ✅ Onboarding flow
   - ✅ Companies management
   - ✅ Personas management
   - ✅ Content (unified module)
   - ✅ Settings

3. **Layouts:**
   - ✅ Auth Layout
   - ✅ Main Layout

4. **Routing:**
   - ✅ Lazy loading
   - ✅ Route guards
   - ✅ Nested routes

### ❌ CO NENÍ IMPLEMENTOVÁNO

1. **Missing Atomic Components (~67%):**
   - Textarea, Select, Checkbox, Toggle, Radio
   - Avatar, Icon component, Tooltip
   - Chip, Progress Bar, Skeleton

2. **Missing Feature Modules:**
   - Media Factory (image/video gen)
   - Approval Center (dedicated module)
   - Analytics dashboard
   - Subscription management (standalone)
   - User Management (admin panel)

3. **Missing Features:**
   - Angular Material (nikdy nebylo)
   - Content API Phase 6-7 modules

### 🔄 CO JE JINAK

| Co | Plán | Realita |
|----|------|---------|
| **Angular version** | 17+ | 19.0.6 |
| **Material** | Ano | Ne |
| **Content modules** | 3 separátní | 1 unified |
| **PageLayout** | Component | Layouts folder |
| **Tier ULTIMATE** | ✅ | ❌ ENTERPRISE |
| **UserRole case** | UPPERCASE | lowercase |
| **Platforms** | 7 | 5 |

---

## 💡 DOPORUČENÍ PRO DOKUMENTACI

### ✅ Co aktualizovat

**1. Header:**

- ❌ Odstranit "Angular Material"
- ✅ Změnit "Angular 17+" → "Angular 19.0.6"
- ✅ Změnit styling na "Tailwind CSS only"

**2. Atomic Components:**

- ❌ Odstranit neexistující (Textarea, Select, Checkbox, atd.)
- ✅ Přidat existující navíc (Toast, Modal, Status Badge, atd.)
- ⚠️ Nebo označit neexistující jako "Planned"

**3. Layouts:**

- ❌ Přepsat PageLayout component
- ✅ Přidat AuthLayout a MainLayout
- ✅ Vysvětlit routing s layouts

**4. Feature Modules:**

- ❌ Odstranit nebo označit jako "Planned":
  - Media Factory
  - Approval Center
  - Analytics
  - Subscription (standalone)
  - User Management
- ✅ Přidat existující navíc:
  - Auth module
  - Dashboard module
  - Landing module

**5. Appendix Enums:**

- ❌ Odstranit TRIAL tier
- ❌ Změnit ULTIMATE → ENTERPRISE
- ❌ Změnit UserRole na lowercase
- ❌ Odstranit YOUTUBE, PINTEREST

**6. Package.json:**

```json
// Aktualizovat dependencies:
{
  "@angular/core": "^19.0.6",
  "tailwindcss": "^3.4.0",
  "@tailwindcss/forms": "^0.5.7"
  // ❌ Odstranit @angular/material
  // ❌ Odstranit @angular/cdk
}
```

---

## 📁 SKUTEČNÁ STRUKTURA (Shrnutí)

```
src/app/
├── layouts/                            # ➕ NAVÍC (ne PageLayout component)
│   ├── auth-layout/
│   └── main-layout/
│
├── shared/
│   └── components/
│       ├── button/                     # ✅
│       ├── input/                      # ✅
│       ├── badge/                      # ✅
│       ├── card/                       # ✅
│       ├── loading-spinner/            # ✅
│       ├── toast/                      # ➕ NAVÍC
│       ├── modal/                      # ➕ NAVÍC
│       ├── status-badge/               # ➕ NAVÍC
│       ├── company-switcher/           # ➕ NAVÍC
│       └── approval-actions/           # ➕ NAVÍC
│
├── auth/                               # ➕ NAVÍC
│   ├── login/
│   └── register/
│
├── dashboard/                          # ➕ NAVÍC
├── landing/                            # ➕ NAVÍC
│
├── onboarding/                         # ✅
├── companies/                          # ✅
├── personas/                           # ✅
├── content/                            # ✅ (unified, ne 3 separátní)
└── settings/                           # ✅

# ❌ CHYBÍ:
# - Media Factory
# - Approval Center (jen approval-actions component)
# - Analytics
# - Subscription (standalone)
# - User Management
```

---

*Tento dokument nyní obsahuje KOMPLETNÍ informace o plánovaných komponentách I skutečném stavu implementace.*
