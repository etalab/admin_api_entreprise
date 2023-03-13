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
   donner le nom `provider_resource.yml` (par exemple: `inpi_actes.yml`) ;
2. Choissisez un `uid` pour votre endpoint: celui-ci servira pour l'URL du
   endpoint (par exemple: `inpi_actes` et donnera donc `/endpoints/inpi_actes`)
3. Mettez le `path` **exact** présent dans le fichier OpenAPI correspondant au
   endpoint: cette variable permet de retrouver automatiquement les infos du
   fichier OpenAPI (par exemple: `/v3/inpi/actes/{siren}`)
4. Finir de remplir les infos dans les clés

A partir de ce moment, le endpoint devrait apparaître sur `/endpoints`.

A noter que le markdown supporté annoté GFM signifie `Github Flavored Markdown`,
la documentation est disponible [ici](https://github.github.com/gfm/)
