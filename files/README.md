# 🤖 Enhanced Agentic Workflow s CheckAgent Kontrolou

> **Profesionální multi-agent development workflow s automatickou quality kontrolou**  
> Zero tolerance pro mock data, dummy variables a TODO komentáře

---

## 📚 Obsah Balíčku

1. **enhanced_agentic_workflow.md** - Kompletní dokumentace workflow
2. **quality-standards.md** - Detailní quality & coding standards
3. **workflow-diagram.mmd** - Mermaid diagram celého procesu
4. **setup-agentic-workflow.sh** - Automatický setup script
5. **README.md** (tento soubor) - Quick start guide

---

## 🎯 Co je Enhanced Agentic Workflow?

Toto je vylepšený agentic development workflow, který přidává **CheckAgent** do každého development cyklu. CheckAgent zajišťuje:

- ✅ **Zero tolerance** pro mock data, dummy variables, TODO
- ✅ **Kompletní implementaci** každého úkolu
- ✅ **Dodržení standardů** (coding, security, performance)
- ✅ **Automatickou kontrolu** před integrací do projektu

### 🔄 Základní Flow

```
1. Orchestrator přidělí mini-úkol → DevAgent
2. DevAgent implementuje KOMPLETNĚ → zapíše README.md
3. CheckAgent zkontroluje PŘÍSNĚ → zapíše za **|** v README.md
4. Orchestrator rozhodne:
   ✅ PASS → Integruj a pokračuj
   ❌ FAIL → Re-run s feedback
   🤔 CLARIFY → Vyžádej více kontextu
```

---

## 🚀 Quick Start

### Krok 1: Setup Struktury

```bash
# Zkopíruj všechny soubory do svého projektu
cp enhanced_agentic_workflow.md /path/to/project/
cp quality-standards.md /path/to/project/
cp workflow-diagram.mmd /path/to/project/
cp setup-agentic-workflow.sh /path/to/project/

# Přejdi do projektu
cd /path/to/project/

# Spusť setup
chmod +x setup-agentic-workflow.sh
./setup-agentic-workflow.sh
```

To vytvoří:

```
.agentic/
├── standards/           # 5 standard souborů
├── agents/             # 6 agent directories
│   ├── agent-1-backend-core/
│   ├── agent-2-ai-pipeline/
│   ├── agent-3-realtime/
│   ├── agent-4-billing/
│   ├── agent-5-frontend/
│   └── agent-6-devops/
└── orchestrator/       # 4 tracking soubory
```

### Krok 2: Přizpůsob Master Plan

```bash
# Edituj master plan pro tvůj projekt
nano .agentic/orchestrator/master-plan.md

# Přidej své fáze projektu
# Updatuj agent zodpovědnosti
# Definuj milestones
```

### Krok 3: Přizpůsob Standardy

```bash
# Přidej project-specific standardy
nano .agentic/standards/quality-standards.md
nano .agentic/standards/coding-standards.md

# Například:
# - Specifické naming conventions
# - Project-specific libraries
# - Custom validation rules
# - Architecture patterns
```

### Krok 4: Start První Úkol

```bash
# 1. Orchestrator vybere první mini-úkol
# 2. Vytvoř current-task.md pro Agent 1
nano .agentic/agents/agent-1-backend-core/current-task.md

# 3. Poskytni kontext (max 14 souborů)
# 4. Spusť DevAgent
# 5. Po dokončení spusť CheckAgent
# 6. Rozhoduj na základě výsledku
```

---

## 📊 6 Development Agents

### 🔵 Agent 1: Backend Core

**Zodpovědnost:**

- Content API endpoints
- User management
- Authentication/Authorization
- Database schema
- Core business logic

**Dependencies:** Žádné (base layer)

---

### 🟢 Agent 2: AI Pipeline

**Zodpovědnost:**

- AI Gateway integrace
- Provider management (OpenAI, Anthropic, local)
- Prompt templating
- Response processing

