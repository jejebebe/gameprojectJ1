-- world.lua — terrain tiles and level props (story 012).
-- Usage (Aseprite batch):
--   Aseprite.exe -b --script-param root=<repo root> --script tools/art/world.lua
-- Writes assets/art/tiles/{ground,block}.png and assets/art/props/*.png (horizontal strips),
--        sources under assets/art_src/{tiles,props}/ (.aseprite with frame durations + _x8 previews),
--        and the review sheet assets/art_src/tiles/world_x4.png (sky #BFEFFF, Jei for scale,
--        plus 9-slice tiling demos). GIFs are made from the .aseprite files with the CLI (--scale 4).
--
-- Style (art-bible §1, §3, §6): no outline (spikes alone get navy_ink), flat colour + one darker
-- shade per material + a 1-2 px top highlight, no dithering or gradients, 24 px tile unit.
-- Every colour is a name from assets/art_src/palette/jei_master.gpl (enforced by lib.color).
--
-- 9-slice margins (source pixels):
--   tiles/ground.png, tiles/block.png  72x72, 8 px all sides (tile the centre)
--   props/burnable.png                 24x96, top 24 / bottom 24 (middle 48 tiles vertically)
--   props/gate.png                     24x72, top 12 / bottom 12 (middle 48 tiles vertically)

local root = app.params["root"]
local lib = dofile(root .. "/tools/art/lib.lua")
lib.init(root)

---------------------------------------------------------------- grid helpers
local function grid(w, h) return { w = w, h = h, p = {} } end
local function set(g, x, y, n)
  if x >= 0 and y >= 0 and x < g.w and y < g.h then g.p[y * g.w + x] = n end
end
local function get(g, x, y)
  if x < 0 or y < 0 or x >= g.w or y >= g.h then return nil end
  return g.p[y * g.w + x]
end
local function copy(g)
  local c = grid(g.w, g.h)
  for k, v in pairs(g.p) do c.p[k] = v end
  return c
end
local function stamp(g, rows, key, ox, oy)
  for r, row in ipairs(rows) do
    for i = 1, #row do
      local ch = row:sub(i, i)
      if ch ~= "." then set(g, ox + i - 1, oy + r - 1, key[ch]) end
    end
  end
end
local function hash(a, b, c)
  local n = (a * 374761393 + b * 668265263 + (c or 0) * 1442695041) & 0x7fffffff
  n = ((n ~ (n >> 13)) * 1274126177) & 0x7fffffff
  n = n ~ (n >> 16)
  return (n % 1000) / 1000
end
-- Clears 2 px rounded corners (3 pixels each) on the chosen corners.
local function round_corners(g, top, bottom)
  local W, H = g.w - 1, g.h - 1
  local function cut(x, y) g.p[y * g.w + x] = nil end
  if top then
    cut(0, 0); cut(1, 0); cut(0, 1)
    cut(W, 0); cut(W - 1, 0); cut(W, 1)
  end
  if bottom then
    cut(0, H); cut(1, H); cut(0, H - 1)
    cut(W, H); cut(W - 1, H); cut(W, H - 1)
  end
end

---------------------------------------------------------------- 1. ground (stone pier)
local function ground()
  local g = grid(72, 72)
  local wave = { [0] = 66, 65, 65, 66, 67, 68, 68, 67 }   -- one sine period per 8 px (divides the 56 px centre)
  for y = 0, 71 do for x = 0, 71 do
    local n = "stone"
    if y <= 1 then n = "cream"
    elseif y == 2 then n = "stone_dark"
    else
      if x == 23 or x == 47 or y == 23 or y == 47 then n = "stone_dark" end
      if y == wave[x % 8] then n = "stone_dark" end
      if x == 0 or x == 71 or y >= 70 then n = "stone_dark" end
    end
    set(g, x, y, n)
  end end
  round_corners(g, true, true)
  return g
end

---------------------------------------------------------------- 2. block (teal tiled roof)
local function block()
  local g = grid(72, 72)
  for y = 0, 71 do for x = 0, 71 do
    local n = "harbour_teal"
    if y <= 1 then n = "cream"
    elseif y == 2 then n = "harbour_teal_dark"
    else
      local u, v = x % 8, y % 8
      if u == 0 or v == 7 or (v == 6 and (u == 1 or u == 7)) then n = "harbour_teal_dark" end
      if x == 0 or x == 71 or y >= 70 then n = "harbour_teal_dark" end
    end
    set(g, x, y, n)
  end end
  round_corners(g, true, true)
  return g
end

---------------------------------------------------------------- 3. spike (only outlined prop)
local function spike()
  local g = grid(24, 16)
  local function inside(x, y)
    if x < 0 or x > 23 or y < 0 or y > 15 then return false end
    local lx = x % 8
    return math.abs(lx - 3.5) <= (y + 1) * 4 / 16
  end
  for y = 0, 15 do for x = 0, 23 do
    if inside(x, y) then
      local edge = y == 15 or not inside(x - 1, y) or not inside(x + 1, y) or not inside(x, y - 1)
      local n
      if edge then n = "navy_ink"
      else
        local right = (x % 8) >= 4
        if y <= 6 then n = right and "dusk_purple" or "enemy_purple"
        else n = right and "stone_dark" or "stone" end
      end
      set(g, x, y, n)
    end
  end end
  return g
end

---------------------------------------------------------------- 4. burnable wall + burn
local SIGN = {
  ".cccccccc.",
  "cccccocccc",
  "ccccoocccc",
  "cccooooccc",
  "ccooaaoocc",
  "ccoaafaocc",
  "ccoaffaocc",
  "cccoaaoccc",
  "cccooooccc",
  ".dddddddd.",
}
local SIGN_KEY = { c = "cream", o = "warn_orange", a = "amber", f = "fire_core", d = "stone_dark" }

local function burnable()
  local g = grid(24, 96)
  local sootTop = { [0] = 84, 80, 86, 82 }
  for y = 0, 95 do for x = 0, 23 do
    local k = math.min(3, x // 6)
    local n = "wood"
    if x == 0 or x == 23 or x % 6 == 5 then n = "wood_dark" end
    if y >= 24 and y == 24 + (k * 17 + 10) % 48 then n = "wood_dark" end          -- plank joints (period 48)
    if y >= 24 and (y - 24) % 24 == 4 and x == 6 * k + 2 then n = "navy_soft" end -- nail dots (period 24)
    if y == 7 and x == 6 * k + 2 then n = "navy_soft" end
    -- top cap: beam
    if y == 0 then n = "cream" elseif y <= 4 then n = "wood" elseif y == 5 then n = "wood_dark" end
    -- base soot
    local st = sootTop[k]
    if y >= st or (y == st - 1 and x % 6 >= 1 and x % 6 <= 3) or y >= 94 then n = "wood_soot" end
    set(g, x, y, n)
  end end
  round_corners(g, true, false)
  stamp(g, SIGN, SIGN_KEY, 7, 9)
  return g
end

local function burn_frames(base)
  local frames = {}
  for f = 1, 6 do
    local g = grid(24, 96)
    local t = f / 6
    for y = 0, 95 do for x = 0, 23 do
      local n0 = get(base, x, y)
      if n0 then
        local k = math.min(3, x // 6)
        local h = hash(k, y // 3, 1)
        local T = 0.15 + (1 - y / 95) * 0.65 + h * 0.2
        local d = T - t
        local h2 = hash(k, y // 4, f)
        local n
        if d <= 0 then n = nil
        elseif d <= 0.08 then n = (h2 > 0.45) and "fire_core" or "amber"
        elseif d <= 0.16 then n = (h2 > 0.5) and "amber" or "warn_orange"
        elseif d <= 0.26 then n = "wood_soot"
        else n = n0 end
        if n then set(g, x, y, n) end
      end
    end end
    -- ember pile on the floor (frames 3-6), only where the wall has burnt away
    if f >= 3 then
      for x = 2, 21 do
        local hgt = math.floor(3.2 - math.abs(x - 11.5) / 4 + hash(x, 9, 2) * 1.5)
        if f == 6 then hgt = hgt - 1 end
        for y = 95 - hgt + 1, 95 do
          if y <= 95 and get(g, x, y) == nil then
            local e = hash(x, y, f + 10)
            local n = "wood_soot"
            if f < 6 then
              if e > 0.75 then n = "amber" elseif e > 0.5 then n = "warn_orange" end
            else
              if e > 0.85 then n = "warn_orange" elseif e > 0.7 then n = "danger_red_dark" end
            end
            set(g, x, y, n)
          end
        end
      end
    end
    -- rising sparks (frames 2-5)
    if f >= 2 and f <= 5 then
      for i = 1, 4 do
        local sx = 2 + math.floor(hash(i, f, 3) * 20)
        local sy = 95 - math.floor((1 - t) * 60) - math.floor(hash(i, f, 4) * 30)
        if get(g, sx, sy) == nil then set(g, sx, sy, (i % 2 == 0) and "fire_core" or "amber") end
      end
    end
    frames[f] = g
  end
  return frames
end

---------------------------------------------------------------- star sparkle helper
local function star(g, cx, cy, size)
  if size <= 1 then set(g, cx, cy, "sky_white"); return end
  for i = 1, size - 1 do
    local n = (i == 1) and "gold_light" or "gold"
    set(g, cx - i, cy, n); set(g, cx + i, cy, n); set(g, cx, cy - i, n); set(g, cx, cy + i, n)
  end
  set(g, cx, cy, "sky_white")
end

---------------------------------------------------------------- pole + base helper
local function pole(g, top, baseY)
  for y = top, baseY - 1 do set(g, 5, y, "navy_soft"); set(g, 6, y, "navy_ink") end
  for y = baseY, g.h - 1 do for x = 1, 10 do
    local n = "stone"
    if y == baseY then n = "cream" end
    if y == g.h - 1 or x == 10 then n = "stone_dark" end
    set(g, x, y, n)
  end end
  set(g, 1, baseY, nil); set(g, 10, baseY, nil)
end

---------------------------------------------------------------- 5. checkpoint
local function checkpoint(active)
  local g = grid(24, 48)
  pole(g, 6, 44)
  for y = 1, 6 do for x = 3, 8 do                                   -- round knob
    if (x - 5.5) ^ 2 + (y - 3.5) ^ 2 <= 2.7 ^ 2 then
      local n = "navy_soft"
      if (x - 5.5) + (y - 3.5) > 1.4 then n = "navy_ink" end
      set(g, x, y, n)
    end
  end end
  set(g, 4, 2, "cream")
  local fill, hi, sh = "cream", "cream", "stone_dark"
  if active then fill, hi, sh = "gold", "gold_light", "amber" end
  for y = 8, 17 do for x = 7, 19 do
    local cut = (x == 19 and y >= 11 and y <= 14) or (x == 18 and y >= 12 and y <= 13)
    if not cut then
      local n = fill
      if y == 8 then n = hi end
      if y == 17 or (x == 18 and (y == 11 or y == 14)) or (x == 17 and (y == 12 or y == 13)) then n = sh end
      set(g, x, y, n)
    end
  end end
  return g
end

local function sparkle_frames()
  local spots = {
    { { 19, 6, 2 }, { 9, 20, 1 } },
    { { 21, 9, 3 }, { 12, 21, 2 } },
    { { 16, 4, 1 }, { 21, 10, 2 }, { 13, 13, 3 } },
    { { 16, 4, 2 }, { 10, 20, 1 }, { 13, 13, 2 } },
  }
  local frames = {}
  for f = 1, 4 do
    local g = checkpoint(true)
    for _, s in ipairs(spots[f]) do star(g, s[1], s[2], s[3]) end
    frames[f] = g
  end
  return frames
end

---------------------------------------------------------------- 6. goal
local function goal_frames()
  local frames = {}
  for f = 0, 3 do
    local g = grid(24, 72)
    pole(g, 12, 66)
    -- medal
    for y = 0, 12 do for x = 0, 12 do
      local dx, dy = x - 6, y - 6
      if dx * dx + dy * dy <= 5.5 ^ 2 then
        local n = "gold"
        if (x + 1 - 6) ^ 2 + (y + 1 - 6) ^ 2 > 5.5 ^ 2 then n = "amber" end
        if (x - 4) ^ 2 + (y - 4) ^ 2 <= 1.6 ^ 2 then n = "gold_light" end
        set(g, x, y, n)
      end
    end end
    stamp(g, { ".c.", "ccc", ".c." }, { c = "cream" }, 6, 6)   -- star on the medal face
    if f == 0 or f == 2 then set(g, 3, 3, "sky_white") end
    -- waving red flag
    for x = 7, 22 do
      local ph = 2 * math.pi * (x - 7) / 14 - f * math.pi / 2
      local amp = (x - 7) / 15 * 2
      local off = math.floor(amp * math.sin(ph) + 0.5)
      local fold = math.cos(ph) < -0.35
      local top = 15 + off
      for r = 0, 11 do
        local cut = x >= 21 and r >= 5 and r <= 6 or (x == 22 and (r == 4 or r == 7))
        if not cut then
          local n = fold and "danger_red_dark" or "danger_red"
          if r == 0 and not fold then n = "cape_red_hi" end
          if r == 11 then n = "danger_red_dark" end
          set(g, x, top + r, n)
        end
      end
    end
    frames[f + 1] = g
  end
  return frames
end

---------------------------------------------------------------- 7. heart
local function heart_frames()
  local function inside(u, v)
    if (u - 4.5) ^ 2 + (v - 5.5) ^ 2 <= 5.0 ^ 2 then return true end
    if (u - 12.5) ^ 2 + (v - 5.5) ^ 2 <= 5.0 ^ 2 then return true end
    if v >= 5 and v <= 17 then
      return math.abs(u - 8.5) <= 8.8 * ((17.4 - v) / 12.4) ^ 0.55
    end
    return false
  end
  local bob = { 0, 1, 1, 1, 0, 0 }
  local spark = { 0, 2, 3, 2, 1, 0 }
  local frames = {}
  for f = 1, 6 do
    local g = grid(24, 24)
    local ox, oy = 3, 2 + bob[f]
    for v = 0, 17 do for u = 0, 17 do
      if inside(u, v) then
        local n = "gold"
        if not inside(u + 1, v) or not inside(u, v + 1) then n = "amber" end
        if (u - 4) ^ 2 + (v - 4) ^ 2 <= 2.2 ^ 2 then n = "gold_light" end
        set(g, ox + u, oy + v, n)
      end
    end end
    set(g, ox + 3, oy + 3, "sky_white")
    if spark[f] > 0 then star(g, 19, 4 + bob[f], spark[f]) end
    frames[f] = g
  end
  return frames
end

---------------------------------------------------------------- 8. gate
local function gate()
  local g = grid(24, 72)
  for y = 0, 71 do for x = 0, 23 do
    local n
    if y <= 11 then                                   -- stone lintel
      n = "stone"
      if y <= 1 then n = "cream" elseif y >= 10 or x == 23 or x == 11 then n = "stone_dark" end
    elseif y >= 60 then                               -- stone sill
      n = "stone"
      if y == 60 then n = "cream" elseif y >= 70 or x == 23 or x == 11 then n = "stone_dark" end
    else                                              -- planks + iron bands (period 24)
      n = "wood"
      if x == 0 or x == 23 or x % 6 == 0 then n = "wood_dark" end
      local r = (y - 12) % 24
      if r == 8 or r == 9 then n = "navy_soft" elseif r == 10 then n = "navy_ink" end
      if r == 9 and (x == 3 or x == 9 or x == 15 or x == 21) then n = "stone_dark" end
      if r == 0 then n = "wood_dark" end
    end
    set(g, x, y, n)
  end end
  round_corners(g, true, true)
  return g
end

---------------------------------------------------------------- build + save
local function make(rel, frames, dur_ms)
  local w, h = frames[1].w, frames[1].h
  local spr = lib.new_sprite(w, h, #frames)
  for i, g in ipairs(frames) do
    local img = lib.image(spr, i)
    for y = 0, h - 1 do for x = 0, w - 1 do
      local n = g.p[y * w + x]
      if n then img:drawPixel(x, y, lib.color(n)) end
    end end
    if dur_ms then spr.frames[i].duration = dur_ms / 1000 end
  end
  lib.finish(spr, rel)
  spr:close()
end

local G_ground, G_block, G_spike = ground(), block(), spike()
local G_burn = burnable()
local F_burn = burn_frames(G_burn)
local F_cp = { checkpoint(false), checkpoint(true) }
local F_spark = sparkle_frames()
local F_goal = goal_frames()
local F_heart = heart_frames()
local G_gate = gate()

make("tiles/ground", { G_ground })
make("tiles/block", { G_block })
make("props/spike", { G_spike })
make("props/burnable", { G_burn })
make("props/burnable_burn", F_burn, 90)
make("props/checkpoint", F_cp)
make("props/checkpoint_sparkle", F_spark, 120)
make("props/goal", F_goal, 150)
make("props/heart", F_heart, 110)
make("props/gate", { G_gate })

---------------------------------------------------------------- 9-slice demo (tile mode)
local function nine(src, w, h, ml, mt, mr, mb)
  local g = grid(w, h)
  local cw, ch = src.w - ml - mr, src.h - mt - mb
  local function map(d, size, srcSize, m0, m1, c)
    if d < m0 then return d end
    if d >= size - m1 then return srcSize - (size - d) end
    return m0 + (d - m0) % c
  end
  for y = 0, h - 1 do for x = 0, w - 1 do
    local sx = map(x, w, src.w, ml, mr, cw)
    local sy = map(y, h, src.h, mt, mb, ch)
    set(g, x, y, get(src, sx, sy))
  end end
  return g
end

---------------------------------------------------------------- review sheet
local SW, SH = 560, 334
local sheet = Image(SW, SH, ColorMode.RGB)
local sky = lib.color("sky")
for y = 0, SH - 1 do for x = 0, SW - 1 do sheet:drawPixel(x, y, sky) end end
local function blit(g, ox, oy)
  for y = 0, g.h - 1 do for x = 0, g.w - 1 do
    local n = g.p[y * g.w + x]
    if n then sheet:drawPixel(ox + x, oy + y, lib.color(n)) end
  end end
end
local ref = Image{ fromFile = root .. "/assets/art/player/jei/default/reference.png" }
local function blit_ref(ox, oy)
  for y = 0, ref.height - 1 do for x = 0, ref.width - 1 do
    local p = ref:getPixel(x, y)
    if app.pixelColor.rgbaA(p) > 0 then sheet:drawPixel(ox + x, oy + y, p) end
  end end
end

-- row 1 (baseline y=76): ground, block, gate, spike, Jei, heart x6, checkpoint x2
blit(G_ground, 4, 4); blit(G_block, 80, 4); blit(G_gate, 156, 4); blit(G_spike, 184, 60)
blit_ref(212, 76 - ref.height)
for i, g in ipairs(F_heart) do blit(g, 264 + (i - 1) * 28, 52) end
for i, g in ipairs(F_cp) do blit(g, 440 + (i - 1) * 28, 28) end
-- row 2 (baseline y=176): burnable + burn x6, goal x4, sparkle x4, Jei
blit(G_burn, 4, 80)
for i, g in ipairs(F_burn) do blit(g, 32 + (i - 1) * 28, 80) end
for i, g in ipairs(F_goal) do blit(g, 204 + (i - 1) * 28, 104) end
for i, g in ipairs(F_spark) do blit(g, 320 + (i - 1) * 28, 128) end
blit_ref(436, 176 - ref.height)
-- row 3: an assembled scene with 9-slice tiling demos (ground y=290)
blit(nine(G_ground, 300, 40, 8, 8, 8, 8), 4, 290)
blit_ref(16, 290 - ref.height)
for i = 0, 2 do blit(G_spike, 80 + i * 24, 274) end
blit(nine(G_gate, 24, 96, 0, 12, 0, 12), 170, 194)
blit(nine(G_burn, 24, 48, 0, 24, 0, 24), 200, 242)
blit(F_cp[2], 230, 242)
blit(F_goal[1], 260, 218)
blit(nine(G_block, 120, 16, 8, 8, 8, 8), 320, 230)
blit(F_heart[1], 368, 204)
blit(nine(G_block, 96, 40, 8, 8, 8, 8), 450, 250)
blit(nine(G_ground, 96, 16, 8, 8, 8, 8), 450, 314)

sheet:resize(SW * 4, SH * 4)
sheet:saveAs(root .. "/assets/art_src/tiles/world_x4.png")
print("wrote world_x4.png")
