# Billiard Knowledge Module (BKM) - Media System

## Version 1.0
**Last Updated:** July 2026
**Status:** Production Specification

---

## 1. Media System Overview

### 1.1 Design Principles

| Principle | Description | Implementation |
|-----------|-------------|----------------|
| **Accessibility First** | All media accessible | Alt text required |
| **Performance Optimized** | Fast loading | Lazy loading, CDN |
| **Format Standardized** | Consistent formats | Configurable presets |
| **Versioned Assets** | Track changes | Version field |
| **Offline Capable** | Local storage | SQLite sync |

### 1.2 Media Types Supported

| Type | Extensions | Use Case |
|------|------------|----------|
| **Image** | jpg, jpeg, png, webp | Photos, diagrams |
| **Video** | mp4, webm, mov | Demonstrations, tutorials |
| **Animation** | gif, webp, lottie | Ball paths, techniques |
| **SVG** | svg | Diagrams, icons, diagrams |
| **Audio** | mp3, m4a, ogg | Pronunciation, audio guides |
| **Document** | pdf | Rulebooks, references |

---

## 2. Folder Structure

### 2.1 Root Directory Organization

```
media/
│
├── assets/                      # Source/original files
│   ├── images/
│   │   ├── terms/
│   │   │   ├── draw-shot/
│   │   │   │   ├── original.jpg
│   │   │   │   └── source/
│   │   ├── equipment/
│   │   ├── players/
│   │   ├── tables/
│   │   └── venues/
│   │
│   ├── videos/
│   │   ├── demonstrations/
│   │   ├── tutorials/
│   │   ├── drills/
│   │   └── tournaments/
│   │
│   ├── animations/
│   │   ├── ball-paths/
│   │   ├── technique-steps/
│   │   └── diagrams/
│   │
│   ├── svg/
│   │   ├── icons/
│   │   ├── diagrams/
│   │   └── icons/
│   │
│   └── audio/
│       ├── pronunciation/
│       └── explanations/
│
├── processed/                   # Optimized versions
│   ├── images/
│   │   ├── 1920w/
│   │   ├── 1280w/
│   │   ├── 640w/
│   │   └── thumbnails/
│   │
│   ├── videos/
│   │   ├── 1080p/
│   │   ├── 720p/
│   │   ├── 480p/
│   │   └── previews/
│   │
│   ├── animations/
│   │   ├── full/
│   │   └── thumbnails/
│   │
│   └── audio/
│       ├── 128kbps/
│       └── 64kbps/
│
├── cdn/                        # CDN-ready structure
│   ├── i/
│   ├── v/
│   ├── a/
│   └── d/
│
└── thumbnails/
    ├── small/
    ├── medium/
    └── large/
```

### 2.2 CDN Structure

```
CDN Root: https://cdn.pool-os.com

Images:
https://cdn.pool-os.com/i/{size}/{term-slug}/{filename}.{ext}

Videos:
https://cdn.pool-os.com/v/{quality}/{term-slug}/{filename}.{ext}

Animations:
https://cdn.pool-os.com/a/{term-slug}/{filename}.{ext}

Audio:
https://cdn.pool-os.com/d/{term-slug}/{filename}.{ext}

Thumbnails:
https://cdn.pool-os.com/t/{size}/{filename}.{ext}
```

---

## 3. Media Metadata Schema

### 3.1 Core Media Entity

