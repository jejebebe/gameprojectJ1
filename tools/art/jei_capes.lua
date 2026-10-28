-- jei_capes.lua — builds Jei's three ability cape sets from the default reference.
-- Usage (Aseprite batch):
--   Aseprite.exe -b --script-param root=<repo root> --script tools/art/jei_capes.lua
-- Reads  assets/art/player/jei/default/reference.png (never written).
-- Writes assets/art/player/jei/<set>/reference.png,
--        assets/art_src/player/jei/<set>/reference.aseprite,
--        assets/art_src/player/jei/capes_sheet_x6.png and capes_sheet_x3.png.
-- Only cape/hood reds are recoloured; mouth (AA373C, A13339, E67674) and skin
-- (B4645C etc.) are untouched. Shape edits are explicit per-pixel rows below.

local root = app.params["root"]
local SRC = root .. "/assets/art/player/jei/default/reference.png"

local function rgb(h)
  return Color{ r = tonumber(h:sub(1,2),16), g = tonumber(h:sub(3,4),16),
                b = tonumber(h:sub(5,6),16), a = 255 }
end

-- Cape/hood colour roles in the default sprite.
-- c = main fill, e = single-pixel alt tone, b = mid shade, g = lining/shadow,
-- y = deepest fold, A = neck tie
local ROLE_OF = { C33132 = "c", ["9E1D27"] = "e", ["961824"] = "b",
                  ["5C121F"] = "g", ["4F181E"] = "y", ["43141C"] = "A" }

local SETS = {
  fireball  = { c = "EC7C2A", e = "C45A20", b = "B44A1C", g = "7A2C14", y = "56200F", A = "48180E" },
  high_jump = { c = "3A9CDC", e = "2A78BC", b = "2668AE", g = "17407A", y = "142E58", A = "11264A" },
  glide     = { c = "EE6FA6", e = "D25690", b = "C24C86", g = "82285A", y = "5E1E44", A = "4E1A3A" },
}
-- Y = flame_core, L = flame_mid (light orange between cape_orange_hi and core)
local FIXED = { a = "010101", Y = "FFF3A0", L = "FFB347", W = "FEFEFE" }

-- Shape edits: { y, x0, string }. '.' clear, '_' keep, a/Y/L/W fixed colours,
-- c/e/b/g/y/A = this set's role colour.
local EDITS = {
  -- Rounded flame tongues (tip up, core Y + light-orange L) on both hem
  -- sides and two small tips on the hood's back point. Only cape outline,
  -- cape fill and transparent pixels are touched; body pixels stay default.
  fireball = {
    -- left side, upper tongue
    {37, 1, "aa"}, {38, 0, "acca"}, {39, 0, "acLca"}, {40, 0, "aLYLcc"},
    {41, 0, "aLYLc"}, {42, 1, "aLcc"}, {43, 2, "a"},
    -- left hem corner tongue
    {44, 1, "aa"}, {45, 0, "accc"}, {46, 0, "aLLcc"}, {47, 0, "aLYLc"},
    {48, 0, "aLYYLc"}, {49, 1, "aLYLcc"}, {50, 2, "aLccca"}, {51, 3, "aaaa"},
    -- right side, upper tongue
    {37, 37, "aa"}, {38, 36, "acca"}, {39, 33, "aaacLca"}, {40, 33, "ccLYLca"},
    {41, 34, "cLYLa"}, {42, 34, "cLca"}, {43, 36, "a"},
    -- right hem corner tongue
    {44, 37, "aa"}, {45, 36, "ccca"}, {46, 35, "ccLLa"}, {47, 35, "cLYLa"},
    {48, 34, "cLYYLa"}, {49, 33, "ccLYLa"}, {50, 32, "acccLa"}, {51, 33, "aaaa"},
    -- hood back point: one rounded flame tongue rising from the slope
    {4, 36, "aa"}, {5, 35, "acca"}, {6, 34, "acLca"}, {7, 33, "acLYLa"},
    {8, 33, "ccLYLa"}, {9, 35, "cLca"}, {10, 36, "cca"}, {11, 37, "ca"},
    {12, 38, "a"},
  },
  high_jump = {
    {43, 3, ".aaaaaa"}, {43, 31, "aaaa."},
    {44, 3, "......"}, {44, 28, "........."},
    {45, 3, "......."}, {45, 27, ".........."},
    {46, 3, "........"}, {46, 25, "............."},
    {47, 3, ".........."}, {47, 18, ".."}, {47, 25, "............."},
    {48, 4, "........."}, {48, 18, ".."}, {48, 25, "............"},
    {49, 5, "......"}, {49, 29, "......."},
    {50, 6, ".."}, {50, 29, "....."},
    -- two 3x3 cross stars
    {21, 33, "W"}, {22, 32, "WWW"}, {23, 33, "W"},
    {34, 25, "W"}, {35, 24, "WWW"}, {36, 25, "W"},
  },
  glide = {
    {40, 4, "acc"}, {41, 3, "acc"}, {42, 2, "accc"}, {43, 1, "accbc"},
    {44, 1, "acc"}, {45, 1, "acc"}, {46, 1, "acc"}, {47, 1, "acc"},
    {48, 1, "accc"}, {48, 11, "g"},
    {49, 1, "acccccgggaa.."}, {50, 1, "accaccagga"}, {51, 1, ".aa.aa.aa."},
    {41, 33, "cba"}, {42, 34, "cba"}, {43, 34, "ccba"}, {44, 35, "ccba"},
    {45, 36, "ccba"}, {46, 36, "ccba"}, {47, 36, "ccba"}, {48, 35, "cccba"},
    {49, 29, "accccccccba"}, {50, 29, ".accaccacba"}, {51, 29, "..aa.aa.aa."},
  },
}

