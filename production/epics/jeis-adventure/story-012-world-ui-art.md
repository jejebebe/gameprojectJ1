# Story 012: 타일·소품·배경·UI 그림 교체

> **Epic**: jeis-adventure
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Visual/Feel
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-29

## Context

**GDD**: `design/art/art-bible.md` §2, §3, §4, §6, §7, §8; `design/assets/entity-inventory.md` rows 7-19, UI screens, HUD
**Requirement**: 아트 전면 교체 3단계 — 회색 임시 바닥·블록·소품·배경·HUD·메뉴를 Cat Isle 파스텔 스타일로 바꾼다 (사용자 결정 2026-10-29 "진행해줘")

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**Engine**: Godot 4.7 | **Risk**: MEDIUM

---

## Acceptance Criteria

- [ ] 바닥(돌 부두)과 떠 있는 블록(청록 기와)이 도트 타일 그림으로 보이고, 크기가 다른 블록도 깨지지 않는다
- [ ] 가시·불타는 나무벽·체크포인트(꺼짐/켜짐)·골 깃발·보너스 하트·보스방 문이 도트 그림으로 보인다
- [ ] 레벨 1~3과 보스방에 각자 다른 배경(하늘·구름·먼 풍경·항구 건물)이 깔리고, 카메라가 움직일 때 겹겹이 다른 속도로 움직인다
- [ ] 배경은 외곽선 없는 파스텔이고 게임 요소(제이·적·발판·가시)가 배경보다 또렷하다 (아트 바이블 원칙 1)
- [ ] HUD 하트(찬/빈/보너스)와 목숨 아이콘이 도트 그림이고 남색 외곽선 2px로 어느 배경에서도 읽힌다
- [ ] 하단 조작 버튼이 영어 글자 대신 아이콘이고, 메뉴는 크림 패널·남색 버튼·빨간 리본 제목·금색 메달 레벨 아이콘이다
- [ ] 충돌 크기·레벨 배치·동작은 바꾸지 않는다

---

## Implementation Notes

- 아트 규칙: 배경·지형·소품·UI = 외곽선 없음(단, HUD 아이콘 남색 2px, 가시 남색 외곽선) + 마스터 팔레트 `assets/art_src/palette/jei_master.gpl` (아트 바이블 §1, §4, §6, §7).
- 제작: 에이전트가 Aseprite Lua 스크립트로 그린다 (`tools/art/`), 그다음 프로그래머가 연결한다.
- 사용자는 이 스토리의 `src/`·`assets/` 수정을 시작 시 승인했다 (2026-10-29).

## Out of Scope

- 판정 크기·레벨 배치 변경 (레벨 디자인 단계), 효과음, 게임 오버 화면 신규 제작, 클리어 연출 신규 제작

## Files

- src/items/bonus_heart.gd
- src/items/bonus_heart.tscn
- src/layout/split_layout.gd
- src/levels/block.gd
- src/levels/burnable.gd
- src/levels/burnable.tscn
- src/levels/checkpoint.gd
- src/levels/checkpoint.tscn
- src/levels/level_01.tscn
- src/levels/level_02.tscn
- src/levels/level_03.tscn
- src/levels/level_goal.tscn
- src/levels/spike.tscn
- src/ui/health_hud.gd
- src/ui/health_hud.tscn
- src/ui/menu_layer.gd
- src/ui/menu_layer.tscn
- src/ui/touch_controls.gd
- src/ui/touch_controls.tscn
- src/levels/background_set.gd
- src/levels/level_backdrop.gd
- src/levels/looping_strip.gd

## Test Evidence

**Story Type**: Visual/Feel — 실행 스크린샷 `production/qa/evidence/story-012-world-ui-art/`, 서명 `production/qa/evidence/story-012-world-ui-art-evidence.md`

## Dependencies

- Depends on: story-005 (레벨), story-007 (메뉴), story-008 (HUD), story-011

---

## Completion Notes
**Completed**: 2026-10-29
**Criteria**: 7/7 passing (scripted play run: menus, levels 1-3, boss arena; 12 screenshots; user sign-off)
**Deviations**: ADVISORY — level end walls use a HIDDEN block style (outside the camera); level-1 first-play Korean labels not implemented (needs saved state); Galmuri11 font not bundled yet; boss-arena goal flag overlaps the boss start (pre-existing); old placeholder art files still on disk
**Test Evidence**: `production/qa/evidence/story-012-world-ui-art/`, sign-off `production/qa/evidence/story-012-world-ui-art-evidence.md`
**Reviewed by**: self, no independent review (Solo mode)