**Dependencies:** Agent 1 (API infrastructure)

---

### 🟡 Agent 3: Realtime

**Zodpovědnost:**

- SSE implementation
- Real-time notifications
- WebSocket fallback
- Client state sync

**Dependencies:** Agent 1 (API) + Agent 2 (AI events)

---

### 🟠 Agent 4: Billing

**Zodpovědnost:**

- Stripe integration
- Usage tracking
- Subscription management
- Limit enforcement

**Dependencies:** Agent 1 (API) + Agent 2 (usage data)

---

### 🔴 Agent 5: Frontend

**Zodpovědnost:**

- Angular 19 components
- Standalone components
- Signals & RxJS
- API integration

**Dependencies:** Agent 1-4 (All backend APIs)

---

### 🟣 Agent 6: DevOps & QA

**Zodpovědnost:**

- CI/CD pipelines
- E2E tests
- Documentation
- Deployment scripts

**Dependencies:** Agent 1-5 (Integration testing)

---

## 🔍 CheckAgent - Quality Kontrola

CheckAgent provádí **10-bodovou kontrolu** každého úkolu:

### ❌ Zakázané Elementy (FAIL if found)

1. Mock data
2. Dummy variables
3. TODO komentáře (kromě testů)

### ✅ Povinné Elementy (FAIL if missing)

4. Kompletní implementace
5. Error handling všude
6. Input validation (zod)
7. Type safety (žádné 'any' bez důvodu)
8. Security checks (auth, authorization, rate limiting)
9. Performance considerations
10. Tests (unit + integration)

### 📝 CheckAgent Output

Po kontrole zapíše do `README.md` za `**|**`:

```markdown
**|**

## ✅ CheckAgent Verification

### Status: PASS ✅ / FAIL ❌

### Kontrolované Oblasti
✅/❌ Mock Data: [status]
✅/❌ Dummy Variables: [status]
✅/❌ TODO Comments: [status]
✅/❌ Kompletnost: [status]
✅/❌ Error Handling: [status]
✅/❌ Type Safety: [status]
✅/❌ Security: [status]
✅/❌ Performance: [status]
✅/❌ Tests: [status]

### Nalezené Problémy (pokud FAIL)
1. **[soubor:řádek]** - [problém]
   - Nalezeno: `[kód]`
   - Důvod: [proč je to problém]
   - Fix: [jak to opravit]

### Doporučení
[Konkrétní kroky]
```

---

## 📝 README.md Formát (Pro Každého Agenta)

Každý agent má svůj `README.md` ve formátu:

```markdown
# Agent N - [Název]

## 🎯 Aktuální Úkol
[Popis od Orchestratora]

## 📝 DevAgent Implementace

### Co bylo implementováno
- Feature X v souboru Y
- Endpoint Z

### Proč tato implementace
- Důvod A: [vysvětlení]
- Důvod B: [vysvětlení]

### Změněné soubory
1. /src/api/content.ts - [změny]
2. /src/services/contentService.ts - [změny]

### Přidané závislosti
- zod@3.22.0 - [proč]
- uuid@9.0.0 - [proč]

**|**

## ✅ CheckAgent Kontrola

### Status: [PASS/FAIL]

[... CheckAgent output ...]
```

---

## 🎨 Mermaid Diagram

Pro vizualizaci workflow použij `workflow-diagram.mmd`:

```bash
# V projektu:
cat workflow-diagram.mmd

# Nebo otevři v Mermaid editoru:
# https://mermaid.live
```

Diagram ukazuje:

- Orchestrator flow
- DevAgent process
- CheckAgent 10-point kontrolu
- Rozhodovací logiku
- Re-run strategie

---

## 📖 Detailní Dokumentace

### 1. enhanced_agentic_workflow.md

- Kompletní workflow popis
- Všechny fáze detailně
- Troubleshooting guide
- Best practices
- Success criteria
- Metrics & tracking

### 2. quality-standards.md