local srcSpr = app.open(SRC)
local base = Image(srcSpr.spec); base:drawSprite(srcSpr, 1)
local W, H = base.width, base.height

local function hexOf(px)
  local c = Color(px)
  if c.alpha == 0 then return nil end
  return string.format("%02X%02X%02X", c.red, c.green, c.blue)
end

local function build(name)
  local map = SETS[name]
  local img = base:clone()
  for y = 0, H-1 do for x = 0, W-1 do
    local h = hexOf(img:getPixel(x, y))
    local role = h and ROLE_OF[h]
    if role then img:drawPixel(x, y, rgb(map[role])) end
  end end
  for _, e in ipairs(EDITS[name]) do
    local y, x0, s = e[1], e[2], e[3]
    for i = 1, #s do
      local ch, x = s:sub(i,i), x0 + i - 1
      if ch == "." then img:drawPixel(x, y, Color{r=0,g=0,b=0,a=0})
      elseif ch ~= "_" then
        img:drawPixel(x, y, rgb(FIXED[ch] or map[ch]))
      end
    end
  end
  return img
end

local function savePng(img, path)
  local s = Sprite(img.spec)
  s:newCel(s.layers[1], 1, img, Point(0,0))
  s:saveAs(path); s:close()
end

local imgs = { base }
for _, name in ipairs({ "fireball", "high_jump", "glide" }) do
  local img = build(name)
  savePng(img, root .. "/assets/art/player/jei/" .. name .. "/reference.png")
  savePng(img, root .. "/assets/art_src/player/jei/" .. name .. "/reference.aseprite")
  table.insert(imgs, img)
end

-- Review sheet: 4 cells of 48x60 on sky, teal ground strip under the feet.
local CW, CH = 48, 60
local sheet = Image(CW * #imgs, CH, ColorMode.RGB)
local sky, teal, tealD = rgb("BFEFFF"), rgb("50AF9F"), rgb("408F9F")
for y = 0, CH-1 do for x = 0, sheet.width-1 do
  local c = sky
  if y >= 56 then c = (y >= 58) and tealD or teal end
  sheet:drawPixel(x, y, c)
end end
for i, img in ipairs(imgs) do sheet:drawImage(img, Point((i-1)*CW + 4, 4)) end

local function scaled(img, k)
  local out = Image(img.width * k, img.height * k, ColorMode.RGB)
  for y = 0, img.height-1 do for x = 0, img.width-1 do
    local p = img:getPixel(x, y)
    for dy = 0, k-1 do for dx = 0, k-1 do out:drawPixel(x*k+dx, y*k+dy, p) end end
  end end
  return out
end
savePng(scaled(sheet, 6), root .. "/assets/art_src/player/jei/capes_sheet_x6.png")
savePng(scaled(sheet, 3), root .. "/assets/art_src/player/jei/capes_sheet_x3.png")
print("done")
