#show: article.with(

  $if(title)$
    title: "$title$",
  $endif$

  $if(subtitle)$
    subtitle: "$subtitle$",
  $endif$

  $if(author)$
    author: "$author$",
  $endif$

  $if(date)$
    date: "$date$",
  $endif$

  $if(params.client)$
    client: "$params.client$",
  $endif$

  $if(params.cover)$
    cover: "$params.cover$",
  $endif$

  $if(params.tocimage)$
    tocimage: "$params.tocimage$",
  $endif$

  $if(params.campaign)$
    campaign: "$params.campaign$"
  $endif$

)
