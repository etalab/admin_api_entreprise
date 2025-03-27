#!/bin/bash

wget "https://particulier.api.gouv.fr/api/open-api.yml" \
  -O config/api-particulier-openapi.yml

wget "https://particulier.api.gouv.fr/api/open-api-v2.yml" \
  -O config/api-particulier-openapi-v2.yml

wget "https://particulier.api.gouv.fr/api/open-api-v3.yml" \
  -O config/api-particulier-openapi-v3.yml

wget "https://entreprise.api.gouv.fr/v3/openapi-entreprise.yaml" \
  -O config/api-entreprise-v3-openapi.yml
