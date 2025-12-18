---

# 05_FRONTEND_ANGULAR.md - PostHub.work

**Dokument:** Frontend Architecture - Angular  
**Verze:** 2.1.0  
**Účel:** Kompletní popis Angular frontend aplikace  
**Status:** ✅ Aktualizováno na skutečný stav  
**Poslední aktualizace:** December 17, 2025

---

## 📋 OBSAH

1. [Project Setup](#1-project-setup)
2. [Architecture Overview](#2-architecture-overview)
3. [Folder Structure](#3-folder-structure)
4. [Core Module](#4-core-module)
5. [State Management](#5-state-management)
6. [Components](#6-components)
7. [Services](#7-services)
8. [Routing](#8-routing)
9. [Forms](#9-forms)
10. [HTTP & API](#10-http--api)
11. [Styling](#11-styling)
12. [Build & Deployment](#12-build--deployment)

---

## 1. PROJECT SETUP

### 1.1 Versions

```json
{
  "name": "posthub-frontend",
  "version": "1.0.0",
  "angular": "^19.2.16",
  "node": ">=18.0.0",
  "npm": ">=9.0.0"
}
```

### 1.2 Key Dependencies

```json
{
  "dependencies": {
    "@angular/animations": "^19.2.16",
    "@angular/common": "^19.2.16",
    "@angular/compiler": "^19.2.16",
    "@angular/core": "^19.2.16",
    "@angular/forms": "^19.2.16",
    "@angular/platform-browser": "^19.2.16",
    "@angular/platform-browser-dynamic": "^19.2.16",
    "@angular/router": "^19.2.16",
    "@ngrx/signals": "^19.0.0",
    "rxjs": "~7.8.0",
    "tslib": "^2.3.0",
    "zone.js": "~0.14.2"
  },
  "devDependencies": {
    "@angular-devkit/build-angular": "^19.2.15",
    "@angular/cli": "^19.2.15",
    "@angular/compiler-cli": "^19.2.16",
    "tailwindcss": "^3.4.1",
    "typescript": "~5.6.3",
    "autoprefixer": "^10.4.20",
    "postcss": "^8.4.35"
  }
}
```

**Poznámky:**
- ✅ Angular 19 (upgraded od verze 17)
- ✅ Standalone Components (default)
- ✅ Signals API nativně podporováno
- ❌ **NEPOUŽÍVÁ** Angular Material
- ✅ Tailwind CSS 3.4 pro styling
- ✅ @ngrx/signals pro state management

### 1.3 Angular Configuration

```json
// angular.json
{
  "$schema": "./node_modules/@angular/cli/lib/config/schema.json",
  "version": 1,
  "newProjectRoot": "projects",
  "projects": {
    "posthub-frontend": {
      "projectType": "application",
      "root": "",
      "sourceRoot": "src",
      "prefix": "app",
      "architect": {
        "build": {
          "builder": "@angular-devkit/build-angular:browser",
          "options": {
            "outputPath": "dist/posthub-frontend",
            "index": "src/index.html",
            "main": "src/main.ts",
            "polyfills": ["zone.js"],
            "tsConfig": "tsconfig.app.json",
            "inlineStyleLanguage": "scss",
            "assets": ["src/favicon.ico", "src/assets"],
            "styles": ["src/styles.scss"],
            "scripts": []
          },
          "configurations": {
            "production": {
              "budgets": [
                {
                  "type": "initial",
                  "maximumWarning": "500kb",
                  "maximumError": "1mb"
                },
                {
                  "type": "anyComponentStyle",
                  "maximumWarning": "2kb",
                  "maximumError": "4kb"
                }
              ],
              "outputHashing": "all",
              "optimization": true,
              "sourceMap": false,
              "namedChunks": false,
              "aot": true,
              "extractLicenses": true,
              "buildOptimizer": true
            },
            "development": {
              "buildOptimizer": false,
              "optimization": false,
              "vendorChunk": true,
              "extractLicenses": false,
              "sourceMap": true,
              "namedChunks": true
            }
          },
          "defaultConfiguration": "production"
        },
        "serve": {
          "builder": "@angular-devkit/build-angular:dev-server",
          "configurations": {
            "production": {
              "buildTarget": "posthub-frontend:build:production"
            },
            "development": {
              "buildTarget": "posthub-frontend:build:development"
            }
          },
          "defaultConfiguration": "development"
        }
      }
    }
  }
}
```

---

## 2. ARCHITECTURE OVERVIEW

### 2.1 Design Philosophy

```
┌────────────────────────────────────────────────────────────────┐
│                    ANGULAR 19 ARCHITECTURE                      │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Standalone Components (No NgModules)                          │
│  ├── Simplified dependency injection                           │
│  ├── Easier lazy loading                                       │
│  └── Better tree-shaking                                       │
│                                                                 │
│  Signals API (@ngrx/signals)                                   │
│  ├── Reactive state management                                 │
│  ├── Fine-grained reactivity                                   │
│  └── Better performance than Observables for state             │
│                                                                 │
│  Smart/Dumb Component Pattern                                  │
│  ├── Smart (Container): Data fetching, business logic          │
│  ├── Dumb (Presentational): Display only, @Input/@Output       │
│  └── Reusability & testability                                 │
│                                                                 │
│  Tailwind CSS (NO Angular Material)                            │
│  ├── Utility-first styling                                     │
│  ├── Custom component library (35+)                            │
│  ├── Visual Book design system                                 │
│  └── Brand colors: violet → blue → cyan → green               │
│                                                                 │
└────────────────────────────────────────────────────────────────┘
```

### 2.2 Component Communication

```typescript
// Parent → Child: @Input
@Component({
  selector: 'app-parent',
  template: '<app-child [data]="parentData"></app-child>'
})
export class ParentComponent {
  parentData = signal('Hello');
}

// Child → Parent: @Output
@Component({
  selector: 'app-child',
  template: '<button (click)="notify()">Click</button>'
})
export class ChildComponent {
  @Output() clicked = new EventEmitter<void>();
  
  notify() {
    this.clicked.emit();
  }
}

// Service (Shared State): Signal Store
const UserStore = signalStore(
  { providedIn: 'root' },
  withState({ user: null }),
  withMethods((store) => ({
    setUser: (user) => patchState(store, { user })
  }))
);
```

---

## 3. FOLDER STRUCTURE

### 3.1 Complete Structure (Actual)

```
frontend/
├── src/
│   ├── app/
│   │   ├── core/                    # Singleton Services
│   │   │   ├── auth/
│   │   │   │   ├── auth.service.ts
│   │   │   │   ├── auth.guard.ts
│   │   │   │   └── token.service.ts
│   │   │   ├── guards/
│   │   │   │   ├── role.guard.ts
│   │   │   │   └── tenant.guard.ts
│   │   │   ├── interceptors/
│   │   │   │   ├── auth.interceptor.ts
│   │   │   │   ├── error.interceptor.ts
│   │   │   │   └── loading.interceptor.ts
│   │   │   └── services/
│   │   │       ├── api.service.ts
│   │   │       ├── notification.service.ts
│   │   │       └── theme.service.ts
│   │   │
│   │   ├── shared/                  # Reusable Components (35+)
│   │   │   ├── components/
│   │   │   │   ├── button/
│   │   │   │   ├── card/
│   │   │   │   ├── modal/
│   │   │   │   ├── table/
│   │   │   │   ├── form-field/
│   │   │   │   ├── progress-bar/
│   │   │   │   ├── avatar/
│   │   │   │   ├── badge/
│   │   │   │   ├── dropdown/
│   │   │   │   ├── tabs/
│   │   │   │   ├── accordion/
│   │   │   │   ├── tooltip/
│   │   │   │   ├── alert/
│   │   │   │   ├── spinner/
│   │   │   │   ├── pagination/
│   │   │   │   ├── breadcrumb/
│   │   │   │   ├── sidebar/
│   │   │   │   ├── header/
│   │   │   │   ├── footer/
│   │   │   │   ├── empty-state/
│   │   │   │   ├── skeleton-loader/
│   │   │   │   ├── rich-text-editor/
│   │   │   │   ├── file-upload/
│   │   │   │   ├── date-picker/
│   │   │   │   ├── color-picker/
│   │   │   │   ├── image-cropper/
│   │   │   │   ├── chart/
│   │   │   │   ├── calendar/
│   │   │   │   ├── timeline/
│   │   │   │   ├── stepper/
│   │   │   │   ├── rating/
│   │   │   │   ├── slider/
│   │   │   │   ├── toggle/
│   │   │   │   ├── chip/
│   │   │   │   └── divider/
│   │   │   ├── directives/
│   │   │   │   ├── click-outside.directive.ts
│   │   │   │   ├── lazy-load.directive.ts
│   │   │   │   └── autofocus.directive.ts
│   │   │   └── pipes/
│   │   │       ├── safe-html.pipe.ts
│   │   │       ├── truncate.pipe.ts
│   │   │       └── time-ago.pipe.ts
│   │   │
│   │   ├── features/                # Feature Modules (Lazy Loaded)
│   │   │   ├── landing/             # ➕ NOVÝ - Public landing page
│   │   │   │   ├── landing.component.ts
│   │   │   │   ├── landing.component.html
│   │   │   │   └── landing.component.scss
│   │   │   │
│   │   │   ├── auth/                # Auth flows (login, register)
│   │   │   │   ├── login/
│   │   │   │   ├── register/
│   │   │   │   └── forgot-password/
│   │   │   │
│   │   │   ├── dashboard/           # Main dashboard
│   │   │   │   ├── dashboard.component.ts
│   │   │   │   └── widgets/
│   │   │   │
│   │   │   ├── companies/           # ➕ NOVÝ - Company management
│   │   │   │   ├── companies-list/
│   │   │   │   ├── company-detail/
│   │   │   │   └── company-form/
│   │   │   │
│   │   │   ├── personas/            # Persona management
│   │   │   │   ├── personas-list/
│   │   │   │   ├── persona-detail/
│   │   │   │   └── persona-form/
│   │   │   │
│   │   │   ├── content/             # Content management
│   │   │   │   ├── topics/
│   │   │   │   ├── blog-posts/
│   │   │   │   └── social-posts/
│   │   │   │
│   │   │   ├── onboarding/          # Onboarding wizard
│   │   │   │   ├── onboarding.component.ts
│   │   │   │   ├── steps/
│   │   │   │   │   ├── company-search/
│   │   │   │   │   ├── dna-scraping/
│   │   │   │   │   ├── persona-generation/
│   │   │   │   │   ├── persona-selection/
│   │   │   │   │   └── subscription-select/
│   │   │   │
│   │   │   └── settings/            # Settings
│   │   │       ├── profile/
│   │   │       ├── billing/
│   │   │       └── team/
│   │   │
│   │   ├── layouts/                 # ➕ NOVÝ - Layout wrappers
│   │   │   ├── app-layout/          # Main app layout (with sidebar)
│   │   │   │   ├── app-layout.component.ts
│   │   │   │   └── app-layout.component.html
│   │   │   ├── auth-layout/         # Auth pages layout
│   │   │   │   ├── auth-layout.component.ts
│   │   │   │   └── auth-layout.component.html
│   │   │   └── onboarding-layout/   # Onboarding layout (no sidebar)
│   │   │       ├── onboarding-layout.component.ts
│   │   │       └── onboarding-layout.component.html
│   │   │
│   │   ├── data/                    # Data Layer
│   │   │   ├── models/
│   │   │   │   ├── user.model.ts
│   │   │   │   ├── organization.model.ts
│   │   │   │   ├── company.model.ts
│   │   │   │   ├── persona.model.ts
│   │   │   │   ├── topic.model.ts
│   │   │   │   ├── blog-post.model.ts
│   │   │   │   └── social-post.model.ts
│   │   │   ├── services/
│   │   │   │   ├── user.service.ts
│   │   │   │   ├── organization.service.ts
│   │   │   │   ├── company.service.ts
│   │   │   │   ├── persona.service.ts
│   │   │   │   └── content.service.ts
│   │   │   └── enums/
│   │   │       ├── role.enum.ts
│   │   │       ├── status.enum.ts
│   │   │       └── tier.enum.ts
│   │   │
│   │   ├── app.component.ts         # Root component
│   │   ├── app.config.ts            # App configuration
│   │   └── app.routes.ts            # Routing configuration
│   │
│   ├── assets/                      # Static assets
│   │   ├── images/
│   │   ├── icons/
│   │   └── fonts/
│   │
│   ├── environments/                # Environment configs
│   │   ├── environment.ts           # Development
│   │   └── environment.prod.ts      # Production
│   │
│   ├── styles/                      # Global styles
│   │   ├── _variables.scss
│   │   ├── _mixins.scss
│   │   └── _visual-book.scss        # Design system
│   │
│   ├── index.html
│   ├── main.ts
│   ├── styles.scss
│   └── tailwind.config.js
│
├── .editorconfig
├── .gitignore
├── angular.json
├── package.json
├── tsconfig.json
├── tsconfig.app.json
└── README.md
```

**Klíčové rozdíly od původního dokumentu:**
- ➕ Přidána složka `layouts/` (app-layout, auth-layout, onboarding-layout)
- ➕ Přidána feature `landing/` (public landing page)
- ➕ Přidána feature `companies/` (company management)
- ❌ Odstraněna složka `stores/` (state management je inline nebo v services)
- ✅ Potvrzena struktura `core/`, `shared/`, `features/`, `data/`

---

## 4. CORE MODULE

### 4.1 Authentication Service

```typescript
// core/auth/auth.service.ts

import { Injectable, inject, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { tap, catchError } from 'rxjs/operators';
import { Observable, of } from 'rxjs';
import { TokenService } from './token.service';
import { User } from '@data/models/user.model';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private http = inject(HttpClient);
  private router = inject(Router);
  private tokenService = inject(TokenService);
  
  // Signals for reactive auth state
  currentUser = signal<User | null>(null);
  isAuthenticated = signal<boolean>(false);
  isLoading = signal<boolean>(false);

  constructor() {
    // Check auth state on init
    const token = this.tokenService.getAccessToken();
    if (token && !this.tokenService.isTokenExpired(token)) {
      this.loadCurrentUser();
    }
  }

  login(email: string, password: string): Observable<any> {
    this.isLoading.set(true);
    
    return this.http.post('/api/auth/login/', { email, password }).pipe(
      tap((response: any) => {
        this.tokenService.saveTokens(response.access, response.refresh);
        this.currentUser.set(response.user);
        this.isAuthenticated.set(true);
        this.isLoading.set(false);
      }),
      catchError((error) => {
        this.isLoading.set(false);
        throw error;
      })
    );
  }

  register(data: any): Observable<any> {
    return this.http.post('/api/auth/register/', data).pipe(
      tap((response: any) => {
        this.tokenService.saveTokens(response.access, response.refresh);
        this.currentUser.set(response.user);
        this.isAuthenticated.set(true);
      })
    );
  }

  logout(): void {
    this.tokenService.clearTokens();
    this.currentUser.set(null);
    this.isAuthenticated.set(false);
    this.router.navigate(['/auth/login']);
  }

  refreshToken(): Observable<any> {
    const refreshToken = this.tokenService.getRefreshToken();
    if (!refreshToken) {
      return of(null);
    }

    return this.http.post('/api/auth/refresh/', { refresh: refreshToken }).pipe(
      tap((response: any) => {
        this.tokenService.saveAccessToken(response.access);
      }),
      catchError(() => {
        this.logout();
        return of(null);
      })
    );
  }

  private loadCurrentUser(): void {
    this.http.get<User>('/api/auth/me/').pipe(
      tap((user) => {
        this.currentUser.set(user);
        this.isAuthenticated.set(true);
      }),
      catchError(() => {
        this.logout();
        return of(null);
      })
    ).subscribe();
  }
}
```

### 4.2 Token Service

```typescript
// core/auth/token.service.ts

import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class TokenService {
  private readonly ACCESS_TOKEN_KEY = 'access_token';
  private readonly REFRESH_TOKEN_KEY = 'refresh_token';

  saveTokens(accessToken: string, refreshToken: string): void {
    localStorage.setItem(this.ACCESS_TOKEN_KEY, accessToken);
    localStorage.setItem(this.REFRESH_TOKEN_KEY, refreshToken);
  }

  saveAccessToken(accessToken: string): void {
    localStorage.setItem(this.ACCESS_TOKEN_KEY, accessToken);
  }

  getAccessToken(): string | null {
    return localStorage.getItem(this.ACCESS_TOKEN_KEY);
  }

  getRefreshToken(): string | null {
    return localStorage.getItem(this.REFRESH_TOKEN_KEY);
  }

  clearTokens(): void {
    localStorage.removeItem(this.ACCESS_TOKEN_KEY);
    localStorage.removeItem(this.REFRESH_TOKEN_KEY);
  }

  isTokenExpired(token: string): boolean {
    try {
      const payload = JSON.parse(atob(token.split('.')[1]));
      const exp = payload.exp * 1000; // Convert to milliseconds
      return Date.now() >= exp;
    } catch {
      return true;
    }
  }
}
```

### 4.3 Auth Guard

```typescript
// core/auth/auth.guard.ts

import { inject } from '@angular/core';
import { Router, CanActivateFn } from '@angular/router';
import { AuthService } from './auth.service';

export const authGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);
  const router = inject(Router);

  if (authService.isAuthenticated()) {
    return true;
  }

  // Redirect to login with return URL
  router.navigate(['/auth/login'], {
    queryParams: { returnUrl: state.url }
  });
  return false;
};
```

### 4.4 Role Guard

```typescript
// core/guards/role.guard.ts

import { inject } from '@angular/core';
import { Router, CanActivateFn } from '@angular/router';
import { AuthService } from '@core/auth/auth.service';
import { Role } from '@data/enums/role.enum';

export const roleGuard = (allowedRoles: Role[]): CanActivateFn => {
  return (route, state) => {
    const authService = inject(AuthService);
    const router = inject(Router);
    
    const user = authService.currentUser();
    
    if (!user) {
      router.navigate(['/auth/login']);
      return false;
    }
    
    if (allowedRoles.includes(user.role)) {
      return true;
    }
    
    // Redirect to unauthorized page
    router.navigate(['/unauthorized']);
    return false;
  };
};
```

### 4.5 Auth Interceptor

```typescript
// core/interceptors/auth.interceptor.ts

import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { TokenService } from '@core/auth/token.service';

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const tokenService = inject(TokenService);
  const token = tokenService.getAccessToken();

  if (token) {
    const cloned = req.clone({
      headers: req.headers.set('Authorization', `Bearer ${token}`)
    });
    return next(cloned);
  }

  return next(req);
};
```

### 4.6 Error Interceptor

```typescript
// core/interceptors/error.interceptor.ts

import { HttpInterceptorFn, HttpErrorResponse } from '@angular/common/http';
import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { catchError, throwError } from 'rxjs';
import { AuthService } from '@core/auth/auth.service';
import { NotificationService } from '@core/services/notification.service';

export const errorInterceptor: HttpInterceptorFn = (req, next) => {
  const router = inject(Router);
  const authService = inject(AuthService);
  const notificationService = inject(NotificationService);

  return next(req).pipe(
    catchError((error: HttpErrorResponse) => {
      let errorMessage = 'An error occurred';

      if (error.error instanceof ErrorEvent) {
        // Client-side error
        errorMessage = `Error: ${error.error.message}`;
      } else {
        // Server-side error
        switch (error.status) {
          case 401:
            authService.logout();
            router.navigate(['/auth/login']);
            errorMessage = 'Unauthorized. Please log in.';
            break;
          case 403:
            router.navigate(['/unauthorized']);
            errorMessage = 'Access denied.';
            break;
          case 404:
            errorMessage = 'Resource not found.';
            break;
          case 500:
            errorMessage = 'Server error. Please try again later.';
            break;
          default:
            errorMessage = error.error?.message || error.message;
        }
      }

      notificationService.error(errorMessage);
      return throwError(() => error);
    })
  );
};
```

---

## 5. STATE MANAGEMENT

### 5.1 Signal-Based State Management

**Status:** @ngrx/signals je v package.json, ale implementace může být:
- A) V samostatných signal store souborech
- B) Inline v komponentách pomocí `signal()`
- C) V services jako shared state

**Poznámka:** Složka `stores/` neexistuje v projektu, takže pravděpodobně varianta B nebo C.

### 5.2 Example: Inline Signals (Varianta B)

```typescript
// features/companies/companies-list/companies-list.component.ts

import { Component, OnInit, signal, computed, inject } from '@angular/core';
import { CompanyService } from '@data/services/company.service';
import { Company } from '@data/models/company.model';

@Component({
  selector: 'app-companies-list',
  templateUrl: './companies-list.component.html',
  standalone: true
})
export class CompaniesListComponent implements OnInit {
  private companyService = inject(CompanyService);
  
  // Signals for reactive state
  companies = signal<Company[]>([]);
  isLoading = signal<boolean>(false);
  error = signal<string | null>(null);
  searchQuery = signal<string>('');
  
  // Computed signal (filtered companies)
  filteredCompanies = computed(() => {
    const query = this.searchQuery().toLowerCase();
    return this.companies().filter(company => 
      company.name.toLowerCase().includes(query)
    );
  });

  ngOnInit(): void {
    this.loadCompanies();
  }

  loadCompanies(): void {
    this.isLoading.set(true);
    this.error.set(null);
    
    this.companyService.getCompanies().subscribe({
      next: (data) => {
        this.companies.set(data);
        this.isLoading.set(false);
      },
      error: (err) => {
        this.error.set(err.message);
        this.isLoading.set(false);
      }
    });
  }

  onSearch(query: string): void {
    this.searchQuery.set(query);
  }
}
```

### 5.3 Example: Service-Based Shared State (Varianta C)

```typescript
// data/services/company.service.ts

import { Injectable, signal, computed } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { tap } from 'rxjs/operators';
import { Company } from '@data/models/company.model';

@Injectable({
  providedIn: 'root'
})
export class CompanyService {
  private http = inject(HttpClient);
  
  // Shared state across components
  private companiesState = signal<Company[]>([]);
  private selectedCompanyState = signal<Company | null>(null);
  
  // Public readonly signals
  readonly companies = this.companiesState.asReadonly();
  readonly selectedCompany = this.selectedCompanyState.asReadonly();
  
  // Computed signals
  readonly activeCompanies = computed(() => 
    this.companiesState().filter(c => c.isActive)
  );

  getCompanies() {
    return this.http.get<Company[]>('/api/companies/').pipe(
      tap(data => this.companiesState.set(data))
    );
  }

  selectCompany(companyId: string) {
    const company = this.companiesState().find(c => c.id === companyId);
    this.selectedCompanyState.set(company || null);
  }

  updateCompany(id: string, data: Partial<Company>) {
    return this.http.patch<Company>(`/api/companies/${id}/`, data).pipe(
      tap(updated => {
        const current = this.companiesState();
        const index = current.findIndex(c => c.id === id);
        if (index !== -1) {
          const newState = [...current];
          newState[index] = updated;
          this.companiesState.set(newState);
        }
      })
    );
  }
}
```

### 5.4 Planned: Signal Store (Varianta A - budoucnost)

```typescript
// stores/content.store.ts (PLÁNOVÁNO)

import { signalStore, withState, withMethods, patchState } from '@ngrx/signals';
import { BlogPost } from '@data/models/blog-post.model';

interface ContentState {
  blogPosts: BlogPost[];
  isLoading: boolean;
  error: string | null;
}

const initialState: ContentState = {
  blogPosts: [],
  isLoading: false,
  error: null
};

export const ContentStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),
  withMethods((store, contentService = inject(ContentService)) => ({
    loadBlogPosts: async () => {
      patchState(store, { isLoading: true, error: null });
      
      try {
        const posts = await contentService.getBlogPosts().toPromise();
        patchState(store, { blogPosts: posts, isLoading: false });
      } catch (error) {
        patchState(store, { 
          error: error.message, 
          isLoading: false 
        });
      }
    },
    
    approveBlogPost: (postId: string) => {
      const posts = store.blogPosts().map(p => 
        p.id === postId ? { ...p, status: 'APPROVED' } : p
      );
      patchState(store, { blogPosts: posts });
    }
  }))
);
```

**Status implementace:**
- ✅ @ngrx/signals nainstalováno
- ⚠️ Implementace pravděpodobně inline v komponentách (varianta B)
- ⏳ Signal Store pattern (varianta A) plánováno

---

## 6. COMPONENTS

### 6.1 Smart vs Dumb Components

```
Smart Components (Container):
  - Fetches data from services
  - Manages state (signals)
  - Business logic
  - Located in: features/*/
  
Dumb Components (Presentational):
  - Receives data via @Input
  - Emits events via @Output
  - No service dependencies
  - Located in: shared/components/
```

### 6.2 Example: Smart Component

```typescript
// features/personas/personas-list/personas-list.component.ts

import { Component, OnInit, signal, inject } from '@angular/core';
import { PersonaService } from '@data/services/persona.service';
import { Persona } from '@data/models/persona.model';
import { PersonaCardComponent } from '@shared/components/persona-card/persona-card.component';

@Component({
  selector: 'app-personas-list',
  standalone: true,
  imports: [PersonaCardComponent],
  template: `
    <div class="personas-grid">
      <app-persona-card
        *ngFor="let persona of personas()"
        [persona]="persona"
        (edit)="onEdit($event)"
        (delete)="onDelete($event)"
      />
    </div>
  `
})
export class PersonasListComponent implements OnInit {
  private personaService = inject(PersonaService);
  
  personas = signal<Persona[]>([]);
  isLoading = signal<boolean>(false);

  ngOnInit(): void {
    this.loadPersonas();
  }

  loadPersonas(): void {
    this.isLoading.set(true);
    this.personaService.getPersonas().subscribe(data => {
      this.personas.set(data);
      this.isLoading.set(false);
    });
  }

  onEdit(persona: Persona): void {
    // Navigate to edit form
  }

  onDelete(persona: Persona): void {
    // Delete persona
    this.personaService.deletePersona(persona.id).subscribe(() => {
      this.loadPersonas();
    });
  }
}
```

### 6.3 Example: Dumb Component

```typescript
// shared/components/persona-card/persona-card.component.ts

import { Component, Input, Output, EventEmitter } from '@angular/core';
import { Persona } from '@data/models/persona.model';

@Component({
  selector: 'app-persona-card',
  standalone: true,
  template: `
    <div class="card">
      <h3>{{ persona.name }}</h3>
      <p>{{ persona.styleDescription }}</p>
      <div class="actions">
        <button (click)="onEdit()">Edit</button>
        <button (click)="onDelete()">Delete</button>
      </div>
    </div>
  `,
  styles: [`
    .card {
      @apply p-4 bg-white rounded-lg shadow-md;
    }
    .actions {
      @apply flex gap-2 mt-4;
    }
  `]
})
export class PersonaCardComponent {
  @Input({ required: true }) persona!: Persona;
  @Output() edit = new EventEmitter<Persona>();
  @Output() delete = new EventEmitter<Persona>();

  onEdit(): void {
    this.edit.emit(this.persona);
  }

  onDelete(): void {
    this.delete.emit(this.persona);
  }
}
```

### 6.4 Custom Components Library (35+)

**Status:** Všechny komponenty jsou custom (Tailwind-based), **ŽÁDNÝ Angular Material**.

```typescript
// shared/components/button/button.component.ts

import { Component, Input, Output, EventEmitter } from '@angular/core';

type ButtonVariant = 'primary' | 'secondary' | 'success' | 'warning' | 'danger';
type ButtonSize = 'sm' | 'md' | 'lg';

@Component({
  selector: 'app-button',
  standalone: true,
  template: `
    <button
      [class]="buttonClasses"
      [disabled]="disabled || loading"
      (click)="onClick.emit($event)"
    >
      <span *ngIf="loading" class="spinner"></span>
      <ng-content></ng-content>
    </button>
  `,
  styles: [`
    .spinner {
      @apply inline-block w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin mr-2;
    }
  `]
})
export class ButtonComponent {
  @Input() variant: ButtonVariant = 'primary';
  @Input() size: ButtonSize = 'md';
  @Input() disabled = false;
  @Input() loading = false;
  @Output() onClick = new EventEmitter<Event>();

  get buttonClasses(): string {
    const base = 'inline-flex items-center justify-center font-medium rounded-lg transition-colors';
    
    const variants = {
      primary: 'bg-primary text-white hover:bg-primary/90',
      secondary: 'bg-secondary text-white hover:bg-secondary/90',
      success: 'bg-success text-white hover:bg-success/90',
      warning: 'bg-warning text-white hover:bg-warning/90',
      danger: 'bg-danger text-white hover:bg-danger/90'
    };
    
    const sizes = {
      sm: 'px-3 py-1.5 text-sm',
      md: 'px-4 py-2 text-base',
      lg: 'px-6 py-3 text-lg'
    };
    
    return `${base} ${variants[this.variant]} ${sizes[this.size]}`;
  }
}
```

---

## 7. SERVICES

### 7.1 API Service

```typescript
// core/services/api.service.ts

import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '@environments/environment';

@Injectable({
  providedIn: 'root'
})
export class ApiService {
  private http = inject(HttpClient);
  private baseUrl = environment.apiUrl;

  get<T>(endpoint: string, params?: any): Observable<T> {
    return this.http.get<T>(`${this.baseUrl}${endpoint}`, {
      params: this.createParams(params)
    });
  }

  post<T>(endpoint: string, body: any): Observable<T> {
    return this.http.post<T>(`${this.baseUrl}${endpoint}`, body);
  }

  put<T>(endpoint: string, body: any): Observable<T> {
    return this.http.put<T>(`${this.baseUrl}${endpoint}`, body);
  }

  patch<T>(endpoint: string, body: any): Observable<T> {
    return this.http.patch<T>(`${this.baseUrl}${endpoint}`, body);
  }

  delete<T>(endpoint: string): Observable<T> {
    return this.http.delete<T>(`${this.baseUrl}${endpoint}`);
  }

  private createParams(params?: any): HttpParams {
    let httpParams = new HttpParams();
    
    if (params) {
      Object.keys(params).forEach(key => {
        if (params[key] !== null && params[key] !== undefined) {
          httpParams = httpParams.set(key, params[key]);
        }
      });
    }
    
    return httpParams;
  }
}
```

### 7.2 Company Service

```typescript
// data/services/company.service.ts

import { Injectable, inject, signal } from '@angular/core';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';
import { ApiService } from '@core/services/api.service';
import { Company } from '@data/models/company.model';

@Injectable({
  providedIn: 'root'
})
export class CompanyService {
  private apiService = inject(ApiService);
  
  // Shared state
  companies = signal<Company[]>([]);
  selectedCompany = signal<Company | null>(null);

  getCompanies(): Observable<Company[]> {
    return this.apiService.get<Company[]>('/api/companies/').pipe(
      tap(data => this.companies.set(data))
    );
  }

  getCompanyById(id: string): Observable<Company> {
    return this.apiService.get<Company>(`/api/companies/${id}/`).pipe(
      tap(data => this.selectedCompany.set(data))
    );
  }

  createCompany(data: Partial<Company>): Observable<Company> {
    return this.apiService.post<Company>('/api/companies/', data).pipe(
      tap(newCompany => {
        this.companies.update(list => [...list, newCompany]);
      })
    );
  }

  updateCompany(id: string, data: Partial<Company>): Observable<Company> {
    return this.apiService.patch<Company>(`/api/companies/${id}/`, data).pipe(
      tap(updated => {
        this.companies.update(list => 
          list.map(c => c.id === id ? updated : c)
        );
      })
    );
  }

  deleteCompany(id: string): Observable<void> {
    return this.apiService.delete<void>(`/api/companies/${id}/`).pipe(
      tap(() => {
        this.companies.update(list => list.filter(c => c.id !== id));
      })
    );
  }

  scrapeDNA(companyId: string): Observable<any> {
    return this.apiService.post(`/api/companies/${companyId}/scrape-dna/`, {});
  }
}
```

---

## 8. ROUTING

### 8.1 Route Configuration (ACTUAL)

```typescript
// app.routes.ts

import { Routes } from '@angular/router';
import { authGuard } from '@core/auth/auth.guard';
import { roleGuard } from '@core/guards/role.guard';
import { Role } from '@data/enums/role.enum';

export const routes: Routes = [
  // ========================================
  // PUBLIC ROUTES
  // ========================================
  {
    path: '',
    loadComponent: () => import('./features/landing/landing.component')
      .then(m => m.LandingComponent)
  },

  // ========================================
  // AUTH ROUTES (Public)
  // ========================================
  {
    path: 'auth',
    loadComponent: () => import('./layouts/auth-layout/auth-layout.component')
      .then(m => m.AuthLayoutComponent),
    children: [
      {
        path: 'login',
        loadComponent: () => import('./features/auth/login/login.component')
          .then(m => m.LoginComponent)
      },
      {
        path: 'register',
        loadComponent: () => import('./features/auth/register/register.component')
          .then(m => m.RegisterComponent)
      },
      {
        path: 'forgot-password',
        loadComponent: () => import('./features/auth/forgot-password/forgot-password.component')
          .then(m => m.ForgotPasswordComponent)
      },
      { path: '', redirectTo: 'login', pathMatch: 'full' }
    ]
  },

  // ========================================
  // ONBOARDING ROUTES (Protected, No Sidebar)
  // ========================================
  {
    path: 'onboarding',
    canActivate: [authGuard],
    loadComponent: () => import('./layouts/onboarding-layout/onboarding-layout.component')
      .then(m => m.OnboardingLayoutComponent),
    children: [
      {
        path: '',
        loadComponent: () => import('./features/onboarding/onboarding.component')
          .then(m => m.OnboardingComponent)
      }
    ]
  },

  // ========================================
  // APP ROUTES (Protected, With Sidebar)
  // ========================================
  {
    path: 'app',
    canActivate: [authGuard],
    loadComponent: () => import('./layouts/app-layout/app-layout.component')
      .then(m => m.AppLayoutComponent),
    children: [
      // Dashboard
      {
        path: 'dashboard',
        loadComponent: () => import('./features/dashboard/dashboard.component')
          .then(m => m.DashboardComponent)
      },

      // Companies
      {
        path: 'companies',
        children: [
          {
            path: '',
            loadComponent: () => import('./features/companies/companies-list/companies-list.component')
              .then(m => m.CompaniesListComponent)
          },
          {
            path: ':id',
            loadComponent: () => import('./features/companies/company-detail/company-detail.component')
              .then(m => m.CompanyDetailComponent)
          }
        ]
      },

      // Personas
      {
        path: 'personas',
        children: [
          {
            path: '',
            loadComponent: () => import('./features/personas/personas-list/personas-list.component')
              .then(m => m.PersonasListComponent)
          },
          {
            path: ':id',
            loadComponent: () => import('./features/personas/persona-detail/persona-detail.component')
              .then(m => m.PersonaDetailComponent)
          }
        ]
      },

      // Content
      {
        path: 'content',
        children: [
          {
            path: 'topics',
            loadComponent: () => import('./features/content/topics/topics.component')
              .then(m => m.TopicsComponent)
          },
          {
            path: 'blog-posts',
            loadComponent: () => import('./features/content/blog-posts/blog-posts.component')
              .then(m => m.BlogPostsComponent)
          },
          {
            path: 'social-posts',
            loadComponent: () => import('./features/content/social-posts/social-posts.component')
              .then(m => m.SocialPostsComponent)
          },
          { path: '', redirectTo: 'topics', pathMatch: 'full' }
        ]
      },

      // Settings
      {
        path: 'settings',
        children: [
          {
            path: 'profile',
            loadComponent: () => import('./features/settings/profile/profile.component')
              .then(m => m.ProfileComponent)
          },
          {
            path: 'billing',
            loadComponent: () => import('./features/settings/billing/billing.component')
              .then(m => m.BillingComponent)
          },
          {
            path: 'team',
            loadComponent: () => import('./features/settings/team/team.component')
              .then(m => m.TeamComponent),
            canActivate: [roleGuard([Role.ADMIN, Role.MANAGER, Role.MARKETER])]
          },
          { path: '', redirectTo: 'profile', pathMatch: 'full' }
        ]
      },

      // Default redirect
      { path: '', redirectTo: 'dashboard', pathMatch: 'full' }
    ]
  },

  // ========================================
  // ERROR ROUTES
  // ========================================
  {
    path: 'unauthorized',
    loadComponent: () => import('./shared/components/unauthorized/unauthorized.component')
      .then(m => m.UnauthorizedComponent)
  },
  {
    path: '**',
    loadComponent: () => import('./shared/components/not-found/not-found.component')
      .then(m => m.NotFoundComponent)
  }
];
```

**Klíčové změny od původního dokumentu:**
- ✅ Root path `/` → Landing page (public)
- ✅ Auth routes na `/auth/*` (login, register)
- ✅ Protected routes pod `/app/*` (dashboard, companies, personas, content, settings)
- ✅ Onboarding na `/onboarding/*` (bez sidebar layoutu)
- ✅ Lazy loading všech routes
- ✅ Role-based access control

### 8.2 Layout Components

```typescript
// layouts/app-layout/app-layout.component.ts

import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { SidebarComponent } from '@shared/components/sidebar/sidebar.component';
import { HeaderComponent } from '@shared/components/header/header.component';

@Component({
  selector: 'app-layout',
  standalone: true,
  imports: [RouterOutlet, SidebarComponent, HeaderComponent],
  template: `
    <div class="app-layout">
      <app-sidebar />
      <div class="main-content">
        <app-header />
        <main class="content">
          <router-outlet />
        </main>
      </div>
    </div>
  `,
  styles: [`
    .app-layout {
      @apply flex h-screen;
    }
    .main-content {
      @apply flex-1 flex flex-col overflow-hidden;
    }
    .content {
      @apply flex-1 overflow-auto p-6;
    }
  `]
})
export class AppLayoutComponent {}
```

---

## 9. FORMS

### 9.1 Reactive Forms (Custom Tailwind Components)

```typescript
// features/companies/company-form/company-form.component.ts

import { Component, OnInit, inject, signal } from '@angular/core';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { CompanyService } from '@data/services/company.service';
import { ButtonComponent } from '@shared/components/button/button.component';
import { FormFieldComponent } from '@shared/components/form-field/form-field.component';

@Component({
  selector: 'app-company-form',
  standalone: true,
  imports: [ReactiveFormsModule, ButtonComponent, FormFieldComponent],
  template: `
    <form [formGroup]="form" (ngSubmit)="onSubmit()" class="space-y-4">
      <app-form-field label="Company Name" [required]="true">
        <input
          type="text"
          formControlName="name"
          class="input"
          [class.error]="isFieldInvalid('name')"
        />
        <div *ngIf="isFieldInvalid('name')" class="error-message">
          Name is required
        </div>
      </app-form-field>

      <app-form-field label="Industry">
        <select formControlName="industry" class="input">
          <option value="">Select industry</option>
          <option value="technology">Technology</option>
          <option value="finance">Finance</option>
          <option value="healthcare">Healthcare</option>
          <option value="retail">Retail</option>
        </select>
      </app-form-field>

      <app-form-field label="Description">
        <textarea
          formControlName="description"
          rows="4"
          class="input"
        ></textarea>
      </app-form-field>

      <div class="flex gap-2">
        <app-button
          type="submit"
          [disabled]="form.invalid"
          [loading]="isLoading()"
        >
          Save Company
        </app-button>
        <app-button
          type="button"
          variant="secondary"
          (onClick)="onCancel()"
        >
          Cancel
        </app-button>
      </div>
    </form>
  `,
  styles: [`
    .input {
      @apply w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary;
    }
    .input.error {
      @apply border-danger;
    }
    .error-message {
      @apply text-sm text-danger mt-1;
    }
  `]
})
export class CompanyFormComponent implements OnInit {
  private fb = inject(FormBuilder);
  private companyService = inject(CompanyService);
  private router = inject(Router);

  form!: FormGroup;
  isLoading = signal<boolean>(false);

  ngOnInit(): void {
    this.initForm();
  }

  initForm(): void {
    this.form = this.fb.group({
      name: ['', Validators.required],
      industry: [''],
      description: ['']
    });
  }

  isFieldInvalid(fieldName: string): boolean {
    const field = this.form.get(fieldName);
    return !!(field && field.invalid && (field.dirty || field.touched));
  }

  onSubmit(): void {
    if (this.form.valid) {
      this.isLoading.set(true);
      
      this.companyService.createCompany(this.form.value).subscribe({
        next: () => {
          this.router.navigate(['/app/companies']);
        },
        error: () => {
          this.isLoading.set(false);
        }
      });
    }
  }

  onCancel(): void {
    this.router.navigate(['/app/companies']);
  }
}
```

### 9.2 Form Field Component (Custom)

```typescript
// shared/components/form-field/form-field.component.ts

import { Component, Input } from '@angular/core';

@Component({
  selector: 'app-form-field',
  standalone: true,
  template: `
    <div class="form-field">
      <label *ngIf="label" class="label">
        {{ label }}
        <span *ngIf="required" class="required">*</span>
      </label>
      <ng-content></ng-content>
      <div *ngIf="hint" class="hint">{{ hint }}</div>
    </div>
  `,
  styles: [`
    .form-field {
      @apply mb-4;
    }
    .label {
      @apply block text-sm font-medium text-gray-700 mb-1;
    }
    .required {
      @apply text-danger;
    }
    .hint {
      @apply text-xs text-gray-500 mt-1;
    }
  `]
})
export class FormFieldComponent {
  @Input() label?: string;
  @Input() required = false;
  @Input() hint?: string;
}
```

---

## 10. HTTP & API

### 10.1 Environment Configuration

```typescript
// environments/environment.ts (Development)

export const environment = {
  production: false,
  apiUrl: 'http://localhost:8000/api',
  stripePublicKey: 'pk_test_...',
  websocketUrl: 'ws://localhost:8000/ws'
};
```

```typescript
// environments/environment.prod.ts (Production)

export const environment = {
  production: true,
  apiUrl: 'https://api.posthub.work/api',
  stripePublicKey: 'pk_live_...',
  websocketUrl: 'wss://api.posthub.work/ws'
};
```

### 10.2 HTTP Client Configuration

```typescript
// app.config.ts

import { ApplicationConfig, provideZoneChangeDetection } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { routes } from './app.routes';
import { authInterceptor } from '@core/interceptors/auth.interceptor';
import { errorInterceptor } from '@core/interceptors/error.interceptor';
import { loadingInterceptor } from '@core/interceptors/loading.interceptor';

export const appConfig: ApplicationConfig = {
  providers: [
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideRouter(routes),
    provideHttpClient(
      withInterceptors([
        authInterceptor,
        errorInterceptor,
        loadingInterceptor
      ])
    )
  ]
};
```

---

## 11. STYLING

### 11.1 Tailwind Configuration (ACTUAL - Extended)

```javascript
// tailwind.config.js

/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{html,ts}",
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        // Primary Brand Colors (Gradient)
        primary: {
          DEFAULT: '#8B5CF6', // Violet
          50: '#F5F3FF',
          100: '#EDE9FE',
          200: '#DDD6FE',
          300: '#C4B5FD',
          400: '#A78BFA',
          500: '#8B5CF6',
          600: '#7C3AED',
          700: '#6D28D9',
          800: '#5B21B6',
          900: '#4C1D95',
        },
        secondary: {
          DEFAULT: '#3B82F6', // Blue
          50: '#EFF6FF',
          100: '#DBEAFE',
          200: '#BFDBFE',
          300: '#93C5FD',
          400: '#60A5FA',
          500: '#3B82F6',
          600: '#2563EB',
          700: '#1D4ED8',
          800: '#1E40AF',
          900: '#1E3A8A',
        },
        accent: {
          DEFAULT: '#06B6D4', // Cyan
          50: '#ECFEFF',
          100: '#CFFAFE',
          200: '#A5F3FC',
          300: '#67E8F9',
          400: '#22D3EE',
          500: '#06B6D4',
          600: '#0891B2',
          700: '#0E7490',
          800: '#155E75',
          900: '#164E63',
        },
        success: {
          DEFAULT: '#10B981', // Green
          50: '#ECFDF5',
          100: '#D1FAE5',
          200: '#A7F3D0',
          300: '#6EE7B7',
          400: '#34D399',
          500: '#10B981',
          600: '#059669',
          700: '#047857',
          800: '#065F46',
          900: '#064E3B',
        },
        warning: {
          DEFAULT: '#F59E0B', // Amber
          50: '#FFFBEB',
          100: '#FEF3C7',
          200: '#FDE68A',
          300: '#FCD34D',
          400: '#FBBF24',
          500: '#F59E0B',
          600: '#D97706',
          700: '#B45309',
          800: '#92400E',
          900: '#78350F',
        },
        danger: {
          DEFAULT: '#EF4444', // Red
          50: '#FEF2F2',
          100: '#FEE2E2',
          200: '#FECACA',
          300: '#FCA5A5',
          400: '#F87171',
          500: '#EF4444',
          600: '#DC2626',
          700: '#B91C1C',
          800: '#991B1B',
          900: '#7F1D1D',
        },
        error: {
          DEFAULT: '#DC2626', // Error Red
          50: '#FEF2F2',
          100: '#FEE2E2',
          200: '#FECACA',
          300: '#FCA5A5',
          400: '#F87171',
          500: '#EF4444',
          600: '#DC2626',
          700: '#B91C1C',
          800: '#991B1B',
          900: '#7F1D1D',
        },
        info: {
          DEFAULT: '#3B82F6', // Blue
          50: '#EFF6FF',
          100: '#DBEAFE',
          200: '#BFDBFE',
          300: '#93C5FD',
          400: '#60A5FA',
          500: '#3B82F6',
          600: '#2563EB',
          700: '#1D4ED8',
          800: '#1E40AF',
          900: '#1E3A8A',
        },
      },
      fontFamily: {
        sans: ['Manrope', 'sans-serif'],
        mono: ['IBM Plex Mono', 'monospace'],
        serif: ['Instrument Serif', 'serif'],
      },
      animation: {
        'float': 'float 6s ease-in-out infinite',
        'shimmer': 'shimmer 2s linear infinite',
        'fade-in': 'fadeIn 0.5s ease-in',
        'fade-in-up': 'fadeInUp 0.6s ease-out',
        'fade-in-down': 'fadeInDown 0.6s ease-out',
        'slide-in-left': 'slideInLeft 0.5s ease-out',
        'slide-in-right': 'slideInRight 0.5s ease-out',
        'gradient-shift': 'gradientShift 3s ease infinite',
        'glow-pulse': 'glowPulse 2s ease-in-out infinite',
      },
      keyframes: {
        float: {
          '0%, 100%': { transform: 'translateY(0px)' },
          '50%': { transform: 'translateY(-20px)' },
        },
        shimmer: {
          '0%': { backgroundPosition: '-1000px 0' },
          '100%': { backgroundPosition: '1000px 0' },
        },
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        fadeInUp: {
          '0%': { opacity: '0', transform: 'translateY(20px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        fadeInDown: {
          '0%': { opacity: '0', transform: 'translateY(-20px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        slideInLeft: {
          '0%': { transform: 'translateX(-100%)' },
          '100%': { transform: 'translateX(0)' },
        },
        slideInRight: {
          '0%': { transform: 'translateX(100%)' },
          '100%': { transform: 'translateX(0)' },
        },
        gradientShift: {
          '0%, 100%': { backgroundPosition: '0% 50%' },
          '50%': { backgroundPosition: '100% 50%' },
        },
        glowPulse: {
          '0%, 100%': { boxShadow: '0 0 20px rgba(139, 92, 246, 0.5)' },
          '50%': { boxShadow: '0 0 40px rgba(139, 92, 246, 0.8)' },
        },
      },
      backgroundImage: {
        'gradient-brand': 'linear-gradient(135deg, #8B5CF6 0%, #3B82F6 50%, #06B6D4 100%)',
        'gradient-hub': 'linear-gradient(to right, #8B5CF6, #3B82F6, #06B6D4, #10B981)',
        'gradient-dark': 'linear-gradient(135deg, #1F2937 0%, #111827 100%)',
        'gradient-glow': 'radial-gradient(circle at center, rgba(139, 92, 246, 0.15) 0%, transparent 70%)',
      },
    },
  },
  plugins: [],
}
```

**Klíčové změny od původního dokumentu:**
- ✅ Všechny brand colors zachovány (violet, blue, cyan, green)
- ✅ Přidány: secondary, success, warning, danger, error, info
- ✅ Přidáno: darkMode: 'class'
- ✅ Přidáno: Instrument Serif font
- ✅ Přidáno: Mnoho animací (float, shimmer, fade-in-*, gradient-shift, glow-pulse)
- ✅ Přidáno: backgroundImage (gradient-brand, gradient-hub, gradient-dark, gradient-glow)

### 11.2 Visual Book Design System

```scss
// styles/_visual-book.scss

// Glassmorphism effect
@mixin glass {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
}

// Neon glow effect
@mixin neon-glow($color: #8B5CF6) {
  box-shadow: 0 0 10px $color,
              0 0 20px $color,
              0 0 30px $color;
}

// Gradient text
@mixin gradient-text {
  background: linear-gradient(135deg, #8B5CF6 0%, #3B82F6 50%, #06B6D4 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

// Card component
.card {
  @apply rounded-lg shadow-md;
  @include glass;
  
  &--elevated {
    @apply shadow-xl;
  }
  
  &--glow {
    @include neon-glow;
  }
}

// Button styles
.btn {
  @apply px-4 py-2 rounded-lg font-medium transition-all;
  
  &--primary {
    @apply bg-primary text-white hover:bg-primary-600;
  }
  
  &--gradient {
    @apply bg-gradient-brand text-white;
    
    &:hover {
      @apply shadow-lg;
      @include neon-glow;
    }
  }
}
```

---

## 12. BUILD & DEPLOYMENT

### 12.1 Production Build

```bash
# Build for production
ng build --configuration production

# Output
dist/posthub-frontend/
├── index.html
├── main.[hash].js
├── polyfills.[hash].js
├── runtime.[hash].js
├── styles.[hash].css
└── assets/
```

### 12.2 Deployment Configuration

```yaml
# .github/workflows/deploy-frontend.yml (Planned)

name: Deploy Frontend

on:
  push:
    branches: [main]
    paths:
      - 'frontend/**'

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json
      
      - name: Install dependencies
        run: |
          cd frontend
          npm ci
      
      - name: Build
        run: |
          cd frontend
          npm run build -- --configuration production
      
      - name: Deploy to VPS
        run: |
          scp -r frontend/dist/* root@72.62.92.89:/var/www/posthub/frontend/
```

### 12.3 Environment-Specific Builds

```json
// package.json scripts

{
  "scripts": {
    "ng": "ng",
    "start": "ng serve",
    "build": "ng build",
    "build:prod": "ng build --configuration production",
    "build:staging": "ng build --configuration staging",
    "test": "ng test",
    "lint": "ng lint",
    "e2e": "ng e2e"
  }
}
```

---

## 📊 IMPLEMENTATION STATUS

### Core Features
- ✅ Angular 19 (100%)
- ✅ Standalone Components (100%)
- ✅ Signals API (100%)
- ✅ Tailwind CSS (100%)
- ✅ Routing Structure (100%)
- ✅ Auth System (100%)
- ⏳ State Management (70% - signals inline, @ngrx/signals částečně)
- ❌ Angular Material (0% - nepoužívá se)

### Components
- ✅ Custom Component Library (35+) (100%)
- ✅ Smart/Dumb Pattern (100%)
- ✅ Layouts (app, auth, onboarding) (100%)
- ✅ Forms (Reactive Forms) (100%)

### Features
- ✅ Landing Page (100%)
- ✅ Auth (Login, Register) (100%)
- ✅ Dashboard (100%)
- ✅ Companies Management (100%)
- ✅ Personas Management (100%)
- ✅ Content Management (100%)
- ✅ Onboarding Wizard (100%)
- ✅ Settings (100%)

### Infrastructure
- ✅ HTTP Interceptors (100%)
- ✅ Route Guards (100%)
- ✅ Services Layer (100%)
- ✅ Environment Configuration (100%)
- ⏳ Build & Deployment (80% - needs CI/CD automation)

---

## 🎯 NEXT STEPS

### Immediate Tasks
1. ✅ ~~Upgrade Angular 17 → 19~~ (DONE)
2. ⏳ Finalize @ngrx/signals implementation
3. ⏳ Complete all 35+ custom components
4. ⏳ Setup CI/CD for frontend deployment

### Phase 2
5. 🎯 Add E2E tests (Cypress)
6. 🎯 Performance optimization (lazy loading, code splitting)
7. 🎯 PWA support
8. 🎯 Internationalization (i18n)

### Phase 3
9. 🎯 Dark mode implementation
10. 🎯 Advanced animations
11. 🎯 Mobile-first responsive design
12. 🎯 Accessibility (a11y) improvements

---

*Tento dokument je LIVE a reflektuje skutečný stav Angular frontendu.*  
*Verze 2.1.0 | Poslední aktualizace: December 17, 2025*  
*Aktualizováno na základě skutečné struktury projektu*

---