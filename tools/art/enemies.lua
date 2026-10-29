-- enemies.lua — the three enemies' move strips (story 011). 24x24 per frame, 8 frames, facing LEFT.
-- Usage (Aseprite batch):
--   Aseprite.exe -b --script-param root=<repo root> --script tools/art/enemies.lua
-- Writes assets/art/enemies/{walker,jumper,flyer}/move.png (horizontal strips),
--        assets/art_src/enemies/{walker,jumper,flyer}/move.aseprite (with frame durations),
--        assets/art_src/enemies/enemies_x6.png + enemies_x3.png (review sheets with Jei's
--        reference at the same scale; not used by the game).
-- GIF previews are made from the .aseprite files with the CLI (--scale 4).
--
-- Style (art-bible §3, §5; matches assets/art/player/jei/default/reference.png):
-- each part (feet, horn, body, wings, spring) is a shape function rendered into its own
-- layer with a black 1px outline (4-neighbour, so the outline is always closed), then
-- composited back to front, so overlapping parts keep an outline between them.
-- Shading: base fill, one shade step on the bottom/right rim (light from upper left),
-- a short light-purple arc inside the upper-left rim. Faces are stamped pixel templates.
-- Every colour is checked against assets/art_src/palette/jei_character.gpl.

local root = app.params["root"]
local pc = app.pixelColor
local W, H, N = 24, 24, 8

---------------------------------------------------------------- palette
local PAL = {}
do
  local path = root .. "/assets/art_src/palette/jei_character.gpl"
  local f = assert(io.open(path, "r"), "palette not found: " .. path)
  for line in f:lines() do
    local hex = line:match("^%s*%d+%s+%d+%s+%d+%s+(%x+)")
    if hex then PAL[hex:upper()] = true end
  end
  f:close()
end
local function rgb(h)
  if not PAL[h] then error("colour not in jei_character.gpl: " .. h) end
  return pc.rgba(tonumber(h:sub(1, 2), 16), tonumber(h:sub(3, 4), 16), tonumber(h:sub(5, 6), 16), 255)
