# Story 010: 제이 그림과 동작을 게임에 넣기

> **Epic**: jeis-adventure
> **Status**: Complete
> **Layer**: Presentation
> **Type**: Visual/Feel
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-28

## Context

**GDD**: `design/game-brief.md`, `design/art/art-bible.md` §5, `design/assets/specs/jei-assets.md`
**Requirement**: 아트 전면 교체의 첫 단계 — 임시 사각형 제이를 확정한 그림과 동작으로 바꾼다 (사용자 결정 2026-10-28 "제이를 게임에 넣기")

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**Engine**: Godot 4.7 | **Risk**: MEDIUM

---

## Acceptance Criteria

- [ ] 게임 속 제이가 임시 사각형 대신 확정한 도트 그림(48x52 칸)으로 보인다
- [ ] 서 있기·달리기·점프·낙하·능력 사용·피격 동작이 상황에 맞게 재생된다
- [ ] 왼쪽으로 움직이면 그림이 좌우로 뒤집힌다
- [ ] 능력을 얻으면 망토 세트(불덩이·높이 점프·활공)로 바뀌고, 능력을 잃으면 기본 빨간 망토로 돌아온다
- [ ] 피격 후 깜빡임(무적 표시)이 그림에도 적용된다
- [ ] 동작별 프레임 수·속도는 데이터 파일로 조정할 수 있다
- [ ] 충돌 크기(16x24)와 레벨은 바꾸지 않는다 (레벨 디자인 단계에서 다시 정함)

---

## Implementation Notes

- 그림: `assets/art/player/jei/{default,fireball,high_jump,glide}/{idle,run,jump,fall,ability,hurt}.png` — 가로 스트립, 프레임 48x52, 발은 맨 아래 줄, 몸 중심은 칸의 가운데(x=24).
- 프레임 수 / 프레임당 시간: idle 6 / 200ms (반복), run 12 / 50ms (반복), jump 3 / 100ms (반복), fall 3 / 100ms (반복), ability 6 / 약 70ms (한 번), hurt 3 / 100ms (한 번).
- 발 위치: 그림의 맨 아래 줄이 충돌 상자(16x24)의 바닥과 맞게 놓는다.
- 기존 `SheetFrames`로 스트립을 불러온다 (적과 같은 방식). 동작 표·경로는 데이터 리소스로 둔다.
- 사용자는 이 스토리의 `src/`·`assets/` 수정을 시작 시 한 번에 승인했다 (2026-10-28).

## Out of Scope

- 판정 크기·레벨 간격 조정 (레벨 디자인 단계)
- 적·보스·타일·배경·UI 그림 (다음 작업)

## Files

- src/player/player.gd
- src/player/player.tscn
- src/player/player_art.gd
- src/player/player_anim_spec.gd
- assets/data/player_art.tres
- src/player/player_art.gd.uid
- src/player/player_anim_spec.gd.uid

## Test Evidence

**Story Type**: Visual/Feel — 실행 스크린샷 `production/qa/evidence/story-010-jei-sprite/`, 서명 기록 `production/qa/evidence/story-010-jei-sprite-evidence.md`

## Dependencies

- Depends on: story-001 (플레이어), story-004 (능력)

---

## Completion Notes
**Completed**: 2026-10-28
**Criteria**: 7/7 passing (scripted play run + 11 screenshots; user sign-off)
**Deviations**: ADVISORY — sprite (48x52) is larger than the 16x24 hitbox until level design; PNG strips are loaded by path at runtime (a filtered export preset must include `assets/art/player/jei/`); one-shot animations rely on `loop = false` in the data
**Test Evidence**: `production/qa/evidence/story-010-jei-sprite/`, sign-off `production/qa/evidence/story-010-jei-sprite-evidence.md`
**Reviewed by**: self, no independent review (Solo mode)