- Zakázané elementy s příklady
- Povinné elementy s příklady
- Coding standards (TypeScript/JS)
- API design standards
- Database standards
- Security standards
- Performance standards
- CheckAgent checklist

### 3. .agentic/README.md

- Quick reference guide
- Structure overview
- Agent popis
- Workflow summary
- Zero tolerance policy

---

## 🛠️ Troubleshooting

### Problem: CheckAgent stále nachází TODO

**Solution:**

```bash
# DevAgent self-check před submit
grep -r "TODO" src/
grep -r "FIXME" src/
grep -r "HACK" src/

# Odstranit všechny nalezené
# CheckAgent znovu zkontroluje
```

### Problem: Mock data v kódu

**Solution:**

```bash
# CheckAgent identifikuje přesné řádky
# DevAgent nahradí real implementací
# Pokud chybí kontext, Orchestrator poskytne více souborů
```

### Problem: Příliš velký úkol

**Solution:**

```bash
# Orchestrator rozdělí na menší mini-úkoly
# Vytvoří dependency chain
# Spustí postupně
```

### Problem: Častý FAIL rate

**Solution:**

```bash
# 1. Review standards - jsou jasné?
# 2. DevAgent training - rozumí požadavkům?
# 3. Task size - nejsou úkoly příliš velké?
# 4. Context - dostává DevAgent správné soubory?
```

---

## 📊 Metrics & Tracking

### Per-Agent Metrics

Track v `.agentic/orchestrator/current-state.md`:

- Tasks completed
- Pass rate (first attempt)
- Average re-runs needed
- Time per task
- Lines of code changed

### Overall Metrics

Track v `.agentic/orchestrator/master-plan.md`:

- Total tasks completed
- Overall pass rate
- Bottleneck agents
- Most common failures
- Integration success rate

### Failure Analysis

Track v `.agentic/orchestrator/failed-attempts.md`:

- Typ problému
- Root cause
- Lessons learned
- Applied fixes

---

## 🎓 Best Practices

### Pro DevAgenty ✅

1. **Čti VŠECHNY soubory PŘED implementací**
   - Nepřehlédni kontext
   - Pochop dependencies
   - Poznej patterns

2. **Implementuj KOMPLETNĚ**
   - Žádné TODO
   - Žádné mock data
   - Žádné dummy variables

3. **Piš testy SOUČASNĚ**
   - Unit tests pro business logiku
   - Integration tests pro API
   - Coverage 80%+

4. **Dokumentuj DŮVODY**
   - Proč tento přístup?
   - Jaké alternativy byly zvažovány?
   - Co bylo rozhodující?

5. **Self-check PŘED submit**
   - grep pro TODO/FIXME/HACK
   - grep pro mock/dummy/placeholder
   - Kontrola všech error handlerů
   - Kontrola type safety

### Pro CheckAgenty ✅

1. **Buď PŘÍSNÝ**
   - Zero tolerance policy
   - Mock data = instant FAIL
   - TODO = instant FAIL
   - Nekompletní = instant FAIL

2. **Poskytuj KONKRÉTNÍ feedback**
   - Soubor:řádek číslo
   - Cituj problematický kód
   - Vysvětli proč je to problém
   - Navrhni řešení

3. **Kontroluj VŠECHNY standardy**
   - 10-point checklist
   - Security best practices
   - Performance considerations
   - Code quality

4. **Buď KONSTRUKTIVNÍ**
   - Ne jen "FAIL"
   - Vysvětli co a jak opravit
   - Poskytni příklady
   - Motivuj k lepšímu kódu

### Pro Orchestratora ✅

1. **Definuj úkoly JASNĚ**
   - Co přesně má být implementováno
   - Jaké jsou requirements
   - Co je expected output
   - Jaké jsou constraints

2. **Poskytni SPRÁVNÝ kontext**
   - Max 14 souborů
   - Relevantní standardy
   - Previous context (při re-run)
   - Related code

