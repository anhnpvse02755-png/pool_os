# Billiard Knowledge Module (BKM) - AI Integration

## Version 1.0
**Last Updated:** July 2026
**Status:** Production Specification

---

## 1. AI Capability Specifications

### 1.1 AI Feature Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           AI CAPABILITIES MATRIX                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   ┌─────────────────────────────────────────────────────────────────────┐  │
│   │                        CONTENT UNDERSTANDING                          │  │
│   │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐                  │  │
│   │  │  Term       │ │  Comparison  │ │  Context     │                  │  │
│   │  │  Explanation│ │  Generation  │ │  Extraction  │                  │  │
│   │  └──────────────┘ └──────────────┘ └──────────────┘                  │  │
│   └─────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
│   ┌─────────────────────────────────────────────────────────────────────┐  │
│   │                        LEARNING ASSISTANCE                           │  │
│   │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌────────────┐  │  │
│   │  │  Drill       │ │  Learning    │ │  Quiz        │ │  Practice  │  │  │
│   │  │  Suggestions │ │  Path Gen    │ │  Generation  │ │  Sessions  │  │  │
│   │  └──────────────┘ └──────────────┘ └──────────────┘ └────────────┘  │  │
│   └─────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
│   ┌─────────────────────────────────────────────────────────────────────┐  │
│   │                      DISCOVERY & ANALYSIS                             │  │
│   │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐                  │  │
│   │  │  Related     │ │  Concept     │ │  Weakness    │                  │  │
│   │  │  Discovery   │ │  Linking     │ │  Detection   │                  │  │
│   │  └──────────────┘ └──────────────┘ └──────────────┘                  │  │
│   └─────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 Feature Specifications

#### 1.2.1 Term Explanation

| Capability | Description | Output Format |
|-----------|-------------|---------------|
| **Basic Explanation** | Simple definition for beginners | 2-3 sentences |
| **Detailed Explanation** | Comprehensive coverage | 1-2 paragraphs |
| **Technical Definition** | Expert-level detail | Structured with physics |
| **Step-by-Step Guide** | How-to instructions | Numbered steps |
| **Visual Description** | Imagery for mental model | Descriptive text |

**Example Prompt:**
```
Explain the draw shot as a {skill_level} technique for {discipline}.
Include:
- What it is
- When to use it
- Key mechanics
- Common mistakes

Language: {language}
Context: Player looking to improve position play
```

#### 1.2.2 Term Comparison

| Comparison Type | Description | Output Format |
|----------------|-------------|---------------|
| **Similar Terms** | Terms with overlapping concepts | Side-by-side table |
| **Opposite Terms** | Contrasting techniques | Comparison with differences |
| **Progression** | Beginner to advanced variants | Sequential list |
| **Category Group** | All terms in a category | Grouped summary |

**Example Prompt:**
```
Compare draw shot and follow shot for a {skill_level} player.

Include:
- Key similarities
- Key differences
- When to prefer each
- Practice tips for each

Output format: Comparison table with explanations
```

#### 1.2.3 Drill Suggestions

| Input | Output | Content |
|-------|--------|---------|
| **Skill Level** | Targeted drills | Drills appropriate to level |
| **Known Technique** | Complementary drills | Skills that reinforce |
| **Weakness Area** | Remedial drills | Drills to address weakness |
| **Equipment** | Equipment-specific drills | Cue/table/practice methods |

**Example Prompt:**
```
Suggest 5 drills to improve draw shot technique for an intermediate player.

For each drill include:
- Name
- Description (how to perform)
- Purpose
- Difficulty (1-5)
- Duration
- Variations

Format: Structured list with difficulty ratings
```

#### 1.2.4 Related Concept Discovery

| Discovery Type | Algorithm | Output |
|---------------|-----------|--------|
| **Direct Relationships** | Graph traversal | Terms with explicit links |
| **Semantic Similarity** | Vector similarity | Related concepts by meaning |
| **Category Proximity** | Category tree | Same/sub-category terms |
| **Usage Patterns** | Co-occurrence | Terms often used together |

