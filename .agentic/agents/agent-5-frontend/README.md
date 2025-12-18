# Agent 5 - Frontend

## Zodpovednost

Angular 19 SPA, Standalone components, NgRx Signal Store, API integration, UI/UX implementation

---

## Tech Stack (REALITA!)

| Technologie | Verze | Poznamka |
|-------------|-------|----------|
| **Angular** | 19.0.6 | NE 17! |
| **Tailwind CSS** | 3.4+ | HLAVNI styling |
| **@tailwindcss/forms** | 0.5.7 | Form styling |
| **@ngrx/signals** | 19 | State management |
| **TypeScript** | 5.x | Strict mode |
| **Node.js** | 20 | Runtime |
| **Jest** | - | Unit tests (NE Karma!) |
| **Playwright** | - | E2E tests |

### KRITICKE ROZDILY OD DOKUMENTACE

| Aspekt | Dokumentace | REALITA |
|--------|-------------|---------|
| Angular verze | 17+ | **19.0.6** |
| UI knihovna | Angular Material | **POUZE Tailwind CSS!** |
| @angular/material | ^17.0.0 | **NEEXISTUJE** |
| @angular/cdk | ^17.0.0 | **NEEXISTUJE** |
| Test runner | Karma/Jasmine | **Jest** |

**PROC BEZ ANGULAR MATERIAL:**
- Mensi bundle size
- Plna kontrola nad designem
- Konzistence s Tailwind-first pristupem
- Mene zavislosti = mene maintenance

---

## Design System

**PostHub Visual Book v3.0**

### Barevna paleta (Dark Theme)

```css
/* Background */
--bg-primary: rgba(15, 23, 42, 1);     /* #0F172A */
--bg-secondary: rgba(30, 41, 59, 0.6);
--bg-card: linear-gradient(145deg, rgba(30,41,59,0.6) 0%, rgba(15,23,42,0.8) 100%);

/* Accent (Gradient) */
--accent-violet: #8b5cf6;
--accent-blue: #3b82f6;
--accent-cyan: #06b6d4;
--accent-green: #10b981;

/* Text */
--text-primary: rgba(255, 255, 255, 0.95);
--text-secondary: rgba(148, 163, 184, 1);
--text-muted: rgba(100, 116, 139, 1);

/* Borders */
--border-subtle: rgba(148, 163, 184, 0.1);
--border-accent: rgba(59, 130, 246, 0.5);
```

### Component Styling Pattern

```css
/* Card Glass Effect */
.card {
  background: linear-gradient(145deg, rgba(30,41,59,0.6) 0%, rgba(15,23,42,0.8) 100%);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(148, 163, 184, 0.1);
  border-radius: 24px;
}

/* Button Primary */
.btn-primary {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
  box-shadow: 0 4px 15px rgba(59, 130, 246, 0.4);
}

/* Button Gradient (Premium) */
.btn-gradient {
  background: linear-gradient(135deg, #8b5cf6 0%, #3b82f6 35%, #06b6d4 65%, #10b981 100%);
}

/* Input Focus */
.input:focus {
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.2);
}
```

---

## Project Structure

```
frontend/src/app/
├── core/
│   ├── components/          # Shared layout (MainNav, Header)
│   ├── guards/              # Auth guards
│   ├── interceptors/        # HTTP interceptors
│   ├── services/            # Core services (Auth, HTTP)
│   └── stores/              # NgRx Signal Stores
│       ├── auth.store.ts
│       ├── company.store.ts
│       ├── content.store.ts
│       └── notification.store.ts
├── data/
│   ├── models/              # TypeScript interfaces
│   └── services/            # API services
│       ├── auth.service.ts
│       ├── company.service.ts
│       ├── content.service.ts
│       └── ai.service.ts
├── features/
│   ├── auth/                # Login, Register, Forgot Password
│   ├── onboarding/          # Company setup wizard
│   ├── dashboard/           # Main dashboard
│   ├── companies/           # Company management
│   ├── personas/            # Persona builder
│   ├── content-planner/     # Topics, Blog Posts, Social Posts
│   ├── approval-center/     # Content approval workflow
│   ├── analytics/           # Stats and reports
│   ├── settings/            # User/Company settings
│   └── billing/             # Subscription management
├── shared/
│   ├── components/          # Reusable UI components (33+)
│   │   ├── button/
│   │   ├── input/
│   │   ├── select/
│   │   ├── card/
│   │   ├── badge/
│   │   ├── dialog/
│   │   ├── toast/
│   │   ├── data-table/
│   │   ├── pagination/
│   │   └── ...
│   ├── directives/          # phTooltip, phAutoFocus
│   └── pipes/               # dateFormat, truncate
└── app.routes.ts            # Lazy-loaded routes
```

