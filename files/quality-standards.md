# Quality Standards - PostHub Project

> **ZERO TOLERANCE POLICY**  
> Mock data, dummy variables a TODO komentáře nejsou přípustné v produkčním kódu.

---

## 🚫 ZAKÁZANÉ ELEMENTY (NIKDY)

### 1. Mock Data
```typescript
// ❌ ZAKÁZÁNO
const mockPosts = [
  { id: 1, title: "Test Post" },
  { id: 2, title: "Another Test" }
];

// ✅ SPRÁVNĚ
const posts = await prisma.post.findMany();
```

### 2. Dummy Variables
```typescript
// ❌ ZAKÁZÁNO
const dummyUser = { id: 123, name: "John Doe" };
const tempData = [...];
const placeholderValue = "TODO";

// ✅ SPRÁVNĚ
const user = await userService.findById(userId);
const processedData = await processRealData(input);
const configValue = process.env.API_KEY;
```

### 3. TODO Komentáře (mimo testy)
```typescript
// ❌ ZAKÁZÁNO v produkčním kódu
// TODO: Implement error handling
// FIXME: This needs optimization
// HACK: Temporary solution

// ✅ POVOLENO pouze v testech
describe('Feature X', () => {
  // TODO: Add edge case tests
  it.todo('should handle empty input');
});
```

### 4. Console.log v Produkci
```typescript
// ❌ ZAKÁZÁNO
console.log('User data:', user);

// ✅ SPRÁVNĚ
logger.info('User authenticated', { userId: user.id });
```

### 5. Hardcoded Credentials
```typescript
// ❌ ZAKÁZÁNO
const apiKey = "sk-1234567890abcdef";
const dbPassword = "password123";

// ✅ SPRÁVNĚ
const apiKey = process.env.OPENAI_API_KEY;
const dbPassword = process.env.DATABASE_PASSWORD;
```

### 6. Ignorované Errors
```typescript
// ❌ ZAKÁZÁNO
try {
  await riskyOperation();
} catch (e) {
  // Silence is golden... NOT!
}

// ✅ SPRÁVNĚ
try {
  await riskyOperation();
} catch (error) {
  logger.error('Operation failed', { error, context });
  throw new AppError('Operation failed', 500);
}
```

### 7. Any Type bez Důvodu
```typescript
// ❌ ZAKÁZÁNO
function processData(data: any): any {
  return data.something;
}

// ✅ SPRÁVNĚ
interface InputData {
  something: string;
}

function processData(data: InputData): string {
  return data.something;
}
```

---

## ✅ POVINNÉ ELEMENTY (VŽDY)

### 1. Error Handling pro External Calls
```typescript
// ✅ VZOR
async function callExternalAPI() {
  try {
    const response = await fetch(url, {
      signal: AbortSignal.timeout(5000) // Timeout
    });
    
    if (!response.ok) {
      throw new APIError(`API returned ${response.status}`, response.status);
    }
    
    return await response.json();
  } catch (error) {
    if (error instanceof APIError) {
      logger.error('API call failed', { error, url });
      throw error;
    }
    
    if (error.name === 'AbortError') {
      throw new TimeoutError('API call timed out');
    }
    
    throw new AppError('Unexpected API error', 500);
  }
}
```

### 2. Input Validation (Zod Schemas)
```typescript
// ✅ VZOR
import { z } from 'zod';

const CreatePostSchema = z.object({
  title: z.string()
    .min(1, 'Title is required')
    .max(200, 'Title too long'),
  content: z.string()
    .min(1, 'Content is required'),
  aiPersonaId: z.string().uuid('Invalid persona ID'),
  scheduledAt: z.date().optional(),
});

type CreatePostInput = z.infer<typeof CreatePostSchema>;

// Usage
const validated = CreatePostSchema.parse(req.body);
```

### 3. Type Safety
```typescript
// ✅ VZOR
interface Post {
  id: string;
  title: string;
  content: string;
  status: 'draft' | 'scheduled' | 'published';
  createdAt: Date;
  updatedAt: Date;
}

// Strict function signatures
async function createPost(
  input: CreatePostInput,
  userId: string
): Promise<Post> {
  // Implementation
}
```

### 4. Security Checks

#### Authentication
```typescript
// ✅ VZOR
import { requireAuth } from '../middleware/auth';

router.post('/posts', 
  requireAuth, // Vždy první
  async (req, res) => {
    // req.user je nyní guaranteed
  }
);
```

#### Authorization
```typescript
// ✅ VZOR
async function deletePost(postId: string, userId: string) {
  const post = await prisma.post.findUnique({
    where: { id: postId }
  });
  
  if (!post) {
    throw new NotFoundError('Post not found');
  }
  
  if (post.userId !== userId) {
    throw new ForbiddenError('Not authorized to delete this post');
  }
  
  await prisma.post.delete({ where: { id: postId } });
}
```

