# Story 009: 보너스 체력 아이템

> **Epic**: jeis-adventure
> **Status**: In Progress
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-27

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 6 (보너스 체력: 아이템을 먹으면 하트 +1, 최대 2개, 죽으면 사라짐)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (MVP 6, Player goal & fail state):*

- [ ] 레벨에 보너스 체력 아이템을 놓을 수 있다
- [ ] 플레이어가 아이템에 닿으면 체력이 +1이 되고 아이템은 사라진다
- [ ] 보너스는 최대 2개까지이고, 이미 최대면 아이템은 먹히지 않고 그대로 남는다 (제안: 아이템이 낭비되지 않게)
- [ ] 체력이 기본값 3을 넘는 부분은 피격 시 먼저 줄어든다
- [ ] 죽으면(체력 0 또는 추락) 보너스가 사라지고 기본 체력 3으로 다시 시작한다
- [ ] 회복량과 최대 개수는 코드에 박지 않고 데이터 파일로 조정할 수 있다

---

## Implementation Notes

**정해진 규칙 (사용자 결정 2026-10-27, `production/direction/decision-log.md`):**
- 아이템 리스폰: 죽으면 재시작 체크포인트보다 오른쪽의 이미 먹은 아이템은 제자리에 다시 나타난다. 지나온 왼쪽 구간의 아이템은 그대로 없다. 게임 오버 때는 모든 아이템이 처음 상태로 돌아간다 (몬스터와 같은 규칙)
- 아이템의 모양과 획득 연출은 임시 도형이면 된다 (완성 아트는 컨셉 샘플 이후 본격 제작 단계)
- 몬스터와 나무 벽의 복구는 `RespawnManager`의 `enemies`·`burnables` 배열과 `reset_to_start()`·`reset()` 방식으로 이미 있다. 아이템도 같은 방식으로 맞춘다

- 보너스 체력은 별도 값이 아니라 현재 체력이 기본 최대(3)를 넘는 만큼이다. 체력 컴포넌트는 스토리 002에 있다
- 회복량(+1)과 최대 보너스 개수(2)는 `assets/data/health_stats.tres`에 필드를 추가해서 둔다
- 죽으면 보너스가 사라지는 동작은 스토리 002의 재시작 체력(3)으로 이미 처리된다. 이 스토리는 그것이 아이템 흐름과 함께 맞는지 확인한다
- Godot 4.7 API는 `docs/engine-reference/godot/`를 확인한 뒤 쓴다

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 002: 체력, 목숨, 재시작 자체
- Story 008: 하트 표시 (보너스 하트의 색 구분 포함)
- Story 005: 아이템을 레벨의 어디에 놓을지

---

## Files

- src/items/bonus_heart.gd
- src/items/bonus_heart.tscn
- src/player/health_stats.gd
- assets/data/health_stats.tres
- src/player/health_component.gd
- src/systems/respawn_manager.gd
- src/ui/health_hud.gd
- src/levels/test_gray_box.tscn

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*`qa.level: minimal`: tests are waived (advisory).*

**Story Type**: Integration
**Required evidence**:
- 권고: `tests/integration/health/bonus_heart_test.gd` 또는 플레이 테스트 기록

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/jeis-adventure/story-002-health-fail-checkpoint.md`
- Unlocks: None
