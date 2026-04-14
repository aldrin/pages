-- ajd.lua -- Pandoc Lua filter for the Org writing system
--
-- 1. Sets default author and date metadata (blank values suppress them)
-- 2. Promotes the first h1 to document title when #+title is absent
-- 3. Shifts remaining headings up one level to compensate
-- 4. Strips the empty "Footnotes" heading Org generates
-- 5. Numbers figures and tables, rewrites [[#label]] links for HTML
-- 6. Converts [[#label]] links to Typst @label cross-references
-- 7. Rewrites image paths: root-relative for Typst, inlines SVGs for HTML
-- 8. Passes explicit figure widths through to Typst
-- 9. Converts special blocks (aside, callout, key, twocol) per format
-- 10. Injects Typst imports for custom blocks that were used

local title_from_heading = false
local imports = {}
local ref_labels = {}

-- Map block class to Typst function name
local typst_blocks = {
  aside     = "aside",
  key       = "key-point",
  note      = "callout",
  tip       = "callout",
  warning   = "callout",
  important = "callout",
}

local function typst(blocks)
  return pandoc.write(pandoc.Pandoc(blocks), "typst")
end

local function html(blocks)
  return pandoc.write(pandoc.Pandoc(blocks), "html")
end

local function empty(meta_value)
  return meta_value and pandoc.utils.stringify(meta_value) == ""
end

local function prefix_caption(caption, kind, num)
  if not caption or not caption.long or #caption.long == 0 then return end
  local block = caption.long[1]
  if not block or not block.content then return end
  local prefix = pandoc.List{
    pandoc.Str(kind), pandoc.Space(),
    pandoc.Str(tostring(num) .. ":"), pandoc.Space()
  }
  prefix:extend(block.content)
  block.content = prefix
end

-----------------------------------------------------------------------
-- Filter 1: Number figures and tables for HTML cross-references
-----------------------------------------------------------------------
local numbering = {
  Pandoc = function(doc)
    if FORMAT == "typst" then return nil end
    local fig_n, tbl_n = 0, 0

    -- Number figures and tables, prefix captions
    doc = doc:walk({
      Figure = function(fig)
        local id = fig.identifier or ""
        if id == "" then return nil end
        fig_n = fig_n + 1
        ref_labels[id] = "Figure " .. fig_n
        prefix_caption(fig.caption, "Figure", fig_n)
        return fig
      end,
      Table = function(tbl)
        local id = tbl.identifier or ""
        if id == "" then return nil end
        tbl_n = tbl_n + 1
        ref_labels[id] = "Table " .. tbl_n
        prefix_caption(tbl.caption, "Table", tbl_n)
        return tbl
      end,
    })

    -- Rewrite cross-reference links
    doc = doc:walk({
      Link = function(link)
        if not link.target:match("^#") then return nil end
        local id = link.target:sub(2)
        local label = ref_labels[id]
        if not label then return nil end
        link.content = pandoc.List{pandoc.Str(label)}
        return link
      end,
    })

    return doc
  end,
}

-----------------------------------------------------------------------
-- Filter 2: Metadata, format conversion, and special blocks
-----------------------------------------------------------------------
local conversion = {
  Pandoc = function(doc)
    if not doc.meta.lang then
      doc.meta.lang = pandoc.MetaInlines{pandoc.Str("en")}
    end
    if empty(doc.meta.author) then
      doc.meta.author = nil
    elseif not doc.meta.author then
      doc.meta.author = {pandoc.MetaInlines{pandoc.Str("Aldrin D'Souza")}}
    end
    if empty(doc.meta.date) then
      doc.meta.date = nil
    elseif not doc.meta.date then
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

    if FORMAT ~= "typst" then
      local src = PANDOC_STATE.input_files[1] or ""
      if not src:match("index%.org$") then
        doc.meta["include-before"] = pandoc.MetaBlocks{
          pandoc.RawBlock("html", '<nav class="home"><a href="index.html">\u{2190} Other Pages</a></nav>')
        }
        local pdf = src:match("([^/]+)%.org$")
        if pdf then
          local date = pandoc.utils.stringify(doc.meta.date or pandoc.MetaInlines{})
          local link = '<a href="' .. pdf .. '.pdf">PDF</a>'
          if date ~= "" then
            link = date .. ' &middot; ' .. link
          end
          doc.meta.date = pandoc.MetaInlines{pandoc.RawInline("html", link)}
        end
      end
      doc.meta["include-after"] = pandoc.MetaBlocks{
        pandoc.RawBlock("html", '<footer>\u{a9} 2026 Aldrin D\u{2019}Souza. Licensed under <a href="https://creativecommons.org/licenses/by/4.0/">CC BY 4.0</a>.</footer>'),
        pandoc.RawBlock("html", '<script data-goatcounter="https://a1drin.goatcounter.com/count" async src="//gc.zgo.at/count.js"></script>')
      }
    end

    return doc
  end,

  Link = function(link)
    if FORMAT ~= "typst" then return nil end
    if link.target:match("^#") then
      return pandoc.RawInline("typst", "@" .. link.target:sub(2))
    end
  end,

  Image = function(img)
    if pandoc.path.is_absolute(img.src) then return img end
    if FORMAT == "typst" then
      img.src = "/" .. img.src
      return img
    end
    local path = img.src:gsub("^%./", "")
    if path:match("%.svg$") then
      local f = io.open(path, "r")
      if f then
        local svg = f:read("*a")
        f:close()
        return pandoc.RawInline("html", svg:gsub("^<%?xml[^>]*>%s*", ""))
      end
    end
    img.src = path
    return img
  end,

  Figure = function(fig)
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
  end,

  Div = function(div)
    local cls = div.classes[1]
    if not cls then return nil end

    if cls == "twocol" then
      local left, right = pandoc.List(), pandoc.List()
      local target = left
      for _, bl in ipairs(div.content) do
        if bl.t == "HorizontalRule" then target = right
        else target:insert(bl) end
      end
      if FORMAT == "typst" then
        imports.twocol = true
        return pandoc.RawBlock("typst",
          "#twocol[" .. typst(left) .. "#colbreak()" .. typst(right) .. "]")
      end
      return pandoc.RawBlock("html",
        '<div class="twocol"><div class="col">' .. html(left)
        .. '</div><div class="col">' .. html(right) .. '</div></div>')
    end

    local block_name = typst_blocks[cls]
    if not block_name then return nil end

    if FORMAT == "typst" then
      imports[block_name] = true
      if block_name == "callout" then
        return pandoc.RawBlock("typst",
          '#callout(kind: "' .. cls .. '")[' .. typst(div.content) .. ']')
      end
      return pandoc.RawBlock("typst",
        "#" .. block_name .. "[" .. typst(div.content) .. "]")
    end

    if block_name == "callout" then
      return pandoc.RawBlock("html",
        '<div class="callout ' .. cls .. '">'
        .. '<span class="callout-label">' .. cls:sub(1,1):upper() .. cls:sub(2) .. '</span>'
        .. html(div.content) .. '</div>')
    end
  end,

  Meta = function(meta)
    if FORMAT ~= "typst" then return nil end
    local names = {}
    for name in pairs(imports) do names[#names + 1] = name end
    if #names == 0 then return nil end
    table.sort(names)
    local import = pandoc.RawBlock("typst",
      '#import "/style/ajd.typ": ' .. table.concat(names, ", "))
    if meta["header-includes"] then
      meta["header-includes"]:insert(import)
    else
      meta["header-includes"] = pandoc.MetaBlocks({import})
    end
    return meta
  end,
}

return {numbering, conversion}
