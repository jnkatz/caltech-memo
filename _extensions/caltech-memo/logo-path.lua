-- caltech-memo: resolve the official Caltech wordmark (vector) to a path
-- each engine can find, regardless of the consuming project's working dir.
--   * LaTeX: a PDF via resolve_path (XeLaTeX embeds vector PDF natively).
--   * Typst: handled by the function default in typst-template.typ — it uses an
--     SVG with a literal, root-relative path, because (a) Typst can't embed
--     EPS/PDF, only SVG/raster, and (b) Pandoc's Typst writer escapes the
--     underscores resolve_path would emit ("\_extensions") and corrupts it.
function Meta(meta)
  if meta["logo-path"] ~= nil or quarto.doc.is_format("typst") then
    return meta
  end
  meta["logo-path"] = pandoc.MetaString(
    quarto.utils.resolve_path("caltech-logo-orange.pdf"))
  return meta
end
