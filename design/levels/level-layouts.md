# Level Layouts — Jei's Adventure (concept sample, levels 1-3)

> **Source**: `level-designer` paper design, 2026-10-27; approved by the user 2026-10-28.
> **Story**: `production/epics/jeis-adventure/story-005-levels-1-3.md`
> **Status**: temporary block layout for the concept sample. Final art, tilemaps and volume come in full production.
> **Scale**: world scaled ×1.5 on 2026-10-29 (user decision, story-013). x' = 1.5·x; y' = 280 − 1.5·(280 − y) (the ground line y=280 stays, heights above and below it ×1.5). Every number below is the scaled value.

## Conventions

- All coordinates in px. Ground top y=280 (ground blocks 60 px thick, centre y=310). Level height 320 = camera view height (no vertical scroll; the highest element, a cliff-top heart, sits at y=73).
- **Platform**: x = centre, y = centre. Top = y-12, underside = y+12. y=220 gives top 208 (72 above ground) and 48 px clearance underneath (player height 36).
- **Cliff** (high-jump obstacle): a solid StaticBody2D block standing on the ground, top y=100 (180 above ground), height 180, centre y=190. A floating platform at y=100 would not block the path.
- Walker and Jumper centre y=268, Flyer y=208, Checkpoint y=262, Spike y=272.5, Burnable wall y=208 (spans 136-280).
- Bonus heart y=253 on the ground, y=73 on a cliff top.
- Enemy patrol is centred on the placed x: Walker ±90 (60 px/s), Flyer ±120 (75 px/s, y 196-220 with bob), Jumper hops in place (~52 px every 1.6 s). Walkers do not turn at ledges, so every walker patrol sits on solid ground.
- One kill zone under the whole level: centre (L/2, 400), width L+300, 60 thick. Walls 24 wide at x=-12 and x=L+12. Camera `limit_right` = L.
- Respawn before the first checkpoint uses the level start.

## Level design rules (approved)

1. **Giver before its obstacle, no checkpoint between them.** A checkpoint sits right before each giver enemy; there is no checkpoint between the giver and the obstacle it feeds. (Otherwise a death there respawns past the giver with no ability: softlock.)
2. **One enemy per zone.** Between a checkpoint and the obstacle it feeds, the only enemy is that obstacle's giver. Every enemy grants an ability, so a second enemy could swap the ability by accident with no way back.
3. **Gaps**: walker patrol edge to burnable wall >= 150 px (room to fire inside the 210 px fireball range); flyer patrol edge to glide pit >= 180 px run-up; >= 240 px clean runway before every glide pit.
4. **Pits**: normal-jump pits <= 96 px (72-84 used). Glide pits <= 255 px: 204 px for the first, 252 px only as a later one.
5. **Checkpoints** about every 750 px; glide sections may stretch to 840-990 px because of rules 1 and 4. Checkpoint >= 120 px past a pit edge.
6. Flags and items >= 90 px from pit edges, spikes and patrol ranges; no item within 12 px of a checkpoint.
7. **Accepted alternate solve**: in level 3 a carried high jump clears a 144 px burnable wall. Allowed.
8. **Time target "2-3 minutes"** means typical play including deaths (user decision 2026-10-28). Clean runs are ~75 s / ~95 s / ~117 s (unchanged by the ×1.5 scale: speeds scale too).

---

## Level 1 "배우기" (L=4800)

Teaching order: walk and jump (spike, platform with heart) → first pit 72 px → a walker with no obstacle (stomp is safe, it gives fire) → two single spikes, pit 84 px → **wall 1** (checkpoint, giver walker, burnable, heart behind) → **wall 2** with a spike right behind → finale walker → goal.

| x | Element | y | Note |
|---|---|---|---|
| 60 | Player start | 262 | |
| 420 | Spike S1 | 272.5 | |
| 600 | Platform w144 (528-672) | 220 | Heart H1 on it at (600, 193) |
| 780 | Checkpoint CP1 | 262 | |
| 1050 | Walker A (patrol 960-1140) | 268 | Teaching stomp; fire granted but not needed |
| 1320-1392 | Pit 1 (72) | – | |
| 1560 | CP2 | 262 | |
| 1740 | Spike S2 | 272.5 | |
| 1950 | Spike S3 | 272.5 | |
| 2250 | CP3 | 262 | Before the giver |
| 2490 | Walker B (patrol 2400-2580) | 268 | **Giver: fireball** |
| 2760 | Burnable B1 (2748-2772) | 208 | |
| 2925 | Heart H2 | 253 | Reward behind the wall |
| 3000 | CP4 | 262 | |
| 3300-3384 | Pit 2 (84) | – | Shrink to 72 if kids fall a lot |
| 3540 | CP5 | 262 | Before the giver |
| 3810 | Walker C (patrol 3720-3900) | 268 | **Giver: fireball** |
| 4080 | Burnable B2 (4068-4092) | 208 | |
| 4200 | Spike S4 | 272.5 | |
| 4320 | CP6 | 262 | |
| 4500 | Walker D (patrol 4410-4590) | 268 | Finale stomp |
| 4710 | Goal flag | 262 | |

Ground: [0-1320] [1392-3300] [3384-4800].

## Level 2 "새 능력" (L=5700)

