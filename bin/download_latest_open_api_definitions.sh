#!/bin/bash

wget "https://particulier.api.gouv.fr/api/open-api.yml" \
  -O config/api-particulier-openapi.yml

wget "https://entreprise.api.gouv.fr/v3/openapi-entreprise.yaml" \
  -O config/api-entreprise-v3-openapi.yml
