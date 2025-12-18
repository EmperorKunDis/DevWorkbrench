#!/bin/bash

# Enhanced Agentic Workflow Setup Script
# Pro PostHub projekt s CheckAgent integrací

set -e  # Exit on error

echo "🚀 Setting up Enhanced Agentic Workflow..."
echo "==========================================="

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Project root (předpokládáme že script běží z root)
PROJECT_ROOT=$(pwd)

echo -e "${BLUE}📁 Creating directory structure...${NC}"

# Create main agentic directory
mkdir -p .agentic

# Create standards directory
mkdir -p .agentic/standards

# Create agents directories
for i in {1..6}; do
    agent_names=("backend-core" "ai-pipeline" "realtime" "billing" "frontend" "devops")
    agent_name=${agent_names[$i-1]}
    
    mkdir -p ".agentic/agents/agent-$i-$agent_name/working"
    echo -e "${GREEN}  ✓ Created agent-$i-$agent_name${NC}"
done

# Create orchestrator directory
mkdir -p .agentic/orchestrator

echo -e "${BLUE}📝 Creating standard files...${NC}"

# ============================================================================
# QUALITY STANDARDS
# ============================================================================
cat > .agentic/standards/quality-standards.md << 'EOF'
# Quality Standards Checklist

## 🚫 ZAKÁZÁNO (ZERO TOLERANCE)
- ❌ Mock data
- ❌ Dummy variables  
- ❌ TODO komentáře (kromě testů)
- ❌ console.log v produkci
- ❌ Hardcoded credentials
- ❌ Ignorované errors
- ❌ any type bez důvodu

## ✅ POVINNÉ
- ✅ Error handling všude
- ✅ Input validation (zod)
- ✅ Type safety
- ✅ Security checks
- ✅ Dokumentace (JSDoc)
- ✅ Unit tests
- ✅ Integration tests

## 📋 CheckAgent Checklist
- [ ] Mock data check
- [ ] Dummy vars check
- [ ] TODO check
- [ ] Kompletnost check
- [ ] Standards check
- [ ] Error handling check
- [ ] Type safety check
- [ ] Security check
- [ ] Performance check
- [ ] Tests check

Reference: quality-standards.md pro detailní požadavky
EOF
echo -e "${GREEN}  ✓ quality-standards.md${NC}"

# ============================================================================
# CODING STANDARDS
# ============================================================================
cat > .agentic/standards/coding-standards.md << 'EOF'
# Coding Standards

## TypeScript/JavaScript
- Strict mode enabled
- Preferuj const před let
- Používej destructuring
- Async/await místo .then()
- Named exports místo default

## API Design  
- RESTful konvence
- Consistent error responses
- Pagination pro lists
- Rate limiting per endpoint
- CORS properly configured

## Database
- Transactions pro multi-step ops
- Proper indexing
- Migration scripts
- Seed data separated
- Prevent N+1 queries

## Security
- Input sanitization
- SQL injection prevention
- XSS protection
- CSRF tokens
- JWT validation
- Environment variables pro secrets
EOF
echo -e "${GREEN}  ✓ coding-standards.md${NC}"

# ============================================================================
# SECURITY STANDARDS
# ============================================================================
cat > .agentic/standards/security-standards.md << 'EOF'
# Security Standards

## Authentication
- JWT tokens with expiration
- Refresh token rotation
- Secure password hashing (bcrypt)
- 2FA support where needed

## Authorization
- Role-based access control
- Resource ownership checks
- Principle of least privilege

## Data Protection
- Encrypt sensitive data at rest
- Use HTTPS only
- Secure headers (helmet)
- Rate limiting
- CSRF protection

## Input Validation
- Validate all user input
- Sanitize HTML
- Prevent SQL injection
- Prevent XSS attacks

## Secrets Management
- Environment variables only
- Never commit secrets
- Rotate secrets regularly
- Use secret management tools (Vault, etc.)
EOF
echo -e "${GREEN}  ✓ security-standards.md${NC}"

# ============================================================================
# DOCUMENTATION STANDARDS
# ============================================================================
cat > .agentic/standards/documentation-standards.md << 'EOF'
# Documentation Standards

## Code Documentation
- JSDoc/TSDoc for all public functions
- Complex logic requires comments
- README.md in each package
- API documentation (OpenAPI/Swagger)

## Agent Documentation
- current-task.md - Current assignment
- README.md - Implementation log + CheckAgent results
- Separated by **|** delimiter

## Project Documentation
- Architecture overview
- Setup instructions
- Contributing guidelines
- Deployment guide
EOF
echo -e "${GREEN}  ✓ documentation-standards.md${NC}"

# ============================================================================
# TESTING STANDARDS
# ============================================================================
cat > .agentic/standards/testing-standards.md << 'EOF'
# Testing Standards

## Coverage Requirements
- Unit tests: 80%+ coverage
- Integration tests: Critical paths
- E2E tests: Main user flows

