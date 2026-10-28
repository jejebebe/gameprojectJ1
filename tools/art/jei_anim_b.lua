-- jei_anim_b.lua — Jei run (12) and ability (6) strips for the default cape set.
-- Usage (Aseprite batch):
--   Aseprite.exe -b --script-param root=<repo root> --script tools/art/jei_anim_b.lua
-- Reads  assets/art/player/jei/default/reference.png (never written).
-- Writes assets/art/player/jei/default/{run,ability}.png (horizontal strips, 48x52 cells),
--        assets/art_src/player/jei/default/{run,ability}.aseprite,
--        assets/art_src/player/jei/anim_b_x6.png / anim_b_x3.png (review sheets, not used by the game).
--
-- Frame: 48x52. The 40x52 reference sits at x offset +4 (OX); every coordinate in
-- this script is a REFERENCE coordinate (valid x range -4..43), get/put add OX.
-- Cut-out rig: body (hood+head, torso, right cape) is copied from the reference
-- (never redrawn; only the mouth changes for the cast). The left cape is redrawn per
-- frame as a travelling wave (edge ripple, scalloped hem, fold shading), the right
-- cape edge ripples, legs are procedural and the arms are short stubby sprites.
-- A closing pass outlines any colour pixel that touches transparency. Palette only.

local root = app.params["root"]
local SRC = root .. "/assets/art/player/jei/default/reference.png"

-- Keys -> jei_character.gpl colours.
local KEY = {
  a = "010101", c = "C33132", b = "961824", g = "5C121F",
  C = "BDB8BF", o = "FEFEFE", F = "BAABAC", B = "B9B2B9",
  k = "FDE3D2", l = "FBDEC9", i = "E09487", z = "B4645C",
  E = "3C2827", D = "1E1319", u = "AA373C", x = "E67674", v = "A13339",
  s = "FCC3AF", n = "EAA894",
}
local pc = app.pixelColor
local CLEAR = pc.rgba(0, 0, 0, 0)
local PX = {}
for ch, h in pairs(KEY) do
  PX[ch] = pc.rgba(tonumber(h:sub(1,2),16), tonumber(h:sub(3,4),16), tonumber(h:sub(5,6),16), 255)
end

local srcSpr = app.open(SRC)
if srcSpr.colorMode ~= ColorMode.RGB then app.command.ChangePixelFormat{ format = "rgb" } end
local ref = Image(srcSpr.spec); ref:clear(); ref:drawSprite(srcSpr, 1)
srcSpr:close()

local OX = 4                                   -- reference x offset inside the frame
local W, H = ref.width + 2 * OX, ref.height    -- 48 x 52
local base = Image(W, H, ColorMode.RGB); base:clear()
base:drawImage(ref, Point(OX, 0))
local XMIN, XMAX = -OX, W - OX - 1             -- reference-coordinate x range

local function rnd(v) return math.floor(v + 0.5) end
local function get(img, x, y)
  x = x + OX
  if x < 0 or y < 0 or x >= W or y >= H then return CLEAR end
  return img:getPixel(x, y)
end
local function setRaw(img, x, y, p)
  x = x + OX
  if x < 0 or y < 0 or x >= W or y >= H then return end
  img:drawPixel(x, y, p)
end
local function opaque(img, x, y) return pc.rgbaA(get(img, x, y)) > 0 end
local function put(img, x, y, ch)
  if ch == "." then setRaw(img, x, y, CLEAR) else
    assert(PX[ch], "no colour for " .. ch); setRaw(img, x, y, PX[ch]) end
end
local function blank() local i = Image(W, H, ColorMode.RGB); i:clear(); return i end
local N4 = { {1,0}, {-1,0}, {0,1}, {0,-1} }

--- Draws a sprite ({y, x, "keys"} rows, '.' = skip) at offset dx, dy.
local function stamp(img, spr, dx, dy, fill)
  for _, e in ipairs(spr) do
    local y, x0, s = e[1], e[2], e[3]
    for n = 1, #s do
      local ch = s:sub(n, n)
      if ch ~= "." then put(img, x0 + n - 1 + dx, y + dy, fill or ch) end
    end
  end
