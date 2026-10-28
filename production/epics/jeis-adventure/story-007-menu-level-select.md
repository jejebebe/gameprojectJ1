# Story 007: 최소 메뉴와 레벨 선택

> **Epic**: jeis-adventure
> **Status**: Complete
> **Layer**: Presentation
> **Type**: UI
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-28

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

- src/ui/menu_layer.gd
- src/ui/menu_layer.tscn
- src/ui/touch_controls.gd
- src/ui/touch_controls.tscn
- src/layout/split_layout.gd
- src/layout/split_layout.tscn
- src/ui/menu_layer.gd.uid

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

---

## Completion Notes
**Completed**: 2026-10-28
**Criteria**: 6/6 passing. Observed in a scripted run with real mouse/touch events and screenshots (`production/qa/evidence/story-007-menu-level-select/`): main menu at launch, `MENU` opens the pause menu (held touch released), continue, level select 1-3 without locks, back to main menu, clear and game over return to the main menu, large buttons, no ads/purchases/personal-data screens
**Deviations**: ADVISORY — one `menu_layer.tscn` holds all three menus instead of the planned `main_menu`/`pause_menu`/`level_select` files; `touch_controls.tscn` changed too (MENU button 64 px tall). ADVISORY — menu texts are in the scenes, not localised (`.claude/rules/ui-code.md`), deferred to full production. ADVISORY — Korean text uses the system font fallback and was not tried on a phone; the focus ring from `grab_focus()` may show on touch-only devices; real device touch not tried (first phone build). The engine check found one real bug (MENU and 계속하기 overlap closed the menu at once), fixed: the menu opens on release
**Test Evidence**: screenshots 01-07, run log and stamp under `production/qa/evidence/story-007-menu-level-select/` (tests waived at qa.level minimal)
**Reviewed by**: self, no independent review (QL-TEST-COVERAGE, LP-CODE-REVIEW skipped — Solo mode; godot-gdscript-specialist ran an engine-API check)
