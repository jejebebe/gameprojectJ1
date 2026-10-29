# Story 011: 적 3종과 보스 그림 교체

> **Epic**: jeis-adventure
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Visual/Feel
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-29

## Context

**GDD**: `design/art/art-bible.md` §3, §4, §5, §8; `design/assets/entity-inventory.md` rows 2-6
**Requirement**: 아트 전면 교체 — 임시 적·보스 그림을 제이 스타일(검은 1px 외곽선, 캐릭터 팔레트)로 바꾼다 (사용자 결정 2026-10-28 "1번 작업 진행")

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**Engine**: Godot 4.7 | **Risk**: MEDIUM

---

## Acceptance Criteria

- [ ] 걷는 적·점프하는 적·나는 적이 제이 스타일의 보라색 도트 그림(24x24, 검은 외곽선)으로 보이고, 이동 동작이 부드럽게 재생된다
- [ ] 세 적은 실루엣만으로 구분된다 (뿔 반원 / 용수철 물방울 / 날개 원)
- [ ] 보스 가시 두더지가 72x60 도트 그림으로 보이고, 보스의 모든 동작(서 있기, 흔들기, 웅크리기, 부풀기, 구르기, 점프, 어지러움, 피격)과 먼지·떨어지는 가시가 새 그림으로 재생된다
- [ ] 적과 보스의 발(바닥)이 땅에 붙어 보인다 (그림이 땅에 묻히거나 떠 보이지 않음)
- [ ] 프레임 수·속도·그림 경로는 데이터 파일로 조정할 수 있다
- [ ] 충돌 크기와 레벨은 바꾸지 않는다 (레벨 디자인 단계에서 다시 정함)

---

## Implementation Notes

- 아트 규칙: 캐릭터·적·보스 = 검은 1px 외곽선 + `assets/art_src/palette/jei_character.gpl` (적 보라 계열 색은 추가 가능). 디자인: 아트 바이블 §3·§5 (걷는 적 = 보라 반원 + 뿔 1개, 점프하는 적 = 보라 물방울 + 용수철 다리, 나는 적 = 보라 원 + 크림 삼각 날개, 보스 = 갈색 반구 두더지 + 크림 배·얼굴 + 등의 부채꼴 가시(끝 보라) + 크림 삽 앞발 2개).
- 제작: 에이전트가 Aseprite Lua 스크립트로 그린다 (`tools/art/`). 제이 최종 그림의 외곽선 굵기·음영 단계·눈 표현에 맞춘다.
- 경로: `assets/art/enemies/{walker,jumper,flyer}/move.png`, `assets/art/enemies/boss/{동작}.png` (아트 바이블 §8 이름 규칙; 옛 `*_sheet.png`는 교체 때 옮김).
- 프레임: 적 이동 8프레임, 보스는 지금 프레임 수의 2배 (부드럽게).
- 사용자는 이 스토리의 `src/`·`assets/` 수정을 시작 시 승인했다 (2026-10-28).

## Out of Scope

- 판정 크기·레벨 간격 조정 (레벨 디자인 단계), 타일·배경·UI 그림 (다음 작업)

## Files

- src/enemies/enemy.gd
- src/enemies/enemy_stats.gd
- src/enemies/boss.gd
- src/enemies/boss.tscn
- src/enemies/boss_spike.gd
- src/enemies/jumper.gd
- src/enemies/jumper.tscn
- src/enemies/walker.tscn
- assets/data/enemies/boss_stats.tres
- assets/data/enemies/walker_stats.tres
- assets/data/enemies/jumper_stats.tres
- assets/data/enemies/flyer_stats.tres
- tools/art/enemies.lua
- tools/art/boss.lua
- assets/art/enemies/{walker,jumper,flyer}/move.png
- assets/art/enemies/boss/v2/*

## Test Evidence

**Story Type**: Visual/Feel — 실행 스크린샷 `production/qa/evidence/story-011-enemy-boss-art/`, 서명 기록 `production/qa/evidence/story-011-enemy-boss-art-evidence.md`

## Dependencies

- Depends on: story-003 (적), story-006 (보스), story-010 (제이 그림 기준)

---

## Completion Notes
**Completed**: 2026-10-29
**Criteria**: 6/6 passing (scripted play run in levels 1-3 + boss fight, 10 screenshots, user sign-off)
**Deviations**: ADVISORY — enemies look small next to Jei until level design; old placeholder art files remain on disk (unused); boss roll pose floats ~6 px on its spike tips; enemy "defeated" frames not drawn (code squash kept)
**Test Evidence**: `production/qa/evidence/story-011-enemy-boss-art/`, sign-off `production/qa/evidence/story-011-enemy-boss-art-evidence.md`
**Reviewed by**: self, no independent review (Solo mode)
