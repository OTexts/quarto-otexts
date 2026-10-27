-- Add the self-hosted fonts (fonts.css and fonts/) to each HTML page
local fonts = {
  "Libron-Regular", "Libron-Italic", "Libron-Bold", "Libron-BoldItalic",
  "hack-regular-subset", "hack-bold-subset", "hack-italic-subset",
  "hack-bolditalic-subset",
}
for _, subset in ipairs({ "latin", "latin-ext" }) do
  for _, face in ipairs({ "400-normal", "400-italic", "600-normal", "700-normal",
    "700-italic" }) do
    table.insert(fonts, "fira-sans-" .. subset .. "-" .. face)
  end
end

local resources = {}
for _, font in ipairs(fonts) do
  table.insert(resources, { name = "fonts/" .. font .. ".woff2",
    path = "fonts/" .. font .. ".woff2" })
end

-- Write a list of metadata items into the page as JSON, for languages.js
local function add_json(id, items)
  local json = quarto.json.encode(items):gsub("</", "<\\/")
  quarto.doc.include_text("in-header",
    '<script type="application/json" id="' .. id .. '">' .. json .. "</script>")
end

-- Language selector: the `languages:` list (lang, name, url of each edition)
local function add_languages(languages)
  if not languages or #languages == 0 then return false end
  local editions = {}
  for _, l in ipairs(languages) do
    table.insert(editions, {
      lang = pandoc.utils.stringify(l.lang),
      name = pandoc.utils.stringify(l.name),
      url = pandoc.utils.stringify(l.url),
    })
  end
  add_json("otexts-languages", editions)
  return true
end

-- R and Python icons: the `software:` list (lang, name, url, and for the
-- current book `current: true`). `pages` maps this book's page names to the
-- other book's, e.g. intro: 01-intro
local function add_software(software)
  if not software or #software == 0 then return false end
  local books = {}
  for _, s in ipairs(software) do
    local book = {
      lang = pandoc.utils.stringify(s.lang),
      name = pandoc.utils.stringify(s.name),
      url = pandoc.utils.stringify(s.url),
      current = s.current == true,
    }
    if s.pages then
      book.pages = {}
      for key, value in pairs(s.pages) do
        book.pages[key] = pandoc.utils.stringify(value)
      end
    end
    table.insert(books, book)
  end
  add_json("otexts-software", books)
  return true
end

-- Title block byline (title-block.html): the authors on one line, as "A, B
-- and C" in the book's language, linked where they have a url, and each
-- affiliation once
local and_words = {
  en = "and", it = "e", es = "y", pt = "e", fr = "et", de = "und",
  el = "και", fa = "و", zh = "和", ja = "と", ko = "와",
}

local function add_byline(meta)
  local authors = meta["by-author"]
  if not authors or #authors == 0 then return end
  local lang = pandoc.utils.stringify(meta.lang or "en"):match("^%a+")
  local and_word = and_words[lang] or "and"
  local byline = pandoc.Inlines({})
  for i, a in ipairs(authors) do
    if i > 1 then
      if i == #authors then
        byline:extend({ pandoc.Space(), pandoc.Str(and_word), pandoc.Space() })
      else
        byline:extend({ pandoc.Str(","), pandoc.Space() })
      end
    end
    local name = a.name and a.name.literal or a.name
    name = pandoc.Inlines(name or {})
    if a.url then
      byline:insert(pandoc.Link(name, pandoc.utils.stringify(a.url)))
    else
      byline:extend(name)
    end
  end
  meta["otexts-byline"] = byline

  local affiliations = pandoc.List({})
  for _, aff in ipairs(meta["by-affiliation"] or {}) do
    if aff.name then affiliations:insert(pandoc.Inlines(aff.name)) end
  end
  if #affiliations > 0 then
    local joined = pandoc.Inlines({})
    for i, aff in ipairs(affiliations) do
      if i > 1 then joined:extend({ pandoc.Str(";"), pandoc.Space() }) end
      joined:extend(aff)
    end
    meta["otexts-affiliations"] = joined
  end
end

function Meta(meta)
  if quarto.doc.is_format("html") then
    add_byline(meta)
    quarto.doc.add_html_dependency({
      name = "otexts-fonts",
      version = "0.1.0",
      stylesheets = { "fonts.css" },
      resources = resources,
    })
    local has_languages = add_languages(meta.languages)
    local has_software = add_software(meta.software)
    if has_languages or has_software then
      quarto.doc.add_html_dependency({
        name = "otexts-languages",
        version = "0.1.0",
        scripts = { "languages.js" },
      })
    end
  end
  return meta
end

-- Mark [-@sec-...] refs so htmlreplace.pl can drop the "Chapter" prefix: on
-- unnumbered pages (e.g. the preface) Quarto ignores the "-" and gives the
-- full chapter title, which htmlreplace.pl would turn into "Chapter N"
function Cite(cite)
  local c = cite.citations[1]
  if #cite.citations == 1 and c.mode == "SuppressAuthor" and c.id:match("^sec%-") then
    return pandoc.Span(cite, { class = "xref-noprefix" })
  end
end
