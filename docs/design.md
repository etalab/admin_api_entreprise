# Design

## Base / framework

Le site est basé sur le [Système de Design de
l'État](https://gouvfr.atlassian.net/wiki/spaces/DB/overview)

Les éléments / la documentation se trouvent sur le lien ci-dessous, la recherche
fonctionne assez bien (grid, button etc etc .. tout ça fonctionne)

Pour les icônes, la librairie [Remix Icon](https://remixicon.com/) sur laquelle
le DSFR s'est inspirée, a été ajoutée.

### Installation de la dernière version du DSFr

Avant toute chose, [téléchargez la dernière version
disponible](https://github.com/GouvernementFR/dsfr/releases)

Il y a quelques manipulations à respecter pour que cela fonctionne:

Concernant le CSS:

1. Remplacer le fichier `app/assets/stylesheets/dsfr.css` par le fichier du même nom dans `dist/dsfr`
2. Chercher l'ensemble des déclarations des font-face de Marianne et Spectral
   dans le fichier, et le supprimer. En effet c'est le fichier
   `app/assets/stylesheets/dsfr-fonts.scss` qui s'occupe de déclarer les fonts

Concernant le js:

1. Remplacer le fichier `app/assets/javascripts/dsfr.nomodule.js` par le fichier
   du même nom dans `dist/dsfr`
2. Wrapper l'ensemble du code dans le callback suivant:
   ```js
   document.addEventListener("turbo:load", function () {
     // Le code ici
   });
   ```

Concernant les icônes:

1. Remplacer le fichier `app/assets/stylesheets/dsfr-utility.css` par le fichier `dist/utility/utility.css`
2. Remplacer le dossier `app/assets/icons` par le dossier `dist/icons`

## Règles

- Essayez au maximum d'utiliser le design système
- Les breakpoints sont exclusivement basé sur des `md` => on n'utilise pas de
  `fr-col-lg-*`, seulement des `fr-col-md-*` si on veut faire du responsive
- Les blocks de code doivent être contenus dans des balises `<pre>`, mais pas dans le cas de code inline.
