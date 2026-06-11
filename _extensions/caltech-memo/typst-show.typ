// caltech-memo: forward Pandoc metadata into the `memo` function defined
// in typst-template.typ. Any field omitted falls back to the function default.
#show: doc => memo(
$if(memo.to)$
  to: ($for(memo.to)$[$it$], $endfor$),
$endif$
$if(memo.from)$
  from: ($for(memo.from)$[$it$], $endfor$),
$endif$
$if(memo.subject)$
  subject: [$memo.subject$],
$endif$
$if(date)$
  date: [$date$],
$endif$
$if(memo.email)$
  email: [$memo.email$],
$endif$
$if(memo.mail-code)$
  mail-code: [$memo.mail-code$],
$endif$
$if(memo.phone)$
  phone: [$memo.phone$],
$endif$
$if(typst-logo-path)$
  logo: $typst-logo-path$,
$endif$
$if(department)$
  department: [$department$],
$endif$
$if(fontsize)$
  fontsize: $fontsize$,
$endif$
  doc,
)
