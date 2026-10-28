# Level Layouts — Jei's Adventure (concept sample, levels 1-3)

> **Source**: `level-designer` paper design, 2026-10-27; approved by the user 2026-10-28.
> **Story**: `production/epics/jeis-adventure/story-005-levels-1-3.md`
> **Status**: temporary block layout for the concept sample. Final art, tilemaps and volume come in full production.

## Conventions

- All coordinates in px. Ground top y=280 (ground blocks 40 px thick, centre y=300). Level height 320 = camera view height (no vertical scroll).
- **Platform**: x = centre, y = centre. Top = y-8, underside = y+8. y=240 gives top 232 (48 above ground) and 32 px clearance underneath.
- **Cliff** (high-jump obstacle): a solid StaticBody2D block standing on the ground, top y=160 (120 above ground), height 120, centre y=220. A floating platform at y=160 would not block the path.
- Walker and Jumper centre y=272, Flyer y=232, Checkpoint y=268, Spike y=275, Burnable wall y=232 (spans 184-280).
- Bonus heart y=262 on the ground, y=142 on a cliff top.
- Enemy patrol is centred on the placed x: Walker ±60 (40 px/s), Flyer ±80 (50 px/s, y 224-240 with bob), Jumper hops in place (~35 px every 1.6 s). Walkers do not turn at ledges, so every walker patrol sits on solid ground.
- One kill zone under the whole level: centre (L/2, 360), width L+200. Walls at x=-8 and x=L+8. Camera `limit_right` = L.
- Respawn before the first checkpoint uses the level start.

## Level design rules (approved)

1. **Giver before its obstacle, no checkpoint between them.** A checkpoint sits right before each giver enemy; there is no checkpoint between the giver and the obstacle it feeds. (Otherwise a death there respawns past the giver with no ability: softlock.)
2. **One enemy per zone.** Between a checkpoint and the obstacle it feeds, the only enemy is that obstacle's giver. Every enemy grants an ability, so a second enemy could swap the ability by accident with no way back.
3. **Gaps**: walker patrol edge to burnable wall >= 100 px (room to fire inside the 140 px fireball range); flyer patrol edge to glide pit >= 120 px run-up; >= 160 px clean runway before every glide pit.
4. **Pits**: normal-jump pits <= 64 px (48-56 used). Glide pits <= 170 px: 136 px for the first, 168 px only as a later one.
5. **Checkpoints** about every 500 px; glide sections may stretch to 560-660 px because of rules 1 and 4. Checkpoint >= 80 px past a pit edge.
6. Flags and items >= 60 px from pit edges, spikes and patrol ranges; no item within 8 px of a checkpoint.
7. **Accepted alternate solve**: in level 3 a carried high jump clears a 96 px burnable wall. Allowed.
8. **Time target "2-3 minutes"** means typical play including deaths (user decision 2026-10-28). Clean runs are ~75 s / ~95 s / ~117 s.

---

## Level 1 "배우기" (L=3200)

Teaching order: walk and jump (spike, platform with heart) → first pit 48 px → a walker with no obstacle (stomp is safe, it gives fire) → two single spikes, pit 56 px → **wall 1** (checkpoint, giver walker, burnable, heart behind) → **wall 2** with a spike right behind → finale walker → goal.

| x | Element | y | Note |
|---|---|---|---|
| 40 | Player start | 268 | |
| 280 | Spike S1 | 275 | |
| 400 | Platform w96 (352-448) | 240 | Heart H1 on it at (400, 222) |
| 520 | Checkpoint CP1 | 268 | |
| 700 | Walker A (patrol 640-760) | 272 | Teaching stomp; fire granted but not needed |
| 880-928 | Pit 1 (48) | – | |
| 1040 | CP2 | 268 | |
| 1160 | Spike S2 | 275 | |
| 1300 | Spike S3 | 275 | |
| 1500 | CP3 | 268 | Before the giver |
| 1660 | Walker B (patrol 1600-1720) | 272 | **Giver: fireball** |
| 1840 | Burnable B1 (1832-1848) | 232 | |
| 1950 | Heart H2 | 262 | Reward behind the wall |
| 2000 | CP4 | 268 | |
| 2200-2256 | Pit 2 (56) | – | Shrink to 48 if kids fall a lot |
| 2360 | CP5 | 268 | Before the giver |
| 2540 | Walker C (patrol 2480-2600) | 272 | **Giver: fireball** |
| 2720 | Burnable B2 (2712-2728) | 232 | |
| 2800 | Spike S4 | 275 | |
| 2880 | CP6 | 268 | |
| 3000 | Walker D (patrol 2940-3060) | 272 | Finale stomp |
| 3140 | Goal flag | 268 | |

Ground: [0-880] [928-2200] [2256-3200].

