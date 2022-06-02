
# Espace développeur 🛠

## Introduction

## Prérequis

Voici la liste des fondamentaux techniques à mettre en place pour le bon fonctionnement de l’API Entreprise :

- ✅ Être en mesure de gérer le protocole HTTPS ;

- ✅ Avoir une version de langage récente. Si vous utilisez Java, une version >= 1.8 est nécessaire (pour la gestion des certificats de +1024 bit, du TLS 1.2 minimum et des suites cryptographiques - ciphers) ;

- ✅ S’assurer que nos Autorités de Certification (AC) pour les certificats SSL sont autorisées par vos systèmes ;

- ✅ L'API Entreprise est uniquement accessible par internet. Si vous avez un pare-feu, il faut donc prévoir de whitelister l'adresse IP du service API Entreprise ;

- ✅ Il est interdit d'interroger l'API Entreprise depuis un site web en front-end, car le jeton d'accès serait alors divulgué. Il vous faut donc interroger nos API depuis une application en back-end. Nous n'autoriserons pas le CORS (CORS - Cross Origin Ressource Sharing) ;

- ✅ Prévoir non seulement les coûts de développement mais également les coûts de maintenance ;

- ✅ Être en capacité de gérer les mises à jour de l'API Entreprise.

## Spécifications générales de l'API Entreprise

### Volumétrie

#### Limites à respecter

Les limites de volumétrie sur API Entreprise se décomposent en deux règles principales :

- Un plafond général par IP de 1000 requêtes/minute.

- Une volumétrie par jeton par groupe d’endpoints :
  - 1er groupe : Les endpoints renvoyant du JSON constituent un premier groupe. Vous pouvez effectuer jusqu’à 250 requêtes/min/jeton sur ce groupe.
  - 2ème groupe : Les endpoints transmettant des documents constituent un autre groupe. La volumétrie maximale d’appel concernant ce groupe est de 50 requêtes/min/jeton.
  - Exceptions : Certains endpoints échappent à cette règle et présentent une volumétrie spécifique par endpoint :
    - L’[attestation fiscale de la DGFIP](TODO) : 5 requêtes/min/jeton ;
    - Les [actes de l’INPI](TODO) : 5 requêtes/min/jeton ;
    - Les [bilans de l’INPI](TODO) : 5 requêtes/min/jeton ;
    - Les [effectifs de l’URSSAF](TODO) : 250 requêtes/min/jeton ;
    - La [conformité des travailleurs handicapés de l’Agefiph](TODO) : 250 requêtes/min/jeton.

Pour vous assurer de la volumétrie d’un endpoint en particulier, vous pouvez consulter la partie “disponibilité” de sa documentation dans le [catalogue de données](TODO).

#### Informations actionnables et alertes

##### Header associé à chaque réponse


| Champs du header    |   Signification    |     Format           |
|:------------------------------|:------------------|:------------:|
| `RateLimit-Limit` |La **limite** concernant l'endpoint appelé, soit le nombre de requête/minute. | Nombre|
| `RateLimit-Remaining` |Le **nombre d'appels restants** durant la période courante d'une minute. | Nombre |
| `RateLimit-Reset` |La **fin de la période** courante. | Timestamp |

>**Exemple&nbsp;:**
>Considérons un endpoint ayant une limite de 50 appels /minute.
>Vous faîtes un premier appel à 10h00 pile, et effectuez un second appel 20 secondes plus tard, puis un troisième 10 secondes plus tard, vous aurez les valeurs suivantes :
> - RateLimit-Limit : 50 ;
> - RateLimit-Remaining : 47 (50 moins les 3 appels effectués) ;
> - RateLimit-Reset : [*Timestamp correspondant au jour présent à 10h01*]. Le premier appel initialise le compteur (à 10h00 pile), la période se termine 1m plus tard.
>
> Vous pouvez donc jusqu'à 10h01 pile effectuer 47 appels, le compteur sera réinitialisé à 50 à ce moment-là.

##### Header associé à un code 429

