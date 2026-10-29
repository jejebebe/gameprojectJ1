# Evidence & Sign-off — Story 011: 적 3종과 보스 그림 교체

**Date**: 2026-10-29
**Screenshots**: `production/qa/evidence/story-011-enemy-boss-art/` (01-walker, 02-jumper, 03-flyer, 04-boss-before, 05-boss-{shake,roll,crouch,jump,dazed,puff}), run log `run-log.txt`, stamp `stamp.txt`

| Criterion | Evidence |
|---|---|
| 적 3종 새 그림 + 이동 동작 | 01, 02, 03 |
| 실루엣으로 구분 | 01-03, `assets/art_src/enemies/enemies_x6.png` |
| 보스 모든 동작 새 그림 | 05-boss-* (run-log의 anim 순서: shake → roll → crouch → jump → dazed → puff) |
| 발이 땅에 붙음 | 01, 02, 05 (그림 위치: 적 y −4, 보스 (2, −18)) |
| 데이터로 조정 | `assets/data/enemies/*_stats.tres` |
| 충돌·레벨 변경 없음 | 충돌 모양·레벨 파일 미변경 |

## Sign-off

| Role | Name | Verdict |
|---|---|---|
| Art / Feel lead | 사용자 (1인 스튜디오) | [x] Approved 2026-10-29 |
| Visual QA | 사용자 (1인 스튜디오) | [x] Approved 2026-10-29 |

Notes: 적(24px)이 제이(48px) 옆에서 작아 보임 — 레벨 디자인 때 조정. 옛 적·보스 그림 파일은 아트 교체 마무리 때 정리.
