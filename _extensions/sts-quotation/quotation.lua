-- Filter for the sts-quotation format.
--
-- 1. Builds the packages-and-fees table from the `fees` field of the YAML
--    header, and puts it where the document has an empty div with the class
--    `fees`:
--
--      ::: {.fees}
--      :::
--
--    The fee of each package is its days times the daily rate, so the fees
--    and totals in the table always agree with the days. Without a rate, the
--    table shows days only; with placeholder text for the rate, such as
--    "x,xxx", every fee shows that text. The table itself is drawn by `sts-fees` in
--    typst-template.typ.
--
-- 2. Passes the fields of `signature` to the template as raw Typst: the link
--    fields (email, web, linkedin, github, scholar) as strings, since the
--    Typst writer escapes characters such as @ that a link target must keep,
--    the other fields as content, and `false` as none. Sets `signature-off`
--    when the YAML header has `signature: false`.

local fees_meta = nil

local link_fields_set = {
  email = true,
  web = true,
  linkedin = true,
  github = true,
  scholar = true,
}

-- Stops the render. Quarto logs an error() raised in a filter and then
-- carries on, which here would produce a quotation with wrong fees, so the
-- message is logged and Pandoc exits with a non-zero status instead.
local function abort(message)
  quarto.log.error("sts-quotation fees: " .. message)
  os.exit(1)
end

local function to_typst(value)
  local t = pandoc.utils.type(value)
  local doc
  if t == "Blocks" then
    doc = pandoc.Pandoc(value)
  elseif t == "Inlines" then
    doc = pandoc.Pandoc({ pandoc.Plain(value) })
  else
    doc = pandoc.Pandoc({ pandoc.Plain({ pandoc.Str(tostring(value)) }) })
  end
  local out = pandoc.write(doc, "typst")
  return "[" .. out:gsub("%s+$", "") .. "]"
end

local function to_string_literal(value)
  local s = pandoc.utils.stringify(value)
  return '"' .. s:gsub("\\", "\\\\"):gsub('"', '\\"') .. '"'
end

local function to_number(value, what)
  local n = tonumber(pandoc.utils.stringify(value))
  if n == nil then
    abort(what .. " must be a number, not '" ..
      pandoc.utils.stringify(value) .. "'")
  end
  return tostring(n)
end

local function as_list(value)
  if value == nil then
    return {}
  end
  if pandoc.utils.type(value) == "List" then
    return value
  end
  return { value }
end

-- A number, with or without thousands separators ("1,200"), is a daily rate.
-- Text with no digits, such as "x,xxx", is a placeholder printed in place of
-- every fee and of the rate, for a template or an example. Text with digits
-- that is not a number, such as "1.200,00", is an error, so that a mistyped
-- rate cannot print as the fee of every package.
-- "1,200" -> 1200 and "12,000.50" -> 12000.5; nil unless every comma
-- separates a group of three digits
local function with_separators(s)
  local whole, fraction = s:match("^([%d,]+)(%.?%d*)$")
  if whole == nil or fraction == "." then
    return nil
  end
  local rest = whole:match("^%d%d?%d?(.*)$")
  if rest == nil or rest == "" then
    return nil
  end
  while rest ~= "" do
    rest = rest:match("^,%d%d%d(.*)$")
    if rest == nil then
      return nil
    end
  end
  return tonumber(whole:gsub(",", "") .. fraction)
end

local function rate_value(rate)
  if rate == nil then
    return "none"
  end
  local s = pandoc.utils.stringify(rate)
  local n = tonumber(s) or with_separators(s)
  if n ~= nil then
    return tostring(n)
  end
  if s:find("%d") then
    abort("rate must be a number, such as 1200 or \"1,200\", " ..
      "or placeholder text with no digits, such as \"x,xxx\", not '" .. s .. "'")
  end
  return to_string_literal(rate)
end

local function fees_call(f)
  local options = as_list(f.options)
  local option_strings = {}
  for _, o in ipairs(options) do
    table.insert(option_strings, to_typst(o))
  end
  local n_options = math.max(#options, 1)

  local packages = {}
  for i, p in ipairs(as_list(f.packages)) do
    local days = as_list(p.days)
    if #days ~= n_options then
      abort("package " .. i .. " has " .. #days ..
        " values of days, for " .. n_options .. " option(s)")
    end
    local day_strings = {}
    for _, d in ipairs(days) do
      table.insert(day_strings, to_number(d, "days"))
    end
    table.insert(
      packages,
      "(name: " .. to_typst(p.name or "") ..
      ", description: " .. (p.description and to_typst(p.description) or "none") ..
      ", days: (" .. table.concat(day_strings, ", ") .. ",))"
    )
  end

  local args = {
    "rate: " .. rate_value(f.rate),
    "options: (" .. table.concat(option_strings, ", ") ..
      (#option_strings > 0 and ",)" or ")"),
    "packages: (" .. table.concat(packages, ", ") ..
      (#packages > 0 and ",)" or ")"),
  }
  if f.symbol then
    table.insert(args, "symbol: " .. to_string_literal(f.symbol))
  end
  if f.currency then
    table.insert(args, "currency: " .. to_typst(f.currency))
  end
  if f.tax then
    table.insert(args, "tax: " .. to_typst(f.tax))
  end
  if f.note then
    table.insert(args, "note: " .. to_typst(f.note))
  end

  return "#sts-fees(" .. table.concat(args, ", ") .. ")"
end

return {
  {
    Meta = function(meta)
      fees_meta = meta.fees

      if meta.signature == false then
        meta.signature = nil
        meta["signature-off"] = true
      elseif pandoc.utils.type(meta.signature) == "table" then
        -- Each field is passed as raw Typst: text fields as content, link
        -- fields as strings, and `false` (as in `scholar: false`) as none,
        -- which drops that item from the signature
        local raw = function(code)
          return pandoc.Inlines({ pandoc.RawInline("typst", code) })
        end
        for k, v in pairs(meta.signature) do
          if v == false then
            meta.signature[k] = raw("none")
          elseif link_fields_set[k] then
            meta.signature[k] = raw(to_string_literal(v))
          else
            meta.signature[k] = raw(to_typst(v))
          end
        end
      end
      return meta
    end,
  },
  {
    Div = function(div)
      if not div.classes:includes("fees") then
        return nil
      end
      if fees_meta == nil then
        abort("the document has a .fees div but no fees field in its YAML header")
      end
      if not quarto.doc.is_format("typst") then
        return nil
      end
      return pandoc.RawBlock("typst", fees_call(fees_meta))
    end,
  },
}
