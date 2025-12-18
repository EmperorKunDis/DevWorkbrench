# PostHub.work - Kompletní seznam UI/UX komponent

**Verze:** 1.0  
**Framework:** Angular 17+ (Standalone Components, Signals API)  
**Styling:** Tailwind CSS + Angular Material  
**Design System:** PostHub Visual Book v3.0

**Aktuální stav implementace:**
- ✅ **Angular verze** - Angular **19.0.6** (ne 17+, novější!)
- ❌ **Angular Material NENÍ používán** - Pouze Tailwind CSS!
- ❌ **@angular/material NENÍ v package.json**
- ❌ **@angular/cdk NENÍ v package.json**
- ✅ **Tailwind CSS** - Ano, používá se
- ✅ **Standalone Components** - Ano
- ⚠️ **Signals API** - Angular 19 má signals, pravděpodobně používáno

**🔴 KRITICKÝ ROZDÍL - Styling Stack:**

```
PLÁN:     Tailwind CSS + Angular Material
REALITA:  Tailwind CSS POUZE (bez Angular Material!)

PLÁN:
{
  "@angular/material": "^17.0.0",
  "@angular/cdk": "^17.0.0"
}

REALITA:
{
  "@angular/core": "^19.0.6",
  "tailwindcss": "^3.4.0",
  "@tailwindcss/forms": "^0.5.7"
  // ❌ Žádný @angular/material!
}
```

**Proč bez Angular Material?**
- ✅ **Lightweight** - Menší bundle size
- ✅ **Custom design** - Plná kontrola nad UI
- ✅ **Tailwind first** - Konzistentní s design systemem
- ✅ **No dependency** - Méně závislostí = méně maintenance

---

## Obsah