#### Rate Limiting
```typescript
// ✅ VZOR
import rateLimit from 'express-rate-limit';

const createPostLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 10, // 10 requests per window
  message: 'Too many posts created, please try again later',
  standardHeaders: true,
  legacyHeaders: false,
});

router.post('/posts', createPostLimiter, async (req, res) => {
  // Implementation
});
```

### 5. Dokumentace v Kódu (JSDoc/TSDoc)
```typescript
// ✅ VZOR
/**
 * Creates a new post with AI-generated content
 * 
 * @param input - The post creation input
 * @param userId - The ID of the user creating the post
 * @returns The created post
 * @throws {ValidationError} If input is invalid
 * @throws {AIGenerationError} If AI generation fails
 * @throws {DatabaseError} If database operation fails
 * 
 * @example
 * ```typescript
 * const post = await createPost({
 *   title: "My Post",
 *   content: "Content here",
 *   aiPersonaId: "uuid-here"
 * }, "user-uuid");
 * ```
 */
async function createPost(
  input: CreatePostInput,
  userId: string
): Promise<Post> {
  // Implementation
}
```

### 6. Unit Tests pro Business Logiku
```typescript
// ✅ VZOR
describe('PostService', () => {
  describe('createPost', () => {
    it('should create post with valid input', async () => {
      const input = {
        title: 'Test Post',
        content: 'Test content',
        aiPersonaId: 'valid-uuid',
      };
      
      const result = await postService.createPost(input, 'user-id');
      
      expect(result).toMatchObject({
        title: input.title,
        content: input.content,
        status: 'draft',
      });
    });
    
    it('should throw ValidationError for invalid input', async () => {
      const input = { title: '', content: '' };
      
      await expect(
        postService.createPost(input as any, 'user-id')
      ).rejects.toThrow(ValidationError);
    });
    
    it('should handle AI generation failure gracefully', async () => {
      // Mock AI failure
      mockAIService.generate.mockRejectedValue(new Error('AI Error'));
      
      await expect(
        postService.createPost(validInput, 'user-id')
      ).rejects.toThrow(AIGenerationError);
    });
  });
});
```

### 7. Integration Tests pro API Endpoints
```typescript
// ✅ VZOR
describe('POST /api/posts', () => {
  it('should create post when authenticated', async () => {
    const response = await request(app)
      .post('/api/posts')
      .set('Authorization', `Bearer ${validToken}`)
      .send({
        title: 'Test Post',
        content: 'Test content',
        aiPersonaId: testPersonaId,
      })
      .expect(201);
    
    expect(response.body).toMatchObject({
      id: expect.any(String),
      title: 'Test Post',
      status: 'draft',
    });
  });
  
  it('should return 401 when not authenticated', async () => {
    await request(app)
      .post('/api/posts')
      .send(validPostData)
      .expect(401);
  });
  
  it('should return 400 for invalid input', async () => {
    const response = await request(app)
      .post('/api/posts')
      .set('Authorization', `Bearer ${validToken}`)
      .send({ title: '' }) // Invalid
      .expect(400);
    
    expect(response.body.error).toBeDefined();
  });
});
```

---

## 🎯 Coding Standards - TypeScript/JavaScript

### 1. Preferuj Const před Let
```typescript
// ❌ ŠPATNĚ
let user = await getUser();
let posts = await getPosts();

// ✅ SPRÁVNĚ
const user = await getUser();
const posts = await getPosts();
```

### 2. Používej Destructuring
```typescript
// ❌ ŠPATNĚ
const title = req.body.title;
const content = req.body.content;

// ✅ SPRÁVNĚ
const { title, content } = req.body;
```

### 3. Async/Await místo .then()
```typescript
// ❌ ŠPATNĚ
function getUser(id) {
  return prisma.user.findUnique({ where: { id } })
    .then(user => user)
    .catch(error => {
      console.error(error);
      throw error;
    });
}

// ✅ SPRÁVNĚ
async function getUser(id: string): Promise<User> {
  try {
    const user = await prisma.user.findUnique({ where: { id } });
    return user;
  } catch (error) {
    logger.error('Failed to get user', { id, error });
    throw new DatabaseError('Failed to fetch user');
  }
}
```

### 4. Named Exports místo Default
```typescript
// ❌ ŠPATNĚ
export default function createPost() { }

// ✅ SPRÁVNĚ
export function createPost() { }
export function deletePost() { }
export function updatePost() { }
```

### 5. Use Strict Mode
```typescript
// ✅ SPRÁVNĚ - tsconfig.json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true
  }
}
```

---

## 🌐 API Design Standards

### 1. RESTful Konvence
```typescript
// ✅ SPRÁVNĚ
GET    /api/posts           // List all posts
GET    /api/posts/:id       // Get single post
POST   /api/posts           // Create post
PUT    /api/posts/:id       // Update post (full)
PATCH  /api/posts/:id       // Update post (partial)
DELETE /api/posts/:id       // Delete post
```

