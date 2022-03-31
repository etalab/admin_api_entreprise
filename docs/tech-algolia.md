# Algolia

Certains modèles sont indexés sur Algolia, ce qui permet d'avoir de la recherche
à moindre coup (sur du contenu de tout façon statique / open-source).

C'est le cas des entrées de FAQ (`FAQEntry`)

Pour effectuer des recherches, il y a 2 approches:

1. Frontend (recommandé par Algolia)
2. Backend

Le backend n'a pas été encore implémenté, seul le frontend est expliqué ici.

## Configuration / credentials

L'environnement de production a ses propres clés, et développement/test aussi.
Ceux-ci sont dans le fichier de credentials. Étant donné que ce ne sont pas des
données critiques, elles sont accessibles directement.

## Implémentation frontend

Il existe un controller stimulus
[`algolia-search-with-accordion`](../app/assets/javascripts/controllers/algolia_search_with_accordion_controller.js)
qui permet d'initialiser la recherche via Algolia.

Celui-ci permet de continuer à utiliser le DSFr en bypassant une partie de la
lib instantsearch et ainsi garder la cohérence du design (notamment la partie
`hits`).

Pour le moment celui-ci n'est utilisé que sur /faq, mais reste tout de même
assez générique (pas impossible de devoir faire de l'héritage pour implémenter
d'autres controller de recherche).

En plus des features classiques de Stimulus, ce controller s'appuie
extensivement sur les `data-algolia-search-with-accordion-*`.

Il faut notamment implémenter:

- `data-algolia-search-with-accordion-hit-attribute` pour chaque attribut que l'on veut rendre
  dans la vue
- `data-algolia-search-with-accordion-hit` pour chaque entrée

Vous pouvez jeter un oeil à la [page de la FAQ](../app/views/faq/index.html.erb)
pour voir plus en détails

## Reindexation des modèles

```shell
rails algolia:reindex
```

Cette réindexation est effectuée lors du déploiement pour la partie production,
et

## Ressources

- [Dépôt algolia/algoliasearch-rails](https://github.com/algolia/algoliasearch-rails)
- [Controller Stimulus `algolia-search-with-accordion`](../app/assets/javascripts/controllers/algolia_search_controller.js)
- [Documentation d'InstantSearch](https://www.algolia.com/doc/guides/building-search-ui/what-is-instantsearch/js/)
- [API Reference InstantSearch.js](https://www.algolia.com/doc/api-reference/widgets/js/)