end

--- Draws a row-list sprite with its top-left (or top-right when mirrored) at ax, ay.
local function stampM(img, rows, ax, ay, mirror)
  for r, row in ipairs(rows) do
    for n = 1, #row do
      local ch = row:sub(n, n)
      if ch ~= "." then
        local x = mirror and (ax - (n - 1)) or (ax + n - 1)
        put(img, x, ay + r - 1, ch)
      end
    end
  end
end

-- Right arm as in the reference (only used to cut it out of the body).
local RARM = {
  {37, 22, "aaaa"}, {38, 22, "aCCCa"}, {39, 23, "aooooa"}, {40, 23, "aoooBia"},
  {41, 24, "aCFkkia"}, {42, 25, "alzkka"}, {43, 26, "aaaaa"},
}
-- Stubby chibi arms: 3-row sleeve + 2x2 hand, <= 5 px shoulder to hand.
local ARM_DOWN = {
  ".aaa.",
  "aoCCa",
  "aooBa",
  "aFoFa",
  "akla.",
  "aiza.",
  ".aa..",
}
local ARM_FWD = {             -- swung forward (down-right); mirrored = back / left arm rest
  ".aaa...",
  "aoCCa..",
  "aoooBa.",
  ".aFBkla",
  "..aaiza",
  "....aa.",
}
local ARM_CAST = {            -- short punch forward
  "aaaa...",
  "aoooaa.",
  "aoCBkla",
  "aFBBiza",
  "aaaaaa.",
}
-- Open mouth for the cast (reference coordinates).
local MOUTH_OPEN = { {27, 14, "vgv"}, {28, 14, "gxg"}, {29, 14, "vuv"} }

