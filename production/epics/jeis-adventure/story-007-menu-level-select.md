# Story 007: 최소 메뉴와 레벨 선택

> **Epic**: jeis-adventure
> **Status**: Ready
> **Layer**: Presentation
> **Type**: UI
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: set by /dev-story when implementation begins

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 7 (Build order 7)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (MVP 7, Out of scope):*

- [ ] 게임을 켜면 메뉴가 열리고, 거기서 레벨을 시작할 수 있다
- [ ] 게임 중 하단 조작 영역의 메뉴 버튼으로 메뉴를 열 수 있다
- [ ] 메뉴에서 계속하기와 레벨 선택을 할 수 있다
- [ ] 레벨 선택에서 레벨 1~3을 골라 시작할 수 있다. 세이브 시스템이 없으므로 레벨 잠금은 없다
- [ ] 모든 터치 대상은 8~12세 손가락 기준으로 크게 만든다. 마우스 호버에 의존하지 않는다
- [ ] 광고, 결제, 개인정보 입력 화면이 없다 (브리프의 범위 밖)

---

## Implementation Notes

- 메뉴는 하단 조작 영역에서 열린다. 화면 분할 레이아웃은 Story 001이 만든 것을 그대로 쓴다
- 메뉴 항목이 더 필요하면 브리프의 "최소 메뉴" 범위를 넘지 않는 선에서 사용자와 정한다
- Godot 4.7 UI 관련 API는 `docs/engine-reference/godot/modules/ui.md`를 확인한 뒤 쓴다

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 005: 레벨 자체
- Story 006: 클리어 연출
- 설정 화면, 업적, 상점 (브리프의 범위 밖)

---

## Files

*Planned. `/dev-story` replaces this list with the files it changed.*

- src/ui/main_menu.tscn
- src/ui/main_menu.gd
- src/ui/pause_menu.tscn
- src/ui/level_select.tscn
- src/ui/level_select.gd

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*`qa.level: minimal`: tests are waived, but a UI story's retained screenshot is not.*

**Story Type**: UI
**Required evidence**:
- 건드린 화면마다 스크린샷 1장 이상: `production/qa/evidence/story-007/`

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/jeis-adventure/story-001-split-layout-move-jump.md`, `production/epics/jeis-adventure/story-005-levels-1-3.md`
- Unlocks: None