### 2. Consistent Error Responses
```typescript
// ✅ VZOR
interface ErrorResponse {
  error: {
    message: string;
    code: string;
    details?: Record<string, any>;
  };
}

// Usage
res.status(400).json({
  error: {
    message: 'Validation failed',
    code: 'VALIDATION_ERROR',
    details: zodError.errors
  }
});
```

### 3. Pagination pro Lists
```typescript
// ✅ VZOR
interface PaginatedResponse<T> {
  data: T[];
  pagination: {
    page: number;
    perPage: number;
    total: number;
    totalPages: number;
  };
}

app.get('/api/posts', async (req, res) => {
  const page = parseInt(req.query.page as string) || 1;
  const perPage = parseInt(req.query.perPage as string) || 20;
  
  const [data, total] = await Promise.all([
    prisma.post.findMany({
      skip: (page - 1) * perPage,
      take: perPage,
    }),
    prisma.post.count(),
  ]);
  
  res.json({
    data,
    pagination: {
      page,
      perPage,
      total,
      totalPages: Math.ceil(total / perPage),
    },
  });
});
```

### 4. Rate Limiting per Endpoint
```typescript
// ✅ VZOR
const standardLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
});

const strictLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
});

app.get('/api/posts', standardLimiter, getPosts);
app.post('/api/posts', strictLimiter, createPost);
```

### 5. CORS Properly Configured
```typescript
// ✅ VZOR
import cors from 'cors';

app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || [],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
```

---

## 🗄️ Database Standards

### 1. Transactions pro Multi-step Operations
```typescript
// ✅ VZOR
async function createPostWithNotification(input: CreatePostInput, userId: string) {
  return await prisma.$transaction(async (tx) => {
    // Step 1: Create post
    const post = await tx.post.create({
      data: {
        ...input,
        userId,
      },
    });
    
    // Step 2: Create notification
    await tx.notification.create({
      data: {
        userId,
        type: 'POST_CREATED',
        postId: post.id,
      },
    });
    
    return post;
  });
}
```

### 2. Proper Indexing
```prisma
// ✅ VZOR - schema.prisma
model Post {
  id        String   @id @default(uuid())
  userId    String
  status    String
  createdAt DateTime @default(now())
  
  user User @relation(fields: [userId], references: [id])
  
  @@index([userId])
  @@index([status])
  @@index([createdAt])
  @@index([userId, status])
}
```

### 3. Migration Scripts
```typescript
// ✅ VZOR - migrations/20240101_add_posts.sql
-- CreateTable
CREATE TABLE "Post" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'draft',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT "Post_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "Post_userId_idx" ON "Post"("userId");
CREATE INDEX "Post_status_idx" ON "Post"("status");
```

### 4. Seed Data Separated
```typescript
// ✅ VZOR - prisma/seed.ts
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  // Seed test data
  await prisma.user.upsert({
    where: { email: 'test@example.com' },
    update: {},
    create: {
      email: 'test@example.com',
      name: 'Test User',
    },
  });
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
```

---

## 🔒 Security Standards

### 1. Input Sanitization
```typescript
// ✅ VZOR
import DOMPurify from 'isomorphic-dompurify';

function sanitizeHtml(input: string): string {
  return DOMPurify.sanitize(input, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a', 'p', 'br'],
    ALLOWED_ATTR: ['href'],
  });
}
```

### 2. SQL Injection Prevention
```typescript
// ✅ SPRÁVNĚ - Používej Prisma ORM
const posts = await prisma.post.findMany({
  where: {
    userId: userId, // Automatically escaped
  },
});

// ❌ NIKDY nepouštěj raw SQL s uživatelským inputem
// const posts = await prisma.$queryRaw`SELECT * FROM Post WHERE userId = ${userId}`;
```

### 3. XSS Protection
```typescript
// ✅ VZOR
import helmet from 'helmet';

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'", "'unsafe-inline'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", 'data:', 'https:'],
    },
  },
}));
```

### 4. CSRF Tokens
```typescript
// ✅ VZOR
import csrf from 'csurf';

const csrfProtection = csrf({ cookie: true });

app.post('/api/posts', csrfProtection, async (req, res) => {
  // Protected endpoint
});
```

### 5. JWT Validation
```typescript
// ✅ VZOR
import jwt from 'jsonwebtoken';

function verifyToken(token: string): TokenPayload {
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as TokenPayload;
    
    // Additional checks
    if (decoded.exp < Date.now() / 1000) {
      throw new TokenExpiredError();
    }
    
    return decoded;
  } catch (error) {
    if (error instanceof jwt.JsonWebTokenError) {
      throw new InvalidTokenError();
    }
    throw error;
  }
}
```

