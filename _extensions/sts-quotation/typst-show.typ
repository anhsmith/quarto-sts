#show: sts-quotation.with(
$if(title)$
  title: [$title$],
$endif$
$if(subtitle)$
  subtitle: [$subtitle$],
$endif$
$if(client)$
  client: [$client$],
$endif$
$if(date)$
  date: [$date$],
$endif$
$if(purpose)$
  purpose: [$purpose$],
$endif$
$if(mainfont)$
  font: ("$mainfont$",),
$endif$
$if(papersize)$
  paper: "$papersize$",
$endif$
$if(signature-off)$
  signature-off: true,
$endif$
$if(signature)$
  signature: (
$if(signature.name)$
    name: $signature.name$,
$endif$
$if(signature.role)$
    role: $signature.role$,
$endif$
$if(signature.bio)$
    bio: $signature.bio$,
$endif$
$if(signature.address)$
    address: $signature.address$,
$endif$
$if(signature.email)$
    email: $signature.email$,
$endif$
$if(signature.web)$
    web: $signature.web$,
$endif$
$if(signature.linkedin)$
    linkedin: $signature.linkedin$,
$endif$
$if(signature.github)$
    github: $signature.github$,
$endif$
$if(signature.scholar)$
    scholar: $signature.scholar$,
$endif$
  ),
$endif$
)