## Level 2 "새 능력" (L=3800)

Order: warm-up spike → **jumper → high jump → cliff 1** (heart on top) → recap pit 56 px + spike → **flyer → glide → 136 px pit** → jumper → cliff 2 (heart) → **flyer → 168 px pit** → spike → goal.

| x | Element | y | Note |
|---|---|---|---|
| 40 | Player start | 268 | |
| 260 | Spike S1 | 275 | |
| 400 | Platform w96 (352-448) | 240 | Optional |
| 520 | CP1 | 268 | |
| 680 | Jumper J1 | 272 | **Giver: high jump** |
| 840-1000 | Cliff 1 (w160, top 160) | centre 220 | Heart H1 on top (920, 142) |
| 1080 | CP2 | 268 | |
| 1220-1276 | Pit P1 (56) | – | |
| 1440 | Spike S2 | 275 | |
| 1560 | CP3 | 268 | Before the giver |
| 1720 | Flyer F1 (patrol 1640-1800) | 232 | **Giver: glide** |
| 1960-2096 | Glide pit Gp1 (136) | – | |
| 2220 | CP4 | 268 | |
| 2400 | Jumper J2 | 272 | **Giver: high jump** |
| 2560-2688 | Cliff 2 (w128, top 160) | centre 220 | Heart H2 on top (2624, 142) |
| 2800 | CP5 | 268 | Before the giver |
| 2980 | Flyer F2 (patrol 2900-3060) | 232 | **Giver: glide** |
| 3200-3368 | Glide pit Gp2 (168) | – | |
| 3460 | CP6 | 268 | |
| 3580 | Spike S3 | 275 | |
| 3740 | Goal flag | 268 | |

Ground: [0-1220] [1276-1960] [2096-3200] [3368-3800].

## Level 3 "섞어 쓰기" (L=4500)

Six sections alternate fire, glide, high jump, fire, glide, high jump — each one checkpoint, one giver, one obstacle. The flat stretch 4100-4500 is reserved for the boss arena (story 006); until then it ends with the goal flag.

| x | Element | y | Note |
|---|---|---|---|
| 40 | Player start | 268 | |
| 260 | Spike S1 | 275 | |
| 380 | Platform w96 (332-428) | 240 | Optional |
| 480 | CP1 | 268 | |
| 640 | Walker W1 (patrol 580-700) | 272 | **Giver: fireball** |
| 820 | Burnable B1 (812-828) | 232 | |
| 940 | CP2 | 268 | |
| 1100 | Flyer F1 (patrol 1020-1180) | 232 | **Giver: glide** |
| 1340-1508 | Glide pit Gp1 (168) | – | |
| 1600 | CP3 | 268 | |
| 1760 | Jumper J1 | 272 | **Giver: high jump** |
| 1920-2048 | Cliff 1 (w128, top 160) | centre 220 | Heart H1 on top (1984, 142) |
| 2160 | CP4 | 268 | |
| 2250 | Spike S2 | 275 | |
| 2380 | Walker W2 (patrol 2320-2440) | 272 | **Giver: fireball** |
| 2560 | Burnable B2 (2552-2568) | 232 | |
| 2680 | CP5 | 268 | |
| 2840 | Flyer F2 (patrol 2760-2920) | 232 | **Giver: glide** |
| 3080-3248 | Glide pit Gp2 (168) | – | |
| 3340 | CP6 | 268 | |
| 3500 | Jumper J2 | 272 | **Giver: high jump** |
| 3660-3788 | Cliff 2 (w128, top 160) | centre 220 | Heart H2 on top (3724, 142) |
| 3900 | CP7 | 268 | |
| 4080 | Spike S3 | 275 | |
| 4220 | Spike S4 | 275 | |
| 4420 | Goal flag | 268 | Boss hand-over point later |

Ground: [0-1340] [1508-3080] [3248-4500].

---

## Playtest risks

- **Flyer stomp window (biggest risk)**: a normal jump apex reaches only ~20 px into the flyer's height range. A kid who cannot stomp a flyer cannot get glide and cannot finish level 2. User decision 2026-10-28: keep the current height, play first, then decide (option: lower the flyer ~12 px).
- Glide pits: 168 px leaves ~32 px margin; a late glide falls. The first glide pit is 136 px for that reason.
- Cliff top margin is 25-30 px; lower the cliff to 112 px if kids miss.
- A kid who jumps over the giver walker reaches the wall without fire; they can walk back because the walker is still alive. Check that this reads clearly.
- Level 3 is close to a repeat of levels 1 and 2; consider tighter chains in full production.

## Open assumptions to confirm in play

- No fall damage from the 120 px cliff drop (none exists today).
- Platforms are solid from below (head bump).
