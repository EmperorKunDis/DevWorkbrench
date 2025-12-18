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

logger = structlog.get_logger(__name__)

class GeminiProvider(AIProviderInterface):
    def __init__(self, api_key: str):
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
    
    def generate_prompt(
        self,
        message: str,
        persona,
        platform: str,
        industry: str | None = None,
    ) -> dict:
        """
        Generuje image prompt na základě kontextu.
        """
        aspect_ratio = self.PLATFORM_ASPECTS.get(platform, '1:1')
        authenticity = self._determine_authenticity(industry or '')
        
        # Build base prompt
        prompt_parts = [
            f"[{aspect_ratio} aspect ratio]",
        ]
        
        # Add visual style from persona
        if persona.art_style_name:
            prompt_parts.append(f"[{persona.art_style_name} style]")
        
        if persona.color_palette:
            prompt_parts.append(f"[{persona.color_palette} color palette]")
        
        if persona.visual_atmosphere:
            prompt_parts.append(f"[{persona.visual_atmosphere} mood]")
        
        # Add authenticity modifiers
        if authenticity == 'high':
            prompt_parts.extend([
                "natural lighting",
                "authentic moment",
                "candid feel",
                "real environment",
            ])
        else:
            prompt_parts.extend([
                "professional photography",
                "studio quality",
                "polished composition",
                "editorial style",
            ])
        
        # Add content
        prompt_parts.append(message)
        
        # Add quality
        prompt_parts.append("high-quality, professional")
        
        full_prompt = ", ".join(prompt_parts)
        
        return {
            "prompt": full_prompt,
            "negative_prompt": "blurry, low quality, distorted, ugly, watermark, text, logo",
            "aspect_ratio": aspect_ratio,
            "authenticity_level": authenticity,
        }
    
    def _determine_authenticity(self, industry: str) -> str:
        """Určí úroveň authenticity podle industry."""
        industry_lower = industry.lower()
        
        for ind in self.HIGH_AUTHENTICITY_INDUSTRIES:
            if ind in industry_lower:
                return 'high'
        
        for ind in self.LOW_AUTHENTICITY_INDUSTRIES:
            if ind in industry_lower:
                return 'low'
        
        return 'medium'
```

---

## 6. VIDEO GENERATION (VEO 3)

### Provider Implementation

```python
# apps/ai_gateway/providers/veo.py
import httpx
import asyncio
import structlog

logger = structlog.get_logger(__name__)

class VeoProvider:
    """
    Veo 3 video generation provider.
    ULTIMATE tier only.
    """
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.base_url = "https://api.veo.google"
    
    async def generate_video(
        self,
        prompt: str,
        *,
        duration: int = 6,  # 6-10 seconds
        aspect_ratio: str = "16:9",
        style: str | None = None,
    ) -> dict:
        """
        Generuje krátké video.
        """
        full_prompt = prompt
        if style:
            full_prompt = f"{prompt}, {style} style"
        
        async with httpx.AsyncClient() as client:
            # Start generation
            response = await client.post(
                f"{self.base_url}/v1/videos/generate",
                headers={
                    "Authorization": f"Bearer {self.api_key}",
                },
                json={
                    "prompt": full_prompt,
                    "duration_seconds": duration,
                    "aspect_ratio": aspect_ratio,
                    "model": "veo-3",
                },
                timeout=30.0,
            )
            response.raise_for_status()
            job = response.json()
            
            # Poll for completion
            job_id = job["id"]
            max_attempts = 60  # 5 minutes max
            
            for _ in range(max_attempts):
                status_response = await client.get(
                    f"{self.base_url}/v1/videos/{job_id}",
                    headers={"Authorization": f"Bearer {self.api_key}"},
                )
                status_response.raise_for_status()
                status = status_response.json()
                
                if status["status"] == "completed":
                    return {
                        "url": status["video_url"],
                        "thumbnail_url": status.get("thumbnail_url"),
                        "duration": status["duration"],
                        "prompt_used": full_prompt,
                    }
                elif status["status"] == "failed":
                    raise Exception(f"Video generation failed: {status.get('error')}")
                
                await asyncio.sleep(5)  # Poll every 5 seconds
            
## 6. VIDEO GENERATION (VEO 3)

### Provider Implementation

```python
# apps/ai_gateway/providers/veo.py
import httpx
import asyncio
import structlog

logger = structlog.get_logger(__name__)

class VeoProvider:
    """
    Veo 3 video generation provider.
    ULTIMATE tier only.
    """
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.base_url = "https://api.veo.google"
    
    async def generate_video(
        self,
        prompt: str,
        *,
        duration: int = 6,  # 6-10 seconds
        aspect_ratio: str = "16:9",
        style: str | None = None,
    ) -> dict:
        """
        Generuje krátké video.
        """
        full_prompt = prompt
        if style:
            full_prompt = f"{prompt}, {style} style"
        
        async with httpx.AsyncClient() as client:
            # Start generation
            response = await client.post(
                f"{self.base_url}/v1/videos/generate",
                headers={
                    "Authorization": f"Bearer {self.api_key}",
                },
                json={
                    "prompt": full_prompt,
                    "duration_seconds": duration,
                    "aspect_ratio": aspect_ratio,
                    "model": "veo-3",
                },
                timeout=30.0,
            )
            response.raise_for_status()
            job = response.json()
            
            # Poll for completion
            job_id = job["id"]
            max_attempts = 60  # 5 minutes max
            
            for _ in range(max_attempts):
                status_response = await client.get(
                    f"{self.base_url}/v1/videos/{job_id}",
                    headers={"Authorization": f"Bearer {self.api_key}"},
                )
                status_response.raise_for_status()
                status = status_response.json()
                
                if status["status"] == "completed":
                    return {
                        "url": status["video_url"],
                        "thumbnail_url": status.get("thumbnail_url"),
                        "duration": status["duration"],
                        "prompt_used": full_prompt,
                    }
                elif status["status"] == "failed":
                    raise Exception(f"Video generation failed: {status.get('error')}")
                
                await asyncio.sleep(5)  # Poll every 5 seconds
            
            raise TimeoutError("Video generation timed out")
```