## Test Structure
- Arrange-Act-Assert pattern
- Descriptive test names
- One assertion per test (ideally)
- Mock external dependencies

## Test Types
- Unit: Business logic
- Integration: API endpoints
- E2E: User workflows
- Performance: Load testing

## CI/CD
- Tests run on every commit
- No merge without passing tests
- Code coverage tracking
EOF
echo -e "${GREEN}  ✓ testing-standards.md${NC}"

# ============================================================================
# ORCHESTRATOR FILES
# ============================================================================
cat > .agentic/orchestrator/master-plan.md << 'EOF'
# Master Plan - PostHub Project

## 🎯 Project Goals
1. Complete backend API implementation
2. AI pipeline integration
3. Real-time features
4. Billing system
5. Frontend implementation
6. Production deployment

## 📊 Current Phase
**Phase 1:** Backend Core Development

## 🗺️ Roadmap

### Phase 1: Backend Core (Agent 1)
- [ ] Content API endpoints
- [ ] User management
- [ ] Authentication/Authorization
- [ ] Database schema
- [ ] Core business logic

### Phase 2: AI Pipeline (Agent 2)
- [ ] AI Gateway integration
- [ ] Provider management
- [ ] Prompt templates
- [ ] Response processing

### Phase 3: Realtime (Agent 3)
- [ ] SSE implementation
- [ ] Notifications system
- [ ] Client state sync

### Phase 4: Billing (Agent 4)
- [ ] Stripe integration
- [ ] Usage tracking
- [ ] Subscription management
- [ ] Limit enforcement

### Phase 5: Frontend (Agent 5)
- [ ] Component library
- [ ] Feature implementation
- [ ] State management
- [ ] API integration

### Phase 6: DevOps & QA (Agent 6)
- [ ] CI/CD pipeline
- [ ] E2E tests
- [ ] Documentation
- [ ] Deployment automation

## 📝 Notes
- Update tento file po dokončení každé fáze
- Track blockers a dependencies
- Document important decisions
EOF
echo -e "${GREEN}  ✓ master-plan.md${NC}"

cat > .agentic/orchestrator/current-state.md << 'EOF'
# Current State

## 🎯 Active Phase
Phase 1: Backend Core

## 🤖 Active Agents
- Agent 1: Backend Core - ACTIVE
- Agent 2: AI Pipeline - WAITING (depends on Agent 1)
- Agent 3: Realtime - WAITING (depends on Agent 1, 2)
- Agent 4: Billing - WAITING (depends on Agent 1)
- Agent 5: Frontend - WAITING (depends on Agent 1-4)
- Agent 6: DevOps - WAITING (depends on all)

## 📋 Current Tasks
None yet - setup phase

## 🚧 Blockers
None

## 📊 Statistics
- Total tasks: 0
- Completed: 0
- Failed: 0
- Pass rate: N/A

## 📝 Last Update
2024-12-17 - Initial setup
EOF
echo -e "${GREEN}  ✓ current-state.md${NC}"

cat > .agentic/orchestrator/completed-tasks.md << 'EOF'
# Completed Tasks

## Format
```
### Task ID: [YYYYMMDD-NNN]
- **Agent:** Agent N - Name
- **Description:** [What was done]
- **Status:** PASS ✅
- **Date:** YYYY-MM-DD
- **Files Changed:** [List]
- **Tests:** [Coverage %]
- **Notes:** [Any important notes]
```

## Tasks
<!-- Tasks will be added here as they complete -->
EOF
echo -e "${GREEN}  ✓ completed-tasks.md${NC}"

cat > .agentic/orchestrator/failed-attempts.md << 'EOF'
# Failed Attempts & Lessons Learned

## Format
```
### Failure ID: [YYYYMMDD-NNN]
- **Agent:** Agent N - Name
- **Task:** [What was attempted]
- **Failure Type:** [Mock data / TODO / etc.]
- **Attempts:** N
- **Root Cause:** [Why it failed]
- **Lesson:** [What we learned]
- **Fix Applied:** [How it was resolved]
- **Date:** YYYY-MM-DD
```

## Failures
<!-- Failures will be tracked here for learning -->
EOF
echo -e "${GREEN}  ✓ failed-attempts.md${NC}"

cat > .agentic/orchestrator/agent-dependencies.md << 'EOF'
# Agent Dependencies

## Dependency Graph

```
Agent 1 (Backend Core)
  └── No dependencies (Base layer)

Agent 2 (AI Pipeline)
  └── Depends on: Agent 1 (API infrastructure)

Agent 3 (Realtime)
  ├── Depends on: Agent 1 (API)
  └── Depends on: Agent 2 (AI events)

Agent 4 (Billing)
  ├── Depends on: Agent 1 (API)
  └── Depends on: Agent 2 (Usage tracking)

Agent 5 (Frontend)
  ├── Depends on: Agent 1 (Backend API)
  ├── Depends on: Agent 2 (AI features)
  ├── Depends on: Agent 3 (Realtime updates)
  └── Depends on: Agent 4 (Billing UI)

Agent 6 (DevOps & QA)
  └── Depends on: ALL (Integration testing)
```