Order: warm-up spike → **jumper → high jump → cliff 1** (heart on top) → recap pit 84 px + spike → **flyer → glide → 204 px pit** → jumper → cliff 2 (heart) → **flyer → 252 px pit** → spike → goal.

| x | Element | y | Note |
|---|---|---|---|
| 60 | Player start | 262 | |
| 390 | Spike S1 | 272.5 | |
| 600 | Platform w144 (528-672) | 220 | Optional |
| 780 | CP1 | 262 | |
| 1020 | Jumper J1 | 268 | **Giver: high jump** |
| 1260-1500 | Cliff 1 (w240, top 100) | centre 190 | Heart H1 on top (1380, 73) |
| 1620 | CP2 | 262 | |
| 1830-1914 | Pit P1 (84) | – | |
| 2160 | Spike S2 | 272.5 | |
| 2340 | CP3 | 262 | Before the giver |
| 2580 | Flyer F1 (patrol 2460-2700) | 208 | **Giver: glide** |
| 2940-3144 | Glide pit Gp1 (204) | – | |
| 3330 | CP4 | 262 | |
| 3600 | Jumper J2 | 268 | **Giver: high jump** |
| 3840-4032 | Cliff 2 (w192, top 100) | centre 190 | Heart H2 on top (3936, 73) |
| 4200 | CP5 | 262 | Before the giver |
| 4470 | Flyer F2 (patrol 4350-4590) | 208 | **Giver: glide** |
| 4800-5052 | Glide pit Gp2 (252) | – | |
| 5190 | CP6 | 262 | |
| 5370 | Spike S3 | 272.5 | |
| 5610 | Goal flag | 262 | |

Ground: [0-1830] [1914-2940] [3144-4800] [5052-5700].

## Level 3 "섞어 쓰기" (L=6750)

Six sections alternate fire, glide, high jump, fire, glide, high jump — each one checkpoint, one giver, one obstacle. The flat stretch 6150-6750 is the boss arena (story 006).

| x | Element | y | Note |
|---|---|---|---|
| 60 | Player start | 262 | |
| 390 | Spike S1 | 272.5 | |
| 570 | Platform w144 (498-642) | 220 | Optional |
| 720 | CP1 | 262 | |
| 960 | Walker W1 (patrol 870-1050) | 268 | **Giver: fireball** |
| 1230 | Burnable B1 (1218-1242) | 208 | |
| 1410 | CP2 | 262 | |
| 1650 | Flyer F1 (patrol 1530-1770) | 208 | **Giver: glide** |
| 2010-2262 | Glide pit Gp1 (252) | – | |
| 2400 | CP3 | 262 | |
| 2640 | Jumper J1 | 268 | **Giver: high jump** |
| 2880-3072 | Cliff 1 (w192, top 100) | centre 190 | Heart H1 on top (2976, 73) |
| 3240 | CP4 | 262 | |
| 3375 | Spike S2 | 272.5 | |
| 3570 | Walker W2 (patrol 3480-3660) | 268 | **Giver: fireball** |
| 3840 | Burnable B2 (3828-3852) | 208 | |
| 4020 | CP5 | 262 | |
| 4260 | Flyer F2 (patrol 4140-4380) | 208 | **Giver: glide** |
| 4620-4872 | Glide pit Gp2 (252) | – | |
| 5010 | CP6 | 262 | |
| 5250 | Jumper J2 | 268 | **Giver: high jump** |
| 5490-5682 | Cliff 2 (w192, top 100) | centre 190 | Heart H2 on top (5586, 73) |
| 5850 | CP7 | 262 | |
| 5985 | Walker W3 | 268 | |
| 6120 | Spike S3 | 272.5 | |
| 6180 | Backdrop switch | – | `boss_switch_x`: boss background fades in |
| 6195 | Boss gate (w24, 6183-6207) | centre 100 | Closes behind the player |
| 6240 | CP8 | 262 | Inside the arena |
| 6264 | Arena trigger | – | `trigger_x`; fight camera `limit_left` 6210 |
| 6630 | Boss start (moves 6231-6726) | 262 | |
| 6732 | Goal flag | 262 | Right end of the arena, inert until the boss is defeated |

Ground: [0-2010] [2262-4620] [4872-6750].

---

## Playtest risks

- **Flyer stomp window (biggest risk)**: a normal jump apex reaches only ~30 px into the flyer's height range. A kid who cannot stomp a flyer cannot get glide and cannot finish level 2. User decision 2026-10-28: keep the current height, play first, then decide (option: lower the flyer ~18 px).
- Glide pits: 252 px leaves ~48 px margin; a late glide falls. The first glide pit in level 2 is 204 px for that reason.
- Cliff top margin is 38-45 px; lower the cliff to 168 px if kids miss.
- A kid who jumps over the giver walker reaches the wall without fire; they can walk back because the walker is still alive. Check that this reads clearly.
- Level 3 is close to a repeat of levels 1 and 2; consider tighter chains in full production.
- **Boss arena wider than the view (since the ×1.5 scale)**: the arena is ~543 px wide, the view 360 px. The fight camera scrolls inside the arena instead of showing all of it, so a telegraph can start off-screen.

## Open assumptions to confirm in play

- No fall damage from the 180 px cliff drop (none exists today).
- Platforms are solid from below (head bump).
