# Story 005: 레벨 3개

> **Epic**: jeis-adventure
> **Status**: Ready
> **Layer**: Feature
> **Type**: Visual/Feel
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: set by /dev-story when implementation begins

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 4 (Build order 4–5)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (MVP 4, Player goal & fail state, Build order 4–5):*

- [ ] 레벨 3개가 있고, 순서대로 끝까지 플레이할 수 있다
- [ ] 각 레벨의 끝 지점에 도달하면 다음 레벨로 넘어간다
- [ ] 한 레벨을 5분 안팎에 끝낼 수 있다 (시험 플레이로 측정한다)
- [ ] 체크포인트가 촘촘하게 놓여 있다 (간격 기준은 시험 플레이로 정한다)
- [ ] 정밀한 점프를 연속으로 요구하는 구간이 없다
- [ ] 각 레벨에 능력에 따라 풀이가 달라지는 구간이 1곳 이상 있다
- [ ] 레벨은 간단한 임시 도트 타일(단색 블록 수준)로 구성한다. 완성 아트는 컨셉 샘플 이후 본격 제작 단계에서 만든다 (사용자 결정 2026-10-27)
- [ ] 세 레벨 모두 세로 분할 화면과 하단 조작 영역에서 플레이된다
- [ ] 임시 도트 타일이 에디터 창에서 흐려지지 않고 선명하게 보인다 (스토리 001에서 이월: 정수 배율, Nearest 필터. 완성 아트의 선명도는 본격 제작 단계에서 다시 확인)

---

## Implementation Notes

- 이 스토리가 가장 크다. 레벨 1을 아트까지 먼저 끝내고 2·3으로 넘어가는 순서를 지킨다
- 레벨의 구체적인 구성은 브리프에 없다. 레벨 설계는 `level-designer`가 맡고, 정할 때 사용자 확인을 받는다
- 레벨 1을 완성하면 시험 플레이로 난이도를 확인하고, 그 결과를 2·3에 반영한다
- 타일맵과 도트 아트는 `docs/engine-reference/godot/` 확인 후 구현한다

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 004: 능력 자체의 구현
- Story 006: 보스 전투
- Story 007: 레벨 선택 화면
- 4번째 이상의 레벨 (브리프의 범위 밖)

---

## Files

*Planned. `/dev-story` replaces this list with the files it changed.*

- src/levels/level_01.tscn
- src/levels/level_02.tscn
- src/levels/level_03.tscn
- src/levels/level_goal.gd
- assets/art/tiles/ (타일셋)
- assets/art/backgrounds/

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*`qa.level: minimal`: tests are waived, but a Visual/Feel story's retained screenshot is not.*

**Story Type**: Visual/Feel
**Required evidence**:
- 레벨마다 실행 화면 스크린샷: `production/qa/evidence/story-005/`
- 서명 기록: `production/qa/evidence/story-005-evidence.md` (시험 플레이 시간 기록 포함)

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/jeis-adventure/story-001-split-layout-move-jump.md`, `production/epics/jeis-adventure/story-002-health-fail-checkpoint.md`, `production/epics/jeis-adventure/story-004-ability-acquire-use.md`
- Unlocks: `production/epics/jeis-adventure/story-006-boss.md`, `production/epics/jeis-adventure/story-007-menu-level-select.md`
