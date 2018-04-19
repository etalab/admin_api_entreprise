# README

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

Création de l'utilisateur:
```
sudo -u postgres -i
cd /path/to/admin_apientreprise
psql -f db/init.sql
```

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

## Déploiements à l'aide de Mina

Il peut être nécessaire que mina exécute ses commandes dans un shell intéractif,
cela peut notamment permettre de taper 'yes' si SSH demande l'ajout de l'hôte à
la liste known_hosts.
Pour cela, ajouter la config suivante dans le fichier `config/deploy.rb` :

    set :execution_mode, 'system'

Pour déployer le projet :

    bundle exec mina deploy to=sandbox|production

### Paramètres d'environnements

Les fichiers suivants ne sont pas déployés par mina. Ils contiennent des
variables d'environnements qui doivent être déployées au préalable par Ansible
sur les machines de production.

* `config/database.yml`
* `config/secrets.yml`
* `config/environments/rails_env.rb`
* `config/initializers/cors.rb`