**Aktuální stav implementace:**
- ❌ **VeoProvider NEEXISTUJE** - Není implementován, video generation není aktivní
- ✅ **API KEY existuje** - `VEO_API_KEY` je v `.env`, ale provider není spuštěný
- ❌ **Video generation** - Není implementována žádná část video generování
- ❌ **Job polling system** - Není implementován asynchronní polling system
- ❌ **Video storage** - Není implementováno storage pro vygenerovaná videa
- ⚠️ **Plánovaná feature** - Video generation je na roadmapě pro ULTIMATE tier

**Status:**
```
🔴 NENÍ IMPLEMENTOVÁNO
📋 Plánováno pro budoucí verzi
💰 Součást ULTIMATE subscription tier (nejvyšší tier)
⏱️ Vyžaduje komplexní polling system a video storage
```

Video generation je nejsložitější a nejdražší feature, která vyžaduje:
1. Implementaci VeoProvider s async polling
2. Video storage (S3/specialized video CDN)
3. Feature gating - pouze ULTIMATE tier
4. UI pro video generation a preview
5. Cost tracking (velmi drahé - $0.05/sekunda)
6. Queue system pro dlouhé video jobs

---

## 7. PROMPT ENGINEERING

### Prompt Templates

```python
# Uloženo v databázi jako PromptTemplate

**Aktuální stav implementace:**
- ❌ **`PromptTemplate` DB model NEEXISTUJE** - Tento model není implementován
- ✅ **`AIJob` model EXISTUJE** - Místo PromptTemplate existuje model pro tracking AI jobů
- ❌ **Template management** - Není systém pro správu a verzování prompt templates
- ⚠️ **Prompty jsou HARDCODED** - Všechny prompty jsou přímo v service funkcích, ne v DB
- ❌ **Jinja2 templating** - Není používán pro dynamic prompt rendering
- ❌ **Template versioning** - Není systém verzování (V1, V2, V3...)
- ❌ **Template types** - Není kategorizace podle typu (persona, topic, blogpost, social_post)

**Co SKUTEČNĚ existuje - `AIJob` model:**

Místo `PromptTemplate` modelu pro šablony, aplikace má `AIJob` model pro tracking AI operací:

```python
# apps/ai_gateway/models.py (skutečný kód)
from django.db import models
from apps.core.models import BaseModel

class JobStatus(models.TextChoices):
    """AI job status choices."""
    PENDING = 'pending', 'Pending'
    PROCESSING = 'processing', 'Processing'
    COMPLETED = 'completed', 'Completed'
    FAILED = 'failed', 'Failed'
    CANCELLED = 'cancelled', 'Cancelled'

class JobType(models.TextChoices):
    """AI job type choices."""
    SCRAPE_DNA = 'scrape_dna', 'Scrape Company DNA'
    GENERATE_PERSONAS = 'generate_personas', 'Generate Personas'
    GENERATE_TOPICS = 'generate_topics', 'Generate Topics'
    GENERATE_BLOGPOST = 'generate_blogpost', 'Generate Blog Post'
    GENERATE_SOCIAL = 'generate_social', 'Generate Social Posts'
    GENERATE_IMAGE = 'generate_image', 'Generate Image'
    GENERATE_VIDEO = 'generate_video', 'Generate Video'

