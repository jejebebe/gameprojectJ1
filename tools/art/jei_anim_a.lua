-- jei_anim_a.lua — Jei default-cape strips: idle (6), jump (3), fall (3), hurt (3). 48x52 per frame.
-- Usage (Aseprite batch):
--   Aseprite.exe -b --script-param root=<repo root> --script tools/art/jei_anim_a.lua
-- Reads  assets/art/player/jei/default/reference.png (40x52, never written).
-- Writes assets/art/player/jei/default/{idle,jump,fall,hurt}.png (horizontal strips),
--        assets/art_src/player/jei/default/{idle,jump,fall,hurt}.aseprite (with frame durations),
--        assets/art_src/player/jei/anim_a_x6.png + anim_a_x3.png (review sheets, not used by the game).
--
-- Shared frame: 48x52. All coordinates below are REFERENCE coordinates (0..39);
-- the working grid spans x = -4..43, so the reference lands at output x +4 and
-- the cape gets a 4 px margin each side. Feet stay on the bottom row.
--
-- Rig: the reference body (hood, face, torso, dress, legs, arms) is kept, the
-- side cape below the shoulders is stripped, and a procedural cape is drawn
-- BEHIND the body every frame: side edges ripple as a wave travelling down
-- (left/right out of phase), the hem carries 2-3 rounded folds travelling
-- outward, troughs show the darker lining, crests get a shaded bottom row, and a
-- fold crease rises from each trough. Arms for jump/fall are short chibi
-- capsules (4 px shoulder->hand) posed by angle; idle/hurt keep the reference arms.
-- The face is never redrawn (hurt swaps the eyes to > <).
--
-- Cape sets: --script-param set=<default|fireball|high_jump|glide|all> (default: default).
-- Ability sets reuse the default rig frame-for-frame and change only the cape:
-- colours per tools/art/jei_capes.lua (mouth/cheek reds untouched), hood edits
-- from the static set references, and per-set procedural cape shape:
--   fireball  — rounded flame tongues (core FFF3A0, mid FFB347) on the side and
--               hem corner of each side, anchored to the rippling edge (+-1 px sway)
--   high_jump — cape cut at the waist (hem +-1 px flutter), two white cross stars
--   glide     — cape 2 px wider each side, 3 petal scallops per side on the hem
-- Ability sets write assets/art/player/jei/<set>/*.png, assets/art_src/player/jei/<set>/*.aseprite;
-- set=all also writes the review sheet assets/art_src/player/jei/sets_a_x3.png.

local root = app.params["root"]
local OUT = root .. "/assets/art/player/jei/default/"
local SRCDIR = root .. "/assets/art_src/player/jei/default/"
local REVIEW = root .. "/assets/art_src/player/jei/"
local X0, X1 = -4, 43          -- working columns (reference coords)
local W, H = X1 - X0 + 1, 52   -- 48 x 52 output
local RW = 40                  -- reference width
local pc = app.pixelColor
local TAU = math.pi * 2

-- Palette (assets/art_src/palette/jei_character.gpl)
local P = { a = "010101", c = "C33132", b = "961824", g = "5C121F", e = "9E1D27",
  E = "3C2827", D = "1E1319", k = "FDE3D2", l = "FBDEC9", i = "E09487",
  o = "FEFEFE", C = "BDB8BF", W = "FEFEFE", Y = "FFF3A0", L = "FFB347" }
local A = P.a
local CAPE = { [P.c] = true, [P.b] = true, [P.g] = true, [P.e] = true }

---------------------------------------------------------------- grid helpers
local function rnd(v) return math.floor(v + 0.5) end
local function clamp(v, lo, hi) return math.max(lo, math.min(hi, v)) end
local function blank() local g = {}; for y = 0, H - 1 do g[y] = {} end; return g end
local function inb(x, y) return x >= X0 and x <= X1 and y >= 0 and y < H end
local function get(g, x, y)
  if not inb(x, y) then return nil end
  return g[y][x]
end
local function copy(g)
  local o = blank()
  for y = 0, H - 1 do for x = X0, X1 do o[y][x] = g[y][x] end end
  return o
end
local function extract(g, pred)
  local o = blank()
  for y = 0, H - 1 do for x = X0, X1 do
    if g[y][x] and pred(x, y, g[y][x]) then o[y][x] = g[y][x] end
  end end
  return o
end
--- Draws the opaque pixels of `src` onto `dst` offset by (dx, dy).
local function compose(dst, src, dx, dy)
  for y = 0, H - 1 do for x = X0, X1 do
    local v = src[y][x]
    if v and inb(x + dx, y + dy) then dst[y + dy][x + dx] = v end
  end end
end
--- Rebuilds an image from source row ranges stacked from output row y0.
local function stack(g, ranges, y0)
  local o, oy = blank(), y0
  for _, r in ipairs(ranges) do
    for sy = r[1], r[2] do
      if oy >= 0 and oy < H then for x = X0, X1 do o[oy][x] = g[sy][x] end end
      oy = oy + 1
    end
  end
  return o
end
--- Stamps string rows at (x0, y0); '.' leaves the pixel alone.
local function stamp(g, x0, y0, rows)
  for j, s in ipairs(rows) do
    for i = 1, #s do
      local ch = s:sub(i, i)
      local x, y = x0 + i - 1, y0 + j - 1
      if ch ~= "." and inb(x, y) then g[y][x] = assert(P[ch], "no colour " .. ch) end
    end
  end
end
--- { y, x0, "str" } edits: '.' clears, '_' keeps, else palette key.
local function edit(g, list)
  for _, e in ipairs(list) do
    local y, x0, s = e[1], e[2], e[3]
    for i = 1, #s do
      local ch = s:sub(i, i)
      if ch == "." then g[y][x0 + i - 1] = nil
      elseif ch ~= "_" then g[y][x0 + i - 1] = assert(P[ch], "no colour " .. ch) end
    end
  end
end

---------------------------------------------------------------- procedural cape
--- Builds a cape description. p fields:
---   f, n      frame index / loop length (phase = 2pi (f-1)/n)
---   top, hem  first cape row, base hem row
---   L0, R0    base outer edges as functions of y
---   amp       side ripple amplitude (px at the hem), vper = its wavelength (rows)
---   hamp      hem fold amplitude (px), per = fold wavelength (px)
---   lift      hem corners lifted by lift*(|x-cx|/20)^2 (billow), default 0
---   skew      px both edges drift toward +x at the hem (flap), default 0
---   ox        whole-cape x offset, default 0
---   lin, ld   lining shows behind the body from row `lin`; trough lining depth
local function capeSpec(p)
  local ph = TAU * (p.f - 1) / p.n
  local ox, skew, lift = p.ox or 0, p.skew or 0, p.lift or 0
  local cx = 20 + ox
  local s = { top = p.top, lin = p.lin, ld = p.ld }
  local function ramp(y) return clamp((y - p.top) / (p.hem - p.top), 0, 1) end
  --- Side wave in [-1,1], travelling down; right side half a cycle behind.
  s.SW = function(y, side)
    return math.sin(TAU * (y - p.top) / p.vper - ph + (side > 0 and math.pi or 0)) * ramp(y)
  end
  s.L = function(y) return p.L0(y) + ox + skew * ramp(y) - p.amp * s.SW(y, -1) end
  s.R = function(y) return p.R0(y) + ox + skew * ramp(y) + p.amp * s.SW(y, 1) end
  --- Hem wave in [-1,1], travelling outward from the centre.
  s.HW = function(x) return math.sin(TAU * math.abs(x - cx) / p.per - ph) end
  s.H = function(x)
    local u = math.abs(x - cx) / 20
    return p.hem - lift * u * u + p.hamp * s.HW(x)
  end
  if p.scallop then
    -- Smooth-scallop hem (jump/fall): one long sine across the whole width
    -- (no mirrored cusp at the centre), folds sliding sideways frame to frame.
    -- Heights are pre-rasterised and de-toothed so every step on a curve is a
    -- run of >= 2 px and no single-pixel teeth remain.
    s.HW = function(x) return math.sin(TAU * (x - cx) / p.per - ph) end
    local hy = {}
    for x = X0 - 1, X1 + 1 do
      local u = math.abs(x - cx) / 20
      hy[x] = rnd(p.hem - lift * u * u + p.hamp * s.HW(x))
    end
    for _ = 1, 2 do
      local o = {}
      for x = X0 - 1, X1 + 1 do o[x] = hy[x] end
      for x = X0, X1 do
        local a, b, v = o[x - 1], o[x + 1], o[x]
        -- tooth: 1 px column sticking out past both neighbours
        if (v > a and v > b) or (v < a and v < b) then
          hy[x] = (math.abs(a - v) <= math.abs(b - v)) and a or b
        -- lone 1 px step on a shallow stretch: join the run nearer the crest
        -- (skipped on the steep billowed corners, where 1 px steps are the curve)
        elseif a ~= b and v ~= a and v ~= b and lift * math.abs(x - cx) / 200 < 0.4 then
          hy[x] = math.max(a, b)
        end
      end
    end
    s.H = function(x) return hy[x] or rnd(p.hem) end
  end
  if p.widen then
    -- glide: edges pushed out by `widen` px, ramping in over 4 rows from top+5
    local L, R = s.L, s.R
    local function wr(y) return clamp((y - p.top - 5) / 4, 0, 1) end
    s.L = function(y) return L(y) - p.widen * wr(y) end
    s.R = function(y) return R(y) + p.widen * wr(y) end
  end
  -- edges without the side ripple (used to limit flame sway)
  s.Ln = function(y) return s.L(y) + p.amp * s.SW(y, -1) end
  s.Rn = function(y) return s.R(y) - p.amp * s.SW(y, 1) end
  return s
end

local function colBottom(m, x, top)
  if x < X0 or x > X1 then return nil end
  for y = H - 1, top, -1 do if m[y][x] then return y end end
  return nil
end
local function extent(m, top)
  local xmin, xmax = X1, X0
  for y = top, H - 1 do for x = X0, X1 do
    if m[y][x] then xmin = math.min(xmin, x); xmax = math.max(xmax, x) end
  end end
  return xmin, xmax
end

--- glide: 3 petals per side (2 px wide, flat bottom) separated by 1 px notches.
local function petals(m, top)
  local xmin, xmax = extent(m, top)
  local function setBottom(x, yb)
    local cb = colBottom(m, x, top)
    if not cb then return end
    for y = top, H - 1 do
      if y > yb then m[y][x] = nil elseif y > cb then m[y][x] = true end
    end
  end
  for side = -1, 1, 2 do
    local d = -side
    local x0 = side < 0 and xmin or xmax
    for k = 0, 2 do
      local a = x0 + d * 3 * k
      local b, n = a + d, a + 2 * d
      local tb = colBottom(m, b, top) or colBottom(m, a, top)
      if tb then
        setBottom(a, tb); setBottom(b, tb)
        local nb = colBottom(m, n, top)
        if nb then setBottom(n, math.min(nb, tb - 1)) end
      end
    end
  end
end

-- fireball flame tongues, copied from the static reference (tools/art/jei_capes.lua):
-- rows { y, x, str } in reference coords; (ay, ax) = the row/edge column they hug.
local FLAME = {
  upL = { ay = 40, ax = 5, rows = { { 37, 1, "aa" }, { 38, 0, "acca" }, { 39, 0, "acLca" }, { 40, 0, "aLYLcc" },
    { 41, 0, "aLYLc" }, { 42, 1, "aLcc" }, { 43, 2, "a" } } },
  cnL = { ay = 47, ax = 3, rows = { { 44, 1, "aa" }, { 45, 0, "accc" }, { 46, 0, "aLLcc" }, { 47, 0, "aLYLc" },
    { 48, 0, "aLYYLc" }, { 49, 1, "aLYLcc" }, { 50, 2, "aLccca" }, { 51, 3, "aaaa" } } },
  upR = { ay = 40, ax = 34, rows = { { 37, 37, "aa" }, { 38, 36, "acca" }, { 39, 33, "aaacLca" }, { 40, 33, "ccLYLca" },
    { 41, 34, "cLYLa" }, { 42, 34, "cLca" }, { 43, 36, "a" } } },
  cnR = { ay = 47, ax = 37, rows = { { 44, 37, "aa" }, { 45, 36, "ccca" }, { 46, 35, "ccLLa" }, { 47, 35, "cLYLa" },
    { 48, 34, "cLYYLa" }, { 49, 33, "ccLYLa" }, { 50, 32, "acccLa" }, { 51, 33, "aaaa" } } },
}
--- Stamps a flame shifted by (dx, dy): colours always, outline only on empty/outline pixels.
local function stampFlame(g, sh, dx, dy)
  local xs, xe = 99, -99
  for _, r in ipairs(sh.rows) do xs = math.min(xs, r[2]); xe = math.max(xe, r[2] + #r[3] - 1) end
  dx = clamp(dx, X0 - xs, X1 - xe)
  dy = math.min(dy, H - 1 - sh.rows[#sh.rows][1])
  for _, r in ipairs(sh.rows) do
    for i = 1, #r[3] do
      local ch, x, y = r[3]:sub(i, i), r[2] + i - 1 + dx, r[1] + dy
      if inb(x, y) then
        if ch == "a" then
          if g[y][x] == nil or g[y][x] == A then g[y][x] = A end
        else g[y][x] = P[ch] end
      end
    end
  end
end
--- Two flames per side: hem corner + side ("side" mode) or + 7 px in along the hem ("hem").
local function flames(g, m, s, E, mode)
  local xmin, xmax = extent(m, s.top)
  for side = -1, 1, 2 do
    local up = side < 0 and FLAME.upL or FLAME.upR
    local cn = side < 0 and FLAME.cnL or FLAME.cnR
    local d = -side
    local x0 = side < 0 and xmin or xmax
    local yb = s.top
    for k = 0, 3 do local b = colBottom(m, x0 + d * k, s.top); if b then yb = math.max(yb, b) end end
    local function sway(y)
      local e = side < 0 and E[y][1] or E[y][2]
      local nm = rnd(side < 0 and s.Ln(y) or s.Rn(y))
      return clamp(e, nm - 1, nm + 1)
    end
    local ty = clamp(yb - 3, s.top + 1, cn.ay)
    stampFlame(g, cn, sway(ty) - cn.ax, ty - cn.ay)
    if mode == "side" then
      local tu = math.max(ty - 7, s.top + 4)
      stampFlame(g, up, sway(tu) - up.ax, tu - up.ay)
    else
      local xc = x0 + d * 7
      local b = colBottom(m, xc, s.top)
      if b then stampFlame(g, cn, xc - cn.ax, b - 3 - cn.ay) end
    end
  end
end

--- Rasterises a cape spec into (layer, mask): filled cape + its outline ring.
local function capeLayer(s, opt)
  local m, E = blank(), {}
  for y = s.top, H - 1 do
    local xl = clamp(rnd(s.L(y)), X0 + 1, X1 - 1)
    local xr = clamp(rnd(s.R(y)), X0 + 1, X1 - 1)
    E[y] = { xl, xr }
    for x = xl, xr do
      if y <= math.min(rnd(s.H(x)), H - 1) then m[y][x] = true end
    end
  end
  if opt and opt.cut then -- high_jump: cape ends at the waist, hem flutters 1 px
    for x = X0, X1 do
      local cy = opt.cut - ((s.HW(x) < -0.2) and 1 or 0)
      for y = cy + 1, H - 1 do m[y][x] = nil end
    end
  end
  -- round the outer hem corners
  local trim = {}
  for y = s.top, H - 1 do
    for _, x in ipairs({ E[y][1], E[y][2] }) do
      if m[y][x] and not get(m, x, y + 1) then trim[#trim + 1] = { x, y } end
    end
  end
  for _, t in ipairs(trim) do m[t[2]][t[1]] = nil end
  -- drop pixels hanging by a thread (<= 1 cape neighbour) so no islands/spikes remain
  for _ = 1, 8 do
    local rm = {}
    for y = s.top, H - 1 do for x = X0, X1 do
      if m[y][x] then
        local nb = 0
        for _, o in ipairs({ { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } }) do
          if get(m, x + o[1], y + o[2]) then nb = nb + 1 end
        end
        if nb <= 1 then rm[#rm + 1] = { x, y } end
      end
    end end
    for _, t in ipairs(rm) do m[t[2]][t[1]] = nil end
  end

  if opt and opt.petals then petals(m, s.top) end

  local function bottom(x, y) local yy = y; while get(m, x, yy + 1) do yy = yy + 1 end; return yy end
  local function crease(x) return s.HW(x) <= s.HW(x - 1) and s.HW(x) < s.HW(x + 1) end
  local g = blank()
  for y = 0, H - 1 do for x = X0, X1 do
    if m[y][x] then
      local xl, xr = E[y][1], E[y][2]
      local dH = bottom(x, y) - y
      local w = s.HW(x)
      local col = P.c
      if y >= s.lin and x - xl >= 3 and xr - x >= 4 then col = P.g end      -- lining behind body
      if x == xr then col = P.b end                                          -- right shade
      if x == xl and s.SW(y, -1) < -0.35 then col = P.b end                  -- left edge pulled in
      if x == xr and s.SW(y, 1) > 0.55 and y >= s.lin then col = P.g end     -- right edge flips out
      if w < -0.25 and dH <= s.ld then col = P.g                              -- trough: lining shows
      elseif dH == 0 then col = P.b end                                      -- crest: shaded fold
      if col == P.c and crease(x) and dH >= s.ld + 1 and dH <= s.ld + 3 then col = P.b end
      g[y][x] = col
    elseif get(m, x - 1, y) or get(m, x + 1, y) or get(m, x, y - 1) or get(m, x, y + 1) then
      g[y][x] = A
    end
  end end
  if opt and opt.flames then flames(g, m, s, E, opt.flames) end
  return g, m
end

---------------------------------------------------------------- arms
--- Short chibi arm: shoulder (sx, sy), angle in degrees (0 = +x, 90 = up).
--- 4 px to the hand centre; 3 px sleeve (white, grey shade on one side),
--- rounded 2-3 px hand. The outline ring is only laid on empty/outline/cape
--- pixels away from the shoulder so the arm joins the torso cleanly.
local function arm(g, sx, sy, ang)
  local LEN = 4
  local a = math.rad(ang)
  local dx, dy = math.cos(a) * LEN, -math.sin(a) * LEN
  local hx, hy = sx + dx, sy + dy
  local L = blank()
  for y = math.floor(sy - 7), math.ceil(sy + 7) do for x = math.floor(sx - 7), math.ceil(sx + 7) do
    if inb(x, y) then
      local t = clamp(((x - sx) * dx + (y - sy) * dy) / (LEN * LEN), 0, 1)
      local qx, qy = sx + t * dx, sy + t * dy
      local d = math.sqrt((x - qx) ^ 2 + (y - qy) ^ 2)
      local dh = math.sqrt((x - hx) ^ 2 + (y - hy) ^ 2)
      if dh <= 1.15 then
        L[y][x] = (y > hy + 0.3) and P.l or P.k
      elseif d <= 1.3 and t < 0.75 then
        L[y][x] = (d > 0.7 and y > qy) and P.C or P.o -- grey on the underside
      end
    end
  end end
  for y = 0, H - 1 do for x = X0, X1 do
    if not L[y][x] and (get(L, x - 1, y) or get(L, x + 1, y) or get(L, x, y - 1) or get(L, x, y + 1)) then
      local v = g[y][x]
      local far = math.sqrt((x - sx) ^ 2 + (y - sy) ^ 2) > 1.6
      if far and (v == nil or v == A or CAPE[v]) then g[y][x] = A end
    end
  end end
  compose(g, L, 0, 0)
end

---------------------------------------------------------------- finishing passes
--- Outline pixels inside the cape mask that sit between two cape colours become cape.
local function seams(g, mask)
  local ch = {}
  for y = 0, H - 1 do for x = X0, X1 do
    if mask[y][x] and g[y][x] == A then
      local l, r, u, d = get(g, x - 1, y), get(g, x + 1, y), get(g, x, y - 1), get(g, x, y + 1)
      if l and r and CAPE[l] and CAPE[r] then ch[#ch + 1] = { x, y, l }
      elseif u and d and CAPE[u] and CAPE[d] then ch[#ch + 1] = { x, y, u } end
    end
  end end
  for _, c in ipairs(ch) do g[c[2]][c[1]] = c[3] end
end
--- Removes outline pixels that touch no coloured pixel (strays).
local function cleanup(g)
  local rm = {}
  for y = 0, H - 1 do for x = X0, X1 do
    if g[y][x] == A then
      local keep = false
      for oy = -1, 1 do for ox = -1, 1 do
        local v = get(g, x + ox, y + oy)
        if v and v ~= A then keep = true end
      end end
      if not keep then rm[#rm + 1] = { x, y } end
    end
  end end
  for _, p in ipairs(rm) do g[p[2]][p[1]] = nil end
end
--- Closes the silhouette: empty pixels 4-touching a coloured pixel become outline.
local function outline(g)
  local add = {}
  for y = 0, H - 1 do for x = X0, X1 do
    if not g[y][x] then
      for _, o in ipairs({ { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } }) do
        local v = get(g, x + o[1], y + o[2])
        if v and v ~= A then add[#add + 1] = { x, y }; break end
      end
    end
  end end
  for _, p in ipairs(add) do g[p[2]][p[1]] = A end
end

local cache = {}
local function rgb(h)
  if not cache[h] then
    cache[h] = pc.rgba(tonumber(h:sub(1, 2), 16), tonumber(h:sub(3, 4), 16), tonumber(h:sub(5, 6), 16), 255)
  end
  return cache[h]
end
local function toImage(g, cmap)
  local im = Image(W, H, ColorMode.RGB)
  im:clear(pc.rgba(0, 0, 0, 0))
  for y = 0, H - 1 do for x = X0, X1 do
    local v = g[y][x]
    if v then im:drawPixel(x - X0, y, rgb((cmap and cmap[v]) or v)) end
  end end
  return im
end
--- Cape layer under body layer, then cleanup passes.
local function frame(cape, mask, body)
  local g = blank()
  compose(g, cape, 0, 0)
  compose(g, body, 0, 0)
  return g, mask
end
local function finish(g, mask, cmap)
  if mask then seams(g, mask) end
  cleanup(g)
  outline(g)
  return toImage(g, cmap)
end

---------------------------------------------------------------- load reference
local srcSpr = app.open(root .. "/assets/art/player/jei/default/reference.png")
local refImg = Image(srcSpr.spec); refImg:drawSprite(srcSpr, 1)
srcSpr:close()
assert(refImg.width == RW and refImg.height == H, "reference must be 40x52")
local REF = blank()
for y = 0, H - 1 do for x = 0, RW - 1 do
  local p = refImg:getPixel(x, y)
  if pc.rgbaA(p) > 0 then
    REF[y][x] = string.format("%02X%02X%02X", pc.rgbaR(p), pc.rgbaG(p), pc.rgbaB(p))
  end
end end

-- Reference hanging arms (rows 37-43, incl. their outline).
local ARM_L = { [37] = { 9, 11 }, [38] = { 8, 11 }, [39] = { 7, 11 }, [40] = { 7, 10 },
  [41] = { 6, 9 }, [42] = { 6, 9 }, [43] = { 6, 8 } }
local ARM_R = { [37] = { 23, 25 }, [38] = { 23, 27 }, [39] = { 24, 28 }, [40] = { 24, 29 },
  [41] = { 25, 30 }, [42] = { 26, 30 }, [43] = { 27, 30 } }
-- Dress outline x per row (reference coords).
local DRESS_L = { [37] = 12, [38] = 12, [39] = 12, [40] = 11, [41] = 10, [42] = 10, [43] = 9, [44] = 9, [45] = 10, [46] = 11 }
local DRESS_R = { [37] = 22, [38] = 22, [39] = 23, [40] = 23, [41] = 24, [42] = 25, [43] = 26, [44] = 27, [45] = 26, [46] = 24 }
local function inArm(x, y, R) return R[y] and x >= R[y][1] and x <= R[y][2] end

--- Body without the side cape (rows 37+): dress, legs, and optionally the arms.
local function bodyOf(src, withArms)
  return extract(src, function(x, y, v)
    if y <= 36 then return true end
    if y <= 46 then
      if x >= DRESS_L[y] and x <= DRESS_R[y] then return true end
      return withArms and (inArm(x, y, ARM_L) or inArm(x, y, ARM_R))
    end
    return x >= 13 and x <= 24 and not CAPE[v]
  end)
end

-- Eyes squeezed to > < (only the eye boxes; rest of the face untouched).
local EYES_HURT = {
  { 21, 9, "aakk" }, { 22, 9, "kaak" }, { 23, 9, "kkaa" }, { 24, 9, "kaak" }, { 25, 9, "aakk" },
  { 21, 18, "kkkaak" }, { 22, 18, "kkaakk" }, { 23, 18, "kaakkk" }, { 24, 18, "kkaakk" }, { 25, 18, "kkkaak" },
}

--- Bands: head+hood (0-30), upper body+arms (31-43), dress bottom (44-46), legs (47-51).
local function bandsOf(src)
  return {
    head = extract(src, function(_, y) return y <= 30 end),
    upper = extract(src, function(_, y) return y >= 31 and y <= 43 end),
    lower = extract(src, function(_, y) return y >= 44 and y <= 46 end),
    legs = extract(src, function(_, y) return y >= 47 end),
  }
end
local function composeBands(b, o)
  local g = blank()
  compose(g, b.lower, o.lower[1], o.lower[2])
  compose(g, b.legs, o.legs[1], o.legs[2])
  compose(g, b.upper, o.upper[1], o.upper[2])
  compose(g, b.head, o.head[1], o.head[2])
  return g
end

-- Base cape edges matching the reference silhouette (left 3 / right 37 at the hem).
local function refL(y) return math.max(3, 10 - 0.7 * (y - 33)) end
local function refR(y) return math.min(37, 29 + 0.7 * (y - 33)) end

---------------------------------------------------------------- cape sets
-- Colour roles and set colours: tools/art/jei_capes.lua (static set references).
local ROLE_OF = { C33132 = "c", ["9E1D27"] = "e", ["961824"] = "b",
                  ["5C121F"] = "g", ["4F181E"] = "y", ["43141C"] = "A" }
local SET_COLS = {
  fireball  = { c = "EC7C2A", e = "C45A20", b = "B44A1C", g = "7A2C14", y = "56200F", A = "48180E" },
  high_jump = { c = "3A9CDC", e = "2A78BC", b = "2668AE", g = "17407A", y = "142E58", A = "11264A" },
  glide     = { c = "EE6FA6", e = "D25690", b = "C24C86", g = "82285A", y = "5E1E44", A = "4E1A3A" },
}
local SETS = {
  fireball = { flames = true, hood = { -- flame tongue on the back point of the hood
    { 4, 36, "aa" }, { 5, 35, "acca" }, { 6, 34, "acLca" }, { 7, 33, "acLYLa" },
    { 8, 33, "ccLYLa" }, { 9, 35, "cLca" }, { 10, 36, "cca" }, { 11, 37, "ca" }, { 12, 38, "a" } } },
  high_jump = { cut = true, hood = { -- two 3x3 cross stars
    { 21, 33, "W" }, { 22, 32, "WWW" }, { 23, 33, "W" },
    { 34, 25, "W" }, { 35, 24, "WWW" }, { 36, 25, "W" } } },
  glide = { widen = 2, petals = true, hood = {} },
}
for name, st in pairs(SETS) do
  st.cmap = {}
  for hex, role in pairs(ROLE_OF) do st.cmap[hex] = SET_COLS[name][role] end
end
-- Waist row (cape cut) and flame placement per animation.
local CUT = { idle = 42, jump = 41, fall = 41, hurt = 42 }
local FLAME_MODE = { idle = "side", jump = "side", fall = "hem", hurt = "side" }
local function optFor(st, anim)
  if not st then return nil end
  return { cut = st.cut and CUT[anim], petals = st.petals, flames = st.flames and FLAME_MODE[anim] }
end

--- Builds idle/jump/fall/hurt frames for one set (st == nil: default cape).
local function build(st)
  local SREF = REF
  if st then SREF = copy(REF); edit(SREF, st.hood) end
  local widen = st and st.widen
  local cmap = st and st.cmap

---------------------------------------------------------------- idle (6)
-- Head+hood bob 0,1,2,2,1,0 px; upper body sinks 1 px while the head is down.
-- Cape: gentle 6-frame loop — side ripple +-1.6 px, hem folds +-1.5 px.
local BODY = bodyOf(SREF, true)
local BB = bandsOf(BODY)
local idle = {}
local BOB = { 0, 1, 2, 2, 1, 0 }
for f = 1, 6 do
  local h = BOB[f]
  local cape, mask = capeLayer(capeSpec({ f = f, n = 6, top = 34, hem = 48.5, L0 = refL, R0 = refR,
    amp = 1.6, vper = 9, hamp = 1.3, per = 10, lin = 43, ld = 1, widen = widen }), optFor(st, "idle"))
  local body = composeBands(BB, { head = { 0, h }, upper = { 0, math.min(h, 1) }, lower = { 0, 0 }, legs = { 0, 0 } })
  local g, m = frame(cape, mask, body)
  idle[f] = finish(g, m, cmap)
end

---------------------------------------------------------------- jump (3)
-- Body stretched: head 2 px up, torso 1 row longer, dress hem 1 px up; legs
-- tucked; short arms raised. Cape trails down behind the legs, narrower,
-- strong flutter (side +-2, hem folds +-2 px reaching the bottom row).
local JUMP_BASE = bodyOf(SREF, false)
for y = 47, H - 1 do JUMP_BASE[y] = {} end
local JUMP_BODY = stack(JUMP_BASE, { { 0, 41 }, { 41, 41 }, { 42, 46 } }, -2)
local TUCK = { "aiiia", "aEEEa", ".aaa." }
local JUMP_LEG_Y = { { 0, 0 }, { 0, 1 }, { 1, 0 } }
local JUMP_ARM = { 140, 150, 132 }
local jump = {}
for f = 1, 3 do
  local cape, mask = capeLayer(capeSpec({ f = f, n = 3, top = 33, hem = 49,
    L0 = function(y) return math.max(5, 10 - 0.6 * (y - 33)) end,
    R0 = function(y) return math.min(35, 29 + 0.6 * (y - 33)) end,
    amp = 2, vper = 7, hamp = 1.2, per = 14, scallop = true, lin = 42, ld = 1, widen = widen }), optFor(st, "jump"))
  local body = copy(JUMP_BODY)
  stamp(body, 12, 46 + JUMP_LEG_Y[f][1], TUCK)
  stamp(body, 21, 46 + JUMP_LEG_Y[f][2], TUCK)
  local g = frame(cape, mask, body)
  arm(g, 10.5, 35, JUMP_ARM[f])
  arm(g, 23.5, 35, 180 - JUMP_ARM[f])
  jump[f] = finish(g, mask, cmap)
end

---------------------------------------------------------------- fall (3)
-- Hood puffed 1 px, body 1 px up; cape billows up and out to the full margin
-- (corners lifted ~10 px), big flapping folds (side +-1.6, hem +-2.2); arms
-- out, flapping; legs dangling, one kicked up per frame.
local FALL_BASE = bodyOf(SREF, false)
for y = 47, H - 1 do FALL_BASE[y] = {} end
local FALL_BODY = stack(FALL_BASE, { { 0, 7 }, { 7, 7 }, { 8, 46 } }, -2)
local DANG_L = { "aiiia", "aklla", ".akla", ".aEEa", ".aEEa", "..aa." }
local DANG_R = { "aiiia", "allka", "akla.", "aEEa.", "aEEa.", ".aa.." }
local function kicked(rows) return { rows[1], rows[2], rows[4], rows[5], rows[6] } end
local FALL_ARM = { 165, 150, 178 }
local FALL_ARM_R = { 20, 2, 32 }
local fall = {}
for f = 1, 3 do
  local cape, mask = capeLayer(capeSpec({ f = f, n = 3, top = 32, hem = 47, lift = 9,
    L0 = function(y) return math.max(-3, 10 - 1.7 * (y - 33)) end,
    R0 = function(y) return math.min(42, 29 + 1.7 * (y - 33)) end,
    amp = 1.6, vper = 6, hamp = 1.5, per = 17, scallop = true, lin = 38, ld = 2, widen = widen }), optFor(st, "fall"))
  local body = copy(FALL_BODY)
  stamp(body, 11, 46, f == 3 and kicked(DANG_L) or DANG_L)
  stamp(body, 21, 46, f == 1 and kicked(DANG_R) or DANG_R)
  local g = frame(cape, mask, body)
  arm(g, 10.5, 35, FALL_ARM[f])
  arm(g, 23.5, 35, FALL_ARM_R[f])
  fall[f] = finish(g, mask, cmap)
end

---------------------------------------------------------------- hurt (3)
-- 1: squash + knocked back 2 px, eyes > <, cape starts flapping forward (+x).
-- 2: most tilted, eyes > <, cape flung forward (skew 4 px) with big folds.
-- 3: recovering, eyes open, cape settling back.
local HB = bandsOf(bodyOf((function() local s = copy(SREF); edit(s, EYES_HURT); return s end)(), true))
local HURT = {
  { b = HB, o = { head = { -2, 1 }, upper = { -2, 1 }, lower = { -1, 0 }, legs = { -1, 0 } }, ox = -1, skew = 2.5 },
  { b = HB, o = { head = { -2, 0 }, upper = { -1, 0 }, lower = { 0, 0 }, legs = { 1, 0 } }, ox = 0, skew = 4 },
  { b = BB, o = { head = { -1, 0 }, upper = { -1, 0 }, lower = { 0, 0 }, legs = { 0, 0 } }, ox = 0, skew = 1 },
}
local hurt = {}
for f = 1, 3 do
  local hf = HURT[f]
  local cape, mask = capeLayer(capeSpec({ f = f, n = 3, top = 34, hem = 48.5, L0 = refL, R0 = refR,
    ox = hf.ox, skew = hf.skew, amp = 2, vper = 8, hamp = 1.5, per = 9, lin = 43, ld = 1, widen = widen }), optFor(st, "hurt"))
  local g, m = frame(cape, mask, composeBands(hf.b, hf.o))
  hurt[f] = finish(g, m, cmap)
end

  return { idle = idle, jump = jump, fall = fall, hurt = hurt }
end

---------------------------------------------------------------- save
local function save(frames, outDir, srcDir, rel, ms)
  local spr = Sprite(W, H, ColorMode.RGB)
  for _ = 2, #frames do spr:newEmptyFrame() end
  for i, im in ipairs(frames) do
    spr:newCel(spr.layers[1], i, im, Point(0, 0))
    spr.frames[i].duration = ms / 1000
  end
  spr:saveAs(srcDir .. rel .. ".aseprite")
  spr:close()
  local strip = Image(W * #frames, H, ColorMode.RGB)
  strip:clear(pc.rgba(0, 0, 0, 0))
  for i, im in ipairs(frames) do strip:drawImage(im, Point((i - 1) * W, 0)) end
  local s2 = Sprite(strip.spec)
  s2:newCel(s2.layers[1], 1, strip, Point(0, 0))
  s2:saveAs(outDir .. rel .. ".png")
  s2:close()
end
local function saveSet(fr, outDir, srcDir)
  save(fr.idle, outDir, srcDir, "idle", 200)
  save(fr.jump, outDir, srcDir, "jump", 100)
  save(fr.fall, outDir, srcDir, "fall", 100)
  save(fr.hurt, outDir, srcDir, "hurt", 100)
end

local sky, teal, tealD = rgb("BFEFFF"), rgb("50AF9F"), rgb("408F9F")
local function bg(sheet, CH)
  for y = 0, sheet.height - 1 do
    local cy = y % CH
    local c = sky
    if cy >= 56 then c = (cy >= 58) and tealD or teal end
    for x = 0, sheet.width - 1 do sheet:drawPixel(x, y, c) end
  end
end
local function scaled(sheet, K, path)
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

local which = app.params["set"] or "default"
local ABILITY = { "fireball", "high_jump", "glide" }

if which == "default" or which == "all" then
  local fr = build(nil)
  saveSet(fr, OUT, SRCDIR)
  local idle, jump, fall, hurt = fr.idle, fr.jump, fr.fall, fr.hurt
  -- Review sheets: row 1 idle 1-6 | row 2 jump 1-3, fall 1-3 | row 3 hurt 1-3, gap, reference.
  local CW, CH = 56, 60
  local cells = {
    { idle[1], idle[2], idle[3], idle[4], idle[5], idle[6] },
    { jump[1], jump[2], jump[3], fall[1], fall[2], fall[3] },
    { hurt[1], hurt[2], hurt[3], false, false, refImg },
  }
  local sheet = Image(CW * 6, CH * 3, ColorMode.RGB)
  bg(sheet, CH)
  for y = CH, sheet.height - 1 do sheet:drawPixel(CW * 3, y, tealD) end -- group divider
  for r, row in ipairs(cells) do
    for c, im in ipairs(row) do
      if im then
        local inset = (im == refImg) and (4 - X0) or 4 -- reference aligned with the +4 frame offset
        sheet:drawImage(im, Point((c - 1) * CW + inset, (r - 1) * CH + 4))
      end
    end
  end
  scaled(sheet, 6, REVIEW .. "anim_a_x6.png")
  scaled(sheet, 3, REVIEW .. "anim_a_x3.png")
end

local built = {}
for _, name in ipairs(ABILITY) do
  if which == name or which == "all" then
    local fr = build(SETS[name])
    saveSet(fr, root .. "/assets/art/player/jei/" .. name .. "/", REVIEW .. name .. "/")
    built[#built + 1] = fr
  end
end
-- Ability review sheet: rows fireball / high_jump / glide; columns idle 1-6, jump 1-3, fall 1-3, hurt 1-3.
if #built == #ABILITY then
  local CW, CH = 56, 60
  local sheet = Image(CW * 15, CH * #built, ColorMode.RGB)
  bg(sheet, CH)
  for r, fr in ipairs(built) do
    local col = 0
    for _, anim in ipairs({ "idle", "jump", "fall", "hurt" }) do
      for _, im in ipairs(fr[anim]) do
        sheet:drawImage(im, Point(col * CW + 4, (r - 1) * CH + 4))
        col = col + 1
      end
      if anim ~= "hurt" then
        for y = (r - 1) * CH, r * CH - 1 do sheet:drawPixel(col * CW, y, tealD) end -- group divider
      end
    end
  end
  scaled(sheet, 3, REVIEW .. "sets_a_x3.png")
end
print("done")
