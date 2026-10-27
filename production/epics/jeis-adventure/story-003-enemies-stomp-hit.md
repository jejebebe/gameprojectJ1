# Story 003: 적 3종과 밟기·피격 규칙

> **Epic**: jeis-adventure
> **Status**: Complete
> **Layer**: Core
> **Type**: Integration
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-26

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 2

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (MVP 2, Player goal & fail state, Art & audio direction):*

- [ ] 적 3종이 있고, 종류마다 행동이 서로 구분된다
- [ ] 적을 위에서 밟으면 적이 쓰러진다
- [ ] 적과 옆이나 아래에서 닿으면 플레이어가 피격하고, 체력이 줄어든다 (Story 002의 체력 시스템 사용)
- [ ] 피격 직후 일정 시간 동안은 다시 피격하지 않는 보호 시간이 있다. 길이는 데이터 파일로 조정할 수 있다 (브리프의 "아이가 막혀서 포기하지 않게" 규칙에서 도출)
- [ ] 각 적은 스프라이트 시트 애니메이션을 가진다
- [ ] 적의 이동 속도 등 수치는 데이터 파일로 조정할 수 있다

---

## Implementation Notes

- 적 3종의 구체적인 행동(걷기, 날기 등)은 브리프에 없다. 구현 전에 사용자와 정한다
- 능력을 주는 적이 어느 것인지는 Story 004에서 정한다
- Godot 4.7 API는 `docs/engine-reference/godot/`를 확인한 뒤 쓴다

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 004: 적에게서 능력을 얻는 동작
- Story 006: 보스

---

## Files

- src/enemies/enemy_stats.gd
- src/enemies/enemy.gd
- src/enemies/walker.gd
- src/enemies/jumper.gd
- src/enemies/flyer.gd
- src/enemies/walker.tscn
- src/enemies/jumper.tscn
- src/enemies/flyer.tscn
- assets/data/enemies/walker_stats.tres
- assets/data/enemies/jumper_stats.tres
- assets/data/enemies/flyer_stats.tres
- assets/art/enemies/walker_sheet.png
- assets/art/enemies/jumper_sheet.png
- assets/art/enemies/flyer_sheet.png
- src/player/player.gd
- src/player/player.tscn
- src/player/player_stats.gd
- assets/data/player_stats.tres
- src/player/health_component.gd
- src/player/health_stats.gd
- assets/data/health_stats.tres
- src/levels/spike.tscn
- src/levels/test_gray_box.tscn

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*`qa.level: minimal`: tests are waived (advisory).*

**Story Type**: Integration
**Required evidence**:
- 권고: `tests/integration/enemies/enemies_stomp_hit_test.gd` 또는 플레이 테스트 기록

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/jeis-adventure/story-002-health-fail-checkpoint.md`
- Unlocks: `production/epics/jeis-adventure/story-004-ability-acquire-use.md`

---

## Completion Notes
**Completed**: 2026-10-26
**Criteria**: 6/6 passing, all observed in scripted runs of the build (`production/qa/evidence/story-003-enemies-stomp-hit/behaviour-run.log`, screenshots 01-04); not yet played by the user
**Deviations**: ADVISORY — added `stomp_tolerance` (6 px, in each enemy .tres) because Area2D overlaps lag one physics frame; not in the story, set it to 0 for the strict rule. ADVISORY — an overlap with a second enemy that starts one frame after a bounce still counts as contact damage (rare). ADVISORY — placeholder enemy sheets are 16x16 and small on screen (real art in story 005). OUT OF SCOPE — changed files not in `## Files` are story 002/008 uncommitted work plus engine-generated `.uid`/`.import` files; commit those with their sources. Side effect handled: the player moved to its own collision layer (layer 3); spike and pit detection re-checked and still work
**Test Evidence**: waived at qa.level minimal (behaviour log and screenshots 01-04 kept in `production/qa/evidence/story-003-enemies-stomp-hit/`)
**Reviewed by**: self, no independent review (QL-TEST-COVERAGE, LP-CODE-REVIEW skipped — Solo mode; godot-gdscript-specialist ran an engine-API check during /dev-story, findings were sent back once and fixed)