3. **Respektuj DEPENDENCIES**
   - Agent 2 potřebuje Agent 1
   - Frontend potřebuje backend APIs
   - E2E tests potřebují vše

4. **Uč se z FAILURES**
   - Track v failed-attempts.md
   - Analyzuj root causes
   - Prevence do budoucna
   - Update standards

5. **Udržuj AKTUÁLNÍ stav**
   - current-state.md po každém úkolu
   - completed-tasks.md průběžně
   - master-plan.md po milestones
   - agent-dependencies.md při změnách

---

## ✅ Success Criteria

Workflow je úspěšný když:

- ✅ **90%+ pass rate** na první pokus
- ✅ **Žádná mock data** v produkci
- ✅ **Všechny standardy** dodrženy
- ✅ **Dokumentace** kompletní a aktuální
- ✅ **Tests** PASSují (80%+ coverage)
- ✅ **Code** production-ready
- ✅ **Security** best practices dodrženy
- ✅ **Performance** optimalizované

---

## 🎯 Příklad Použití

### Scénář: Implementovat Content API endpoint

#### 1. Orchestrator

```markdown
# .agentic/agents/agent-1-backend-core/current-task.md

## Úkol
Implementovat POST /api/content/posts endpoint

## Požadavky
- Validace inputu (zod)
- Ukládání do DB (Prisma)
- Auth required
- Rate limiting
- Error handling

## Poskytnuté Soubory
1. src/api/content.ts
2. src/services/contentService.ts (vytvořit)
3. src/schemas/content.schema.ts (vytvořit)
4. .agentic/standards/quality-standards.md
5. .agentic/standards/coding-standards.md
```

#### 2. DevAgent Implementuje

```typescript
// Kompletní implementace
// Žádné TODO, mock data, dummy vars
// Error handling všude
// Tests napsané
```

#### 3. DevAgent Zapíše README.md

```markdown
## 📝 DevAgent Implementace

### Co bylo implementováno
- POST /api/content/posts endpoint
- contentService.createPost()
- Zod validation schemas
- Unit tests (95% coverage)
- Integration tests

### Proč tato implementace
- Zod: Type-safe validation
- Service layer: Testovatelnost
- Rate limiting: Security
- Proper error handling: User experience

### Změněné soubory
1. src/api/content.ts - UPDATED
2. src/services/contentService.ts - NEW
3. src/schemas/content.schema.ts - NEW
4. tests/services/contentService.test.ts - NEW
5. tests/api/content.test.ts - NEW
```

#### 4. CheckAgent Kontroluje

Provede 10-bodovou kontrolu a zapíše:

```markdown
**|**

## ✅ CheckAgent Verification

### Status: PASS ✅

### Kontrolované Oblasti
✅ Mock Data: Žádná nalezena
✅ Dummy Variables: Žádné
✅ TODO Comments: Žádné
✅ Kompletnost: Plná implementace
✅ Error Handling: Kompletní
✅ Type Safety: Správný typing
✅ Security: Auth + rate limiting
✅ Performance: Optimální
✅ Tests: 95% coverage, ALL PASS

### Nalezené Problémy
Žádné!

### Doporučení
Production-ready. Můžeme integrovat.
```

#### 5. Orchestrator Rozhodne

```markdown
# .agentic/orchestrator/current-state.md

## Poslední Update
Agent 1 - Backend Core: Content API - PASS ✅

## Rozhodnutí
- Status: PASS
- Action: Integrovat do main
- Next Task: Agent 2 - AI Pipeline

## Integration
1. Merge files
2. Run full test suite
3. Update docs
4. Mark completed
```

---

## 📦 Co Je v Balíčku

```
enhanced-agentic-workflow/
├── README.md                           (tento soubor)
├── enhanced_agentic_workflow.md        (kompletní docs)
├── quality-standards.md                (standards)
├── workflow-diagram.mmd                (Mermaid diagram)
└── setup-agentic-workflow.sh           (setup script)
```