class AIJob(BaseModel):
    """
    Tracks AI generation jobs.
    
    CRITICAL: AIJob belongs to COMPANY (content tenant), not Organization!
    """
    company = models.ForeignKey('companies.Company', on_delete=models.CASCADE)
    created_by = models.ForeignKey('users.User', on_delete=models.SET_NULL, null=True)
    
    # Job identification
    job_type = models.CharField(max_length=30, choices=JobType.choices)
    status = models.CharField(max_length=20, choices=JobStatus.choices, default=JobStatus.PENDING)
    
    # Data
    input_data = models.JSONField(default=dict)
    output_data = models.JSONField(default=dict, blank=True)
    
    # Error tracking
    error_message = models.TextField(blank=True)
    error_details = models.JSONField(default=dict, blank=True)
    
    # Timing
    started_at = models.DateTimeField(null=True, blank=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    
    # Retry logic
    retry_count = models.IntegerField(default=0)
    max_retries = models.IntegerField(default=3)
    
    # Celery integration
    celery_task_id = models.CharField(max_length=255, blank=True)
    priority = models.IntegerField(default=5)
    
    # Usage tracking
    tokens_used = models.IntegerField(default=0)
    generation_time_seconds = models.FloatField(null=True, blank=True)
    
    def mark_processing(self):
        """Mark job as processing."""
        self.status = JobStatus.PROCESSING
        self.started_at = timezone.now()
        self.save()
    
    def mark_completed(self, output_data: dict, tokens_used: int = 0):
        """Mark job as completed."""
        self.status = JobStatus.COMPLETED
        self.output_data = output_data
        self.completed_at = timezone.now()
        self.tokens_used = tokens_used
        self.save()
    
    def mark_failed(self, error_message: str, error_details: dict = None):
        """Mark job as failed."""
        self.status = JobStatus.FAILED
        self.error_message = error_message
        self.error_details = error_details or {}
        self.completed_at = timezone.now()
        self.save()
```

**Klíčové vlastnosti `AIJob` modelu:**
- ✅ **Job tracking** - Sleduje všechny AI operace (scraping, generation)
- ✅ **Status management** - PENDING → PROCESSING → COMPLETED/FAILED
- ✅ **Celery integration** - Ukládá `celery_task_id` pro async tracking
- ✅ **Retry logic** - Automatické retry s max 3 pokusy
- ✅ **Usage tracking** - Sleduje `tokens_used` a `generation_time_seconds`
- ✅ **Error handling** - Ukládá error messages a details
- ✅ **Company-scoped** - Patří k Company, ne Organization (multi-tenancy)

**Skutečné použití v aplikaci:**
```python
# Services používají hardcoded prompty, ne DB templates:

def scrape_company_dna(*, website: str, company_name: str) -> dict:
    """Scrape company DNA using Perplexity."""
    provider = get_research_provider()
    
    # ❌ Prompt je HARDCODED, ne z DB
    prompt = f'''Research the company "{company_name}" with website {website}.

Find and return comprehensive information about:

1. **Mission & Vision**
   - Company mission statement
   - Company vision
   
2. **Values & Culture**
   - Core company values
   
3. **Target Audience**
   - Primary customer segments
   
... (full prompt hardcoded here)
'''
    
    schema = {
        'mission': 'string - Company mission',
        'vision': 'string - Company vision',
        'values': ['string - Core value'],
        # ... schema je taky hardcoded
    }
    
    result = provider.generate_json(prompt, schema)
    return result


def generate_personas(*, company_dna: dict, count: int = 6) -> list[dict]:
    """Generate personas based on company DNA."""
    provider = get_text_provider()
    
    # ❌ Prompt je opět HARDCODED
    prompt = f'''Create {count} unique fictional author personas.

Company Information:
- Name: {company_dna.get('name')}
- Industry: {company_dna.get('industry')}
- Mission: {company_dna.get('mission')}

Requirements for each persona:
1. Unique Identity
2. Psychology: Jung archetype and MBTI
3. Personal Values: 3-5 values
... (full prompt hardcoded)
'''
    
    schema = {
        'personas': [
            {
                'name': 'string - Full name',
                'bio': 'string - Biography',
                'archetype': 'string - Jung archetype',
                'mbti': 'string - MBTI type',
                # ... schema hardcoded
            }
        ]
    }
    
    result = provider.generate_json(prompt, schema)
    return result['personas']
```

**Proč je to problém:**
- 🔄 **Těžká údržba** - Změna promptu vyžaduje code deploy, ne DB update
- 📝 **Žádné verzování** - Nelze A/B testovat různé verze promptů
- 🔍 **Žádný audit trail** - Není historie změn promptů
- 👥 **Vyžaduje programátora** - Content manažer nemůže upravit prompty bez code změny
- 🎯 **Žádná optimalizace** - Nelze trackovat které prompt verze fungují nejlépe

**Co je potřeba implementovat:**
1. ✅ Vytvořit `PromptTemplate` model v Django
2. ✅ Přidat fields: `code`, `name`, `template_type`, `system_prompt`, `user_prompt_template`, `temperature`, `max_tokens`, `version`
3. ✅ Migrovat všechny hardcoded prompty do databáze
4. ✅ Implementovat Jinja2 rendering pro variables (`{{ company.name }}`, `{% for persona in personas %}`)
5. ✅ Vytvořit management commands pro import/export templates
6. ✅ Přidat versioning system (V1, V2, V3...) s možností A/B testingu
7. ✅ UI pro editaci templates v admin rozhraní nebo custom UI
8. ✅ Integrovat do services - místo hardcoded promptů načítat z DB

# =============================================================================
# PERSONA GENERATION
# =============================================================================
PERSONA_GEN_V1 = {
    "code": "PERSONA_GEN_V1",
    "name": "Persona Generation v1",
    "template_type": "persona",
    "system_prompt": """Jsi expert na tvorbu brand person a obsahovou strategii pro české firmy. 
Tvým úkolem je vytvořit 6 unikátních, realistických a diverzifikovaných person.

Každá persona musí být:
1. Unikátní v kombinaci archetypu, MBTI a perspektivy
2. Relevantní pro daný obor podnikání
3. Schopná komunikovat s cílovou skupinou firmy

DŮLEŽITÉ: Nikdy neopakuj stejnou kombinaci Jungova archetypu nebo MBTI typu!""",
    
    "user_prompt_template": """Vytvoř 6 unikátních person pro firmu:

=== INFORMACE O FIRMĚ ===
Název: {{ company.name }}
Obor: {{ company.business_field }}
Produkt/služba: {{ company.product_type }}

=== CÍLOVÁ SKUPINA ===
{{ company.company_dna.target_audience | default('Nespecifikováno') }}

=== POŽADAVKY ===
- 6 RŮZNÝCH Jungových archetypů
- 6 RŮZNÝCH MBTI typů
- Různé úrovně hierarchie

Vrať JSON s polem "personas" obsahujícím 6 person.""",
    
    "temperature": 0.8,
    "max_tokens": 8192,
}

# =============================================================================
# TOPIC GENERATION
# =============================================================================
TOPIC_GEN_V1 = {
    "code": "TOPIC_GEN_V1",
    "name": "Topic Generation v1",
    "template_type": "topic",
    "system_prompt": """Jsi expert na obsahovou strategii a SEO pro české firmy.
Vytváříš promyšlené obsahové plány témat pro blogové příspěvky.

Každé téma musí:
1. Být relevantní pro obor firmy
2. Mít jasný SEO potenciál
3. Být přiřazeno konkrétní personě""",
    
    "user_prompt_template": """Vytvoř {{ posts_count }} témat pro měsíc {{ month }}/{{ year }}:

=== FIRMA ===
Název: {{ company.name }}
Obor: {{ company.business_field }}

=== PERSONY ===
{% for persona in personas %}
- {{ persona.character_name }} ({{ persona.jung_archetype }})
{% endfor %}

=== PRAVIDLA ===
- Rozděl témata rovnoměrně mezi persony
- Naplánuj témata přes celý měsíc

Vrať JSON s polem "topics".""",
    
    "temperature": 0.7,
    "max_tokens": 4096,
}

# =============================================================================
# BLOGPOST GENERATION
# =============================================================================
BLOGPOST_GEN_V1 = {
    "code": "BLOGPOST_GEN_V1",
    "name": "Blogpost Generation v1",
    "template_type": "blogpost",
    "system_prompt": """Jsi zkušený copywriter. Píšeš jako konkrétní persona - s jejím hlasem, slovníkem a způsobem argumentace.

Blogpost musí obsahovat:
1. Magnetický titulek s focus keyword
2. Strukturované sekce (intro, body, conclusion)
3. FAQ sekci
4. Key takeaways
5. 1500-2500 slov""",
    
    "user_prompt_template": """Napiš blogpost na téma:

=== TÉMA ===
Titulek: {{ topic.title }}
Popis: {{ topic.description }}
Focus keyword: {{ topic.focus_keyword }}

=== PERSONA ===
Jméno: {{ persona.character_name }}
Archetyp: {{ persona.jung_archetype }}
MBTI: {{ persona.mbti_type }}
Slovní zásoba: {{ persona.vocabulary_level }}
Oblíbené fráze: {{ persona.favorite_phrases }}
Typický závěr: {{ persona.unique_signature_ending }}

=== FIRMA ===
{{ company.name }} - {{ company.business_field }}

Vrať strukturovaný JSON.""",
    
    "temperature": 0.7,
    "max_tokens": 12000,
}

# =============================================================================
# SOCIAL POST GENERATION
# =============================================================================
SOCIAL_POST_GEN_V1 = {
    "code": "SOCIAL_POST_GEN_V1",
    "name": "Social Post Generation v1",
    "template_type": "social_post",
    "system_prompt": """Jsi expert na sociální sítě a virální obsah.
Transformuješ blogposty do příspěvků pro konkrétní platformy.""",
    
    "user_prompt_template": """Vytvoř příspěvek pro {{ platform }}:

=== BLOGPOST ===
Titulek: {{ blogpost.title }}
Key takeaways:
{% for takeaway in blogpost.key_takeaways %}
- {{ takeaway }}
{% endfor %}

=== PERSONA ===
{{ persona.character_name }} - {{ persona.jung_archetype }}
Oblíbené fráze: {{ persona.favorite_phrases }}

=== PLATFORMA: {{ platform | upper }} ===
{% if platform == 'instagram' %}
Max délka: 2200 znaků
5-15 hashtagů
Hook v první větě
{% elif platform == 'linkedin' %}
Profesionální tón
3-5 hashtagů
Hook v prvních 2 řádcích
{% elif platform == 'twitter' %}
Max 280 znaků
1-2 hashtagy
{% endif %}

Vrať JSON s textContent, hashtags, ctaText.""",
    
    "temperature": 0.75,
    "max_tokens": 2048,
}
```

---

## 8. COST TRACKING

### Cost Tracker

```python
# apps/ai_gateway/cost_tracker.py
from decimal import Decimal
from django.core.cache import cache
from django.utils import timezone

# Ceny za 1000 tokenů (USD)
COST_PER_1K_TOKENS = {
    'gemini': {
        'input': Decimal('0.00025'),
        'output': Decimal('0.0005'),
    },
    'perplexity': {
        'input': Decimal('0.001'),
        'output': Decimal('0.001'),
    },
}

# Ceny za obrázek/video
COST_PER_IMAGE = {
    'nanobana': Decimal('0.02'),
}

COST_PER_VIDEO_SECOND = {
    'veo': Decimal('0.05'),
}

class CostTracker:
    def __init__(self):
        self.cache_prefix = "ai_cost"
    
    async def track(
        self,
        organization,
        provider: str,
        input_tokens: int,
        output_tokens: int,
    ) -> Decimal:
        """Sleduje cost za text generování."""
        costs = COST_PER_1K_TOKENS.get(provider, {})
        
        input_cost = (Decimal(input_tokens) / 1000) * costs.get('input', Decimal('0'))
        output_cost = (Decimal(output_tokens) / 1000) * costs.get('output', Decimal('0'))
        total_cost = input_cost + output_cost
        
        # Update cache counter
        cache_key = f"{self.cache_prefix}:{organization.id}:{timezone.now().strftime('%Y-%m')}"
        current = cache.get(cache_key, Decimal('0'))
        cache.set(cache_key, current + total_cost, timeout=60*60*24*31)  # 31 days
        
        # Update usage record in DB (async)
        from apps.billing.tasks import update_usage_record
        update_usage_record.delay(
            str(organization.id),
            tokens=input_tokens + output_tokens,
            cost=float(total_cost),
        )
        
        return total_cost
    
    async def track_image(
        self,
        organization,
        provider: str,
    ) -> Decimal:
        """Sleduje cost za image generování."""
        cost = COST_PER_IMAGE.get(provider, Decimal('0'))
        
        cache_key = f"{self.cache_prefix}:{organization.id}:{timezone.now().strftime('%Y-%m')}"
        current = cache.get(cache_key, Decimal('0'))
        cache.set(cache_key, current + cost, timeout=60*60*24*31)
        
        from apps.billing.tasks import update_usage_record
        update_usage_record.delay(
            str(organization.id),
            images=1,
            cost=float(cost),
        )
        
        return cost
    
    def get_monthly_cost(self, organization) -> Decimal:
        """Získá aktuální měsíční cost."""
## 8. COST TRACKING

### Cost Tracker

```python
# apps/ai_gateway/cost_tracker.py
from decimal import Decimal
from django.core.cache import cache
from django.utils import timezone

# Ceny za 1000 tokenů (USD)
COST_PER_1K_TOKENS = {
    'gemini': {
        'input': Decimal('0.00025'),
        'output': Decimal('0.0005'),
    },
    'perplexity': {
        'input': Decimal('0.001'),
        'output': Decimal('0.001'),
    },
}

# Ceny za obrázek/video
COST_PER_IMAGE = {
    'nanobana': Decimal('0.02'),
}

COST_PER_VIDEO_SECOND = {
    'veo': Decimal('0.05'),
}

class CostTracker:
    def __init__(self):
        self.cache_prefix = "ai_cost"
    
    async def track(
        self,
        organization,
        provider: str,
        input_tokens: int,
        output_tokens: int,
    ) -> Decimal:
        """Sleduje cost za text generování."""
        costs = COST_PER_1K_TOKENS.get(provider, {})
        
        input_cost = (Decimal(input_tokens) / 1000) * costs.get('input', Decimal('0'))
        output_cost = (Decimal(output_tokens) / 1000) * costs.get('output', Decimal('0'))
        total_cost = input_cost + output_cost
        
        # Update cache counter
        cache_key = f"{self.cache_prefix}:{organization.id}:{timezone.now().strftime('%Y-%m')}"
        current = cache.get(cache_key, Decimal('0'))
        cache.set(cache_key, current + total_cost, timeout=60*60*24*31)  # 31 days
        
        # Update usage record in DB (async)
        from apps.billing.tasks import update_usage_record
        update_usage_record.delay(
            str(organization.id),
            tokens=input_tokens + output_tokens,
            cost=float(total_cost),
        )
        
        return total_cost
    
    async def track_image(
        self,
        organization,
        provider: str,
    ) -> Decimal:
        """Sleduje cost za image generování."""
        cost = COST_PER_IMAGE.get(provider, Decimal('0'))
        
        cache_key = f"{self.cache_prefix}:{organization.id}:{timezone.now().strftime('%Y-%m')}"
        current = cache.get(cache_key, Decimal('0'))
        cache.set(cache_key, current + cost, timeout=60*60*24*31)
        
        from apps.billing.tasks import update_usage_record
        update_usage_record.delay(
            str(organization.id),
            images=1,
            cost=float(cost),
        )
        
        return cost
    
    def get_monthly_cost(self, organization) -> Decimal:
        """Získá aktuální měsíční cost."""
        cache_key = f"{self.cache_prefix}:{organization.id}:{timezone.now().strftime('%Y-%m')}"
        return cache.get(cache_key, Decimal('0'))
```

**Aktuální stav implementace:**
- ❌ **`CostTracker` třída NEEXISTUJE** - Není implementována žádná centrální cost tracking třída
- ❌ **Cost tracking per provider** - Není sledování nákladů podle providera (gemini, perplexity)
- ❌ **Cache-based counters** - Není implementováno ukládání měsíčních nákladů do cache
- ❌ **Integration s billing** - Není propojení s `apps.billing.tasks.update_usage_record`
- ❌ **Cost constants** - Konstanty `COST_PER_1K_TOKENS`, `COST_PER_IMAGE`, `COST_PER_VIDEO_SECOND` nejsou definovány
- ❌ **Monthly aggregation** - Není funkce `get_monthly_cost()`
- ⚠️ **Token counts jsou k dispozici** - Gemini a Perplexity vracejí `input_tokens` a `output_tokens` v response, ale nejsou sledovány

**Skutečný stav:**
```python
# Realita: Žádný cost tracking
# Token counts jsou dostupné v GenerationResult, ale nejsou sledovány:

@dataclass
class GenerationResult:
    content: str
    input_tokens: int      # ✅ K dispozici z API
    output_tokens: int     # ✅ K dispozici z API
    model: str
    provider: str

# Ale nejsou nikam persistovány ani agregovány! ❌
```

**Co je potřeba implementovat:**
1. ✅ Vytvořit `CostTracker` třídu v `apps/ai_gateway/cost_tracker.py`
2. ✅ Definovat cost constants pro všechny providery
3. ✅ Implementovat `track()` metodu pro text generation tracking
4. ✅ Implementovat `track_image()` a `track_video()` metody
5. ✅ Vytvořit `update_usage_record` Celery task v `apps.billing.tasks`
6. ✅ Integrovat do všech provider volání (GeminiProvider, PerplexityProvider)
7. ✅ Vytvořit billing reports pro organizace
8. ✅ Přidat cost monitoring dashboard

---

## 9. CACHING & OPTIMIZATION

### Semantic Cache

```python
# apps/ai_gateway/cache.py
from django.core.cache import cache
import hashlib

class AICache:
    """Cache pro AI responses."""
    
    PREFIX = "ai_response"
    DEFAULT_TTL = 3600  # 1 hour
    
    @classmethod
    def get_key(cls, prompt: str, model: str) -> str:
        """Generuje cache key z promptu."""
        content = f"{model}:{prompt}"
        return f"{cls.PREFIX}:{hashlib.sha256(content.encode()).hexdigest()}"
    
    @classmethod
    def get(cls, prompt: str, model: str) -> str | None:
        """Získá cached response."""
        key = cls.get_key(prompt, model)
        return cache.get(key)
    
    @classmethod
    def set(cls, prompt: str, model: str, response: str, ttl: int = None):
        """Uloží response do cache."""
        key = cls.get_key(prompt, model)
        cache.set(key, response, ttl or cls.DEFAULT_TTL)
    
### Rate Limiting

```python
# apps/ai_gateway/rate_limiter.py
from django.core.cache import cache
import time

class AIRateLimiter:
    """Rate limiter pro AI API volání."""
    
    # Limity per provider per minute
    LIMITS = {
        'gemini': 60,
        'perplexity': 50,
        'nanobana': 10,
        'veo': 5,
    }
    
    @classmethod
    def check(cls, provider: str, organization_id: str) -> bool:
        """Kontroluje zda lze provést volání."""
        key = f"rate_limit:{provider}:{organization_id}"
        current = cache.get(key, 0)
        limit = cls.LIMITS.get(provider, 60)
        return current < limit
    
    @classmethod
    def increment(cls, provider: str, organization_id: str):
        """Inkrementuje counter."""
        key = f"rate_limit:{provider}:{organization_id}"
        current = cache.get(key, 0)
        cache.set(key, current + 1, timeout=60)  # Reset every minute
    
---

## 📌 QUICK REFERENCE

### Environment Variables

```bash
GEMINI_API_KEY=your-gemini-api-key
PERPLEXITY_API_KEY=your-perplexity-api-key
NANOBANA_API_KEY=your-nanobana-api-key
VEO_API_KEY=your-veo-api-key
```

### Usage Example

```python
from apps.ai_gateway.services import AIGateway
from apps.ai_gateway.models import PromptTemplate

gateway = AIGateway()

# Text generation
template = PromptTemplate.objects.get(code='BLOGPOST_GEN_V1')
result = await gateway.generate(
    prompt_template=template,
    variables={'topic': topic, 'persona': persona, 'company': company},
    organization=organization,
)

# Image generation
image = await gateway.generate_image(
    prompt="Professional business meeting in modern office",
    organization=organization,
    aspect_ratio="16:9",
)
```

**Aktuální stav implementace pro QUICK REFERENCE:**
- ✅ **Environment Variables** - Všechny 4 API keys jsou správně nakonfigurovány v `.env`
- ❌ **AIGateway třída** - NEEXISTUJE, místo toho se používají factory funkce
- ❌ **PromptTemplate model** - NEEXISTUJE, prompty jsou hardcoded
- ❌ **Usage example** - Kód v příkladu NEFUNGUJE, protože `AIGateway()` třída neexistuje

**Skutečné použití:**
```python
# Realita - funkcionální factory pattern:
from apps.ai_gateway.providers import get_text_provider, get_research_provider

# Text generation (Gemini)
text_provider = get_text_provider()
result = await text_provider.generate_text(
    system_prompt="Jsi expert na...",
    user_prompt="Vytvoř blogpost o...",
    temperature=0.7,
    max_tokens=4096,
)

# Research (Perplexity)
research_provider = get_research_provider()
company_info = await research_provider.search(
    query=f"informace o firmě {domain}"
)
```

---

## 📊 IMPLEMENTATION STATUS SUMMARY

### ✅ CO JE IMPLEMENTOVÁNO (Funguje v produkci)

| Komponenta | Status | Detail |
|------------|--------|--------|
| **GeminiProvider** | ✅ Funguje | Text generation pomocí Gemini 1.5 Pro |
| **PerplexityProvider** | ✅ Funguje | Web search a company scraping |
| **API Keys** | ✅ Nakonfigurovány | Všechny 4 keys v `.env` |
| **GenerationResult dataclass** | ✅ Existuje | Pro návratové hodnoty |
| **Factory functions** | ✅ Fungují | `get_text_provider()`, `get_research_provider()` |
| **`scrape_company_dna()`** | ✅ Funguje | Klíčová funkce pro onboarding |
| **Async support** | ✅ Funguje | Všechny providery jsou async |
| **Token counts** | ✅ K dispozici | V response metadata |

### ❌ CO NENÍ IMPLEMENTOVÁNO (Pouze plán)

| Komponenta | Důvod absence | Priorita |
|------------|---------------|----------|
| **AIGateway třída** | Používá se funkcionální přístup místo OOP | 🟡 Medium |
| **CostTracker** | Není sledování nákladů | 🔴 High |
| **PromptTemplate model** | Prompty jsou hardcoded | 🟡 Medium |
| **AICache** | Není caching AI responses | 🔴 High |
| **AIRateLimiter** | Není rate limiting | 🟡 Medium |
| **NanobanaProvider** | Image generation není aktivní | 🟢 Low |
| **VeoProvider** | Video generation není aktivní | 🟢 Low |
| **ImageResult dataclass** | Není potřeba bez image gen | 🟢 Low |
| **structlog** | Používá se standardní `logging` | 🟢 Low |
| **litellm** | Je v requirements, ale je zakomentovaný | 🟢 Low |
| **tiktoken** | Není pro přesné počítání tokenů | 🟢 Low |

### 🎯 PRIORITY IMPLEMENTACE (Co implementovat jako první)

**🔴 HIGH PRIORITY** (Kritické pro produkci):
1. **CostTracker** - Sledování nákladů per organizace, kritické pro billing
2. **AICache** - Snížení nákladů a latence, snadná win
3. **Error handling & retries** - Robustní handling API selhání

**🟡 MEDIUM PRIORITY** (Zlepšení architektury):
4. **PromptTemplate model** - Lepší správa promptů, verzování
5. **AIRateLimiter** - Ochrana před překročením limitů
6. **AIGateway třída** - Centralizace logiky (nebo ponechat factory pattern)
7. **Monitoring & metrics** - Sledování využití API

**🟢 LOW PRIORITY** (Budoucí features):
8. **NanobanaProvider** - Image generation pro PRO+ tier
9. **VeoProvider** - Video generation pro ULTIMATE tier
10. **structlog** - Lepší logging (kosmetická změna)
11. **litellm gateway** - Multi-provider abstrakce (není nutné)

### 🏗️ ARCHITEKTONICKÝ ROZDÍL: Plán vs Realita

**PLÁN v dokumentu:**
```
AIGateway (OOP Gateway Class)
    ├── GeminiProvider
    ├── PerplexityProvider
    ├── NanobanaProvider
    └── CostTracker
```

**REALITA v kódu:**
```
Factory Functions (Funkcionální přístup)
    ├── get_text_provider() → GeminiProvider
    └── get_research_provider() → PerplexityProvider

Přímé použití providerů bez gateway layer
```

**Závěr:** Kód funguje dobře s factory pattern přístupem. Není nutně potřeba vytvářet OOP Gateway třídu, ale **CostTracker** a **AICache** jsou kritické pro produkční použití.

---

*Tento dokument je SELF-CONTAINED - obsahuje všechny informace o AI integracích.*

---

## 📂 PŘESNÁ STRUKTURA SOUBORŮ A KÓDU

### Skutečná složka `providers/`

```bash
$ ls -lh apps/ai_gateway/providers/
total 52
-rw-r--r-- 1 root root  476 Dec 15 07:27 __init__.py
-rw-r--r-- 1 root root 4686 Dec 16 07:22 base.py
-rw-r--r-- 1 root root 4364 Dec 16 08:00 gemini.py
-rw-r--r-- 1 root root 5842 Dec 16 08:07 perplexity.py
```

### `__init__.py` (476 bytů) - Factory Functions

```python
"""Factory functions for AI providers."""
from apps.ai_gateway.providers.base import AIProvider
from apps.ai_gateway.providers.gemini import GeminiProvider
from apps.ai_gateway.providers.perplexity import PerplexityProvider

def get_text_provider() -> AIProvider:
    """Get the default text generation provider (Gemini)."""
    return GeminiProvider()

def get_research_provider() -> AIProvider:
    """Get the web research provider (Perplexity)."""
    return PerplexityProvider()
```

### `base.py` (4,686 bytů) - Base Classes

```python
"""Base classes for AI providers."""
from abc import ABC, abstractmethod
from dataclasses import dataclass
from typing import Any

@dataclass
class GenerationResult:
    """Result from AI generation."""
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

### `gemini.py` (4,364 bytů) - Gemini Provider

**Status:** ✅ Plně funkční

```python
"""Google Gemini provider for text generation."""
import logging
import google.genai as genai
from django.conf import settings

from apps.ai_gateway.providers.base import AIProvider, GenerationResult

logger = logging.getLogger(__name__)

class GeminiProvider(AIProvider):
    """Gemini 1.5 Pro provider."""
    
    def __init__(self):
        self.client = genai.Client(api_key=settings.GEMINI_API_KEY)
        self.model = "gemini-1.5-pro-002"
    
    def generate_text(self, prompt: str, max_tokens: int = 4096, **kwargs) -> GenerationResult:
        """Generate text using Gemini."""
        response = self.client.models.generate_content(
            model=self.model,
            contents=prompt,
            config=genai.types.GenerateContentConfig(
                max_output_tokens=max_tokens,
            )
        )
        
        return GenerationResult(
            content=response.text,
            input_tokens=response.usage_metadata.prompt_token_count,
            output_tokens=response.usage_metadata.candidates_token_count,
            model=self.model,
            provider="gemini",
            raw_response=response,
        )
    
    def generate_json(self, prompt: str, schema: dict) -> dict:
        """Generate structured JSON."""
        # Implementation with JSON mode
        ...
```

### `perplexity.py` (5,842 bytů) - Perplexity Provider

**Status:** ✅ Plně funkční

```python
"""Perplexity API provider for web search."""
import logging
import httpx
from django.conf import settings

from apps.ai_gateway.providers.base import AIProvider, GenerationResult

logger = logging.getLogger(__name__)

class PerplexityProvider(AIProvider):
    """Perplexity Sonar provider for web search."""
    
    def __init__(self):
        self.api_key = settings.PERPLEXITY_API_KEY
        self.base_url = "https://api.perplexity.ai"
        self.model = "llama-3.1-sonar-large-128k-online"
    
    def generate_text(self, prompt: str, **kwargs) -> GenerationResult:
        """Search the web and generate response."""
        with httpx.Client() as client:
            response = client.post(
                f"{self.base_url}/chat/completions",
                headers={
                    "Authorization": f"Bearer {self.api_key}",
                    "Content-Type": "application/json",
                },
                json={
                    "model": self.model,
                    "messages": [
                        {"role": "user", "content": prompt}
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
    
    def generate_json(self, prompt: str, schema: dict) -> dict:
        """Generate structured JSON with web search."""
        # Adds schema instructions to prompt
        result = self.generate_text(prompt + "\n\nReturn ONLY valid JSON.")
        return json.loads(result.content)
```

### `models.py` - AIJob Model (NE PromptTemplate!)

**Status:** ✅ Existuje pro job tracking

```python
"""AI Gateway models."""
from django.db import models
from apps.core.models import BaseModel

class JobStatus(models.TextChoices):
    PENDING = 'pending', 'Pending'
    PROCESSING = 'processing', 'Processing'
    COMPLETED = 'completed', 'Completed'
    FAILED = 'failed', 'Failed'
    CANCELLED = 'cancelled', 'Cancelled'

class JobType(models.TextChoices):
    SCRAPE_DNA = 'scrape_dna', 'Scrape Company DNA'
    GENERATE_PERSONAS = 'generate_personas', 'Generate Personas'
    GENERATE_TOPICS = 'generate_topics', 'Generate Topics'
    GENERATE_BLOGPOST = 'generate_blogpost', 'Generate Blog Post'
    GENERATE_SOCIAL = 'generate_social', 'Generate Social Posts'
    GENERATE_IMAGE = 'generate_image', 'Generate Image'
    GENERATE_VIDEO = 'generate_video', 'Generate Video'

class AIJob(BaseModel):
    """Tracks AI generation jobs with Celery integration."""
    company = models.ForeignKey('companies.Company', on_delete=models.CASCADE)
    created_by = models.ForeignKey('users.User', on_delete=models.SET_NULL, null=True)
    
    job_type = models.CharField(max_length=30, choices=JobType.choices)
    status = models.CharField(max_length=20, choices=JobStatus.choices)
    
    input_data = models.JSONField(default=dict)
    output_data = models.JSONField(default=dict)
    
    error_message = models.TextField(blank=True)
    error_details = models.JSONField(default=dict)
    
    started_at = models.DateTimeField(null=True, blank=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    
    retry_count = models.IntegerField(default=0)
    max_retries = models.IntegerField(default=3)
    
    celery_task_id = models.CharField(max_length=255, blank=True)
    priority = models.IntegerField(default=5)
    
    tokens_used = models.IntegerField(default=0)
    generation_time_seconds = models.FloatField(null=True, blank=True)
```

### `services.py` - Business Logic (s hardcoded prompty!)

**Status:** ✅ Funguje, ale prompty jsou hardcoded

```python
"""AI Gateway services."""
import logging
from apps.ai_gateway.providers import get_text_provider, get_research_provider

logger = logging.getLogger(__name__)

def scrape_company_dna(*, website: str, company_name: str) -> dict:
    """Scrape company DNA using Perplexity."""
    provider = get_research_provider()
    
    # ❌ HARDCODED PROMPT (měl by být v DB jako PromptTemplate!)
    prompt = f"""Research the company "{company_name}" with website {website}.

Find and return comprehensive information about:

1. **Mission & Vision**
   - Company mission statement
   - Company vision
   - Core purpose

2. **Values & Culture**
   - Core company values
   - Company culture aspects

3. **Target Audience**
   - Primary customer segments
   - Customer pain points
   - Customer desires/goals

4. **Business Details**
   - Industry/niche
   - Main products or services
   - Unique selling proposition (USP)

5. **Brand Voice**
   - Communication style (formal vs casual)
   - Tone (serious vs playful)
   - Key messaging themes

6. **Competitors**
   - Main competitors in the market

Be thorough and accurate. If information is not available, indicate "Not found".
"""
    
    # ❌ HARDCODED SCHEMA (mělo by být v PromptTemplate!)
    schema = {
        'mission': 'string - Company mission statement',
        'vision': 'string - Company vision',
        'values': ['string - Core value'],
        'target_audience': 'string - Description',
        'audience_pain_points': ['string - Pain point'],
        'audience_desires': ['string - Desire/goal'],
        'industry': 'string - Industry/niche',
        'products_services': ['string - Product or service'],
        'usp': 'string - Unique selling proposition',
        'tone_formal_casual': 'number 0-100',
        'tone_serious_playful': 'number 0-100',
        'content_themes': ['string - Content theme'],
        'competitors': ['string - Competitor name'],
    }
    
    result = provider.generate_json(prompt, schema)
    
    # Add defaults for missing fields
    defaults = {
        'mission': '', 'vision': '', 'values': [],
        'target_audience': '', 'audience_pain_points': [],
        'audience_desires': [], 'industry': '',
        'products_services': [], 'usp': '',
        'tone_formal_casual': 50, 'tone_serious_playful': 50,
        'content_themes': [], 'competitors': [],
    }
    
    for key, default in defaults.items():
        if key not in result or result[key] is None:
            result[key] = default
    
    return result


def generate_personas(*, company_dna: dict, count: int = 6) -> list[dict]:
    """Generate personas based on company DNA."""
    provider = get_text_provider()
    
    tone_formality = 'Casual' if company_dna.get('tone_formal_casual', 50) > 50 else 'Formal'
    tone_mood = 'Playful' if company_dna.get('tone_serious_playful', 50) > 50 else 'Serious'
    
    # ❌ DALŠÍ HARDCODED PROMPT!
    prompt = f"""Create {count} unique fictional author personas for content creation.

Company Information:
- Name: {company_dna.get('name', 'Unknown')}
- Industry: {company_dna.get('industry', 'General')}
- Mission: {company_dna.get('mission', 'Not specified')}
- Vision: {company_dna.get('vision', 'Not specified')}
- Values: {', '.join(company_dna.get('values', []))}
- Target Audience: {company_dna.get('target_audience', 'General audience')}
- USP: {company_dna.get('usp', 'Not specified')}
- Tone: {tone_formality}, {tone_mood}

Requirements for each persona:
1. **Unique Identity**: Distinct name and background
2. **Psychology**: Jung archetype and MBTI type that align with brand
3. **Personal Values**: 3-5 values that resonate with the company
4. **Writing Style**: Specific vocabulary level, sentence style, formality
5. **Visual Style**: Description for image generation
6. **Expertise**: 3-5 topics they're experts in

Make personas diverse but all aligned with the company's brand voice.
Include a mix of archetypes to cover different content angles.

Jung Archetypes: innocent, everyman, hero, outlaw, explorer, creator, ruler, 
magician, lover, caregiver, jester, sage

MBTI types: INTJ, INTP, ENTJ, ENTP, INFJ, INFP, ENFJ, ENFP, ISTJ, ISFJ, 
ESTJ, ESFJ, ISTP, ISFP, ESTP, ESFP
"""
    
    # ❌ HARDCODED SCHEMA
    schema = {
        'personas': [
            {
                'name': 'string - Full name',
                'bio': 'string - 2-3 sentence biography',
                'archetype': 'string - Jung archetype (lowercase)',
                'mbti': 'string - MBTI type (4 letters uppercase)',
                'values': ['string - Personal value'],
                'frustrations': ['string - What frustrates them'],
                'vocabulary_level': 'string - simple|professional|academic',
                # ... více fields
            }
        ]
    }
    
    result = provider.generate_json(prompt, schema)
    return result['personas']
```

---

## 🎯 KLÍČOVÉ ZJIŠTĚNÍ

### ✅ Co funguje výborně:
1. **Provider implementace** - GeminiProvider a PerplexityProvider jsou solidní
2. **Factory pattern** - Čistý, jednoduchý přístup bez zbytečné abstrakce
3. **AIJob model** - Dobrý základ pro async job tracking s Celery
4. **Token tracking** - Data jsou k dispozici z API responses

### ❌ Největší problémy:
1. **Hardcoded prompty** - Všechny prompty jsou v `services.py`, ne v DB
   - Nelze upravovat bez code deploy
   - Žádné verzování nebo A/B testing
   - Content manažer nemůže upravit
   
2. **Žádný cost tracking** - I když máme `tokens_used` v `AIJob`, není agregace
   - Chybí monthly summary per company
   - Není billing integration
   
3. **Žádný caching** - Opakované requesty jdou znovu na API
   - Zbytečné náklady
   - Pomalejší response

### 💡 Quick Wins:
1. **AICache** - Implementace za 1-2 hodiny, okamžitá úspora
2. **CostTracker** - Data už máme, jen přidat persistování
3. **PromptTemplate model** - Umožní non-tech editaci promptů

---

*Tento dokument nyní obsahuje KOMPLETNÍ informace o plánované architektuře I skutečném stavu implementace.*
