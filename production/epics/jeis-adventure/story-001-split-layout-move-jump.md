# Story 001: 세로 분할 화면과 이동·점프

> **Epic**: jeis-adventure
> **Status**: Ready
> **Layer**: Foundation
> **Type**: Visual/Feel
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: set by /dev-story when implementation begins

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 1 (Build order 1–2)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (MVP 1, Player goal & fail state, Build order 1–2):*

- [ ] 화면이 세로로 고정되고, 상단 절반에 게임 화면, 하단 절반에 조작 버튼(이동·점프·능력)과 메뉴 버튼이 표시된다
- [ ] 하단 조작 영역의 버튼이 게임 화면을 가리지 않는다
- [ ] 터치로 좌우 이동과 점프가 된다
- [ ] 키보드(PC)로도 같은 이동·점프가 된다 (보조 입력)
- [ ] 점프는 버튼을 누른 시간에 따라 높이가 달라진다 (가변 점프 높이)
- [ ] 이동 속도, 점프 높이 등 수치는 코드에 박지 않고 데이터 파일로 조정할 수 있다
- [ ] 정밀한 점프를 연속으로 요구하지 않는 회색 상자 테스트 레벨에서 이동·점프를 해 볼 수 있다
- [ ] 도트가 흐려지지 않고 선명하게 보인다 (정수 배율, Nearest 필터)
- [ ] 8~12세 아이 1~2명이 직접 해 보고, 난이도와 버튼 크기에 대한 관찰 기록을 `production/qa/evidence/`에 남긴다

---

## Implementation Notes

- 기준 해상도 360×640 (상단 360×320 게임, 하단 360×320 조작), PC 창 720×1280. 설정은 `project.godot`에 이미 있다
- Godot 4.7 API는 쓰기 전에 `docs/engine-reference/godot/`를 확인한다. 같은 참조 문서의 4.7 목록에 `VirtualJoystick`이 나오지만, 쓸 수 있는지와 사용법은 거기서 확인한 뒤 정한다
- 터치 버튼은 8~12세 손가락 기준으로 크게 만들고, 마우스 호버에 의존하지 않는다

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 002: 체력, 실패, 체크포인트
- Story 004: 능력 사용 버튼의 동작 (버튼 자리만 만든다)
- Story 007: 메뉴 버튼이 여는 메뉴 내용 (버튼 자리만 만든다)

---

## Files

*Planned. `/dev-story` replaces this list with the files it changed.*

- src/layout/split_layout.tscn
- src/layout/split_layout.gd
- src/ui/touch_controls.tscn
- src/ui/touch_controls.gd
- src/player/player.tscn
- src/player/player.gd
- assets/data/player_stats.tres
- src/levels/test_gray_box.tscn

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*`qa.level: minimal`: tests are waived, but a Visual/Feel story's retained screenshot is not.*

**Story Type**: Visual/Feel
**Required evidence**:
- 720×1280 창에서 찍은 레이아웃 스크린샷: `production/qa/evidence/story-001/`
- 서명 기록: `production/qa/evidence/story-001-evidence.md` (아이 시험 플레이 관찰 포함)

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: None
- Unlocks: `production/epics/jeis-adventure/story-002-health-fail-checkpoint.md`, `production/epics/jeis-adventure/story-007-menu-level-select.md`