```json
{
  "id": "770e8400-e29b-41d4-a716-446655440001",
  "type": "video",
  "status": "ready",
  
  "file": {
    "original_name": "draw-shot-demonstration.mp4",
    "filename": "draw-shot-demo-abc123.mp4",
    "mime_type": "video/mp4",
    "size_bytes": 52428800,
    "duration_seconds": 45.5,
    "checksum": "sha256:abc123..."
  },
  
  "storage": {
    "local_path": "/media/processed/videos/1080p/draw-shot-demo-abc123.mp4",
    "cdn_url": "https://cdn.pool-os.com/v/1080p/draw-shot/draw-shot-demo-abc123.mp4",
    "backup_url": "s3://pool-os-backup/media/v/..."
  },
  
  "dimensions": {
    "width": 1920,
    "height": 1080,
    "aspect_ratio": "16:9",
    "frame_rate": 30
  },
  
  "versions": [
    {
      "quality": "1080p",
      "url": "https://cdn.pool-os.com/v/1080p/draw-shot/draw-shot-demo-abc123.mp4",
      "size_bytes": 52428800
    },
    {
      "quality": "720p",
      "url": "https://cdn.pool-os.com/v/720p/draw-shot/draw-shot-demo-abc123.mp4",
      "size_bytes": 26214400
    },
    {
      "quality": "480p",
      "url": "https://cdn.pool-os.com/v/480p/draw-shot/draw-shot-demo-abc123.mp4",
      "size_bytes": 10485760
    }
  ],
  
  "thumbnail": {
    "url": "https://cdn.pool-os.com/t/medium/draw-shot-demo-abc123.jpg",
    "sprite_url": "https://cdn.pool-os.com/t/sprite/draw-shot-demo-abc123.jpg",
    "video_preview_url": "https://cdn.pool-os.com/v/preview/draw-shot/draw-shot-demo-abc123.webp"
  },
  
  "content": {
    "alt_text": {
      "en": "Video demonstration of a draw shot technique showing the cue ball striking below center and reversing direction after contact",
      "vi": "Video minh họa kỹ thuật úp bóng cho thấy bóng cơ được đánh phía dưới tâm và quay ngược lại sau khi chạm"
    },
    "caption": {
      "en": "Draw Shot Demonstration",
      "vi": "Minh Họa Đòn Úp Bóng"
    },
    "description": {
      "en": "This video demonstrates the proper technique for executing a draw shot in pool...",
      "vi": "Video này minh họa kỹ thuật đúng để thực hiện đòn úp bóng trong bida lỗ..."
    }
  },
  
  "attribution": {
    "source": "Pool OS Original",
    "author": "Coach Name",
    "license": "CC BY 4.0",
    "copyright_notice": "© 2026 Pool OS"
  },
  
  "context": {
    "term_id": "term-uuid-here",
    "term_slug": "draw-shot",
    "usage_type": "demonstration",
    "is_primary": true,
    "sort_order": 1
  },
  
  "statistics": {
    "view_count": 15420,
    "download_count": 234,
    "like_count": 567
  },
  
  "metadata": {
    "created_at": "2026-07-01T00:00:00Z",
    "updated_at": "2026-07-15T10:30:00Z",
    "processed_at": "2026-07-01T01:00:00Z",
    "created_by": "user-uuid"
  }
}
```

### 3.2 Image-Specific Metadata

```json
{
  "type": "image",
  "image_metadata": {
    "camera": {
      "make": "Canon",
      "model": "EOS R5",
      "settings": {
        "focal_length": "50mm",
        "aperture": "f/2.8",
        "iso": 400
      }
    },
    "artwork": {
      "is_illustration": true,
      "illustration_style": "diagram",
      "has_annotations": true,
      "color_scheme": "full-color"
    },
    "colors": {
      "dominant": "#4A90D9",
      "palette": ["#4A90D9", "#333333", "#FFFFFF"]
    }
  }
}
```

### 3.3 Video-Specific Metadata

```json
{
  "type": "video",
  "video_metadata": {
    "encoding": {
      "codec": "h264",
      "bitrate": "5000kbps",
      "audio_codec": "aac",
      "audio_bitrate": "128kbps"
    },
    "content": {
      "has_subtitles": true,
      "subtitle_languages": ["en", "vi"],
      "has_chapters": true,
      "chapter_markers": [
        { "time": 0, "title": "Introduction" },
        { "time": 30, "title": "Setup" },
        { "time": 60, "title": "Execution" },
        { "time": 120, "title": "Common Mistakes" }
      ],
      "has_transcript": true
    },
    "segments": [
      { "start": 0, "end": 30, "title": "Introduction" },
      { "start": 30, "end": 60, "title": "Setup" }
    ]
  }
}
```

---

## 4. Asset Naming Conventions

### 4.1 Naming Format

```
{type}-{context}-{identifier}-{variant}.{ext}

Examples:
├── images-draw-shot-001-full.jpg
├── images-draw-shot-001-thumb.jpg
├── videos-draw-shot-demo-1080p.mp4
├── animations-ball-path-spin-001.gif
├── svg-diagram-aiming-001.svg
└── audio-pronunciation-draw-shot-en.mp3
```

### 4.2 Naming Rules

| Rule | Description | Example |
|------|-------------|---------|
| **Lowercase** | All lowercase | `draw-shot-demo.mp4` |
| **Hyphens** | Words separated by hyphens | `draw-shot` |
| **Descriptive** | Clear, descriptive names | `draw-shot-demo.mp4` |
| **Versioned** | Include version if applicable | `draw-shot-v2.mp4` |
| **No Spaces** | Never use spaces | ❌ `draw shot.mp4` |
| **Unique IDs** | Include unique identifier | `draw-shot-001.mp4` |

### 4.3 Term-Specific Folders

