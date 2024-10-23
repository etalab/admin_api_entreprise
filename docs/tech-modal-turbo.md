# Utilisation des modals avec Turbo

Une modal globale est partagée entre les diverses actions et définie dans la vue
[shared/modal](../app/views/shared/_modal.html.erb)

La procédure pour utiliser cette modale partagée:

Mettre un lien qui trigger une action rendant une vue, vue que l'on veut
mettre dans la modale, de la manière suivante:

```
<a href="link" data-turbo-frame="main-modal-content" data-fr-opened="false" aria-controls="main-modal">
  Link
</a>
```

Le `data-turbo-frame` explicite que la réponse de l'action doit cibler la
modal, le `aria-controls` permet d'ouvrir la modal.

La vue doit renvoyer des balises turbo-frame de cette manière:

```
<turbo-frame id="main-modal-content">
  Content
</turbo-frame>
```

De cette manière turbo va prendre le contenu de la balise turbo-frame et
remplacer celle de la modal par ce contenu.

Pour aller plus loin: [lien](https://blog.skelz0r.fr/posts/turbo-form-redirect)
