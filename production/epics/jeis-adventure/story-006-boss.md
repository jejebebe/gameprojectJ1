# Story 006: 보스 1개

> **Epic**: jeis-adventure
> **Status**: Ready
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: set by /dev-story when implementation begins

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 5 (Build order 6)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (MVP 5, Player goal & fail state):*

- [ ] 레벨 3을 지나면 보스전이 시작된다
- [ ] 보스의 공격 패턴은 2~3개이다
- [ ] 각 패턴은 시작 전에 알아볼 수 있는 예고 동작이 있다 (브리프의 "아이가 막혀서 포기하지 않게" 규칙에서 도출)
- [ ] 보스를 쓰러뜨리면 클리어 상태가 되고, 플레이어에게 알려진다
- [ ] 보스전에서 실패하면 보스 앞의 체크포인트에서 다시 시작한다
- [ ] 보스는 스프라이트 시트 애니메이션과 이펙트를 가진다
- [ ] 보스의 체력, 패턴 간격 등 수치는 데이터 파일로 조정할 수 있다

---

## Implementation Notes

- 보스의 모습과 패턴 내용은 브리프에 없다. 구현 전에 사용자와 정한다
- 보스 앞 체크포인트는 Story 002의 체크포인트 기능을 쓴다
- Godot 4.7 API는 `docs/engine-reference/godot/`를 확인한 뒤 쓴다

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 005: 레벨 1~3 자체
- Story 007: 클리어 후 메뉴 흐름 (이 스토리는 클리어 상태까지만)
- 클리어 이후 스토리 컷신 (브리프의 범위 밖)

---

## Files

*Planned. `/dev-story` replaces this list with the files it changed.*

- src/enemies/boss.tscn
- src/enemies/boss.gd
- assets/data/enemies/boss_stats.tres
- assets/art/enemies/boss/ (스프라이트 시트)

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*`qa.level: minimal`: tests are waived (advisory).*

**Story Type**: Integration
**Required evidence**:
- 권고: `tests/integration/boss/boss_fight_test.gd` 또는 플레이 테스트 기록

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/jeis-adventure/story-004-ability-acquire-use.md`, `production/epics/jeis-adventure/story-005-levels-1-3.md`
- Unlocks: None
