# Story 008: 하트·목숨 표시

> **Epic**: jeis-adventure
> **Status**: Complete
> **Layer**: Presentation
> **Type**: UI
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-26

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 6 (하트 체력을 게임 화면 위쪽에 표시, 목숨은 체력과 구분해서 표시)

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (MVP 6, Player goal & fail state):*

- [ ] 체력은 하트 모양으로 게임 화면 위쪽에 표시된다
- [ ] 현재 체력만큼 꽉 찬 하트로, 나머지는 빈 하트로 보인다 (기본 3칸)
- [ ] 보너스 체력은 다른 색 하트로 구분해서 기본 하트 뒤에 붙는다
- [ ] 목숨은 체력과 구분해서 따로 표시한다 (숫자나 아이콘, 형식은 구현 시 제안)
- [ ] 체력이나 목숨이 바뀌면 신호로 즉시 표시가 바뀐다 (매 프레임 확인하지 않는다)
- [ ] 360×320 게임 화면에서 읽을 수 있는 크기이고 플레이 시야를 과하게 가리지 않는다
- [ ] 보너스가 늘어 하트가 최대 5개가 되어도 화면 밖으로 나가지 않는다
- [ ] 게임 오버로 초기화되면 표시도 처음 값으로 돌아간다

---

## Implementation Notes

- 스토리 002가 체력과 목숨이 바뀔 때 보내는 신호(현재 값, 최대 값)를 받아서 그린다. 표시 쪽이 값을 바꾸지 않는다
- 하트와 목숨 그림은 지금 임시 도형이어도 된다. 실제 도트 그림은 레벨 1 아트 단계(스토리 005)에서 만든다
- 현재 체력이 최대 체력(3)을 넘을 수 있다. 보너스 체력이다
- 하트 개수, 간격, 색, 위치는 코드에 박지 않고 씬 값이나 데이터 파일로 조정할 수 있게 한다
- Godot 4.7 UI 관련 API는 `docs/engine-reference/godot/modules/ui.md`를 확인한 뒤 쓴다

---

## Out of Scope

*Handled by neighbouring stories — do not implement here:*

- Story 002: 체력·목숨 값 자체와 신호
- Story 009: 보너스 체력 아이템
- Story 007: 게임 오버 화면과 메인 메뉴

---

## Files

- src/ui/health_hud.gd
- src/ui/health_hud.tscn
- src/layout/split_layout.tscn

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*`qa.level: minimal`: tests are waived, but a UI story's retained screenshot is not.*

**Story Type**: UI
**Required evidence**:
- 표시 상태마다 스크린샷 (체력 가득, 체력 감소, 보너스 체력 있음, 목숨 감소): `production/qa/evidence/story-008-health-lives-hud/`

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/jeis-adventure/story-002-health-fail-checkpoint.md`
- Unlocks: None

---

## Completion Notes
**Completed**: 2026-10-26
**Criteria**: 8/8 passing, each seen in a retained screenshot (`production/qa/evidence/story-008-health-lives-hud/` 01-07 and state-run.log)
**Deviations**: ADVISORY — bonus hearts differ from full hearts by colour only (ui-code.md colourblind rule; empty hearts now differ by shape). ADVISORY — "x %d" lives text is hardcoded, not localized (localization is out of scope in the brief). ADVISORY — default vector font will look softer than the pixel hearts at 2x scale (not verifiable on this monitor). ADVISORY — no null asserts on the HUD's exported node references. Art note for story 005 — the life icon reads like a coin. OUT OF SCOPE — changed files not in `## Files` are story 002's uncommitted work plus `health_hud.gd.uid` and the engine cache; commit the `.uid` file with its script
**Test Evidence**: waived at qa.level minimal (UI story: retained screenshots, see above)
**Reviewed by**: self, no independent review (QL-TEST-COVERAGE, LP-CODE-REVIEW skipped — Solo mode; godot-gdscript-specialist and godot-specialist ran engine-API checks during /dev-story)
