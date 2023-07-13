# Site vitrine / backoffice de [API Entreprise](https://entreprise.api.gouv.fr) et [API Particulier](https://particulier.api.gouv.fr)

[![Tests](https://github.com/etalab/admin_api_entreprise/actions/workflows/tests.yml/badge.svg)](https://github.com/etalab/admin_api_entreprise/actions/workflows/tests.yml)
[![Linter](https://github.com/etalab/admin_api_entreprise/actions/workflows/lint.yml/badge.svg)](https://github.com/etalab/admin_api_entreprise/actions/workflows/lint.yml)
[![Security](https://github.com/etalab/admin_api_entreprise/actions/workflows/security.yml/badge.svg)](https://github.com/etalab/admin_api_entreprise/actions/workflows/security.yml)

## Requirements

- ruby 3.2.1
- redis-server >= 6
- postgresql >= 9

## Install

### Sans Docker

Il suffit de lancer la commande suivante pour configurer la base de données,
installer les paquets et importer les tables de la base de données :

```sh
./bin/install.sh
```

### Avec Docker

Installer `Docker` et `docker-compose` (sur Mac tout est
[ici](https://docs.docker.com/desktop/mac/install/))

Pour lancer l'application :

```sh
make start
```

**L'application doit être lancée pour exécuter les autres commandes.**

Pour arrêter:

```sh
make stop
```

Lors du premier lancement, il faut initialiser la base de donnée (après `make start`):

```sh
make install_database
```

En cas de problème, pour réinstaller la base de données:

```sh
make reinstall_database
```

## Tests

Pour faire tourner les tests, un navigateur headless est necessaire (au moins
sous linux).

```sh
sudo apt install chromium-browser
```

Il faut lancer:

```sh
bin/rspec
```

[Guard](https://github.com/guard/guard) est aussi installé:

```sh
guard
```

### Static security

[brakeman](https://github.com/presidentbeef/brakeman) est installé. Vous pouvez
l'utiliser en lançant la commande suivante:

```sh
./bin/brakeman
```

### Développement

Vous pouvez importer des données afin d'avoir un site qui ne soit pas vide:

```sh
rails db:seed:replant
```

En local et sandbox, la connexion s'effectue sur `auth-test.api.gouv.fr` qui est remplie
de données de fixtures (disponible
[ici](https://github.com/betagouv/api-auth/blob/master/scripts/fixtures.sql))

Les comptes suivants sont disponibles :

- user@yopmail.com / user@yopmail.com -> utilisateur normal

### Sans Docker

Pour lancer le server:

```sh
./bin/local.sh

# Pour load le fichier OpenAPI local:
LOAD_LOCAL_OPEN_API_DEFINITIONS=true ./bin/local.sh
```

Vous pouvez accéder ensuite accéder au site via les adresses suivantes:

```
# Pour visualiser le site d'API Entreprise
http://entreprise.api.localtest.me:3000/
# Pour visualiser le site d'API Particulier
http://particulier.api.localtest.me:3000/
```

### Avec Docker

Pour lancer le server:

```sh
docker-compose up
```

Vous pouvez accéder ensuite accéder au site via le'adresse suivante:

```
# Pour visualiser le site d'API Entreprise
http://entreprise.api.localtest.me:5000/
# Pour visualiser le site d'API Particulier
http://particulier.api.localtest.me:5000/
```

#### (API Entreprise) Stub des requêtes SIADE en developpement

Pour la page `/profile/attestations`, en développement on appelle le staging de SIADE avec un stub du token de test,
ceci pour simplifier les démos / intervenir sur l'interface plus facilement.

Le résultat de la recherche est donc toujours le même (et constitué des fausses données renvoyées par le staging).

## Déploiements

Effectuer la commande suivante pour déployer en production:

```
./bin/deploy
```

Dans le cas d'un test sur sandbox sur la machine frontale avec la branche `features/whatever`

```
ssh -A watchdoge -- /usr/local/bin/rails_deploy_admin_apientreprise_sandbox.sh features/whatever
```

## Ajout de credentials via rails:credentials

Avant toute chose, lisez la partie sur la gestion des credentials chiffré dans
la [doc officielle de
Rails](https://edgeguides.rubyonrails.org/security.html#environmental-security)

Chaque environnement possède son propre fichier de credentials.

Pour les environments de tests et developments, le fichier de développment est un lien
symbolique sur le fichier de test : modifier l'un modifie l'autre, et la
clé est présente dans le dépôt. Il ne faut mettre aucune donnée sensible dans
ce fichier.

Pour les fichiers de production (i.e. sandbox, staging et production), il y a
aussi plusieurs fichiers. Les clés ne sont pas versionnées, il faut les importer
depuis le vault d'ansible du dépôt stockant l'ensemble des secrets.

Vous pouvez executer le script
[`scripts/import_master_keys.sh`](./scripts/import_master_keys.sh) pour
effectuer l'import.

Pour rappel, la commande d'édition:

```sh
rails credentials:edit
```

### Premier déploiement

Après le premier déploiement sur une machine : la BDD est vide, les
administrateurs n'existent pas, aucun rôle, etc

```sh
RAILS_ENV=staging bundle exec rake db_seed:scopes
```

### Paramètres d'environnements

Les fichiers suivants ne sont pas déployés par mina. Ils contiennent des
variables d'environnements qui doivent être déployées au préalable par Ansible
sur les machines de production.

- `config/database.yml`
- `config/credentials/sandbox.key`
- `config/credentials/staging.key`
- `config/credentials/production.key`
- `config/environments/rails_env.rb`
- `config/initializers/cors.rb`

## Documentation métier

Ci-dessous les diverses rubriques principalement à destination des métiers /
produits pour itérer sur le site (que ce soit en terme de contenu ou fonctionnel)

- [Gestion des webhooks DataPass](docs/webhooks.md)
- [Blog posts](docs/blog_posts.md)
- [Design (CSS and stuff)](docs/design.md)
- Technique
  - [Utilisation des modals avec Turbo](docs/tech-modal-turbo.md)
  - [Utilisation d'Algolia](docs/tech-algolia.md)
- Contenu
  - [Gestion des wordings (layouts, templates, FAQ)](docs/wordings.md)
  - [Ajout d'un nouvel endpoint dans le catalogue](docs/endpoint.md)

## Outils de production

Il y a plusieurs scripts utiles pour faire des manipulations en production pour des usages bien précis.

Ils sont rangés dans `lib/tasks/`. À ce jour il y en a 2 :

- `user:transfer_account` : afin de transférer un compte entre deux emails
- `token:blacklist` : afin de blacklister un jeton qui aurait été envoyé par email et en créer un nouveau

Les tâches ont des descriptions visible avec `bundle exec rake -D user:transfer_account` par exemple.

Exemple de commande :

```shell
# les backslash '\' sont malheureusement nécessaire sinon ils sont interprété par ZSH
# il ne faut pas mettre d'espace après la virgule entre les variables qui sont entre crochets
bundle exec rake user:transfer_account\['current@user.com','new@user.com'\]
```

## Génération des sitemaps

On utilise 2 sitemaps différents pour le site d'API Entreprise et le site d'API Particulier.
Pour générer les sitemaps il suffit d'executer la commande :

```shell
rake sitemap:refresh
```

Lors de l'éxecution de la commande, un ping auto sera envoyé à google afin d'indiquer que le sitemaps a changé.
En local, afin de ne pas solliciter google inutilement il est préférable de ne pas déclencher le ping

```shell
rake sitemap:refresh:no_ping
```
