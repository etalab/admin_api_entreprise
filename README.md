# README

## Par où commencer ?

```sh
git clone git@github.com:etalab/admin_api_entreprise.git
cd admin_api_entreprise/
sudo apt install postgresql
sudo -i -u postgres
```

Puis, dans le sous-shell, entrer cette commande :

```sh
psql -f /absolute/path/to/admin_api_entreprise/postgresql_setup.txt
exit
```

Poursuivre ensuite l'installation :

```sh
bundle install
bin/rails db:migrate
bin/rails db:migrate RAILS_ENV=test
```

Il faudra ensuite renseigner la clé `master.key` pour pouvoir avoir accès aux
_credentials_ (voir plus bas le détail de la procédure à suivre).

Il sera alors possible d'exécuter la suite de tests :

```sh
bin/rspec
```

## Configuration de la base de données

### Choosing UUIDs as IDs

#### Kill it with fire

Ce message s'addresse à toute personne ayant cloné ce projet **avant** que le
choix d'utilisation des UUID n'ait été fait. Si vous avez dans vos
environnements de développement une jeune version de la base de donnée avec des
IDs "entier", veuillez exécuter la commande suivante :

`rails db:drop`

Cela supprimera entièrement les bases de données non conformes, le plus simple
étant de repartir de zéro, comme il est documenté ci-dessous.

#### Configuration des BDD de développement

L'application est configurée pour que les ID des modèles ne soient plus un entier
incrémenté à chaque création en base mais des UUID. Depuis Rails 5, il suffit
d'activer l'extension _pgcrypto_ dans Postgresql. Pour cela, créer tout d'abord
les bases de données de votre environnement de développement :

`rails db:create`

Puis exécuter la commande suivante dans la console de Postgresql (pour chacune
des deux bases de données de développement et de tests) :

`CREATE EXTENSION pgcrypto;`

Soit en détail:

```
sudo -u postgres -i
psql -d admin_apientreprise_development
psql> CREATE EXTENSION pgcrypto;
psql>\q
psql -d admin_apientreprise_test
psql> CREATE EXTENSION pgcrypto;
psql>\q
```

La commande `rails db:migrate` devrait alors se dérouler sans encombre.

Si les migrations échouent avec le message d'erreur suivant :

> PG::UndefinedFunction: ERROR:  function gen_random_uuid() does not exist

... cela signifie que l'extension _pgcrypto_ n'est pas installée (note : la
commande `\dx` depuis la console de Postgresql permet de lister les extensions
installées sur une base de données).

Le fichier de configuration _config/initializers/generators.rb_ assure de la prise
en compte du changement de type d'ID dans les futures migrations : vérifier tout
de même la présence de l'option `id: :uuid` lorsqu'une migration créé une
nouvelle table (ajout d'un nouveau modèle par exemple).

```ruby
class NewMigration < ActiveRecord::Migration[5.1]>
  def change
    create_table :my_table, id: :uuid do |t|
      ...
    end
  end
end
```

De la même manière, lors de la création d'une relation entre deux modèles, il
est nécessaire d'indiquer que le lien est réaliser sur des UUID à l'aide de
l'option `type: :uuid`. Exemple :

```ruby
class AddMyRelationToMyModel < ActiveRecord::Migration[5.1]
  def change
    add_reference :my_model, :my_relation, foreign_key: true, type: :uuid, index: true
  end
end
```

## Récupérer la MASTER_KEY pour les environnements de test et de développement

Le fichier `config/credentials.yml.enc` contient les paramètres d'environnements
de développement et de tests (utilisation des _credentials_ Rails). Il est
nécessaire de récupérer la clé dans le répertoire Ansible et de créer un fichier
`config/master.key` contenant cette clé.

La MASTER_KEY en question est disponible dans le fichier
`secrets/admin_apientreprise_dev_and_test.yml`.

## Déploiements à l'aide de Mina

Il peut être nécessaire que mina exécute ses commandes dans un shell intéractif,
cela peut notamment permettre de taper 'yes' si SSH demande l'ajout de l'hôte à
la liste known_hosts.
Pour cela, ajouter la config suivante dans le fichier `config/deploy.rb` :

    set :execution_mode, 'system'

Pour déployer le projet :

    bundle exec mina deploy to=sandbox|production

### Premier déploiement

Après le premier déploiement sur une machine, la BDD est vide.
L'utilisateur admin n'existe pas et les rôles non plus.
Par exemple en staging :

    RAILS_ENV=staging bundle exec rake create_admin
    RAILS_ENV=staging bundle exec rake db_seed:roles

### Paramètres d'environnements

Les fichiers suivants ne sont pas déployés par mina. Ils contiennent des
variables d'environnements qui doivent être déployées au préalable par Ansible
sur les machines de production.

* `config/database.yml`
* `config/credentials/sandbox.key`
* `config/credentials/staging.key`
* `config/credentials/production.key`
* `config/environments/rails_env.rb`
* `config/initializers/cors.rb`
