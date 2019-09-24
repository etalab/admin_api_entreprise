# README

## Configuration de la base de données

### Choosing UUIDs as IDs

#### Kill it with fire

Ce message s'addresse à toute personne ayant cloné ce projet **avant** que le
choix d'utilisation des UUID n'ait été fait. Si vous avez dans vos
environnements de développement une jeune version de la base de donnée avec des
IDs "entier", veuillez exécuter les commandes suivantes :

`rails db:drop`

Cela supprimera entièrement les bases de données non conformes, le plus simple
étant de repartir de zéro, comme il est documenté ci-dessous.

Supprimez également le fichier `db/schema.rb` si vous en avez un.

#### Configuration des BDD de développement

L'application est configurée pour que les ID des modèles ne soient plus un entier
incrémenté à chaque création en base mais des UUID. Depuis Rails 5, il suffit
d'activer l'extension _pgcrypto_ dans Postgresql (selon la distribution UNIX de votre machine, une librairie telle que `postgresql-contrib` peut être nécessaire.)

Pour créer l'utilisateur, les bases de donnée `test` et `development`, et installer les extensions `pgcrypto` :

```
sudo -u postgres -i
cd /path/to/admin_apientreprise
psql -f postgresql_setup.txt
```

La commande `rails db:migrate` devrait alors se dérouler sans encombre.

Si les migrations échouent avec le message d'erreur suivant :

> PG::UndefinedFunction: ERROR:  function gen_random_uuid() does not exist

... cela signifie que l'extension _pgcrypto_ n'est pas installée (note : la
commande `\dx` depuis la console de Postgresql permet de lister les extensions
installées sur une base de données).

Attention, si cette erreur apparait tout de même après que vous ayez manuellement installé l'extension `pgcrypto`, vérifiez que vous n'avez pas de fichier db/schema.rb. Il se peut que Rails désinstalle l'extension lorsqu'il load `schema.rb` (par exemple pendant les tests).

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
* `config/secrets.yml`
* `config/environments/rails_env.rb`
* `config/initializers/cors.rb`
