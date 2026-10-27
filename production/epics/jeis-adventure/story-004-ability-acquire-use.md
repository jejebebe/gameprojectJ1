# Story 004: 능력 획득과 사용 (능력 3종)

> **Epic**: jeis-adventure
> **Status**: Complete
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-27

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 3 (Build order 3: 적 1종 + 능력 1종으로 먼저 루프 증명)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (MVP 3, Core loop, Art & audio direction):*

- [ ] 적에게서 능력을 획득할 수 있다 (획득 방식은 아래 "구현 전에 정할 것" 참고)
- [ ] 능력 3종이 있고, 하단 조작 영역의 능력 버튼으로 사용한다
- [ ] 능력을 써서 막힌 구간이나 적을 돌파할 수 있다
- [ ] 지금 가진 능력이 무엇인지 화면에 보인다
- [ ] 능력 사용 이펙트는 스프라이트 시트 애니메이션이다
- [ ] 능력 수치(지속 시간, 위력 등)는 데이터 파일로 조정할 수 있다
- [ ] 먼저 능력 1종으로 "획득 → 사용" 루프가 재미있는지 확인한 뒤 나머지 2종을 추가한다 (Build order 3, 5)
- [ ] 죽으면 재시작 체크포인트보다 오른쪽(진행 방향)에 있던 쓰러진 몬스터가 처음 자리에 되살아난다. 체크포인트보다 왼쪽(지나온 구간) 몬스터는 그대로 없다. 게임 오버 때는 모든 몬스터와 타 버린 나무 벽이 처음 상태로 돌아간다 (사용자 결정 2026-10-27: 능력이 필요한 구간에서 진행이 막히지 않게)

---

## Implementation Notes

**정해진 규칙 (사용자 결정 2026-10-27, `production/direction/decision-log.md`):**
- 획득: 적을 밟아 쓰러뜨리면 그 적의 능력을 자동으로 얻는다
- 보유: 한 번에 1개. 새 능력을 얻으면 교체된다. 죽으면(체력 0 또는 추락) 사라진다
- 짝: 걷는 적 = **불꽃 던지기** (바라보는 방향으로 불꽃을 쏘아 적을 쓰러뜨리고 태울 수 있는 장애물을 태움), 점프하는 적 = **높이 점프** (땅에서 ABILITY를 누르면 크게 뜀), 나는 적 = **활공** (공중에서 ABILITY를 누르고 있으면 천천히 떨어짐)
- 사용: 하단 조작 영역의 ABILITY 버튼 하나 (세 능력 모두)
  - 불꽃: 누를 때마다 한 발, 대기시간 있음 (1차 완료)
  - 높이 점프: 땅에 있을 때 ABILITY를 누르면 보통 점프의 약 1.8배(약 145px) 높이로 뜀. 착지해야 다시 쓸 수 있음 (사용자 결정 2026-10-27)
  - 활공: 공중에서 ABILITY를 누르고 있는 동안 떨어지는 속도가 크게 줄어듦(예: 초당 60px), 좌우 이동은 그대로, 시간 제한 없음 (사용자 결정 2026-10-27)
  - 세부 수치(속도, 높이, 대기시간)는 나중 밸런스 테스트 때 조정한다 (사용자 결정 2026-10-27)
- 구현 순서: **1차 = 능력 시스템 + 불꽃 + 현재 능력 표시 + 태울 수 있는 장애물(테스트 레벨)**, 직접 해 보고 재미를 확인한 뒤 **2차 = 높이 점프, 활공**. 1차가 끝나도 이 스토리는 닫지 않는다

Godot 4.7 API는 `docs/engine-reference/godot/`를 확인한 뒤 쓴다.

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 003: 적 자체의 행동
- Story 005: 능력으로 풀 레벨 구간의 실제 배치
- 4번째 이상의 능력 (브리프의 범위 밖)

---

## Files

- src/abilities/ability.gd
- src/abilities/sheet_frames.gd
- src/abilities/high_jump_ability.gd
- src/abilities/glide_ability.gd
- src/abilities/fireball_ability.gd
- src/abilities/fireball.gd
- src/abilities/fireball.tscn
- src/player/ability_holder.gd
- src/player/player.gd
- src/player/player.tscn
- src/enemies/enemy.gd
- src/enemies/enemy_stats.gd
- assets/data/abilities/fireball.tres
- assets/data/abilities/high_jump.tres
- assets/data/abilities/glide.tres
- assets/data/enemies/walker_stats.tres
- assets/data/enemies/jumper_stats.tres
- assets/data/enemies/flyer_stats.tres
- assets/art/abilities/fireball_fly_sheet.png
- assets/art/abilities/fireball_burst_sheet.png
- assets/art/abilities/high_jump_dust_sheet.png
- assets/art/abilities/glide_canopy_sheet.png
- src/systems/respawn_manager.gd
- src/ui/touch_controls.gd
- src/ui/touch_controls.tscn
- src/ui/health_hud.gd
- src/ui/health_hud.tscn
- src/layout/split_layout.gd
- src/layout/split_layout.tscn
- src/levels/burnable.gd
- src/levels/burnable.tscn
- src/levels/test_gray_box.tscn

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*`qa.level: minimal`: tests are waived (advisory).*

**Story Type**: Integration
**Required evidence**:
- 권고: `tests/integration/abilities/ability_acquire_use_test.gd` 또는 플레이 테스트 기록

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/jeis-adventure/story-003-enemies-stomp-hit.md`
- Unlocks: `production/epics/jeis-adventure/story-005-levels-1-3.md`, `production/epics/jeis-adventure/story-006-boss.md`

---

## Completion Notes
**Completed**: 2026-10-27
**Criteria**: 8/8 passing, all observed in scripted runs of the build (`production/qa/evidence/story-004-ability-acquire-use/` pass1-run.log, pass2-run.log, respawn-run.log, screenshots 01-07 and 09); the fireball loop was confirmed fun by the user
**Deviations**: ADVISORY — the burnable wall is 96 px (not the planned 64 px, which a jump clears); a player on platform C can still jump over it; re-place it in story 005. ADVISORY — jump + glide falls ~8 px short of the 190 px pit if the jump is released early; tune in the balance test (user decision 2026-10-27). ADVISORY — test level extended to 2200 px; ability effect sheets are 8-16 px flat placeholders (real art in story 005). ADVISORY — minor engine-check notes (data sanity asserts, per-frame node lookup in glide) left as notes. OUT OF SCOPE — changed files not in `## Files` are story 002/003 uncommitted work plus 27 engine-generated `.uid`/`.import` files; commit those with their sources
**Test Evidence**: waived at qa.level minimal (behaviour logs and screenshots kept in `production/qa/evidence/story-004-ability-acquire-use/`)
**Reviewed by**: self, no independent review (QL-TEST-COVERAGE, LP-CODE-REVIEW skipped — Solo mode; godot-gdscript-specialist ran engine-API checks for both passes, findings were sent back once and fixed)
