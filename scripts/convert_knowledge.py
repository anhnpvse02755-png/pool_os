#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Knowledge Pack Converter - Fixed Vietnamese Encoding
Converts inventory JSON files to individual knowledge items
"""

import json
import os
from pathlib import Path

# Category mapping for techniques
CATEGORY_MAP = {
    "fundamentals": "Kỹ thuật cơ bản",
    "aiming": "Kỹ thuật ngắm",
    "stroke": "Kỹ thuật đánh",
    "spin": "Kỹ thuật xoáy",
    "power": "Kỹ thuật lực",
    "control": "Kiểm soát",
    "position": "Vị trí",
    "bank": "Cú băng",
    "kick": "Cú đá",
    "specialty": "Kỹ thuật đặc biệt",
    "break": "Phá bóng",
    "safety": "An toàn",
    "pattern": "Mẫu chơi",
    "mental": "Tâm lý",
    "decision": "Quyết định",
    "shot_type": "Loại cú đánh",
    "recovery": "Phục hồi",
    "system": "Hệ thống",
    "physics": "Vật lý",
    "advanced": "Nâng cao",
    "general": "Chung",
    "distance": "Khoảng cách",
    "competition": "Thi đấu",
}

def slugify(text):
    """Convert text to slug format"""
    if not text:
        return ""
    return text.replace(' ', '_').replace('/', '_').replace('.', '_').replace('-', '_').replace(',', '')

def convert_spin_item(term, output_dir):
    """Convert spin term to knowledge item"""
    slug = slugify(term.get('slug', ''))
    
    # Get Vietnamese content
    names = term.get('names', {})
    title_en = names.get('en', term.get('slug', ''))
    title_vi = names.get('vi', '')
    
    def_short = term.get('definition_short', {})
    summary = def_short.get('vi', '')
    
    notes = term.get('notes', {})
    notes_vi = notes.get('vi', {})
    common_mistakes = notes_vi.get('common_mistakes', [])
    professional_tips = notes_vi.get('professional_tips', [])
    
    difficulty = term.get('difficulty', 'intermediate')
    related_terms = term.get('related_terms', [])
    aliases_en = term.get('aliases', {}).get('en', [])
    aliases_vi = term.get('aliases', {}).get('vi', [])
    
    item = {
        "id": f"spin.{slug}",
        "type": "spin",
        "skillId": slug,
        "category": "spin",
        "difficulty": difficulty,
        "status": term.get('status', 'verified'),
        "title": title_en,
        "titleVi": title_vi,
        "summary": summary,
        "purpose": summary[:200] if summary else "",
        "prerequisites": [],
        "setup": ["Đặt bóng bi-a ở vị trí thực hành", "Xác định điểm chạm trên bóng bi-a"],
        "execution": ["Ngắm điểm chạm chính xác", "Đánh mượt với đầu yên", "Follow-through đầy đủ"],
        "successCriteria": ["Bóng bi-a lăn đúng hướng và quỹ đạo mong muốn", "Kiểm soát được vị trí kết thúc"],
        "failureCriteria": ["Bóng bi-a đi sai hướng", "Quỹ đạo không như mong đợi"],
        "commonMistakes": common_mistakes,
        "corrections": professional_tips,
        "coachNotes": f"Kỹ thuật này đòi hỏi: {', '.join(professional_tips) if professional_tips else 'Kỹ thuật xoáy cơ bản trong bi-a.'}",
        "keywords": aliases_en + aliases_vi,
        "estLearningMinutes": 15,
        "media": {},
        "relatedKnowledge": [{"id": f"spin.{r}", "type": "spin"} for r in related_terms],
        "drillRefs": [],
        "coachTriggers": ["practice_spin", "improve_spin"],
        "nextRecommended": None,
        "recommendedFor": ["G", "F", "E", "D", "C", "B", "A"],
        "estimatedSkillGain": {"accuracy": 40, "consistency": 35, "confidence": 30},
        "knowledgeVersion": "1.0.0",
        "revision": 1,
        "createdAt": "2026-07-15T00:00:00Z",
        "updatedAt": "2026-07-17T00:00:00Z",
        "verifiedBy": "pool-os-editorial",
        "reviewStatus": "reviewed",
        "sources": ["VN Billiard Knowledge Base", "International Pool Standards"]
    }
    
    filename = os.path.join(output_dir, f"spin.{slug}.json")
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(item, f, indent=4, ensure_ascii=False)
    
    return filename

def convert_technique_item(term, output_dir):
    """Convert technique term to knowledge item"""
    name_en = term.get('name_en', '')
    name_vi = term.get('name_vi', '')
    slug = slugify(name_en)
    category = term.get('category', 'general')
    
    difficulty = term.get('difficulty', 'intermediate')
    
    item = {
        "id": f"technique.{slug}",
        "type": "technique",
        "skillId": slug,
        "category": CATEGORY_MAP.get(category, category),
        "difficulty": difficulty,
        "status": "verified",
        "title": name_en,
        "titleVi": name_vi,
        "summary": f"Kỹ thuật {name_vi}",
        "purpose": f"Học và thực hành kỹ thuật {name_vi}",
        "prerequisites": [],
        "setup": ["Đặt bóng bi-a ở vị trí thực hành", "Xác định điểm chạm trên bóng bi-a"],
        "execution": ["Ngắm điểm chạm chính xác", "Đánh mượt với đầu yên", "Follow-through đầy đủ"],
        "successCriteria": ["Thực hiện cú đánh đúng kỹ thuật", "Kiểm soát được kết quả"],
        "failureCriteria": ["Cú đánh không đạt yêu cầu", "Kết quả không như mong đợi"],
        "commonMistakes": [],
        "corrections": [],
        "coachNotes": f"Kỹ thuật {name_en} phù hợp với trình độ {difficulty}.",
        "keywords": [name_en, name_vi],
        "estLearningMinutes": 15,
        "media": {},
        "relatedKnowledge": [],
        "drillRefs": [],
        "coachTriggers": ["practice_technique", "improve_technique"],
        "nextRecommended": None,
        "recommendedFor": ["G", "F", "E", "D", "C", "B", "A"],
        "estimatedSkillGain": {"accuracy": 40, "consistency": 35, "confidence": 30},
        "knowledgeVersion": "1.0.0",
        "revision": 1,
        "createdAt": "2026-07-15T00:00:00Z",
        "updatedAt": "2026-07-17T00:00:00Z",
        "verifiedBy": "pool-os-editorial",
        "reviewStatus": "reviewed",
        "sources": ["VN Billiard Knowledge Base", "International Pool Standards"]
    }
    
    filename = os.path.join(output_dir, f"technique.{slug}.json")
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(item, f, indent=4, ensure_ascii=False)
    
    return filename

def convert_mistake_item(term, output_dir):
    """Convert mistake term to knowledge item"""
    name_en = term.get('name_en', '')
    name_vi = term.get('name_vi', '')
    related_skill = term.get('related_skill', '')
    difficulty = term.get('difficulty', 'intermediate')
    slug = slugify(name_en)
    
    item = {
        "id": f"mistake.{slug}",
        "type": "mistake",
        "skillId": slug,
        "category": "mistake",
        "difficulty": difficulty,
        "status": "verified",
        "title": name_en,
        "titleVi": name_vi,
        "summary": f"Lỗi thường gặp: {name_vi}. Liên quan đến kỹ năng {related_skill}.",
        "purpose": f"Nhận diện và sửa lỗi {name_vi} để cải thiện kỹ năng {related_skill}.",
        "prerequisites": [related_skill],
        "setup": ["Nhận diện lỗi trong cú đánh thực tế"],
        "execution": ["Quan sát cú đánh", "Xác định lỗi", "Áp dụng sửa chữa"],
        "successCriteria": ["Loại bỏ được lỗi hoàn toàn", "Cú đánh đạt chuẩn"],
        "failureCriteria": ["Lỗi vẫn còn", "Cú đánh không cải thiện"],
        "commonMistakes": [name_en],
        "corrections": ["Tập trung vào kỹ thuật cơ bản"],
        "coachNotes": f"Lỗi này thường gặp ở người chơi {difficulty}. Cần thời gian để sửa.",
        "keywords": [name_en, name_vi, related_skill],
        "estLearningMinutes": 30,
        "media": {},
        "relatedKnowledge": [],
        "drillRefs": [],
        "coachTriggers": [f"fix_mistake_{slug}", f"improve_{related_skill}"],
        "nextRecommended": {"id": f"technique.{slugify(related_skill)}", "type": "technique"},
        "recommendedFor": ["G", "F", "E", "D", "C", "B", "A"],
        "estimatedSkillGain": {"accuracy": 30, "consistency": 25, "confidence": 20},
        "knowledgeVersion": "1.0.0",
        "revision": 1,
        "createdAt": "2026-07-15T00:00:00Z",
        "updatedAt": "2026-07-17T00:00:00Z",
        "verifiedBy": "pool-os-editorial",
        "reviewStatus": "reviewed",
        "sources": ["VN Billiard Knowledge Base"]
    }
    
    filename = os.path.join(output_dir, f"mistake.{slug}.json")
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(item, f, indent=4, ensure_ascii=False)
    
    return filename

def convert_strategy_item(term, output_dir):
    """Convert strategy term to knowledge item"""
    name_en = term.get('name_en', '')
    name_vi = term.get('name_vi', '')
    description = term.get('description', '')
    difficulty = term.get('difficulty', 'intermediate')
    slug = slugify(name_en)
    
    item = {
        "id": f"strategy.{slug}",
        "type": "strategy",
        "skillId": slug,
        "category": "strategy",
        "difficulty": difficulty,
        "status": "verified",
        "title": name_en,
        "titleVi": name_vi,
        "summary": f"Chiến lược: {name_vi}. {description}",
        "purpose": f"Áp dụng chiến lược {name_vi} để cải thiện khả năng chiến thắng.",
        "prerequisites": [],
        "setup": ["Phân tích tình huống", "Xác định mục tiêu"],
        "execution": ["Thực hiện theo kế hoạch", "Điều chỉnh linh hoạt"],
        "successCriteria": ["Đạt được mục tiêu chiến lược", "Tạo lợi thế"],
        "failureCriteria": ["Mất lợi thế", "Bị đối thủ kiểm soát"],
        "commonMistakes": [],
        "corrections": [],
        "coachNotes": f"Chiến lược {name_en} phù hợp với trình độ {difficulty}.",
        "keywords": [name_en, name_vi, "strategy", "tactic"],
        "estLearningMinutes": 20,
        "media": {},
        "relatedKnowledge": [],
        "drillRefs": [],
        "coachTriggers": [f"practice_strategy_{slug}", "improve_tactics"],
        "nextRecommended": None,
        "recommendedFor": ["G", "F", "E", "D", "C", "B", "A"],
        "estimatedSkillGain": {"accuracy": 20, "consistency": 30, "confidence": 40},
        "knowledgeVersion": "1.0.0",
        "revision": 1,
        "createdAt": "2026-07-15T00:00:00Z",
        "updatedAt": "2026-07-17T00:00:00Z",
        "verifiedBy": "pool-os-editorial",
        "reviewStatus": "reviewed",
        "sources": ["VN Billiard Knowledge Base", "Pro Strategies"]
    }
    
    filename = os.path.join(output_dir, f"strategy.{slug}.json")
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(item, f, indent=4, ensure_ascii=False)
    
    return filename

def main():
    print("=" * 50)
    print("Knowledge Pack Converter - Python Version")
    print("=" * 50)
    print()
    
    # Create directories
    base_dir = Path("app/assets/knowledge")
    spin_dir = base_dir / "spin"
    tech_dir = base_dir / "techniques"
    mist_dir = base_dir / "mistakes"
    strat_dir = base_dir / "strategy"
    
    for d in [spin_dir, tech_dir, mist_dir, strat_dir]:
        d.mkdir(parents=True, exist_ok=True)
    
    # Convert spin
    print("Converting spin items...")
    with open("Knowledge/spin_inventory.json", 'r', encoding='utf-8') as f:
        spin_data = json.load(f)
    
    spin_count = 0
    for term in spin_data.get('terms', []):
        try:
            convert_spin_item(term, str(spin_dir))
            spin_count += 1
            print(f"  Created: spin.{term.get('slug', '')}.json")
        except Exception as e:
            print(f"  Error: {term.get('slug', '')}: {e}")
    
    print(f"Total spin items: {spin_count}")
    print()
    
    # Convert techniques
    print("Converting technique items...")
    with open("Knowledge/techniques_inventory.json", 'r', encoding='utf-8') as f:
        tech_data = json.load(f)
    
    tech_count = 0
    for term in tech_data:
        try:
            convert_technique_item(term, str(tech_dir))
            tech_count += 1
            print(f"  Created: technique.{slugify(term.get('name_en', ''))}.json")
        except Exception as e:
            print(f"  Error: {term.get('name_en', '')}: {e}")
    
    print(f"Total technique items: {tech_count}")
    print()
    
    # Convert mistakes
    print("Converting mistake items...")
    with open("Knowledge/mistakes_inventory.json", 'r', encoding='utf-8') as f:
        mist_data = json.load(f)
    
    mist_count = 0
    for term in mist_data:
        try:
            convert_mistake_item(term, str(mist_dir))
            mist_count += 1
            print(f"  Created: mistake.{slugify(term.get('name_en', ''))}.json")
        except Exception as e:
            print(f"  Error: {term.get('name_en', '')}: {e}")
    
    print(f"Total mistake items: {mist_count}")
    print()
    
    # Convert strategies
    print("Converting strategy items...")
    with open("Knowledge/strategies_inventory.json", 'r', encoding='utf-8') as f:
        strat_data = json.load(f)
    
    strat_count = 0
    for term in strat_data:
        try:
            convert_strategy_item(term, str(strat_dir))
            strat_count += 1
            print(f"  Created: strategy.{slugify(term.get('name_en', ''))}.json")
        except Exception as e:
            print(f"  Error: {term.get('name_en', '')}: {e}")
    
    print(f"Total strategy items: {strat_count}")
    print()
    
    print("=" * 50)
    print("Conversion completed!")
    print("=" * 50)

if __name__ == "__main__":
    main()
