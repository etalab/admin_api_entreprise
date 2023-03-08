# Gestion des webhooks DataPass

## Introduction / contexte

DataPass intègre un système de webhooks qui envoie des payloads à une URL cible
en fonction du service, ceci à chaque changement d'état d'une demande associé à
ce dit service. Dans le cadre d'API Entreprise, ceux-ci nous servent à gérer
intégralement la communication envoyée aux utilisateurs, ainsi que la création
du jeton associé en cas de validation.

Pour le contexte, les emails étaient précédemment géré par DataPass, tandis que
la création du jeton était géré par un " bridge " custom côté DataPass.

A noter que certains emails (relatifs aux contacts RGPD) sont encore gérés côté
DataPass.

Pour plus d'infos sur les webhooks:

- [Documentation DataPass sur les
  webhooks](https://github.com/betagouv/datapass/blob/master/backend/docs/webhooks.md)
- [Implémentation technique pour API
  Entreprise](https://github.com/betagouv/datapass/blob/master/backend/app/notifiers/api_entreprise_notifier.rb)

## Implémentation technique

L'intégralité du traitement s'effectue à travers le controller
`DatapassWebhooksController`, où l'organizer `DatapassWebhook` est appelé.

Celui-ci effectue les tâches suivantes de manière séquentielle:

1. Trouve ou crée l'utilisateur (le demandeur)
1. Trouve ou crée la demande, en affectant les dernières valeurs (intitule,
   contacts etc...)
1. Si l'événement est une validation, crée le jeton associé
1. Mets à jour les contacts (demandeur, technique et métier) sur Mailjet
1. Construit la liste des variables Mailjet
1. Planifie l'ensemble des emails associés à la demande, en fonction de
   l'événement

Cette dernière étape s'appuie sur un fichier de configuration, expliqué
ci-dessous.

## Fichier de configuration

Le fichier de configuration se situe dans
[`config/datapass_webhooks.yml`](./config/datapass_webhooks.yml) et permet de
planifier les emails aux divers contacts associés à la demande.

Ci-dessous un exemple avec les explications de chaque entrée:

```yaml
# L'environnement associé à la configuration
production:
  # Chaque clé à ce niveau correspond à un événement associé à la demande. La liste exhaustive se trouve dans la documentation DataPass
  # Une clé vide ou absente n'effectue aucun envoi d'email.
  created: {}
  send_application:
    emails:
      # Chaque entrée correspond à un email. Le champ 'id' correspond à l'ID technique d'un template transactionnel sur Mailjet, et doit être présent (il s'agit du seul champ obligatoire)
      - id: "11"
      - id: "12"
        # La clé 'when' permet de planifier un email dans le future, dans le cadre des relances. Point iportant: si la demande a changé d'état au moment de l'envoi, l'email n'est pas envoyé.
        # Par défaut l'email est envoyé sans délai.
        when: "in 14 days"
  review_application:
    emails:
      - id: "22"
  refuse_application:
    emails:
      - id: "32"
  validate_application:
    emails:
      - id: "51"
        # La clé 'condition_on_authorization' permet d'appliquer une condition sur l'envoi de l'email. Cette condition est évaluée au moment de la réception du webhook et non lors de l'envoi. Cette condition doit être une méthode définie sur la classe AuthorizationRequestConditionFacade
        # Par défaut condition est évalué à true
        condition_on_authorization: "all_contacts_have_the_same_email?"
      - id: "52"
        condition_on_authorization: "all_contacts_have_different_emails?"
        # Tableau des destinataires, doit être soit un modèle User soit un modèle Contact
        to:
          - "authorization_request.contact_metier"
        # Tableau des destinataires en copie
        cc:
          - "authorization_request.contact_technique"
          - "authorization_request.user"
```

Un test d'acceptance vérifie le format du fichier: si il y a une typo les tests
ne passeront pas.

Pour les conditions évaluées, vous trouverez le fichier ici:
[AuthorizationRequestConditionFacade](../app/lib/authorization_request_condition_facade.rb)

## Variables d'environnement disponibles lors de l'envoi via Mailjet

Les variables ci-dessous sont disponibles quelque soit l'état de la demande:

1. `authorization_request_id`, `integer`, l'ID de la demande DataPass
1. `authorization_request_intitule`, `string`, l'intitulé de la demande DataPass
1. `authorization_request_description`, `string`, la description de la demande DataPass
1. `demandeur_first_name`, `string`, le prénom du demandeur
1. `demandeur_last_name`, `string`, le nom du demandeur
1. `demandeur_email`, `string`, l'email du demandeur
1. `contact_metier_first_name`, `string`, le prénom du contact métier
1. `contact_metier_last_name`, `string`, le nom du contact métier
1. `contact_metier_email`, `string`, l'email du contact métier
1. `contact_technique_first_name`, `string`, le prénom du contact technique
1. `contact_technique_last_name`, `string`, le nom du contact technique
1. `contact_technique_email`, `string`, l'email du contact technique

A noter que les variables associées aux contacts peuvent être vides.

Si l'événement est initié par un instructeur (`refuse_application`,
`review_application`, `validate_application`, `review`), les variables suivantes
sont disponibles:

1. `instructor_first_name`, `string`, prénom de l'instructeur
1. `instructor_last_name`, `string`, nom de l'instructeur

A noter qu'il s'agit de variables d'environnements. Les attributs des contacts
sont mis à jour avant l'envoi des emails, et décrit ci-dessous.

Si un jeton est associé à la demande (théoriquement seulement dans le cas de la
validation), les variables suivantes sont disponibles:

1. `token_role_ROLE`, `boolean`, détermine si ROLE est associé au jeton. La
   liste des rôles est celle en base de données.

## Mise à jour des attributs des contacts

A chaque réception d'un webhook, les informations de contacts sont mis à jour
sur Mailjet. Les contacts regroupent le demandeur, le contact technique et le
contact métier. Les informations mises à jour sont les suivantes:

1. `prénom`, `string`, le prénom du contact
1. `nom`, `string`, le nom du contact
1. `contact_demandeur`, `boolean`, indique si le contact est le demandeur
1. `contact_métier`, `boolean`, indique si le contact est le contact métier
1. `contact_technique`, `boolean`, indique si le contact est le contact
   technique
