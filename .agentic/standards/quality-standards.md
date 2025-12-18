# PostHub Quality Standards

## CheckAgent 10-Point Verification

Kazdy kod MUSI projit timto checklistem pred PASS.

---

## ZAKAZANO (Zero Tolerance = instant FAIL)

### 1. Mock Data
```python
# FAIL
personas = [{"name": "John"}, {"name": "Jane"}]  # Hardcoded

# PASS
personas = PersonaSelector.get_for_company(company_id=company_id)
```

### 2. Dummy Variables
```python
# FAIL
user_id = "12345"  # Magic value
price = 100  # Hardcoded

# PASS
user_id = request.user.id
price = tier_limits.get_price(organization.subscription_tier)
```

### 3. TODO Komentare
```python
# FAIL
# TODO: implement this later
# FIXME: handle edge case
# XXX: needs review

# PASS
# Vsechno implementovano, zadne TODO!
```

### 4. console.log v Production
```typescript
// FAIL
console.log('debug:', data);  // V produkci

// PASS - Pouzij logger service
this.logger.debug('Processing data', { data });
```

### 5. Hardcoded Credentials
```python
# FAIL
api_key = "sk_live_123456"
password = "admin123"

# PASS
api_key = settings.STRIPE_SECRET_KEY
password = env('ADMIN_PASSWORD')
```

### 6. `any` Type bez Komentare
```typescript
// FAIL
const data: any = response.data;

// PASS
const data = response.data as ApiResponse<Topic>;

// Nebo s oduvodnenim:
// eslint-disable-next-line @typescript-eslint/no-explicit-any -- API returns untyped response
const legacyData: any = legacyApi.getData();
```

---

## POVINNE (Missing = FAIL)

### 7. Kompletni Implementace
- Vsechny metody musi byt PLNE implementovane
- Zadne `pass`, `...`, `NotImplementedError`
- Vsechny edge cases osetreny

### 8. Error Handling
```python
# Backend - VZDY chytej exceptions
try:
    result = service.process(data)
except ValidationError as e:
    return Response({'status': 'error', 'code': 'VALIDATION_ERROR', 'message': str(e)}, status=400)
except PermissionError:
    return Response({'status': 'error', 'code': 'PERMISSION_DENIED'}, status=403)
except Exception as e:
    logger.exception("Unexpected error")
    return Response({'status': 'error', 'code': 'INTERNAL_ERROR'}, status=500)
```

```typescript
// Frontend - VZDY handle errors
try {
  await this.contentService.createTopic(data);
  this.toast.success('Tema vytvoreno');
} catch (error) {
  this.toast.error('Nepodarilo se vytvorit tema');
  this.store.setError('Chyba pri vytvareni tematu');
}
```

### 9. Input Validation
```python
# Backend - DRF serializers
class TopicCreateSerializer(serializers.Serializer):
    title = serializers.CharField(max_length=200, required=True)
    personaId = serializers.UUIDField(required=True)

    def validate_title(self, value):
        if len(value.strip()) < 3:
            raise serializers.ValidationError("Nazev musi mit alespon 3 znaky")
        return value.strip()
```

```typescript
// Frontend - Zod nebo class-validator
const TopicSchema = z.object({
  title: z.string().min(3, 'Nazev musi mit alespon 3 znaky').max(200),
  personaId: z.string().uuid('Neplatne ID persony'),
});
```

### 10. Type Safety
```python
# Backend - Type hints VSUDE
def create_topic(
    *,
    company: Company,
    persona: Persona,
    title: str,
    created_by: User
) -> Topic:
    """Create a new topic for a persona."""
    return Topic.objects.create(
        company=company,
        persona=persona,
        title=title,
        created_by=created_by,
        status=ContentStatus.DRAFT
    )
```

```typescript
// Frontend - Strict TypeScript
interface Topic {
  id: string;
  title: string;
  status: ContentStatus;
  personaId: string;
  createdAt: Date;
}

function createTopic(data: CreateTopicData): Observable<Topic> {
  return this.http.post<ApiResponse<Topic>>(`${this.baseUrl}/topics/`, data)
    .pipe(map(res => res.data));
}
```

### 11. Security Checks

#### Tenant Isolation (KRITICKE!)
```python
# KAZDY endpoint MUSI kontrolovat tenant!
def get_topics(self, request):
    company = self._get_company(request)  # Kontroluje ownership
    if not company:
        return Response({'error': 'Company not found or access denied'}, status=404)

    topics = TopicSelector.get_for_company(company_id=company.id)
    return Response({'data': topics})
```

#### Authentication
```python
# ViewSets
permission_classes = [IsAuthenticated]

# Custom permissions
class IsCompanyOwner(BasePermission):
    def has_object_permission(self, request, view, obj):
        return obj.company.organization.owner == request.user
```

### 12. Performance

#### Backend
```python
# VZDY pouzivat select_related/prefetch_related
topics = Topic.objects.filter(company=company)\
    .select_related('persona', 'created_by')\
    .prefetch_related('blog_posts')\
    .order_by('-created_at')

# Indexy v modelech
class Meta:
    indexes = [
        models.Index(fields=['company', 'status']),
        models.Index(fields=['company', 'created_at']),
    ]
```

#### Frontend
```typescript
// OnPush change detection
@Component({
  changeDetection: ChangeDetectionStrategy.OnPush,
})

// TrackBy pro ngFor
@for (topic of topics(); track topic.id) {
  <app-topic-card [topic]="topic" />
}
```

### 13. Tests
- Unit testy pro services/selectors
- Integration testy pro API endpoints
- Coverage target: 80%+

---

## PostHub-Specific Standards

### API Response Format
```json
{
  "status": "success",
  "data": { ... },
  "meta": { "page": 1, "pageSize": 20, "total": 150 }
}
```

### Naming Conventions
| Where | Convention | Example |
|-------|------------|---------|
| Python vars | snake_case | `created_at` |
| Python classes | PascalCase | `TopicService` |
| TypeScript vars | camelCase | `createdAt` |
| TypeScript classes | PascalCase | `TopicService` |
| JSON keys | camelCase | `createdAt` |
| API URLs | kebab-case | `/blog-posts/` |
| DB tables | snake_case | `content_topics` |

### Tier Naming
- BASIC, PRO, ULTIMATE (NE ENTERPRISE!)
- Prices in haliru (99000 = 990 Kc)

### Authentication
- Tests: `api_client.force_authenticate(user=user)`
- Production: JWT tokens via SimpleJWT

---

## CheckAgent Checklist Template

```markdown
### Status: PASS/FAIL

### Zakazane elementy
| Check | Status |
|-------|--------|
| Mock data | PASS/FAIL |
| Dummy variables | PASS/FAIL |
| TODO komentare | PASS/FAIL |
| console.log | PASS/FAIL |
| Hardcoded credentials | PASS/FAIL |
| any without comment | PASS/FAIL |

### Povinne elementy
| Check | Status |
|-------|--------|
| Kompletni implementace | PASS/FAIL |
| Error handling | PASS/FAIL |
| Input validation | PASS/FAIL |
| Type safety | PASS/FAIL |
| Security (tenant isolation) | PASS/FAIL |
| Performance | PASS/FAIL |
| Tests | PASS/FAIL/DEFERRED |

### Poznamky
[Konkretni problemy s file:line referencemi]

### Datum kontroly
YYYY-MM-DD
```

---

## Reference

- `files/02_BACKEND_DJANGO.md` - Backend patterns
- `files/05_FRONTEND_ANGULAR.md` - Frontend patterns
- `files/09_SECURITY.md` - Security standards
- `files/12_TESTING.md` - Testing standards
