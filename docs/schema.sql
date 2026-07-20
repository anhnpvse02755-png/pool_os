-- BKM Knowledge Graph Database Schema
-- Version 1.0
-- Last Updated: July 2026
-- Database: PostgreSQL (SQLite compatible with modifications)

-- ============================================================================
-- ID SEQUENCES
-- ============================================================================

CREATE TABLE id_sequences (
    entity_type    VARCHAR(20) PRIMARY KEY,
    prefix         VARCHAR(10) NOT NULL,
    current_max    BIGINT NOT NULL DEFAULT 0,
    min_value      BIGINT NOT NULL DEFAULT 1,
    max_value      BIGINT NOT NULL DEFAULT 999999,
    increment_by   BIGINT NOT NULL DEFAULT 1,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT valid_range CHECK (current_max <= max_value)
);

-- Pre-populate with entity types
INSERT INTO id_sequences (entity_type, prefix, current_max) VALUES
    ('CATEGORY', 'CAT', 0),
    ('TERM', 'TERM', 0),
    ('TAG', 'TAG', 0),
    ('MEDIA', 'MEDIA', 0),
    ('RELATION', 'REL', 0),
    ('USER', 'USR', 0),
    ('SESSION', 'SES', 0),
    ('DRILL', 'DRL', 0),
    ('QUIZ', 'QUIZ', 0),
    ('DRILL_ATTEMPT', 'DA', 0),
    ('REVISION', 'REV', 0);

-- ============================================================================
-- CATEGORIES
-- ============================================================================

