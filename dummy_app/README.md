# Dummy DS app

Mini app Sinatra qui simule l'éditeur DS et démontre le flow OAuth2.

## Installation

```
cd dummy_app
bundle install
```

## Configuration

- `DS_OAUTH_CLIENT_ID` / `DS_OAUTH_CLIENT_SECRET` : identifiants Doorkeeper de l'application (générés par les seeds : `dummy-ds-client-id` / `dummy-ds-client-secret`).
- `API_ENTREPRISE_OAUTH_SITE` : URL du serveur OAuth2 (par défaut `http://entreprise.api.localtest.me:5000`).
- `SESSION_SECRET` : secret de session Sinatra.

## Lancement

```
cd dummy_app
bundle exec rackup -p 5678 -o 0.0.0.0
```

## Credentials ProConnect sandbox

- Email: `user@yopmail.com`
- Mot de passe: `user@yopmail.com`

L'application est accessible sur `http://ds.api.localtest.me:5678/settings`.

Le bouton "Connecter API Entreprise" redirige vers `http://entreprise.api.localtest.me:5000/oauth/authorize`, puis récupère et affiche les jetons retournés dans la réponse `/oauth/token` (champ `api_tokens`).
