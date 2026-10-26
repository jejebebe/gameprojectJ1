# Story 003: 적 3종과 밟기·피격 규칙

> **Epic**: jeis-adventure
> **Status**: Ready
> **Layer**: Core
> **Type**: Integration
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: set by /dev-story when implementation begins

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

*Planned. `/dev-story` replaces this list with the files it changed.*

- src/enemies/enemy_base.gd
- src/enemies/enemy_a.tscn
- src/enemies/enemy_b.tscn
- src/enemies/enemy_c.tscn
- assets/data/enemies/enemy_stats.tres
- assets/art/enemies/ (스프라이트 시트)

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
