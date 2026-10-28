# Story 006: 보스 1개

> **Epic**: jeis-adventure
> **Status**: Complete
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-28

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

**정해진 보스 설계 (사용자 결정 2026-10-28, `production/direction/decision-log.md`):**
- 보스 "가시 두더지"(임시 그림), 레벨 3 끝의 평지(x 4100~4500)에서 싸운다. 입장하면 문이 잠기고 싸움이 시작된다
- 체력 3: 위에서 밟거나 불꽃을 맞히면 1 줄고, 맞은 뒤 잠시 깜빡이며 무적. 높이 점프·활공은 필수가 아니다
- 패턴 3개, 모두 약 1초의 예고 동작이 먼저 나온다:
  1. 돌진: 뒤로 물러나 몸을 떤 뒤 벽까지 굴러 돌진. 점프로 넘으면 된다
  2. 점프 찍기: 웅크린 뒤 크게 뛰어올라 플레이어 쪽에 착지. 착지 후 어지러워하는 동안이 밟을 기회
  3. 가시 비: 몸을 부풀리고, 떨어질 자리에 그림자가 보인 뒤 가시 3개가 떨어진다
- 보스방 앞에 능력을 주는 걷는 적 1마리, 방 안에 체크포인트 1개. 레벨 3의 임시 골 깃발은 보스를 쓰러뜨리면 작동하게 바꾼다
- 클리어: 보스가 쓰러지면 화면에 "클리어!"를 보여 주고, 임시로 처음 레벨로 돌아간다 (메인 화면과 클리어 후 흐름은 스토리 007)
- 보스 수치(체력, 예고 시간, 속도, 패턴 간격, 가시 개수)는 모두 데이터 파일
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

- src/enemies/boss.gd
- src/enemies/boss.tscn
- src/enemies/boss_spike.gd
- src/enemies/boss_spike.tscn
- src/enemies/boss_stats.gd
- src/enemies/boss_strip.gd
- src/enemies/enemy.gd
- src/abilities/fireball.gd
- src/player/player.gd
- src/levels/boss_arena.gd
- src/levels/level_goal.gd
- src/levels/level_03.tscn
- assets/data/enemies/boss_stats.tres
- assets/art/enemies/boss/crouch.png
- assets/art/enemies/boss/dazed.png
- assets/art/enemies/boss/dust.png
- assets/art/enemies/boss/hurt.png
- assets/art/enemies/boss/idle.png
- assets/art/enemies/boss/jump.png
- assets/art/enemies/boss/puff.png
- assets/art/enemies/boss/roll.png
- assets/art/enemies/boss/shake.png
- assets/art/enemies/boss/spike.png
- src/enemies/boss.gd.uid
- src/enemies/boss_spike.gd.uid
- src/enemies/boss_stats.gd.uid
- src/enemies/boss_strip.gd.uid
- src/levels/boss_arena.gd.uid

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

---

## Completion Notes
**Completed**: 2026-10-28
**Criteria**: 7/7 passing. Observed in a scripted run and screenshots (`production/qa/evidence/story-006-boss/`): fight starts at the arena entrance, 3 patterns each with a ~1 s telegraph, fireball/stomp hits (3 separate stomps needed), death restores a full-HP boss at the arena checkpoint with the gate closed, "클리어!" then level 1, sprite-sheet animations + landing dust, all numbers in `boss_stats.tres`
**Deviations**: ADVISORY — scope grew past the planned files: `Player.knock_back`, `Enemy.take_hit` hook, fireball hook, `BossArena`, `LevelGoal.arena`, camera lock during the fight (all listed under `## Files`). ADVISORY — the sideways knock-back after a stomp has no screenshot of its own (only the log shows 3 separate stomps). ADVISORY — engine-check notes: a dormant boss absorbs fireballs and still damages by touch (gate/trigger keep the player away); `HURT -> HURT` is blocked only while `hit_invulnerable_time` >= `hurt_time`; camera limit snaps instantly when the gate closes. Placeholder art; feel and difficulty not playtested by hand (balance test later). `print("GAME CLEAR")` and the return to level 1 are placeholders until story 007
**Test Evidence**: run log, 12 screenshots and stamp under `production/qa/evidence/story-006-boss/` (tests waived at qa.level minimal)
**Reviewed by**: self, no independent review (QL-TEST-COVERAGE, LP-CODE-REVIEW skipped — Solo mode; godot-gdscript-specialist ran an engine-API check, no BREAKS, one SHOULD-FIX fixed)