Po spuštění `setup-agentic-workflow.sh`:

```
project/
├── .agentic/
│   ├── README.md
│   ├── standards/
│   │   ├── quality-standards.md
│   │   ├── coding-standards.md
│   │   ├── security-standards.md
│   │   ├── documentation-standards.md
│   │   └── testing-standards.md
│   ├── agents/
│   │   ├── agent-1-backend-core/
│   │   │   ├── README.md
│   │   │   ├── current-task.md
│   │   │   └── working/
│   │   ├── agent-2-ai-pipeline/
│   │   ├── agent-3-realtime/
│   │   ├── agent-4-billing/
│   │   ├── agent-5-frontend/
│   │   └── agent-6-devops/
│   └── orchestrator/
│       ├── master-plan.md
│       ├── current-state.md
│       ├── completed-tasks.md
│       ├── failed-attempts.md
│       └── agent-dependencies.md
├── enhanced_agentic_workflow.md
├── quality-standards.md
└── workflow-diagram.mmd
```

---

## 🤝 Přizpůsobení Pro Tvůj Projekt

### 1. Agent Roles

Pokud tvůj projekt má jiné potřeby:

```bash
# Přejmenuj agenty
mv .agentic/agents/agent-1-backend-core .agentic/agents/agent-1-api-gateway

# Update jejich README.md s novými zodpovědnostmi
nano .agentic/agents/agent-1-api-gateway/README.md

# Update dependencies
nano .agentic/orchestrator/agent-dependencies.md
```

### 2. Standards

Přidej project-specific požadavky:

```bash
# Například pro GraphQL místo REST
echo "## GraphQL Standards" >> .agentic/standards/coding-standards.md
echo "- Use schema-first approach" >> .agentic/standards/coding-standards.md
echo "- Implement DataLoaders" >> .agentic/standards/coding-standards.md

# Nebo pro specifické knihovny
echo "## Project Libraries" >> .agentic/standards/quality-standards.md
echo "- Always use Tanstack Query" >> .agentic/standards/quality-standards.md
```

### 3. Checklist

Customize CheckAgent checklist:

```bash
nano .agentic/standards/quality-standards.md

# Přidej/odeber položky podle potřeby
# Například:
# - GraphQL schema validation
# - Prisma migration check
# - i18n string check
```

---

## 🚀 Deployment

### Development

```bash
# Všichni agenti pracují lokálně
# Orchestrator je Claude instance
# CheckAgent je další Claude instance
```

### Production

```bash
# Agenti generují production-ready kód
# Všechny checks prošly
# Tests PASSují
# Deploy s confidence!
```

---

## 📞 Support & Questions

Pro otázky nebo problémy:

1. **Dokumentace**: Přečti `enhanced_agentic_workflow.md`
2. **Standards**: Zkontroluj `quality-standards.md`
3. **Examples**: Podívej se na příklady v dokumentaci
4. **Troubleshooting**: Sekce troubleshooting v README

---

## 📝 Changelog

### v1.0.0 - 2024-12-17

- ✨ Initial release
- 🤖 6-agent architecture
- ✅ CheckAgent integration
- 📚 Complete documentation
- 🛠️ Setup script
- 📊 Mermaid diagrams

---

## 📄 License

Pro PostHub projekt - Praut s.r.o.

---

## 👨‍💻 Author

**Martin**  
CEO & Co-founder, Praut s.r.o.  
AI Integration & Business Automation  
Cheb, Czech Republic

---

## 🎉 Happy Coding

Tento workflow ti pomůže vytvořit:

- ✅ **Kvalitní kód** bez mock dat
- ✅ **Kompletní implementaci** každého featuru
- ✅ **Production-ready výstup** s testy
- ✅ **Dokumentovaný proces** s lessons learned

**Start now:**

```bash
./setup-agentic-workflow.sh
```

**Následuj workflow v:** `enhanced_agentic_workflow.md`

**Good luck! 🚀**
