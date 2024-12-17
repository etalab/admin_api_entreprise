Mercredi 8 novembre 2023 - Publication

# Guide de migration V.2 => V.3
![Image de présentation de l'article sur le numéro de TVA intracommunautaire](<%= image_path('api_particulier/blog/lieu-naissance-code-cog-en-tete.png') %>)

{:.fr-highlight}
**Qu'est que le code COG ?**
Le code COG (Code Officiel Géographique) est un code permettant de repérer notamment les communes et les territoires étrangers. Ce code est différent du code postal et peut évoluer dans le temps. C'est pourquoi, le code COG demandé pour identifier un particulier est le **code COG du pays de naissance et de la commune de naissance si le particulier est né à en France**.
*Pour en savoir plus : [Code COG - Insee.fr](https://www.insee.fr/fr/information/2560452){:target="_blank"} et [Codification des pays et territoires étrangers - Insee.fr](https://www.insee.fr/fr/information/2028273){:target="_blank"}*.

<nav class="fr-summary" role="navigation" aria-labelledby="fr-summary-title">
 <p class="fr-summary__title" id="fr-summary-title">Sommaire</p>
 <ol class="fr-summary__list">
 <li>
   <a class="fr-summary__link fr-text--lg" href="#introduction"> Introduction</a>
  </li>
  <li>
   <a class="fr-summary__link fr-text--lg" href="#evolutions-generales">Évolutions générales</a>
   <ul>
    <li> <a class="fr-summary__link" href="#jeton-dacces-a-parametrer-dans-le-header">1. Jeton d'accès à paramétrer dans le header</a></li>
    <li> <a class="fr-summary__link" href="#votre-numéro-de-siret-obligatoire-dans-le-recipient">2. Numéro de SIRET obligatoire dans le "recipient"</a></li>
    <li> <a class="fr-summary__link" href="#codes-erreurs-specifiques-a-chaque-situation-actionnables-et-documentes">3. Codes erreurs spécifiques à chaque situation, actionnables et documentés</a></li>
    <li> <a class="fr-summary__link" href="#volumétrie-indiquée-dans-le-header-et-actionnable">4. Volumétrie indiquée dans le header et actionnable</a></li>
    <li> <a class="fr-summary__link" href="#une-route-specifique-pour-chaque-modalite-d-appel">5. Une route spécifique pour chaque modalité d'appel</a></li>
    <li> <a class="fr-summary__link" href="#donnee-qualifiee-et-uniformisee-metier">6. Les données des payloads, qualifiées et uniformisées d'un point de vue métier</a></li>
    <li> <a class="fr-summary__link" href="#payloads-permettant-de-reperer-les-scopes">7. Des payloads permettant de repérer plus facilement les scopes (droits d'accès)</a></li>
    <li> <a class="fr-summary__link" href="#refonte-des-scopes-de-certaines-api">8. Refonte des scopes de certaines API</a></li>
    <li> <a class="fr-summary__link" href="#une-route-specifique-pour-chaque-modalite-d-appel">9. Les appels via la modalité FranceConnect ne renvoient plus les données d'identité</a></li>
    </ul>
  </li>
  <li>
   <a class="fr-summary__link fr-text--lg" href="#table-correspondance"> Table de correspondance de chaque API</a>
  </li>
 </ol>
</nav>

<br/>

## <a name="introduction"></a>Introduction

{:.fr-text--lead}
Ce guide **liste les changements effectués** entre la version 2 de l’API&nbsp;Particulier et la version 3, et vous livre les **éléments nécessaires pour effectuer la migration**.

{:.fr-text--lead}
Les évolutions présentées ici ont été guidées par les objectifs suivants&nbsp;:&nbsp;
- Assurer une meilleure sécurité de la donnée des fournisseurs ;
- Normaliser les formats pour faciliter la compréhension et l’industrialisation ;
- Clarifier la documentation et simplifier les routes des différentes modalités d'appel ;
- Clarifier, documenter les réponses et les rendre actionnables par vos logiciels ;
- Faire converger l'architecture technique de l'API Particulier avec celle de l'API Entreprise.

{:.fr-highlight.fr}
> **Votre jeton d'accès reste identique 🔑**
> Pour accéder à la version 3 de l'API&nbsp;Particulier, utilisez le même token qu'en V.2. En effet, tant que votre jeton est valide, il est inutile de refaire une demande d'accès car la migration vers la V.3 ne change pas les droits que vous avez déjà obtenu.


## <a name="evolutions-generales"></a>Évolutions générales

### <a name="jeton-dacces-a-parametrer-dans-le-header"></a> 1. Jeton d'accès à paramétrer dans le header

**🚀 Avec la V.3 :** Le jeton est à paramétrer uniquement dans le header de l’appel.

{:.fr-highlight.fr-highlight--example}
> **Avant** : Le jeton JWT pouvait être un paramètre de l’URL d’appel (query parameter).

**🤔 Pourquoi ?**
- Respecter les standards de sécurité ;
- Garantir que le token ne sera pas utilisé dans un navigateur.

**🧰 Comment ?**
Utilisez un client REST API pour tester les API pendant le développement.
Des clients sont disponibles gratuitement. API&nbsp;Particulier utilise pour ses propres tests le client Insomnia. Le plus connu sur le marché est Postman.
Une fois le client installé, vous pouvez directement intégrer notre fichier [Swagger/OpenAPI](<%= developers_openapi_path %>){:target="_blank"} dedans.

### <a name="votre-numéro-de-siret-obligatoire-dans-le-recipient"></a> 2. Numéro de SIRET obligatoire dans le "recipient"

 **🚀 Avec la V.3 :** Le paramètre obligatoire `recipient` de l’URL d’appel devra obligatoirement être complété par votre numéro de SIRET.

{:.fr-highlight.fr-highlight--example}
> **Avant** : Ce paramètre obligatoire n’était pas contraint en termes de syntaxe.

**🤔 Pourquoi ?**
- Pour garantir la traçabilité de l’appel jusqu’au bénéficiaire ayant obtenu l’habilitation à appeler l’API&nbsp;Particulier et respecter nos engagements auprès des fournisseurs de données ;
- Nous avions trop d’utilisateurs inscrivant le numéro de SIRET ou RNA de l’entreprise/association recherchée.

{:.fr-highlight.fr-highlight--caution}
> **⚠️ Cas particulier**, _vous êtes un éditeur ?_
> Ce n’est pas votre numéro de SIRET mais celui de votre client public qu’il s’agira de renseigner. API&nbsp;Particulier doit pouvoir tracer pour quelle entité publique l'appel a été passé.

Pour en savoir plus sur les paramètres obligatoires d'appel, consultez les [spécifications techniques](<%= developers_path(anchor: 'renseigner-les-paramètres-dappel-et-de-traçabilité') %>).

### <a name="codes-erreurs-specifiques-a-chaque-situation-actionnables-et-documentes"></a> 3. Codes erreurs spécifiques à chaque situation, actionnables et documentés

**🚀 Avec la V.3 :** Tous les codes erreur HTTPS sont accompagnés de codes plus précis, spécifiques à chaque situation d’erreur. Une explication en toutes lettres est également donnée dans la payload. Enfin, dans certains cas, une métadonnée actionnable est disponible.

Dans l’exemple ci-dessous, la clé `retry_in` permet de relancer un appel après le nombre de secondes indiquées.

###### Exemple de _payload_ d’un code HTTP 502 :
```
{
"errors": [
    {
    "code": "04501",
    "title": "Analyse de la situation du compte en cours",
    "detail": "La situation de l'entreprise requiert une
                analyse manuelle d'un agent de l'URSSAF.
                Une demande d'analyse vient d'être envoyée,
                cela prend au maximum 2 jours.",
    "meta": {
        "provider": "ACOSS",
        "retry_in": 172800
    }
    }
]
}
```

{:.fr-highlight.fr-highlight--example}
> Avant : Seul le code HTTP standard vous était fourni. Il pouvait correspondre à de nombreuses situations.
> ###### Exemple de payload d’un code HTTP 502 :
> ```
> {
>   "errors": [
>     "L'ACOSS ne peut répondre à votre requête, réessayez ultérieurement  (erreur: Analyse de la situation du compte en cours)"
>   ]
> }
> ```

**🤔 Pourquoi ?**
- Pour préciser la nature de l’erreur et vous aider à la comprendre ;
- Pour vous permettre d’actionner automatiquement l’erreur en utilisant le code.


**🧰 Comment ?**
Utiliser les libellés pour comprendre l’erreur rencontrée, voire automatiser votre logiciel en fonction du code.
La liste de tous les codes erreurs spécifiques (environ 80) est disponible dans le [Swagger](<%= developers_openapi_path %>){:target="_blank"}. La gestion des erreurs et l'explication des codes retours est détaillée dans la [documentation technique générale](<%= developers_path(anchor: 'code-https-et-gestion-des-erreurs') %>){:target="_blank"}.


### <a name="volumétrie-indiquée-dans-le-header-et-actionnable"></a> 4. Volumétrie indiquée dans le header et actionnable

La gestion de la volumétrie est maintenue identique à la dernière évolution de la V.2 et expliquée dans cette [documentation](<%= developers_path(anchor: 'volumétrie') %>)


### <a name="une-route-specifique-pour-chaque-modalite-d-appel"></a> 5. Une route spécifique pour chaque modalité d'appel

**🚀 Avec la V.3 :** Chaque modalité d'appel d'une API a son propre endpoint

Désormais avec la V.3. chaque modalité d'appel a son propre endpoint, matérialisé ainsi dans l'URL d'appel :
- `/identite`, pour les appels avec les paramètres de l'identité pivot du particulier ;
- `/france_connect`, pour les appels avec FranceConnect ;
- `/identifiant`, pour les appels avec un numéro unique spécifique à l'API.

{:.fr-highlight.fr-highlight--example}
> **Avant** : Dans la V.2., une seule route existait par API, ce qui signifiait que les différentes modalités d'appel étaient toutes documentées au même endroit, entrainant plusieurs difficultés, dont notamment le fait de ne pas pouvoir rendre obligatoires certains paramètre pourtant obligatoires dans les faits.

**🤔 Pourquoi ?**
- Clarifier la documentation des paramètres d'appel ;
- Identifier précisémement les paramètres obligatoires ;
- Rendre actionnable le swagger et le fichier OpenAPI.

**🧰 Comment ?**
Utiliser [le swagger](<%= developers_openapi_path %>){:target="_blank"}.
              

### <a name="donnee-qualifiee-et-uniformisee-metier"></a> 6. Les données des payloads, qualifiées et uniformisées d'un point de vue métier

**🚀 Avec la V.3 :** Nous avons profité de la refonte technique pour uniformiser la façon de traiter la donnée entre les API et compléter significativement les documentations. Ces évolutions concernent plusieurs aspects : 
- **Normaliser et préciser les clés de certains champs qui définissent le même type d'information**. Ainsi quelques règles sont maintenant largement utilisées sur toutes les API, par exemple :
- le statut (étudiant, bénéficaire d'une prestation, etc.) est désormais toujours nommé par une clé préfixée par `est_...`, comme par exemple `est_boursier` ou `est_beneficiaire` ;
- les dates de début et de fin de droit auront les clés `date_debut_droit` / `date_fin_droit` ;
- les clés se veulent les plus précises possibles, par exemple, dans l'API étudiant, : la clé `code_commune` en V.2. devient `code_cog_insee_commune` en V.3. pour éviter toute confusion avec le code postal. 
- **Expliciter l'origine des diverses données d'identité transmises dans les payloads** et préciser si la donnée a été consolidée et comment. Par exemple : au travers d'un recoupement avec une pièce d'identité ou bien avec un répertoire ; 
- Uniformiser le style des clés pour faciliter votre lecture de la documentation. Le format choisi est désormais en XXXX TODO, c'est-à-dire que les mots sont séparés par des _, par exemple `code_cog_insee_commune`.

**🤔 Pourquoi ?**
- Simplifier la compréhension et la lecture des données transmises ;
- Faciliter l'intégration de l'API.


### <a name="payloads-permettant-de-reperer-les-scopes"></a>7. Des payloads permettant de repérer plus facilement les scopes (droits d'accès)

**🚀 Avec la V.3 :** Les scopes sont repérables plus facilement car ils sont incarnés par une seule clé (qui peut être une clé parente) et qui dans la mesure du possible se trouve à la racine du tableau `"data"`. Ce changement est particulièrement visible sur l'API statut étudiant boursier : 

###### Exemple avec la payload V.3. de l'API Étudiant boursier :
Dans cette payload, les différents scopes pour lesquels vous pouvez demander une habilitation sont très visibles :  

```
{
    "data": {
    "identite": {   ## Scope "identité"
        "nom": "Moustaki",
        "prenoms": ["Georges", "Claude"],
        "date_naissance": "1992-11-29",
        "nom_commune_naissance": "Poitiers",
        "sexe": "M"
    },
    "est_boursier": true, ## Scope "statut"
    "periode_versement_bourse": { ## Scope "Période de versement"
        "date_rentree": "2019-09-01",
        "duree": 12
    },
    "etablissement_etudes": { ## Scope "Établissement et ville d'études"
        "nom_commune": "Brest",
        "nom_etablissement": "Carnot"
    },
    "echelon_bourse": "6", ## Scope "Échelon de la bourse"
    "email": "georges@moustaki.fr", ## Scope "E-mail
    "statut_bourse": { ## Scope "Statut définitif de la bourse"
        "code": 0,
        "libelle": "définitif"
    }
    },
    "links": {},
    "meta": {}
}
```

{:.fr-highlight.fr-highlight--example}
> Avant : Les droits d'accès pouvait couvrir une ou plusieurs clés dans la payload, il n'y avait pas de règles. Dans certains cas, un scope pouvait même indiquer un périmètre de particuliers concernés.

> ###### Exemple avec la payload V.2. de l'API Étudiant boursier :
> ```
> {
>   "data": {
>     "nom": "Moustaki",
>     "prenom": "Georges",
>     "prenom2": "Claude",
>     "date_naissance": "1992-11-29",
>     "lieu_naissance": "Poitiers",
>     "sexe": "M",
>     "boursier": true,
>     "echelon_bourse": "6",
>     "email": "georges@moustaki.fr",
>     "date_de_rentree": "2019-09-01",
>     "duree_versement": 12,
>     "statut": 0,
>     "statut_libelle": "définitif",
>     "ville_etudes": "Brest",
>     "etablissement": "Carnot"
>   },
>   "links": {},
>   "meta": {}
> }
> ```

**🤔 Pourquoi ?**
Clarifier quelles informations sont disponibles pour chaque scope.

### <a name="refonte-des-scopes-de-certaines-api"></a>8. Refonte des scopes de certaines API

**🚀 Avec la V.3 :** Certains scopes (droits d'accès) ont été modifiés : 
- API Statut demandeur d'emploi : Le scope `pole_emploi_identifiant` a été créé. Par conséquent, l'identifiant pôle emploi n'est plus retourné par défaut par l'API.
- API Statut élève scolarisé : Le scope `men_statut_identite` a été créé. Par conséquent, les données d'identité de l'élève (nom, prénom, sexe et date de naissance) ne sont plus retournées par défaut par l'API.
- API Statut étudiant : Les scopes de cette API ont été largement transformés car ils étaient incompréhensibles. Les scopes `mesri_inscription_etudiant`, `mesri_inscription_autre` et  `mesri_admission` ont donc été supprimés et remplacés par un seul et même scope : `mesri_admissions`. Le scope `mesri_regime` a été créé. Par conséquent, le régime de formation de l'élève n'est plus donné par défaut.
XXXX TODO => Mieux comprendre les scopes

{:.fr-highlight.fr-highlight--example}
> **Avant** : Dans la V.2., 

**🤔 Pourquoi ?**
- De nouveaux scopes ont été créés afin de répondre aux exigences de l'[article 4 de la loi informatique et libertés](https://www.legifrance.gouv.fr/loda/article_lc/LEGIARTI000037822953/){:target="_blank"} qui stipule que seules les données strictement nécessaires à la réalisation des missions peuvent être manipulées. La création de nouveaux scopes permet une meilleure granularité
- Certains scopes filtraient les étudiant transmis selon leur régime de formation. Ce fonctionnement n'a pas lieu d'être, rendait la compréhension des scopes très difficile, il a donc été supprimé.

**🧰 Comment ?**
- Si vous aviez déjà demandé une habilitation pour les API statut demandeur d'emploi ou élève scolarisé, les scopes `pole_emploi_identifiant` et `men_statut_identite`, qui étaient disponibles par défaut en V.2. vous ont automatiquement été attribués. Vous n'avez rien à faire.



### <a name="une-route-specifique-pour-chaque-modalite-d-appel"></a>9. Les appels via la modalité FranceConnect ne renvoient plus les données d'identité
**🚀 Avec la V.3 :** Lorsque vous utilisez les API avec FranceConnect, les données d'identité du particulier regroupées sous la clé `"identite"` ne seront plus renvoyées. 

**🤔 Pourquoi ?**
- C'est un impératif de FranceConnect ; 
- FranceConnect est en possession de l'identité pivot de l'usager, ces données sont certifiées et parfois plus fiables que les données livrées par les API, si vous avez besoin des données d'identité, vous pouvez donc les récupérer directement via FranceConnect.

**🧰 Comment ?**
XXXXX TODO

## <a name="table-correspondance"> Table de correspondance de chaque API