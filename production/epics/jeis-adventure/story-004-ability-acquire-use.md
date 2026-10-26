# Story 004: 능력 획득과 사용 (능력 3종)

> **Epic**: jeis-adventure
> **Status**: Ready
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: set by /dev-story when implementation begins

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

---

## Implementation Notes

**구현 전에 사용자와 정할 것 (브리프에 없음):**
- 능력을 얻는 방식 (밟으면 얻는지, 다른 방식인지)
- 한 번에 가질 수 있는 능력 수와 교체 규칙
- 실패해서 재시작하면 능력을 유지하는지
- 능력 3종의 구체적인 내용과, 어느 적이 어느 능력을 주는지

정해지면 이 스토리에 반영한다. 크게 바뀌면 `/quick-design`으로 한 장짜리 명세를 먼저 만든다. Godot 4.7 API는 `docs/engine-reference/godot/`를 확인한 뒤 쓴다.

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 003: 적 자체의 행동
- Story 005: 능력으로 풀 레벨 구간의 실제 배치
- 4번째 이상의 능력 (브리프의 범위 밖)

---

## Files

*Planned. `/dev-story` replaces this list with the files it changed.*

- src/abilities/ability_base.gd
- src/abilities/ability_a.gd
- src/abilities/ability_b.gd
- src/abilities/ability_c.gd
- src/player/ability_holder.gd
- assets/data/abilities/ability_stats.tres
- assets/art/effects/ (스프라이트 시트)

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
