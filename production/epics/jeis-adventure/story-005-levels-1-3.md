# Story 005: 레벨 3개

> **Epic**: jeis-adventure
> **Status**: Complete
> **Layer**: Feature
> **Type**: Visual/Feel
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-28

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
- [ ] 한 레벨을 2~3분 안팎에 끝낼 수 있다 (시험 플레이로 측정한다. 5분은 본격 제작 단계에서 볼륨을 늘릴 때 맞춘다. 사용자 결정 2026-10-27)
- [ ] 체크포인트가 촘촘하게 놓여 있다 (간격 기준은 시험 플레이로 정한다)
- [ ] 정밀한 점프를 연속으로 요구하는 구간이 없다
- [ ] 각 레벨에 능력에 따라 풀이가 달라지는 구간이 1곳 이상 있다
- [ ] 레벨은 간단한 임시 도트 타일(단색 블록 수준)로 구성한다. 완성 아트는 컨셉 샘플 이후 본격 제작 단계에서 만든다 (사용자 결정 2026-10-27)
- [ ] 세 레벨 모두 세로 분할 화면과 하단 조작 영역에서 플레이된다
- [ ] 임시 도트 타일이 에디터 창에서 흐려지지 않고 선명하게 보인다 (스토리 001에서 이월: 정수 배율, Nearest 필터. 완성 아트의 선명도는 본격 제작 단계에서 다시 확인)

---

## Implementation Notes

**정해진 레벨 구성 (사용자 결정 2026-10-27, `production/direction/decision-log.md`):**
- 레벨 1 "배우기" 약 3200px: 걷는 적을 밟아 불꽃을 얻고 나무 벽을 태움. 낮은 구덩이, 가시, 보너스 하트
- 레벨 2 "새 능력" 약 3800px: 점프하는 적에게서 높이 점프(높은 단), 나는 적에게서 활공(넓은 구덩이)
- 레벨 3 "섞어 쓰기" 약 4500px: 세 능력을 번갈아 써야 하는 구간들. 끝은 스토리 006의 보스로 이어짐 (006 전까지는 끝 깃발에서 게임 클리어)
- 목표 길이 레벨당 2~3분. 체크포인트 약 500px마다. 능력을 주는 적은 그 능력이 필요한 장애물보다 앞에 둔다. 정밀한 점프 연속 구간 없음. 아이템은 체크포인트에서 8px 이상 떨어뜨림
- 레벨 끝 깃발에 닿으면 다음 레벨로 이동. 목숨은 이어가고, 능력과 보너스 체력은 새 레벨에서 초기화. 게임 오버는 처음(레벨 1)부터
- 레벨은 타일맵 칸 데이터 대신 지금 테스트 레벨처럼 블록(StaticBody2D 조각)을 배치하는 방식으로 만든다 (임시 도트 블록). 완성 아트와 타일맵은 본격 제작 단계
- 레벨 전환: 레이아웃이 레벨 장면을 갈아 끼우고 HUD·재시작 관리를 새 레벨에 다시 연결한다. 메인 화면과 레벨 선택은 스토리 007

**구현 순서:** 레벨 1 완성 → 시험 → 레벨 2·3. 레벨 설계는 `level-designer`가 맡고 `gameplay-programmer`가 연결한다.
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

- src/levels/block.gd
- src/levels/level_goal.gd
- src/levels/level_goal.tscn
- src/levels/level.gd
- src/levels/level_01.tscn
- src/levels/level_02.tscn
- src/levels/level_03.tscn
- src/layout/split_layout.gd
- src/layout/split_layout.tscn
- src/ui/health_hud.gd
- src/systems/respawn_manager.gd
- assets/data/enemies/flyer_stats.tres

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

---

## Completion Notes
**Completed**: 2026-10-28
**Criteria**: 8/9 passing, 1 deferred. Deferred: "한 레벨 2~3분" was not measured (needs a timed playtest; design estimate 75-117 s clean, 2-3 min with deaths). All others observed in scripted runs and screenshots (`production/qa/evidence/story-005-levels-1-3/`); sign-off in `production/qa/evidence/story-005-levels-1-3-evidence.md`. The user confirmed tile sharpness in the editor. Level 3's burnable-wall and cliff sections were not run one by one (same parts as levels 1 and 2)
**Deviations**: ADVISORY — level 1 playtest skipped by user decision (2026-10-28); detailed per-stage level design moves to full production. ADVISORY — `flyer_stats.tres` eased (stomp_tolerance 6->14, move_speed 50->35): running jumps stomp the flyer 3/8 with no hits, standing jumps still cannot stomp it; revisit in detailed planning. ADVISORY — engine-check notes: lives read at goal time vs a queued failure, `set_lives` vs `await player.ready` when the node order changes, `_loading` stuck after a bad level, level length repeated in 6 places per scene. ADVISORY — evidence folder is `story-005-levels-1-3`, not the `story-005/` named in the story's Test Evidence section. `print("GAME CLEAR")` is a placeholder until story 006/007
**Test Evidence**: screenshots 01-05, run log and sign-off under `production/qa/evidence/` (tests waived at qa.level minimal)
**Reviewed by**: self, no independent review (QL-TEST-COVERAGE, LP-CODE-REVIEW skipped — Solo mode; level-designer designed the layouts; godot-gdscript-specialist ran an engine-API check, no criterion-breaking findings)