Si vous dépassez le nombre d'appels autorisés (`RateLimit-Remaining = 0`), le serveur répondra avec le **status 429** sur tous les appels suivants dans la même période.

Le header associé à ce code erreur 429 sera accompagné :
- des trois champs précédents ;
- d'un champ supplémentaire indiquant le temps à attendre avant de pouvoir effectuer des nouveaux appels.

| Champs du header    |   Signification    |     Format           |
|:------------------------------|:------------------|:------------:|
| `RateLimit-Limit` |La **limite** concernant l'endpoint appelé, soit le nombre de requête/minute. | Nombre|
| `RateLimit-Remaining` |Le **nombre d'appels restants** durant la période courante d'une minute. | Nombre |
| `RateLimit-Reset` |La **fin de la période** courante. | Timestamp |
| *Uniquement pour le header associé au code erreur 429* <br> `Retry-after`| **Décompte du nombre de secondes restantes** avant la prochaine période | Secondes |

Vous pouvez donc **utiliser les champs du header pour optimiser votre consommation de l'API Entreprise**.

#### Bannissement

En cas de **non prise en compte des codes erreurs 429** ou en cas de **dépassement de la limite de volumétrie globale**, votre IP sera temporairement bannie de nos serveurs **pour une durée fixe et non révocable de 12h**. Si vous avez plusieurs jetons, tous seront donc bloqués pendant ce laps de temps.

Les appels depuis une IP bannie ne renvoient pas de codes HTTP, le serveur ne répond tout simplement pas.
Vous pouvez en revanche vérifier si vous avez dépassé ce seuil depuis votre tableau de bord.

> ℹ️ Au bout de ces 12 heures, vos accès sont automatiquement rétablis ; **il est donc inutile d'écrire au support**.

Nous vous invitons à prendre les mesures nécessaires car le dépassement intervient généralement chez nos utilisateurs lorsque leur programme n'a pas été correctement configuré.

Pour les appels de traitement de masse, il est souhaitable que vous fassiez vos **batchs automatiques la nuit ou durant les heures creuses** afin de ne pas affecter la qualité du service pour le reste des usagers.

### Timeout

Le timeout est le temps d'attente maximal de réponse à une requête. Pour chaque endpoint, nous vous indiquons le timeout idéal dans le [catalogue de donnée](../catalogue/).

Le timout est un outil important qui permet de ne pas immobiliser votre logiciel en le laissant bloqué sur un appel sans réponse.

De façon générale, nous vous recommandons un timeout :
- de **5 secondes** pour les appels de données structurées JSON ;
- de **12 secondes** pour les appels retournant un PDF ou un ZIP.

De même, pour ne pas immobiliser nos serveurs, nous attendons les réponses de nos fournisseurs un maximum de 10 secondes avant de vous les retransmettre. Si ce délai d’attente est dépassé un code erreur HTTP 504 vous sera renvoyé.

### Certificats SSL