**Example Prompt:**
```
Find all concepts related to "draw shot" including:
- Direct relationships (uses, prerequisites)
- Semantic matches (similar techniques)
- Category neighbors
- Common co-occurrences

Return organized by relationship type with explanations
```

#### 1.2.5 Learning Path Generation

| Path Type | Content | Structure |
|-----------|---------|-----------|
| **Skill-Based** | Complete skill acquisition | Prerequisites → Core → Advanced |
| **Game-Based** | Specific game improvement | 8-ball, 9-ball, Snooker specific |
| **Time-Based** | Daily/weekly practice | 15min, 30min, 1hr routines |
| **Adaptive** | Personalized progression | Based on assessment |

**Example Prompt:**
```
Create a 4-week learning path for an intermediate player 
to master draw shot technique.

Include:
- Weekly milestones
- Daily practice allocation
- Specific drills for each day
- Progress indicators
- Assessment checkpoints

Time commitment: 30 minutes per day
```

#### 1.2.6 Quiz Generation

| Quiz Type | Question Types | Difficulty |
|-----------|---------------|------------|
| **Knowledge** | Definitions, facts | Variable |
| **Application** | Scenario-based | Medium-Hard |
| **Identification** | Spot the technique | Visual |
| **Mixed** | All types | Adaptive |

**Example Prompt:**
```
Generate a 10-question quiz on draw shot technique 
for an intermediate player.

Include:
- 4 definition questions
- 3 application questions
- 3 technique identification questions

For each question:
- Question text
- Answer options (4 for multiple choice)
- Correct answer
- Explanation

Difficulty: Intermediate
Language: {language}
```

#### 1.2.7 Practice Session Generation

| Session Type | Duration | Focus |
|--------------|----------|-------|
| **Warm-Up** | 10-15 min | Light practice, mental prep |
| **Skill Building** | 30-60 min | Targeted technique |
| **Game Simulation** | 45-90 min | Match situations |
| **Full Practice** | 90-120 min | Complete routine |

**Example Prompt:**
```
Create a 45-minute practice session for draw shot improvement.

Structure:
- 5 min: Warm-up
- 20 min: Main drills
- 10 min: Application practice
- 10 min: Cool-down

Include specific exercises, repetitions, and success criteria
```

---

## 2. Prompt Templates

### 2.1 Core Template Structure

```json
{
  "template_id": "term_explanation_v1",
  "name": "Term Explanation",
  "version": "v1",
  
  "system_prompt": "You are an expert billiards coach with extensive knowledge of {discipline}. Provide accurate, helpful explanations following the Pool OS teaching methodology.",
  
  "template": {
    "task": "Explain the {term_name} in {language}",
    "context": {
      "skill_level": "{skill_level}",
      "discipline": "{discipline}",
      "player_background": "{player_background}"
    },
    "requirements": {
      "include_definitions": true,
      "include_examples": true,
      "include_common_mistakes": true,
      "include_practice_tips": true,
      "difficulty_adjustment": "{skill_level}"
    },
    "output_format": "structured_markdown"
  },
  
  "variables": {
    "term_name": {
      "type": "string",
      "required": true,
      "description": "The term to explain"
    },
    "language": {
      "type": "enum",
      "options": ["en", "vi", "ja", "ko"],
      "default": "en"
    },
    "skill_level": {
      "type": "enum",
      "options": ["beginner", "intermediate", "advanced", "professional"]
    },
    "discipline": {
      "type": "enum",
      "options": ["pool", "snooker", "carom", "chinese_8ball"]
    },
    "player_background": {
      "type": "string",
      "required": false,
      "description": "Additional context about the player"
    }
  },
  
  "constraints": {
    "max_tokens": 2000,
    "temperature": 0.7,
    "format": "markdown"
  }
}
```

### 2.2 Template Library

#### 2.2.1 Term Explanation Template