## Execution Order
1. Agent 1 - Backend Core (Start here)
2. Agent 2 - AI Pipeline (After Agent 1)
3. Agent 3, 4 - Can run in parallel (After Agent 1, 2)
4. Agent 5 - Frontend (After Agent 1-4)
5. Agent 6 - DevOps (After all)
EOF
echo -e "${GREEN}  ✓ agent-dependencies.md${NC}"

# ============================================================================
# AGENT README TEMPLATES
# ============================================================================
echo -e "${BLUE}📝 Creating agent README templates...${NC}"

agent_names=("Backend Core" "AI Pipeline" "Realtime" "Billing" "Frontend" "DevOps & QA")
agent_responsibilities=(
    "Content API, User management, Auth, Database schema, Core business logic"
    "AI Gateway, Provider management, Prompt templates, Response processing"
    "SSE implementation, Notifications, WebSocket fallback, Client state sync"
    "Stripe integration, Usage tracking, Subscription management, Limit enforcement"
    "Angular 19 components, Standalone components, Signals & RxJS, API integration"
    "CI/CD pipelines, E2E tests, Documentation, Deployment scripts"
)

agent_slugs=("backend-core" "ai-pipeline" "realtime" "billing" "frontend" "devops")

for i in {1..6}; do
    agent_name=${agent_names[$i-1]}
    agent_resp=${agent_responsibilities[$i-1]}
    agent_slug=${agent_slugs[$i-1]}
    agent_dir=".agentic/agents/agent-$i-$agent_slug"
    
    cat > "$agent_dir/README.md" << EOF
# Agent $i - $agent_name

## 🎯 Zodpovědnost
$agent_resp

## 📋 Current Task
No task assigned yet.

## 📝 DevAgent Implementation
<!-- DevAgent bude psát sem po dokončení úkolu -->

## Status
Waiting for assignment...

**|**

## ✅ CheckAgent Verification
<!-- CheckAgent bude psát sem po kontrole -->

No verification yet.
EOF
    echo -e "${GREEN}  ✓ Agent $i README.md${NC}"
    
    # Create current-task template
    cat > "$agent_dir/current-task.md" << EOF
# Current Task - Agent $i

## Status
⏸️ No task assigned

## Task Description
Waiting for Orchestrator to assign task...

## Requirements
- TBD

## Provided Files
- TBD

## Expected Output
- TBD

## Notes
- TBD
EOF
done

# ============================================================================
# CREATE WORKFLOW DOCUMENTATION
# ============================================================================
echo -e "${BLUE}📚 Creating workflow documentation...${NC}"

cat > .agentic/README.md << 'EOF'
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
5. **Frontend** - React, UI, State management
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
EOF
echo -e "${GREEN}  ✓ .agentic/README.md${NC}"

# ============================================================================
# CREATE .gitignore
# ============================================================================
cat > .agentic/.gitignore << 'EOF'
# Working directories (temp files)
*/working/*

# Keep structure
!*/working/.gitkeep
EOF

# Create .gitkeep files
for i in {1..6}; do
    agent_names=("backend-core" "ai-pipeline" "realtime" "billing" "frontend" "devops")
    agent_name=${agent_names[$i-1]}
    touch ".agentic/agents/agent-$i-$agent_name/working/.gitkeep"
done

echo -e "${GREEN}  ✓ .gitignore created${NC}"

# ============================================================================
# SUMMARY
# ============================================================================
echo ""
echo -e "${GREEN}✅ Setup completed successfully!${NC}"
echo ""
echo -e "${YELLOW}📁 Created structure:${NC}"
echo "  .agentic/"
echo "    ├── standards/          (5 standard files)"
echo "    ├── agents/             (6 agent directories)"
echo "    │   └── working/        (temp work dirs)"
echo "    ├── orchestrator/       (4 tracking files)"
echo "    └── README.md           (Quick reference)"
echo ""
echo -e "${YELLOW}📝 Next steps:${NC}"
echo "  1. Review .agentic/orchestrator/master-plan.md"
echo "  2. Update agent-dependencies.md if needed"
echo "  3. Start with Agent 1 (Backend Core)"
echo "  4. Follow the workflow in enhanced_agentic_workflow.md"
echo ""
echo -e "${BLUE}📚 Documentation:${NC}"
echo "  - Full workflow: enhanced_agentic_workflow.md"
echo "  - Quick reference: .agentic/README.md"
echo "  - Quality standards: .agentic/standards/quality-standards.md"
echo ""
echo -e "${GREEN}🚀 Ready to start agentic development!${NC}"
EOF
