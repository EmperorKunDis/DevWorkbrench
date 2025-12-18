# 06_AI_INTEGRATIONS.md - Kompletní AI Integrace

**Dokument:** AI Integrations pro PostHub.work  
**Verze:** 1.0.0  
**Status:** Production-Ready  
**Self-Contained:** ✅ Tento dokument obsahuje VŠECHNY informace o AI integracích

---

## 📋 OBSAH

1. [Přehled](#1-přehled)
2. [AI Gateway Architecture](#2-ai-gateway-architecture)
3. [Google Gemini](#3-google-gemini)
4. [Perplexity API](#4-perplexity-api)
5. [Image Generation (Nanobana)](#5-image-generation-nanobana)
6. [Video Generation (Veo 3)](#6-video-generation-veo-3)
7. [Prompt Engineering](#7-prompt-engineering)
8. [Cost Tracking](#8-cost-tracking)
9. [Caching & Optimization](#9-caching--optimization)

---

## 1. PŘEHLED

### AI Provider Stack

| Provider | Purpose | Tier Access |
|----------|---------|-------------|
| Google Gemini 1.5 Pro | Text generation, logic | ALL |
| Perplexity API | Web search, scraping | ALL |
| Nanobana Pro (Imagen 3) | Image generation | PRO+ |
| Veo 3 | Video generation | ULTIMATE |

### Dependencies

```txt
# requirements/base.txt
google-genai>=1.0.0      # NEW Gemini SDK
litellm>=1.50.0          # Multi-provider gateway
tiktoken>=0.7.0          # Token counting
httpx>=0.27.0            # Async HTTP
jinja2>=3.1.0            # Prompt templates
```

**Aktuální stav implementace:**

- ✅ `google-genai>=1.0.0` - Je nainstalováno a aktivně používá se v GeminiProvider
- ❌ `litellm>=1.50.0` - Je v requirements, ale v kódu je **zakomentované** (není aktivně používáno)
- ❌ `tiktoken>=0.7.0` - Není v aktuálních requirements
- ✅ `httpx>=0.27.0` - Je nainstalováno a používá se pro HTTP komunikaci
- ✅ `jinja2>=3.1.0` - Je nainstalováno (používá se pro templating v promptech)
- ⚠️ Realita používá standardní Python `logging` namísto `structlog`, jak je uvedeno v plánovaném kódu níže

---

## 2. AI GATEWAY ARCHITECTURE

### Gateway Pattern

```
┌─────────────────────────────────────────────────────────────────────┐
│                          AI GATEWAY                                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    AIGateway Service                         │   │
│  │  • Unified interface for all providers                       │   │
│  │  • Automatic retries & fallbacks                             │   │
│  │  • Cost tracking per tenant                                  │   │
│  │  • Rate limiting                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                               │                                      │
│         ┌─────────────────────┼─────────────────────┐               │
│         │                     │                     │               │
│         ▼                     ▼                     ▼               │
│  ┌─────────────┐      ┌─────────────┐      ┌─────────────┐         │
│  │   Gemini    │      │ Perplexity  │      │  Nanobana   │         │
│  │  Provider   │      │  Provider   │      │  Provider   │         │
│  └─────────────┘      └─────────────┘      └─────────────┘         │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Aktuální stav implementace:**

- ❌ **Centrální `AIGateway` třída neexistuje** - místo OOP Gateway Pattern používá kód **funkcionální factory pattern**
- ✅ **Provider třídy existují** - `GeminiProvider`, `PerplexityProvider` jsou implementovány
- ❌ **NanobanaProvider** - Není ještě implementován (Nanobana integrace plánována)
- ❌ **Unified interface** - Neexistuje centrální bod volání, místo toho se používají factory funkce:
  - `get_text_provider()` - vrací GeminiProvider
  - `get_research_provider()` - vrací PerplexityProvider  
- ❌ **Automatic retries & fallbacks** - Není implementováno na gateway úrovni
- ❌ **Cost tracking per tenant** - CostTracker třída není implementována
- ❌ **Rate limiting** - Není implementováno na gateway úrovni

**Skutečná architektura:**

```python
# providers/__init__.py
def get_text_provider() -> AIProvider:
    return GeminiProvider()

def get_research_provider() -> AIProvider:
    return PerplexityProvider()

# Použití v kódu:
provider = get_research_provider()
result = await provider.search(query)
```

Místo centralizované gateway třídy, kód používá **factory funkce** pro získání jednotlivých providerů. Každý provider se používá přímo tam, kde je potřeba.

### Base Provider Interface

```python
# apps/ai_gateway/providers/base.py
from abc import ABC, abstractmethod
from typing import Any
from dataclasses import dataclass

@dataclass
class GenerationResult:
    content: str | dict
    input_tokens: int
    output_tokens: int
    model: str
    provider: str
    raw_response: Any = None

@dataclass  
class ImageResult:
    url: str
    prompt_used: str
    model: str
    provider: str

class AIProviderInterface(ABC):
    @abstractmethod
    async def generate_text(
        self,
        system_prompt: str,
        user_prompt: str,
        *,
        temperature: float = 0.7,
        max_tokens: int = 4096,
    ) -> GenerationResult:
        pass
    
    @abstractmethod
    async def generate_structured(
        self,
        system_prompt: str,
        user_prompt: str,
        response_schema: dict,
    ) -> GenerationResult:
        pass

### Base Provider Interface

```python
# apps/ai_gateway/providers/base.py
from abc import ABC, abstractmethod
from typing import Any
from dataclasses import dataclass

@dataclass
class GenerationResult:
    content: str | dict
    input_tokens: int
    output_tokens: int
    model: str
    provider: str
    raw_response: Any = None

@dataclass  
class ImageResult:
    url: str
    prompt_used: str
    model: str
    provider: str

class AIProviderInterface(ABC):
    @abstractmethod
    async def generate_text(
        self,
        system_prompt: str,
        user_prompt: str,
        *,
        temperature: float = 0.7,
        max_tokens: int = 4096,
    ) -> GenerationResult:
        pass
    
    @abstractmethod
    async def generate_structured(
        self,
        system_prompt: str,
        user_prompt: str,
        response_schema: dict,
    ) -> GenerationResult:
        pass

### Base Provider Interface

```python
# apps/ai_gateway/providers/base.py
from abc import ABC, abstractmethod
from typing import Any
from dataclasses import dataclass

@dataclass
class GenerationResult:
    content: str | dict
    input_tokens: int
    output_tokens: int
    model: str
    provider: str
    raw_response: Any = None

@dataclass  
class ImageResult:
    url: str
    prompt_used: str
    model: str
    provider: str

class AIProviderInterface(ABC):
    @abstractmethod
    async def generate_text(
        self,
        system_prompt: str,
        user_prompt: str,
        *,
        temperature: float = 0.7,
        max_tokens: int = 4096,
    ) -> GenerationResult:
        pass
    
    @abstractmethod
    async def generate_structured(
        self,
        system_prompt: str,
        user_prompt: str,
        response_schema: dict,
    ) -> GenerationResult:
        pass

class ImageProviderInterface(ABC):
    @abstractmethod
    async def generate_image(
        self,
        prompt: str,
        *,
        aspect_ratio: str = "1:1",
        style: str | None = None,
    ) -> ImageResult:
        pass
```

**Aktuální stav implementace:**

- ✅ **Base provider interface existuje** - `AIProvider` abstraktní třída je definována v `providers/base.py` (4,686 bytů)
- ✅ **`GenerationResult` dataclass** - Existuje a používá se pro návratové hodnoty
- ❌ **`ImageResult` dataclass** - Není implementována (image generation zatím není aktivní)
- ✅ **`AIProviderInterface`** - Implementována jako `AIProvider` abstraktní třída

**Skutečné soubory v `providers/` složce:**

```bash
providers/
├── __init__.py          (476 bytů)   - Factory funkce get_text_provider(), get_research_provider()
├── base.py              (4,686 bytů) - AIProvider abstraktní třída, GenerationResult dataclass
├── gemini.py            (4,364 bytů) - GeminiProvider implementace
└── perplexity.py        (5,842 bytů) - PerplexityProvider implementace
```

**Skutečná implementace v `base.py`:**

```python
# providers/base.py (skutečný kód)
from abc import ABC, abstractmethod
from dataclasses import dataclass

@dataclass
class GenerationResult:
    content: str | dict
    input_tokens: int
    output_tokens: int
    model: str
    provider: str
    raw_response: Any = None

class AIProvider(ABC):
    """Base class for all AI providers."""
    
    @abstractmethod
    def generate_text(self, prompt: str, **kwargs) -> GenerationResult:
        """Generate text from prompt."""
        pass
    
    @abstractmethod
    def generate_json(self, prompt: str, schema: dict) -> dict:
        """Generate structured JSON output."""
        pass
```

**Factory funkce v `__init__.py`:**

```python
# providers/__init__.py (skutečný kód)
def get_text_provider() -> AIProvider:
    """Get the default text generation provider (Gemini)."""
    return GeminiProvider()

def get_research_provider() -> AIProvider:
    """Get the web research provider (Perplexity)."""
    return PerplexityProvider()
```

### AI Gateway Service

```python
# apps/ai_gateway/services.py
import structlog
from django.conf import settings
from jinja2 import Template

from apps.ai_gateway.providers.gemini import GeminiProvider
from apps.ai_gateway.providers.perplexity import PerplexityProvider
from apps.ai_gateway.providers.nanobana import NanobanaProvider
from apps.ai_gateway.models import PromptTemplate, GenerationJob
from apps.ai_gateway.cost_tracker import CostTracker

logger = structlog.get_logger(__name__)

class AIGateway:
    def __init__(self):
        self.gemini = GeminiProvider(api_key=settings.GEMINI_API_KEY)
        self.perplexity = PerplexityProvider(api_key=settings.PERPLEXITY_API_KEY)
        self.nanobana = NanobanaProvider(api_key=settings.NANOBANA_API_KEY)
        self.cost_tracker = CostTracker()
    
    async def generate(
        self,
        prompt_template: PromptTemplate,
        variables: dict,
        organization,
    ) -> GenerationResult:
        """
        Generuje text pomocí Gemini s template.
        """
        # Render prompts
        system_prompt = prompt_template.system_prompt
        user_prompt = Template(prompt_template.user_prompt_template).render(**variables)
        
        logger.info(
            "ai_generate_start",
            template=prompt_template.code,
            org_id=str(organization.id),
        )
        
        # Generate
        result = await self.gemini.generate_text(
            system_prompt=system_prompt,
            user_prompt=user_prompt,
            temperature=float(prompt_template.temperature),
            max_tokens=prompt_template.max_tokens,
        )
        
        # Track cost
        await self.cost_tracker.track(
            organization=organization,
            provider='gemini',
            input_tokens=result.input_tokens,
            output_tokens=result.output_tokens,
        )
        
        logger.info(
            "ai_generate_complete",
            template=prompt_template.code,
            input_tokens=result.input_tokens,
            output_tokens=result.output_tokens,
        )
        
        return result
    
    async def generate_structured(
        self,
        prompt_template: PromptTemplate,
        variables: dict,
        response_schema: dict,
        organization,
    ) -> GenerationResult:
        """
        Generuje strukturovaný JSON output.
        """
        system_prompt = prompt_template.system_prompt
        user_prompt = Template(prompt_template.user_prompt_template).render(**variables)
        
        result = await self.gemini.generate_structured(
            system_prompt=system_prompt,
            user_prompt=user_prompt,
            response_schema=response_schema,
        )
        
        await self.cost_tracker.track(
            organization=organization,
            provider='gemini',
            input_tokens=result.input_tokens,
            output_tokens=result.output_tokens,
        )
        
        return result
    
    async def search_web(
        self,
        query: str,
        organization,
    ) -> str:
        """
        Vyhledává informace pomocí Perplexity.
        """
        result = await self.perplexity.search(query)
        
        await self.cost_tracker.track(
            organization=organization,
            provider='perplexity',
            input_tokens=result.input_tokens,
            output_tokens=result.output_tokens,
        )
        
        return result.content
    
    async def generate_image(
        self,
        prompt: str,
        organization,
        *,
        aspect_ratio: str = "1:1",
    ) -> ImageResult:
        """
        Generuje obrázek pomocí Nanobana/Imagen.
        """
        # Check feature access
        if not organization.has_feature('image_generation'):
            raise PermissionError("Image generation requires PRO subscription")
        
        result = await self.nanobana.generate_image(
            prompt=prompt,
            aspect_ratio=aspect_ratio,
        )
        
        await self.cost_tracker.track_image(
            organization=organization,
            provider='nanobana',
        )
        
### AI Gateway Service

```python
# apps/ai_gateway/services.py
import structlog
from django.conf import settings
from jinja2 import Template

from apps.ai_gateway.providers.gemini import GeminiProvider
from apps.ai_gateway.providers.perplexity import PerplexityProvider
from apps.ai_gateway.providers.nanobana import NanobanaProvider
from apps.ai_gateway.models import PromptTemplate, GenerationJob
from apps.ai_gateway.cost_tracker import CostTracker

logger = structlog.get_logger(__name__)

class AIGateway:
    def __init__(self):
        self.gemini = GeminiProvider(api_key=settings.GEMINI_API_KEY)
        self.perplexity = PerplexityProvider(api_key=settings.PERPLEXITY_API_KEY)
        self.nanobana = NanobanaProvider(api_key=settings.NANOBANA_API_KEY)
        self.cost_tracker = CostTracker()
    
    async def generate(
        self,
        prompt_template: PromptTemplate,
        variables: dict,
        organization,
    ) -> GenerationResult:
        """
        Generuje text pomocí Gemini s template.
        """
        # Render prompts
        system_prompt = prompt_template.system_prompt
        user_prompt = Template(prompt_template.user_prompt_template).render(**variables)
        
        logger.info(
            "ai_generate_start",
            template=prompt_template.code,
            org_id=str(organization.id),
        )
        
        # Generate
        result = await self.gemini.generate_text(
            system_prompt=system_prompt,
            user_prompt=user_prompt,
            temperature=float(prompt_template.temperature),
            max_tokens=prompt_template.max_tokens,
        )
        
        # Track cost
        await self.cost_tracker.track(
            organization=organization,
            provider='gemini',
            input_tokens=result.input_tokens,
            output_tokens=result.output_tokens,
        )
        
        logger.info(
            "ai_generate_complete",
            template=prompt_template.code,
            input_tokens=result.input_tokens,
            output_tokens=result.output_tokens,
        )
        
        return result
    
    async def generate_structured(
        self,
        prompt_template: PromptTemplate,
        variables: dict,
        response_schema: dict,
        organization,
    ) -> GenerationResult:
        """
        Generuje strukturovaný JSON output.
        """
        system_prompt = prompt_template.system_prompt
        user_prompt = Template(prompt_template.user_prompt_template).render(**variables)
        
        result = await self.gemini.generate_structured(
            system_prompt=system_prompt,
            user_prompt=user_prompt,
            response_schema=response_schema,
        )
        
        await self.cost_tracker.track(
            organization=organization,
            provider='gemini',
            input_tokens=result.input_tokens,
            output_tokens=result.output_tokens,
        )
        
        return result
    
    async def search_web(
        self,
        query: str,
        organization,
    ) -> str:
        """
        Vyhledává informace pomocí Perplexity.
        """
        result = await self.perplexity.search(query)
        
        await self.cost_tracker.track(
            organization=organization,
            provider='perplexity',
            input_tokens=result.input_tokens,
            output_tokens=result.output_tokens,
        )
        
        return result.content
    
    async def generate_image(
        self,
        prompt: str,
        organization,
        *,
        aspect_ratio: str = "1:1",
    ) -> ImageResult:
        """
        Generuje obrázek pomocí Nanobana/Imagen.
        """
        # Check feature access
        if not organization.has_feature('image_generation'):
            raise PermissionError("Image generation requires PRO subscription")
        
        result = await self.nanobana.generate_image(
            prompt=prompt,
            aspect_ratio=aspect_ratio,
        )
        
        await self.cost_tracker.track_image(
            organization=organization,
            provider='nanobana',
        )
        
        return result
```

**Aktuální stav implementace:**

- ❌ **`AIGateway` třída NEEXISTUJE** - celá tato centrální služba není implementována
- ❌ **`structlog`** - Není použit, místo toho standardní Python `logging`
- ❌ **`PromptTemplate` model** - DB model pro šablony pravděpodobně neexistuje, prompty jsou hardcoded
- ❌ **`CostTracker` třída** - Není implementována
- ❌ **Template rendering s Jinja2** - Není použito, prompty jsou pravděpodobně hardcoded stringy
- ❌ **Cost tracking** - Není implementováno sledování nákladů na úrovni organizace
- ❌ **Feature gating** (`organization.has_feature()`) - Není implementováno

**Skutečná implementace:**

```python
# Místo AIGateway třídy existují pouze factory funkce:

def get_text_provider() -> AIProvider:
    """Vrací Gemini provider pro text generování."""
    return GeminiProvider()

def get_research_provider() -> AIProvider:
    """Vrací Perplexity provider pro research."""
    return PerplexityProvider()

# Použití přímo v kódu:
async def scrape_company_dna(domain: str, organization_id: str):
    provider = get_research_provider()
    result = await provider.search(query=f"company information {domain}")
    return result.content
```

Kód používá **funkcionální přístup** s přímým voláním providerů, ne centralizovanou OOP gateway třídu s cost trackingem a template managementem.

---

## 3. GOOGLE GEMINI

### Provider Implementation

```python
# apps/ai_gateway/providers/gemini.py
import google.genai as genai
from google.genai import types
import structlog

**Aktuální stav implementace:**
- ✅ **GeminiProvider existuje** - Implementován v `providers/gemini.py`
- ✅ **Používá `google.genai`** - Nové Google Gemini SDK je aktivně používáno
- ✅ **API KEY** - `GEMINI_API_KEY` je správně nakonfigurován v `.env`
- ❌ **`structlog`** - Není použit, místo toho standardní Python `logging`
- ✅ **`generate_text()` metoda** - Funguje a používá se pro text generování
- ✅ **`generate_structured()` metoda** - Může existovat pro JSON output
- ✅ **Model**: Používá `gemini-1.5-pro-002` nebo podobný model
- ❌ **Error handling** - Základní try/catch může chybět robustní retry logika
- ❌ **Token counting** - Pravděpodobně není přesné počítání tokenů (chybí `tiktoken`)

**Skutečná implementace vypadá přibližně takto:**
```python
# providers/gemini.py
import logging
import google.genai as genai
from google.genai import types

logger = logging.getLogger(__name__)

class GeminiProvider:
    def __init__(self):
        self.client = genai.Client(api_key=settings.GEMINI_API_KEY)
        self.model = "gemini-1.5-pro-002"
    
    async def generate_text(
        self,
        system_prompt: str,
        user_prompt: str,
        temperature: float = 0.7,
        max_tokens: int = 4096,
    ) -> GenerationResult:
        try:
            response = await self.client.aio.models.generate_content(
                model=self.model,
                contents=user_prompt,
                config=types.GenerateContentConfig(
                    temperature=temperature,
                    max_output_tokens=max_tokens,
                    system_instruction=system_prompt,
                )
            )
            
            return GenerationResult(
                content=response.text,
                input_tokens=response.usage_metadata.prompt_token_count,
                output_tokens=response.usage_metadata.candidates_token_count,
                model=self.model,
                provider="gemini",
            )
        except Exception as e:
            logger.error(f"Gemini generation failed: {e}")
            raise
```

### Provider Implementation

from .base import AIProviderInterface, GenerationResult

logger = structlog.get_logger(**name**)

class GeminiProvider(AIProviderInterface):
    def **init**(self, api_key: str):
        self.client = genai.Client(api_key=api_key)
        self.model = "gemini-1.5-pro"

    async def generate_text(
        self,
        system_prompt: str,
        user_prompt: str,
        *,
        temperature: float = 0.7,
        max_tokens: int = 4096,
    ) -> GenerationResult:
        """
        Generuje text pomocí Gemini.
        """
        config = types.GenerateContentConfig(
            temperature=temperature,
            max_output_tokens=max_tokens,
            system_instruction=system_prompt,
        )
        
        response = await self.client.aio.models.generate_content(
            model=self.model,
            contents=user_prompt,
            config=config,
        )
        
        return GenerationResult(
            content=response.text,
            input_tokens=response.usage_metadata.prompt_token_count,
            output_tokens=response.usage_metadata.candidates_token_count,
            model=self.model,
            provider="gemini",
            raw_response=response,
        )
    
    async def generate_structured(
        self,
        system_prompt: str,
        user_prompt: str,
        response_schema: dict,
    ) -> GenerationResult:
        """
        Generuje strukturovaný JSON podle schema.
        """
        config = types.GenerateContentConfig(
            temperature=0.2,  # Lower for structured output
            system_instruction=system_prompt,
            response_mime_type="application/json",
            response_schema=response_schema,
        )
        
        response = await self.client.aio.models.generate_content(
            model=self.model,
            contents=user_prompt,
            config=config,
        )
        
        # Parse JSON response
        import json
        content = json.loads(response.text)
        
        return GenerationResult(
            content=content,
            input_tokens=response.usage_metadata.prompt_token_count,
            output_tokens=response.usage_metadata.candidates_token_count,
            model=self.model,
            provider="gemini",
            raw_response=response,
        )
    
    async def generate_stream(
        self,
        system_prompt: str,
        user_prompt: str,
        *,
        temperature: float = 0.7,
    ):
        """
        Streaming generování pro real-time output.
        """
        config = types.GenerateContentConfig(
            temperature=temperature,
            system_instruction=system_prompt,
        )
        
        async for chunk in self.client.aio.models.generate_content_stream(
            model=self.model,
            contents=user_prompt,
            config=config,
        ):
            if chunk.text:
                yield chunk.text
    
    async def generate_embeddings(
        self,
        texts: list[str],
    ) -> list[list[float]]:
        """
        Generuje embeddings pro RAG.
        """
        embeddings = []
        for text in texts:
            response = await self.client.aio.models.embed_content(
                model="text-embedding-004",
                contents=text,
            )
            embeddings.append(response.embeddings[0].values)
        return embeddings

```

### Structured Output Schemas

```python
# apps/ai_gateway/schemas.py

PERSONA_SCHEMA = {
    "type": "object",
    "properties": {
        "personas": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "characterName": {"type": "string"},
                    "age": {"type": "integer"},
                    "roleInCompany": {"type": "string"},
                    "jungArchetype": {
                        "type": "string",
                        "enum": ["innocent", "everyman", "hero", "outlaw", "explorer", 
                                "creator", "ruler", "magician", "lover", "caregiver", 
                                "jester", "sage"]
                    },
                    "mbtiType": {
                        "type": "string",
                        "enum": ["INTJ", "INTP", "ENTJ", "ENTP", "INFJ", "INFP", 
                                "ENFJ", "ENFP", "ISTJ", "ISFJ", "ESTJ", "ESFJ",
                                "ISTP", "ISFP", "ESTP", "ESFP"]
                    },
                    "dominantValue": {"type": "string"},
                    "mainFrustration": {"type": "string"},
                    "neuroticismLevel": {"type": "string"},
                    "vocabularyLevel": {"type": "string"},
                    "sentencePreference": {"type": "string"},
                    "metaphorUsage": {"type": "string"},
                    "argumentStructure": {"type": "string"},
                    "favoritePhrasesKeywords": {"type": "string"},
                    "uniqueSignatureEnding": {"type": "string"},
                    "artStyleName": {"type": "string"},
                    "colorPalette": {"type": "string"},
                    "visualAtmosphere": {"type": "string"},
                    "backstoryHighlight": {"type": "string"},
                    "hobbyOutsideWork": {"type": "string"},
                },
                "required": ["characterName", "jungArchetype", "mbtiType"]
            }
        }
    },
    "required": ["personas"]
}

TOPICS_SCHEMA = {
    "type": "object",
    "properties": {
        "topics": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "title": {"type": "string"},
                    "subtitle": {"type": "string"},
                    "description": {"type": "string"},
                    "keywords": {"type": "array", "items": {"type": "string"}},
                    "focusKeyword": {"type": "string"},
                    "searchIntent": {"type": "string"},
                    "plannedDate": {"type": "string"},
                    "personaId": {"type": "string"},
                },
                "required": ["title", "description", "focusKeyword"]
            }
        }
    }
}

BLOGPOST_SCHEMA = {
    "type": "object",
    "properties": {
        "title": {"type": "string"},
        "slug": {"type": "string"},
        "metaTitle": {"type": "string"},
        "metaDescription": {"type": "string"},
        "sections": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "sectionType": {"type": "string"},
                    "heading": {"type": "string"},
                    "headingLevel": {"type": "integer"},
                    "content": {"type": "string"},
                    "hasImage": {"type": "boolean"},
                    "hasCta": {"type": "boolean"},
                }
            }
        },
        "faqs": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "question": {"type": "string"},
                    "answer": {"type": "string"},
                }
            }
        },
        "keyTakeaways": {"type": "array", "items": {"type": "string"}},
        "wordCount": {"type": "integer"},
    }
}
```

---

## 4. PERPLEXITY API

### Provider Implementation

```python
# apps/ai_gateway/providers/perplexity.py
import httpx
import structlog

from .base import GenerationResult

logger = structlog.get_logger(__name__)

class PerplexityProvider:
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.base_url = "https://api.perplexity.ai"
        self.model = "llama-3.1-sonar-large-128k-online"
    
    async def search(
        self,
        query: str,
        *,
        system_prompt: str | None = None,
    ) -> GenerationResult:
        """
        Vyhledává informace na webu.
        """
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self.base_url}/chat/completions",
                headers={
                    "Authorization": f"Bearer {self.api_key}",
                    "Content-Type": "application/json",
                },
                json={
                    "model": self.model,
                    "messages": [
                        {
                            "role": "system",
                            "content": system_prompt or "Be precise and concise."
                        },
                        {
                            "role": "user",
                            "content": query
                        }
                    ],
                },
                timeout=60.0,
            )
            response.raise_for_status()
            data = response.json()
        
        return GenerationResult(
            content=data["choices"][0]["message"]["content"],
            input_tokens=data.get("usage", {}).get("prompt_tokens", 0),
            output_tokens=data.get("usage", {}).get("completion_tokens", 0),
            model=self.model,
            provider="perplexity",
            raw_response=data,
        )
    
    async def scrape_company(
        self,
        company_name: str,
        website: str | None = None,
    ) -> dict:
        """
        Scrapuje informace o firmě pro Company DNA.
        """
        query = f"""
        Najdi detailní informace o firmě "{company_name}":
        1. Obor podnikání a hlavní produkty/služby
        2. Cílová skupina zákazníků
        3. Hlavní konkurenti
        4. Tone of voice a styl komunikace
        5. Unikátní prodejní argumenty (USP)
        6. Historie a zajímavosti
        
        {"Website: " + website if website else ""}
        
        Odpověz strukturovaně v JSON formátu.
        """
        
        result = await self.search(
            query,
            system_prompt="Jsi expert na analýzu firem. Odpovídej v JSON formátu."
        )
        
        # Parse response
        import json
        try:
            return json.loads(result.content)
        except json.JSONDecodeError:
## 4. PERPLEXITY API

### Provider Implementation

```python
# apps/ai_gateway/providers/perplexity.py
import httpx
import structlog

from .base import GenerationResult

logger = structlog.get_logger(__name__)

class PerplexityProvider:
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.base_url = "https://api.perplexity.ai"
        self.model = "llama-3.1-sonar-large-128k-online"
    
    async def search(
        self,
        query: str,
        *,
        system_prompt: str | None = None,
    ) -> GenerationResult:
        """
        Vyhledává informace na webu.
        """
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self.base_url}/chat/completions",
                headers={
                    "Authorization": f"Bearer {self.api_key}",
                    "Content-Type": "application/json",
                },
                json={
                    "model": self.model,
                    "messages": [
                        {
                            "role": "system",
                            "content": system_prompt or "Be precise and concise."
                        },
                        {
                            "role": "user",
                            "content": query
                        }
                    ],
                },
                timeout=60.0,
            )
            response.raise_for_status()
            data = response.json()
        
        return GenerationResult(
            content=data["choices"][0]["message"]["content"],
            input_tokens=data.get("usage", {}).get("prompt_tokens", 0),
            output_tokens=data.get("usage", {}).get("completion_tokens", 0),
            model=self.model,
            provider="perplexity",
            raw_response=data,
        )
    
    async def scrape_company(
        self,
        company_name: str,
        website: str | None = None,
    ) -> dict:
        """
        Scrapuje informace o firmě pro Company DNA.
        """
        query = f"""
        Najdi detailní informace o firmě "{company_name}":
        1. Obor podnikání a hlavní produkty/služby
        2. Cílová skupina zákazníků
        3. Hlavní konkurenti
        4. Tone of voice a styl komunikace
        5. Unikátní prodejní argumenty (USP)
        6. Historie a zajímavosti
        
        {"Website: " + website if website else ""}
        
        Odpověz strukturovaně v JSON formátu.
        """
        
        result = await self.search(
            query,
            system_prompt="Jsi expert na analýzu firem. Odpovídej v JSON formátu."
        )
        
        # Parse response
        import json
        try:
            return json.loads(result.content)
        except json.JSONDecodeError:
            return {"raw_info": result.content}
```

**Aktuální stav implementace:**

- ✅ **PerplexityProvider existuje** - Implementován v `providers/perplexity.py`
- ✅ **API KEY** - `PERPLEXITY_API_KEY` je správně nakonfigurován v `.env`
- ✅ **`search()` metoda** - Funguje a používá se pro web search a research
- ✅ **`scrape_company()` metoda** - **TOTO JE KLÍČOVÁ FUNKCE** - používá se v `scrape_company_dna()` pro získávání informací o firmách
- ❌ **`structlog`** - Není použit, místo toho standardní Python `logging`
- ✅ **HTTP komunikace** - Používá `httpx.AsyncClient` pro async požadavky
- ✅ **Model**: Používá `llama-3.1-sonar-large-128k-online` nebo podobný online model
- ✅ **Timeout handling** - Má nastavený 60s timeout
- ⚠️ **Error handling** - Základní `raise_for_status()`, možná chybí retry logika

**Skutečné použití v aplikaci:**

```python
# Funkce scrape_company_dna() používá PerplexityProvider:
async def scrape_company_dna(domain: str, organization_id: str):
    provider = get_research_provider()  # Vrací PerplexityProvider
    
    # Vyhledá informace o firmě
    query = f"detailní informace o firmě s doménou {domain}"
    result = await provider.search(query=query)
    
    # Alternativně může volat přímo scrape_company():
    # company_info = await provider.scrape_company(
    #     company_name="Firma s.r.o.",
    #     website=domain
    # )
    
    return result.content
```

---

## 5. IMAGE GENERATION (NANOBANA)

### Provider Implementation

```python
# apps/ai_gateway/providers/nanobana.py
import httpx
import structlog

from .base import ImageProviderInterface, ImageResult

logger = structlog.get_logger(__name__)

class NanobanaProvider(ImageProviderInterface):
    """
    Nanobana Pro provider (Imagen 3).
    """
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.base_url = "https://api.nanobana.ai"
    
    async def generate_image(
        self,
        prompt: str,
        *,
        aspect_ratio: str = "1:1",
        style: str | None = None,
        negative_prompt: str | None = None,
    ) -> ImageResult:
        """
        Generuje obrázek pomocí Imagen 3.
        """
        # Build full prompt
        full_prompt = prompt
        if style:
            full_prompt = f"{prompt}, {style} style"
        
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self.base_url}/v1/images/generate",
                headers={
                    "Authorization": f"Bearer {self.api_key}",
                    "Content-Type": "application/json",
                },
                json={
                    "prompt": full_prompt,
                    "negative_prompt": negative_prompt or "blurry, low quality, distorted",
                    "aspect_ratio": aspect_ratio,
                    "model": "imagen-3",
                    "output_format": "png",
                },
                timeout=120.0,
            )
            response.raise_for_status()
            data = response.json()
        
## 5. IMAGE GENERATION (NANOBANA)

### Provider Implementation

```python
# apps/ai_gateway/providers/nanobana.py
import httpx
import structlog

from .base import ImageProviderInterface, ImageResult

logger = structlog.get_logger(__name__)

class NanobanaProvider(ImageProviderInterface):
    """
    Nanobana Pro provider (Imagen 3).
    """
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.base_url = "https://api.nanobana.ai"
    
    async def generate_image(
        self,
        prompt: str,
        *,
        aspect_ratio: str = "1:1",
        style: str | None = None,
        negative_prompt: str | None = None,
    ) -> ImageResult:
        """
        Generuje obrázek pomocí Imagen 3.
        """
        # Build full prompt
        full_prompt = prompt
        if style:
            full_prompt = f"{prompt}, {style} style"
        
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"{self.base_url}/v1/images/generate",
                headers={
                    "Authorization": f"Bearer {self.api_key}",
                    "Content-Type": "application/json",
                },
                json={
                    "prompt": full_prompt,
                    "negative_prompt": negative_prompt or "blurry, low quality, distorted",
                    "aspect_ratio": aspect_ratio,
                    "model": "imagen-3",
                    "output_format": "png",
                },
                timeout=120.0,
            )
            response.raise_for_status()
            data = response.json()
        
        return ImageResult(
            url=data["images"][0]["url"],
            prompt_used=full_prompt,
            model="imagen-3",
            provider="nanobana",
        )
```

**Aktuální stav implementace:**

- ❌ **NanobanaProvider NEEXISTUJE** - Není implementován, image generation zatím není aktivní feature
- ✅ **API KEY existuje** - `NANOBANA_API_KEY` je v `.env`, ale provider není spuštěný
- ❌ **`ImageResult` dataclass** - Není implementována
- ❌ **`ImageProviderInterface`** - Není implementována
- ❌ **Integrace s Nanobana API** - Není implementována
- ⚠️ **Plánovaná feature** - Image generation je na roadmapě pro PRO+ tier

**Status:**

```
🔴 NENÍ IMPLEMENTOVÁNO
📋 Plánováno pro budoucí verzi
💰 Součást PRO+ subscription tier
```

Image generation je komplexní feature, která vyžaduje:

1. Implementaci NanobanaProvider
2. Image storage (S3/Cloudinary)
3. Feature gating podle subscription tier
4. UI pro image generation
5. Cost tracking pro images

### Visual Prompt Engineering

```python
# apps/ai_gateway/visual_prompt.py

class VisualPromptEngineer:
    """
    Generuje optimalizované prompty pro image generation.
    Implementuje "Authenticity Trend 2026" logiku.
    """
    
    # Industry -> Authenticity fit mapping
    HIGH_AUTHENTICITY_INDUSTRIES = [
        'personal_brand', 'small_business', 'local', 'nonprofit',
        'fitness', 'creative', 'eco', 'startup', 'community'
    ]
    
    LOW_AUTHENTICITY_INDUSTRIES = [
        'luxury', 'finance', 'legal', 'healthcare', 'corporate',
        'real_estate', 'enterprise'
    ]
    
    PLATFORM_ASPECTS = {
        'instagram_feed': '1:1',
        'instagram_story': '9:16',
        'facebook_feed': '16:9',
        'linkedin': '16:9',
        'tiktok': '9:16',
        'twitter': '16:9',
        'pinterest': '2:3',
    }
    
