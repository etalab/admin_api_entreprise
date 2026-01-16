# OAuth Connect - Executive Summary

## Qu'est-ce que c'est ?

OAuth Connect permet aux **editeurs de logiciels** (comme Demarches Simplifiees) de recuperer les jetons API Entreprise de leurs utilisateurs, avec leur consentement explicite.

## Le probleme resolu

Aujourd'hui, lorsqu'un utilisateur souhaite utiliser son jeton API Entreprise dans une application tierce, il doit :
1. Se connecter a API Entreprise
2. Copier manuellement son jeton
3. Le coller dans l'application tierce

Ce processus est **fastidieux**, **source d'erreurs**, et pose des **problemes de securite** (jetons partages par email, stockes dans des fichiers, etc.).

## La solution OAuth Connect

```
+------------------+         +--------------------+         +------------------+
|   Application    |         |   API Entreprise   |         |    ProConnect    |
|   (ex: DS)       |         |   OAuth Server     |         |    (SSO Etat)    |
+------------------+         +--------------------+         +------------------+
        |                             |                             |
        |  1. Clic "Connecter"        |                             |
        |---------------------------->|                             |
        |                             |                             |
        |  2. Page login OAuth        |                             |
        |<----------------------------|                             |
        |                             |                             |
        |  3. Clic "ProConnect"       |                             |
        |---------------------------->|----------------------------->|
        |                             |                             |
        |                             |  4. Authentification        |
        |                             |<-----------------------------|
        |                             |                             |
        |  5. Page de consentement    |                             |
        |     (selection des jetons)  |                             |
        |<----------------------------|                             |
        |                             |                             |
        |  6. Autorisation            |                             |
        |---------------------------->|                             |
        |                             |                             |
        |  7. Redirection + code      |                             |
        |<----------------------------|                             |
        |                             |                             |
        |  8. Echange code -> tokens  |                             |
        |---------------------------->|                             |
        |                             |                             |
        |  9. Access token + refresh  |                             |
        |<----------------------------|                             |
        |                             |                             |
        |  10. GET /oauth/me          |                             |
        |---------------------------->|                             |
        |                             |                             |
        |  11. Jetons API selectionnes|                             |
        |<----------------------------|                             |
        |                             |                             |
```

## Benefices pour les editeurs

### 1. Integration simplifiee
- **Un seul flux OAuth standard** pour recuperer les jetons
- Pas besoin de gerer la copie manuelle des jetons
- Compatible avec les bibliotheques OAuth existantes

### 2. Experience utilisateur amelioree
- L'utilisateur reste sur l'interface de l'editeur
- Connexion via ProConnect (SSO de l'Etat)
- Selection visuelle des jetons a partager

### 3. Securite renforcee
- **Consentement explicite** de l'utilisateur
- Tokens OAuth avec expiration (1h) et refresh
- Possibilite de revoquer l'acces a tout moment
- Pas de jeton API en clair dans les emails ou fichiers

### 4. Controle granulaire
- L'utilisateur choisit **quels jetons** partager
- Un utilisateur peut avoir plusieurs jetons (plusieurs organisations)
- L'editeur n'accede qu'aux jetons autorises

## Cas d'usage type : Demarches Simplifiees

1. Un instructeur veut pre-remplir un formulaire avec les donnees entreprise
2. Il clique sur "Connecter API Entreprise" dans DS
3. Il s'authentifie via ProConnect
4. Il selectionne les jetons de sa collectivite
5. DS peut maintenant faire des appels API en son nom

## Donnees transmises a l'editeur

Pour chaque jeton autorise :
- **Intitule** : nom de l'organisation
- **SIRET** : identifiant de l'etablissement
- **Scopes** : permissions associees au jeton
- **Token JWT** : le jeton d'acces reel pour appeler l'API

## Securite et conformite

- Protocole **OAuth 2.0** standard (RFC 6749)
- Authentification via **ProConnect** (SSO gouvernemental)
- Tokens avec **expiration courte** (1h) + refresh token
- **Revocation** possible a tout moment
- Historique des autorisations pour audit