---

## NgRx Signal Store Pattern

```typescript
// stores/content.store.ts

import { signalStore, withState, withComputed, withMethods, patchState } from '@ngrx/signals';

interface ContentState {
  topics: Topic[];
  blogPosts: BlogPost[];
  socialPosts: SocialPost[];
  stats: ContentStats | null;
  pendingCounts: PendingCounts | null;
  currentCompanyId: string | null;
  loading: boolean;
  error: string | null;
}

const initialState: ContentState = {
  topics: [],
  blogPosts: [],
  socialPosts: [],
  stats: null,
  pendingCounts: null,
  currentCompanyId: null,
  loading: false,
  error: null,
};

export const ContentStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),

  withComputed(({ topics, blogPosts, socialPosts }) => ({
    draftTopics: computed(() => topics().filter(t => t.status === 'draft')),
    approvedBlogPosts: computed(() => blogPosts().filter(b => b.status === 'approved')),
    publishedSocialPosts: computed(() => socialPosts().filter(s => s.status === 'published')),
    scheduledSocialPosts: computed(() => socialPosts().filter(s => s.scheduledAt != null)),
    totalPendingApprovals: computed(() =>
      topics().filter(t => t.status === 'pending_approval').length +
      blogPosts().filter(b => b.status === 'pending_approval').length +
      socialPosts().filter(s => s.status === 'pending_approval').length
    ),
  })),

  withMethods((store, contentService = inject(ContentService)) => ({
    async loadTopics(companyId: string) {
      patchState(store, { loading: true, currentCompanyId: companyId });
      try {
        const topics = await firstValueFrom(contentService.getTopics(companyId));
        patchState(store, { topics, loading: false });
      } catch (error) {
        patchState(store, { error: 'Nepodařilo se načíst témata', loading: false });
      }
    },

    async createTopic(companyId: string, data: CreateTopicData) {
      patchState(store, { loading: true });
      try {
        const topic = await firstValueFrom(contentService.createTopic(companyId, data));
        patchState(store, {
          topics: [...store.topics(), topic],
          loading: false
        });
        return topic;
      } catch (error) {
        patchState(store, { error: 'Nepodařilo se vytvořit téma', loading: false });
        throw error;
      }
    },

    // ... 30+ more methods
  }))
);
```

---

## Component Pattern (Standalone, OnPush)

```typescript
// features/content-planner/content-planner.component.ts

import { Component, ChangeDetectionStrategy, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { ContentStore } from '@core/stores/content.store';
import { CompanyStore } from '@core/stores/company.store';

@Component({
  selector: 'app-content-planner',
  standalone: true,
  imports: [CommonModule, RouterModule, TopicCardComponent, ...],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="container mx-auto px-4 py-8">
      <header class="flex justify-between items-center mb-8">
        <h1 class="text-2xl font-bold text-white">Content Planner</h1>
        <button class="btn btn-primary" (click)="createTopic()">
          + New Topic
        </button>
      </header>

      @if (contentStore.loading()) {
        <app-loading-spinner />
      } @else {
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          @for (topic of contentStore.topics(); track topic.id) {
            <app-topic-card [topic]="topic" (approve)="approveTopic($event)" />
          }
        </div>
      }
    </div>
  `
})
export class ContentPlannerComponent {
  protected readonly contentStore = inject(ContentStore);
  protected readonly companyStore = inject(CompanyStore);

  createTopic() {
    // Dialog logic
  }

  approveTopic(topicId: string) {
    this.contentStore.approveTopic(this.companyStore.currentCompanyId()!, topicId);
  }
}
```

---

## API Service Pattern

```typescript
// data/services/content.service.ts

@Injectable({ providedIn: 'root' })
export class ContentService {
  private http = inject(HttpClient);
  private baseUrl = '/api/v1/content';

  // Topics
  getTopics(companyId: string): Observable<Topic[]> {
    return this.http.get<ApiResponse<Topic[]>>(`${this.baseUrl}/topics/`, {
      params: { companyId }
    }).pipe(map(res => res.data));
  }

  createTopic(companyId: string, data: CreateTopicData): Observable<Topic> {
    return this.http.post<ApiResponse<Topic>>(`${this.baseUrl}/topics/`, data, {
      params: { companyId }
    }).pipe(map(res => res.data));
  }

