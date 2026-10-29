-- backgrounds.lua — parallax backgrounds for levels 1-3 and the boss room, story-012.
-- Usage (Aseprite batch):
--   Aseprite.exe -b --script-param root=<repo root> --script tools/art/backgrounds.lua
-- Writes assets/art/backgrounds/<lvl>/{l0_sky,l1_clouds,l2_far,l3_town}.png (720x320 each),
--        assets/art_src/backgrounds/<lvl>.aseprite (4 layers),
--        assets/art_src/backgrounds/bg_<lvl>_x2.png (360x320 view + Jei + grey ground, x2, review).
-- Reads  assets/art/player/jei/default/reference.png (review images only).
--
-- Rules (design/art/art-bible.md §1, §2, §4, §6, §8): backgrounds recede (light end
-- of the palette, low contrast), flat colour + 1 shade, no outline, no dithering;
-- L0 sky is 3-5 flat horizontal bands. Every layer is 720 px wide and tiles
-- seamlessly: all drawing goes through px(), which wraps x modulo 720.
-- Every colour is a master-palette name (lib.color stops the script otherwise).
-- Suggested Parallax2D scroll_scale.x: L0 0, L1 0.1, L2 0.25, L3 0.5 (§6).

local root = app.params["root"]
local lib = dofile(root .. "/tools/art/lib.lua")
lib.init(root)
local C = lib.color
local pc = app.pixelColor
local W, H = 720, 320
local OUT_ART = root .. "/assets/art/backgrounds/"
local OUT_SRC = root .. "/assets/art_src/backgrounds/"
local floor, max, min = math.floor, math.max, math.min

-- Drawing primitives (all wrap horizontally) -------------------------------
local function new_img()
  local img = Image(W, H, ColorMode.RGB)
  img:clear(pc.rgba(0, 0, 0, 0))
  return img
end
local function px(img, x, y, c)
  if y >= 0 and y < H then img:drawPixel(floor(x) % W, floor(y), c) end
end
local function rect(img, x0, y0, x1, y1, c)
  for y = max(floor(y0), 0), min(floor(y1), H - 1) do
    for x = floor(x0), floor(x1) do img:drawPixel(x % W, y, c) end
  end
end

