# Evidence & Sign-off — Story 010: 제이 그림과 동작을 게임에 넣기

**Date**: 2026-10-28
**Screenshots**: `production/qa/evidence/story-010-jei-sprite/` (01-idle … 11-after-hurt), run log `run-log.txt`, stamp `stamp.txt`

| Criterion | Evidence |
|---|---|
| 임시 사각형 대신 도트 그림 | 01-idle.png |
| 동작이 상황에 맞게 재생 | 01 idle, 02 run, 03 jump, 04 fall, 07 ability, 10 hurt (run-log의 anim 이름) |
| 왼쪽 이동 시 뒤집힘 | 05-run-left-flip.png (flip=true) |
| 능력별 망토 세트 전환 | 06 fireball, 08 glide, 09 high_jump |
| 피격 깜빡임 적용 | 10-hurt.png (modulate a=0.53), 11 |
| 프레임·속도 데이터 조정 | assets/data/player_art.tres |
| 충돌·레벨 변경 없음 | player.tscn 충돌 16x24 그대로, 레벨 파일 미변경 |

## Sign-off

| Role | Name | Verdict |
|---|---|---|
| Art / Feel lead | 사용자 (1인 스튜디오) | [x] Approved 2026-10-28 |
| Visual QA | 사용자 (1인 스튜디오) | [x] Approved 2026-10-28 |

Notes: 그림이 판정(16x24)보다 크다 — 레벨 디자인 단계에서 판정을 다시 정한다 (사용자 결정 2026-10-28).
