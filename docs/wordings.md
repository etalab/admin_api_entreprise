# Wordings globaux

La gestion des wordings des templates et layouts se fait à travers les fichiers i18n,
présent dans [`config/locales/`](../config/locales/).

Pour certaines pages, c'est directement codé dans le HTML. C'est le cas des
pages suivantes:

- [`/mentions`](app/views/pages/mentions.html.erb)
- [`/cgu`](app/views/pages/cgu.html.erb)

L'architecture des clés au sein du YAML suit l'architecture des fichiers au sein du dossier
`app/views`. Par exemple, pour la vue `app/views/endpoints/show.html.erb`, le
YAML sera architecturé comme suit:

```yaml
---
fr:
  endpoints:
    show:
      title: "Titre"
```

Et au sein de la vue, pour retrouver le `title` ci-dessus:

```html
<h1><%= t('.title') %></h1>
```
