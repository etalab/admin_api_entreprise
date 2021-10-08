# Design

## Base / framework

Le site est basé sur le [Système de Design de
l'État](https://gouvfr.atlassian.net/wiki/spaces/DB/overview)

Les éléments / la documentation se trouvent sur le lien ci-dessous, la recherche
fonctionne assez bien (grid, button etc etc .. tout ça fonctionne)

### Installation de la dernière version du DSFr

Il y a quelques manipulations à respecter:

1. Télécharger le zip et remplacer le fichier `app/assets/stylesheets/dsfr.css` par le fichier du même nom
   dans `dist/`
2. Chercher l'ensemble des déclarations des font-face de Marianne et Spectral
   dans le fichier, et le supprimer. En effet c'est le fichier
   `app/assets/stylesheets/dsfr-fonts.scss` qui s'occupe de déclarer les fonts

## Règles

- Essayez au maximum d'utiliser le design système
- Les breakpoints sont exclusivement basé sur des `md` => on n'utilise pas de
  `fr-col-lg-*`, seulement des `fr-col-md-*` si on veut faire du responsive
