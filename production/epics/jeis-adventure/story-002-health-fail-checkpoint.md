# Story 002: 체력, 실패, 체크포인트 재시작

> **Epic**: jeis-adventure
> **Status**: Ready
> **Layer**: Core
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: set by /dev-story when implementation begins

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 6 (+ Player goal & fail state의 난이도 규칙)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (MVP 6, Player goal & fail state):*

- [ ] 플레이어는 체력을 가지고, 피격하면 체력이 줄어든다
- [ ] 체력이 0이 되면 실패로 처리된다
- [ ] 구덩이에 추락해도 실패로 처리된다
- [ ] 실패하면 마지막으로 지난 체크포인트에서 다시 시작한다. 목숨 제한이 없어서 게임 오버로 끝나지 않는다
- [ ] 체크포인트를 지나면 재시작 위치가 갱신된다
- [ ] 같은 구간에서 연속으로 실패하면 재시작할 때 체력을 더 채워 준다. 연속 실패 횟수와 보충량은 데이터 파일로 조정할 수 있다
- [ ] 체력 최대치 등 수치는 코드에 박지 않고 데이터 파일로 조정할 수 있다

---

## Implementation Notes

- 체크포인트를 얼마나 촘촘히 놓을지는 레벨 스토리(005)에서 정한다. 여기서는 동작만 만든다
- 의존성 주입을 쓰고, 싱글턴에 직접 기대지 않는다 (단위 테스트 가능하게)
- Godot 4.7 API는 `docs/engine-reference/godot/`를 확인한 뒤 쓴다

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 003: 적이 피해를 주는 규칙 (이 스토리는 받는 쪽만 만든다)
- Story 005: 체크포인트의 실제 배치
- Story 007: 실패 후 보이는 메뉴

---

## Files

*Planned. `/dev-story` replaces this list with the files it changed.*

- src/player/health_component.gd
- src/levels/checkpoint.gd
- src/systems/respawn_manager.gd
- assets/data/difficulty_assist.tres
- tests/unit/health/health_checkpoint_test.gd

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