```markdown
## System Prompt
You are an expert billiards coach with extensive knowledge of {discipline}.
Provide accurate, helpful explanations following the Pool OS teaching methodology.

## User Prompt
Explain the **{term_name}** for a {skill_level} player in {discipline}.

### Context
- Player experience: {player_experience}
- Learning goal: {learning_goal}
- Preferred language: {language}

### Requirements
Provide a comprehensive explanation including:
1. **What is it?** - Clear definition
2. **Why use it?** - Purpose and benefits
3. **How to execute** - Step-by-step mechanics
4. **When to use** - Appropriate situations
5. **Common mistakes** - What to avoid
6. **Practice tips** - How to improve

### Output Format
Use markdown with headers, bullet points, and emphasis.
Keep explanations accessible but technically accurate.
Adjust complexity to {skill_level} level.
```

#### 2.2.2 Drill Suggestion Template

```markdown
## System Prompt
You are a certified billiards coach specializing in drill design and 
skill development. Recommend effective, progressive drills that build 
competence systematically.

## User Prompt
Suggest {number} drills to improve **{technique_name}** for a 
{skill_level} {discipline} player.

### Player Context
- Available equipment: {equipment}
- Practice space: {space}
- Time available: {duration}
- Current skill assessment: {assessment}

### Drill Requirements
For each drill provide:
1. **Name** - Descriptive title
2. **Objective** - What skill it develops
3. **Setup** - How to prepare
4. **Execution** - Step-by-step instructions
5. **Success criteria** - How to measure progress
6. **Variations** - Modifications for different levels

### Output Format
Structured list with difficulty rating for each drill.
Include approximate time and repetitions.
```

#### 2.2.3 Quiz Generation Template

```markdown
## System Prompt
You are an expert billiards educator creating assessments for skill development.
Questions should be accurate, fair, and pedagogically valuable.

## User Prompt
Generate a {question_count}-question quiz on **{topic_name}**.

### Quiz Specifications
- Difficulty: {difficulty}
- Question types: {question_types} (definition, application, analysis, etc.)
- Player level: {player_level}
- Language: {language}

### Question Requirements
For each question provide:
1. Question text
2. Answer options (4 for multiple choice)
3. Correct answer
4. Explanation (why the answer is correct)
5. Difficulty rating (1-5)
6. Related concept

### Output Format
JSON or markdown with all question data.
Include quiz metadata (title, instructions, time estimate).
```

### 2.3 Variable Definitions

```json
{
  "variables": {
    "term_name": {
      "type": "string",
      "description": "Name of the billiards term to explain"
    },
    "language": {
      "type": "enum",
      "options": ["en", "vi", "ja", "ko", "zh_CN"],
      "default": "en"
    },
    "skill_level": {
      "type": "enum",
      "options": ["beginner", "intermediate", "advanced", "professional"],
      "description": "Player's skill level"
    },
    "discipline": {
      "type": "enum",
      "options": ["pool", "snooker", "carom", "chinese_8ball", "any"],
      "default": "pool"
    },
    "player_experience": {
      "type": "string",
      "description": "Brief description of player's experience"
    },
    "learning_goal": {
      "type": "string",
      "description": "What the player wants to achieve"
    },
    "equipment": {
      "type": "array",
      "description": "Available equipment",
      "items": ["cue", "table", "balls", "training aids"]
    },
    "space": {
      "type": "string",
      "description": "Available practice space"
    },
    "duration": {
      "type": "string",
      "description": "Time available for practice"
    },
    "assessment": {
      "type": "object",
      "description": "Current skill assessment",
      "properties": {
        "strengths": { "type": "array" },
        "weaknesses": { "type": "array" },
        "consistency": { "type": "number" }
      }
    }
  }
}
```

---

## 3. Response Format Standards

### 3.1 Structured Response Schema

```json
{
  "response": {
    "id": "response-uuid",
    "request_id": "request-uuid",
    "model": "gpt-4-turbo",
    
    "content": {
      "text": "Markdown formatted response...",
      "sections": [
        {
          "type": "explanation",
          "content": "..."
        },
        {
          "type": "steps",
          "items": ["...", "..."]
        },
        {
          "type": "examples",
          "items": [
            {
              "scenario": "...",
              "result": "..."
            }
          ]
        }
      ]
    },
    
    "citations": [
      {
        "term_id": "term-uuid",
        "slug": "draw-shot",
        "source": "BKM",
        "relevance": 0.95
      }
    ],
    
    "metadata": {
      "tokens_used": 1500,
      "generation_time_ms": 2500,
      "confidence": 0.92,
      "language": "en"
    }
  }
}
```

