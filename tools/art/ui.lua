-- HUD and UI art for 제이의 모험 (story-012, design/art/art-bible.md §3 UI grammar, §4, §7).
--
-- Run (Aseprite batch):
--   Aseprite.exe -b --script-param root=<repo> --script tools/art/ui.lua
--
-- Writes assets/art/ui/{hud,icons,panels,buttons}/*.png (1x, single frame),
-- sources under assets/art_src/ui/, and the review sheet assets/art_src/ui/ui_x3.png.
-- Every colour goes through lib.color (master palette only).
--
-- 9-slice margins (left, top, right, bottom) are listed in NINE below and
-- printed at the end of the run.

local root = app.params["root"]
local lib = dofile(root .. "/tools/art/lib.lua")
lib.init(root)

local C = lib.color
local TRANSPARENT = app.pixelColor.rgba(0, 0, 0, 0)

local saved = {}   -- rel -> Image copy (for the review sheet)

------------------------------------------------------------------------------
-- Pixel helpers (all operate on an Image)
------------------------------------------------------------------------------

local function inb(img, x, y) return x >= 0 and y >= 0 and x < img.width and y < img.height end
local function put(img, x, y, name) if inb(img, x, y) then img:drawPixel(x, y, C(name)) end end
local function alpha(img, x, y)
  if not inb(img, x, y) then return 0 end
  return app.pixelColor.rgbaA(img:getPixel(x, y))
end

--- Fills every pixel whose centre satisfies `test(cx, cy)`.
local function fill(img, name, test)
  for y = 0, img.height - 1 do
    for x = 0, img.width - 1 do
      if test(x + 0.5, y + 0.5) then img:drawPixel(x, y, C(name)) end
    end
  end
end

--- Rounded rectangle (x, y, w, h, radius) filled with `name`.
local function rrect(img, x0, y0, w, h, r, name)
  fill(img, name, function(cx, cy)
    if cx < x0 or cy < y0 or cx > x0 + w or cy > y0 + h then return false end
    local qx = math.max(x0 + r - cx, 0, cx - (x0 + w - r))
    local qy = math.max(y0 + r - cy, 0, cy - (y0 + h - r))
    return qx * qx + qy * qy <= r * r
  end)
end

local function circle_test(ox, oy, r)
  return function(cx, cy) return (cx - ox) ^ 2 + (cy - oy) ^ 2 <= r * r end
end

-- Distance from point to segment.
local function seg_dist(px, py, ax, ay, bx, by)
  local dx, dy = bx - ax, by - ay
  local t = ((px - ax) * dx + (py - ay) * dy) / (dx * dx + dy * dy)
  t = math.max(0, math.min(1, t))
  local qx, qy = ax + t * dx - px, ay + t * dy - py
  return math.sqrt(qx * qx + qy * qy)
end

local function in_tri(px, py, a, b, c)
  local function s(p1, p2) return (px - p2[1]) * (p1[2] - p2[2]) - (p1[1] - p2[1]) * (py - p2[2]) end
  local d1, d2, d3 = s(a, b), s(b, c), s(c, a)
  local neg = d1 < 0 or d2 < 0 or d3 < 0
  local pos = d1 > 0 or d2 > 0 or d3 > 0
  return not (neg and pos)
end

--- Test for a triangle with corners rounded by `r` (shrink about the incentre,
--- then grow by r), so its outer size stays the same as the sharp triangle.
local function round_tri(a, b, c, r)
  local la = math.sqrt((b[1] - c[1]) ^ 2 + (b[2] - c[2]) ^ 2)
  local lb = math.sqrt((a[1] - c[1]) ^ 2 + (a[2] - c[2]) ^ 2)
  local lc = math.sqrt((a[1] - b[1]) ^ 2 + (a[2] - b[2]) ^ 2)
  local p = la + lb + lc
  local ix, iy = (la * a[1] + lb * b[1] + lc * c[1]) / p, (la * a[2] + lb * b[2] + lc * c[2]) / p
  local s = p / 2
  local area = math.abs((b[1] - a[1]) * (c[2] - a[2]) - (c[1] - a[1]) * (b[2] - a[2])) / 2
  local k = (area / s - r) / (area / s)
  local function sh(v) return { ix + (v[1] - ix) * k, iy + (v[2] - iy) * k } end
  local A, B, Cc = sh(a), sh(b), sh(c)
  return function(px, py)
    if in_tri(px, py, A, B, Cc) then return true end
    local d = math.min(seg_dist(px, py, A[1], A[2], B[1], B[2]),
                       seg_dist(px, py, B[1], B[2], Cc[1], Cc[2]),
                       seg_dist(px, py, Cc[1], Cc[2], A[1], A[2]))
    return d <= r
  end
end

--- Adds a 2 px outline of `name` around every opaque pixel (8-neighbour pass,
--- then 4-neighbour pass, which gives softly rounded outer corners).
local function outline2(img, name)
  local function pass(diag)
    local add = {}
    for y = 0, img.height - 1 do
      for x = 0, img.width - 1 do
        if alpha(img, x, y) == 0 then
          local hit = alpha(img, x - 1, y) > 0 or alpha(img, x + 1, y) > 0
                   or alpha(img, x, y - 1) > 0 or alpha(img, x, y + 1) > 0
          if diag and not hit then
            hit = alpha(img, x - 1, y - 1) > 0 or alpha(img, x + 1, y - 1) > 0
               or alpha(img, x - 1, y + 1) > 0 or alpha(img, x + 1, y + 1) > 0
          end
          if hit then add[#add + 1] = { x, y } end
        end
      end
    end
    for _, p in ipairs(add) do img:drawPixel(p[1], p[2], C(name)) end
  end
  pass(true)
  pass(false)
end

local function grid(img, rows, key, ox, oy)
  for y, row in ipairs(rows) do
    for x = 1, #row do
      local ch = row:sub(x, x)
      if ch ~= "." then
        local name = key[ch]
        if name == nil then error("no colour for '" .. ch .. "'") end
        put(img, (ox or 0) + x - 1, (oy or 0) + y - 1, name)
      end
    end
  end
end

--- Creates a sprite, lets `draw(img)` paint it, saves it through lib.finish.
local function make(rel, w, h, draw)
  local spr = lib.new_sprite(w, h, 1)
  local img = lib.image(spr, 1)
  draw(img)
  saved[rel] = img:clone()
  lib.finish(spr, "ui/" .. rel)
  spr:close()
end

------------------------------------------------------------------------------
-- 1. HUD (16x16, navy 2 px outline)
------------------------------------------------------------------------------

-- Heart interior (outline added by outline2). h = highlight, f = fill, d = shade, w = glint.
local HEART = {
  "................",
  "..whff....fffd..",
  "..whfff..ffffd..",
  "..hffffffffffd..",
  "..ffffffffffdd..",
  "..ffffffffffdd..",
  "...ffffffffdd...",
  "....ffffffdd....",
  ".....fffffd.....",
  "......ffdd......",
  ".......fd.......",
}

local function heart(key, hollow)
  return function(img)
    grid(img, HEART, key, 0, 2)
    outline2(img, "navy_ink")
    if hollow then
      for y = 0, 15 do for x = 0, 15 do
        -- clear interior: anything not navy
        if alpha(img, x, y) > 0 and img:getPixel(x, y) ~= C("navy_ink") then img:drawPixel(x, y, TRANSPARENT) end
      end end
    end
  end
end

make("hud/heart_full", 16, 16, heart({ w = "fire_core", h = "gold_light", f = "gold", d = "amber" }))
make("hud/heart_empty", 16, 16, heart({ w = "gold", h = "gold", f = "gold", d = "gold" }, true))
make("hud/heart_bonus", 16, 16, function(img)
  heart({ w = "sky_white", h = "sky", f = "sky_deep_water", d = "sea_blue_collar" })(img)
  -- sparkle: a 4-point white star in the right lobe
  put(img, 10, 5, "sky_white"); put(img, 9, 6, "sky_white"); put(img, 10, 6, "sky_white")
  put(img, 11, 6, "sky_white"); put(img, 10, 7, "sky_white")
end)

-- Life icon: Jei's red hood head, simplified.
make("hud/life_icon", 16, 16, function(img)
  grid(img, {
    "................",
    "................",
    ".....hRRRRR.....",
    "...RhhRRRRRR....",
    "..RhRRRRRRRRL...",
    "..RhRRRRRRRRRL..",
    "..RRRHHHHHHRRL..",
    "..RRHssssssHRL..",
    "..RHsessssesHL..",
    "..RHbessssebHL..",
    "..RRsssmmsssRL..",
    "...RRssssssRL...",
    "....LRRRRRRL....",
  }, { h = "cape_red_hi", R = "cape_red_mid", L = "cape_red_lo", H = "hair_mid",
       s = "skin_mid", e = "navy_ink", b = "blush_warm", m = "skin_lo" }, 0, 0)
  outline2(img, "navy_ink")
end)

------------------------------------------------------------------------------
-- 2. Control + ability icons (32x32, no outline, sit on navy buttons)
------------------------------------------------------------------------------

local function shade_bottom(img, from_name, to_name, rows)
  -- recolour the lowest `rows` opaque pixels of each column (1-tone shade)
  for x = 0, img.width - 1 do
    local n = 0
    for y = img.height - 1, 0, -1 do
      if alpha(img, x, y) > 0 and img:getPixel(x, y) == C(from_name) then
        if n < rows then img:drawPixel(x, y, C(to_name)) end
        n = n + 1
      elseif n > 0 then break end
    end
  end
end

make("icons/right", 32, 32, function(img)
  fill(img, "cream", round_tri({ 9, 5 }, { 9, 27 }, { 27, 16 }, 3))
  shade_bottom(img, "cream", "stone", 2)
end)
make("icons/left", 32, 32, function(img)
  fill(img, "cream", round_tri({ 23, 5 }, { 23, 27 }, { 5, 16 }, 3))
  shade_bottom(img, "cream", "stone", 2)
end)

local function up_arrow(head_test)
  return function(cx, cy)
    if head_test(cx, cy) then return true end
    -- stem
    local qx = math.max(12 - cx, 0, cx - 20); local qy = math.max(15 - cy, 0, cy - 26)
    return cx >= 10 and cx <= 22 and cy >= 13 and cy <= 28 and qx * qx + qy * qy <= 4
  end
end

-- Jump: navy + cream only (no stone shade) per art bible §7.
make("icons/jump", 32, 32, function(img)
  fill(img, "cream", up_arrow(round_tri({ 16, 2 }, { 3, 17 }, { 29, 17 }, 2.5)))
end)

make("icons/menu", 32, 32, function(img)
  rrect(img, 8, 6, 6, 20, 3, "cream")
  rrect(img, 18, 6, 6, 20, 3, "cream")
  shade_bottom(img, "cream", "stone", 2)
end)

-- No ability: an empty ring (cream; reads on navy and on the disabled #BDB4A8 button).
make("icons/ability_none", 32, 32, function(img)
  fill(img, "cream", function(cx, cy)
    local d = math.sqrt((cx - 16) ^ 2 + (cy - 16) ^ 2)
    return d <= 11 and d >= 8.2
  end)
  -- faded: every other pixel of the lower half drops to stone (dotted, soft)
  for y = 16, 31 do for x = 0, 31 do
    if alpha(img, x, y) > 0 and (x + y) % 2 == 0 then img:drawPixel(x, y, C("stone_dark")) end
  end end
end)

local function flame(scale, oy)
  local s = scale
  local body = circle_test(16, 21 + oy, 9 * s)
  local tip = round_tri({ 16 - 8.6 * s, 19 + oy }, { 16 + 8.6 * s, 19 + oy }, { 18, 21 + oy - 18 * s }, 2 * s)
  return function(cx, cy) return body(cx, cy) or tip(cx, cy) end
end

make("icons/ability_fireball", 32, 32, function(img)
  fill(img, "warn_orange", flame(1, 0))
  fill(img, "amber", flame(0.68, 2.5))
  fill(img, "fire_core", flame(0.36, 5))
  -- 1-tone shade on the lower-right rim
  for y = 0, 31 do for x = 0, 31 do
    if img:getPixel(x, y) == C("warn_orange") and (x - 16) + (y - 21) > 8 then
      img:drawPixel(x, y, C("cape_orange_lo"))
    end
  end end
end)

make("icons/ability_high_jump", 32, 32, function(img)
  fill(img, "sky_deep_water", up_arrow(round_tri({ 16, 2 }, { 3, 17 }, { 29, 17 }, 2.5)))
  -- left-side highlight, right-side shade (1 tone each)
  for y = 0, 31 do for x = 0, 31 do
    if img:getPixel(x, y) == C("sky_deep_water") then
      if alpha(img, x - 2, y) == 0 or alpha(img, x - 1, y - 1) == 0 then img:drawPixel(x, y, C("sky")) end
      if alpha(img, x + 2, y) == 0 or alpha(img, x, y + 2) == 0 then img:drawPixel(x, y, C("cape_blue_lo")) end
    end
  end end
  -- star (gold, upper right)
  grid(img, {
    "..g..",
    ".ggg.",
    "ggGgg",
    ".g.g.",
  }, { g = "gold", G = "fire_core" }, 25, 0)
end)

make("icons/ability_glide", 32, 32, function(img)
  -- leaf/wing lens along the diagonal from (5,27) to (27,5)
  local k = 1 / math.sqrt(2)
  local d, R = 9, math.sqrt(81 + 15 * 15)
  local c1x, c1y = 16 + d * k, 16 + d * k
  local c2x, c2y = 16 - d * k, 16 - d * k
  fill(img, "glide_pink", function(cx, cy)
    return (cx - c1x) ^ 2 + (cy - c1y) ^ 2 <= R * R and (cx - c2x) ^ 2 + (cy - c2y) ^ 2 <= R * R
  end)
  for y = 0, 31 do for x = 0, 31 do
    if img:getPixel(x, y) == C("glide_pink") then
      local side = (x + 0.5) - (y + 0.5)  -- not used for axis; axis is x + y = 32
      local ax = (x + 0.5) + (y + 0.5) - 32
      if math.abs(ax) < 0.8 and x > 8 and x < 25 then
        img:drawPixel(x, y, C("cape_pink_lo"))                  -- centre vein
      elseif alpha(img, x + 1, y + 1) == 0 or alpha(img, x + 1, y) == 0 and ax > 0 then
        img:drawPixel(x, y, C("cape_pink_lo"))                  -- shaded lower-right rim
      elseif ax < -5 then
        img:drawPixel(x, y, C("cape_pink_hi"))                  -- light upper-left half
      end
      local _ = side
    end
  end end
  -- stem
  put(img, 4, 27, "cape_pink_lo"); put(img, 3, 28, "cape_pink_lo"); put(img, 5, 26, "cape_pink_lo")
end)

------------------------------------------------------------------------------
-- 3. Buttons (48x48 9-slice sources)
------------------------------------------------------------------------------

make("buttons/button_navy", 48, 48, function(img)
  rrect(img, 0, 0, 48, 48, 8, "navy_soft")      -- 4 px thickness shows below
  rrect(img, 0, 0, 48, 44, 8, "navy_ink")
end)
make("buttons/button_navy_pressed", 48, 48, function(img)
  -- moved down 4 px, thickness gone, 2 px cream border
  rrect(img, 0, 4, 48, 44, 8, "cream")
  rrect(img, 2, 6, 44, 40, 6, "navy_ink")
end)
make("buttons/button_disabled", 48, 48, function(img)
  -- flat (no thickness: it cannot be pressed), same footprint as the raised button
  rrect(img, 0, 0, 48, 44, 8, "stone_dark")
end)

------------------------------------------------------------------------------
-- 4. Panels
------------------------------------------------------------------------------

make("panels/panel_cream", 48, 48, function(img)
  rrect(img, 0, 0, 48, 48, 6, "stone")          -- soft rim + 1-row shade below
  rrect(img, 1, 1, 46, 45, 5, "cream")
end)

make("panels/ribbon_red", 96, 24, function(img)
  -- tails (behind), V-notched outer ends
  for y = 5, 22 do
    for x = 0, 13 do
      local notch = 6 * (1 - math.abs(y + 0.5 - 14) / 9)
      if x + 0.5 > notch then
        put(img, x, y, "danger_red_dark"); put(img, 95 - x, y, "danger_red_dark")
      end
    end
  end
  -- fold shadow where the band wraps behind
  for y = 18, 22 do for x = 10, 13 do
    if (x - 10) >= (y - 18) - 1 then put(img, x, y, "cape_red_lo"); put(img, 95 - x, y, "cape_red_lo") end
  end end
  -- main band
  rrect(img, 10, 1, 76, 18, 1, "danger_red")
  for x = 11, 84 do put(img, x, 17, "danger_red_dark"); put(img, x, 18, "danger_red_dark") end
  for x = 12, 83 do put(img, x, 2, "cape_red_mid") end
end)

make("panels/control_panel", 48, 48, function(img)
  fill(img, "cream", function() return true end)
  for x = 0, 47 do put(img, x, 0, "stone"); put(img, x, 1, "stone") end
end)

------------------------------------------------------------------------------
-- 5. Level medals (32x40)
------------------------------------------------------------------------------

local function medal(face)
  return function(img)
    -- ribbon tails behind the medal
    for y = 22, 39 do
      local sp = math.floor((y - 22) / 6)
      for i = 0, 6 do
        local lx, rx = 9 + i - sp, 16 + i + sp
        local function cut(cx) -- V notch at the bottom
          return y >= 37 and math.abs(i - 3) <= (y - 37)
        end
        if not cut() then put(img, lx, y, "danger_red"); put(img, rx, y, "danger_red_dark") end
      end
    end
    -- medal
    fill(img, "amber", circle_test(16, 15, 14))
    fill(img, "gold", circle_test(16, 15, 12))
    fill(img, "gold_light", function(cx, cy)
      local d = math.sqrt((cx - 16) ^ 2 + (cy - 15) ^ 2)
      return d <= 12 and d > 10 and (cx - 16) + (cy - 15) < -6
    end)
    put(img, 8, 8, "fire_core"); put(img, 9, 7, "fire_core")
    face(img)
  end
end

local NAVY = { n = "navy_ink" }
local function big_digit(rows)
  return function(img)
    local scaled = {}
    for _, r in ipairs(rows) do
      local s = r:gsub(".", function(c) return c .. c end)
      scaled[#scaled + 1] = s; scaled[#scaled + 1] = s
    end
    grid(img, scaled, NAVY, 11, 8)
  end
end

make("icons/medal_1", 32, 40, medal(big_digit({
  "..n..", ".nn..", "n.n..", "..n..", "..n..", "..n..", "nnnnn",
})))
make("icons/medal_2", 32, 40, medal(big_digit({
  ".nnn.", "n...n", "....n", "...n.", "..n..", ".n...", "nnnnn",
})))
make("icons/medal_3", 32, 40, medal(function(img)
  -- spiky mole face (boss) + a small "3"
  grid(img, {
    "...k...k...k...",
    "..kk..kkk..kk..",
    "..kkk.kkk.kkk..",
    "..ppppppppppp..",
    ".ppppppppppppp.",
    ".ppwepppppweppq",
    ".ppeepppppeepq.",
    ".pbbppnnnppbbq.",
    "..pppppnppppq..",
    "...qqqqqqqqq...",
  }, { k = "navy_ink", p = "enemy_purple", q = "dusk_purple", w = "sky_white", e = "navy_ink",
       b = "peach_blush", n = "sunset_pink" }, 9, 5)
  grid(img, { "nnn", "..n", ".nn", "..n", "nnn" }, NAVY, 15, 19)
end))

------------------------------------------------------------------------------
-- 9-slice margins (left, top, right, bottom), for the programmer
------------------------------------------------------------------------------

local NINE = {
  { "buttons/button_navy", 12, 12, 12, 12 },
  { "buttons/button_navy_pressed", 12, 12, 12, 12 },
  { "buttons/button_disabled", 12, 12, 12, 12 },
  { "panels/panel_cream", 8, 8, 8, 8 },
  { "panels/ribbon_red", 16, 0, 16, 0 },
  { "panels/control_panel", 0, 2, 0, 0 },
}
for _, n in ipairs(NINE) do
  print(string.format("9-slice %s: left %d top %d right %d bottom %d", n[1], n[2], n[3], n[4], n[5]))
end

------------------------------------------------------------------------------
-- Review sheet (1x layout, saved x3)
------------------------------------------------------------------------------

--- Draws `src` stretched to w x h with 9-slice margins (l, t, r, b).
local function nine(dst, src, l, t, r, b, dx, dy, w, h)
  local sw, sh = src.width, src.height
  local function map(v, size, a, z, s)
    if v < a then return v end
    if v >= size - z then return s - (size - v) end
    return a + math.floor((v - a) * (s - a - z) / (size - a - z))
  end
  for y = 0, h - 1 do for x = 0, w - 1 do
    local px = src:getPixel(map(x, w, l, r, sw), map(y, h, t, b, sh))
    if app.pixelColor.rgbaA(px) > 0 then dst:drawPixel(dx + x, dy + y, px) end
  end end
end

local W, H = 440, 300
local sheet = Image(W, H, ColorMode.RGB)
local function band(x, y, w, h, name)
  for yy = y, y + h - 1 do for xx = x, x + w - 1 do put(sheet, xx, yy, name) end end
end
local function blit(rel, x, y) sheet:drawImage(saved[rel], Point(x, y)) end

band(0, 0, W, H, "stone")

-- Row A: HUD on level-1 sky and on sunset pink (as on the HUD: 8 px margin)
for i, bg in ipairs({ "sky", "sunset_pink" }) do
  local y = (i - 1) * 32
  band(0, y, W, 32, bg)
  local x = 8
  for _, h in ipairs({ "heart_full", "heart_full", "heart_bonus", "heart_empty" }) do
    blit("hud/" .. h, x, y + 8); x = x + 18
  end
  blit("hud/life_icon", W - 8 - 16 - 20, y + 8)
  blit("hud/heart_empty", 120, y + 8); blit("hud/life_icon", 140, y + 8)
end

-- Row B: control + ability icons on navy buttons (64x64 touch target drawn at 1x 48)
local icons = { "left", "right", "jump", "ability_none", "ability_fireball", "ability_high_jump",
                "ability_glide", "menu" }
for i, n in ipairs(icons) do
  local x, y = 4 + (i - 1) * 54, 70
  local base = (n == "ability_none") and "buttons/button_disabled" or "buttons/button_navy"
  blit(base, x, y)
  blit("icons/" .. n, x + 8, y + 6)
end
-- pressed state demo
blit("buttons/button_navy_pressed", 4, 124); blit("icons/jump", 12, 134)
blit("buttons/button_navy", 58, 124)
blit("buttons/button_disabled", 112, 124)

-- Row C: 9-slice stretch tests on the cream control panel
nine(sheet, saved["panels/control_panel"], 0, 2, 0, 0, 170, 124, 270, 70)
nine(sheet, saved["buttons/button_navy"], 12, 12, 12, 12, 180, 134, 140, 36)
nine(sheet, saved["buttons/button_navy_pressed"], 12, 12, 12, 12, 330, 134, 100, 36)
blit("icons/jump", 239, 136); blit("icons/menu", 364, 138)

-- Row D: menu panel with ribbon title and medals (on sky)
band(0, 180, 170, 120, "sky")
band(170, 194, 270, 106, "sky")
nine(sheet, saved["panels/panel_cream"], 8, 8, 8, 8, 10, 196, 400, 96)
nine(sheet, saved["panels/ribbon_red"], 16, 0, 16, 0, 110, 184, 200, 24)
blit("icons/medal_1", 40, 230); blit("icons/medal_2", 90, 230); blit("icons/medal_3", 140, 230)
blit("panels/ribbon_red", 200, 230)
blit("panels/panel_cream", 330, 226)
nine(sheet, saved["buttons/button_navy"], 12, 12, 12, 12, 200, 258, 120, 28)

sheet:resize(W * 3, H * 3)
sheet:saveAs(root .. "/assets/art_src/ui/ui_x3.png")
print("wrote review sheet ui_x3.png")
