# Evidence: Story 001 — 세로 분할 화면과 이동·점프

> **Story**: `production/epics/jeis-adventure/story-001-split-layout-move-jump.md`
> **Type**: Visual/Feel
> **Sign-off**: 사용자 (1인 개발자, 리드 역할 겸임)
> **Date**: 2026-10-26
> **Stamp**: `production/qa/evidence/story-001-split-layout-move-jump/stamp.txt` (서명 시점의 파일 해시)

## Sign-off

사용자가 Godot 에디터에서 직접 플레이하고 피드백을 반영한 뒤 승인했다 ("괜찮네 진행하자").

| 항목 | 결과 |
|---|---|
| 화면비, 위아래 분할 (9:16, 20:9) | OK |
| 조작 버튼 위치 (아래 여백 48px, ABILITY는 이동 버튼과 JUMP 사이 위쪽) | OK |
| 최대 점프 높이 (측정값 83.4px, 64px 발판에 올라갈 수 있음) | OK |
| 카메라 시선 보정 (바라보는 쪽을 넓게 보여 줌, 레벨 끝에서 멈춤) | OK |
| 이동 속도, 세부 점프 높이 | 추후 조정 (사용자 결정) |

## Sign-Off

1인 개발이라 사용자가 리드(디자이너)로 직접 서명한다 (2026-10-26, `/story-done` 중 확인).

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Lead (designer, solo developer) | 사용자 | 2026-10-26 | [x] Approved |

## Screenshots

- [03-ratio-20x9-full.png](story-001-split-layout-move-jump/03-ratio-20x9-full.png): 20:9 폰 비율. 게임 화면이 위, 버튼이 아래에 붙음
- [04-controls-raised-at-left-edge.png](story-001-split-layout-move-jump/04-controls-raised-at-left-edge.png): 레벨 왼쪽 끝. 카메라가 경계에서 멈춤
- [05-facing-right.png](story-001-split-layout-move-jump/05-facing-right.png): 오른쪽을 볼 때 캐릭터가 화면 왼쪽 1/3에 옴
- [06-facing-left.png](story-001-split-layout-move-jump/06-facing-left.png): 왼쪽을 볼 때 캐릭터가 화면 오른쪽 1/3에 옴

## Not covered

- **아이 시험 플레이 (인수 조건)**: DEFERRED. 사용자 결정 (2026-10-26)으로 당분간 하지 않는다
- **도트 선명도 (인수 조건)**: 아직 확인 못 함. 지금은 단색 사각형과 글자뿐이고, 스크린샷은 기준 해상도로 저장되어 창 확대 시 흐려짐은 담기지 않는다. 실제 도트 그림이 들어간 뒤 확인한다
- **실기기 두 손가락 동시 입력**: 아직 확인 못 함. 모바일 빌드가 필요하다
- **손맛 (타이밍, 무게감)**: 정지 화면으로는 확인할 수 없다. 사용자가 직접 플레이로 확인했다