--- Reference minus right arm (filled with cape lining), left arm, left cape and legs.
local function makeBody(mouth)
  local img = base:clone()
  stamp(img, RARM, 0, 0, "g")
  local marks = {}
  for y = 36, 44 do for x = 20, 31 do
    if get(img, x, y) == PX.g then
      for _, d in ipairs(N4) do
        local p = get(img, x + d[1], y + d[2])
        if p == PX.E or p == PX.D then marks[#marks+1] = {x, y}; break end
      end
    end
  end end
  for _, m in ipairs(marks) do put(img, m[1], m[2], "a") end
  local keep = { [36]=13, [37]=12, [38]=12, [39]=12, [40]=11, [41]=10,
                 [42]=10, [43]=9, [44]=9, [45]=10, [46]=11 }
  for y = 36, 46 do for x = XMIN, keep[y] - 1 do put(img, x, y, ".") end end
  for y = 47, H - 1 do for x = XMIN, 28 do put(img, x, y, ".") end end
  if mouth then stamp(img, MOUTH_OPEN, 0, 0) end
  return img
end

--- Per-row lean: rows 0-10 (hood top) hood, 11-30 (head) head, 31+ (torso) torso.
local function lean(img, hood, head, torso)
  local out = blank()
  for y = 0, H - 1 do
    local dx = (y <= 10) and hood or ((y <= 30) and head or torso)
    for x = 0, W - 1 do
      local p = img:getPixel(x, y)
      local nx = x + dx
      if pc.rgbaA(p) > 0 and nx >= 0 and nx < W then out:drawPixel(nx, y, p) end
    end
  end
  return out
end

--- Squash: drops one torso row, everything above moves down 1 px.
local function squash(img, row)
  local out = blank()
  for y = 0, H - 1 do for x = 0, W - 1 do
    local p = img:getPixel(x, y)
    if y > row then out:drawPixel(x, y, p) elseif y < row then out:drawPixel(x, y + 1, p) end
  end end
  return out
end

--- Vertical move by dy (negative = up).
local function bob(img, dy)
  if dy == 0 then return img end
  local out = blank()
  for y = 0, H - 1 do for x = 0, W - 1 do
    local ny = y + dy
    if ny >= 0 and ny < H then out:drawPixel(x, ny, img:getPixel(x, y)) end
  end end
  return out
end

--- Right cape edge ripple: shifts the outer 4 px of each row by base + travelling sine.
local function wobbleRight(img, y0, y1, ph, amp, baseD)
  for y = y0, y1 do
    local t = (y - y0) / (y1 - y0)
    local d = baseD + rnd(amp * (0.3 + 0.7 * t) * math.sin((y - y0) * 0.7 - ph))
    if d ~= 0 then
      local xr
      for x = XMAX, XMIN, -1 do if opaque(img, x, y) then xr = x; break end end
      if xr and xr >= 28 then
        local xs = xr - 3
        local o = {}
        for x = xs, xr do o[x] = get(img, x, y) end
        for x = xs, xr + d do
          local src = x - d
          if src < xs then src = xs end
          setRaw(img, x, y, o[src])
        end
        for x = xr + d + 1, xr do setRaw(img, x, y, CLEAR) end
      end
    end
  end
end

--- Left cape behind the body as a travelling wave.
-- p: top, hem, tdx, stream (extra trailing reach), lift (hem rise at the tip),
--    amp (edge ripple px), fold (hem scallop px), phase.
local function drawCape(img, p)
  local top, hb, ph = p.top, p.hem, p.phase
  local L, Lmin = {}, 99
  for y = top, hb + 2 do
    local t = math.min(1, (y - top) / (hb - top))
    local v = 7 + p.tdx - rnd(4 * t) - rnd(p.stream * t ^ (p.curve or 1.3))
              + rnd(p.amp * t ^ 0.8 * math.sin((y - top) * 0.7 - ph))
    if v < XMIN then v = XMIN end
    L[y] = v; if v < Lmin then Lmin = v end
  end
  local xA = 15 + p.tdx
  local function fs(x, y) return math.sin(ph + x * 0.75 + (y - top) * 0.2) end
  local function hemAt(x)
    local u = (xA - x) / math.max(1, xA - Lmin)
    if u < 0 then u = 0 elseif u > 1 then u = 1 end
    local h = hb - rnd(p.lift * u) + rnd(p.fold * fs(x, hb))
    if x > xA - 3 and h > hb then h = hb end
    return h
  end
  local mask = {}
  for y = top, hb + 2 do
    mask[y] = {}
    local x = L[y]
    while x <= XMAX and not opaque(img, x, y) do
      if y <= hemAt(x) then mask[y][x] = true end
      x = x + 1
    end
  end
  local function inM(x, y) return mask[y] ~= nil and mask[y][x] == true end
  -- Strand cleanup: drop cape pixels with < 2 supported 4-neighbours (no 1-px threads).
  for _ = 1, 3 do
    local drop = {}
    for y = top, hb + 2 do for x, _ in pairs(mask[y]) do
      local nb = 0
      for _, d in ipairs(N4) do
        if inM(x + d[1], y + d[2]) or opaque(img, x + d[1], y + d[2]) then nb = nb + 1 end
      end
      if nb < 2 then drop[#drop+1] = {x, y} end
    end end
    for _, q in ipairs(drop) do mask[q[2]][q[1]] = nil end
  end
  local function isEdge(x, y)
    for _, d in ipairs(N4) do
      local nx, ny = x + d[1], y + d[2]
      if not inM(nx, ny) and not opaque(img, nx, ny) then return true end
    end
    return false
  end
  local N8 = { {1,0}, {-1,0}, {0,1}, {0,-1}, {1,1}, {1,-1}, {-1,1}, {-1,-1} }
  local paint = {}
  for y = top, hb + 2 do for x, _ in pairs(mask[y]) do
    local edge = isEdge(x, y)
    local ch
    if edge then
      -- Outline-only threads (no cloth behind them) are dropped.
      local body = false
      for _, d in ipairs(N8) do
        local nx, ny = x + d[1], y + d[2]
        if inM(nx, ny) and not isEdge(nx, ny) then body = true; break end
      end
      ch = body and "a" or nil
    else
      local t = math.min(1, (y - top) / (hb - top))
      local dl = x - L[y]
      local red = 2 + math.max(0, rnd(p.stream * 0.5 * t))
      local s = fs(x, y)
      if dl <= red then ch = (s < -0.55 and dl > 0) and "b" or "c"
      elseif dl == red + 1 then ch = "b"
      else ch = (s > 0.65) and "b" or "g" end
      if y >= hemAt(x) - 1 and s < -0.3 then ch = "g" end
    end
    if ch then paint[#paint+1] = {x, y, ch} end
  end end
  for _, q in ipairs(paint) do put(img, q[1], q[2], q[3]) end
end

--- One leg: hip column hx at row hr, ankle offset d, sole row fy.
local function drawLeg(img, hx, hr, d, fy)
  if fy < hr + 3 then fy = hr + 3 end
  if fy > H - 1 then fy = H - 1 end
  local ax, last = hx + d, fy - 3
  local n = last - hr + 1
  for r = hr, last do
    local x = hx + rnd(d * (r - hr + 1) / (n + 1))
    local s1, s2 = "l", "k"
    if r == hr then s1, s2 = "i", "i" end
    put(img, x-1, r, "a"); put(img, x, r, s1); put(img, x+1, r, s2); put(img, x+2, r, "a")
  end
  put(img, ax-1, fy-2, "a"); put(img, ax, fy-2, "E"); put(img, ax+1, fy-2, "E"); put(img, ax+2, fy-2, "a")
  put(img, ax-1, fy-1, "a"); put(img, ax, fy-1, "E"); put(img, ax+1, fy-1, "E"); put(img, ax+2, fy-1, "E"); put(img, ax+3, fy-1, "a")
  put(img, ax, fy, "a"); put(img, ax+1, fy, "a"); put(img, ax+2, fy, "a")
end

--- Two legs, the one further forward drawn last (in front).
local function drawLegs(img, tdx, hr, dL, fyL, dR, fyR)
  local legs = { {15 + tdx, dL, fyL}, {22 + tdx, dR, fyR} }
  if dL > dR then legs = { legs[2], legs[1] } end
  for _, g in ipairs(legs) do drawLeg(img, g[1], hr, g[2], g[3]) end
end

--- Front (right) arm pose: "F" forward, "D" down, "B" back, "C" cast.
local function rightArm(img, pose, dy)
  if pose == "F" then stampM(img, ARM_FWD, 22, 37 + dy, false)
  elseif pose == "B" then stampM(img, ARM_FWD, 26, 37 + dy, true)
  elseif pose == "C" then stampM(img, ARM_CAST, 24, 38 + dy, false)
  else stampM(img, ARM_DOWN, 22, 37 + dy, false) end
end
--- Back (left) arm pose: "F" tucked forward, "D" rest, "B" swung back.
local function leftArm(img, pose, dy)
  if pose == "F" then stampM(img, ARM_DOWN, 12, 36 + dy, true)
  elseif pose == "B" then stampM(img, ARM_FWD, 11, 36 + dy, true)
  else stampM(img, ARM_FWD, 12, 36 + dy, true) end
end

--- Closing pass: transparent pixel next to a non-outline colour becomes outline.
local function closeOutline(img)
  local marks = {}
  for y = 0, H - 1 do for x = XMIN, XMAX do
    if not opaque(img, x, y) then
      for _, d in ipairs(N4) do
        local p = get(img, x + d[1], y + d[2])
        if pc.rgbaA(p) > 0 and p ~= PX.a then marks[#marks+1] = {x, y}; break end
      end
    end
  end end
  for _, m in ipairs(marks) do put(img, m[1], m[2], "a") end
end

-- ---------------------------------------------------------------- run (12)
-- Frames 0-5: contact R (0) -> up (3) -> pre-contact; 6-11 mirror with legs swapped.
local RUN_BY  = { 0, -1, -2, -3, -2, -1 }
-- {forward-leg d, fy, back-leg d, fy} in the half cycle where R leads.
local RUN_LEGS = {
  { 3, 51, -2, 50 }, { 1, 51, -2, 49 }, { -1, 50, -1, 48 },
  { -2, 48, 1, 47 }, { -2, 48, 2, 49 }, { -2, 49, 3, 50 },
}

local function runFrame(f)            -- f = 0..11
  local half, k = (f >= 6), f % 6
  local by, sq = RUN_BY[k + 1], (k == 0) and 1 or 0
  local img = makeBody(false)
  img = lean(img, 1, 1, 0)            -- head leans 1 px; torso/feet centre fixed
  if sq == 1 then img = squash(img, 44) end
  img = bob(img, by)
  local ph = f * math.pi / 3          -- two wave cycles per loop, ~1.4 px travel/frame
  wobbleRight(img, 36 + by, 50 + by, ph, 2, 0)
  drawCape(img, { top = 36 + by + sq, hem = 48 + by, tdx = 0,
                  stream = 5 + rnd(math.sin(ph)), lift = 2 + rnd(1.5 * math.sin(ph + 1)), curve = 0.8,
                  amp = 2.5, fold = 1.6, phase = ph })
  local lg = RUN_LEGS[k + 1]
  local hr = 47 + by
  if not half then drawLegs(img, 0, hr, lg[3], lg[4], lg[1], lg[2])
  else drawLegs(img, 0, hr, lg[1], lg[2], lg[3], lg[4]) end
  local c = math.cos(2 * math.pi * f / 12)
  local rp = (c > 0.3) and "B" or ((c < -0.3) and "F" or "D")
  local lp = (rp == "F") and "B" or ((rp == "B") and "F" or "D")
  leftArm(img, lp, by + sq)
  rightArm(img, rp, by + sq)
  closeOutline(img)
  return img
end

-- ---------------------------------------------------------------- ability (6)
-- head: head/hood lean; rb/ra: right cape edge base shift / ripple; spark: 0-2.
local AB = {
  { head= 0, arm="D", larm="D", stream=-1, lift=0, amp=1.0, fold=1.0, rb=-1, ra=1, dL=-1, dR=0, mouth=false, spark=0 },
  { head=-1, arm="B", larm="F", stream=-1, lift=0, amp=1.0, fold=1.0, rb=-1, ra=1, dL=-1, dR=0, mouth=false, spark=0 },
  { head= 1, arm="C", larm="B", stream= 3, lift=3, amp=2.0, fold=1.6, rb=-2, ra=2, dL=-2, dR=2, mouth=true,  spark=1 },
  { head= 1, arm="C", larm="B", stream= 5, lift=5, amp=3.0, fold=1.6, rb=-2, ra=2, dL=-2, dR=2, mouth=true,  spark=2 },
  { head= 1, arm="C", larm="B", stream= 4, lift=4, amp=2.5, fold=1.6, rb=-1, ra=2, dL=-2, dR=2, mouth=true,  spark=1 },
  { head= 0, arm="D", larm="D", stream= 1, lift=1, amp=1.5, fold=1.0, rb= 0, ra=1, dL=-1, dR=1, mouth=false, spark=0 },
}
-- Cast sparkle in front of the hand (drawn after the outline pass, unoutlined).
local SPARK = {
  [1] = { {32, 40, "x"}, {33, 40, "o"}, {33, 39, "x"}, {33, 41, "x"}, {34, 40, "x"} },
  [2] = { {33, 37, "u"}, {33, 38, "x"}, {31, 40, "u"}, {32, 40, "x"}, {33, 40, "o"},
          {34, 40, "x"}, {35, 40, "u"}, {33, 41, "x"}, {33, 42, "u"}, {32, 39, "s"},
          {34, 39, "s"}, {32, 41, "s"}, {34, 41, "s"}, {33, 39, "o"} },
}

local function abilityFrame(f)        -- f = 1..6
  local a = AB[f]
  local img = makeBody(a.mouth)
  img = lean(img, a.head, a.head, 0)
  local ph = f * 1.3
  wobbleRight(img, 36, 50, ph, a.ra, a.rb)
  drawCape(img, { top = 36, hem = 48, tdx = 0, stream = a.stream, lift = a.lift,
                  amp = a.amp, fold = a.fold, phase = ph })
  drawLegs(img, 0, 47, a.dL, 51, a.dR, 51)
  leftArm(img, a.larm, 0)
  rightArm(img, a.arm, 0)
  closeOutline(img)
  if a.spark > 0 then for _, q in ipairs(SPARK[a.spark]) do put(img, q[1], q[2], q[3]) end end
  return img
end

-- ---------------------------------------------------------------- output
local function savePng(img, path)
  local s = Sprite(img.spec)
  s:newCel(s.layers[1], 1, img, Point(0, 0))
  s:saveAs(path); s:close()
end

local function writeAnim(name, imgs, durations)
  local strip = Image(W * #imgs, H, ColorMode.RGB); strip:clear()
  for n, img in ipairs(imgs) do strip:drawImage(img, Point((n-1) * W, 0)) end
  savePng(strip, root .. "/assets/art/player/jei/default/" .. name .. ".png")
  local s = Sprite(W, H, ColorMode.RGB)
  for _ = 2, #imgs do s:newEmptyFrame() end
  for n, img in ipairs(imgs) do
    s:newCel(s.layers[1], n, img, Point(0, 0))
    s.frames[n].duration = durations[n]
  end
  s:saveAs(root .. "/assets/art_src/player/jei/default/" .. name .. ".aseprite"); s:close()
end

local run, ability = {}, {}
for f = 0, 11 do run[f + 1] = runFrame(f) end
for f = 1, 6 do ability[f] = abilityFrame(f) end
local rd = {}; for n = 1, 12 do rd[n] = 0.05 end
writeAnim("run", run, rd)                                        -- 0.60 s loop
writeAnim("ability", ability, {0.07, 0.07, 0.05, 0.08, 0.08, 0.05}) -- 0.40 s one-shot

-- Review sheets: row 1 = run 1-12, row 2 = ability 1-6; 52x60 cells on sky, teal ground.
local CW, CH = 52, 60
local function hex(h) return pc.rgba(tonumber(h:sub(1,2),16), tonumber(h:sub(3,4),16), tonumber(h:sub(5,6),16), 255) end
local sheet = Image(CW * 12, CH * 2, ColorMode.RGB)
for y = 0, sheet.height - 1 do for x = 0, sheet.width - 1 do
  local cy = y % CH
  local c = hex("BFEFFF")
  if cy >= 56 then c = (cy >= 58) and hex("408F9F") or hex("50AF9F") end
  sheet:drawPixel(x, y, c)
end end
for n, img in ipairs(run) do sheet:drawImage(img, Point((n-1) * CW + 2, 4)) end
for n, img in ipairs(ability) do sheet:drawImage(img, Point((n-1) * CW + 2, CH + 4)) end
local function scaled(k)
  local big = Image(sheet.width * k, sheet.height * k, ColorMode.RGB)
  for y = 0, sheet.height - 1 do for x = 0, sheet.width - 1 do
    local p = sheet:getPixel(x, y)
    for dy = 0, k-1 do for dx = 0, k-1 do big:drawPixel(x*k+dx, y*k+dy, p) end end
  end end
  return big
end
savePng(scaled(6), root .. "/assets/art_src/player/jei/anim_b_x6.png")
savePng(scaled(3), root .. "/assets/art_src/player/jei/anim_b_x3.png")
print("done")