end
local C = {
  a = "010101",                              -- outline / brows (char_00)
  p = "9060A8", s = "6E4A6A", h = "B48CCC",  -- enemy purple, shade, highlight
  k = "F6EEE4", K = "DCC9B4",                -- cream horn/wings + shade (boss cream)
  o = "FEFEFE", D = "1E1319",                -- eye highlight, eye dark
  M = "AA373C",                              -- mouth inside (Jei's mouth red)
  b = "EE6FA6",                              -- blush
  n = "2668AE", N = "17407A", m = "142E58",  -- spring navy hi / mid / deep
}
for _, v in pairs(C) do rgb(v) end

---------------------------------------------------------------- grid helpers
local function canvas() local g = {}; for y = 0, H - 1 do g[y] = {} end; return g end
local function put(g, x, y, c) if x >= 0 and x < W and y >= 0 and y < H then g[y][x] = c end end
local function rnd(v) return math.floor(v + 0.5) end

-- Renders one part: F(x, y) -> inside (integer pixel), col(x, y) -> hex. Outline drawn around it.
local function part(g, F, col)
  for y = 0, H - 1 do for x = 0, W - 1 do
    if F(x, y) then put(g, x, y, col(x, y))
    elseif F(x - 1, y) or F(x + 1, y) or F(x, y - 1) or F(x, y + 1) then put(g, x, y, C.a) end
  end end
end

-- Standard material: shade on bottom/right rim, highlight arc 1px inside the upper-left rim.
local function shaded(F, base, shade, hi, hiArea)
  return function(x, y)
    if shade and (not F(x + 1, y + 1) or not F(x, y + 2)) then return shade end
    if hi and hiArea(x, y) and F(x - 1, y - 1) and not F(x - 2, y - 2) then return hi end
    return base
  end
end

local function stamp(g, rows, x0, y0)
  for r, row in ipairs(rows) do
    for i = 1, #row do
      local ch = row:sub(i, i)
      if ch ~= "." then put(g, x0 + i - 1, y0 + r - 1, C[ch]) end
    end
  end
end

local function tri(ax, ay, bx, by, cx, cy)
  return function(x, y)
    local px, py = x + 0.5, y + 0.5
    local d1 = (px - bx) * (ay - by) - (ax - bx) * (py - by)
    local d2 = (px - cx) * (by - cy) - (bx - cx) * (py - cy)
    local d3 = (px - ax) * (cy - ay) - (cx - ax) * (py - ay)
    local neg = d1 < 0 or d2 < 0 or d3 < 0
    local pos = d1 > 0 or d2 > 0 or d3 > 0
    return not (neg and pos)
  end
end

---------------------------------------------------------------- faces
-- Angry-cute eyes: slanted brow (inner end low), dark eye with a white highlight top-left.
local EYE_L  = { "aa..", "..aa", ".oDD", ".DDD", ".DDD" }
local EYE_R  = { "..aa", "aa..", "oDD.", "DDD.", "DDD." }
local EYE_SL = { "aa.", "..a", "oD.", "DD.", "DD." }   -- small (flyer)
local EYE_SR = { ".aa", "a..", ".oD", ".DD", ".DD" }
local MOUTH  = { ".aa.", "aoMa", "aaaa" }               -- open frown with one fang
local MOUTH_S = { ".a.", "aoa" }

---------------------------------------------------------------- walker
-- Low wide half-dome, one cream horn, stubby feet. 8-frame waddle: two steps per loop.
local function walker(i)
  local down  = ({ 1, 0, 0, 1, 1, 0, 0, 1 })[i]
  local liftL = ({ 0, 1, 1, 0, 0, 0, 0, 0 })[i]
  local liftR = ({ 0, 0, 0, 0, 0, 1, 1, 0 })[i]
  local wob   = ({ 0, -1, -1, 0, 0, 1, 1, 0 })[i]
  local g = canvas()
  local yb = 19 + down           -- bottom fill row of the body
  local top = yb - 12            -- top fill row
  local cx, rx, ry = 11.5, 9.6 + 0.45 * down, 12.5
  local function body(x, y)
    if y > yb or y < top then return false end
    local px, py = x + 0.5, y + 0.5
    local dx = math.abs(px - cx)
    if ((dx / rx) ^ 2.6 + ((py - (yb + 0.5)) / ry) ^ 2) > 1 then return false end  -- fuller dome
    if y == yb and dx > rx - 1.5 then return false end
    if y == yb - 1 and dx > rx - 0.6 then return false end
    return true
  end
  -- horn (behind the body)
  local hx = 10.5
  local horn = tri(hx - 3.6, top + 1.5, hx + 3.6, top + 1.5, hx + wob, top - 6.5)
  part(g, horn, function(x, y)
    if not horn(x + 1, y) then return C.K end
    return C.k
  end)
  part(g, body, shaded(body, C.p, C.s, C.h, function(x, y) return x + 0.5 < cx - 2 and y < top + 6 end))
  -- feet (in front, so a line separates them from the body)
  local function foot(fx, lift)
    local fy = 22 - lift
    return function(x, y)
      local d = math.abs(x + 0.5 - fx)
      return (y == fy - 1 and d <= 1.5) or (y == fy and d <= 2.5)
    end
  end
  local fl, fr = foot(6.5 - liftL, liftL), foot(15.5 - liftR, liftR)
  part(g, fl, function() return C.s end)
  part(g, fr, function() return C.s end)
  -- face (1px left of centre: facing left)
  local ey = top + 3
  stamp(g, EYE_L, 6, ey)
  stamp(g, EYE_R, 12, ey)
  put(g, 5, ey + 5, C.b); put(g, 6, ey + 5, C.b)
  put(g, 15, ey + 5, C.b); put(g, 16, ey + 5, C.b)
  stamp(g, MOUTH, 9, ey + 5)
  return g
end

---------------------------------------------------------------- jumper
-- Droplet body on a navy coil spring. Hop: squash 1-2, stretch 3-5, land squash 6-8.
-- { body bottom row, x scale, y scale, tip lean }
local JF = {
  { 18, 1.08, 0.92, 0 }, { 19, 1.18, 0.82, 0 }, { 17, 0.94, 1.05, 1 }, { 16, 0.88, 1.08, 1 },
  { 16, 0.92, 1.06, 0 }, { 17, 1.04, 0.96, -1 }, { 19, 1.16, 0.84, -1 }, { 18, 1.10, 0.90, 0 },
}
local function jumper(i)
  local yb, sx, sy, lean = JF[i][1], JF[i][2], JF[i][3], JF[i][4]
  local g = canvas()
  local cx = 11.5
  local R = 6.5 * sx
  local Hb = rnd(15 * sy)
  local top = yb - Hb + 1
  local tm = 0.55
  local function body(x, y)
    if y < top or y > yb then return false end
    local px, py = x + 0.5, y + 0.5
    local t = (py - top) / Hb
    local w, c = 0, cx
    if t < tm then
      w = R * math.sin(math.pi / 2 * t / tm) ^ 1.3
      c = cx + lean * (1 - t / tm) ^ 2
    else
      local u = (t - tm) / (1 - tm)
      w = R * math.sqrt(math.max(0, 1 - u * u))
    end
    return math.abs(px - c) <= w
  end
  -- spring: bottom-up foot (row 22), then gap / band rows alternating up to the body
  local function spring(x, y)
    if y > 22 or y <= yb then return false end
    local d = x + 0.5 - cx
    if y == 22 then return math.abs(d) <= 4.5 end
    local k = 22 - y
    if k % 2 == 1 then return math.abs(d) <= 1.5 end            -- gap
    local off = ((k / 2) % 2 == 1) and -0.5 or 0.5               -- bands lean alternately
    return math.abs(d - off) <= 3.5
  end
  part(g, spring, function(x, y)
    local k = 22 - y
    if y == 22 or k % 2 == 1 then return C.m end
    if not spring(x - 1, y) then return C.n end                  -- lit left end of a band
    return C.N
  end)
  local yw = top + rnd(Hb * tm)
  part(g, body, shaded(body, C.p, C.s, C.h, function(x, y) return x + 0.5 < cx - 1.5 and y < yw - 1 end))
  local ey = yw - 4
  stamp(g, EYE_L, 6, ey)
  stamp(g, EYE_R, 12, ey)
  put(g, 6, ey + 5, C.b); put(g, 15, ey + 5, C.b)
  stamp(g, MOUTH, 9, ey + 6)
  return g
end

---------------------------------------------------------------- flyer
-- Small round body, two cream triangle wings. Flap: wings up at 1, down at 5; body rises on the downstroke.
local function flyer(i)
  local c = math.cos(2 * math.pi * (i - 1) / N)
  local tipdy = -0.5 - 5 * c
  local cy = 12 + rnd(1.4 * c)
  local cx = 12
  local g = canvas()
  local function body(x, y)
    local px, py = x + 0.5, y + 0.5
    return (px - cx) ^ 2 + (py - cy) ^ 2 <= 5.1 * 5.1
  end
  local wl = tri(cx - 4, cy - 4, cx - 4, cy + 3, 1.2, cy + tipdy)
  local wr = tri(cx + 4, cy - 4, cx + 4, cy + 3, 22.8, cy + tipdy)
  local function wcol(F) return function(x, y) if not F(x, y + 1) then return C.K end return C.k end end
  part(g, wl, wcol(wl))
  part(g, wr, wcol(wr))
  part(g, body, shaded(body, C.p, C.s, C.h, function(x, y) return x + 0.5 < cx - 1 and y + 0.5 < cy - 1 end))
  local ey = cy - 4
  stamp(g, EYE_SL, 8, ey)
  stamp(g, EYE_SR, 11, ey)
  stamp(g, MOUTH_S, 10, ey + 6)
  return g
end

---------------------------------------------------------------- output
local function toImage(g)
  local im = Image(W, H, ColorMode.RGB)
  im:clear(pc.rgba(0, 0, 0, 0))
  for y = 0, H - 1 do for x = 0, W - 1 do
    local c = g[y][x]
    if c then im:drawPixel(x, y, rgb(c)) end
  end end
  return im
end

local function save(frames, name, ms)
  local srcDir = root .. "/assets/art_src/enemies/" .. name .. "/"
  local outDir = root .. "/assets/art/enemies/" .. name .. "/"
  app.fs.makeAllDirectories(srcDir)
  app.fs.makeAllDirectories(outDir)
  local spr = Sprite(W, H, ColorMode.RGB)
  for _ = 2, #frames do spr:newEmptyFrame() end
  for i, im in ipairs(frames) do
    spr:newCel(spr.layers[1], i, im, Point(0, 0))
    spr.frames[i].duration = ms / 1000
  end
  spr:saveAs(srcDir .. "move.aseprite")
  spr:close()
  local strip = Image(W * #frames, H, ColorMode.RGB)
  strip:clear(pc.rgba(0, 0, 0, 0))
  for i, im in ipairs(frames) do strip:drawImage(im, Point((i - 1) * W, 0)) end
  local s2 = Sprite(strip.spec)
  s2:newCel(s2.layers[1], 1, strip, Point(0, 0))
  s2:saveAs(outDir .. "move.png")
  s2:close()
end

local sets = {
  { name = "walker", fn = walker, ms = 110 },
  { name = "jumper", fn = jumper, ms = 90 },
  { name = "flyer",  fn = flyer,  ms = 80 },
}
local built = {}
for r, s in ipairs(sets) do
  local frames = {}
  for i = 1, N do frames[i] = toImage(s.fn(i)) end
  save(frames, s.name, s.ms)
  built[r] = frames
end

-- Review sheet: rows walker / jumper / flyer, columns frames 1-8, Jei's reference on the right.
local function hexc(h) return pc.rgba(tonumber(h:sub(1, 2), 16), tonumber(h:sub(3, 4), 16), tonumber(h:sub(5, 6), 16), 255) end
local sky, teal, tealD = hexc("BFEFFF"), hexc("50AF9F"), hexc("408F9F")
local CW, CH = 28, 28
local sheet = Image(CW * N + 48, CH * 3, ColorMode.RGB)
for y = 0, sheet.height - 1 do
  local cy = y % CH
  for x = 0, sheet.width - 1 do
    local col = sky
    if cy >= 26 and (x < CW * N or y >= CH * 2) then col = (cy >= 27) and tealD or teal end
    sheet:drawPixel(x, y, col)
  end
end
for r, frames in ipairs(built) do
  for i, im in ipairs(frames) do sheet:drawImage(im, Point((i - 1) * CW + 2, (r - 1) * CH + 2)) end
end
local ref = Image{ fromFile = root .. "/assets/art/player/jei/default/reference.png" }
sheet:drawImage(ref, Point(CW * N + 4, CH * 3 - 2 - ref.height))

local function scaled(K, path)
  local big = Image(sheet.width * K, sheet.height * K, ColorMode.RGB)
  for y = 0, sheet.height - 1 do for x = 0, sheet.width - 1 do
    local p = sheet:getPixel(x, y)
    for dy = 0, K - 1 do for dx = 0, K - 1 do big:drawPixel(x * K + dx, y * K + dy, p) end end
  end end
  local rs = Sprite(big.spec)
  rs:newCel(rs.layers[1], 1, big, Point(0, 0))
  rs:saveAs(path)
  rs:close()
end
scaled(6, root .. "/assets/art_src/enemies/enemies_x6.png")
scaled(3, root .. "/assets/art_src/enemies/enemies_x3.png")
print("done")
