# Asset Specs — Character: 제이 (Jei)

> **Source**: design/assets/entity-inventory.md (row 1), design/art/art-bible.md §5
> **Art Bible**: design/art/art-bible.md
> **Generated**: 2026-10-28. Revised 2026-10-28 (v2): first reference rejected as 촌스러움 → redesign by art-director: 36x48, red cape, Cat Isle-cute, asymmetric, ability = cape design + colour. Drawn by agents with Aseprite Lua scripts (art-bible §8).
> **Final reference (2026-10-28)**: `assets/art/player/jei/default/reference.png` — the user-supplied AI concept converted to native pixels (40x52 frame, 32 colours, black outline). It supersedes the "디자인" section below where they differ (hood up, black bob, white sleeves + dark brown dress, no twin tails).
> **Status**: 4 assets specced / 4 approved / 0 in production / 0 done

사용자 결정 (2026-10-28): 모든 그림 약 1.5배 (제이 36x48) / 빨간 망토 / 각진 대칭형 금지, Cat Isle처럼 귀엽게 / 외곽선 없음 / 능력을 얻으면 망토의 모양과 색이 바뀜 / 머리끈은 항상 빨강 / 기본 세트 폴더 `default` / 치마(원피스) `#1F5E66` / 피격 `hurt` 1프레임 4세트 모두.

**충돌 크기**: 지금은 16x24 그대로 (레벨 디자인 단계에서 다시 정한다). 그때까지 그림이 판정보다 크다.

---

## 디자인 (모든 프레임 공통)

36x48, 오른쪽을 봄, 바닥선 y=47 (신발 맨 아래 줄), 몸 중심 x=18.

**금지:** 사각 블록 머리, 좌우 대칭, 정면 차렷 자세, 직사각형 양갈래. 수직·수평 직선은 3px를 넘지 않고, 곡선은 계단형(2-1-1식 픽셀 줄이기)으로 그린다.

**비율**
- 머리(머리카락 포함) y=3~24, 22px. 폭 x=8~29, 22px. 위쪽은 넓고 둥글게, 볼에서 가장 넓고, 턱은 4px로 좁아진다.
- 몸 y=24~40 (망토와 원피스), 다리 y=41~44, 신발 y=45~47. 머리 : 몸 ≈ 1 : 1.1 (2등신).

**얼굴** (Cat Isle식 큰 눈 — 외곽선이 없으니 얼굴에 시선을 잡는 점이 필요)
- 눈은 얼굴 아래쪽 절반 (눈 위끝 y=14). 앞쪽 눈 3x5, 뒤쪽 눈 2x5 (3/4 원근), 두 눈 사이 4px.
- 눈 `navy_ink` #302030, 하이라이트 `sky_white` #FFFFFF 1x2 (위쪽 앞), 아래 끝에 `sea_blue_collar` #3A9FC4 1px (색 홍채 반사).
- 볼터치 `peach_blush` #DF9F8F 2x1 (눈 아래), 입 `danger_red_dark` #AF3050 1~2px, 코 없음.

