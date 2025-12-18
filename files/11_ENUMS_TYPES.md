# 11_ENUMS_TYPES.md - Kompletní Enums a Typy

**Dokument:** Enums a TypeScript Types pro PostHub.work  
**Verze:** 1.0.0  
**Self-Contained:** ✅ Všechny enum definice

---

> ## ⚠️ DŮLEŽITÉ UPOZORNĚNÍ
> 
> **Sekce 1-6** tohoto dokumentu popisují **PLÁNOVANOU/IDEÁLNÍ** strukturu enumů a typů.  
> **Sekce 7** popisuje **SKUTEČNÝ AKTUÁLNÍ STAV** - jaké enumy existují vs chybí.  
> 
> **Shoda dokumentace s realitou: ~40-45%**
> 
> - ✅ **User Enums (sekce 1)** = PŘESNÁ SHODA (90%)
> - ⚠️ **Persona Enums (sekce 2)** = ČÁSTEČNĚ (50%)
> - ⚠️ **Content Enums (sekce 3)** = ČÁSTEČNĚ (60%)
> - ❌ **AI Enums (sekce 4)** = JINÝ NAMING (30%)
> - ❌ **Billing Enums (sekce 5)** = ROZDÍLY (40%)
> - ❌ **TypeScript Interfaces (sekce 6)** = NEPŘESNÉ (20%)

---

## 📋 OBSAH