  approveTopic(companyId: string, topicId: string): Observable<Topic> {
    return this.http.post<ApiResponse<Topic>>(
      `${this.baseUrl}/topics/${topicId}/approve/`,
      {},
      { params: { companyId } }
    ).pipe(map(res => res.data));
  }

  // ... 40+ methods total
}
```

---

## Component Library (33+ komponent)

### Atomic Components
- ButtonComponent, InputComponent, TextareaComponent
- SelectComponent, CheckboxComponent, ToggleComponent
- RadioGroupComponent, BadgeComponent, AvatarComponent
- IconComponent, ChipComponent, ProgressBarComponent
- SpinnerComponent, SkeletonComponent

### Layout Components
- CardComponent, PageLayoutComponent, SidebarLayoutComponent
- GridComponent, DividerComponent, TabsComponent
- AccordionComponent, EmptyStateComponent

### Navigation Components
- MainNavComponent, BreadcrumbsComponent, DropdownMenuComponent
- PaginationComponent, StepperComponent

### Form Components
- FormFieldComponent, DatePickerComponent, TimePickerComponent
- FileUploadComponent, ColorPickerComponent, RichTextEditorComponent
- TagInputComponent, SliderComponent, SearchInputComponent

### Data Display Components
- DataTableComponent, ListComponent, StatCardComponent
- TimelineComponent, ChartComponent, CalendarViewComponent
- KanbanBoardComponent

### Feedback Components
- ToastService, DialogService, ConfirmDialogComponent
- AlertComponent, NotificationBellComponent, LoadingOverlayComponent

---

## Implemented Files

### ContentService (`content.service.ts` - 364 lines)

```
Topics: getTopics, getTopic, createTopic, updateTopic, deleteTopic,
        approveTopic, rejectTopic, submitTopicForApproval, getPendingTopics

BlogPosts: getBlogPosts, getBlogPost, getBlogPostBySlug, createBlogPost,
           updateBlogPost, deleteBlogPost, approveBlogPost, rejectBlogPost,
           submitBlogPostForApproval, publishBlogPost, getPendingBlogPosts

SocialPosts: getSocialPosts, getSocialPost, getSocialPostsForBlogPost,
             createSocialPost, updateSocialPost, deleteSocialPost,
             approveSocialPost, rejectSocialPost, submitSocialPostForApproval,
             publishSocialPost, getPendingSocialPosts, getScheduledSocialPosts

Stats: getContentStats, getPendingApprovals, getCalendarEvents

AI: regenerateTopic, regenerateBlogPost, regenerateSocialPost
```

### ContentStore (`content.store.ts` - 597 lines)

State, computed signals, and 30+ methods matching ContentService.

---

## API Integration Rules

```typescript
// SPRAVNE - companyId jako query parameter
this.http.get('/api/v1/content/topics/', {
  params: { companyId: this.companyStore.currentCompanyId() }
});

// SPATNE - company v URL path
this.http.get(`/api/v1/companies/${companyId}/topics/`); // ❌
```

**API URL Pattern:**
- Base: `/api/v1/content/`
- Query param: `?companyId=uuid`
- Tenant isolation zajistena na backendu

---

## CheckAgent Requirements

### ZAKAZANO
- Angular Material imports
- @angular/cdk imports
- Karma/Jasmine test configs
- console.log v production
- `any` type bez komentare

### POVINNE
- Standalone components
- ChangeDetectionStrategy.OnPush
- inject() misto constructor injection
- Tailwind CSS for styling
- NgRx Signal Store for state
- firstValueFrom pro async/await
- Czech error messages

---

## Documentation Reference

- `files/05_FRONTEND_ANGULAR.md` - Frontend patterns
- `files/13_FRONTEND_COMPONENTS.md` - Component specs
- `files/10_API_CONTRACTS.md` - API response format

---

## Completed Tasks

### TASK-008: Frontend Content API Integration
**Status:** COMPLETED
**Date:** 2025-12-18
**Files:** `content.service.ts` (364 lines), `content.store.ts` (597 lines)

---

## Current Task

**COMPLETED** - Frontend API integration is done

---

**|**

## CheckAgent Verification

### Status: PASS

### Kontrolovane oblasti
| Check | Status |
|-------|--------|
| Mock Data | PASS |
| Dummy Variables | PASS |
| TODO Komentare | PASS |
| Standalone Components | PASS |
| OnPush Change Detection | PASS |
| TypeScript Strict | PASS |
| Tailwind CSS (no Material) | PASS |
| Signal Store Pattern | PASS |
| API Integration | PASS |
| Tests | DEFERRED |

### Datum kontroly
2025-12-18
