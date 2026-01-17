Je veux implémenter un serveur OAuth2 permettant à des partenaires de récupérer les jetons des usagers.
Les partenaires sont des éditeurs de logiciels : ils devront implémenter une connexion OAuth2 API Entreprise / Particulier.

Pour simplifier on ne parlera que de l'API Entreprise, et l'éditeur sera DS
(Démarches Simplifiées).

En terme de flow ce que ça donne:

1. Un usager est sur DS, dans les settings pour configurer ses donnés, celui-ci propose un "Connecter API Entreprise"
2. L'usager clique sur ce bouton, il est redirigé vers le serveur OAuth2 de
   l'API Entreprise, qui propose la connexion ProConnect
3. L'usager se connecte avec ses identifiants ProConnect, il est redirigé
   vers une page de consentement, où il accepte que DS puisse récupérer ses
   jetons API Entreprise : il peut sélectionner les demandes qu'il souhaite
   transférer à DS
4. Une fois le consentement donné, l'usager est redirigé vers DS avec un code d'autorisation
5. DS utilise ce code d'autorisation pour récupérer un jeton d'accès et un
   jeton de rafraîchissement auprès du serveur OAuth2 de l'API Entreprise
6. DS stocke ces jetons de manière sécurisée et les utilise pour faire des
   appels API au nom de l'usager

Je veux que tu m'implémente ce flow, et que tu me créer une dummy app dans
dummy_app/ qui simule le comportement de DS, avec une page settings et un
bouton "Connecter API Entreprise".

On utilisera Doorkeeper pour implémenter le serveur OAuth2. Omniauth pour le
dummy client.

Utilise agent-browser pour simuler la navigation de l'usager entre DS et l'API
Entreprise, tu ne t'arrêtes que lorsque tu verras les jetons API Entreprise dans
la dummy app.