### 6. Environment Variables pro Secrets
```typescript
// ✅ VZOR - .env
DATABASE_URL="postgresql://..."
JWT_SECRET="random-secret-here"
OPENAI_API_KEY="sk-..."
STRIPE_SECRET_KEY="sk_test_..."

// ✅ VZOR - config.ts
import { z } from 'zod';

const envSchema = z.object({
  DATABASE_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  OPENAI_API_KEY: z.string().startsWith('sk-'),
  STRIPE_SECRET_KEY: z.string(),
});

export const config = envSchema.parse(process.env);
```

---

## 📊 Performance Standards

### 1. Prevent N+1 Queries
```typescript
// ❌ ŠPATNĚ - N+1 Query
const posts = await prisma.post.findMany();
for (const post of posts) {
  post.author = await prisma.user.findUnique({ where: { id: post.userId } });
}

// ✅ SPRÁVNĚ - Single Query with Include
const posts = await prisma.post.findMany({
  include: {
    author: true,
  },
});
```

### 2. Caching Strategy
```typescript
// ✅ VZOR
import Redis from 'ioredis';

const redis = new Redis(process.env.REDIS_URL);

async function getCachedPosts(userId: string): Promise<Post[]> {
  const cacheKey = `posts:${userId}`;
  
  // Try cache first
  const cached = await redis.get(cacheKey);
  if (cached) {
    return JSON.parse(cached);
  }
  
  // Fetch from DB
  const posts = await prisma.post.findMany({
    where: { userId },
  });
  
  // Cache for 5 minutes
  await redis.setex(cacheKey, 300, JSON.stringify(posts));
  
  return posts;
}
```

### 3. Batch Operations
```typescript
// ❌ ŠPATNĚ - Multiple individual queries
for (const postId of postIds) {
  await prisma.post.delete({ where: { id: postId } });
}

// ✅ SPRÁVNĚ - Single batch operation
await prisma.post.deleteMany({
  where: {
    id: {
      in: postIds,
    },
  },
});
```

---

## ✅ CheckAgent Checklist

Pro každý úkol, CheckAgent MUSÍ zkontrolovat:

### Critical (Must PASS)
- [ ] ❌ Žádná mock data
- [ ] ❌ Žádné dummy variables
- [ ] ❌ Žádné TODO komentáře (kromě testů)
- [ ] ✅ Kompletní implementace
- [ ] ✅ Error handling všude
- [ ] ✅ Input validation (zod)
- [ ] ✅ Type safety (žádné any bez důvodu)

### Security (Must PASS)
- [ ] ✅ Auth middleware where needed
- [ ] ✅ Authorization checks
- [ ] ✅ Rate limiting
- [ ] ✅ Input sanitization
- [ ] ✅ Environment variables pro secrets
- [ ] ✅ XSS/CSRF protection

### Code Quality (Should PASS)
- [ ] ✅ Dokumentace (JSDoc)
- [ ] ✅ Unit tests
- [ ] ✅ Integration tests
- [ ] ✅ Coding conventions
- [ ] ✅ Performance considerations
- [ ] ✅ Database best practices

### Nice to Have (Recommended)
- [ ] ✅ Comments for complex logic
- [ ] ✅ Reusable helper functions
- [ ] ✅ Consistent naming
- [ ] ✅ Clean code structure

---

## 📈 Failure Analysis

Pokud CheckAgent najde FAIL, musí identifikovat:

1. **Typ problému** (Mock data / Dummy vars / TODO / etc.)
2. **Konkrétní lokace** (soubor:řádek)
3. **Nalezený kód** (co přesně je problém)
4. **Důvod** (proč je to problém)
5. **Fix** (jak to opravit)

### Příklad FAIL Report:
```markdown
### Status: FAIL ❌

### Nalezené Problémy

1. **src/api/content.ts:45** - Mock data
   - Nalezeno: `const mockPosts = [{ id: 1, title: "Test" }]`
   - Důvod: Mock data nejsou přípustná v produkčním kódu
   - Fix: Nahradit real DB query: `const posts = await prisma.post.findMany()`

2. **src/services/contentService.ts:23** - TODO komentář
   - Nalezeno: `// TODO: Add error handling`
   - Důvod: Implementace musí být kompletní
   - Fix: Implementovat error handling s try/catch a proper error types

3. **src/api/content.ts:67** - Chybí rate limiting
   - Nalezeno: Endpoint bez rate limit middleware
   - Důvod: Security risk - možnost abuse
   - Fix: Přidat: `router.post('/posts', rateLimit({ max: 10, windowMs: 60000 }), ...)`
```

---

**Verze:** 1.0.0  
**Poslední Update:** 2024-12-17  
**Autor:** Martin - Praut s.r.o.  
**Pro Projekt:** PostHub SaaS Platform
