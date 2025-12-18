# Enhanced Agentic Workflow - Quick Reference

## 🚀 Quick Start

1. **Orchestrator** vybere mini-úkol z `master-plan.md`
2. **DevAgent** implementuje (zapisuje do `README.md`)
3. **CheckAgent** kontroluje (zapisuje za `**|**` v `README.md`)
4. **Orchestrator** rozhodne další krok (PASS → další, FAIL → re-run)

## 📁 Structure

```
.agentic/
├── standards/           # Quality & coding standards
├── agents/             # Agent directories
│   ├── agent-1-backend-core/
│   ├── agent-2-ai-pipeline/
│   ├── agent-3-realtime/
│   ├── agent-4-billing/
│   ├── agent-5-frontend/
│   └── agent-6-devops/
└── orchestrator/       # Master plan & tracking
```

## 🎯 Agents

1. **Backend Core** - Content API, Auth, Database
2. **AI Pipeline** - AI Gateway, Providers, Prompts
3. **Realtime** - SSE, Notifications, Sync
4. **Billing** - Stripe, Usage, Subscriptions
5. **Frontend** - Angular 19 components, Standalone components, Signals & RxJS, API integration
6. **DevOps & QA** - CI/CD, Tests, Deployment

## 📋 CheckAgent Requirements

### Must PASS ✅

- No mock data
- No dummy variables
- No TODO comments (except tests)
- Complete implementation
- Error handling
- Type safety
- Security checks

### Nice to Have 💡

- Good documentation
- Performance optimization
- Clean code structure

## 🔄 Workflow

```
Orchestrator → DevAgent → CheckAgent → Orchestrator
     ↓            ↓            ↓            ↓
  Assign      Implement    Verify      Decide
               Write        Write       (Pass/Fail)
              README.md    after **|**
```

## 📝 README.md Format

```markdown
# Agent N - Name

## 🎯 Current Task
[Task description]

## 📝 DevAgent Implementation
### Co bylo implementováno
- Feature X
- Tests Y

### Proč tato implementace
- Reason A
- Reason B

**|**

## ✅ CheckAgent Verification
### Status: PASS/FAIL
### Problémy
[If FAIL]
```

## 🚫 Zero Tolerance

- Mock data = FAIL
- Dummy vars = FAIL  
- TODO = FAIL
- Incomplete = FAIL

## 📊 Tracking

- `master-plan.md` - Project roadmap
- `current-state.md` - Active status
- `completed-tasks.md` - Done tasks
- `failed-attempts.md` - Lessons learned

## 🎓 Best Practices

**DevAgent:**

- Read all files BEFORE implementing
- Implement COMPLETELY
- Write tests CONCURRENTLY
- Document REASONS
- Self-check BEFORE submit

**CheckAgent:**

- Be STRICT (zero tolerance)
- Provide SPECIFIC feedback (file:line)
- Suggest SOLUTIONS
- Check ALL standards

**Orchestrator:**

- Define tasks CLEARLY
- Provide RIGHT context (max 14 files)
- Respect DEPENDENCIES
- Learn from FAILURES
- Keep plan UPDATED

## 📚 Reference Docs

See `../enhanced_agentic_workflow.md` for complete documentation.
See `quality-standards.md` for detailed requirements.
