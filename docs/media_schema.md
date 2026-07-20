# BKM - Media Schema

## Version 1.0
**Last Updated:** July 2026
**Status:** Production Standard

---

## 1. Overview

Media assets enhance terms with visual and audio content.

---

## 2. Media Types

| Type | Extensions | Purpose |
|------|------------|---------|
| `image` | webp, jpg, png | Photos, diagrams |
| `video` | mp4, webm | Tutorials, demos |
| `animation` | gif, webp | Ball paths, animations |
| `svg` | svg | Diagrams, diagrams |
| `audio` | mp3, ogg | Audio tips |

---

## 3. Media Schema

```json
{
  "id": "MEDIA-000001",
  "term_id": "TERM-000001",
  "type": "image",
  "role": "primary",
  "names": {
    "en": "Draw Shot Diagram",
    "vi": "Sơ đồ đường cắt đít"
  },
  "file_name": "draw-shot-diagram.webp",
  "mime_type": "image/webp",
  "url": "/media/draw-shot-diagram.webp",
  "thumbnail_url": "/media/draw-shot-diagram-thumb.webp",
  "width": 1920,
  "height": 1080,
  "file_size": 102400,
  "alt_text": {
    "en": "Diagram showing cue ball contact point for draw shot",
    "vi": "Sơ đồ điểm chạm bóng cơ cho đường cắt đít"
  },
  "captions": {
    "en": "Proper tip contact point for draw shot",
    "vi": "Điểm chạm đầu cơ đúng cho đường cắt đít"
  },
  "is_active": true,
  "created_at": "2026-07-17T00:00:00Z"
}
```

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | ID | Yes | MEDIA-NNNNNN |
| `term_id` | ID | Yes | Associated term |
| `type` | enum | Yes | image/video/animation/svg/audio |
| `role` | enum | Yes | primary/illustration/tutorial/diagram |
| `names` | JSONB | Yes | Multilingual names |
| `file_name` | string | Yes | Physical file name |
| `mime_type` | string | Yes | MIME type |
| `url` | string | Yes | Full URL |
| `thumbnail_url` | string | No | Thumbnail URL |
| `width` | integer | No | Pixel width |
| `height` | integer | No | Pixel height |
| `file_size` | integer | No | Bytes |
| `alt_text` | JSONB | Yes | Accessibility text |
| `captions` | JSONB | No | Display captions |
| `is_active` | boolean | Yes | Visibility |
| `created_at` | timestamp | Yes | Creation time |

### Role Values

| Role | Description |
|------|-------------|
| `primary` | Main hero image |
| `illustration` | Supporting visual |
| `tutorial` | Step-by-step visual |
| `diagram` | Technical diagram |

---

## 4. Database Schema

### PostgreSQL

```sql
CREATE TABLE media (
    id              VARCHAR(20) PRIMARY KEY,
    term_id         VARCHAR(20) NOT NULL REFERENCES terms(id),
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
    
    CONSTRAINT valid_media_type CHECK (type IN ('image', 'video', 'animation', 'svg', 'audio')),
    CONSTRAINT valid_media_role CHECK (role IN ('primary', 'illustration', 'tutorial', 'diagram'))
);

CREATE INDEX idx_media_term ON media(term_id);
CREATE INDEX idx_media_type ON media(type);
```

---

## 5. Related Documents

- [ID Standard](./id_standard.md)
- [Naming Convention](./naming.md)

---

**End of Document**
