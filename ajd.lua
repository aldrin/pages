-- ajd.lua -- Pandoc Lua filter for Org-to-Typst pipeline
--
-- 1. Promotes the first h1 to document title when #+title is absent
-- 2. Shifts remaining headings up one level to compensate
-- 3. Strips the empty "Footnotes" heading Org generates
-- 4. Sets default author and date (today)
-- 5. Converts internal links to Typst @label cross-references
-- 6. Rewrites image paths to root-relative for typst --root
-- 7. Converts special blocks (aside/callout/key/twocol) to Typst

local title_from_heading = false

-- Document-level transforms: metadata defaults, title promotion, heading cleanup
function Pandoc(doc)
  if not doc.meta.author or #doc.meta.author == 0 then
    doc.meta.author = {pandoc.MetaInlines{pandoc.Str("Aldrin D'Souza")}}
  end
  if not doc.meta.date then
    doc.meta.date = pandoc.MetaInlines{pandoc.Str(os.date("%Y-%m-%d"))}
  end

  if not doc.meta.title then
    for i, el in ipairs(doc.blocks) do
      if el.t == "Header" and el.level == 1 then
        doc.meta.title = pandoc.MetaInlines(el.content)
        doc.blocks:remove(i)
        title_from_heading = true
        break
      end
    end
  end

  local blocks = pandoc.List()
  for _, el in ipairs(doc.blocks) do
    if el.t == "Header" then
      if el.content[1] and el.content[1].text == "Footnotes" then
        goto continue
      end
      if title_from_heading and el.level > 1 then
        el.level = el.level - 1
      end
    end
    blocks:insert(el)
    ::continue::
  end

  doc.blocks = blocks
  return doc
end

-- Convert [[#label]] to Typst @label cross-references
function Link(link)
  if FORMAT ~= "typst" then return nil end
  if link.target:match("^#") then
    return pandoc.RawInline("typst", "@" .. link.target:sub(2))
  end
end

-- Rewrite relative image paths to root-relative for typst --root
function Image(img)
  if not pandoc.path.is_absolute(img.src) then
    img.src = "/" .. img.src
  end
  return img
end

-- Pass image width through to Figure's Typst output
function Figure(fig)
  if FORMAT ~= "typst" then return nil end
  local w = fig.attributes and fig.attributes.width
  if not w then return nil end
  local img = fig.content[1] and fig.content[1].content[1]
  if img and img.t == "Image" then
    local caption = pandoc.write(pandoc.Pandoc(fig.caption.long), "typst")
    local label = fig.identifier ~= "" and ("\n<" .. fig.identifier .. ">") or ""
    return pandoc.RawBlock("typst",
      '#figure(image("' .. img.src .. '", width: ' .. w .. '),\n'
      .. '  caption: [' .. caption .. ']\n)'
      .. label)
  end
end

-- Special block conversion
local imports = {}
local callout_kinds = { note = true, tip = true, warning = true, important = true }

local function render(blocks)
  return pandoc.write(pandoc.Pandoc(blocks), "typst")
end

function Div(div)
  if FORMAT ~= "typst" then return nil end

  for _, cls in ipairs(div.classes) do
    if callout_kinds[cls] then
      imports.callout = true
      return pandoc.RawBlock("typst",
        '#callout(kind: "' .. cls .. '")[' .. render(div.content) .. ']')
    end

    if cls == "aside" then
      imports.aside = true
      return pandoc.RawBlock("typst",
        "#aside[" .. render(div.content) .. "]")
    end

    if cls == "key" then
      imports["key-point"] = true
      return pandoc.RawBlock("typst",
        "#key-point[" .. render(div.content) .. "]")
    end

    if cls == "twocol" then
      imports.twocol = true
      local left, right = pandoc.List(), pandoc.List()
      local target = left
      for _, bl in ipairs(div.content) do
        if bl.t == "HorizontalRule" then
          target = right
        else
          target:insert(bl)
        end
      end
      return pandoc.RawBlock("typst",
        "#twocol[" .. render(left) .. "#colbreak()" .. render(right) .. "]")
    end
  end
end

-- Inject imports for custom blocks that were actually used
function Meta(meta)
  if FORMAT ~= "typst" then return nil end
  local names = {}
  for name in pairs(imports) do
    names[#names + 1] = name
  end
  if #names > 0 then
    table.sort(names)
    local import = pandoc.RawBlock("typst",
      '#import "/style/ajd.typ": ' .. table.concat(names, ", "))
    if meta["header-includes"] then
      meta["header-includes"]:insert(import)
    else
      meta["header-includes"] = pandoc.MetaBlocks({import})
    end
  end
  return meta
end
