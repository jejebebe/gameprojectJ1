-- boss.lua — draws the boss "가시 두더지" (spiky mole) animations, story-011.
-- Usage (Aseprite batch):
--   Aseprite.exe -b --script-param root=<repo root> --script tools/art/boss.lua
-- Writes assets/art/enemies/boss/v2/<anim>.png (horizontal strips),
--        assets/art_src/enemies/boss/<anim>.aseprite,
--        assets/art_src/enemies/boss/boss_x3.png (all frames + Jei, review),
--        assets/art_src/enemies/boss/boss_x6.png (key poses + Jei, review).
-- Reads  assets/art/player/jei/default/reference.png (review sheets only).
--
-- Style follows Jei's final art (art-bible §5): black 1px outline, 1-2 shade
-- steps, big eyes with white highlight. Every colour must be in
-- assets/art_src/palette/jei_character.gpl; an unknown hex stops the script.
-- Drawing is procedural: each body part is a mask whose 4-neighbour border
-- becomes the outline, so every part carries its own 1px line.
-- Boss faces LEFT; belly sits on the bottom row of the 72x60 frame.

local root = app.params["root"]
local OUT_ART = root .. "/assets/art/enemies/boss/v2/"
local OUT_SRC = root .. "/assets/art_src/enemies/boss/"
app.fs.makeAllDirectories(OUT_ART)
app.fs.makeAllDirectories(OUT_SRC)

-- Character palette check -------------------------------------------------
local PAL = {}
do
  local path = root .. "/assets/art_src/palette/jei_character.gpl"
  local f = assert(io.open(path, "r"), "palette not found: " .. path)
  for line in f:lines() do
    local hex = line:match("^%s*%d+%s+%d+%s+%d+%s+(%x%x%x%x%x%x)")
    if hex then PAL[hex:upper()] = true end
  end
  f:close()
end
local cache = {}
local function px(hex)
  local c = cache[hex]
  if c then return c end
  if not PAL[hex] then error("colour not in jei_character.gpl: " .. hex) end
  c = app.pixelColor.rgba(tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16),
                          tonumber(hex:sub(5, 6), 16), 255)
  cache[hex] = c
  return c
end

-- Colours (all from jei_character.gpl)
local OUT, EYE, EYE2, WHITE = "010101", "272729", "4E3C39", "FEFEFE"
local NOSE, NOSE_HI, MOUTH, TONGUE, BLUSH = "E67674", "FEB6A7", "961824", "E67674", "FEAD9E"
local STAR, STAR2, DUSTLINE = "FFF3A0", "FFB347", "8D7668"
local BR_HI, BR, BR_LO = "B07A52", "8A5A3C", "64402C"
local CR, CR_LO, PU, PU_LO = "F6EEE4", "DCC9B4", "9060A8", "6E4A6A"

-- Canvas & shape helpers ---------------------------------------------------
local function canvas(w, h) return { w = w, h = h, p = {} } end
local function put(C, x, y, hex)
  if x >= 0 and y >= 0 and x < C.w and y < C.h then C.p[y * C.w + x] = hex end
end
local function stamp(C, x0, y0, rows, key)
  for y, row in ipairs(rows) do
    for x = 1, #row do
      local ch = row:sub(x, x)
      if ch ~= "." then put(C, x0 + x - 1, y0 + y - 1, key[ch]) end
    end
  end
end

--- Fills every pixel whose centre passes `test`; the mask's 4-neighbour
--- border gets `line` (no border when line is nil), the rest `fill(x, y)`.
local function part(C, test, fill, line)
  local m, w = {}, C.w
  for y = 0, C.h - 1 do
    for x = 0, w - 1 do
      if test(x + 0.5, y + 0.5) then m[y * w + x] = true end
    end
  end
  local function inm(x, y) return x >= 0 and y >= 0 and x < w and y < C.h and m[y * w + x] end
  for k in pairs(m) do
    local x, y = k % w, k // w
    if line and not (inm(x - 1, y) and inm(x + 1, y) and inm(x, y - 1) and inm(x, y + 1)) then
      C.p[k] = line
    else
      C.p[k] = fill(x + 0.5, y + 0.5)
    end
  end