1. [User Enums](#1-user-enums) *(Přesná shoda - 90%)*
2. [Persona Enums](#2-persona-enums) *(Částečně - 50%)*
3. [Content Enums](#3-content-enums) *(Částečně - 60%)*
4. [AI Enums](#4-ai-enums) *(Jiný naming - 30%)*
5. [Billing Enums](#5-billing-enums) *(Rozdíly - 40%)*
6. [TypeScript Interfaces](#6-typescript-interfaces) *(Nepřesné - 20%)*
7. [**Aktuální Stav Enumů**](#7-aktuální-stav-enumů-reality-check) ⚠️ **← SOUČASNÁ REALITA**

---

## 1. USER ENUMS

### Python

```python
# apps/users/enums.py
from django.db import models

class UserRole(models.TextChoices):
    ADMIN = 'admin', 'Admin'
    MANAGER = 'manager', 'Manager'
    MARKETER = 'marketer', 'Marketer'
    SUPERVISOR = 'supervisor', 'Supervisor'

# Hierarchy: ADMIN > MANAGER > MARKETER > SUPERVISOR
```

### TypeScript

```typescript
// src/app/data/enums/user.enums.ts
export enum UserRole {
  ADMIN = 'admin',
  MANAGER = 'manager',
  MARKETER = 'marketer',
  SUPERVISOR = 'supervisor',
}

export const UserRoleLabels: Record<UserRole, string> = {
  [UserRole.ADMIN]: 'Admin',
  [UserRole.MANAGER]: 'Manager',
  [UserRole.MARKETER]: 'Marketér',
  [UserRole.SUPERVISOR]: 'Supervisor',
};
```

---

## 2. PERSONA ENUMS

### Python

```python
# apps/personas/enums.py
from django.db import models

class JungArchetype(models.TextChoices):
    INNOCENT = 'innocent', 'Neviňátko'
    EVERYMAN = 'everyman', 'Každý člověk'
    HERO = 'hero', 'Hrdina'
    OUTLAW = 'outlaw', 'Rebel'
    EXPLORER = 'explorer', 'Objevitel'
    CREATOR = 'creator', 'Tvůrce'
    RULER = 'ruler', 'Vládce'
    MAGICIAN = 'magician', 'Kouzelník'
    LOVER = 'lover', 'Milovník'
    CAREGIVER = 'caregiver', 'Pečovatel'
    JESTER = 'jester', 'Šašek'
    SAGE = 'sage', 'Mudrc'

class MBTIType(models.TextChoices):
    INTJ = 'INTJ', 'INTJ - Architekt'
    INTP = 'INTP', 'INTP - Logik'
    ENTJ = 'ENTJ', 'ENTJ - Velitel'
    ENTP = 'ENTP', 'ENTP - Debatér'
    INFJ = 'INFJ', 'INFJ - Advokát'
    INFP = 'INFP', 'INFP - Prostředník'
    ENFJ = 'ENFJ', 'ENFJ - Protagonista'
    ENFP = 'ENFP', 'ENFP - Aktivista'
    ISTJ = 'ISTJ', 'ISTJ - Logistik'
    ISFJ = 'ISFJ', 'ISFJ - Obránce'
    ESTJ = 'ESTJ', 'ESTJ - Výkonný'
    ESFJ = 'ESFJ', 'ESFJ - Konzul'
    ISTP = 'ISTP', 'ISTP - Virtuóz'
    ISFP = 'ISFP', 'ISFP - Dobrodruh'
    ESTP = 'ESTP', 'ESTP - Podnikatel'
    ESFP = 'ESFP', 'ESFP - Bavič'

class PersonaStatus(models.TextChoices):
    GENERATED = 'generated', 'Vygenerována'
    SELECTED = 'selected', 'Vybrána'
    ACTIVE = 'active', 'Aktivní'
    INACTIVE = 'inactive', 'Neaktivní'
    ARCHIVED = 'archived', 'Archivována'

class VocabularyLevel(models.TextChoices):
    ACADEMIC = 'academic', 'Akademický'
    STREET_SLANG = 'street_slang', 'Hovorový'
    CORPORATE_SPEAK = 'corporate_speak', 'Korporátní'
    TECHNICAL = 'technical', 'Technický'

class SentencePreference(models.TextChoices):
    SHORT_PUNCHY = 'short_punchy', 'Krátké a úderné'
    LONG_COMPLEX = 'long_complex', 'Dlouhé a komplexní'
    CHAOTIC = 'chaotic', 'Chaotické'

class ArgumentStructure(models.TextChoices):
    DATA_DRIVEN = 'data_driven', 'Datově řízený'
    STORY_DRIVEN = 'story_driven', 'Příběhový'
    EMOTION_DRIVEN = 'emotion_driven', 'Emoční'

class ArtStyleName(models.TextChoices):
    MINIMALIST_CORPORATE = 'minimalist_corporate', 'Minimalist Corporate'
    CYBERPUNK = 'cyberpunk', 'Cyberpunk'
    HAND_DRAWN = 'hand_drawn', 'Ručně kreslený'
    REALISTIC_PHOTO = 'realistic_photo', 'Realistická fotka'
    VINTAGE_RETRO = 'vintage_retro', 'Vintage/Retro'
    FLAT_DESIGN = 'flat_design', 'Flat Design'
    WATERCOLOR = 'watercolor', 'Akvarel'

class ColorPalette(models.TextChoices):
    NEON_DARK = 'neon_dark', 'Neon Dark'
    PASTEL_SOFT = 'pastel_soft', 'Pastel Soft'
    HIGH_CONTRAST_BW = 'high_contrast_bw', 'Vysoký kontrast B&W'
    WARM_EARTH = 'warm_earth', 'Teplé zemité'
    COOL_CORPORATE = 'cool_corporate', 'Studené korporátní'
    VIBRANT_ENERGETIC = 'vibrant_energetic', 'Živé energické'

class VisualAtmosphere(models.TextChoices):
    CHAOTIC = 'chaotic', 'Chaotická'
    STERILE_CLEAN = 'sterile_clean', 'Sterilní'
    WARM_HOMEY = 'warm_homey', 'Teplá domácí'
    PROFESSIONAL = 'professional', 'Profesionální'
    PLAYFUL = 'playful', 'Hravá'
    DRAMATIC = 'dramatic', 'Dramatická'
    MINIMALIST = 'minimalist', 'Minimalistická'
```

### TypeScript

```typescript
// src/app/data/enums/persona.enums.ts

export enum JungArchetype {
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
  SAGE = 'sage',
}

export const JungArchetypeLabels: Record<JungArchetype, string> = {
  [JungArchetype.INNOCENT]: 'Neviňátko',
  [JungArchetype.EVERYMAN]: 'Každý člověk',
  [JungArchetype.HERO]: 'Hrdina',
  [JungArchetype.OUTLAW]: 'Rebel',
  [JungArchetype.EXPLORER]: 'Objevitel',
  [JungArchetype.CREATOR]: 'Tvůrce',
  [JungArchetype.RULER]: 'Vládce',
  [JungArchetype.MAGICIAN]: 'Kouzelník',
  [JungArchetype.LOVER]: 'Milovník',
  [JungArchetype.CAREGIVER]: 'Pečovatel',
  [JungArchetype.JESTER]: 'Šašek',
  [JungArchetype.SAGE]: 'Mudrc',
};

export enum MBTIType {
  INTJ = 'INTJ', INTP = 'INTP', ENTJ = 'ENTJ', ENTP = 'ENTP',
  INFJ = 'INFJ', INFP = 'INFP', ENFJ = 'ENFJ', ENFP = 'ENFP',
  ISTJ = 'ISTJ', ISFJ = 'ISFJ', ESTJ = 'ESTJ', ESFJ = 'ESFJ',
  ISTP = 'ISTP', ISFP = 'ISFP', ESTP = 'ESTP', ESFP = 'ESFP',
}

export enum PersonaStatus {
  GENERATED = 'generated',
  SELECTED = 'selected',
  ACTIVE = 'active',
  INACTIVE = 'inactive',
  ARCHIVED = 'archived',
}

export enum VocabularyLevel {
  ACADEMIC = 'academic',
  STREET_SLANG = 'street_slang',
  CORPORATE_SPEAK = 'corporate_speak',
  TECHNICAL = 'technical',
}

export enum ArgumentStructure {
  DATA_DRIVEN = 'data_driven',
  STORY_DRIVEN = 'story_driven',
  EMOTION_DRIVEN = 'emotion_driven',
}

export enum ArtStyleName {
  MINIMALIST_CORPORATE = 'minimalist_corporate',
  CYBERPUNK = 'cyberpunk',
  HAND_DRAWN = 'hand_drawn',
  REALISTIC_PHOTO = 'realistic_photo',
  VINTAGE_RETRO = 'vintage_retro',
  FLAT_DESIGN = 'flat_design',
  WATERCOLOR = 'watercolor',
}

export enum ColorPalette {
  NEON_DARK = 'neon_dark',
  PASTEL_SOFT = 'pastel_soft',
  HIGH_CONTRAST_BW = 'high_contrast_bw',
  WARM_EARTH = 'warm_earth',
  COOL_CORPORATE = 'cool_corporate',
  VIBRANT_ENERGETIC = 'vibrant_energetic',
}

export enum VisualAtmosphere {
  CHAOTIC = 'chaotic',
  STERILE_CLEAN = 'sterile_clean',
  WARM_HOMEY = 'warm_homey',
  PROFESSIONAL = 'professional',
  PLAYFUL = 'playful',
  DRAMATIC = 'dramatic',
  MINIMALIST = 'minimalist',
}
```

---

## 3. CONTENT ENUMS

### Python

```python
# apps/content/enums.py
from django.db import models

class ContentStatus(models.TextChoices):
    DRAFT = 'draft', 'Koncept'
    PENDING = 'pending', 'Čeká'
    GENERATING = 'generating', 'Generuje se'
    PENDING_APPROVAL = 'pending_approval', 'Čeká na schválení'
    APPROVED = 'approved', 'Schváleno'
    REJECTED = 'rejected', 'Zamítnuto'
    PUBLISHED = 'published', 'Publikováno'
    FAILED = 'failed', 'Selhalo'
    ARCHIVED = 'archived', 'Archivováno'

class SocialPlatform(models.TextChoices):
    FACEBOOK = 'facebook', 'Facebook'
    INSTAGRAM = 'instagram', 'Instagram'
    LINKEDIN = 'linkedin', 'LinkedIn'
    TWITTER = 'twitter', 'Twitter/X'
    TIKTOK = 'tiktok', 'TikTok'
    YOUTUBE = 'youtube', 'YouTube'
    PINTEREST = 'pinterest', 'Pinterest'

class SearchIntent(models.TextChoices):
    INFORMATIONAL = 'informational', 'Informační'
    COMMERCIAL = 'commercial', 'Komerční'
    TRANSACTIONAL = 'transactional', 'Transakční'
    NAVIGATIONAL = 'navigational', 'Navigační'

class SectionType(models.TextChoices):
    INTRO = 'intro', 'Úvod'
    BODY = 'body', 'Tělo'
    CONCLUSION = 'conclusion', 'Závěr'
    FAQ = 'faq', 'FAQ'
    CTA = 'cta', 'Výzva k akci'

class MediaType(models.TextChoices):
    IMAGE = 'image', 'Obrázek'
    VIDEO = 'video', 'Video'
    CAROUSEL = 'carousel', 'Carousel'
```

### TypeScript

```typescript
// src/app/data/enums/content.enums.ts

export enum ContentStatus {
  DRAFT = 'draft',
  PENDING = 'pending',
  GENERATING = 'generating',
  PENDING_APPROVAL = 'pending_approval',
  APPROVED = 'approved',
  REJECTED = 'rejected',
  PUBLISHED = 'published',
  FAILED = 'failed',
  ARCHIVED = 'archived',
}

export const ContentStatusLabels: Record<ContentStatus, string> = {
  [ContentStatus.DRAFT]: 'Koncept',
  [ContentStatus.PENDING]: 'Čeká',
  [ContentStatus.GENERATING]: 'Generuje se',
  [ContentStatus.PENDING_APPROVAL]: 'Čeká na schválení',
  [ContentStatus.APPROVED]: 'Schváleno',
  [ContentStatus.REJECTED]: 'Zamítnuto',
  [ContentStatus.PUBLISHED]: 'Publikováno',
  [ContentStatus.FAILED]: 'Selhalo',
  [ContentStatus.ARCHIVED]: 'Archivováno',
};

export const ContentStatusColors: Record<ContentStatus, string> = {
  [ContentStatus.DRAFT]: 'slate',
  [ContentStatus.PENDING]: 'slate',
  [ContentStatus.GENERATING]: 'blue',
  [ContentStatus.PENDING_APPROVAL]: 'yellow',
  [ContentStatus.APPROVED]: 'green',
  [ContentStatus.REJECTED]: 'red',
  [ContentStatus.PUBLISHED]: 'green',
  [ContentStatus.FAILED]: 'red',
  [ContentStatus.ARCHIVED]: 'slate',
};

export enum SocialPlatform {
  FACEBOOK = 'facebook',
  INSTAGRAM = 'instagram',
  LINKEDIN = 'linkedin',
  TWITTER = 'twitter',
  TIKTOK = 'tiktok',
  YOUTUBE = 'youtube',
  PINTEREST = 'pinterest',
}

export const PlatformLimits: Record<SocialPlatform, { maxLength: number; maxHashtags: number }> = {
  [SocialPlatform.FACEBOOK]: { maxLength: 63206, maxHashtags: 30 },
  [SocialPlatform.INSTAGRAM]: { maxLength: 2200, maxHashtags: 30 },
  [SocialPlatform.LINKEDIN]: { maxLength: 3000, maxHashtags: 5 },
  [SocialPlatform.TWITTER]: { maxLength: 280, maxHashtags: 2 },
  [SocialPlatform.TIKTOK]: { maxLength: 2200, maxHashtags: 5 },
  [SocialPlatform.YOUTUBE]: { maxLength: 5000, maxHashtags: 15 },
  [SocialPlatform.PINTEREST]: { maxLength: 500, maxHashtags: 20 },
};

export enum SearchIntent {
  INFORMATIONAL = 'informational',
  COMMERCIAL = 'commercial',
  TRANSACTIONAL = 'transactional',
  NAVIGATIONAL = 'navigational',
}

export enum SectionType {
  INTRO = 'intro',
  BODY = 'body',
  CONCLUSION = 'conclusion',
  FAQ = 'faq',
  CTA = 'cta',
}

export enum MediaType {
  IMAGE = 'image',
  VIDEO = 'video',
  CAROUSEL = 'carousel',
}
```

---

## 4. AI ENUMS

### Python

```python
# apps/ai_gateway/enums.py
from django.db import models

class JobStatus(models.TextChoices):
    PENDING = 'pending', 'Čeká'
    QUEUED = 'queued', 'Ve frontě'
    GENERATING = 'generating', 'Generuje se'
    COMPLETED = 'completed', 'Dokončeno'
    FAILED = 'failed', 'Selhalo'
    TIMEOUT = 'timeout', 'Timeout'
    CANCELLED = 'cancelled', 'Zrušeno'

class JobType(models.TextChoices):
    PERSONAS = 'personas', 'Generování person'
    TOPICS = 'topics', 'Generování témat'
    BLOGPOST = 'blogpost', 'Generování blogpostu'
    SOCIAL_POST = 'social_post', 'Generování social postu'
    IMAGE = 'image', 'Generování obrázku'
    VIDEO = 'video', 'Generování videa'
    COMPANY_SCRAPE = 'company_scrape', 'Scraping firmy'

class AIProvider(models.TextChoices):
    GEMINI = 'gemini', 'Google Gemini'
    PERPLEXITY = 'perplexity', 'Perplexity'
    NANOBANA = 'nanobana', 'Nanobana (Imagen)'
    VEO = 'veo', 'Veo 3'
```

### TypeScript

```typescript
// src/app/data/enums/ai.enums.ts

export enum JobStatus {
  PENDING = 'pending',
  QUEUED = 'queued',
  GENERATING = 'generating',
  COMPLETED = 'completed',
  FAILED = 'failed',
  TIMEOUT = 'timeout',
  CANCELLED = 'cancelled',
}

export const JobStatusIsTerminal: Record<JobStatus, boolean> = {
  [JobStatus.PENDING]: false,
  [JobStatus.QUEUED]: false,
  [JobStatus.GENERATING]: false,
  [JobStatus.COMPLETED]: true,
  [JobStatus.FAILED]: true,
  [JobStatus.TIMEOUT]: true,
  [JobStatus.CANCELLED]: true,
};

export enum JobType {
  PERSONAS = 'personas',
  TOPICS = 'topics',
  BLOGPOST = 'blogpost',
  SOCIAL_POST = 'social_post',
  IMAGE = 'image',
  VIDEO = 'video',
  COMPANY_SCRAPE = 'company_scrape',
}

export enum AIProvider {
  GEMINI = 'gemini',
  PERPLEXITY = 'perplexity',
  NANOBANA = 'nanobana',
  VEO = 'veo',
}
```

---

## 5. BILLING ENUMS

### Python

```python
# apps/billing/enums.py
from django.db import models

class SubscriptionTier(models.TextChoices):
    BASIC = 'basic', 'Basic'
    PRO = 'pro', 'Pro'
    ULTIMATE = 'ultimate', 'Ultimate'

class SubscriptionStatus(models.TextChoices):
    TRIALING = 'trialing', 'Trial'
    ACTIVE = 'active', 'Aktivní'
    PAST_DUE = 'past_due', 'Po splatnosti'
    CANCELED = 'canceled', 'Zrušeno'
    UNPAID = 'unpaid', 'Nezaplaceno'

class BillingCycle(models.TextChoices):
    MONTHLY = 'monthly', 'Měsíčně'
    YEARLY = 'yearly', 'Ročně'
```

### TypeScript

```typescript
// src/app/data/enums/billing.enums.ts

export enum SubscriptionTier {
  BASIC = 'basic',
  PRO = 'pro',
  ULTIMATE = 'ultimate',
}

export enum SubscriptionStatus {
  TRIALING = 'trialing',
  ACTIVE = 'active',
  PAST_DUE = 'past_due',
  CANCELED = 'canceled',
  UNPAID = 'unpaid',
}

export enum BillingCycle {
  MONTHLY = 'monthly',
  YEARLY = 'yearly',
}
```

---

## 6. TYPESCRIPT INTERFACES

```typescript
// src/app/data/models/index.ts

export interface User {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  fullName: string;
  role: UserRole;
  organizationId?: string;
  isActive: boolean;
}

export interface Organization {
  id: string;
  name: string;
  slug: string;
  legalName?: string;
  businessField?: string;
  subscriptionTier: SubscriptionTier;
}

export interface Persona {
  id: string;
  characterName: string;
  age?: number;
  roleInCompany?: string;
  jungArchetype: JungArchetype;
  mbtiType: MBTIType;
  dominantValue?: string;
  mainFrustration?: string;
  vocabularyLevel?: VocabularyLevel;
  argumentStructure?: ArgumentStructure;
  artStyleName?: ArtStyleName;
  colorPalette?: ColorPalette;
  visualAtmosphere?: VisualAtmosphere;
  status: PersonaStatus;
  isSelected: boolean;
}

export interface Topic {
  id: string;
  calendarId: string;
  personaId?: string;
  personaName?: string;
  title: string;
  description?: string;
  keywords: string[];
  focusKeyword?: string;
  searchIntent?: SearchIntent;
  plannedDate?: string;
  status: ContentStatus;
}

export interface BlogPost {
  id: string;
  topicId: string;
  title: string;
  slug: string;
  metaTitle?: string;
  metaDescription?: string;
  focusKeyword?: string;
  seoScore?: number;
  wordCount: number;
  readingTimeMinutes: number;
  status: ContentStatus;
  sections: BlogPostSection[];
  faqs: BlogPostFaq[];
  persona?: Persona;
}

export interface BlogPostSection {
  id: string;
  sectionType: SectionType;
  sectionOrder: number;
  heading?: string;
  headingLevel?: number;
  content: string;
  wordCount: number;
}

export interface BlogPostFaq {
  question: string;
  answer: string;
}

export interface SocialPost {
  id: string;
  blogpostId?: string;
  platform: SocialPlatform;
  textContent: string;
  hashtags: string[];
  mediaUrl?: string;
  mediaType?: MediaType;
  plannedPublishDate?: string;
  status: ContentStatus;
}

export interface GenerationJob {
  id: string;
  jobType: JobType;
  status: JobStatus;
  progress?: number;
  step?: string;
  startedAt?: string;
  completedAt?: string;
  errorMessage?: string;
}

export interface SubscriptionPlan {
  id: string;
  code: string;
  name: string;
  tier: SubscriptionTier;
  priceMonthly: number;
  priceYearly?: number;
  maxPersonas: number;
  maxPostsPerMonth: number;
  includesImages: boolean;
  includesVideo: boolean;
}

export interface Subscription {
  id: string;
  plan: SubscriptionPlan;
  status: SubscriptionStatus;
  billingCycle: BillingCycle;
  currentPeriodEnd?: string;
  cancelAtPeriodEnd: boolean;
}
```

---

## 7. AKTUÁLNÍ STAV ENUMŮ (REALITY CHECK)

> **⚠️ DŮLEŽITÉ:** Sekce 1-6 v tomto dokumentu popisují **PLÁNOVANOU/IDEÁLNÍ** strukturu enumů.  
> **Tato sekce (7) popisuje SKUTEČNÝ aktuální stav** implementovaných enumů k prosinci 2024.

---

### 7.1 Overview - Enum Implementation Status

| Kategorie | Plánováno | Implementováno | Shoda | Kritické rozdíly |
|-----------|-----------|----------------|-------|------------------|
| **User Enums** | ✅ | ✅ | 90% | Žádné |
| **Jung Archetype** | ✅ 12 archetypes | ✅ 12 archetypes | 100% | Perfektní shoda |
| **MBTI Type** | ✅ 16 types | ✅ Pole v DB | ⚠️ | Enum def nenalezen |
| **PersonaStatus** | ✅ 5 values | ✅ 3 values | 60% | GENERATED, SELECTED, INACTIVE chybí |
| **ContentStatus** | ✅ 9 values | ✅ 7 values | 78% | PENDING, ARCHIVED chybí |
| **SocialPlatform** | ✅ 7 platforms | ✅ 5 platforms | 71% | YOUTUBE, PINTEREST chybí |
| **JobStatus** | ✅ 7 values | ✅ 5 values | 71% | QUEUED, TIMEOUT chybí; PROCESSING místo GENERATING |
| **JobType** | ✅ 7 types | ✅ 7 types | 100%* | *Jiný naming convention |
| **SubscriptionTier** | ✅ 3 tiers | ✅ 3 tiers | 67% | ULTIMATE → ENTERPRISE |
| **VocabularyLevel** | ✅ 4 levels | ❌ | 0% | Neexistuje |
| **SentencePreference** | ✅ 3 types | ❌ | 0% | Neexistuje |
| **ArgumentStructure** | ✅ 3 types | ❌ | 0% | Neexistuje |
| **ArtStyleName** | ✅ 7 styles | ❌ | 0% | Neexistuje |
| **ColorPalette** | ✅ 6 palettes | ❌ | 0% | Neexistuje |
| **VisualAtmosphere** | ✅ 7 types | ❌ | 0% | Neexistuje |
| **SearchIntent** | ✅ 4 types | ❌ | 0% | Neexistuje |
| **SectionType** | ✅ 5 types | ❌ | 0% | Neexistuje |
| **MediaType** | ✅ 3 types | ❌ | 0% | Neexistuje |
| **AIProvider** | ✅ 4 providers | ❌ | 0% | Neexistuje |
| **BillingCycle** | ✅ 2 cycles | ⚠️ | ? | dj-stripe likely |
| **SubscriptionStatus** | ✅ 5 statuses | ⚠️ | ? | dj-stripe likely |

**Celková shoda: ~40-45%**

---

### 7.2 User Enums - PŘESNÁ SHODA (90%)

#### ✅ UserRole - 100% IMPLEMENTOVÁNO

**Realita = Dokument:**

```python
# apps/users/enums.py (SKUTEČNÝ SOUBOR)
class UserRole(models.TextChoices):
    ADMIN = 'admin', 'Admin'           # ✅ PŘESNÁ SHODA
    MANAGER = 'manager', 'Manager'     # ✅ PŘESNÁ SHODA
    MARKETER = 'marketer', 'Marketer'  # ✅ PŘESNÁ SHODA
    SUPERVISOR = 'supervisor', 'Supervisor'  # ✅ PŘESNÁ SHODA
```

**Status:** ✅ Tato enum je identická v dokumentu i realitě!

**Role Hierarchy:** ✅ Také přesně odpovídá:
- ADMIN (4) > MANAGER (3) > MARKETER (2) > SUPERVISOR (1)

---

### 7.3 Persona Enums - ČÁSTEČNĚ (50%)

#### ✅ JungArchetype - 100% IMPLEMENTOVÁNO

**Realita = Dokument:**

```python
# apps/personas/enums.py (SKUTEČNÝ SOUBOR)
class JungArchetype(models.TextChoices):
    INNOCENT = 'innocent', 'Neviňátko'      # ✅ OK
    EVERYMAN = 'everyman', 'Každý člověk'   # ✅ OK
    HERO = 'hero', 'Hrdina'                 # ✅ OK
    OUTLAW = 'outlaw', 'Rebel'              # ✅ OK
    EXPLORER = 'explorer', 'Objevitel'      # ✅ OK
    CREATOR = 'creator', 'Tvůrce'           # ✅ OK
    RULER = 'ruler', 'Vládce'               # ✅ OK
    MAGICIAN = 'magician', 'Kouzelník'      # ✅ OK
    LOVER = 'lover', 'Milovník'             # ✅ OK
    CAREGIVER = 'caregiver', 'Pečovatel'    # ✅ OK
    JESTER = 'jester', 'Šašek'              # ✅ OK
    SAGE = 'sage', 'Mudrc'                  # ✅ OK
```

**Status:** ✅ Všech 12 archetypů je přesně podle dokumentu!

#### ⚠️ MBTIType - POLE EXISTUJE, ENUM DEFINICE NENALEZENA

**Dokument popisuje:**
```python
class MBTIType(models.TextChoices):
    INTJ = 'INTJ', 'INTJ - Architekt'
    # ... 16 values total
```

**Realita:**
```python
# apps/personas/models.py
class Persona(BaseModel):
    mbti_type = models.CharField(max_length=4, blank=True)  # ✅ POLE EXISTUJE
    # ❌ Ale enum definice nenalezena v grep výstupu
```

**Status:** ⚠️ Pole v databázi existuje, ale enum třída nebyla nalezena

#### ❌ PersonaStatus - KRITICKÝ ROZDÍL

**Dokument popisuje:**
```python
class PersonaStatus(models.TextChoices):
    GENERATED = 'generated', 'Vygenerována'   # ❌ CHYBÍ
    SELECTED = 'selected', 'Vybrána'          # ❌ CHYBÍ
    ACTIVE = 'active', 'Aktivní'              # ✅ OK
    INACTIVE = 'inactive', 'Neaktivní'        # ❌ CHYBÍ
    ARCHIVED = 'archived', 'Archivována'      # ✅ OK
```

**Realita:**
```python
# apps/personas/enums.py (SKUTEČNÝ STAV)
class PersonaStatus(models.TextChoices):
    DRAFT = 'draft', 'Koncept'                # ➕ NOVÉ (v dokumentu chybí)
    ACTIVE = 'active', 'Aktivní'              # ✅ OK
    ARCHIVED = 'archived', 'Archivována'      # ✅ OK
    # ❌ GENERATED, SELECTED, INACTIVE neexistují
```

**Porovnání:**

| Hodnota | Dokument | Realita |
|---------|----------|---------|
| `GENERATED` | ✅ | ❌ CHYBÍ |
| `SELECTED` | ✅ | ❌ CHYBÍ |
| `ACTIVE` | ✅ | ✅ OK |
| `INACTIVE` | ✅ | ❌ CHYBÍ |
| `ARCHIVED` | ✅ | ✅ OK |
| `DRAFT` | ❌ CHYBÍ | ✅ EXISTUJE |

**Impact:**
- Workflow person je jednodušší: `DRAFT` → `ACTIVE` → `ARCHIVED`
- Chybí `GENERATED` a `SELECTED` stavy z AI workflow

#### ❌ Detail Persona Enums - NEEXISTUJÍ

**Dokument popisuje:**
```python
class VocabularyLevel(models.TextChoices):     # ❌ NEEXISTUJE
    ACADEMIC = 'academic'
    STREET_SLANG = 'street_slang'
    CORPORATE_SPEAK = 'corporate_speak'
    TECHNICAL = 'technical'

class SentencePreference(models.TextChoices):  # ❌ NEEXISTUJE
    SHORT_PUNCHY = 'short_punchy'
    LONG_COMPLEX = 'long_complex'
    CHAOTIC = 'chaotic'

class ArgumentStructure(models.TextChoices):   # ❌ NEEXISTUJE
    DATA_DRIVEN = 'data_driven'
    STORY_DRIVEN = 'story_driven'
    EMOTION_DRIVEN = 'emotion_driven'

class ArtStyleName(models.TextChoices):        # ❌ NEEXISTUJE
    MINIMALIST_CORPORATE = 'minimalist_corporate'
    CYBERPUNK = 'cyberpunk'
    # ... + 5 more

class ColorPalette(models.TextChoices):        # ❌ NEEXISTUJE
    NEON_DARK = 'neon_dark'
    # ... + 5 more

class VisualAtmosphere(models.TextChoices):    # ❌ NEEXISTUJE
    CHAOTIC = 'chaotic'
    # ... + 6 more
```

**Realita:**
```python
# apps/personas/enums.py (SKUTEČNÝ STAV)
# ❌ ŽÁDNÝ Z TĚCHTO ENUMŮ NEEXISTUJE
```

**Status:** ❌ Všechny detailní persona enums chybí

**Důsledek:**
- Persony jsou jednodušší bez těchto atributů
- Nebo atributy jsou stored jako free-text/JSON místo enumů

---

### 7.4 Content Enums - ČÁSTEČNĚ (60%)

#### ⚠️ ContentStatus - CHYBÍ 2 HODNOTY

**Dokument popisuje:**
```python
class ContentStatus(models.TextChoices):
    DRAFT = 'draft', 'Koncept'                           # ✅ OK
    PENDING = 'pending', 'Čeká'                          # ❌ CHYBÍ
    GENERATING = 'generating', 'Generuje se'             # ✅ OK
    PENDING_APPROVAL = 'pending_approval', 'Čeká na schválení'  # ✅ OK
    APPROVED = 'approved', 'Schváleno'                   # ✅ OK
    REJECTED = 'rejected', 'Zamítnuto'                   # ✅ OK
    PUBLISHED = 'published', 'Publikováno'               # ✅ OK
    FAILED = 'failed', 'Selhalo'                         # ✅ OK
    ARCHIVED = 'archived', 'Archivováno'                 # ❌ CHYBÍ
```

**Realita:**
```python
# apps/content/enums.py (SKUTEČNÝ STAV)
class ContentStatus(models.TextChoices):
    DRAFT = 'draft', 'Koncept'                           # ✅ OK
    # ❌ PENDING CHYBÍ
    GENERATING = 'generating', 'Generuje se'             # ✅ OK
    PENDING_APPROVAL = 'pending_approval', 'Čeká na schválení'  # ✅ OK
    APPROVED = 'approved', 'Schváleno'                   # ✅ OK
    REJECTED = 'rejected', 'Zamítnuto'                   # ✅ OK
    PUBLISHED = 'published', 'Publikováno'               # ✅ OK
    FAILED = 'failed', 'Selhalo'                         # ✅ OK
    # ❌ ARCHIVED CHYBÍ
```

**Porovnání:**

| Hodnota | Dokument | Realita | Note |
|---------|----------|---------|------|
| `DRAFT` | ✅ | ✅ | OK |
| `PENDING` | ✅ | ❌ | CHYBÍ |
| `GENERATING` | ✅ | ✅ | OK |
| `PENDING_APPROVAL` | ✅ | ✅ | OK |
| `APPROVED` | ✅ | ✅ | OK |
| `REJECTED` | ✅ | ✅ | OK |
| `PUBLISHED` | ✅ | ✅ | OK |
| `FAILED` | ✅ | ✅ | OK |
| `ARCHIVED` | ✅ | ❌ | CHYBÍ |

**Shoda:** 7/9 = 78%

**Impact:**
- Chybí `PENDING` pre-queue stav
- Chybí `ARCHIVED` pro archivaci obsahu

#### ⚠️ SocialPlatform - CHYBÍ 2 PLATFORMY

**Dokument popisuje:**
```python
class SocialPlatform(models.TextChoices):
    FACEBOOK = 'facebook', 'Facebook'      # ✅ OK
    INSTAGRAM = 'instagram', 'Instagram'   # ✅ OK
    LINKEDIN = 'linkedin', 'LinkedIn'      # ✅ OK
    TWITTER = 'twitter', 'Twitter/X'       # ✅ OK
    TIKTOK = 'tiktok', 'TikTok'            # ✅ OK
    YOUTUBE = 'youtube', 'YouTube'         # ❌ CHYBÍ
    PINTEREST = 'pinterest', 'Pinterest'   # ❌ CHYBÍ
```

**Realita:**
```python
# apps/content/enums.py (SKUTEČNÝ STAV)
class SocialPlatform(models.TextChoices):
    FACEBOOK = 'facebook', 'Facebook'      # ✅ OK
    INSTAGRAM = 'instagram', 'Instagram'   # ✅ OK
    LINKEDIN = 'linkedin', 'LinkedIn'      # ✅ OK
    TWITTER = 'twitter', 'Twitter/X'       # ✅ OK
    TIKTOK = 'tiktok', 'TikTok'            # ✅ OK
    # ❌ YOUTUBE CHYBÍ
    # ❌ PINTEREST CHYBÍ
```

**Shoda:** 5/7 = 71%

**Impact:**
- YouTube a Pinterest nejsou podporované platformy
- Nebo budou přidány v budoucnu

#### ❌ Content Detail Enums - NEEXISTUJÍ

**Dokument popisuje:**
```python
class SearchIntent(models.TextChoices):    # ❌ NEEXISTUJE
    INFORMATIONAL = 'informational'
    COMMERCIAL = 'commercial'
    TRANSACTIONAL = 'transactional'
    NAVIGATIONAL = 'navigational'

class SectionType(models.TextChoices):     # ❌ NEEXISTUJE
    INTRO = 'intro'
    BODY = 'body'
    CONCLUSION = 'conclusion'
    FAQ = 'faq'
    CTA = 'cta'

class MediaType(models.TextChoices):       # ❌ NEEXISTUJE
    IMAGE = 'image'
    VIDEO = 'video'
    CAROUSEL = 'carousel'
```

**Realita:**
```python
# apps/content/enums.py (SKUTEČNÝ STAV)
# ❌ ŽÁDNÝ Z TĚCHTO ENUMŮ NEEXISTUJE
```

**Status:** ❌ Content detail enums chybí

**Důsledek:**
- BlogPost nemá strukturované sekce (nebo je to free-text)
- SearchIntent není trackován
- MediaType není enum (může být CharField)

---

### 7.5 AI Enums - KRITICKÉ ROZDÍLY (30%)

#### ⚠️ JobStatus - JINÉ HODNOTY

**Dokument popisuje:**
```python
class JobStatus(models.TextChoices):
    PENDING = 'pending', 'Čeká'            # ✅ OK
    QUEUED = 'queued', 'Ve frontě'         # ❌ CHYBÍ
    GENERATING = 'generating', 'Generuje se'  # ❌ → PROCESSING
    COMPLETED = 'completed', 'Dokončeno'   # ✅ OK
    FAILED = 'failed', 'Selhalo'           # ✅ OK
    TIMEOUT = 'timeout', 'Timeout'         # ❌ CHYBÍ
    CANCELLED = 'cancelled', 'Zrušeno'     # ✅ OK
```

**Realita:**
```python
# apps/ai_gateway/enums.py (SKUTEČNÝ STAV)
class JobStatus(models.TextChoices):
    PENDING = 'pending', 'Čeká'            # ✅ OK
    # ❌ QUEUED CHYBÍ
    PROCESSING = 'processing', 'Zpracovává se'  # ➕ MÍSTO GENERATING
    COMPLETED = 'completed', 'Dokončeno'   # ✅ OK
    FAILED = 'failed', 'Selhalo'           # ✅ OK
    # ❌ TIMEOUT CHYBÍ
    CANCELLED = 'cancelled', 'Zrušeno'     # ✅ OK
```

**Porovnání:**

| Hodnota | Dokument | Realita | Note |
|---------|----------|---------|------|
| `PENDING` | ✅ | ✅ | OK |
| `QUEUED` | ✅ | ❌ | CHYBÍ |
| `GENERATING` | ✅ | ❌ | → PROCESSING |
| `PROCESSING` | ❌ | ✅ | NOVÉ |
| `COMPLETED` | ✅ | ✅ | OK |
| `FAILED` | ✅ | ✅ | OK |
| `TIMEOUT` | ✅ | ❌ | CHYBÍ |
| `CANCELLED` | ✅ | ✅ | OK |

**Shoda:** 5/7 = 71%

**Kritický rozdíl:**
- `GENERATING` → `PROCESSING` (jiný název pro stejný stav)
- Chybí `QUEUED` a `TIMEOUT` stavy

#### ❌ JobType - KOMPLETNĚ JINÝ NAMING

**Dokument popisuje:**
```python
class JobType(models.TextChoices):
    PERSONAS = 'personas', 'Generování person'         # ❌ → GENERATE_PERSONAS
    TOPICS = 'topics', 'Generování témat'              # ❌ → GENERATE_TOPICS
    BLOGPOST = 'blogpost', 'Generování blogpostu'      # ❌ → GENERATE_BLOGPOST
    SOCIAL_POST = 'social_post', 'Generování social postu'  # ❌ → GENERATE_SOCIAL
    IMAGE = 'image', 'Generování obrázku'              # ❌ → GENERATE_IMAGE
    VIDEO = 'video', 'Generování videa'                # ❌ → GENERATE_VIDEO
    COMPANY_SCRAPE = 'company_scrape', 'Scraping firmy'  # ❌ → SCRAPE_DNA
```

**Realita:**
```python
# apps/ai_gateway/enums.py (SKUTEČNÝ STAV)
class JobType(models.TextChoices):
    SCRAPE_DNA = 'scrape_dna', 'Scraping firmy'           # ➕ JINÝ NÁZEV
    GENERATE_PERSONAS = 'generate_personas', 'Generování person'  # ➕ PREFIX
    GENERATE_TOPICS = 'generate_topics', 'Generování témat'       # ➕ PREFIX
    GENERATE_BLOGPOST = 'generate_blogpost', 'Generování blogpostu'  # ➕ PREFIX
    GENERATE_SOCIAL = 'generate_social', 'Generování social postu'   # ➕ PREFIX
    GENERATE_IMAGE = 'generate_image', 'Generování obrázku'      # ➕ PREFIX
    GENERATE_VIDEO = 'generate_video', 'Generování videa'        # ➕ PREFIX
```

**Porovnání:**

| Dokument | Realita | Note |
|----------|---------|------|
| `PERSONAS` | `GENERATE_PERSONAS` | Prefix přidán |
| `TOPICS` | `GENERATE_TOPICS` | Prefix přidán |
| `BLOGPOST` | `GENERATE_BLOGPOST` | Prefix přidán |
| `SOCIAL_POST` | `GENERATE_SOCIAL` | Prefix + zkráceno |
| `IMAGE` | `GENERATE_IMAGE` | Prefix přidán |
| `VIDEO` | `GENERATE_VIDEO` | Prefix přidán |
| `COMPANY_SCRAPE` | `SCRAPE_DNA` | Úplně jiný název |

**Shoda:** 0/7 = 0% (všechny hodnoty mají jiný naming)

**Naming convention:**
- Realita používá **verb-first** pattern: `GENERATE_*`, `SCRAPE_*`
- Dokument používá **noun-only** pattern: `PERSONAS`, `TOPICS`, etc.

**Impact:**
- Backend kód funguje správně s `GENERATE_*` prefixem
- Frontend musí používat správné hodnoty
- Dokumentace je matoucí

#### ❌ AIProvider - NEEXISTUJE

**Dokument popisuje:**
```python
class AIProvider(models.TextChoices):
    GEMINI = 'gemini', 'Google Gemini'
    PERPLEXITY = 'perplexity', 'Perplexity'
    NANOBANA = 'nanobana', 'Nanobana (Imagen)'
    VEO = 'veo', 'Veo 3'
```

**Realita:**
```python
# apps/ai_gateway/enums.py (SKUTEČNÝ STAV)
# ❌ AIProvider enum NEEXISTUJE
```

**Status:** ❌ Enum nenalezen v grep výstupu

**Možnost:**
- Provider je hardcoded v kódu
- Nebo je to CharField bez enumů

---

### 7.6 Billing Enums - ROZDÍLY (40%)

#### ⚠️ SubscriptionTier - JINÝ NÁZEV

**Dokument popisuje:**
```python
class SubscriptionTier(models.TextChoices):
    BASIC = 'basic', 'Basic'               # ✅ OK
    PRO = 'pro', 'Pro'                     # ✅ OK
    ULTIMATE = 'ultimate', 'Ultimate'      # ❌ → ENTERPRISE
```

**Realita:**
```python
# apps/billing/models.py nebo enums.py (SKUTEČNÝ STAV)
class SubscriptionTier(models.TextChoices):
    BASIC = 'basic', 'Basic'               # ✅ OK
    PRO = 'pro', 'Pro'                     # ✅ OK
    ENTERPRISE = 'enterprise', 'Enterprise'  # ➕ MÍSTO ULTIMATE
```

**Porovnání:**

| Dokument | Realita |
|----------|---------|
| `BASIC` | ✅ `BASIC` |
| `PRO` | ✅ `PRO` |
| `ULTIMATE` | ❌ → `ENTERPRISE` |

**Shoda:** 2/3 = 67%

**Důvod změny:**
- `ENTERPRISE` je běžnější termín v B2B SaaS
- `ULTIMATE` zní consumer-friendly

#### ⚠️ SubscriptionStatus & BillingCycle - dj-stripe

**Dokument popisuje:**
```python
class SubscriptionStatus(models.TextChoices):
    TRIALING = 'trialing', 'Trial'
    ACTIVE = 'active', 'Aktivní'
    PAST_DUE = 'past_due', 'Po splatnosti'
    CANCELED = 'canceled', 'Zrušeno'
    UNPAID = 'unpaid', 'Nezaplaceno'

class BillingCycle(models.TextChoices):
    MONTHLY = 'monthly', 'Měsíčně'
    YEARLY = 'yearly', 'Ročně'
```

**Realita:**
```python
# apps/billing/ (PRAVDĚPODOBNÝ STAV)
# ⚠️ Používá se dj-stripe package
# SubscriptionStatus a BillingCycle pravděpodobně z dj-stripe
# Nenalezeno v grep výstupu custom definic
```

**Status:** ⚠️ Likely používá dj-stripe enums, ne custom

**dj-stripe standardní hodnoty:**
- SubscriptionStatus: `trialing`, `active`, `past_due`, `canceled`, `unpaid`, `incomplete`, `incomplete_expired`
- BillingCycle: Stripe používá `month`, `year` (ne `monthly`, `yearly`)

---

### 7.7 TypeScript - Frontend Enums

#### ❌ Frontend Enum Files - NEEXISTUJÍ

**Dokument popisuje:**
```typescript
// src/app/data/enums/user.enums.ts       // ❌ NEEXISTUJE
// src/app/data/enums/persona.enums.ts    // ❌ NEEXISTUJE
// src/app/data/enums/content.enums.ts    // ❌ NEEXISTUJE
// src/app/data/enums/ai.enums.ts         // ❌ NEEXISTUJE
// src/app/data/enums/billing.enums.ts    // ❌ NEEXISTUJE
```

**Realita:**
```bash
# Frontend struktura (SKUTEČNÝ STAV)
src/app/data/enums/    # ❌ FOLDER NEEXISTUJE
```

**Status:** ❌ Celá enum struktura ve frontendu chybí

**Možné scénáře:**
1. Enums jsou **inline** v jednotlivých komponentách
2. Enums jsou **importované z API** jako typy
3. Používají se **string literals** místo enumů
4. Frontend struktura je jiná než plánováno

**Důsledek:**
- Chybí centrální místo pro enum definice
- Risk inconsistency mezi backend a frontend
- Každý dev může definovat vlastní string literals

---

### 7.8 TypeScript Interfaces - NEPŘESNÉ (20%)

#### ❌ Topic Interface - ROZDÍLY

**Dokument popisuje:**
```typescript
export interface Topic {
  id: string;
  calendarId: string;              // ❌ Calendar neexistuje
  personaId?: string;
  personaName?: string;
  title: string;
  description?: string;
  keywords: string[];              // ✅ OK (array)
  focusKeyword?: string;           // ❌ Je 'keywords' array
  searchIntent?: SearchIntent;     // ❌ SearchIntent enum neexistuje
  plannedDate?: string;
  status: ContentStatus;
}
```

**Realita:**
```python
# apps/content/models.py (SKUTEČNÝ STAV)
class Topic(BaseModel):
    company = models.ForeignKey(...)         # ✅ OK
    persona = models.ForeignKey(...)         # ✅ OK
    title = models.CharField(...)            # ✅ OK
    description = models.TextField(...)      # ✅ OK
    keywords = models.JSONField(...)         # ✅ OK (array)
    # ❌ calendarId NEEXISTUJE
    # ❌ focusKeyword JE keywords array
    # ❌ searchIntent NEEXISTUJE
    planned_date = models.DateField(...)     # ✅ OK
    status = models.CharField(...)           # ✅ OK
```

**Rozdíly:**

| Field | Dokument | Realita | Status |
|-------|----------|---------|--------|
| `calendarId` | ✅ | ❌ CHYBÍ | Calendar feature neexistuje |
| `focusKeyword` | ✅ (string) | ❌ (keywords array) | Jiný design |
| `searchIntent` | ✅ (enum) | ❌ CHYBÍ | Enum neexistuje |

#### ❌ BlogPost Interface - ZÁSADNÍ ROZDÍLY

**Dokument popisuje:**
```typescript
export interface BlogPost {
  id: string;
  topicId: string;
  title: string;
  slug: string;
  metaTitle?: string;
  metaDescription?: string;
  focusKeyword?: string;
  seoScore?: number;              // ❌ NEEXISTUJE
  wordCount: number;
  readingTimeMinutes: number;
  status: ContentStatus;
  sections: BlogPostSection[];    // ❌ NEPOUŽÍVÁ SE
  faqs: BlogPostFaq[];            // ❌ NEEXISTUJE
  persona?: Persona;
}

export interface BlogPostSection {  // ❌ NEPOUŽÍVÁ SE
  id: string;
  sectionType: SectionType;
  sectionOrder: number;
  heading?: string;
  headingLevel?: number;
  content: string;
  wordCount: number;
}

export interface BlogPostFaq {      // ❌ NEEXISTUJE
  question: string;
  answer: string;
}
```

**Realita:**
```python
# apps/content/models.py (SKUTEČNÝ STAV)
class BlogPost(BaseModel):
    topic = models.ForeignKey(...)           # ✅ OK
    title = models.CharField(...)            # ✅ OK
    slug = models.SlugField(...)             # ✅ OK
    meta_title = models.CharField(...)       # ✅ OK
    meta_description = models.TextField(...) # ✅ OK
    content = models.TextField(...)          # ➕ JEDEN FIELD
    # ❌ focusKeyword - používá se topic.keywords
    # ❌ seoScore NEEXISTUJE
    word_count = models.IntegerField(...)    # ✅ OK
    reading_time = models.IntegerField(...)  # ✅ OK
    status = models.CharField(...)           # ✅ OK
    # ❌ sections NEEXISTUJÍ jako separate model
    # ❌ faqs NEEXISTUJÍ
```

**Kritické rozdíly:**

| Feature | Dokument | Realita | Impact |
|---------|----------|---------|--------|
| **sections[]** | BlogPostSection[] | `content` TextField | Flat místo structured |
| **faqs[]** | BlogPostFaq[] | ❌ CHYBÍ | FAQ feature není |
| **seoScore** | number | ❌ CHYBÍ | SEO scoring není |

**Důsledek:**
- BlogPost má **flat content**, ne strukturované sections
- **FAQ není separate** feature
- **SEO score není kalkulován**

#### ⚠️ SubscriptionPlan Interface - ROZDÍL

**Dokument popisuje:**
```typescript
export interface SubscriptionPlan {
  id: string;
  code: string;
  name: string;
  tier: SubscriptionTier;         // ❌ Je 'code' v realitě
  priceMonthly: number;
  priceYearly?: number;
  maxPersonas: number;
  maxPostsPerMonth: number;
  includesImages: boolean;
  includesVideo: boolean;
}
```

**Realita:**
```python
# apps/billing/models.py nebo dj-stripe (PRAVDĚPODOBNÝ STAV)
# ⚠️ Používá dj-stripe models
# Plan má 'code' field, ne 'tier' enum
```

**Rozdíl:**
- Dokument: `tier: SubscriptionTier` (enum)
- Realita: `code: string` (basic/pro/enterprise jako string)

---

### 7.9 Porovnání: Plánované vs Skutečné Enums

#### Backend Python Enums

| Enum | Dokument Values | Realita Values | Shoda | Kritický rozdíl |
|------|----------------|----------------|-------|-----------------|
| **UserRole** | 4 | 4 | ✅ 100% | Žádný |
| **JungArchetype** | 12 | 12 | ✅ 100% | Žádný |
| **MBTIType** | 16 | Pole v DB | ⚠️ | Enum def missing |
| **PersonaStatus** | 5 | 3 | ⚠️ 60% | DRAFT místo GENERATED/SELECTED |
| **VocabularyLevel** | 4 | 0 | ❌ 0% | Neexistuje |
| **SentencePreference** | 3 | 0 | ❌ 0% | Neexistuje |
| **ArgumentStructure** | 3 | 0 | ❌ 0% | Neexistuje |
| **ArtStyleName** | 7 | 0 | ❌ 0% | Neexistuje |
| **ColorPalette** | 6 | 0 | ❌ 0% | Neexistuje |
| **VisualAtmosphere** | 7 | 0 | ❌ 0% | Neexistuje |
| **ContentStatus** | 9 | 7 | ⚠️ 78% | PENDING, ARCHIVED chybí |
| **SocialPlatform** | 7 | 5 | ⚠️ 71% | YOUTUBE, PINTEREST chybí |
| **SearchIntent** | 4 | 0 | ❌ 0% | Neexistuje |
| **SectionType** | 5 | 0 | ❌ 0% | Neexistuje |
| **MediaType** | 3 | 0 | ❌ 0% | Neexistuje |
| **JobStatus** | 7 | 5 | ⚠️ 71% | PROCESSING místo GENERATING |
| **JobType** | 7 | 7 | ⚠️ 100%* | *Jiný naming (GENERATE_ prefix) |
| **AIProvider** | 4 | 0 | ❌ 0% | Neexistuje |
| **SubscriptionTier** | 3 | 3 | ⚠️ 67% | ENTERPRISE místo ULTIMATE |
| **SubscriptionStatus** | 5 | dj-stripe | ⚠️ | Likely dj-stripe |
| **BillingCycle** | 2 | dj-stripe | ⚠️ | Likely dj-stripe |

#### Frontend TypeScript

| Feature | Dokument | Realita | Status |
|---------|----------|---------|--------|
| **Enum folder structure** | ✅ src/app/data/enums/ | ❌ NEEXISTUJE | ❌ |
| **user.enums.ts** | ✅ | ❌ | ❌ |
| **persona.enums.ts** | ✅ | ❌ | ❌ |
| **content.enums.ts** | ✅ | ❌ | ❌ |
| **ai.enums.ts** | ✅ | ❌ | ❌ |
| **billing.enums.ts** | ✅ | ❌ | ❌ |
| **TypeScript interfaces** | ✅ Detailed | ⚠️ Nepřesné | ⚠️ |

---

### 7.10 Missing Enums - Impact Analysis

#### 🔴 CRITICAL Missing Enums

| Enum | Use Case | Impact |
|------|----------|--------|
| **AIProvider** | Track which AI service used | Can't report by provider |
| **SectionType** | Structured blog sections | Flat content instead |
| **MediaType** | Social media types | Probably CharField |

#### 🟡 MEDIUM Missing Enums

| Enum | Use Case | Impact |
|------|----------|--------|
| **SearchIntent** | SEO optimization | Can't categorize by intent |
| **VocabularyLevel** | Persona voice tuning | Simpler personas |
| **ArgumentStructure** | Content style | Simpler personas |
| **SentencePreference** | Writing style | Simpler personas |

#### 🟢 LOW Missing Enums (Nice to have)

| Enum | Use Case | Impact |
|------|----------|--------|
| **ArtStyleName** | Visual style for images | Free text or hardcoded |
| **ColorPalette** | Color schemes | Free text or hardcoded |
| **VisualAtmosphere** | Image mood | Free text or hardcoded |

---

### 7.11 Naming Convention Issues

#### Backend JobType - Inconsistency

**Problem:**
```python
# Dokument říká:
PERSONAS = 'personas'
TOPICS = 'topics'
BLOGPOST = 'blogpost'

# Realita má:
GENERATE_PERSONAS = 'generate_personas'
GENERATE_TOPICS = 'generate_topics'
GENERATE_BLOGPOST = 'generate_blogpost'
```

**Impact:**
- Frontend musí používat `GENERATE_*` konstanty
- API responses obsahují `generate_personas` ne `personas`
- Matoucí pro developery

**Doporučení:**
- Buď updatovat dokument na `GENERATE_*`
- Nebo refactor backend na simple naming

#### PersonaStatus vs ContentStatus Inconsistency

**Problem:**
```python
# PersonaStatus používá:
DRAFT, ACTIVE, ARCHIVED

# ContentStatus používá:
DRAFT, GENERATING, PENDING_APPROVAL, APPROVED, REJECTED, PUBLISHED, FAILED
```

**Design question:**
- Proč `PersonaStatus` nemá `GENERATED` stav?
- Měly by být konzistentní?

---

### 7.12 Frontend Integration Gaps

#### ❌ No Centralized Enum Definitions

**Problem:**
```typescript
// Očekává se:
import { UserRole } from '@/data/enums/user.enums';

// Realita (pravděpodobně):
const role = 'admin'; // ❌ String literal
// nebo
type UserRole = 'admin' | 'manager' | 'marketer' | 'supervisor'; // ❌ Inline
```

**Impact:**
- Žádná single source of truth
- Risk typo: `'manger'` místo `'manager'`
- Těžší refactoring

#### ⚠️ PlatformLimits Helper Missing

**Dokument popisuje:**
```typescript
export const PlatformLimits: Record<SocialPlatform, { maxLength: number; maxHashtags: number }> = {
  [SocialPlatform.FACEBOOK]: { maxLength: 63206, maxHashtags: 30 },
  // ...
};
```

**Status:** ❓ Pravděpodobně chybí

**Impact:**
- Frontend validace musí být hardcoded
- Nebo duplicated logic

---

### 7.13 Migration Plan: Align Enums

#### Phase 1: Fix Critical Naming (Week 1)

```python
# 1. Dokumentovat skutečné JobType values
# apps/ai_gateway/enums.py
class JobType(models.TextChoices):
    SCRAPE_DNA = 'scrape_dna', 'Scraping firmy'
    GENERATE_PERSONAS = 'generate_personas', 'Generování person'
    GENERATE_TOPICS = 'generate_topics', 'Generování témat'
    GENERATE_BLOGPOST = 'generate_blogpost', 'Generování blogpostu'
    GENERATE_SOCIAL = 'generate_social', 'Generování social postu'
    GENERATE_IMAGE = 'generate_image', 'Generování obrázku'
    GENERATE_VIDEO = 'generate_video', 'Generování videa'

# 2. Fix PersonaStatus
class PersonaStatus(models.TextChoices):
    DRAFT = 'draft', 'Koncept'
    ACTIVE = 'active', 'Aktivní'
    ARCHIVED = 'archived', 'Archivována'

# 3. Fix SubscriptionTier
class SubscriptionTier(models.TextChoices):
    BASIC = 'basic', 'Basic'
    PRO = 'pro', 'Pro'
    ENTERPRISE = 'enterprise', 'Enterprise'  # NE ULTIMATE
```

#### Phase 2: Add Missing Platform Support (Week 2-3)

```python
# Decide: Do we want YouTube and Pinterest?
class SocialPlatform(models.TextChoices):
    FACEBOOK = 'facebook', 'Facebook'
    INSTAGRAM = 'instagram', 'Instagram'
    LINKEDIN = 'linkedin', 'LinkedIn'
    TWITTER = 'twitter', 'Twitter/X'
    TIKTOK = 'tiktok', 'TikTok'
    # TODO: Add if needed
    # YOUTUBE = 'youtube', 'YouTube'
    # PINTEREST = 'pinterest', 'Pinterest'
```

#### Phase 3: Create Frontend Enums (Week 3-4)

```bash
# Create enum files
mkdir -p src/app/data/enums

# src/app/data/enums/user.enums.ts
export enum UserRole {
  ADMIN = 'admin',
  MANAGER = 'manager',
  MARKETER = 'marketer',
  SUPERVISOR = 'supervisor',
}

# src/app/data/enums/ai.enums.ts
export enum JobType {
  SCRAPE_DNA = 'scrape_dna',
  GENERATE_PERSONAS = 'generate_personas',
  GENERATE_TOPICS = 'generate_topics',
  GENERATE_BLOGPOST = 'generate_blogpost',
  GENERATE_SOCIAL = 'generate_social',
  GENERATE_IMAGE = 'generate_image',
  GENERATE_VIDEO = 'generate_video',
}

export enum JobStatus {
  PENDING = 'pending',
  PROCESSING = 'processing',  // NE GENERATING
  COMPLETED = 'completed',
  FAILED = 'failed',
  CANCELLED = 'cancelled',
}

# src/app/data/enums/content.enums.ts
export const PlatformLimits: Record<SocialPlatform, { maxLength: number; maxHashtags: number }> = {
  [SocialPlatform.FACEBOOK]: { maxLength: 63206, maxHashtags: 30 },
  [SocialPlatform.INSTAGRAM]: { maxLength: 2200, maxHashtags: 30 },
  [SocialPlatform.LINKEDIN]: { maxLength: 3000, maxHashtags: 5 },
  [SocialPlatform.TWITTER]: { maxLength: 280, maxHashtags: 2 },
  [SocialPlatform.TIKTOK]: { maxLength: 2200, maxHashtags: 5 },
};
```

#### Phase 4: Decide on Missing Enums (Month 2)

**Decision matrix:**

| Enum | Implement? | Reason |
|------|------------|--------|
| **VocabularyLevel** | ⚠️ Maybe | If persona detail needed |
| **SentencePreference** | ⚠️ Maybe | If persona detail needed |
| **ArgumentStructure** | ⚠️ Maybe | If persona detail needed |
| **ArtStyleName** | ❌ No | Free text is fine |
| **ColorPalette** | ❌ No | Free text is fine |
| **VisualAtmosphere** | ❌ No | Free text is fine |
| **SearchIntent** | ✅ Yes | Useful for SEO |
| **SectionType** | ⚠️ Maybe | If structured content needed |
| **MediaType** | ✅ Yes | Should be enum |
| **AIProvider** | ✅ Yes | For analytics |

---

### 7.14 Action Items - Enum Alignment

#### Immediate (týdny)

- [ ] **CRITICAL:** Update dokumentace pro `JobType` naming (GENERATE_ prefix)
- [ ] **CRITICAL:** Update dokumentace pro `PersonaStatus` (DRAFT, ACTIVE, ARCHIVED)
- [ ] **CRITICAL:** Update dokumentace pro `SubscriptionTier` (ENTERPRISE ne ULTIMATE)
- [ ] Fix `JobStatus`: dokumentovat `PROCESSING` místo `GENERATING`
- [ ] Remove neexistující enums z dokumentace (VocabularyLevel, ArtStyleName, etc.)

#### Short-term (měsíce)

- [ ] Create frontend enum files structure
- [ ] Implement `AIProvider` enum
- [ ] Implement `SearchIntent` enum
- [ ] Implement `MediaType` enum
- [ ] Add `YOUTUBE`, `PINTEREST` support decision
- [ ] Fix TypeScript interfaces (Topic, BlogPost)

#### Long-term (6+ měsíců)

- [ ] Decide on persona detail enums (VocabularyLevel, etc.)
- [ ] Consider structured BlogPost sections
- [ ] Evaluate SEO scoring feature
- [ ] Full frontend-backend enum sync validation

---

**📊 ZÁVĚR:**

Dokument 11_ENUMS_TYPES.md popisuje **PLÁNOVANOU** strukturu enumů.  
**Skutečný stav má ~40-45% shodu** s dokumentem.  

**Co má přesnou shodu:**
- ✅ UserRole (100%)
- ✅ JungArchetype (100%)

**Co má jiné názvy:**
- ⚠️ JobType: `GENERATE_*` prefix vs simple names
- ⚠️ JobStatus: `PROCESSING` vs `GENERATING`
- ⚠️ SubscriptionTier: `ENTERPRISE` vs `ULTIMATE`

**Co úplně chybí:**
- ❌ 9+ persona detail enums (VocabularyLevel, ArtStyleName, etc.)
- ❌ Content detail enums (SearchIntent, SectionType, MediaType)
- ❌ AIProvider enum
- ❌ Celá frontend enum struktura

**Priorita:** Update dokumentace na skutečné hodnoty ASAP pro konzistenci.

---

## 📌 QUICK REFERENCE

### Barrel Exports

```typescript
// src/app/data/enums/index.ts
export * from './user.enums';
export * from './persona.enums';
export * from './content.enums';
export * from './ai.enums';
export * from './billing.enums';

// src/app/data/models/index.ts
export * from './user.model';
export * from './persona.model';
export * from './content.model';
export * from './billing.model';
```

---

*Tento dokument je SELF-CONTAINED.*