**머리카락** (`navy_ink` #302030, 윤기 `navy_soft` #404050)
- 앞머리: 비대칭, 얼굴 앞쪽으로 쓸어 넘긴 3갈래. 정수리 바보털 3px.
- 양갈래: 높게 묶은 물방울형. 묶는 점 y=8, 각각 6x12, 아래 끝은 둥글고 바깥으로 휜다. 앞쪽 꼬리는 4~5px 밖으로 (x≈30~34), 뒤쪽 꼬리는 머리 뒤로 3~4px만 보임 (x≈3~7). 양쪽 다 보여야 한다.
- 머리끈 2x2, 항상 `danger_red` #D2373F (능력이 바뀌어도 "제이 = 빨강").
- 움직임: idle 끝 1px 흔들림, run 뒤로 날림 2px, fall 위로 뜸.

**포즈** (비대칭 3/4)
- 몸통 약 30° 돌림, 앞 어깨 1px 낮춤, 머리 1px 기울임.
- 앞 팔만 보이고 뒤 팔은 망토에 가린다.
- 발은 앞뒤로 2px 어긋남. idle은 한쪽 다리에 무게.
- 대칭 축이 생기면 실패.

**옷**
- 망토 아래 `teal_deep_skirt` #1F5E66 원피스 (무릎 위), 앞쪽에만 크림 소매 2px.
- 다리 `cream` #F6EEE4, 신발 `wood_dark` #8A5A3C 3px.

**기본 빨강 망토**
- 몸 `danger_red` #D2373F, 음영·안감 `danger_red_dark` #AF3050, 목 장식 크림 2x2.
- 내린 후드: 목 뒤에 3px 둥근 주름 (빨간 망토의 상징 실루엣).
- 길이: 어깨 y=23 → 뒤쪽 끝 y=40, 앞쪽 끝 y=37 (뒤쪽이 무거운 비대칭).
- 뒤쪽으로 몸 밖 4~5px까지 퍼짐 (x≈4), 끝단은 둥근 물결 2개.
- 흐름: idle 끝단 1px 흔들림, run 수평에 가깝게 뒤로 6px, jump 위로 접힘, fall 위로 부풂, hurt 앞으로 펄럭.

**능력 망토 3종** (모양과 색이 모두 다르다. 몸·얼굴 격자는 공유하고 망토만 바꾼다. 추가 팔레트 색 없음)

| 세트 | 실루엣 | 색 |
|---|---|---|
| fireball | 기본 길이, 끝단에 **둥근** 불꽃 혀 3개 (각 3x4, 끝이 동그람 — 뾰족하면 위험 형태 규칙 위반) | 몸 `warn_orange` #F07A2A, 음영 `danger_red` #D2373F, 불꽃 끝 `fire_core` #FFF1B8 |
| high_jump | **짧은 망토** (허리까지, y=23~32), 양 끝이 위로 튕겨 올라감, 3x3 십자 별 2개 | 몸 `sea_blue_collar` #3A9FC4, 윗줄 `sky_deep_water` #80DFFF, 별 `sky_white` #FFFFFF |
| glide | **넓은 날개형**, 뒤로 몸 밖 7~8px, 끝단 꽃잎 3개, fall/ability에서 양옆으로 펼침 (폭 최대 36) | 몸 `glide_pink` #E89AC0, 음영 `sunset_pink` #DF608F, 안감 크림 |

1배 크기에서 구분하는 기준: 길이 (긴 / 짧은 / 넓은) × 끝단 (불꽃 / 별 / 꽃잎) × 색.

---

## ASSET-001 — 기준 프레임 (idle 1프레임, 4세트)

| Field | Value |
|---|---|
| Category | Character / 기준 그림 |
| Dimensions | 36x48 1프레임 × 4세트 (default, fireball, high_jump, glide) |
| Format | `.aseprite` 원본 + PNG |
| Path | `assets/art_src/player/jei/[세트]/reference.*`, `assets/art/player/jei/[세트]/reference.png`, 스크립트 `tools/art/jei.lua` |

위 디자인 그대로의 idle 첫 프레임. 기본(빨강 망토)을 먼저 확정하고, 같은 몸·얼굴에 망토만 바꿔 3종을 만든다. 사용자가 확인한 뒤 나머지 프레임을 그린다.

**Art Bible Anchors:** §1 원칙 3, §1 그림 검수 기준, §4 팔레트, §5 제이.
**Status:** Needed

---

## ASSET-002 — 기본(default) 세트 스트립 6종

| 스트립 | 프레임 | 스트립 크기 | 경로 |
|---|---|---|---|
| idle | 2 | 72x48 | `assets/art/player/jei/default/idle.png` |
| run | 4 | 144x48 | `assets/art/player/jei/default/run.png` |
| jump | 1 | 36x48 | `assets/art/player/jei/default/jump.png` |
| fall | 1 | 36x48 | `assets/art/player/jei/default/fall.png` |
| ability | 2 | 72x48 | `assets/art/player/jei/default/ability.png` |
| hurt | 1 | 36x48 | `assets/art/player/jei/default/hurt.png` |

공통: 프레임 36x48, 가로 1줄, 여백 0, PNG RGBA, 알파 0/255만, 오른쪽을 봄 (왼쪽은 `flip_h`). 원본 `assets/art_src/player/jei/default/[동작].aseprite`.

**동작:** 모든 프레임에서 바닥선과 몸 중심이 같다. idle은 숨쉬기 1px + 양갈래·망토 끝 흔들림. run은 다리 2포즈를 4프레임으로, 양갈래와 망토가 뒤로 날린다. jump는 팔을 들고 망토가 위로 접힘, fall은 팔을 벌리고 양갈래·망토가 위로 뜸. ability는 프레임 1 팔을 당김, 프레임 2 팔을 뻗음, 두 프레임 모두 입 벌림. hurt는 몸이 뒤로 젖혀지고 눈 `> <`, 망토가 앞으로 펄럭.

**구현 메모:** `hurt` 프레임과 36x48 그림은 지금 게임 코드와 크기가 다르다 (지금은 임시 사각형 16x24). 그림 교체 스토리에서 플레이어 장면을 시트 애니메이션으로 바꾸고, 판정은 레벨 디자인 때 맞춘다.

**Status:** Needed

---

## ASSET-003 — 능력별 망토 3세트

| 세트 | 폴더 |
|---|---|
| fireball | `assets/art/player/jei/fireball/` |
| high_jump | `assets/art/player/jei/high_jump/` |
| glide | `assets/art/player/jei/glide/` |

각 폴더에 `idle` `run` `jump` `fall` `ability` `hurt` 6개 파일, 크기는 ASSET-002와 같다. 몸·얼굴·머리끈은 default와 픽셀 단위로 같고, 망토만 위 "능력 망토 3종" 표대로 다르다. 같은 스크립트가 망토 격자만 바꿔 4세트를 내보낸다.

**Status:** Needed

---

## ASSET-004 — 표정 (별도 파일 없음, 스트립에 포함)

- 기본 (큰 눈): idle, run, jump, fall.
- 능력 사용 (입 벌림): ability 2프레임.
- 피격 (`> <`): hurt 1프레임, 4세트 모두.

**Status:** Needed