local seed = 1
local function rnd(n)
  seed = (seed * 1103515245 + 12345) % 2147483648
  return (seed // 65536) % n
end

-- Sky: list of {y_start, colour_name}, flat bands top to bottom.
local function sky(bands)
  local img = new_img()
  for i, b in ipairs(bands) do
    local y1 = (bands[i + 1] and bands[i + 1][1] - 1) or (H - 1)
    rect(img, 0, b[1], W - 1, y1, C(b[2]))
  end
  return img
end

-- Cloud = union of circles {x, y, r} with a flat bottom at `base`. Lit part is
-- the same circles nudged up-left and shrunk; the rest is the one shade.
local function in_circles(cs, x, y, dx, dy, dr)
  for _, c in ipairs(cs) do
    local ex, ey, r = x - (c[1] + dx), y - (c[2] + dy), c[3] + dr
    if r > 0 and ex * ex + ey * ey <= r * r then return true end
  end
  return false
end
local function cloud(img, cx, base, w, h, body, shade)
  local cs = {}
  local rb0 = h * 0.38
  local n = max(2, floor((w - 2 * rb0) / (rb0 * 1.3)))
  local rb = h * 0.38
  for i = 0, n do cs[#cs + 1] = { cx - w / 2 + rb + i * (w - 2 * rb) / n, base - rb, rb } end
  cs[#cs + 1] = { cx - w * 0.12, base - h + h * 0.55, h * 0.55 }
  cs[#cs + 1] = { cx + w * 0.18, base - h * 0.55, h * 0.42 }
  cs[#cs + 1] = { cx - w * 0.33, base - h * 0.45, h * 0.36 }
  local bc, sc = C(body), C(shade)
  for y = floor(base - h - 2), floor(base) do
    for x = floor(cx - w / 2 - 2), floor(cx + w / 2 + 2) do
      if in_circles(cs, x, y, 0, 0, 0) then
        local lit = y <= base - 3 and in_circles(cs, x, y, -2, -3, -1)
        px(img, x, y, lit and bc or sc)
      end
    end
  end
end

-- Half-ellipse hump (islands, mounds, hills); right third shaded.
local function hump(img, cx, base, w, h, body, shade)
  local bc, sc = C(body), C(shade)
  local hw = w / 2
  for y = floor(base - h), floor(base) do
    for x = floor(cx - hw), floor(cx + hw) do
      local ex, ey = (x - cx) / hw, (base - y) / h
      if ex * ex + ey * ey * ey * ey <= 1 then
        px(img, x, y, (ex > 0.4 and sc) or bc)
      end
    end
  end
end

local function sea(img, top, body, glint, n)
  rect(img, 0, top, W - 1, H - 1, C(body))
  local g = C(glint)
  rect(img, 0, top, W - 1, top, g)
  for _ = 1, n do
    local x = rnd(W)
    local y = top + 4 + rnd(H - top - 6)
    local len = 2 + (y - top) // 10 + rnd(4)
    rect(img, x, y, x + len, y, g)
  end
end

-- House: wall from `top` to the image bottom, sloped tile roof above it.
-- o = {x, w, top, roof_h, wall, wall_sh, roof, roof_hi, roof_sh, win, floors}
local function house(img, o)
  local x, w, top, rh = o.x, o.w, o.top, o.roof_h or 14
  local bot = o.bottom or (H - 1)
  rect(img, x, top, x + w - 1, bot, C(o.wall))
  rect(img, x + w - 4, top, x + w - 1, bot, C(o.wall_sh))
  rect(img, x, top, x + w - 1, top + 2, C(o.wall_sh))           -- eave shadow
  local over = 5
  for i = 0, rh - 1 do
    local inset = (rh - 1 - i)
    local c = o.roof
    if i == rh - 1 or i == 0 then c = o.roof_sh
    elseif (rh - 1 - i) % 3 == 0 then c = o.roof_hi end
    rect(img, x - over + inset, top - rh + i, x + w - 1 + over - inset, top - rh + i, C(c))
  end
  -- windows: rows every 30 px, columns every 20 px, 8x11 with a wall mullion
  local wc, ws = C(o.win), C(o.wall_sh)
  local fy = top + 10
  for _ = 1, (o.floors or 2) do
    for wx = x + 8, x + w - 16, 20 do
      rect(img, wx, fy, wx + 7, fy + 10, wc)
      rect(img, wx + 3, fy, wx + 4, fy + 10, C(o.wall))
      rect(img, wx, fy + 11, wx + 7, fy + 11, ws)                -- sill shade
    end
    fy = fy + 30
  end
end

-- Striped awning: 4 px stripes, 6 rows, scalloped last row, 1-row shadow under.
local function awning(img, x, y, w, c1, c2, wall_sh)
  local a, b = C(c1), C(c2)
  for r = 0, 5 do
    for i = 0, w - 1 do
      local c = ((i // 4) % 2 == 0) and a or b
      if r < 5 or (i % 4 == 1 or i % 4 == 2) then px(img, x + i, y + r, c) end
    end
  end
  if wall_sh then rect(img, x + 1, y + 7, x + w - 2, y + 7, C(wall_sh)) end
end

local function laundry(img, xa, xb, y, sag, line, cloths)
  local lc = C(line)
  for x = xa, xb do
    local t = (x - xa) / (xb - xa)
    px(img, x, y + floor(sag * 4 * t * (1 - t) + 0.5), lc)
  end
  local k = 0
  for x = xa + 5, xb - 9, 12 do
    k = k + 1
    local t = (x + 3 - xa) / (xb - xa)
    local yy = y + floor(sag * 4 * t * (1 - t) + 0.5) + 1
    local cl = cloths[(k - 1) % #cloths + 1]
    local hgt = 7 + (k % 2) * 3
    rect(img, x, yy, x + 6, yy + hgt, C(cl[1]))
    rect(img, x, yy + hgt, x + 6, yy + hgt, C(cl[2]))
  end
end

-- Tapered striped lighthouse; right third is the shade side.
local function lighthouse(img, cx, base, hgt, wb, wt, o)
  local sh = hgt / 7
  for y = floor(base - hgt), floor(base) do
    local t = (base - y) / hgt
    local half = floor((wb + (wt - wb) * t) / 2)
    local striped = floor((base - y) / sh) % 2 == 1
    for x = cx - half, cx + half do
      local shade = x > cx + half / 3
      local c
      if striped then c = shade and o.stripe_sh or o.stripe else c = shade and o.body_sh or o.body end
      px(img, x, y, C(c))
    end
  end
  local top = floor(base - hgt)
  local ht = floor(wt / 2)
  rect(img, cx - ht - 3, top - 2, cx + ht + 3, top - 1, C(o.cap))        -- gallery
  rect(img, cx - ht + 1, top - 10, cx + ht - 1, top - 3, C(o.lamp))      -- lamp room
  rect(img, cx - 1, top - 10, cx, top - 3, C(o.cap))                     -- mullion
  for i = 0, 5 do rect(img, cx - ht - 1 + i, top - 11 - i, cx + ht + 1 - i, top - 11 - i, C(o.cap)) end
end

-- Rock mass between x0..x1 whose top follows topf(x); shade on the right edge
-- and a few strata ledges; 1-row highlight on top.
local function cliff(img, x0, x1, topf, body, shade, hi)
  local bc, sc, hc = C(body), C(shade), C(hi)
  for x = x0, x1 do
    local t = floor(topf(x))
    for y = t, H - 1 do
      local c = bc
      if y == t then c = hc elseif x > x1 - 10 - ((y // 9) % 2) * 3 then c = sc end
      px(img, x, y, c)
    end
  end
  for _ = 1, floor((x1 - x0) / 45) do
    local x = x0 + 6 + rnd(max(1, x1 - x0 - 40))
    local t = floor(topf(x))
    local y = t + 12 + rnd(max(1, H - t - 30))
    local len = 10 + rnd(20)
    if floor(topf(x + len)) < y - 4 then rect(img, x, y, x + len, y + 1, sc) end
  end
end

local GULL = { "x.....x", ".xx.xx.", "...x..." }
local function gull(img, x, y, c)
  for r, row in ipairs(GULL) do
    for i = 1, #row do
      if row:sub(i, i) == "x" then px(img, x + i - 1, y + r - 1, C(c)) end
    end
  end
end

local function mound(img, cx, base, w, h, body, shade, hole)
  hump(img, cx, base, w, h, body, shade)
  rect(img, cx - 2, base - h + 1, cx + 1, base - h + 2, C(hole))
  px(img, cx - w / 2 - 3, base, C(body)); px(img, cx - w / 2 - 6, base - 1, C(body))
  px(img, cx + w / 2 + 3, base, C(shade)); px(img, cx + w / 2 + 5, base, C(body))
end

local function lantern(img, x, top, post, glow)
  rect(img, x, top, x + 1, H - 1, C(post))
  rect(img, x - 2, top, x + 3, top + 1, C(post))
  local gx, gy = x + 0.5, top - 8
  for y = gy - 11, gy + 11 do
    for xx = gx - 11, gx + 11 do
      if (xx - gx) ^ 2 + (y - gy) ^ 2 <= 110 then px(img, xx, y, C(glow)) end
    end
  end
  rect(img, x - 3, top - 15, x + 4, top - 14, C("navy_soft"))   -- cap
  rect(img, x - 2, top - 13, x + 3, top - 3, C("amber"))
  rect(img, x - 1, top - 11, x + 2, top - 5, C("fire_core"))
  rect(img, x - 3, top - 2, x + 4, top - 2, C("navy_soft"))
end

-- Levels --------------------------------------------------------------------
local LEVELS = {}

-- L1: morning harbour — coolest, lowest contrast, gulls, 1 house per 360 px.
LEVELS.l1 = function()
  seed = 11
  local l0 = sky({ { 0, "sky" }, { 110, "sky_mist" }, { 210, "sky_white" } })
  local l1 = new_img()
  cloud(l1, 70, 62, 110, 40, "sky_white", "teal_pale")
  cloud(l1, 260, 128, 170, 62, "sky_white", "teal_pale")
  cloud(l1, 450, 54, 90, 30, "sky_white", "teal_pale")
  cloud(l1, 620, 150, 130, 48, "sky_white", "teal_pale")
  local l2 = new_img()
  sea(l2, 214, "sky", "sky_white", 70)
  hump(l2, 110, 214, 140, 18, "teal_pale", "sky")
  hump(l2, 500, 214, 80, 11, "teal_pale", "sky")
  lighthouse(l2, 128, 200, 18, 6, 4, { body = "sky_mist", body_sh = "teal_pale", stripe = "teal_pale",
    stripe_sh = "teal_pale", lamp = "sky_white", cap = "teal_pale" })
  gull(l2, 230, 120, "stone_dark"); gull(l2, 252, 108, "stone_dark"); gull(l2, 610, 90, "stone_dark")
  local l3 = new_img()
  house(l3, { x = 40, w = 98, top = 206, roof_h = 15, wall = "sky_mist", wall_sh = "stone",
    roof = "teal_pale", roof_hi = "sky_mist", roof_sh = "stone_dark", win = "sky", floors = 2 })
  awning(l3, 46, 236, 40, "peach_blush", "cream", "stone")
  house(l3, { x = 420, w = 82, top = 224, roof_h = 13, wall = "cream", wall_sh = "stone",
    roof = "teal_pale", roof_hi = "sky_mist", roof_sh = "stone_dark", win = "sky", floors = 2 })
  for _, x in ipairs({ 210, 270, 330, 560, 640 }) do
    rect(l3, x, 264, x + 3, H - 1, C("stone")); rect(l3, x + 3, 264, x + 3, H - 1, C("stone_dark"))
  end
  return { l0, l1, l2, l3 }
end

-- L2: afternoon rooftops — brighter, more clouds, teal roofs, orange/peach awnings, laundry.
LEVELS.l2 = function()
  seed = 22
  local l0 = sky({ { 0, "sky_deep_water" }, { 70, "sky" }, { 170, "sky_mist" }, { 250, "sky_white" } })
  local l1 = new_img()
  cloud(l1, 40, 96, 150, 66, "sky_white", "sky")
  cloud(l1, 230, 52, 110, 40, "sky_white", "sky")
  cloud(l1, 390, 120, 190, 74, "sky_white", "teal_pale")
  cloud(l1, 580, 66, 120, 46, "sky_white", "sky")
  cloud(l1, 690, 150, 90, 30, "sky_white", "teal_pale")
  local l2 = new_img()
  sea(l2, 196, "sky", "sky_white", 60)
  hump(l2, 160, 196, 220, 34, "teal_pale", "sky")
  hump(l2, 560, 196, 160, 24, "teal_pale", "sky")
  for _, h in ipairs({ { 100, 176 }, { 116, 172 }, { 140, 166 }, { 168, 170 }, { 196, 178 }, { 520, 182 }, { 548, 178 }, { 590, 184 } }) do
    rect(l2, h[1], h[2], h[1] + 8, 196, C("cream"))
    rect(l2, h[1] - 1, h[2] - 3, h[1] + 9, h[2] - 1, C("sky"))
  end
  local l3 = new_img()
  local roof = { roof = "teal_pale", roof_hi = "sky_mist", roof_sh = "stone_dark", win = "sky" }
  local function b(x, w, top, wall, floors)
    house(l3, { x = x, w = w, top = top, roof_h = 15, wall = wall, wall_sh = "stone", roof = roof.roof,
      roof_hi = roof.roof_hi, roof_sh = roof.roof_sh, win = roof.win, floors = floors })
  end
  b(10, 110, 176, "sky_mist", 3)
  b(186, 92, 150, "cream", 4)
  b(380, 120, 190, "sky_white", 3)
  b(566, 100, 162, "cream", 3)
  awning(l3, 18, 216, 44, "amber", "cream", "stone")
  awning(l3, 192, 222, 36, "peach_blush", "cream", "stone")
  awning(l3, 392, 228, 56, "amber", "cream", "stone")
  awning(l3, 574, 204, 40, "peach_blush", "cream", "stone")
  local cloths = { { "sky_white", "stone" }, { "peach_blush", "stone_dark" }, { "teal_pale", "stone_dark" }, { "gold_light", "stone" } }
  laundry(l3, 120, 186, 196, 8, "stone_dark", cloths)
  laundry(l3, 500, 566, 186, 7, "stone_dark", cloths)
  laundry(l3, 666, 730, 200, 6, "stone_dark", cloths)
  return { l0, l1, l2, l3 }
end

-- L3: sunset lighthouse cliff — pale peach/cream sunset (one step paler than the
-- deep pinks so it recedes), many clouds, stone cliff, peach-striped lighthouse.
-- No glide_pink here: it is Jei's glide cape colour and she would vanish on it.
LEVELS.l3 = function()
  seed = 33
  local l0 = sky({ { 0, "peach_blush" }, { 30, "sunset_cloud" }, { 140, "fire_core" }, { 200, "cream" } })
  local l1 = new_img()
  for _, c in ipairs({ { 50, 40, 120, 22 }, { 200, 92, 150, 28 }, { 330, 30, 90, 18 }, { 430, 120, 130, 24 },
    { 560, 60, 160, 30 }, { 690, 140, 100, 20 }, { 120, 160, 80, 16 } }) do
    cloud(l1, c[1], c[2], c[3], c[4], "cream", "peach_blush")
  end
  local l2 = new_img()
  sea(l2, 228, "sunset_cloud", "cream", 50)
  for y = 0, 18 do                                                -- setting sun
    for x = -26, 26 do
      if x * x + (y - 0) ^ 2 <= 26 * 26 then px(l2, 520 + x, 227 - y, C((x * x + y * y <= 400) and "fire_core" or "gold_light")) end
    end
  end
  for i = 0, 6 do rect(l2, 520 - 18 + i * 2, 234 + i * 7, 520 + 18 - i * 2, 235 + i * 7, C("fire_core")) end
  hump(l2, 300, 228, 120, 12, "stone", "peach_blush")
  hump(l2, 680, 228, 70, 8, "stone", "peach_blush")
  local l3 = new_img()
  local function topf(x)
    local base = 176 + floor(3 * math.sin(x / 9))
    if x < 30 then return base + (30 - x) * 3 end
    if x > 250 then return base + (x - 250) * 2 end
    return base
  end
  cliff(l3, 0, 300, topf, "stone", "peach_blush", "cream")
  lighthouse(l3, 140, 177, 96, 30, 20, { body = "cream", body_sh = "stone", stripe = "peach_blush",
    stripe_sh = "sunset_pink", lamp = "fire_core", cap = "dusk_purple" })
  house(l3, { x = 62, w = 44, top = 152, roof_h = 10, wall = "sunset_cloud", wall_sh = "peach_blush",
    roof = "teal_pale", roof_hi = "sky_mist", roof_sh = "stone_dark", win = "gold_light", floors = 1, bottom = 182 })
  house(l3, { x = 430, w = 70, top = 226, roof_h = 12, wall = "sunset_cloud", wall_sh = "peach_blush",
    roof = "teal_pale", roof_hi = "sky_mist", roof_sh = "stone_dark", win = "gold_light", floors = 2 })
  house(l3, { x = 560, w = 60, top = 240, roof_h = 11, wall = "cream", wall_sh = "peach_blush",
    roof = "teal_pale", roof_hi = "sky_mist", roof_sh = "stone_dark", win = "gold_light", floors = 2 })
  for _, m in ipairs({ { 350, 283, 24, 11 }, { 400, 284, 18, 8 }, { 660, 283, 26, 12 } }) do
    mound(l3, m[1], m[2], m[3], m[4], "stone_dark", "peach_blush", "navy_soft")
  end
  return { l0, l1, l2, l3 }
end

-- Boss: just after sunset — dusk purple, cave mouth under the lighthouse, 2 lanterns, sparse.
LEVELS.boss = function()
  seed = 44
  local l0 = sky({ { 0, "dusk_purple" }, { 140, "sunset_pink" }, { 210, "peach_blush" } })
  local l1 = new_img()
  cloud(l1, 120, 70, 140, 18, "glide_pink", "sunset_pink")
  cloud(l1, 420, 110, 110, 16, "glide_pink", "sunset_pink")
  cloud(l1, 640, 40, 90, 14, "glide_pink", "sunset_pink")
  local l2 = new_img()
  sea(l2, 236, "dusk_purple", "peach_blush", 40)
  hump(l2, 200, 236, 110, 10, "sunset_pink", "dusk_purple")
  local l3 = new_img()
  local function topf(x)
    local base = 150 + floor(4 * math.sin(x / 11))
    if x < 440 then return base + (440 - x) * 2 end
    if x > 700 then return base + (x - 700) * 3 end
    return base
  end
  cliff(l3, 360, 760, topf, "dusk_purple", "navy_soft", "sunset_pink")
  lighthouse(l3, 640, 150, 70, 22, 15, { body = "cream", body_sh = "stone", stripe = "peach_blush",
    stripe_sh = "sunset_pink", lamp = "fire_core", cap = "navy_soft" })
  -- cave mouth: round-topped arch, interior navy_soft
  local cx, hw, archTop = 560, 52, 196
  for y = archTop, H - 1 do
    for x = cx - hw, cx + hw do
      local inside = true
      if y < archTop + hw then
        local ex, ey = (x - cx) / hw, (y - (archTop + hw)) / hw
        inside = ex * ex + ey * ey <= 1
      end
      if inside then px(l3, x, y, C("navy_soft")) end
    end
  end
  lantern(l3, 480, 226, "stone_dark", "peach_blush")
  lantern(l3, 642, 226, "stone_dark", "peach_blush")
  for _, m in ipairs({ { 420, 283, 26, 12 }, { 520, 284, 20, 9 }, { 700, 283, 24, 11 }, { 90, 284, 20, 9 } }) do
    mound(l3, m[1], m[2], m[3], m[4], "stone_dark", "dusk_purple", "navy_soft")
  end
  return { l0, l1, l2, l3 }
end

-- Output --------------------------------------------------------------------
local NAMES = { "l0_sky", "l1_clouds", "l2_far", "l3_town" }
local FACTORS = { 0, 0.1, 0.25, 0.5 }

local function savePng(img, path)
  local s = Sprite(img.spec)
  s:newCel(s.layers[1], 1, img, Point(0, 0))
  s:saveAs(path); s:close()
end

local jspr = app.open(root .. "/assets/art/player/jei/default/reference.png")
local jei = Image(jspr.spec); jei:drawSprite(jspr, 1); jspr:close()

local function over(out, src, ox, oy, sx, sw, sh)
  for y = 0, sh - 1 do
    for x = 0, sw - 1 do
      local p = src:getPixel((sx + x) % src.width, y)
      if pc.rgbaA(p) > 0 then out:drawPixel(ox + x, oy + y, p) end
    end
  end
end

local function review(layers, cam, with_jei)
  local out = Image(360, H, ColorMode.RGB)
  for i, img in ipairs(layers) do over(out, img, 0, 0, floor(cam * FACTORS[i]), 360, H) end
  if with_jei then
    local g, gt = pc.rgba(150, 150, 150, 255), pc.rgba(190, 190, 190, 255)
    for y = 280, H - 1 do for x = 0, 359 do out:drawPixel(x, y, (y < 282) and gt or g) end end
    for y = 0, jei.height - 1 do
      for x = 0, jei.width - 1 do
        local p = jei:getPixel(x, y)
        if pc.rgbaA(p) > 0 then out:drawPixel(150 + x, 280 - jei.height + y, p) end
      end
    end
  end
  return out
end

local function scaled(img, k)
  local out = Image(img.width * k, img.height * k, ColorMode.RGB)
  for y = 0, img.height - 1 do
    for x = 0, img.width - 1 do
      local p = img:getPixel(x, y)
      for yy = 0, k - 1 do for xx = 0, k - 1 do out:drawPixel(x * k + xx, y * k + yy, p) end end
    end
  end
  return out
end

app.fs.makeAllDirectories(OUT_SRC)
local scratch = app.params["scratch"]
local sheet = scratch and Image(360 * 4, H, ColorMode.RGB)
local full = scratch and Image(W * 2, H * 4, ColorMode.RGB)
for li, lvl in ipairs({ "l1", "l2", "l3", "boss" }) do
  local layers = LEVELS[lvl]()
  app.fs.makeAllDirectories(OUT_ART .. lvl)
  local spr = Sprite(W, H, ColorMode.RGB)
  for i, img in ipairs(layers) do
    savePng(img, OUT_ART .. lvl .. "/" .. NAMES[i] .. ".png")
    local layer = (i == 1) and spr.layers[1] or spr:newLayer()
    layer.name = NAMES[i]
    local cel = layer:cel(1)
    if cel then cel.image = img; cel.position = Point(0, 0) else spr:newCel(layer, 1, img, Point(0, 0)) end
  end
  spr:saveAs(OUT_SRC .. lvl .. ".aseprite"); spr:close()
  local view = review(layers, 200, true)
  savePng(scaled(view, 2), OUT_SRC .. "bg_" .. lvl .. "_x2.png")
  if scratch then
    sheet:drawImage(view, Point((li - 1) * 360, 0))
    for i, img in ipairs(layers) do
      over(full, img, 0, (li - 1) * H, 0, W, H); over(full, img, W, (li - 1) * H, 0, W, H)
    end
  end
  print("wrote backgrounds/" .. lvl)
end
if scratch then
  savePng(sheet, scratch .. "/bg_sheet.png")
  savePng(full, scratch .. "/bg_full.png")
end
