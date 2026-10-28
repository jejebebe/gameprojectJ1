# Visual Entity & Screen Inventory

> Generated: 2026-10-28
> Sources: design/game-brief.md, design/art/art-bible.md, design/levels/level-layouts.md, current placeholder art under assets/art/ (17 PNGs), src/ scenes
> Sizes revised 2026-10-28: all game art about 1.5x (art-bible §5, §8); HUD/UI icons keep their size.
> Status values: Needed / Direction only (art-bible direction exists, the screen or effect is not in the game yet) / Later

## Entities

| # | Name | Type | Description | Source | Status |
|---|------|------|-------------|--------|--------|
| 1 | 제이 (Jei) | Character | Heroine in a red cape, 36x48 sprite, 4 sets (default / fireball / high_jump / glide) differing in cape shape + colour; idle 2, run 4, jump 1, fall 1, ability 2 | art-bible §5, §8 | Needed |
| 2 | 걷는 적 (walker) | Enemy | 24x24, purple half-dome + one horn; walk + defeated; grants fireball | art-bible §3, §5 | Needed |
| 3 | 점프하는 적 (jumper) | Enemy | 24x24, purple droplet + spring legs; move (with crouch telegraph) + defeated; grants high jump | art-bible §3, §5 | Needed |
| 4 | 나는 적 (flyer) | Enemy | 24x24, purple circle + cream triangle wings + navy outline; move + defeated; grants glide | art-bible §3, §5 | Needed |
| 5 | 보스 가시 두더지 | Enemy | 72x60 sprite (hitbox set in level design); idle, shake, crouch, puff, roll, jump, dazed, hurt | art-bible §3, §5 | Needed |
| 6 | 보스 가시 (falling spike) | Enemy | 16x28 falling spike, same grammar as ground spikes, pointing down | art-bible §6 | Needed |
| 7 | 돌 부두 바닥 | Environment | Stone pier ground: cream top line, 24px seams, wave pattern water below | art-bible §6 | Needed |
| 8 | 떠 있는 블록 | Environment | Teal tiled-roof blocks, 24px tile unit (72x72 source, 8px 9-slice margins) | art-bible §6, §8 | Needed |
| 9 | 가시 | Environment | 24px wide, 3 triangles, purple tips, navy outline | art-bible §6 | Needed |
| 10 | 불타는 나무벽 | Environment | Vertical planks, nail marks, soot at the base, small flame sign; burns away | art-bible §6 | Needed |
| 11 | 보스방 문 | Environment | Gate that closes behind the player at the boss arena | src/levels/level_03.tscn | Needed |
| 12 | 배경 레벨 1 (아침 항구) | Environment | Parallax layers L0-L3 + L5, width 360/720, height ≤320 | art-bible §2, §6 | Needed |
| 13 | 배경 레벨 2 (오후 지붕길) | Environment | Same layer set | art-bible §2, §6 | Needed |
| 14 | 배경 레벨 3 (노을 등대 절벽) | Environment | Same layer set | art-bible §2, §6 | Needed |
| 15 | 배경 보스 (동굴 입구) | Environment | Same layer set, sparse: cave mouth + 2 lanterns | art-bible §2, §6 | Needed |
| 16 | 배경 소품 (이야기 요소) | Environment | Cat residents (new design, not Cat Isle cats), seagulls, mole dirt mounds and burrows | art-bible §6, §9 | Needed |
| 17 | 체크포인트 | Item | 24x48 navy pole; inactive cream flag, active gold flag + 2-frame sparkle | art-bible §6 | Needed |
| 18 | 골 깃발 | Item | 24x72 gold medal + red ribbon flag | art-bible §6 | Needed |
| 19 | 보너스 하트 | Item | 24x24 frame, chubby gold heart 18x18, bob + sparkle | art-bible §6 | Needed |
| 20 | 불덩이 (비행, 폭발) | VFX | Fly 12x12, burst 24x24; orange + pale yellow core | art-bible §4, current fireball sheets | Needed |
| 21 | 높이 점프 먼지 | VFX | 24x24 dust | current high_jump_dust_sheet | Needed |
| 22 | 활공 날개 | VFX | 24x24 pink wing/leaf canopy | art-bible §4, current glide_canopy_sheet | Needed |
| 23 | 적 쓰러짐 연기 | VFX | Squash → puff (part of each enemy's defeated strip or shared) | art-bible §5 | Needed |
| 24 | 보스 착지 먼지 | VFX | 24x24 dust, 4 frames | art-bible §5 | Needed |
| 25 | 보스 어지러움 별 | VFX | Stars over the dazed boss | art-bible §5 | Needed |
| 26 | 클리어 효과 (금빛, 색종이) | VFX | Gold radial light + confetti over the game view | art-bible §2, §7 | Direction only |

## UI Screens

| # | Screen Name | Description | Source | Status |
|---|-------------|-------------|--------|--------|
| 1 | 메인 메뉴 | Title logo "제이의 모험", 시작하기 / 레벨 선택; cream panel, navy pill buttons | story-007, art-bible §7 | Needed |
| 2 | 일시정지 메뉴 | 계속하기 / 레벨 선택 / 처음 화면으로 over the bottom area | story-007, art-bible §7 | Needed |
| 3 | 레벨 선택 | Gold medal per level (1-3, boss face on 3), 뒤로 | story-007, art-bible §7 | Needed |
| 4 | 클리어 화면 | Red ribbon "클리어!", gold medal drops in | story-006, art-bible §7 | Needed |
| 5 | 게임 오버 화면 | Navy 60% veil, cream panel, ribbon "다시 해볼까?", sleepy Jei illustration (cream thick border allowed), 다시 하기 | art-bible §7, §9 | Direction only |
| 6 | 하단 조작 영역 | Cream panel, navy rounded buttons with 4px thickness, pressed/disabled states | art-bible §7 | Needed |

## HUD Elements

| # | Element | Description | Source | Status |
|---|---------|-------------|--------|--------|
| 1 | 하트 (찬 / 빈 / 보너스) | Chubby hearts, 2px navy outline, empty = navy outline only | story-008, art-bible §7 | Needed |
| 2 | 목숨 아이콘 | Icon + "x 3" (11px digits), 2px navy outline | story-008, art-bible §7 | Needed |
| 3 | 능력 아이콘 | Fireball / high jump / glide / none (faded empty circle), shown on the ability button | art-bible §4, §7 | Needed |
| 4 | 조작 아이콘 | Left / right chubby triangles, jump up-arrow (navy + cream only), menu `||` | art-bible §7 | Needed |
| 5 | 첫 회 한글 라벨 | 22px Korean labels under buttons, level 1 first play only | art-bible §7 | Needed |
| 6 | 글꼴 Galmuri11 | Bundled pixel font (SIL OFL 1.1) + licence file, sizes 11/22/33 | art-bible §7, §8 | Needed |

## Audio

| # | Name | Type (SFX / Music / Ambient) | Description | Source | Status |
|---|------|------------------------------|-------------|--------|--------|
| 1 | 칩튠 효과음 | SFX | Jump, stomp, hurt, fireball / high jump / glide (each distinct), checkpoint, heart pickup, clear | brief (Art & audio), art-bible §4 colourblind backup | Later |
| 2 | 레벨별 음악 | Music | Retro chiptune per level + boss + menu | brief (Art & audio) | Later |