```
media/
└── terms/
    └── {term-slug}/
        ├── images/
        │   ├── {term-slug}-diagram-001.svg
        │   ├── {term-slug}-setup-001.jpg
        │   ├── {term-slug}-result-001.jpg
        │   └── {term-slug}-variation-001.jpg
        │
        ├── videos/
        │   ├── {term-slug}-demo-main.mp4
        │   ├── {term-slug}-demo-variation.mp4
        │   └── {term-slug}-mistakes.mp4
        │
        ├── animations/
        │   ├── {term-slug}-path-basic.gif
        │   ├── {term-slug}-path-advanced.gif
        │   └── {term-slug}-steps.lottie
        │
        └── audio/
            ├── {term-slug}-pron-en.mp3
            └── {term-slug}-pron-vi.mp3
```

---

## 5. Resolution Standards

### 5.1 Image Resolutions

| Size Name | Width | Height | Use Case |
|-----------|-------|--------|----------|
| **Original** | Variable | Variable | Source files |
| **4K** | 3840 | 2160 | Hero images, high-quality displays |
| **2K** | 2560 | 1440 | Large displays |
| **1080p** | 1920 | 1080 | Standard HD |
| **720p** | 1280 | 720 | Smaller displays, mobile |
| **480p** | 854 | 480 | Low bandwidth |
| **Thumbnail** | 320 | 240 | Lists, previews |
| **Icon** | 64 | 64 | UI icons |

### 5.2 Image Processing Presets

```json
{
  "presets": {
    "hero": {
      "width": 1920,
      "height": 1080,
      "format": "webp",
      "quality": 85,
      "fit": "cover"
    },
    "content": {
      "width": 1280,
      "height": 720,
      "format": "webp",
      "quality": 80,
      "fit": "contain"
    },
    "thumbnail": {
      "width": 320,
      "height": 240,
      "format": "jpg",
      "quality": 75,
      "fit": "cover"
    },
    "icon": {
      "width": 64,
      "height": 64,
      "format": "png",
      "quality": 90,
      "fit": "contain"
    }
  }
}
```

### 5.3 Video Resolutions

| Quality | Width | Height | Bitrate | Use Case |
|---------|-------|--------|---------|----------|
| **1080p** | 1920 | 1080 | 5 Mbps | High quality |
| **720p** | 1280 | 720 | 2.5 Mbps | Standard |
| **480p** | 854 | 480 | 1 Mbps | Mobile/Low bandwidth |
| **360p** | 640 | 360 | 500 Kbps | Very low bandwidth |
| **Preview** | 320 | 180 | 100 Kbps | GIF/WebP preview |

---

## 6. Video Format Standards

### 6.1 Video Encoding Specifications

| Specification | Standard | Premium | Mobile |
|--------------|----------|---------|--------|
| **Container** | MP4 | MP4 | MP4/WebM |
| **Codec** | H.264 | H.265/HEVC | VP9 |
| **Resolution** | 1920×1080 | 1920×1080 | 1280×720 |
| **Frame Rate** | 30 fps | 60 fps | 30 fps |
| **Bitrate** | 5 Mbps | 8 Mbps | 2.5 Mbps |
| **Audio Codec** | AAC-LC | AAC-LC | AAC-LC |
| **Audio Bitrate** | 128 kbps | 192 kbps | 128 kbps |
| **Audio Channels** | Stereo | Stereo | Stereo |

### 6.2 Video Processing Pipeline

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         VIDEO PROCESSING PIPELINE                              │
└─────────────────────────────────────────────────────────────────────────────┘

Source Upload
     │
     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ STAGE 1: Validation                                                             │
│ • File format check                                                            │
│ • Size limits (max 500MB)                                                     │
│ • Duration limits (max 10 min)                                                 │
│ • Codec detection                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ STAGE 2: Transcoding                                                            │
│                                                                              │
│ Source ──► 1080p H.264 ──► 720p H.264 ──► 480p H.264                        │
│            (5 Mbps)     (2.5 Mbps)    (1 Mbps)                               │
│                │              │              │                                 │
│                ▼              ▼              ▼                                 │
│            Poster Frame   Poster Frame   Poster Frame                          │
│                │              │              │                                 │
│                ▼              ▼              ▼                                 │
│            WebP Preview   WebP Preview   WebP Preview                          │
└─────────────────────────────────────────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ STAGE 3: Storage & CDN                                                          │
│ • Upload to object storage (S3/GCS)                                            │
│ • Generate signed CDN URLs                                                     │
│ • Update database records                                                     │
└─────────────────────────────────────────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ STAGE 4: Thumbnail Generation                                                   │
│ • Extract frames at 0s, 25%, 50%, 75%                                         │
│ • Generate sprite sheet for seeking                                           │
│ • Create animated WebP preview                                                │
└─────────────────────────────────────────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ COMPLETE                                                                        │
│ • All versions available                                                       │
│ • CDN cached                                                                  │
│ • Ready for delivery                                                           │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 7. Animation Standards