CREATE TABLE categories (
    id              VARCHAR(20) PRIMARY KEY,
    slug            VARCHAR(100) NOT NULL UNIQUE,
    names           JSONB NOT NULL,
    description     JSONB,
    
    -- Hierarchy
    parent_id       VARCHAR(20) REFERENCES categories(id),
    parent_path     TEXT[] DEFAULT '{}',
    level           SMALLINT NOT NULL DEFAULT 0,
    sort_order      SMALLINT NOT NULL DEFAULT 0,
    
    -- Display
    icon            VARCHAR(50),
    color           VARCHAR(7),
    
    -- Status
    is_active       BOOLEAN NOT NULL DEFAULT true,
    
    -- Timestamps
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT valid_level CHECK (level >= 0 AND level <= 3),
    CONSTRAINT valid_slug CHECK (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$')
);

CREATE INDEX idx_categories_parent ON categories(parent_id);
CREATE INDEX idx_categories_level ON categories(level);
CREATE INDEX idx_categories_slug ON categories(slug);
CREATE INDEX idx_categories_path ON categories USING GIN(parent_path);
CREATE INDEX idx_categories_active ON categories(is_active) WHERE is_active = true;

-- ============================================================================
-- TERMS
-- ============================================================================

CREATE TABLE terms (
    -- Primary Key
    id              VARCHAR(20) PRIMARY KEY,
    
    -- Identification
    slug            VARCHAR(255) NOT NULL,
    
    -- Content
    names           JSONB NOT NULL,
    pronunciation   JSONB,
    definition_short JSONB NOT NULL,
    definition_full  JSONB NOT NULL,
    aliases         JSONB DEFAULT '{}',
    notes           JSONB,
    
    -- Classification
    category_id     VARCHAR(20) NOT NULL REFERENCES categories(id),
    difficulty      VARCHAR(20) NOT NULL DEFAULT 'beginner',
    status          VARCHAR(20) NOT NULL DEFAULT 'draft',
    
    -- SEO
    meta_title      JSONB,
    meta_description JSONB,
    keywords        JSONB DEFAULT '[]',
    
    -- Statistics
    views           INTEGER NOT NULL DEFAULT 0,
    completions    INTEGER NOT NULL DEFAULT 0,
    average_rating  DECIMAL(3,2) DEFAULT 0,
    quiz_pass_rate  DECIMAL(5,2) DEFAULT 0,
    last_accessed_at TIMESTAMPTZ,
    
    -- Timestamps
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    published_at    TIMESTAMPTZ,
    next_review_date TIMESTAMPTZ,
    
    -- Constraints
    CONSTRAINT unique_slug UNIQUE (slug),
    CONSTRAINT valid_difficulty CHECK (difficulty IN ('beginner', 'intermediate', 'advanced', 'professional')),
    CONSTRAINT valid_status CHECK (status IN ('draft', 'review', 'published', 'deprecated')),
    CONSTRAINT valid_rating CHECK (average_rating >= 0 AND average_rating <= 5)
);

CREATE INDEX idx_terms_slug ON terms(slug);
CREATE INDEX idx_terms_category ON terms(category_id);
CREATE INDEX idx_terms_difficulty ON terms(difficulty);
CREATE INDEX idx_terms_status ON terms(status);
CREATE INDEX idx_terms_published ON terms(published_at) WHERE status = 'published';
CREATE INDEX idx_terms_updated ON terms(updated_at);

-- ============================================================================
-- TAGS
-- ============================================================================

CREATE TABLE tags (
    id              VARCHAR(20) PRIMARY KEY,
    slug            VARCHAR(50) NOT NULL UNIQUE,
    names           JSONB NOT NULL,
    description     JSONB,
    color           VARCHAR(7),
    icon            VARCHAR(50),
    sort_order      INTEGER DEFAULT 0,
    is_active       BOOLEAN NOT NULL DEFAULT true,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_tags_slug ON tags(slug);
CREATE INDEX idx_tags_active ON tags(is_active) WHERE is_active = true;

-- ============================================================================
-- TERM-TAG JUNCTION
-- ============================================================================

CREATE TABLE term_tags (
    term_id         VARCHAR(20) NOT NULL REFERENCES terms(id) ON DELETE CASCADE,
    tag_id          VARCHAR(20) NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (term_id, tag_id)
);

CREATE INDEX idx_term_tags_term ON term_tags(term_id);
CREATE INDEX idx_term_tags_tag ON term_tags(tag_id);

-- ============================================================================
-- MEDIA
-- ============================================================================

CREATE TABLE media (
    id              VARCHAR(20) PRIMARY KEY,
    term_id         VARCHAR(20) NOT NULL REFERENCES terms(id) ON DELETE CASCADE,
    type            VARCHAR(20) NOT NULL,
    role            VARCHAR(20) NOT NULL,
    names           JSONB NOT NULL,
    file_name       VARCHAR(255) NOT NULL,
    mime_type       VARCHAR(100) NOT NULL,
    url             VARCHAR(500) NOT NULL,
    thumbnail_url   VARCHAR(500),
    width           INTEGER,
    height          INTEGER,
    file_size       INTEGER,
    alt_text        JSONB NOT NULL,
    captions        JSONB,
    is_active       BOOLEAN NOT NULL DEFAULT true,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT valid_media_type CHECK (type IN ('image', 'video', 'animation', 'svg', 'audio')),
    CONSTRAINT valid_media_role CHECK (role IN ('primary', 'illustration', 'tutorial', 'diagram'))
);

CREATE INDEX idx_media_term ON media(term_id);
CREATE INDEX idx_media_type ON media(type);
CREATE INDEX idx_media_active ON media(is_active) WHERE is_active = true;

-- ============================================================================
-- RELATIONSHIPS
-- ============================================================================

CREATE TABLE relationships (
    id                  VARCHAR(20) PRIMARY KEY,
    source_id           VARCHAR(20) NOT NULL REFERENCES terms(id) ON DELETE CASCADE,
    target_id           VARCHAR(20) NOT NULL REFERENCES terms(id) ON DELETE CASCADE,
    relationship_type   VARCHAR(30) NOT NULL,
    weight              DECIMAL(3,2) DEFAULT 1.0,
    notes               JSONB,
    is_bidirectional    BOOLEAN DEFAULT false,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT unique_relationship UNIQUE (source_id, target_id, relationship_type),
    CONSTRAINT valid_weight CHECK (weight >= 0 AND weight <= 1),
    CONSTRAINT valid_relationship_type CHECK (relationship_type IN (
        'prerequisite', 'leads_to', 'synonym', 'opposite', 
        'part_of', 'uses', 'trained_by', 'opposite_of'
    )),
    CONSTRAINT no_self_reference CHECK (source_id != target_id)
);

CREATE INDEX idx_relationships_source ON relationships(source_id);
CREATE INDEX idx_relationships_target ON relationships(target_id);
CREATE INDEX idx_relationships_type ON relationships(relationship_type);

-- ============================================================================
-- KEY POINTS
-- ============================================================================

CREATE TABLE key_points (
    id              VARCHAR(20) PRIMARY KEY,
    term_id         VARCHAR(20) NOT NULL REFERENCES terms(id) ON DELETE CASCADE,
    order_index     SMALLINT NOT NULL DEFAULT 0,
    title           JSONB NOT NULL,
    content         JSONB NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_key_points_term ON key_points(term_id);
CREATE INDEX idx_key_points_order ON key_points(term_id, order_index);

-- ============================================================================
-- STEPS
-- ============================================================================

CREATE TABLE steps (
    id              VARCHAR(20) PRIMARY KEY,
    term_id         VARCHAR(20) NOT NULL REFERENCES terms(id) ON DELETE CASCADE,
    order_index     SMALLINT NOT NULL DEFAULT 0,
    title           JSONB NOT NULL,
    description     JSONB NOT NULL,
    tips            JSONB DEFAULT '[]',
    media_id        VARCHAR(20) REFERENCES media(id) ON DELETE SET NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_steps_term ON steps(term_id);
CREATE INDEX idx_steps_order ON steps(term_id, order_index);

-- ============================================================================
-- COMMON MISTAKES
-- ============================================================================

CREATE TABLE common_mistakes (
    id              VARCHAR(20) PRIMARY KEY,
    term_id         VARCHAR(20) NOT NULL REFERENCES terms(id) ON DELETE CASCADE,
    mistake         JSONB NOT NULL,
    cause           JSONB NOT NULL,
    correction      JSONB NOT NULL,
    order_index     SMALLINT NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_common_mistakes_term ON common_mistakes(term_id);

-- ============================================================================
-- TROUBLESHOOTING
-- ============================================================================

CREATE TABLE troubleshooting (
    id              VARCHAR(20) PRIMARY KEY,
    term_id         VARCHAR(20) NOT NULL REFERENCES terms(id) ON DELETE CASCADE,
    problem         JSONB NOT NULL,
    cause           JSONB NOT NULL,
    solution        JSONB NOT NULL,
    order_index     SMALLINT NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_troubleshooting_term ON troubleshooting(term_id);

-- ============================================================================
-- QUIZ QUESTIONS
-- ============================================================================

CREATE TABLE quiz_questions (
    id              VARCHAR(20) PRIMARY KEY,
    term_id         VARCHAR(20) NOT NULL REFERENCES terms(id) ON DELETE CASCADE,
    question        JSONB NOT NULL,
    options         JSONB NOT NULL,
    correct_answer  VARCHAR(1) NOT NULL,
    explanation     JSONB,
    order_index     SMALLINT NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_quiz_questions_term ON quiz_questions(term_id);
CREATE INDEX idx_quiz_questions_order ON quiz_questions(term_id, order_index);

-- ============================================================================
-- DRILLS
-- ============================================================================

CREATE TABLE drills (
    id              VARCHAR(20) PRIMARY KEY,
    term_id         VARCHAR(20) NOT NULL REFERENCES terms(id) ON DELETE CASCADE,
    name            VARCHAR(255) NOT NULL,
    difficulty      VARCHAR(20) NOT NULL DEFAULT 'beginner',
    equipment       JSONB DEFAULT '[]',
    duration_minutes INTEGER DEFAULT 15,
    instructions    JSONB NOT NULL,
    success_criteria JSONB,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT valid_drill_difficulty CHECK (difficulty IN ('beginner', 'intermediate', 'advanced'))
);

CREATE INDEX idx_drills_term ON drills(term_id);
CREATE INDEX idx_drills_difficulty ON drills(difficulty);

-- ============================================================================
-- REFERENCES
-- ============================================================================

CREATE TABLE references (
    id              VARCHAR(20) PRIMARY KEY,
    term_id         VARCHAR(20) NOT NULL REFERENCES terms(id) ON DELETE CASCADE,
    ref_type        VARCHAR(20) NOT NULL,
    title           VARCHAR(500) NOT NULL,
    author          VARCHAR(255),
    url             VARCHAR(500),
    year            INTEGER,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT valid_ref_type CHECK (ref_type IN ('book', 'article', 'video', 'website'))
);

CREATE INDEX idx_references_term ON references(term_id);
CREATE INDEX idx_references_type ON references(ref_type);

-- ============================================================================
-- REVISIONS (Audit Trail)
-- ============================================================================

CREATE TABLE revisions (
    id              VARCHAR(20) PRIMARY KEY,
    term_id         VARCHAR(20) NOT NULL REFERENCES terms(id) ON DELETE CASCADE,
    version         VARCHAR(20) NOT NULL,
    changes         JSONB NOT NULL,
    author_id       VARCHAR(20),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_revisions_term ON revisions(term_id);
CREATE INDEX idx_revisions_date ON revisions(created_at);

-- ============================================================================
-- USERS
-- ============================================================================

CREATE TABLE users (
    id              VARCHAR(20) PRIMARY KEY,
    email           VARCHAR(255) NOT NULL UNIQUE,
    name            VARCHAR(255) NOT NULL,
    role            VARCHAR(20) NOT NULL DEFAULT 'viewer',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT valid_role CHECK (role IN ('viewer', 'editor', 'reviewer', 'admin'))
);

CREATE INDEX idx_users_email ON users(email);

-- ============================================================================
-- SESSIONS
-- ============================================================================

CREATE TABLE sessions (
    id              VARCHAR(20) PRIMARY KEY,
    user_id         VARCHAR(20) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    started_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ended_at        TIMESTAMPTZ,
    terms_viewed    JSONB DEFAULT '[]',
    drills_completed INTEGER DEFAULT 0,
    quiz_score      DECIMAL(5,2)
);

CREATE INDEX idx_sessions_user ON sessions(user_id);
CREATE INDEX idx_sessions_date ON sessions(started_at);

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Atomic ID allocation
CREATE OR REPLACE FUNCTION allocate_id(p_entity_type VARCHAR)
RETURNS VARCHAR AS $$
DECLARE
    v_prefix VARCHAR;
    v_next_id BIGINT;
    v_result VARCHAR;
BEGIN
    UPDATE id_sequences
    SET 
        current_max = current_max + 1,
        updated_at = NOW()
    WHERE entity_type = p_entity_type
    RETURNING prefix, current_max INTO v_prefix, v_next_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Unknown entity type: %', p_entity_type;
    END IF;
    
    v_result := v_prefix || '-' || LPAD(v_next_id::TEXT, 6, '0');
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for auto-update
CREATE TRIGGER trg_terms_updated_at
    BEFORE UPDATE ON terms
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_categories_updated_at
    BEFORE UPDATE ON categories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_tags_updated_at
    BEFORE UPDATE ON tags
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_media_updated_at
    BEFORE UPDATE ON media
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================================
-- VIEWS
-- ============================================================================

-- Published terms view
CREATE OR REPLACE VIEW v_published_terms AS
SELECT 
    t.*,
    c.slug AS category_slug,
    c.names AS category_names,
    (
        SELECT json_agg(json_build_object(
            'id', m.id,
            'type', m.type,
            'role', m.role,
            'url', m.url,
            'thumbnail_url', m.thumbnail_url
        ))
        FROM media m
        WHERE m.term_id = t.id AND m.is_active = true
    ) AS media,
    (
        SELECT json_agg(json_build_object(
            'id', tg.id,
            'slug', tg.slug,
            'name', tg.names,
            'color', tg.color
        ))
        FROM term_tags tt
        JOIN tags tg ON tt.tag_id = tg.id
        WHERE tt.term_id = t.id AND tg.is_active = true
    ) AS tags
FROM terms t
LEFT JOIN categories c ON t.category_id = c.id
WHERE t.status = 'published' AND t.is_active = true;

-- Term statistics view
CREATE OR REPLACE VIEW v_term_statistics AS
SELECT 
    t.id,
    t.slug,
    t.names,
    t.views,
    t.completions,
    t.average_rating,
    t.quiz_pass_rate,
    t.last_accessed_at,
    (
        SELECT COUNT(*) 
        FROM relationships r 
        WHERE r.source_id = t.id OR r.target_id = t.id
    ) AS relationship_count,
    (
        SELECT COUNT(*) 
        FROM media m 
        WHERE m.term_id = t.id AND m.is_active = true
    ) AS media_count
FROM terms t;

-- ============================================================================
-- SEED DATA: Categories
-- ============================================================================

-- (See category_seed.json for full category data)

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================
