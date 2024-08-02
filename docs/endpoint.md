# Ajout d'un nouveau endpoint

## Pré-requis

Pour ajouter un nouvel endpoint, il faut que celui-ci soit présent au sein du
fichier OpenAPI disponible à l'adresse suivante:
[https://entreprise.api.gouv.fr/v3/openapi-entreprise.yaml](https://entreprise.api.gouv.fr/v3/openapi-entreprise.yaml).

Il existe une copie locale situé [ici](../config/api-entreprise-v3-openapi.yml)
en cas d'erreur du serveur (pour le mettre à jour vous pouvez utiliser le
binaire `bin/download_latest_open_api_definition.sh`)

## Ajout d'un nouveau endpoint

1. Copier le fichier `template.yml.example` situé dans `config/endpoints` et lui
   donner le nom `provider_resource.yml` (par exemple: `infogreffe_extrait_rcs.yml`) ;
2. Choissisez un `uid` pour votre endpoint: celui-ci servira pour l'URL du
   endpoint (par exemple: `infogreffe/rcs/extrait` et donnera donc `/endpoints/infogreffe/rcs/extrait`)
3. Mettez le `path` **exact** présent dans le fichier OpenAPI correspondant au
   endpoint: cette variable permet de retrouver automatiquement les infos du
   fichier OpenAPI (par exemple: `/v3/infogreffe/rcs/unites_legales/{siren}/extrait_kbis`)
4. Finir de remplir les infos dans les clés

A partir de ce moment, le endpoint devrait apparaître sur `/endpoints`.

A noter que le markdown supporté annoté GFM signifie `Github Flavored Markdown`,
la documentation est disponible [ici](https://github.github.com/gfm/)
