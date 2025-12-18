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

#### Overview Tab

- Stat cards (This month: Topics, Blog posts, Social posts, Engagement)
- Activity timeline
- Upcoming posts preview

#### DNA & Brand Tab

- Company DNA viewer (JSON pretty print)
- Brand colors preview
- Brand fonts
- Tone of voice
- Edit button

#### Personas Tab

- PersonaCard grid
- Add persona button
- Filter: Active / All

#### Platforms Tab

- Platform cards (enabled/disabled)
- Configure each platform

#### Settings Tab

- Publication frequency
- Auto-approve settings
- Notification settings
- Export settings

#### Events Tab

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

#### Basic Info Tab

- Character name
- Age
- Role in company
- Hierarchy level (select)
- Perspective (select)
