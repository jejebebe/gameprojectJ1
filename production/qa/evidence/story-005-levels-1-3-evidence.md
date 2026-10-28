# Evidence: Story 005 — 레벨 3개

> **Story**: `production/epics/jeis-adventure/story-005-levels-1-3.md`
> **Story Type**: Visual/Feel
> **Date**: 2026-10-28
> **Tester**: 덕수(project-director)가 자동 입력 스크립트로 실행하고 확인, 사용자가 에디터(F5)에서 선명도 확인
> **Stamp**: `production/qa/evidence/story-005-levels-1-3/stamp.txt` (서명 시점의 파일 해시)

---

## What Was Tested

세로 분할 화면에서 레벨 1~3이 순서대로 로드되고, 레벨마다 능력으로 푸는 구간이 동작하며, 끝 깃발에서 다음 레벨로 넘어가는지 확인했다. 레벨은 임시 단색 블록이다 (완성 아트와 세부 레벨 디자인은 컨셉 샘플 이후 본격 제작 단계).

**Acceptance criteria covered**: 레벨 3개 순서대로 진행, 끝 지점에서 다음 레벨로 이동, 체크포인트 간격, 정밀 점프 연속 구간 없음, 레벨마다 능력 구간, 임시 단색 블록, 세로 분할 화면, 임시 타일 선명도

---

## Acceptance Criteria Results

| # | Criterion (from story) | Result | Notes |
|---|----------------------|--------|-------|
| AC-1 | 레벨 3개가 있고 순서대로 끝까지 플레이할 수 있다 | PASS | 레벨 1의 벽 2개, 레벨 2의 절벽과 활공 구덩이, 레벨 3의 활공 구덩이 2곳과 골까지 실행으로 확인. 레벨 3의 나무 벽·절벽 구간은 개별 실행하지 않음 |
| AC-2 | 끝 지점에 도달하면 다음 레벨로 넘어간다 | PASS | 1→2(목숨 이어짐, 능력 초기화), 2→3, 3→GAME CLEAR 후 새 레벨 1 |
| AC-3 | 한 레벨을 2~3분 안팎에 끝낼 수 있다 | DEFERRED | 시험 플레이로 측정하지 않음. 설계 추정은 실수 없이 75~117초 |
| AC-4 | 체크포인트가 촘촘하게 놓여 있다 | PASS | 레벨 1·2는 6개, 레벨 3은 7개 (간격 460~660px) |
| AC-5 | 정밀한 점프를 연속으로 요구하는 구간이 없다 | PASS | 일반 구덩이 48~56px, 가시는 하나씩 떨어져 있음 (배치도와 장면 일치) |
| AC-6 | 각 레벨에 능력에 따라 풀이가 달라지는 구간 1곳 이상 | PASS | 레벨 1 벽 2개, 레벨 2 절벽 2개·구덩이 2개, 레벨 3 6구간 |
| AC-7 | 임시 단색 블록으로 구성 | PASS | 스크린샷 01, 03, 04, 05 |
| AC-8 | 세 레벨 모두 세로 분할 화면과 하단 조작 영역 | PASS | 스크린샷 01, 03, 04, 05 |
| AC-9 | 임시 타일이 선명하게 보인다 | PASS | 사용자가 에디터에서 확인 (2026-10-28) |

---

## Screenshots / Video

| # | Filename | What It Shows | Acceptance Criterion |
|---|----------|--------------|----------------------|
| 1 | `story-005-levels-1-3/01-level1-start.png` | 레벨 1 시작: 가시, 하트가 놓인 발판, 체크포인트 깃발, HUD | AC-7, AC-8 |
| 2 | `story-005-levels-1-3/02-level1-after-wall1.png` | 첫 나무 벽을 태우고 지난 뒤: 보너스 하트, 불꽃 아이콘 | AC-6 |
| 3 | `story-005-levels-1-3/03-level2-start.png` | 레벨 2 시작 (목숨 이어짐) | AC-2, AC-8 |
| 4 | `story-005-levels-1-3/04-level2-on-cliff.png` | 높이 점프로 올라선 절벽 위, 보너스 하트, 골 깃발 | AC-6 |
| 5 | `story-005-levels-1-3/05-level3-start.png` | 레벨 3 시작 | AC-8 |

Run log: `story-005-levels-1-3/levels-run.log`

---

## Test Conditions

- **Game state at start**: 새 게임, 목숨 3, 레벨 1
- **Platform / hardware**: Windows 11, 창 모드 540x960 (기준 해상도 360x640), 자동 입력 스크립트(순간이동, 입력 주입)
- **Framerate during test**: 측정하지 않음
- **Any special setup required**: 구간 확인을 위해 위치를 직접 옮김

---

## Observations

- 나는 적을 밟기 쉽게 `flyer_stats.tres`를 바꾼 뒤(판정 여유 6→14px, 속도 50→35), 달리면서 점프하면 8번 중 3번 밟고 맞지는 않는다. 제자리 점프로는 여전히 밟지 못한다.
- 활공 구덩이 4곳은 가장자리에서 점프하고 최고점에서 활공을 시작하면 모두 건넜다.
- 레벨 1 시험 플레이는 사용자 결정으로 건너뛰었다.

---

## Sign-Off

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Lead (designer, solo developer) | 사용자 | 2026-10-28 | [x] Approved |

*서명 범위: 스크린샷 5장과 실행 기록을 확인함. 2~3분 측정과 직접 플레이는 미룸.*
