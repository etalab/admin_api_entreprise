# Wordings

## Wordings globaux (templates, vues...)

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

## Cas d'usages

Il est possible de rajouter des cas d'usage en ajoutant une nouvelle entrée au fichier `config/locales/cas_usages_entries.fr.yml`, en respectant l'architecture du fichier.

Les listes d'APIs utiles (présente sur chaque page de cas d'usage) est renseignée depuis les clefs "use_cases" et "use_cases_optional" dans les fichiers endpoint correspondants.

La colonne pour commentaire dans cette liste se remplit depuis la fiche cas d'usage avec la structure suivante:

```
fr:
  cas_usages_entries:
    marches_publics:
      name: 'Marchés publics'
      comments_endpoints:
        "insee/etablissements_diffusibles": "commentaire à afficher"
        "inpi/rne/actes": "commentaire à afficher"
```

## Page/wordings FAQ

Les wordings de la FAQ globale se trouvent dans le fichier
[`config/locales/faq_entries.fr.yml`](../config/locales/faq_entries.fr.yml)

Pour chaque entrée, la clé `answer` est traduite du markdown au HTML (le
markdown supporté est le [Github Flavored
Markdown](https://github.github.com/gfm/))

Niveau éléments graphiques DSFR, une cheatsheet (des exemples sont aussi
disponibles dans le fichier de locale):

### Les tableaux

  ```md
  {:.fr-table}
  | Header 1 | Header 2 |
  | -------- | -------- |
  | Value 11 | Value 12 |
  | Value 21 | Value 22 |
  ```

### Les mise en exergues

  ```md
  {:.fr-highlight}

  > Texte

  {:.fr-highlight.fr-highlight--caution}

  > Texte qui exige de l'attention

  {:.fr-highlight.fr-highlight--example}

  > Texte de type exemple
  ```

### Les boutons

Bouton primaire bleu du DSFR :

  ```md
  [Texte du Bouton](https://www.google.fr}{:target="_blank"}){:.fr-btn}
  ```
 Bouton secondaire blanc contour bleu du DSFR :

  ```md
  [Texte du Bouton](https://www.google.fr}{:target="_blank"}){:.fr-btn fr-btn--secondary}
  ```

### Les liens externes (qui ajoute le picto externe)

  ```md
  [Lien externe](https://www.google.fr}{:target="_blank"})
  ```

De plus, il est possible d'utiliser les helpers de routes et d'images avec de
l'interpolation ERB.

### Les routes:

```md
Le lien du profile: [Profile](<%= user_profile_path %>)
```

La liste des urls sont disponibles en tapant la commande `rails routes` ou depuis ce fichier : [https://gist.github.com/skelz0r/48f3f6f4be8356f37e79368cfaa6e4f6](https://gist.github.com/Samuelfaure/fbaec88bca51aaa5d5af8d5ad5a273de)

#### Route vers les fiches métiers :

Exemple de la fiche métier de l'endpoint unités légales de l'insee :

```md
Le lien du profile: [Fiche métier "Données de référence d'une unité légale diffusible"](<%= endpoint_path(uid: 'insee/unites_legales_diffusibles') %>)
```

#### Route une question précise de la FAQ :

```md
[Exemple de lien vers une ancre de la FAQ](<%= faq_index_path(anchor: 'quelles-sont-les-conditions-d-eligibilite') %>)
```
#### Route vers fiche cas d'usage :

```md
[Cas d'usage aides et subventions publiques](<%= cas_usage_path('aides_publiques') %>)
```

### Les images:

```md
![Description image](<%= image_path('loading.gif') %>)
```

Le `'loading.gif'` doit être le chemin vers une image valide (ie dans
`app/assets/images`)

Pour gérer la taille de l'image, je peux ajouter une largeur et/ou une hauteur :
```md
![Description image](<%= image_path('loading.gif') %>){:width="600px"}
```

### Les citations

Bloc html à ajouter dans le fichier markdown :

```md
<figure class="fr-quote--column ">
{:.fr-quote}
>
> <blockquote>«&nbsp;LoremIpsum&nbsp;»
> </blockquote>
>
> <figcaption>
> Commune de Vénissieux
> {:.fr-quote__author}
>
> [Nom du lien](https://demarches.venissieux.fr/){:target="_blank"}
> {:.fr-quote__source}
>
> {:.fr-quote__image}
>  ![Decrit l'image](<%= image_path('api_entreprise/cas_usages/chemindelimage.png') %>){:width="100px"}
> </figcaption>
>
</figure>
```

### Les téléchargements

Bloc html à ajouter dans le fichier markdown :

```md
<div class="fr-grid-row fr-grid-row--gutters">
 <div class="fr-col-12 fr-col-md-6">
  <div class="fr-download fr-enlarge-link fr-download--card">
   <p>
    <a href="/files/formulaire-unique-subventions-associations-cerfa_12156-06.pdf" download class="fr-download__link">Télécharger le document
     <span class="fr-download__detail">PDF – 1,3 Mo</span>
    </a>
   </p>
   <p class="fr-download__desc">Lorem Ipsum pour en dire plus</p>
  </div>
 </div>
</div>
```


### Utilisation Ruby

A noter qu'il est aussi possible d'utiliser du ruby dans la vue (même si ce
n'est pas du tout recommandé):

```md
Il y a en ce moment <%= User.count %> d'inscrits
```