### 3.2 Response Quality Checks

| Check | Requirement | Action on Failure |
|-------|-------------|-------------------|
| **Accuracy** | Must not contradict BKM | Flag for review |
| **Completeness** | All required sections present | Request regeneration |
| **Safety** | No harmful advice | Block response |
| **Format** | Matches template | Reformat |
| **Length** | Within token limits | Truncate or summarize |

---

## 4. Context Window Management

### 4.1 Context Budget

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          CONTEXT WINDOW ALLOCATION                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Total Context: 128,000 tokens                                                │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ System Prompt: 2,000 tokens (1.6%)                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ BKM Context (RAG): 60,000 tokens (47%)                               │   │
│  │  - Related terms: 20,000 tokens                                      │   │
│  │  - Definitions: 15,000 tokens                                        │   │
│  │  - Examples: 10,000 tokens                                          │   │
│  │  - Media descriptions: 5,000 tokens                                │   │
│  │  - Prerequisites: 5,000 tokens                                     │   │
│  │  - Related sources: 5,000 tokens                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ User Query: 1,000 tokens (0.8%)                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Response: 65,000 tokens (51%)                                       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.2 Context Selection Algorithm

```python
def select_context(query: str, term: Term, max_tokens: int = 60000) -> list:
    """
    Select relevant context for AI prompt within token budget.
    """
    context = []
    remaining_tokens = max_tokens
    
    # 1. Primary term definition (high priority)
    definition = get_term_definition(term)
    tokens = estimate_tokens(definition)
    if tokens <= remaining_tokens:
        context.append(("definition", definition))
        remaining_tokens -= tokens
    
    # 2. Related terms (medium priority)
    related = get_related_terms(term, max_related=10)
    for rel in related:
        rel_text = f"Related: {rel.name}\n{rel.definition}\n"
        tokens = estimate_tokens(rel_text)
        if tokens <= remaining_tokens:
            context.append(("related", rel_text))
            remaining_tokens -= tokens
    
    # 3. Examples (fill remaining)
    examples = get_examples(term, max_examples=5)
    for ex in examples:
        ex_text = f"Example: {ex.text}\n"
        tokens = estimate_tokens(ex_text)
        if tokens <= remaining_tokens:
            context.append(("example", ex_text))
            remaining_tokens -= tokens
    
    return context
```

---

## 5. RAG Architecture

### 5.1 RAG Pipeline

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         RAG ARCHITECTURE                                       │
└─────────────────────────────────────────────────────────────────────────────┘

User Query: "How do I improve my draw shot technique?"
                    │
                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ STAGE 1: Query Processing                                                     │
│                                                                              │
│ • Query embedding (text-embedding-3)                                          │
│ • Keyword extraction: draw, shot, improve, technique                          │
│ • Intent classification: learning, drill, comparison                          │
│ • Language detection: en                                                     │
└─────────────────────────────────────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ STAGE 2: Retrieval Strategy                                                    │
│                                                                              │
│ ┌───────────────────────────────────────────────────────────────────────┐  │
│ │  Hybrid Retrieval                                                        │  │
│ │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐  │  │
│ │  │  Vector Search  │    │  Keyword Search │    │  Graph Traverse │  │  │
│ │  │  (Pinecone)     │ OR │  (PostgreSQL)   │ OR │  (Neo4j)        │  │  │
│ │  │                 │    │                 │    │                 │  │  │
│ │  │  Semantic match │    │  Exact match    │    │  Relationships  │  │  │
│ │  │  to query       │    │  to keywords    │    │  via graph     │  │  │
│ │  └─────────────────┘    └─────────────────┘    └─────────────────┘  │  │
│ └───────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ STAGE 3: Document Ranking                                                     │
│                                                                              │
│ • BM25 scores for keyword matches                                             │
│ • Vector similarity for semantic matches                                      │
│ • Relationship strength for graph matches                                      │
│ • Reciprocal Rank Fusion (RRF)                                               │
│ • Re-rank with cross-encoder                                                  │
└─────────────────────────────────────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ STAGE 4: Context Assembly                                                     │
│                                                                              │
│ • Select top-K documents (K=20)                                              │
│ • Remove duplicates                                                           │
│ • Truncate to fit context window                                              │
│ • Add document metadata and citations                                        │
└─────────────────────────────────────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ STAGE 5: Generation                                                           │
│                                                                              │
│ • Inject context into prompt                                                   │
│ • Generate response with citations                                            │
│ • Post-process for format compliance                                          │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.2 Vector Embedding Strategy