### 7.1 Animation Types

| Type | Format | Max Size | Use Case |
|------|--------|----------|----------|
| **Ball Path** | Lottie, WebP, GIF | 2 MB | Trajectory animations |
| **Technique Steps** | Lottie | 1 MB | Step-by-step |
| **Diagram** | SVG | 100 KB | Static diagrams |
| **Interactive** | Lottie + JSON | 500 KB | Interactive elements |

### 7.2 Animation Specifications

```json
{
  "animation": {
    "ball_path": {
      "format": "webp",
      "max_fps": 30,
      "max_duration_seconds": 10,
      "max_file_size_kb": 500,
      "loop": true,
      "transparent_background": true
    },
    "technique_steps": {
      "format": "lottie",
      "max_fps": 60,
      "has_controls": true,
      "interactive": false
    },
    "diagram": {
      "format": "svg",
      "max_width": 1920,
      "max_height": 1080,
      "optimized": true
    }
  }
}
```

---

## 8. Thumbnail Specifications

### 8.1 Thumbnail Types

| Type | Size | Aspect Ratio | Use Case |
|------|------|--------------|----------|
| **Video Poster** | 1920×1080 | 16:9 | Video thumbnail |
| **Video Sprite** | Variable×90 | 16:9 | Seeking preview |
| **Image Preview** | 640×480 | 4:3 | Image lightbox |
| **Term Card** | 400×300 | 4:3 | Search results |
| **Category** | 800×600 | 4:3 | Category pages |

### 8.2 Thumbnail Generation Rules

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ THUMBNAIL GENERATION RULES                                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│ VIDEO THUMBNAILS                                                              │
│ • Extract frame at 10% of duration                                           │
│ • Fallback: frame at 0s if <10% unavailable                                  │
│ • Apply slight blur for text overlay area                                    │
│ • Add play button overlay for video thumbnails                                │
│                                                                              │
│ IMAGE THUMBNAILS                                                              │
│ • Smart crop to target aspect ratio                                          │
│ • Focus on center of image                                                    │
│ • Fallback: top-left crop if center is low-contrast                           │
│                                                                              │
│ ANIMATION THUMBNAILS                                                          │
│ • Extract first frame as static thumbnail                                     │
│ • Add animation indicator badge                                              │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 9. Alt Text Requirements

### 9.1 Alt Text Standards

| Image Type | Required | Example |
|------------|----------|---------|
| **Informative** | Full description | "Video showing proper draw shot technique with cue striking below center" |
| **Decorative** | Empty alt="" | Pure decorative borders |
| **Functional** | Describe function | "Pool OS logo - returns to home page" |
| **Complex** | Extended description | "Diagram showing 5-step draw shot technique with angle measurements" |
| **Text in Image** | Same text | All visible text repeated |

### 9.2 Alt Text Template

```json
{
  "alt_text_templates": {
    "shot_demonstration": {
      "en": "{video|Photo} showing {technique_name} technique demonstrating {specific_action}",
      "vi": "{video|Ảnh} minh họa kỹ thuật {technique_name} cho thấy {specific_action}"
    },
    "equipment": {
      "en": "{equipment_type} - {brand} {model} used for {purpose}",
      "vi": "{equipment_type} - {brand} {model} dùng để {purpose}"
    },
    "diagram": {
      "en": "Diagram illustrating {concept}: {key_elements}",
      "vi": "Sơ đồ minh họa {concept}: {key_elements}"
    },
    "player": {
      "en": "Professional pool player {name} demonstrating {action}",
      "vi": "Vận động viên bida lỗ chuyên nghiệp {name} minh họa {action}"
    }
  }
}
```

---

## 10. Accessibility Guidelines

### 10.1 WCAG 2.1 AA Compliance

| Requirement | Implementation |
|-------------|---------------|
| **Alt Text** | Required for all images |
| **Video Captions** | Required for all videos |
| **Audio Descriptions** | Required for instructional videos |
| **Color Contrast** | Minimum 4.5:1 for text |
| **Focus Indicators** | Visible focus states |
| **Keyboard Navigation** | All controls accessible |

### 10.2 Media Accessibility Checklist