1. [Základní (Atomic) komponenty](#1-základní-atomic-komponenty)
2. [Layout komponenty](#2-layout-komponenty)
3. [Navigační komponenty](#3-navigační-komponenty)
4. [Formulářové komponenty](#4-formulářové-komponenty)
5. [Data Display komponenty](#5-data-display-komponenty)
6. [Feedback komponenty](#6-feedback-komponenty)
7. [Moduly - Onboarding](#7-modul-onboarding)
8. [Moduly - Companies](#8-modul-companies)
9. [Moduly - Personas](#9-modul-personas)
10. [Moduly - Content Planner](#10-modul-content-planner)
11. [Moduly - Blog Posts](#11-modul-blog-posts)
12. [Moduly - Social Posts](#12-modul-social-posts)
13. [Moduly - Media Factory](#13-modul-media-factory)
14. [Moduly - Approval Center](#14-modul-approval-center)
15. [Moduly - Analytics](#15-modul-analytics)
16. [Moduly - Settings](#16-modul-settings)
17. [Moduly - Subscription](#17-modul-subscription)
18. [Moduly - User Management](#18-modul-user-management)

---

## 1. Základní (Atomic) komponenty

### 1.1 `ButtonComponent`
**Soubor:** `shared/components/button/button.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `variant` | `'primary' \| 'secondary' \| 'gradient' \| 'outline' \| 'ghost' \| 'danger'` | Vizuální styl tlačítka |
| `size` | `'sm' \| 'md' \| 'lg'` | Velikost (padding, font-size) |
| `loading` | `boolean` | Zobrazí spinner místo textu |
| `disabled` | `boolean` | Deaktivuje interakci |
| `icon` | `string` | Název ikony (prefix/suffix) |
| `iconPosition` | `'left' \| 'right'` | Pozice ikony |
| `fullWidth` | `boolean` | 100% šířka |

**Styly dle Visual Book:**
```css
/* Primary */
background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
box-shadow: 0 4px 15px rgba(59, 130, 246, 0.4);

/* Gradient (premium) */
background: linear-gradient(135deg, #8b5cf6 0%, #3b82f6 35%, #06b6d4 65%, #10b981 100%);
```

**Funkce:**
- Hover efekt: `translateY(-2px)` + zvýšený shadow
- Loading state: Spinner + disabled interakce
- Ripple efekt při kliknutí

---

### 1.2 `InputComponent`
**Soubor:** `shared/components/input/input.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `type` | `'text' \| 'email' \| 'password' \| 'number' \| 'tel' \| 'url'` | Typ inputu |
| `label` | `string` | Floating label |
| `placeholder` | `string` | Placeholder text |
| `hint` | `string` | Pomocný text pod inputem |
| `error` | `string` | Chybová hláška |
| `required` | `boolean` | Povinné pole |
| `disabled` | `boolean` | Deaktivace |
| `icon` | `string` | Ikona vlevo |
| `clearable` | `boolean` | Tlačítko pro vymazání |
| `maxLength` | `number` | Max počet znaků |
| `showCharCount` | `boolean` | Zobrazit počítadlo znaků |

**Styly:**
```css
background: rgba(15, 23, 42, 0.6);
border: 1px solid rgba(148, 163, 184, 0.2);
border-radius: 12px;
/* Focus state */
border-color: #3b82f6;
box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.2);
```

**Stavy:**
- Default, Hover, Focus, Error, Disabled, Readonly

---

### 1.3 `TextareaComponent`
**Soubor:** `shared/components/textarea/textarea.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `label` | `string` | Label |
| `rows` | `number` | Počet řádků (default: 4) |
| `autoResize` | `boolean` | Automatická výška |
| `maxLength` | `number` | Max znaků |
| `showCharCount` | `boolean` | Počítadlo |
| `error` | `string` | Chyba |
| `hint` | `string` | Nápověda |

---

### 1.4 `SelectComponent`
**Soubor:** `shared/components/select/select.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `options` | `SelectOption[]` | `{ value: any, label: string, icon?: string, disabled?: boolean }` |
| `label` | `string` | Label |
| `placeholder` | `string` | Placeholder |
| `multiple` | `boolean` | Vícenásobný výběr |
| `searchable` | `boolean` | Vyhledávání v options |
| `clearable` | `boolean` | Možnost vymazat |
| `groupBy` | `string` | Seskupení options |
| `error` | `string` | Chyba |

**Funkce:**
- Keyboard navigation (šipky, Enter, Escape)
- Virtuální scrolling pro 100+ položek
- Custom template pro options

---

### 1.5 `CheckboxComponent`
**Soubor:** `shared/components/checkbox/checkbox.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `checked` | `boolean` | Stav |
| `indeterminate` | `boolean` | Částečně zaškrtnuté |
| `label` | `string` | Popisek |
| `disabled` | `boolean` | Deaktivace |

---

### 1.6 `ToggleComponent`
**Soubor:** `shared/components/toggle/toggle.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `checked` | `boolean` | Stav |
| `label` | `string` | Popisek |
| `labelPosition` | `'left' \| 'right'` | Pozice labelu |
| `disabled` | `boolean` | Deaktivace |
| `size` | `'sm' \| 'md'` | Velikost |

**Rozměry:**
- Width: 48px, Height: 26px
- Knob: 20px circle

---

### 1.7 `RadioGroupComponent`
**Soubor:** `shared/components/radio-group/radio-group.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `options` | `RadioOption[]` | `{ value: any, label: string, description?: string }` |
| `value` | `any` | Vybraná hodnota |
| `orientation` | `'horizontal' \| 'vertical'` | Orientace |
| `disabled` | `boolean` | Deaktivace |

---

### 1.8 `BadgeComponent`
**Soubor:** `shared/components/badge/badge.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `variant` | `'violet' \| 'blue' \| 'cyan' \| 'green' \| 'success' \| 'warning' \| 'error' \| 'neutral'` | Barva |
| `size` | `'sm' \| 'md'` | Velikost |
| `dot` | `boolean` | Tečka místo textu |
| `removable` | `boolean` | Zobrazit X pro odstranění |
| `icon` | `string` | Ikona |

**Použití:**
- Status stavy (DRAFT, GENERATING, APPROVED...)
- Tagy (keywords, hashtags)
- Počítadla (notifikace)

---

### 1.9 `AvatarComponent`
**Soubor:** `shared/components/avatar/avatar.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `src` | `string` | URL obrázku |
| `name` | `string` | Jméno pro iniciály (fallback) |
| `size` | `'xs' \| 'sm' \| 'md' \| 'lg' \| 'xl'` | Velikost |
| `shape` | `'circle' \| 'square'` | Tvar |
| `status` | `'online' \| 'offline' \| 'busy'` | Online status |
| `badge` | `string \| number` | Badge overlay |

---

### 1.10 `IconComponent`
**Soubor:** `shared/components/icon/icon.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `name` | `string` | Název ikony (Lucide icons) |
| `size` | `number` | Velikost v px |
| `color` | `string` | Barva |
| `spin` | `boolean` | Rotující animace |

---

### 1.11 `TooltipDirective`
**Soubor:** `shared/directives/tooltip.directive.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `phTooltip` | `string` | Text tooltipu |
| `position` | `'top' \| 'bottom' \| 'left' \| 'right'` | Pozice |
| `delay` | `number` | Zpoždění v ms |

---

### 1.12 `ChipComponent`
**Soubor:** `shared/components/chip/chip.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `label` | `string` | Text |
| `removable` | `boolean` | Možnost odstranění |
| `selected` | `boolean` | Vybraný stav |
| `avatar` | `string` | Avatar URL |
| `icon` | `string` | Ikona |
| `variant` | `'filled' \| 'outlined'` | Styl |

---

### 1.13 `ProgressBarComponent`
**Soubor:** `shared/components/progress-bar/progress-bar.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `value` | `number` | Aktuální hodnota (0-100) |
| `max` | `number` | Maximum |
| `showLabel` | `boolean` | Zobrazit % |
| `variant` | `'default' \| 'gradient' \| 'success' \| 'warning' \| 'error'` | Barva |
| `size` | `'sm' \| 'md' \| 'lg'` | Výška |
| `indeterminate` | `boolean` | Neznámý progress |

---

### 1.14 `SpinnerComponent`
**Soubor:** `shared/components/spinner/spinner.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `size` | `'sm' \| 'md' \| 'lg'` | Velikost |
| `color` | `'primary' \| 'white' \| 'current'` | Barva |
| `overlay` | `boolean` | Překrytí celé sekce |

---

### 1.15 `SkeletonComponent`
**Soubor:** `shared/components/skeleton/skeleton.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `variant` | `'text' \| 'circle' \| 'rect' \| 'card'` | Typ |
| `width` | `string` | Šířka |
| `height` | `string` | Výška |
| `lines` | `number` | Počet řádků (pro text) |
| `animated` | `boolean` | Pulse animace |

---

## 2. Layout komponenty

### 2.1 `CardComponent`
**Soubor:** `shared/components/card/card.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `variant` | `'default' \| 'elevated' \| 'outlined' \| 'glass'` | Styl |
| `padding` | `'none' \| 'sm' \| 'md' \| 'lg'` | Vnitřní padding |
| `hoverable` | `boolean` | Hover efekt (translateY) |
| `clickable` | `boolean` | Kurzor pointer |
| `loading` | `boolean` | Skeleton overlay |

**Styly:**
```css
background: linear-gradient(145deg, rgba(30,41,59,0.6) 0%, rgba(15,23,42,0.8) 100%);
backdrop-filter: blur(20px);
border: 1px solid rgba(148, 163, 184, 0.1);
border-radius: 24px;
```

**Části:**
- `<ph-card-header>` - Header s title a actions
- `<ph-card-content>` - Hlavní obsah
- `<ph-card-footer>` - Footer s akcemi

---

### 2.2 `PageLayoutComponent`
**Soubor:** `shared/components/page-layout/page-layout.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `title` | `string` | Nadpis stránky |
| `subtitle` | `string` | Podnapis |
| `breadcrumbs` | `Breadcrumb[]` | Drobečková navigace |
| `actions` | `TemplateRef` | Akční tlačítka vpravo |
| `loading` | `boolean` | Loading state |
| `maxWidth` | `'sm' \| 'md' \| 'lg' \| 'xl' \| 'full'` | Max šířka obsahu |

**Struktura:**
```html
<ph-page-layout title="Content Planner">
  <ng-container actions>
    <ph-button>+ New Topic</ph-button>
  </ng-container>
  
  <!-- Page content here -->
</ph-page-layout>
```

---

### 2.3 `SidebarLayoutComponent`
**Soubor:** `shared/components/sidebar-layout/sidebar-layout.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `sidebarWidth` | `number` | Šířka sidebaru v px |
| `sidebarPosition` | `'left' \| 'right'` | Pozice |
| `collapsible` | `boolean` | Možnost sbalit |
| `collapsed` | `boolean` | Aktuální stav |
| `stickyHeader` | `boolean` | Sticky header |

---

### 2.4 `GridComponent`
**Soubor:** `shared/components/grid/grid.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `columns` | `number \| ResponsiveConfig` | Počet sloupců |
| `gap` | `'sm' \| 'md' \| 'lg'` | Mezera |
| `alignItems` | `'start' \| 'center' \| 'end' \| 'stretch'` | Zarovnání |

---

### 2.5 `DividerComponent`
**Soubor:** `shared/components/divider/divider.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `orientation` | `'horizontal' \| 'vertical'` | Orientace |
| `label` | `string` | Text uprostřed |
| `variant` | `'solid' \| 'dashed' \| 'gradient'` | Styl čáry |

---

### 2.6 `TabsComponent`
**Soubor:** `shared/components/tabs/tabs.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `tabs` | `Tab[]` | `{ id: string, label: string, icon?: string, badge?: number, disabled?: boolean }` |
| `activeTab` | `string` | Aktivní tab ID |
| `variant` | `'default' \| 'pills' \| 'underline'` | Styl |
| `orientation` | `'horizontal' \| 'vertical'` | Orientace |
| `lazy` | `boolean` | Lazy loading obsahu |

**Events:**
- `tabChange: EventEmitter<string>` - Změna tabu

---

### 2.7 `AccordionComponent`
**Soubor:** `shared/components/accordion/accordion.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `items` | `AccordionItem[]` | `{ id: string, title: string, content: TemplateRef, expanded?: boolean }` |
| `multiple` | `boolean` | Více otevřených najednou |
| `expandIcon` | `string` | Ikona pro expand |

---

### 2.8 `EmptyStateComponent`
**Soubor:** `shared/components/empty-state/empty-state.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `icon` | `string` | Ilustrační ikona |
| `title` | `string` | Nadpis |
| `description` | `string` | Popis |
| `action` | `{ label: string, onClick: () => void }` | Akční tlačítko |

---

## 3. Navigační komponenty

### 3.1 `MainNavComponent`
**Soubor:** `core/components/main-nav/main-nav.component.ts`

**Obsah:**
- Logo PostHub (gradient ring verze)
- Hlavní navigační položky:
  - Dashboard
  - Companies
  - Content Planner
  - Approval Center
  - Analytics
  - Settings
- User menu (avatar + dropdown)
- Notifikace icon + badge

**Funkce:**
- Collapsed state (pouze ikony)
- Active route highlighting
- Badge pro pending approvals
- Role-based menu items (Admin vidí User Management)

---

### 3.2 `BreadcrumbsComponent`
**Soubor:** `shared/components/breadcrumbs/breadcrumbs.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `items` | `Breadcrumb[]` | `{ label: string, route?: string, icon?: string }` |
| `separator` | `string` | Oddělovač (default: `/`) |

---

### 3.3 `DropdownMenuComponent`
**Soubor:** `shared/components/dropdown-menu/dropdown-menu.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `trigger` | `TemplateRef` | Element pro trigger |
| `items` | `MenuItem[]` | `{ label: string, icon?: string, action: () => void, divider?: boolean, danger?: boolean }` |
| `position` | `'bottom-start' \| 'bottom-end' \| 'top-start' \| 'top-end'` | Pozice |
| `width` | `string` | Šířka menu |

---

### 3.4 `PaginationComponent`
**Soubor:** `shared/components/pagination/pagination.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `currentPage` | `number` | Aktuální stránka |
| `totalPages` | `number` | Celkový počet stránek |
| `totalItems` | `number` | Celkový počet položek |
| `pageSize` | `number` | Položek na stránku |
| `pageSizeOptions` | `number[]` | Možnosti velikosti |
| `showFirstLast` | `boolean` | Tlačítka první/poslední |
| `showPageSize` | `boolean` | Výběr velikosti stránky |

**Events:**
- `pageChange: EventEmitter<number>`
- `pageSizeChange: EventEmitter<number>`

---

### 3.5 `StepperComponent`
**Soubor:** `shared/components/stepper/stepper.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `steps` | `Step[]` | `{ label: string, description?: string, icon?: string, optional?: boolean }` |
| `activeStep` | `number` | Aktuální krok |
| `orientation` | `'horizontal' \| 'vertical'` | Orientace |
| `linear` | `boolean` | Vyžadovat sekvenční průchod |
| `editable` | `boolean` | Možnost vrátit se zpět |

**Použití:** Onboarding wizard, Multi-step formuláře

---

## 4. Formulářové komponenty

### 4.1 `FormFieldComponent`
**Soubor:** `shared/components/form-field/form-field.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `label` | `string` | Label |
| `required` | `boolean` | Hvězdička |
| `hint` | `string` | Nápověda |
| `error` | `string` | Chybová hláška |
| `orientation` | `'vertical' \| 'horizontal'` | Layout |

**Použití:** Wrapper pro input/select/textarea

---

### 4.2 `DatePickerComponent`
**Soubor:** `shared/components/date-picker/date-picker.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `value` | `Date \| null` | Vybraná hodnota |
| `min` | `Date` | Minimální datum |
| `max` | `Date` | Maximální datum |
| `format` | `string` | Formát zobrazení |
| `placeholder` | `string` | Placeholder |
| `clearable` | `boolean` | Možnost vymazat |
| `disabled` | `boolean` | Deaktivace |
| `disabledDates` | `Date[]` | Zakázaná data |

---

### 4.3 `DateRangePickerComponent`
**Soubor:** `shared/components/date-range-picker/date-range-picker.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `startDate` | `Date` | Počáteční datum |
| `endDate` | `Date` | Koncové datum |
| `presets` | `DatePreset[]` | `{ label: string, start: Date, end: Date }` (Tento týden, Tento měsíc...) |
| `minDays` | `number` | Minimální rozsah |
| `maxDays` | `number` | Maximální rozsah |

---

### 4.4 `TimePickerComponent`
**Soubor:** `shared/components/time-picker/time-picker.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `value` | `string` | Čas (HH:mm) |
| `min` | `string` | Minimální čas |
| `max` | `string` | Maximální čas |
| `step` | `number` | Krok v minutách |
| `format` | `'12h' \| '24h'` | Formát |

---

### 4.5 `FileUploadComponent`
**Soubor:** `shared/components/file-upload/file-upload.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `accept` | `string` | Povolené typy (`.pdf,.docx`) |
| `multiple` | `boolean` | Více souborů |
| `maxSize` | `number` | Max velikost v MB |
| `maxFiles` | `number` | Max počet souborů |
| `dragDrop` | `boolean` | Drag & drop zóna |
| `preview` | `boolean` | Náhled obrázků |

**Funkce:**
- Drag & drop zóna
- Progress bar při uploadu
- Validace typu a velikosti
- Preview náhledů
- Odstranění souborů

---

### 4.6 `ColorPickerComponent`
**Soubor:** `shared/components/color-picker/color-picker.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `value` | `string` | HEX hodnota |
| `presets` | `string[]` | Předvolené barvy |
| `format` | `'hex' \| 'rgb' \| 'hsl'` | Formát výstupu |
| `showInput` | `boolean` | Zobrazit input pro manuální zadání |

---

### 4.7 `RichTextEditorComponent`
**Soubor:** `shared/components/rich-text-editor/rich-text-editor.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `value` | `string` | HTML/Markdown obsah |
| `placeholder` | `string` | Placeholder |
| `toolbar` | `ToolbarConfig` | Konfigurace toolbaru |
| `minHeight` | `string` | Min výška |
| `maxLength` | `number` | Max znaků |
| `mentionable` | `boolean` | @mentions |
| `imageUpload` | `boolean` | Upload obrázků |

**Toolbar options:**
- Bold, Italic, Underline, Strike
- H1, H2, H3
- Lists (ordered, unordered)
- Links
- Images
- Code blocks
- Emoji picker

---

### 4.8 `TagInputComponent`
**Soubor:** `shared/components/tag-input/tag-input.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `value` | `string[]` | Pole tagů |
| `suggestions` | `string[]` | Návrhy pro autocomplete |
| `maxTags` | `number` | Max počet tagů |
| `allowCustom` | `boolean` | Povolit vlastní tagy |
| `validator` | `(tag: string) => boolean` | Validační funkce |
| `placeholder` | `string` | Placeholder |

**Použití:** Keywords, Hashtags

---

### 4.9 `SliderComponent`
**Soubor:** `shared/components/slider/slider.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `value` | `number` | Hodnota |
| `min` | `number` | Minimum |
| `max` | `number` | Maximum |
| `step` | `number` | Krok |
| `showValue` | `boolean` | Zobrazit hodnotu |
| `marks` | `{ value: number, label: string }[]` | Značky |
| `range` | `boolean` | Range slider |

---

### 4.10 `SearchInputComponent`
**Soubor:** `shared/components/search-input/search-input.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `placeholder` | `string` | Placeholder |
| `debounce` | `number` | Debounce v ms |
| `loading` | `boolean` | Loading state |
| `suggestions` | `SearchSuggestion[]` | Autocomplete návrhy |
| `recentSearches` | `string[]` | Nedávná hledání |
| `clearable` | `boolean` | Tlačítko vymazat |

**Events:**
- `search: EventEmitter<string>` - Při submitu
- `searchChange: EventEmitter<string>` - Při změně (debounced)

---

## 5. Data Display komponenty

### 5.1 `DataTableComponent`
**Soubor:** `shared/components/data-table/data-table.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `data` | `T[]` | Data |
| `columns` | `ColumnDef[]` | Definice sloupců |
| `loading` | `boolean` | Loading state |
| `selectable` | `boolean` | Checkbox výběr |
| `sortable` | `boolean` | Řazení |
| `filterable` | `boolean` | Filtrování |
| `pagination` | `PaginationConfig` | Stránkování |
| `expandable` | `boolean` | Rozbalitelné řádky |
| `stickyHeader` | `boolean` | Sticky header |
| `emptyState` | `TemplateRef` | Prázdný stav |
| `rowActions` | `RowAction[]` | Akce na řádku |

**ColumnDef:**
```typescript
interface ColumnDef {
  key: string;
  header: string;
  sortable?: boolean;
  filterable?: boolean;
  width?: string;
  align?: 'left' | 'center' | 'right';
  template?: TemplateRef;
  formatter?: (value: any) => string;
}
```

---

### 5.2 `ListComponent`
**Soubor:** `shared/components/list/list.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `items` | `T[]` | Položky |
| `itemTemplate` | `TemplateRef` | Template pro item |
| `selectable` | `boolean` | Výběr |
| `multiSelect` | `boolean` | Vícenásobný výběr |
| `dividers` | `boolean` | Oddělovače |
| `loading` | `boolean` | Loading |
| `virtualScroll` | `boolean` | Virtual scrolling |

---

### 5.3 `StatCardComponent`
**Soubor:** `shared/components/stat-card/stat-card.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `title` | `string` | Název metriky |
| `value` | `string \| number` | Hodnota |
| `previousValue` | `number` | Předchozí hodnota (pro trend) |
| `trend` | `'up' \| 'down' \| 'neutral'` | Směr trendu |
| `trendValue` | `string` | Hodnota změny (např. "+12%") |
| `icon` | `string` | Ikona |
| `loading` | `boolean` | Loading |

---

### 5.4 `TimelineComponent`
**Soubor:** `shared/components/timeline/timeline.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `items` | `TimelineItem[]` | `{ date: Date, title: string, description?: string, icon?: string, status?: string }` |
| `orientation` | `'vertical' \| 'horizontal'` | Orientace |
| `alternating` | `boolean` | Střídavé strany |

**Použití:** Historie změn, Activity log

---

### 5.5 `ChartComponent`
**Soubor:** `shared/components/chart/chart.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `type` | `'line' \| 'bar' \| 'pie' \| 'doughnut' \| 'area'` | Typ grafu |
| `data` | `ChartData` | Data |
| `options` | `ChartOptions` | Konfigurace |
| `height` | `string` | Výška |
| `loading` | `boolean` | Loading |
| `legend` | `boolean` | Zobrazit legendu |

**Knihovna:** Chart.js nebo Recharts

---

### 5.6 `CalendarViewComponent`
**Soubor:** `shared/components/calendar-view/calendar-view.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `events` | `CalendarEvent[]` | `{ id: string, title: string, start: Date, end?: Date, color?: string, data?: any }` |
| `view` | `'month' \| 'week' \| 'day'` | Zobrazení |
| `currentDate` | `Date` | Aktuální datum |
| `selectable` | `boolean` | Výběr dat |
| `draggable` | `boolean` | Drag & drop events |
| `resizable` | `boolean` | Resize events |
| `showWeekNumbers` | `boolean` | Čísla týdnů |

**Events:**
- `eventClick: EventEmitter<CalendarEvent>`
- `dateClick: EventEmitter<Date>`
- `eventDrop: EventEmitter<{ event: CalendarEvent, newDate: Date }>`

---

### 5.7 `KanbanBoardComponent`
**Soubor:** `shared/components/kanban-board/kanban-board.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `columns` | `KanbanColumn[]` | `{ id: string, title: string, color?: string, limit?: number }` |
| `items` | `KanbanItem[]` | `{ id: string, columnId: string, title: string, data?: any }` |
| `itemTemplate` | `TemplateRef` | Custom item template |
| `columnTemplate` | `TemplateRef` | Custom column header |

**Použití:** Workflow stavy (DRAFT → GENERATING → PENDING → APPROVED)

---

## 6. Feedback komponenty

### 6.1 `ToastService` & `ToastComponent`
**Soubor:** `core/services/toast.service.ts`, `shared/components/toast/toast.component.ts`

**Metody:**
```typescript
toast.success(message: string, options?: ToastOptions): void
toast.error(message: string, options?: ToastOptions): void
toast.warning(message: string, options?: ToastOptions): void
toast.info(message: string, options?: ToastOptions): void
```

**ToastOptions:**
```typescript
interface ToastOptions {
  duration?: number;      // ms, default: 5000
  position?: 'top-right' | 'top-left' | 'bottom-right' | 'bottom-left';
  action?: { label: string; onClick: () => void };
  dismissible?: boolean;
}
```

---

### 6.2 `DialogService` & `DialogComponent`
**Soubor:** `core/services/dialog.service.ts`, `shared/components/dialog/dialog.component.ts`

**Metody:**
```typescript
dialog.open<T>(component: Type<T>, config: DialogConfig): DialogRef<T>
dialog.confirm(config: ConfirmConfig): Promise<boolean>
dialog.alert(config: AlertConfig): Promise<void>
```

**DialogConfig:**
```typescript
interface DialogConfig {
  title?: string;
  data?: any;
  width?: string;
  maxWidth?: string;
  disableClose?: boolean;
  panelClass?: string;
}
```

---

### 6.3 `ConfirmDialogComponent`
**Soubor:** `shared/components/confirm-dialog/confirm-dialog.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `title` | `string` | Nadpis |
| `message` | `string` | Zpráva |
| `confirmText` | `string` | Text potvrzení (default: "Confirm") |
| `cancelText` | `string` | Text zrušení (default: "Cancel") |
| `variant` | `'default' \| 'danger'` | Styl (danger = červené tlačítko) |

---

### 6.4 `AlertComponent`
**Soubor:** `shared/components/alert/alert.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `variant` | `'info' \| 'success' \| 'warning' \| 'error'` | Typ |
| `title` | `string` | Nadpis |
| `message` | `string` | Zpráva |
| `dismissible` | `boolean` | Možnost zavřít |
| `icon` | `string` | Custom ikona |
| `actions` | `AlertAction[]` | Akční tlačítka |

---

### 6.5 `NotificationBellComponent`
**Soubor:** `core/components/notification-bell/notification-bell.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `count` | `number` | Počet nepřečtených |
| `notifications` | `Notification[]` | Seznam notifikací |
| `maxVisible` | `number` | Max viditelných v dropdown |

**Notification:**
```typescript
interface Notification {
  id: string;
  type: 'approval_required' | 'content_ready' | 'generation_failed' | 'mention' | 'system';
  title: string;
  message: string;
  createdAt: Date;
  read: boolean;
  actionUrl?: string;
}
```

---

### 6.6 `LoadingOverlayComponent`
**Soubor:** `shared/components/loading-overlay/loading-overlay.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `loading` | `boolean` | Zobrazit overlay |
| `message` | `string` | Zpráva pod spinnerem |
| `transparent` | `boolean` | Průhledné pozadí |

---

### 6.7 `PopoverComponent`
**Soubor:** `shared/components/popover/popover.component.ts`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `trigger` | `'click' \| 'hover'` | Typ triggeru |
| `position` | `'top' \| 'bottom' \| 'left' \| 'right'` | Pozice |
| `content` | `TemplateRef` | Obsah popoveru |
| `closeOnClickOutside` | `boolean` | Zavřít při kliknutí mimo |

---

## 7. Modul: Onboarding

### 7.1 `OnboardingWizardComponent`
**Soubor:** `features/onboarding/components/onboarding-wizard/`

**Kroky:**
1. **Company Search** - Vyhledání firmy
2. **Company Verification** - Potvrzení správné firmy
3. **Company Details** - Doplnění údajů
4. **Persona Generation** - AI generování person
5. **Persona Selection** - Výběr 3 person
6. **Platform Setup** - Konfigurace sociálních sítí
7. **Summary** - Shrnutí a dokončení

**Komponenty:**

#### `CompanySearchStepComponent`
- Input pro název firmy
- Seznam výsledků z Google Search API
- Skeleton loading
- Empty state pokud nenalezeno
- Tlačítko "Create manually"

#### `CompanyVerificationStepComponent`
- Karta s náhledem firmy (logo, název, adresa, web)
- Scraped data preview (Company DNA)
- "This is my company" / "Search again" tlačítka
- Zobrazení business field, target audience

#### `CompanyDetailsStepComponent`
- Formulář pro doplnění chybějících údajů:
  - Price segment (select)
  - Communication style (select)
  - Brand voice (select)
  - Target age range (slider)
  - Target gender (radio)
  - Main pain point (textarea)
  - Brand colors (color picker array)

#### `PersonaGenerationStepComponent`
- Animace generování (pulsující gradient)
- Progress bar
- "This may take 30-60 seconds" message
- Zobrazení vygenerovaných person jako karty

#### `PersonaSelectionStepComponent`
- Grid 6 PersonaCard komponent
- Checkbox/toggle pro výběr
- Max 3 výběr validation
- "Select all" / "Clear selection"
- Preview modal při kliknutí na personu

#### `PlatformSetupStepComponent`
- Seznam platforem s toggle
- Pro každou povolenou platformu:
  - Profile URL input
  - Preferred post time (time picker)
  - Preferred days (checkbox group)

#### `OnboardingSummaryStepComponent`
- Shrnutí všech kroků
- Edit tlačítka pro návrat
- "Start generating content" CTA

---

### 7.2 `PersonaPreviewModalComponent`
**Soubor:** `features/onboarding/components/persona-preview-modal/`

**Obsah:**
- Header: Avatar, Name, Role
- Tabs:
  - **Psychology** - Jung archetype, MBTI, Values, Frustrations
  - **Writing Style** - Vocabulary, Sentence preference, Metaphors
  - **Visual Style** - Art style, Color palette, Atmosphere
  - **Backstory** - Background, Hobbies, Social status

---

## 8. Modul: Companies

### 8.1 `CompanyListComponent`
**Soubor:** `features/companies/components/company-list/`

**Obsah:**
- Search input
- Filter by status (Active, Pending, Suspended)
- Data table se sloupci:
  - Logo + Company name
  - Business field
  - Subscription tier (badge)
  - Status (badge)
  - Personas count
  - Posts this month
  - Actions (View, Edit, Suspend)

---

### 8.2 `CompanyDetailComponent`
**Soubor:** `features/companies/components/company-detail/`

**Layout:** Sidebar + Main content

**Sidebar:**
- Company card (logo, name, status badge)
- Quick stats (posts, personas, subscription)
- Navigation:
  - Overview
  - DNA & Brand
  - Personas
  - Platforms
  - Settings
  - Events

**Main content (tabs):**

#### Overview Tab:
- Stat cards (This month: Topics, Blog posts, Social posts, Engagement)
- Activity timeline
- Upcoming posts preview

#### DNA & Brand Tab:
- Company DNA viewer (JSON pretty print)
- Brand colors preview
- Brand fonts
- Tone of voice
- Edit button

#### Personas Tab:
- PersonaCard grid
- Add persona button
- Filter: Active / All

#### Platforms Tab:
- Platform cards (enabled/disabled)
- Configure each platform

#### Settings Tab:
- Publication frequency
- Auto-approve settings
- Notification settings
- Export settings

#### Events Tab:
- Calendar view malého měsíce
- List upcoming events
- Add event button

---

### 8.3 `CompanyDnaEditorComponent`
**Soubor:** `features/companies/components/company-dna-editor/`

**Sekce:**
- Target Audience (textarea)
- Competitors (tag input)
- Main Pain Points (tag input)
- Tone of Voice (select)
- Brand Colors (color picker array)
- Brand Fonts (font selector)
- Custom Instructions (textarea)

---

### 8.4 `CompanyEventFormComponent`
**Soubor:** `features/companies/components/company-event-form/`

**Pole:**
- Event name
- Event type (select: sale, holiday, launch, webinar, other)
- Date / Date range
- All day toggle
- Start/End time (if not all day)
- Recurring toggle
- Recurrence rule (if recurring)
- Should influence content (toggle)
- Content priority (slider 1-10)
- Suggested topics (tag input)
- Keywords (tag input)

---

## 9. Modul: Personas

### 9.1 `PersonaCardComponent`
**Soubor:** `shared/components/persona-card/`

| Vlastnost | Typ | Popis |
|-----------|-----|-------|
| `persona` | `Persona` | Data persony |
| `selectable` | `boolean` | Zobrazit checkbox |
| `selected` | `boolean` | Vybraný stav |
| `compact` | `boolean` | Kompaktní verze |
| `actions` | `boolean` | Zobrazit akce menu |

**Obsah karty:**
- Avatar (generovaný nebo default)
- Name + Role
- Jung archetype badge
- MBTI badge
- Key traits (2-3)
- Active/Inactive toggle
- Actions: Edit, Duplicate, Archive

---

### 9.2 `PersonaEditorComponent`
**Soubor:** `features/personas/components/persona-editor/`

**Tabs:**

#### Basic Info Tab:
- Character name
- Age
- Role in company
- Hierarchy level (select)
- Perspective (select)

#### Psychology Tab:
- Jung archetype (visual selector s ikonami)
- MBTI type (4x2 toggle grid)
- Dominant value
- Main frustration
- Neuroticism level (slider: Low/Medium/High)

#### Writing Style Tab:
- Vocabulary level (select)
- Sentence preference (select)
- Metaphor usage (select)
- Argument structure (select)
- Preferred writing framework (select)
- Analysis depth (select)
- Topic opening style (select)
- Favorite phrases/keywords (tag input)
- Unique signature ending

#### Visual Style Tab:
- Art style name (visual selector)
- Color palette (visual selector)
- Visual atmosphere (select)
- Equipment in photos
- Reference images (file upload)

#### Backstory Tab:
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

### Potvrzené komponenty v `shared/components/`:

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

### Potvrzené moduly v `src/app/`:

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

### Plán vs Realita:

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

### ✅ Co aktualizovat:

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
