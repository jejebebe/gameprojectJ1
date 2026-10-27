# Story 002: 체력, 목숨, 실패, 체크포인트 재시작

> **Epic**: jeis-adventure
> **Status**: Complete
> **Layer**: Core
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-26

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 6 (체력·목숨·게임 오버·체크포인트 부분. 하트 표시와 보너스 체력 아이템은 별도 스토리). 2026-10-26 기획 변경으로 인수 조건 교체

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (MVP 6, Player goal & fail state):*

- [ ] 플레이어는 목숨 1개당 체력 3을 가지고, 피격하면 체력이 줄어든다
- [ ] 체력이 0이 되면 마지막 체크포인트에서 다시 시작하고, 목숨 -1, 체력은 기본값 3이 된다
- [ ] 아래로 추락하면 체력과 관계없이 목숨 -1이 되고, 마지막 체크포인트에서 체력 3으로 다시 시작한다
- [ ] 시작 목숨은 3이다. 목숨이 0이 되면 진행을 초기화하고 게임 오버를 알린다. 메인 화면(스토리 007)이 생기기 전까지는 레벨을 처음부터 다시 시작한다
- [ ] 체크포인트는 깃발의 X좌표를 지나면 켜진다 (공중으로 지나가도 켜짐)
- [ ] 새 체크포인트가 켜지면 이전 깃발은 화면에서 사라지고 다시 켜지지 않는다
- [ ] 같은 순간에 두 번 실패해도 (예: 체력 0과 추락이 겹침) 목숨은 1만 줄어든다
- [ ] 최대 체력, 시작 목숨 등 수치는 코드에 박지 않고 데이터 파일로 조정할 수 있다

---

## Implementation Notes

- 체크포인트를 얼마나 촘촘히 놓을지는 레벨 스토리(005)에서 정한다. 여기서는 동작만 만든다
- 첫 구현(연속 실패 보정 방식)이 이미 있다. 보정 코드(`assist_*` 값, 연속 실패 카운터)는 제거하고, 같은 순간 실패를 한 번만 세는 장치는 유지한다
- 하트·목숨 표시 스토리가 쓸 수 있도록 체력과 목숨이 바뀔 때 신호를 보낸다 (현재 값, 최대 값)
- 의존성 주입을 쓰고, 싱글턴에 직접 기대지 않는다 (단위 테스트 가능하게)
- Godot 4.7 API는 `docs/engine-reference/godot/`를 확인한 뒤 쓴다

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 003: 적이 피해를 주는 규칙 (이 스토리는 받는 쪽만 만든다)
- Story 005: 체크포인트의 실제 배치
- Story 007: 게임 오버 후 메인 화면, 실패 후 보이는 메뉴
- 새 스토리 (하트·목숨 표시): 화면에 하트와 목숨을 그리는 것
- 새 스토리 (보너스 체력 아이템): 아이템과 보너스 하트

---

## Files

- src/systems/respawn_manager.gd
- src/player/health_stats.gd
- assets/data/health_stats.tres
- src/player/health_component.gd
- src/levels/checkpoint.gd
- src/levels/checkpoint.tscn
- src/levels/kill_zone.gd
- src/levels/spike.gd
- src/levels/spike.tscn
- src/player/player.gd
- src/player/player.tscn
- src/levels/test_gray_box.tscn

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*`qa.level: minimal`: tests are waived (advisory).*

**Story Type**: Logic
**Required evidence**:
- 권고: `tests/unit/health/health_checkpoint_test.gd`

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/jeis-adventure/story-001-split-layout-move-jump.md`
- Unlocks: `production/epics/jeis-adventure/story-003-enemies-stomp-hit.md`

---

## Completion Notes
**Completed**: 2026-10-26
**Criteria**: 8/8 passing, all observed in a scripted run of the build (`production/qa/evidence/story-002-health-fail-checkpoint/behaviour-run.log`); not yet played by the user
**Deviations**: ADVISORY — respawn health is read from RespawnManager's stats, not HealthComponent's (same .tres today, nothing enforces it). ADVISORY — HealthComponent has no assert for an unassigned stats resource. OUT OF SCOPE — engine-generated `.uid` files and `.godot/global_script_class_cache.cfg` are not in `## Files`; commit the `.uid` files with their scripts. For later stories: story 005 puts flags on solid ground clear of pits; story 008's HUD sees lives 0 briefly before the game-over reset
**Test Evidence**: waived at qa.level minimal (behaviour log and screenshots 01-03 kept in `production/qa/evidence/story-002-health-fail-checkpoint/`)
**Reviewed by**: self, no independent review (QL-TEST-COVERAGE, LP-CODE-REVIEW skipped — Solo mode; godot-gdscript-specialist ran an engine-API check during /dev-story)