end

local function ell(cx, cy, rx, ry)
  return function(x, y)
    local u, v = (x - cx) / rx, (y - cy) / ry
    return u * u + v * v <= 1
  end
end

local function tri(ax, ay, bx, by, cx, cy)
  return function(x, y)
    local d1 = (x - bx) * (ay - by) - (ax - bx) * (y - by)
    local d2 = (x - cx) * (by - cy) - (bx - cx) * (y - cy)
    local d3 = (x - ax) * (cy - ay) - (cx - ax) * (y - ay)
    local neg = d1 < 0 or d2 < 0 or d3 < 0
    local pos = d1 > 0 or d2 > 0 or d3 > 0
    return not (neg and pos)
  end
end

local LX, LY = -0.6, -0.8 -- light from the top-left (screen coords)

--- One spike: cream body, purple tip, shaded on the side away from the light.
local function spike(C, bx, by, tx, ty, w, back)
  local dx, dy = tx - bx, ty - by
  local L = math.sqrt(dx * dx + dy * dy)
  local ux, uy = dx / L, dy / L
  local nx, ny = -uy, ux
  local lit = nx * LX + ny * LY
  if math.abs(lit) < 0.05 then lit = 1 end
  local test = tri(bx + nx * w, by + ny * w, bx - nx * w, by - ny * w, tx, ty)
  part(C, test, function(x, y)
    local t = ((x - bx) * ux + (y - by) * uy) / L
    local s = (x - bx) * nx + (y - by) * ny
    local shade = s * lit < -0.4
    if t > 0.64 then
      return (back or shade) and PU_LO or PU
    end
    if back then return CR_LO end
    return shade and CR_LO or CR
  end, OUT)
end

--- Fan of spikes on the back: `n` front spikes from angle a0 to a1 (degrees,
--- 0 = right, 90 = up) plus a darker back row between them.
local function fan(C, cx, cy, rx, ry, S)
  local function row(n, a0, a1, len, w, back)
    for i = 0, n - 1 do
      local a = math.rad(n == 1 and a0 or a0 + (a1 - a0) * i / (n - 1))
      local c, s = math.cos(a), math.sin(a)
      spike(C, cx + rx * 0.7 * c, cy - ry * 0.7 * s,
            cx + (rx + len) * c, cy - (ry + len) * s, w, back)
    end
  end
  local half = (S.a1 - S.a0) / (S.n - 1) / 2
  row(S.n - 1, S.a0 + half, S.a1 - half, S.len * 0.82, S.w, true)
  row(S.n, S.a0, S.a1, S.len, S.w, false)
end