```json
{
  "embeddings": {
    "model": "text-embedding-3-large",
    "dimensions": 3072,
    "batch_size": 100,
    
    "content_to_embed": {
      "term_name": {
        "template": "{name_en} - {definition_en}",
        "weight": 1.0
      },
      "term_summary": {
        "template": "Summary: {summary_en}",
        "weight": 0.8
      },
      "term_examples": {
        "template": "Examples: {examples_en}",
        "weight": 0.6
      },
      "term_relationships": {
        "template": "Related to: {related_terms}",
        "weight": 0.5
      }
    },
    
    "indexing": {
      "provider": "pinecone",
      "index_name": "pool-os-terms",
      "metric": "cosine",
      "metadata_fields": ["slug", "discipline", "difficulty", "language"]
    }
  }
}
```

### 5.3 Retrieval Configuration

```python
class RetrievalConfig:
    # Vector search settings
    vector_top_k = 20
    vector_similarity_threshold = 0.7
    
    # Keyword search settings
    keyword_fields = ["name", "summary", "definition", "aliases"]
    keyword_top_k = 20
    keyword_bm25_weight = 0.3
    
    # Graph settings
    graph_depth = 2  # Follow relationships up to 2 hops
    graph_max_nodes = 10
    
    # Fusion settings
    fusion_method = "rrf"  # Reciprocal Rank Fusion
    fusion_k = 60
    
    # Reranking
    use_reranker = True
    reranker_model = "cross-encoder/ms-marco-MiniLM-L-6v2"
    reranker_top_k = 10
```

---

## 6. Semantic Search Integration

### 6.1 Semantic Search Pipeline

```python
async def semantic_search(query: SearchQuery) -> SearchResults:
    """
    Hybrid search combining vector and keyword search.
    """
    # 1. Generate query embedding
    query_embedding = await embedding_service.embed(query.text)
    
    # 2. Parallel retrieval
    vector_results = await vector_db.search(
        embedding=query_embedding,
        top_k=Config.vector_top_k,
        filter=query.filters
    )
    
    keyword_results = await postgres.search(
        query=query.text,
        fields=Config.keyword_fields,
        top_k=Config.keyword_top_k,
        filters=query.filters
    )
    
    # 3. Graph expansion (if enabled)
    if query.expand_graph:
        graph_results = await graph_db.traverse(
            seed_terms=extract_terms(query.text),
            depth=Config.graph_depth,
            relationship_types=["uses", "prerequisite", "related"]
        )
    else:
        graph_results = []
    
    # 4. RRF Fusion
    fused_results = reciprocal_rank_fusion(
        sources=[vector_results, keyword_results, graph_results],
        k=Config.fusion_k
    )
    
    # 5. Rerank (optional)
    if Config.use_reranker:
        fused_results = await reranker.rerank(
            query=query.text,
            documents=fused_results,
            top_k=Config.reranker_top_k
        )
    
    return fused_results
```

---

## 7. LLM Provider Considerations

### 7.1 Provider Comparison

| Provider | Model | Strengths | Limitations |
|----------|-------|----------|-------------|
| **OpenAI** | GPT-4o, GPT-4-turbo | Speed, function calling | Cost, rate limits |
| **Anthropic** | Claude 3.5 | Reasoning, long context | Token limits |
| **Google** | Gemini 1.5 | Long context, multimodal | Availability |
| **Local** | Llama 3, Mistral | Privacy, no API cost | Quality, hardware |