API Entreprise utilise [DHIMYOTIS](https://www.dhimyotis.com/) comme organisme de délivrance de ses certificats SSL principaux ainsi que [Let's Encrypt](https://letsencrypt.org/) pour certains services secondaires.

Il est conseillé d'ajouter ces Autorités de Certifications (AC) à votre base de confiance si vous en avez une. Une solution idéale est d'utiliser un paquet d'autorités mises à jour automatiquement ([Mozilla par exemple](https://wiki.mozilla.org/CA/Included_Certificates))

API Entreprise utilise des certificats multi-domaines ; c'est à dire avec un "nom courant" (_common name - CN_) et plusieurs "noms alternatifs du sujet" (_subject alternatives names - SAN_), soyez certains que vos outils fonctionnent correctement avec.

### Code HTTPS et gestion des erreurs

#### Un code standard HTTPS pour catégoriser le statut de l'appel
Toutes les réponse de l’API Entreprise sont envoyées avec un code HTTPS. **Ces codes permettent de se renseigner sur le statut de l’appel**. Pour en savoir plus sur les codes HTTPS, cet article de [Wikipedia](https://fr.wikipedia.org/wiki/Liste_des_codes_HTTP)constitue une bonne base explicative.

API Entreprise a harmonisé les codes erreur de l’ensemble des fournisseurs de données, en s'appuyant sur le protocole HTTP, afin de vous en simplifier la compréhension.

<details>

<summary>👀 Consulter la liste des codes HTTPS et leur signification.</summary>

###### En cas de succès, le code HTTP commence par 2 :

| Code HTTPS                                       |      Signification                 |
|--------------------------------------------------|------------------------------------|
|`200` | **Tout va bien.**|
|`206` | **Réponse incomplète** - La requête a fonctionné mais un des fournisseurs de données a renvoyé une erreur ou une réponse incomplète. Les valeurs concernées dans le JSON contiennent le message : “Donnée indisponible”.|

###### En cas d’échec, si l’erreur vient de votre côté, le code HTTP commence par 4 :

| Code HTTP                       |      Signification                     |
|---------------------------------|----------------------------------------|
|`400` | **Mauvaise requête** – La syntaxe de votre requête est erronée.|
|`401` | **Non autorisé** – Votre token est invalide ou manquant.|
|`403` | **Interdit** – Le serveur a compris votre requête mais refuse de l’exécuter car votre jeton ne vous donne pas accès à cette ressource.|
|`404` | **Non trouvé** – La ressource (l'entreprise, le certificat, …) demandée n'a pas été trouvée. Cette erreur intervient par exemple lors de l’entrée d’un numéro de SIREN qui n’existe pas, ou bien lorsque l’entreprise qu’il designe est en dehors du périmètre de l’endpoint.|
|`422` | **Entité non traitable** – Le format de la donnée passée en paramètre n'est pas accepté. Par exemple, si vous entrez 20 chiffres dans le paramètre SIREN, votre requête est automatiquement rejetée, car un SIREN fait obligatoirement 9 chiffres.|
|`451` | **Indisponible pour raisons légales** - ce code est spécifiquement renvoyé lorsque vous demandez les informations d’une entreprise ou d’un établissement non diffusible au travers des endpoints `entreprises` et `etablissements` de l’INSEE, sans avoir utilisé l’option d’appel spécifique. Pour en savoir plus, [consultez la documentation de cet endpoint dans le catalogue de données](../catalogue/).|


###### En cas d’échec, si l’erreur provient d’API Entreprise ou bien des fournisseurs de données, le code HTTP commence par 5 :

| Code HTTP                        |      Signification                     |
|----------------------------------|----------------------------------------|
|`500` | **Erreur interne à API Entreprise** – Une erreur interne du serveur d’API Entreprise est survenue. [Consultez votre tableau de bord](https://dashboard.entreprise.api.gouv.fr/login){:target="_blank"}, l’historique de l’incident devrait y être affiché ; ainsi que les actions à venir.
|`502` | **Erreur interne fournisseur** – Une erreur interne du serveur du ou des fournisseurs est survenue. [Consultez votre tableau de bord](https://dashboard.entreprise.api.gouv.fr/login){:target="_blank"}, l’historique de l’incident devrait y être affiché ; ainsi que les actions à venir.
|`503` | **Service non disponible** – Le service est temporairement indisponible ou en maintenance. Pour connaître l’historique de disponibilité et les incidents type de l’endpoint, vous pouvez [consulter le catalogue de données](../catalogue/).
|`504` | **Intermédiaire hors délai** – Le(s) producteur(s) de données ont mis trop de temps à répondre. Notre temps d’attente, nous permettant de ne pas immobiliser le serveur sur un appel sans réponse, est fixé à 10 secondes et a été dépassé.|

</details>

#### En V3, un second code spécifique API Entreprise pour préciser l'erreur et enclencher une action

Avec la V3, tous les codes erreur HTTPS sont accompagnés de codes plus précis, spécifiques à chaque situation d’erreur. Une explication en toutes lettres est également donnée dans la payload. Enfin, dans certains cas, une métadonnée actionnable est disponible.

Dans l’exemple ci-dessous, la clé `retry_in` permet justement de relancer un appel après le nombre de secondes indiquées.

>_Exemple de payload d'un code HTTPS 502 :_
>```
>{
>    "errors": [
>       {
>            "code": "04501",
>            "title": "Analyse de la situation du compte en cours",
>            "detail": "La situation de l'entreprise requiert une analyse manuelle d'un agent de l'URSSAF. Une >demande d'analyse vient d'être envoyée, cela prend au maximum 2 jours.",
>            "meta": {
>                "provider": "ACOSS",
>                "retry_in": 172800
>           }
>        }
>    ]
>}
>```

### Paramètres d'appel et traçabilité

API Entreprise vous permet d’accéder à des données protégées. C’est pourquoi, dans un **objectif de traçabilité**, nous vous demandons de renseigner dans chacune de vos requêtes, **non seulement un jeton d’accès**, mais aussi certaines informations qualifiant votre requête.


> ⚠️ **Ces paramètres sont obligatoires**. Les appels ne comportant pas ces paramètres sont rejetés, et un code erreur vous est renvoyé.


Pour chaque endpoint, nous précisons dans le [catalogue des données](../catalogue/) les paramètres obligatoires spécifiques, ci-dessous une explication détaillée des éléments à fournir pour chaque paramètre de traçabilité :

| Paramètre                                                  |      Information à renseigner           |
|:----------------------------------------------------------:|-----------------------------------------|
|`&context=CadreDeLaRequête`|**Cadre de la requête** <br>Par exemple : aides publiques, marchés publics ou gestion d'un référentiel tiers utilisé pour tel type d'application*.*
|`&recipient=BénéficaireDeL'Appel`|**Bénéficiaire de l'appel** <br>SIRET de l'administration destinatrice des données.
|`&object= RaisonDeL'AppelOuIdentifiant`|**La raison de l'appel** <br> ou l'identifiant de la procédure. <br> L'identifiant peut être interne à votre organisation ou bien un numéro de marché publique, un nom de procédure ; l'essentiel est que celui-ci vous permette de tracer et de retrouver les informations relatives à l'appel. En effet, vous devez pouvoir justifier de la raison d'un appel auprès du fournisseur de données. Description courte (< 50 caractères).

### Compatibilité ascendante et versionnage

Avec la V3, toutes les API pourront évoluer indépendamment les unes des autres. Les anciennes versions resteront toujours disponibles. Le numéro de version devient donc un paramètre de l’appel et non plus une valeur fixe pour toutes les API.

Pour changer de version, il suffit de mettre le numéro de la version voulue (à partir de `v3`) dans l’URL, au même endroit qu’avant, par exemple : `https://entreprise.api.gouv.fr/v3/insee/sirene/etablissements/:siret`

Ce type de versionnage permet :
- d'ajouter de nouvelles informations sans forcer nos utilisateurs à monter de version ;
- de continuer de garantir la continuité des API dans le temps.

> 📩 Une techlettre annoncera systématiquement les nouvelles évolutions. Vous pouvez vous abonner [ici](TODO).


### Monitorer la disponibilité des API

#### Disponibilité des API en temps réel

Pour connaître la disponibilité de tous les endpoints en temps réel, vous pouvez utiliser l'API `/current_status`. Cette **API est ouverte et ne nécessite pas de token**, attention à tout de même respecter les [limites de volumétrie](TODO) habituelles.

###### La requête HTTP :


```
https://entreprise.api.gouv.fr/watchdoge/dashboard/current_status
```


> **Exemple de réponse JSON :**
>
>```
>      {
>        "results": [
>          {
>            "uname": "apie_2_etablissements",
>            "name": "Etablissements",
>            "provider": "insee",
>            "api_version": 2,
>            "code": 200,
>            "timestamp": "2020-10-14T14:36:33.640Z"
>          },
>          {
>            "uname": "apie_2_certificats_qualibat",
>            "name": "Certificats Qualibat",
>            "provider": "qualibat",
>            "api_version": 2,
>            "code": 503,
>            "timestamp": "2020-10-14T14:38:02.736Z"
>          },
>          [...]
>        ]
>      }
>
> ```

ℹ️ Pour plus d'informations, vous pouvez vous référer à l'[environnement de production documenté (*swagger*) disponible sur api.gouv.fr](https://api.gouv.fr/documentation/api-entreprise).

#### Historique de disponibilité des API

Pour connaître l'historique de disponibilité des données de API Entreprise ainsi que le taux d'erreurs constatées, vous pouvez utiliser l'API `/provider_availabilities`. **Cette API est ouverte et ne nécessite pas de token**, attention à tout de même respecter les [limites de volumétrie](TODO) habituelle.

###### La requête HTTP :

```
https://entreprise.api.gouv.fr/watchdoge/stats/provider_availabilities?period=ParamètreDeLaPeriode&endpoint=ParamètreDuEndpoint
```


Pour appeler l'API concernant l'endpoint et la période voulue, référez-vous à la suite de cet article ⤵️


> **Exemple de réponse JSON :**
>```
>      {
>        "endpoint": "api/v3/entreprises_restored",
>        "days_availability": {
>          "2020-04-13": {
>            "total": 12615,
>            "404": 9,
>            "502": 0,
>            "503": 0,
>            "504": 0
>          },
>          "2020-04-14": {
>            "total": 44677,
>            "404": 25,
>            "502": 0,
>            "503": 16,
>            "504": 0
>          }
>        },
>        "total_availability": 99.96,
>        "last_week_availability": 100.0
>      }
>      ```


###### Nomenclature des paramètres de la requête HTTP :


Cette API possède deux paramètres, `period` et `endpoint`, voici leur nomenclature :

|Liste indicative de *period*|Période correspondante|
|---|---|
|`1y` | depuis un an |
|`2M` | depuis 2 mois |
|`3w` | depuis 3 semaines |
|`4d` | depuis 4 jours |
|`5h` | depuis 5 heures |
|`6m` | depuis 6 minutes |
|`7s` | depuis 7 secondes |

À partir de la nomenclature, `Y`(année), `M`(mois), `W`(semaine), `D`(jour), `m`(minute), `s`(seconde), vous pouvez obtenir l'historique de disponibilité de la période que vous souhaitez.

|Liste exhaustive des *endpoint*|API correspondante|
|---|---|
|`api/v3/entreprises_restored`|[Entreprises](https://entreprise.api.gouv.fr/catalogue/#entreprises)|
|`api/v3/etablissements_restored`|[Établissements](https://entreprise.api.gouv.fr/catalogue/#etablissements)|
|`api/v2/extraits_rcs_infogreffe`|[Extrait RCS](https://entreprise.api.gouv.fr/catalogue/#extraits_rcs_infogreffe)|
|`api/v2/associations`|[Informations déclaratives d’une association](https://entreprise.api.gouv.fr/catalogue/#associations)|
|`api/v2/documents_associations`|[Divers documents d'une association](https://entreprise.api.gouv.fr/catalogue/#documents_associations)|
|`api/v2/documents_inpi`|[Actes INPI](https://entreprise.api.gouv.fr/catalogue/#actes_inpi)|
|`api/v2/conventions_collectives`|[Conventions collectives ](https://entreprise.api.gouv.fr/catalogue/#conventions_collectives)|
|`api/v2/exercices`|[Chiffre d'affaires](https://entreprise.api.gouv.fr/catalogue/#exercices)|
|`api/v2/documents_inpi`|[Bilans annuels INPI](https://entreprise.api.gouv.fr/catalogue/#bilans_inpi)|
|`api/v2/bilans_entreprises_bdf`|[3 derniers bilans annuels](https://entreprise.api.gouv.fr/catalogue/#bilans_entreprises_bdf)|
|`api/v2/liasses_fiscales_dgfip`|[Déclarations de résultat](https://entreprise.api.gouv.fr/catalogue/#liasses_fiscales_dgfip)|
|`api/v2/attestations_fiscales_dgfip`|[Attestation fiscale](https://entreprise.api.gouv.fr/catalogue/#attestations_fiscales_dgfip)|
|`api/v2/attestations_sociales_acoss`|[Attestation de vigilance](https://entreprise.api.gouv.fr/catalogue/#attestations_sociales_acoss)|
|`api/v2/attestations_agefiph`|[Conformité emploi des travailleurs handicapés](https://entreprise.api.gouv.fr/catalogue/#attestations_agefiph)|
|`api/v2/cotisations_msa`|[Cotisations de sécurité sociale agricole](https://entreprise.api.gouv.fr/catalogue/#cotisations_msa)|
|`api/v2/attestations_cotisation_retraite_probtp`|[Attestation de cotisations retraite du bâtiment](https://entreprise.api.gouv.fr/catalogue/#cotisation_retraite_probtp)|
|`api/v2/eligibilites_cotisation_retraite_probtp`|[Éligibilité au cotisations retraite du bâtiment](https://entreprise.api.gouv.fr/catalogue/#cotisation_retraite_probtp)|
|`api/v2/cartes_professionnelles_fntp`|[Carte professionnelle travaux publics](https://entreprise.api.gouv.fr/catalogue/#cartes_professionnelles_fntp)|
|`api/v2/certificats_cnetp`|[Cotisations congés payés & chômage intempéries](https://entreprise.api.gouv.fr/catalogue/#certificats_cnetp)|
|`api/v2/certificats_rge_ademe`|[Certification RGE](https://entreprise.api.gouv.fr/catalogue/#certificats_rge_ademe)|
|`api/v2/certificats_qualibat`|[Certificat de qualification bâtiment](https://entreprise.api.gouv.fr/catalogue/#certificats_qualibat)|
|`api/v2/certificats_opqibi`|[Certification de qualification d'ingénierie](https://entreprise.api.gouv.fr/catalogue/#certificats_opqibi)|
|`api/v2/extraits_courts_inpi`|[Brevets modèles et marques déposés](https://entreprise.api.gouv.fr/catalogue/#extraits_courts_inpi)|
|`api/v2/effectifs_mensuels_etablissement_acoss_covid`|Effectifs mensuels par établissement (aides COVID-19) - documentation à venir|
|`api/v2/effectifs_mensuels_entreprise_acoss_covid`|Effectifs mensuels par entreprise (aides COVID-19) - documentation à venir|
|`api/v2/effectifs_annuels_entreprise_acoss_covid`|Effectifs annuels par entreprise (aides COVID-19) - documentation à venir|

ℹ️ Pour plus d'informations, vous pouvez vous référer à l'[environnement de production documenté (*swagger*) disponible sur api.gouv.fr](https://api.gouv.fr/documentation/api-entreprise).

### Retrouver les droits d'un JWT

Pour connaître **la liste des APIs auxquelles vous avez le droit** avec votre jeton d'accès, vous pouvez le vérifier avec l'API `/privileges`.

Si vous gérez les tokens pour vos clients, vous pouvez aussi utiliser cette API pour vérifier les droits associés à leurs tokens.

###### La requête HTTP :

```
https://entreprise.api.gouv.fr/v2/privileges?token=LeTokenATester
```

Le paramètre d'appel à renseigner est le token dont vous souhaitez connaître les droits.

> **Exemple de réponse JSON :**
>```
>      {
>        "privileges": [
>          "attestations_agefiph",
>          [...]
>          "actes_bilans_inpi"
>        ]
>      }
>     ```

La réponse JSON renvoie la liste des API autorisées. Retrouvez-leurs spéciifications techniques dans le [Swagger](TODO).

## 🧰 Kit de mise en production

### Récupérer le jeton JWT 🔑

Seule la personne ayant fait la demande d'habilitation a accès au [token](../entreprise.api.gouv.fr/doc/#tokens), au travers du tableau de bord. **Elle est responsable de cette clé et de sa transmission sécurisée** si cela est nécessaire dans le cadre de l'intégration de l'API Entreprise.

- _Si vous avez réalisé la demande d'habilitation_, vous pouvez **récupérer vos tokens ou jetons d'accès directement depuis votre [tableau de bord](https://dashboard.entreprise.api.gouv.fr/login)**.

- _Si vous avez réalisé la demande d'habilitation mais que vous n'êtes pas la personne en charge d'intégrer l'API Entreprise_, **vous pouvez transmettre le token de façon sécurisée depuis votre [tableau de bord](https://dashboard.entreprise.api.gouv.fr/login)**, en cliquant sur le bouton _"Transmettre le jeton à mon équipe technique"_.

**Le destinataire recevra, par e-mail, un lien d'une durée de 4 heures**, où il pourra copier/coller le token.

> ⚠️ Votre [clé d'accès est unique et privée](TODO vers qu'est qu'unjeton). L'utilisation de cette fonctionnalité du tableau de bord doit avoir pour unique objectif la transmission sécurisée de votre clé à vos services techniques qui intégreront l'API Entreprise. **Vous ne devez jamais transmettre votre clé d'accès par e-mail.**

### Faire sa première requête

#### Utiliser l'environnement de production - _Swagger_

Après avoir récupéré votre jeton, vous pouvez donc désormais faire un premier appel de test.

Utilisez l'[environnement de production documenté (_Swagger_)](https://api.gouv.fr/documentation/api-entreprise), disponible sur api.gouv.fr.
Il permet, à l'aide d'un token d'authentification valide 🔑, d'effectuer directement depuis le navigateur des tests de l'API. Les données confidentielles restent bien protégées. Vous y trouverez aussi la spécification technique téléchargeable sous format YAML afin de pouvoir accélérer le développement de vos outils d'interfaçage avec API Entreprise.

> ⚠️ Attention, pour rappel, vous ne devez jamais copier-coller un token dans la barre de recherche classique d'un moteur de recherche ou dans un e-mail. Pour récupérer votre jeton de façon sécurisée, consultez cette [rubrique](TODO).


#### Éléments constitutifs de la requête HTTP d'API Entreprise

Chaque URL de requête est spécifiée dans la [documentation technique (_Swagger_) dédiée à chaque API](../doc/){:trarget="_blank_"},

###### Exemple de requête :

```
https://entreprise.api.gouv.fr/v3/attestation_fiscales_dgfip/SirenDeL’Entreprise?token=📝&user_id=📝&context=📝&recipient=📝&object=📝
```


| Éléments composant la requête              |   État    | Exemples      |
|--------------------------------------------|-----------|---------------|
|**Domaine** <br>(ou préfixe) <br>qui conduit à l'API de façon sécurisée| prédéfini par endpoint|`https://entreprise.api.gouv.fr`|
|**Numéro de la version** <br>(par défaut désormais en V3)| prédéfini par endpoint| `/v3`|
|**Nom de la donnée recherchée** <br>(ou *endpoint*)| prédéfini par endpoint| `/attestation_fiscale_dgfip`|
|**Identité de l'établissement concerné** <br>(souvent SIREN ou SIRET)| à choisir 📝|`/SIRENouSIRETdeL'Etablissement`|
|**Votre jeton d'accès**| à renseigner 📝|`?token=JetonD'Habilitation`|
|**Des paramètres de traçabilité**| à renseigner 📝| `&context=CadreDeLaRequête`<br> ℹ️ Plus d'informations disponibles dans la partie [Instruire les paramètres de traçabilité](TODO){:target="_blank"}|

#### Constatez votre première trace d’appel depuis le tableau de bord

Une fois que vous avez fait un premier appel, celui-ci est **répertorié** dans votre tableau de bord, en passant par [la liste de tous vos tokens](https://dashboard.entreprise.api.gouv.fr/me/tokens), et en cliquant sur "Voir les statistiques".

### Configurer le logiciel métier

## Spécifications techniques de chaque API & Swagger

## Rupture de service, incidents et maintenances

Le service ne répond plus, consultez [cette rubrique de notre FAQ](TODO).

Pour être informé des différentes indisponibilités, [abonnez-vous aux notificiations par e-mail depuis notre page de statuts](https://status.entreprise.api.gouv.fr/subscribe/email).

## Renouvellement du JWT 🔑

Pour comprendre comment renouveler votre jeton, consultez [cette rubrique de notre FAQ](TODO).