--- Big cream shovel paw; `ang` is the claw direction in degrees.
local function paw(C, x, y, ang, base)
  local a = math.rad(ang)
  local ca, sa = math.cos(a), -math.sin(a)
  local nx, ny = -sa, ca
  local claws = {}
  for i = -1, 1 do
    claws[#claws + 1] = { x + ca * 5.2 + nx * i * 3.1, y + sa * 5.2 + ny * i * 3.1 }
  end
  base = base or 60
  part(C, function(px_, py_)
    if py_ > base then return false end
    local dx, dy = px_ - x, py_ - y
    local p, q = dx * ca + dy * sa, dx * nx + dy * ny
    if (p / 5.4) ^ 2 + (q / 5.0) ^ 2 <= 1 then return true end
    for _, c in ipairs(claws) do
      if (px_ - c[1]) ^ 2 + (py_ - c[2]) ^ 2 <= 2.5 ^ 2 then return true end
    end
    return false
  end, function(px_, py_)
    local dx, dy = px_ - x, py_ - y
    return (dx * 0.6 + dy * 0.8 > 1.8) and CR_LO or CR
  end, OUT)
  -- claw gaps
  for _, i in ipairs({ -0.5, 0.5 }) do
    put(C, math.floor(x + ca * 7 + nx * i * 3.1), math.floor(y + sa * 7 + ny * i * 3.1), OUT)
  end
end

local function star(C, x, y, big)
  local key = { a = OUT, Y = STAR, L = STAR2, W = WHITE }
  if big then
    stamp(C, x - 3, y - 3, { "...a...", "..aYa..", ".aYWYa.", "aYWYYLa", ".aYYLa.", "..aLa..", "...a..." }, key)
  else
    stamp(C, x - 2, y - 2, { "..a..", ".aYa.", "aYYLa", ".aLa.", "..a.." }, key)
  end
end

--- Face: eyes, nose, mouth, blush, brows. `o` = { eyes=, mouth=, brows=, blush= }.
local function face(C, cx, cy, rx, ry, o)
  local e1 = math.floor(cx - rx * 0.66)
  local e2 = math.floor(cx - rx * 0.22)
  local ey = math.floor(cy - ry * 0.42)
  local nxp, nyp = math.floor((e1 + e2) / 2), ey + 5
  local my = nyp + 3
  -- blush first (under everything else)
  local bw = o.blush or 3
  for i = 0, bw - 1 do
    put(C, e1 - 2 - i + 1, ey + 5, BLUSH); put(C, e2 + 1 + i, ey + 5, BLUSH)
    if bw > 3 then put(C, e1 - 1 - i + 1, ey + 6, BLUSH); put(C, e2 + i, ey + 6, BLUSH) end
  end
  for idx, e in ipairs({ e1, e2 }) do
    local mode = o.eyes or "open"
    if mode == "open" or mode == "squint" then
      local ryy = (mode == "squint") and 2.4 or 3.6
      local oy = (mode == "squint") and 1 or 0
      part(C, ell(e + 0.5, ey + 0.5 + oy, 2.8, ryy), function(_, y)
        return (y > ey + 1.5 + oy) and EYE2 or EYE
      end, OUT)
      put(C, e - 1, ey - 2 + oy + (mode == "squint" and 1 or 0), WHITE)
      put(C, e, ey - 2 + oy + (mode == "squint" and 1 or 0), WHITE)
      if mode == "open" then put(C, e - 1, ey - 1, WHITE); put(C, e, ey - 1, WHITE) end
      put(C, e + 1, ey + 2 + oy, WHITE)
    elseif mode == "spiral" then
      stamp(C, e - 3, ey - 3, { ".aaaa..", "a....a.", "a.aa..a", "a.a.a.a", "a..a..a", ".a...a.", "..aaa.." }, { a = OUT })
    elseif mode == "hurt" then
      local rows = (idx == 1) and { "aa....", "..aa..", "....aa", "..aa..", "aa...." }
                                or { "....aa", "..aa..", "aa....", "..aa..", "....aa" }
      stamp(C, e - 2, ey - 2, rows, { a = OUT })
    end
  end
  if o.brows then
    stamp(C, e1 - 3, ey - 7, { "aa....", "..aa..", "....a." }, { a = OUT })
    stamp(C, e2 - 2, ey - 7, { "....aa", "..aa..", ".a...." }, { a = OUT })
  end
  -- nose
  part(C, ell(nxp + 0.5, nyp + 0.5, 3.2, 2.4), function() return NOSE end, OUT)
  put(C, nxp - 1, nyp - 1, NOSE_HI); put(C, nxp, nyp - 1, NOSE_HI)
  -- mouth
  local m = o.mouth or "w"
  if m == "w" then
    stamp(C, nxp - 3, my, { "a..a..a", ".aa.aa." }, { a = OUT })
  elseif m == "open" then
    part(C, ell(nxp + 0.5, my + 2, 2.7, 2.4), function(_, y)
      return (y > my + 2.5) and TONGUE or MOUTH
    end, OUT)
  elseif m == "line" then
    stamp(C, nxp - 2, my + 1, { "aaaaa" }, { a = OUT })
  elseif m == "puff" then
    stamp(C, nxp - 1, my + 1, { "aaa" }, { a = OUT })
  elseif m == "wavy" then
    stamp(C, nxp - 3, my + 1, { ".a...a.", "a.a.a.a" }, { a = OUT })
  end
end

--- The mole in a standing pose. o: cx, rx, ry, spikes{n,a0,a1,len,w},
--- paws{{x,y,ang},...} (absolute, far paw first), face{...}.
local function mole(C, o)
  local base = 60
  local cx, rx, ry = o.cx, o.rx, o.ry
  local cy = base - ry * 0.62
  fan(C, cx, cy, rx, ry, o.spikes)
  -- body dome
  part(C, function(x, y)
    local u, v = (x - cx) / rx, (y - cy) / ry
    return y < base and u * u + v * v <= 1
  end, function(x, y)
    local u, v = (x - cx) / rx, (y - cy) / ry
    local s = -0.55 * u - 0.8 * v
    if s > 0.62 then return BR_HI elseif s < -0.3 then return BR_LO end
    return BR
  end, OUT)
  -- cream face + belly (no line: colour edge like Jei's face against hair)
  local fcx, fcy, frx, fry = cx - rx * 0.46, cy - ry * 0.02, rx * 0.52, ry * 0.74
  part(C, function(x, y)
    local u, v = (x - cx) / (rx - 1.2), (y - cy) / (ry - 1.2)
    local fu, fv = (x - fcx) / frx, (y - fcy) / fry
    return y < base - 1 and u * u + v * v <= 1 and fu * fu + fv * fv <= 1
  end, function(x, y)
    if (x - fcx) / frx > 0.5 or y > base - 5 then return CR_LO end
    return CR
  end, nil)
  face(C, cx, cy, rx, ry, o.face or {})
  if o.paws then
    for _, p in ipairs(o.paws) do paw(C, p[1], p[2], p[3]) end
  end
  return cy
end

local function lerp(a, b, t) return a + (b - a) * t end

-- Animations ----------------------------------------------------------------
local CX = 34
local function restPaws(cx, rx, dy)
  dy = dy or 0
  return { { cx - rx * 0.32, 55 + dy, 185 }, { cx - rx * 0.82, 54.5 + dy, 195 } }
end

local ANIMS = {}

ANIMS[#ANIMS + 1] = { name = "idle", w = 72, h = 60, n = 4, ms = 180, draw = function(C, f)
  local k = ({ 0, 0.6, 1, 0.6 })[f]
  local rx, ry = 26 - 0.4 * k, 24 + k
  mole(C, { cx = CX, rx = rx, ry = ry,
    spikes = { n = 7, a0 = 8, a1 = 116, len = 10 + 0.5 * k, w = 6.2 },
    paws = restPaws(CX, 26), face = { eyes = "open", mouth = "w" } })
end }

ANIMS[#ANIMS + 1] = { name = "shake", w = 72, h = 60, n = 8, ms = 50, draw = function(C, f)
  local dx = ({ -1, 1, -2, 1, -1, 2, -1, 1 })[f]
  local j = (f % 2 == 0) and 1 or 0
  local cx, rx, ry = CX + dx, 26, 24
  local cy = 60 - ry * 0.62
  mole(C, { cx = cx, rx = rx, ry = ry,
    spikes = { n = 7, a0 = 10 + j * 3, a1 = 116 + j * 3, len = 10.5, w = 6.2 },
    paws = { { cx - rx * 0.12, cy - ry * 0.02 - j, 75 }, { cx - rx * 0.88, cy - ry * 0.12 + j, 115 } },
    face = { eyes = "open", mouth = "open", brows = true } })
end }

ANIMS[#ANIMS + 1] = { name = "crouch", w = 72, h = 60, n = 6, ms = 70, draw = function(C, f)
  local t = ({ 0, 0.2, 0.45, 0.7, 0.9, 1 })[f]
  local rx, ry = 26 * (1 + 0.08 * t), 24 * (1 - 0.25 * t)
  local r = restPaws(CX, 26)
  local cy = 60 - ry * 0.62
  mole(C, { cx = CX, rx = rx, ry = ry,
    spikes = { n = 7, a0 = 8 + 8 * t, a1 = 116 - 4 * t, len = 10 - 1.5 * t, w = 6.2 },
    paws = { { lerp(r[1][1], CX - rx * 0.45, t), lerp(r[1][2], 56.5, t), lerp(185, 245, t) },
             { lerp(r[2][1], CX - rx * 0.95, t), lerp(r[2][2], 56, t), lerp(195, 235, t) } },
    face = { eyes = (t > 0.3) and "squint" or "open", mouth = (t > 0.3) and "line" or "w", brows = t > 0.3 } })
  if t >= 0.7 then -- dirt clods kicked up by the digging paws
    local o = (f - 4) * 2
    for _, c in ipairs({ { CX - rx * 0.95 - 8 - o, 50 - o }, { CX - rx * 0.45 - 3 - o, 47 - o * 1.5 } }) do
      local x, y = math.floor(c[1]), math.floor(c[2])
      stamp(C, x, y, { ".aa.", "abba", "abca", ".aa." }, { a = OUT, b = BR, c = BR_LO })
    end
  end
  return cy
end }

ANIMS[#ANIMS + 1] = { name = "puff", w = 72, h = 60, n = 8, ms = 60, draw = function(C, f)
  local t = ({ 0, 0.15, 0.35, 0.55, 0.75, 0.9, 1, 1 })[f]
  local rx, ry = 26 + 1.5 * t, 24 + 2 * t
  local cy = 60 - ry * 0.62
  mole(C, { cx = CX, rx = rx, ry = ry,
    spikes = { n = 7, a0 = 8 + 17 * t, a1 = 116 + 24 * t, len = 10 + 3.5 * t, w = 6.2 + 0.6 * t },
    paws = { { CX - rx * 0.3, 55, 185 }, { CX - rx * 0.86 - 2 * t, lerp(54.5, cy + 2, t), lerp(195, 150, t) } },
    face = { eyes = "open", mouth = (t > 0.3) and "puff" or "w", brows = t > 0.3, blush = (t > 0.3) and 4 or 3 } })
end }

ANIMS[#ANIMS + 1] = { name = "roll", w = 72, h = 60, n = 8, ms = 60, draw = function(C, f)
  local cx, cy, r = 36, 30, 21
  local ph = (f - 1) * 45 -- rolling left = counter-clockwise on screen
  -- speed lines behind (right side)
  for i, y in ipairs({ 18, 30, 42 }) do
    local x0 = 63 + ((f + i) % 3)
    for x = x0, math.min(71, x0 + 5 - i % 2) do put(C, x, y, CR_LO) end
  end
  for i = 0, 9 do
    local a = math.rad(ph + i * 36)
    local c, s = math.cos(a), math.sin(a)
    spike(C, cx + r * 0.7 * c, cy - r * 0.7 * s, cx + (r + 8) * c, cy - (r + 8) * s, 5.2, i % 2 == 1)
  end
  part(C, ell(cx, cy, r, r), function(x, y)
    local u, v = (x - cx) / r, (y - cy) / r
    local s = -0.55 * u - 0.8 * v
    if s > 0.6 then return BR_HI elseif s < -0.3 then return BR_LO end
    return BR
  end, OUT)
  -- tucked cream belly with curled paws, rotating with the ball
  local a = math.rad(ph + 200)
  local pcx, pcy = cx + math.cos(a) * r * 0.42, cy - math.sin(a) * r * 0.42
  part(C, function(x, y)
    local u, v = (x - cx) / (r - 1.2), (y - cy) / (r - 1.2)
    return u * u + v * v <= 1 and ((x - pcx) ^ 2 + (y - pcy) ^ 2) <= (r * 0.55) ^ 2
  end, function(x, y)
    return ((x - pcx) * 0.6 + (y - pcy) * 0.8 > 3) and CR_LO or CR
  end, nil)
  for _, d in ipairs({ -40, 40 }) do
    local b = math.rad(ph + 200 + d)
    local qx, qy = cx + math.cos(b) * r * 0.62, cy - math.sin(b) * r * 0.62
    part(C, ell(qx, qy, 3.6, 3.6), function(x, y)
      return ((x - qx) * 0.6 + (y - qy) * 0.8 > 1) and CR_LO or CR
    end, OUT)
  end
end }

ANIMS[#ANIMS + 1] = { name = "jump", w = 72, h = 60, n = 4, ms = 100, draw = function(C, f)
  local k = ({ 0, 1, 2, 1 })[f]
  local cx, rx, ry = CX + 1, 22, 29
  local cy = 60 - ry * 0.62
  mole(C, { cx = cx, rx = rx, ry = ry,
    spikes = { n = 7, a0 = 0, a1 = 112, len = 10 + 0.5 * k, w = 5.6 },
    paws = { { cx - rx * 0.15, cy - ry * 0.78 - k, 80 }, { cx - rx * 0.92, cy - ry * 0.62 - k, 125 } },
    face = { eyes = "open", mouth = "open" } })
end }

ANIMS[#ANIMS + 1] = { name = "dazed", w = 72, h = 60, n = 8, ms = 110, draw = function(C, f)
  local dx = ({ 0, 1, 1, 0, 0, -1, -1, 0 })[f]
  local cx, rx, ry = CX + dx, 26, 23.5
  local cy = 60 - ry * 0.62
  mole(C, { cx = cx, rx = rx, ry = ry,
    spikes = { n = 7, a0 = 8, a1 = 112, len = 9.5, w = 6.2 },
    paws = restPaws(CX, 26, 0.5), face = { eyes = "spiral", mouth = "wavy" } })
  -- three stars circling above the head (front ones drawn last and bigger)
  local scx, scy = CX - 8, 9
  local stars = {}
  for i = 0, 2 do
    local a = math.rad((f - 1) * 15 + i * 120)
    stars[#stars + 1] = { scx + math.cos(a) * 13, scy + math.sin(a) * 4, math.sin(a) }
  end
  table.sort(stars, function(p, q) return p[3] < q[3] end)
  for _, s in ipairs(stars) do star(C, math.floor(s[1] + 0.5), math.floor(s[2] + 0.5), s[3] > -0.2) end
end }

ANIMS[#ANIMS + 1] = { name = "hurt", w = 72, h = 60, n = 4, ms = 70, draw = function(C, f)
  local dx = ({ 2, 3, 2, 1 })[f]
  local sq = ({ 1.5, 2, 1, 0.5 })[f]
  local cx, rx, ry = CX + dx, 26 + sq * 0.5, 24 - sq
  local cy = 60 - ry * 0.62
  mole(C, { cx = cx, rx = rx, ry = ry,
    spikes = { n = 7, a0 = 16, a1 = 120, len = 10, w = 6.2 },
    paws = { { cx + rx * 0.12, cy - ry * 0.8, 80 }, { cx - rx * 0.9, cy - ry * 0.35, 140 } },
    face = { eyes = "hurt", mouth = "open" } })
end }

ANIMS[#ANIMS + 1] = { name = "dust", w = 24, h = 24, n = 8, ms = 60, draw = function(C, f)
  local t = (f - 1) / 7
  local spread = 3 + 7.5 * t
  local rr = (t < 0.45) and (3 + 6.5 * t) or (5.9 - 7 * (t - 0.45))
  local yy = 19.5 - 7 * t
  local blobs = { { 12 - spread, yy + 1.5, rr * 0.85 }, { 12, yy - 2 * t, rr }, { 12 + spread, yy + 1.5, rr * 0.85 } }
  part(C, function(x, y)
    for _, b in ipairs(blobs) do
      if (x - b[1]) ^ 2 + (y - b[2]) ^ 2 <= b[3] ^ 2 then return true end
    end
    return false
  end, function(x, y)
    for _, b in ipairs(blobs) do
      if (x - b[1]) ^ 2 + (y - b[2]) ^ 2 <= b[3] ^ 2 then
        return ((x - b[1]) * 0.5 + (y - b[2]) * 0.85 > b[3] * 0.25) and CR_LO or CR
      end
    end
    return CR
  end, DUSTLINE)
end }

ANIMS[#ANIMS + 1] = { name = "spike", w = 16, h = 28, n = 4, ms = 100, draw = function(C, f)
  local tt, cap = tri(1.5, 3, 14.5, 3, 8, 27.6), ell(8, 3.2, 6.5, 2.8)
  part(C, function(x, y) return tt(x, y) or cap(x, y) end, function(x, y)
    if y > 14 then return (x > 8.6) and PU_LO or PU end
    return (x > 9) and CR_LO or CR
  end, OUT)
  local gy = 3 + f * 3
  local half = (27.6 - gy) / 24.6 * 6.5
  local gx = math.floor(8 - half * 0.45)
  put(C, gx, gy, WHITE); put(C, gx, gy + 1, WHITE)
end }

-- Build ---------------------------------------------------------------------
local RESULT = {}
for _, A in ipairs(ANIMS) do
  local spr = Sprite(A.w, A.h, ColorMode.RGB)
  for _ = 2, A.n do spr:newEmptyFrame() end
  local imgs = {}
  for f = 1, A.n do
    local C = canvas(A.w, A.h)
    A.draw(C, f)
    local img = Image(A.w, A.h, ColorMode.RGB)
    for k, hex in pairs(C.p) do img:drawPixel(k % A.w, k // A.w, px(hex)) end
    local cel = spr.layers[1]:cel(f)
    if cel then cel.image = img else spr:newCel(spr.layers[1], f, img, Point(0, 0)) end
    spr.frames[f].duration = A.ms / 1000
    imgs[f] = img
  end
  spr:saveAs(OUT_SRC .. A.name .. ".aseprite")
  app.command.ExportSpriteSheet{
    ui = false, type = SpriteSheetType.HORIZONTAL, textureFilename = OUT_ART .. A.name .. ".png",
    borderPadding = 0, shapePadding = 0, innerPadding = 0,
  }
  spr:close()
  RESULT[#RESULT + 1] = { anim = A, imgs = imgs }
  print("wrote " .. A.name .. " " .. A.w .. "x" .. A.h .. " x" .. A.n)
end

-- Review sheets (sky + teal ground, Jei at the same scale) -------------------
local function rgb(h)
  return app.pixelColor.rgba(tonumber(h:sub(1, 2), 16), tonumber(h:sub(3, 4), 16), tonumber(h:sub(5, 6), 16), 255)
end
local jspr = app.open(root .. "/assets/art/player/jei/default/reference.png")
local jei = Image(jspr.spec); jei:drawSprite(jspr, 1); jspr:close()

local CW, CH = 76, 64
local function sheetImage(cols, rows)
  local img = Image(cols * CW, rows * CH, ColorMode.RGB)
  local sky, teal, tealD = rgb("BFEFFF"), rgb("50AF9F"), rgb("408F9F")
  for y = 0, img.height - 1 do
    local ry = y % CH
    local c = sky
    if ry >= 62 then c = tealD elseif ry >= 60 then c = teal end
    for x = 0, img.width - 1 do img:drawPixel(x, y, c) end
  end
  return img
end
-- place `img` bottom-centred in cell (col,row) so its last row sits on the ground
local function place(sheet, img, col, row)
  sheet:drawImage(img, Point(col * CW + 2 + (72 - img.width) // 2, row * CH + 60 - img.height))
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
local function savePng(img, path)
  local s = Sprite(img.spec)
  s:newCel(s.layers[1], 1, img, Point(0, 0))
  s:saveAs(path); s:close()
end

local full = sheetImage(9, #RESULT)
for r, R in ipairs(RESULT) do
  place(full, jei, 0, r - 1)
  for f, img in ipairs(R.imgs) do place(full, img, f, r - 1) end
end
savePng(scaled(full, 3), OUT_SRC .. "boss_x3.png")

local KEY = { idle = 1, shake = 3, crouch = 6, puff = 8, roll = 2, jump = 1, dazed = 1, hurt = 2, dust = 4, spike = 1 }
local key = sheetImage(6, 2)
place(key, jei, 0, 0); place(key, jei, 0, 1)
local i = 0
for _, R in ipairs(RESULT) do
  local col, row = 1 + i % 5, i // 5
  place(key, R.imgs[KEY[R.anim.name]], col, row)
  i = i + 1
end
savePng(scaled(key, 6), OUT_SRC .. "boss_x6.png")
print("wrote review sheets")
