# Story 013: 월드 1.5배 맞춤 (판정·레벨·물리) + 글꼴·정리

> **Epic**: jeis-adventure
> **Status**: Complete
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-29

## Context

**GDD**: `design/game-brief.md`, `design/levels/level-layouts.md`, `design/art/art-bible.md` §5, §7, §8
**Requirement**: 아트를 1.5배로 키운 뒤 판정과 레벨이 예전 크기 그대로라 맞지 않음 → 월드 전체를 그림과 같은 1.5배로 맞춘다 (사용자 결정 2026-10-29 "월드 전체 1.5배"). 함께: 보스방 골 깃발 위치, 한글 글꼴 Galmuri11, 옛 그림 정리.

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**Engine**: Godot 4.7 | **Risk**: HIGH (게임 전체 수치가 바뀜)

---

## Acceptance Criteria

- [ ] 제이·적·보스·소품의 판정이 그림 크기에 맞는다 (예전 판정의 1.5배)
- [ ] 레벨 1~3의 모든 위치·크기·간격이 1.5배로 바뀌고, 바닥선과 화면 높이 안에서 자연스럽게 보인다
- [ ] 이동 속도·점프·중력·적과 보스의 움직임·능력(불덩이·높이 점프·활공)이 1.5배 월드에서 예전과 같은 느낌(같은 시간, 1.5배 거리)으로 동작한다
- [ ] 레벨 1~3을 처음부터 끝까지 진행할 수 있고(막히는 곳 없음), 보스를 쓰러뜨릴 수 있다
- [ ] 보스방 골 깃발이 보스와 겹치지 않는다
- [ ] 메뉴·HUD 한글이 Galmuri11 도트 글꼴로 보이고, 라이선스 파일이 함께 들어간다
- [ ] 쓰지 않는 옛 임시 그림 파일이 정리된다

---

## Implementation Notes

- 거리 단위 값(위치, 크기, 판정, 속도, 가속도, 중력, 점프 속도, 이동 범위)은 ×1.5. 시간 단위 값(예고 시간, 무적 시간, 쿨다운)은 그대로.
- 세로는 바닥선(y≈280)을 기준으로 위쪽 높이만 ×1.5 (화면 높이 320 안에 들어오게). 넘치면 카메라 세로 추적을 켠다.
- 사용자는 이 스토리의 `src/`·`assets/` 수정을 시작 시 승인했다 (2026-10-29).

## Out of Scope

- 새 레벨·볼륨 추가, 난이도 재설계 (이번에는 비율만 맞춤), 소리

## Files

- assets/data/abilities/fireball.tres
- assets/data/abilities/glide.tres
- assets/data/camera_stats.tres
- assets/data/enemies/boss_stats.tres
- assets/data/enemies/flyer_stats.tres
- assets/data/enemies/jumper_stats.tres
- assets/data/enemies/walker_stats.tres
- assets/data/player_stats.tres
- src/abilities/fireball.tscn
- src/abilities/fireball_ability.gd
- src/abilities/glide_ability.gd
- src/abilities/high_jump_ability.gd
- src/enemies/boss.tscn
- src/enemies/boss_spike.tscn
- src/enemies/boss_stats.gd
- src/enemies/enemy_stats.gd
- src/enemies/flyer.tscn
- src/enemies/jumper.tscn
- src/enemies/walker.tscn
- src/items/bonus_heart.tscn
- src/levels/boss_arena.gd
- src/levels/burnable.tscn
- src/levels/checkpoint.tscn
- src/levels/level_01.tscn
- src/levels/level_02.tscn
- src/levels/level_03.tscn
- src/levels/level_goal.tscn
- src/levels/spike.tscn
- src/player/camera_stats.gd
- src/player/look_ahead_camera.gd
- src/player/player.gd
- src/player/player.tscn
- src/player/player_stats.gd
- src/ui/health_hud.tscn
- src/ui/menu_layer.tscn
- assets/data/ui_theme.tres
- assets/art/fonts/Galmuri11.ttf
- assets/art/fonts/Galmuri11-Bold.ttf
- assets/art/fonts/OFL.txt
- design/levels/level-layouts.md

## Test Evidence

**Story Type**: Integration — 실행 기록과 스크린샷 `production/qa/evidence/story-013-world-scale/`

## Dependencies

- Depends on: story-010, story-011, story-012

---

## Completion Notes
**Completed**: 2026-10-29
**Criteria**: 7/7 passing. Level 1 traversed end to end by a bot (31 s, god mode); levels 2-3 obstacle by obstacle (glide pits, high-jump cliffs, fireball walls); boss fight: gate, 3 patterns, fireball hit, restore on death, 3 stomps, clear message (Galmuri11) — `production/qa/evidence/story-013-world-scale/run-log.txt` + screenshots
**Deviations**: ADVISORY — boss arena (~495 px) is wider than the view: a two-target camera follows Jei and the boss, but when they stand at opposite ends the boss can be off-screen (user accepted 2026-10-29 "지금대로 두기"); burnable walls can be jumped over with high jump (no high jump is available before them in level 1); level 2-3 not run end to end in one go (bot is weak at pits); level-1 first-play labels still not implemented
**Test Evidence**: `production/qa/evidence/story-013-world-scale/` (tests waived at qa.level minimal)
**Reviewed by**: self, no independent review (Solo mode)