```markdown
## Image Accessibility
- [ ] Alt text written for all images
- [ ] Complex images have extended descriptions
- [ ] Text in images is readable
- [ ] No information conveyed by color alone
- [ ] Animated GIFs can be paused

## Video Accessibility
- [ ] Captions provided (EN)
- [ ] Captions provided (VI)
- [ ] Audio description track available
- [ ] Transcript available
- [ ] Video player keyboard accessible
- [ ] No autoplay without user consent

## Animation Accessibility
- [ ] Can be paused/stopped
- [ ] No flashing content >3 times/second
- [ ] Loop can be disabled
- [ ] Alternative static version available
```

---

## 11. CDN Considerations

### 11.1 CDN Configuration

```json
{
  "cdn": {
    "provider": "cloudflare",
    "zone": "pool-os.com",
    "assets_subdomain": "cdn.pool-os.com",
    
    "cache_rules": {
      "images": {
        "ttl": "1 year",
        "stale_while_revalidate": true
      },
      "videos": {
        "ttl": "1 year",
        "private": false
      },
      "animations": {
        "ttl": "1 year",
        "stale_while_revalidate": true
      }
    },
    
    "transformations": {
      "enabled": true,
      "signed_urls": true,
      "url_signing_key": "${CDN_SIGNING_KEY}"
    },
    
    "restrictions": {
      "hotlinking_allowed": false,
      "referrer_whitelist": ["pool-os.com", "*.pool-os.com"]
    }
  }
}
```

### 11.2 Image CDN Transformations

```
CDN URL with transformations:

https://cdn.pool-os.com/i/draw-shot/diagram.jpg
  ?w=800                           # Width
  &h=600                           # Height
  &fit=crop                        # Resize mode
  &f=center                        # Focal point
  &q=80                            # Quality
  &fm=webp                         # Format
  &blur=0                          # Blur radius
  &sharpen=1                       # Sharpen
```

---

## 12. Lazy Loading Design

### 12.1 Lazy Loading Implementation

```dart
// Flutter Lazy Loading Implementation
class LazyMediaLoader extends StatelessWidget {
  final String mediaUrl;
  final MediaType type;
  final String? thumbnailUrl;
  
  @override
  Widget build(BuildContext context) {
    return switch (type) {
      MediaType.image => CachedNetworkImage(
        imageUrl: mediaUrl,
        placeholder: (context, url) => _buildPlaceholder(),
        fadeInDuration: Duration(milliseconds: 300),
      ),
      
      MediaType.video => VideoPlayer(
        initial: VideoPlayerValue(
          thumbnailUrl: thumbnailUrl,
          videoUrl: mediaUrl,
        ),
        lazyLoad: true,
        intersectionObserver: true,
      ),
      
      MediaType.animation => Lottie.network(
        mediaUrl,
        placeholder: _buildAnimationPlaceholder(),
        onLoaded: (composition) {
          // Enable controls after load
        },
      ),
    };
  }
}
```

### 12.2 Intersection Observer Setup

```javascript
// JavaScript Intersection Observer for web
const observerOptions = {
  root: null,
  rootMargin: '100px', // Load before visible
  threshold: 0.01
};

const lazyLoadObserver = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      const mediaElement = entry.target;
      
      // Load actual media
      if (mediaElement.dataset.src) {
        mediaElement.src = mediaElement.dataset.src;
      }
      
      // Load poster/thumbnail first
      if (mediaElement.dataset.poster) {
        mediaElement.poster = mediaElement.dataset.poster;
      }
      
      // Unobserve after loading
      lazyLoadObserver.unobserve(mediaElement);
    }
  });
}, observerOptions);
```

---

## 13. Appendix

### 13.1 File Size Limits

| Type | Max File Size | Recommended |
|------|--------------|-------------|
| **Image** | 20 MB | < 2 MB |
| **Video** | 500 MB | < 100 MB |
| **Animation** | 10 MB | < 2 MB |
| **Audio** | 50 MB | < 10 MB |
| **Document** | 50 MB | < 10 MB |

### 13.2 Supported Formats Matrix

| Type | JPEG | PNG | WebP | GIF | SVG | MP4 | WebM | Lottie |
|------|------|-----|------|-----|-----|-----|------|--------|
| **Photo** | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Diagram** | ✅ | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ |
| **Animation** | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ | ✅ |
| **Video** | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ |
| **Icon** | ❌ | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ |

### 13.3 Related Documents

- [BKM Database Schema](./03_Database.md)
- [BKM JSON Spec](./04_JSON_Spec.md)
- [BKM Architecture](./02_Architecture.md)

---

**End of Document**