### 7.2 Cost Optimization Strategies

| Strategy | Savings | Trade-off |
|----------|---------|-----------|
| **Caching** | 60-80% | Stale responses possible |
| **Batching** | 20-30% | Increased latency |
| **Model selection** | Variable | Quality vs cost |
| **Context pruning** | 30-40% | May lose context |
| **Response truncation** | 10-20% | Less detail |

### 7.3 Provider Abstraction

```python
class LLMProvider(Protocol):
    async def generate(
        self, 
        prompt: str, 
        system: str,
        **kwargs
    ) -> GenerationResult:
        ...
    
    async def embed(self, text: str) -> Embedding:
        ...

class OpenAIProvider(LLMProvider):
    def __init__(self, api_key: str, model: str = "gpt-4-turbo"):
        self.client = OpenAI(api_key=api_key)
        self.model = model
    
    async def generate(self, prompt: str, system: str, **kwargs) -> GenerationResult:
        response = await self.client.chat.completions.create(
            model=self.model,
            messages=[
                {"role": "system", "content": system},
                {"role": "user", "content": prompt}
            ],
            **kwargs
        )
        return GenerationResult(
            text=response.choices[0].message.content,
            tokens=response.usage.total_tokens
        )

class AnthropicProvider(LLMProvider):
    def __init__(self, api_key: str, model: str = "claude-3-5-sonnet"):
        self.client = Anthropic(api_key=api_key)
        self.model = model
    # ... similar implementation
```

---

## 8. Privacy Considerations

### 8.1 Data Handling

| Data Type | Handling | Retention |
|-----------|----------|-----------|
| **User queries** | Anonymized | 90 days |
| **Session context** | Encrypted | Session only |
| **Generated content** | Logged | 1 year |
| **User preferences** | GDPR compliant | Until deletion |

### 8.2 Privacy-Preserving Features

```python
class PrivacyConfig:
    # Anonymization
    anonymize_queries = True
    anonymize_fields = ["user_id", "session_id", "ip_address"]
    
    # Data minimization
    log_only_aggregates = False
    delete_after_days = 90
    
    # User control
    allow_opt_out = True
    export_data_available = True
    delete_on_request = True
```

### 8.3 Content Filtering

```python
class ContentFilter:
    """
    Filter AI-generated content for safety and quality.
    """
    
    def check_response(self, response: str) -> FilterResult:
        checks = [
            self._safety_check(response),
            self._accuracy_check(response),
            self._bias_check(response),
            self._format_check(response)
        ]
        
        return FilterResult(
            passed=all(c.passed for c in checks),
            issues=[c.issue for c in checks if not c.passed]
        )
    
    def _safety_check(self, response: str) -> CheckResult:
        # Check for harmful content
        harmful_patterns = ["...", "..."]  # Define patterns
        for pattern in harmful_patterns:
            if re.search(pattern, response):
                return CheckResult(passed=False, issue="safety_violation")
        return CheckResult(passed=True)
```

---

## 9. Appendix

### 9.1 API Response Examples

```json
{
  "ai_response": {
    "type": "term_explanation",
    "term": {
      "slug": "draw-shot",
      "name": { "en": "Draw Shot", "vi": "Úp Bóng" }
    },
    "explanation": {
      "what_is_it": "...",
      "why_use_it": "...",
      "how_to_execute": ["...", "..."],
      "when_to_use": ["...", "..."],
      "common_mistakes": ["...", "..."],
      "practice_tips": ["...", "..."]
    },
    "related_terms": ["follow-shot", "stun-shot"],
    "drills": ["draw-shot-drill-1", "draw-shot-drill-2"],
    "citations": ["bkm:draw-shot", "bkm:backspin"]
  }
}
```

### 9.2 Related Documents

- [BKM Architecture](./02_Architecture.md)
- [BKM Search System](./05_Search_System.md)
- [BKM API Design](./15_API_Design_For_PoolOS.md)
- [BKM Database Schema](./03_Database.md)

---

**End of Document**
