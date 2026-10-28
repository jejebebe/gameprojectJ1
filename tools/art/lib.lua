-- Shared helpers for agent-drawn pixel art (design/art/art-bible.md §8).
--
-- Usage from a drawing script run in Aseprite batch mode:
--   local lib = dofile(app.params["root"] .. "/tools/art/lib.lua")
--   lib.init(app.params["root"])
--   local spr = lib.new_sprite(24, 32, 2)           -- width, height, frames
--   lib.draw_grid(spr, 1, { "....", ".aa." }, { a = "navy_ink" })
--   lib.finish(spr, "player/jei/default/idle")      -- saves .aseprite + strip PNG + x8 preview
--
-- Every colour is named from assets/art_src/palette/jei_master.gpl. An unknown
-- name stops the script with an error, so nothing outside the palette can be drawn.

local lib = {}

local root = nil
local colors = {}   -- name -> pixel value
local hexes = {}    -- name -> "RRGGBB"

--- Loads the master palette. `project_root` is the repo root (forward slashes).
function lib.init(project_root)
  root = project_root
  local path = root .. "/assets/art_src/palette/jei_master.gpl"
  local f = assert(io.open(path, "r"), "palette not found: " .. path)
  for line in f:lines() do
    local r, g, b, hex, name = line:match("^%s*(%d+)%s+(%d+)%s+(%d+)%s+(%x+)%s+(%S+)")
    if r then
      colors[name] = app.pixelColor.rgba(tonumber(r), tonumber(g), tonumber(b), 255)
      hexes[name] = hex
    end
  end
  f:close()
  assert(next(colors) ~= nil, "palette is empty: " .. path)
end

--- Pixel value for a palette colour name; errors on names not in the palette.
function lib.color(name)
  local c = colors[name]
  if c == nil then error("colour not in palette: " .. tostring(name)) end
  return c
end

--- New RGB sprite with `frames` empty frames.
function lib.new_sprite(w, h, frames)
  local spr = Sprite(w, h, ColorMode.RGB)
  for _ = 2, (frames or 1) do spr:newEmptyFrame() end
  return spr
end

--- Image of `frame` (1-based) on the first layer, creating the cel if needed.
function lib.image(spr, frame)
  local layer = spr.layers[1]
  local cel = layer:cel(frame)
  if cel == nil then cel = spr:newCel(layer, frame) end
  return cel.image
end

--- Draws a character grid onto `frame`. Each string is one row; each character
--- maps to a palette colour name through `key`. "." (or any unmapped space)
--- is transparent. `ox`, `oy` offset the grid (default 0, 0).
function lib.draw_grid(spr, frame, rows, key, ox, oy)
  local img = lib.image(spr, frame)
  ox, oy = ox or 0, oy or 0
  for y, row in ipairs(rows) do
    for x = 1, #row do
      local ch = row:sub(x, x)
      if ch ~= "." and ch ~= " " then
        local name = key[ch]
        if name == nil then error(string.format("no colour for '%s' at row %d col %d", ch, y, x)) end
        img:drawPixel(ox + x - 1, oy + y - 1, lib.color(name))
      end
    end
  end
end

--- Saves `<root>/assets/art_src/<rel>.aseprite`, exports the horizontal strip
--- to `<root>/assets/art/<rel>.png`, and writes an x8 preview next to the
--- source as `<rel>_x8.png` (for review; not used by the game).
function lib.finish(spr, rel)
  local src = root .. "/assets/art_src/" .. rel .. ".aseprite"
  local png = root .. "/assets/art/" .. rel .. ".png"
  app.fs.makeAllDirectories(app.fs.filePath(src))
  app.fs.makeAllDirectories(app.fs.filePath(png))
  spr:saveAs(src)
  app.command.ExportSpriteSheet{
    ui = false, type = SpriteSheetType.HORIZONTAL, textureFilename = png,
    borderPadding = 0, shapePadding = 0, innerPadding = 0,
  }
  local preview = Image(spr.width * #spr.frames, spr.height, ColorMode.RGB)
  for i = 1, #spr.frames do
    preview:drawSprite(spr, i, Point((i - 1) * spr.width, 0))
  end
  preview:resize(preview.width * 8, preview.height * 8)
  preview:saveAs(root .. "/assets/art_src/" .. rel .. "_x8.png")
  print("wrote " .. png .. " (" .. #spr.frames .. " frames)")
end

return lib
