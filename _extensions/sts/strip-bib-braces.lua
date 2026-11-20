-- strip-bib-braces.lua
--
-- Removes the braces that Better BibTeX writes into literal fields of
-- library.bib, such as type = {New {{Zealand Fisheries Assessment Report}}}.
-- The pandoc BibLaTeX reader reads the type field (CSL genre) as a plain
-- string, so the braces reach the reference list as text. Title and other
-- formatted fields are read as inlines, in which the braces become case
-- protection; this filter leaves those fields unchanged.
--
-- The filter reads the cited references, removes the braces from their
-- plain-string fields, writes the cleaned references to the references
-- metadata field, and removes the bibliography field, so that citeproc reads
-- only the cleaned copies. library.bib is not edited.
--
-- Registered for both formats in _extension.yml:
--   filters:
--     - strip-bib-braces.lua

-- Plain-string fields in which a brace could be legitimate.
local keep = {
  id = true,
  type = true,
  URL = true,
  DOI = true,
  ISBN = true,
  ISSN = true,
}

function Pandoc(doc)
  if not doc.meta.bibliography then
    return nil
  end

  local refs = pandoc.utils.references(doc)
  local changed = 0

  for _, ref in ipairs(refs) do
    for field, value in pairs(ref) do
      if not keep[field] and type(value) == "string" and value:find("[{}]") then
        ref[field] = value:gsub("[{}]", "")
        changed = changed + 1
      end
    end
  end

  if changed == 0 then
    return nil
  end

  doc.meta.references = refs
  doc.meta.bibliography = nil
  return doc
end
