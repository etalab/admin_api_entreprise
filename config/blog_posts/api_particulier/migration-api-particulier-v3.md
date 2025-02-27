<div style="background-color: #ffffff; padding: 20px 20px ; border-radius: 5px; width: 100%;">

Mardi 11 février 2024 - Publication

<div style="background-color: #fff9c4; padding: 20px 10px ; border-radius: 5px; width: 100%; box-sizing: border-box;">
  <h1 class="fr-h1" style="margin: 0; color: #333; text-align: center; ">🔄 Guide de migration V.3</h1>
</div>


<nav class="fr-summary" role="navigation" aria-labelledby="fr-summary-title">
 <p class="fr-summary__title" id="fr-summary-title">Sommaire</p>
 <ol class="fr-summary__list">
 <li>
   <a class="fr-summary__link fr-text--lg" href="#introduction"> Introduction</a>
  </li>
  <li>
   <a class="fr-summary__link fr-text--lg" href="#evolutions-generales">Évolutions générales</a>
   <ol>
    <li> <a class="fr-summary__link fr-text--md" href="#jeton-dacces-a-parametrer-dans-le-header">Jeton d'accès à paramétrer dans le header</a></li>
    <li> <a class="fr-summary__link fr-text--md" href="#votre-numero-de-siret-obligatoire-dans-le-recipient">Numéro de SIRET obligatoire dans le "recipient"</a></li>
    <li> <a class="fr-summary__link fr-text--md" href="#codes-erreurs-detailles">Codes erreurs détaillés</a></li>
    <li> <a class="fr-summary__link fr-text--md" href="#volumetrie-indiquee-dans-le-header-et-actionnable">Volumétrie indiquée dans le header et actionnable</a></li>
    <li> <a class="fr-summary__link fr-text--md" href="#une-route-specifique-pour-chaque-modalite-d-appel">Une route spécifique pour chaque modalité d'appel</a></li>
    <li> <a class="fr-summary__link fr-text--md" href="#donnee-qualifiee-et-uniformisee-metier">Données uniformisées et documentées</a></li>
    <li> <a class="fr-summary__link fr-text--md" href="#refonte-des-scopes">Refonte des scopes</a></li>
    <li> <a class="fr-summary__link fr-text--md" href="#suppression-donnees-identite-via-france-connect">Suppression des données d'identité pour les appels via FranceConnect</a></li>
    </ol>
  </li>
  <li>
   <a class="fr-summary__link fr-text--lg" href="#table-correspondance"> Table de correspondance de chaque API</a>
  </li>
 </ol>
</nav>

<br/>

<h2 class="fr-h2 fr-mt-4w" style="padding: 2px; background-color : #fff9c4; display: inline-block"><a name="introduction"></a>Introduction</h2>

{:.fr-text--lead}
Ce guide **liste les changements effectués** entre la version 2 de l’API&nbsp;Particulier et la version 3 et vous livre les **éléments nécessaires pour effectuer la migration**.

{:.fr-text--lead}
Les évolutions présentées visent les objectifs suivants&nbsp;:&nbsp;
- Assurer une meilleure sécurité de la donnée des fournisseurs ;
- Normaliser les formats pour faciliter la compréhension et l’industrialisation ;
- Simplifier les routes des différentes modalités d'appel et leur utilisation ;
- Clarifier, documenter les réponses et les rendre actionnables par vos logiciels ;
- Faire converger l'architecture technique de l'API Particulier avec celle de l'API Entreprise.

{:.fr-highlight.fr}
> **Votre habilitation et votre jeton d'accès restent identiques 🔑**
> Pour accéder à la version 3 de l'API&nbsp;Particulier, utilisez le même token qu'en V.2. Il est inutile d'effectuer une nouvelle demande d'habilitation car la migration vers la V.3 ne changera pas les droits que vous avez déjà obtenu.
> En revanche, vous pourriez avoir besoin de demander une modification de votre habilitation pour certaines API dont [les scopes évoluent en V.3](#refonte-des-scopes).

<h2 class="fr-h2 fr-mt-4w" style="padding: 2px; margin-top: 10px; background-color : #fff9c4; display: inline-block"><a name="evolutions-generale"></a>Évolutions générales</h2>


<h3 class="fr-mt-4w" id="jeton-dacces-a-parametrer-dans-le-header"> 1. Jeton d'accès à paramétrer dans le header</h3>

**🚀 Avec la V.3 :** Le jeton est à paramétrer uniquement dans le header de l’appel.

{:.fr-highlight.fr-highlight--example}
> **Avant** : Le jeton JWT pouvait être un paramètre de l’URL d’appel.

**🤔 Pourquoi ?**
- Respecter les standards de sécurité ;
- Garantir que le token ne sera pas utilisé dans un navigateur.

**🧰 Comment ?**
Utilisez un client REST API pour tester les API pendant le développement.
Des clients sont disponibles gratuitement. API&nbsp;Particulier utilise pour ses propres tests le client Insomnia. Le plus connu sur le marché est Postman.
Une fois le client installé, vous pouvez directement intégrer notre fichier [Swagger/OpenAPI](<%= api_particulier_developers_openapi_v3_path %>){:target="_blank"} dedans.


<h3 class="fr-mt-6w" id="votre-numero-de-siret-obligatoire-dans-le-recipient"> 2. Numéro de SIRET obligatoire dans le "recipient"</h3>

 **🚀 Avec la V.3 :** Le paramètre `recipient` de l’URL d’appel devra obligatoirement être complété par votre numéro de SIRET.

{:.fr-highlight.fr-highlight--example}
> **Avant** : Ce paramètre obligatoire n’était pas contraint en termes de syntaxe.

**🤔 Pourquoi ?**
- Pour garantir la traçabilité de l’appel jusqu’au bénéficiaire ayant obtenu l’habilitation à appeler l’API&nbsp;Particulier et respecter nos engagements auprès des fournisseurs de données ;
- Nous avions trop d'appels avec le numéro de SIRET d'un éditeur de logiciel. Hors, pour rappel, l'éditeur n'est en aucun cas le destinataire de la donnée. C'est le numéro  de SIRET du client public qu’il s’agit de renseigner. API&nbsp;Particulier doit pouvoir tracer pour quelle entité publique l'appel a été passé.


Pour en savoir plus sur les paramètres obligatoires d'appel, consultez les [spécifications techniques](<%= developers_path(anchor: 'renseigner-les-paramètres-dappel-et-de-traçabilité') %>).


<h3 class="fr-mt-6w" id="codes-erreurs-detailles"> 3. Codes erreurs détaillés</h3>

**🚀 Avec la V.3 :** Tous les codes erreur HTTPS sont accompagnés de codes plus précis, spécifiques à chaque situation d’erreur. Une explication en toutes lettres est également donnée dans la payload.

###### Exemple de _payload_ d’un code HTTP 502 :
```
{
"errors": [
    {
      "code": "37003",
      "title": "Entité non trouvée",
      "detail": "Dossier allocataire inexistant. Le document ne peut être édité.",
      "source": null,
      "meta": 
      {
        "provider": "CNAV"
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
La liste de tous les codes erreurs spécifiques (environ 80) est disponible dans le [Swagger](<%= api_particulier_developers_openapi_v3_path %>){:target="_blank"}. La gestion des erreurs et l'explication des codes retours est détaillée dans la [documentation technique générale](<%= developers_path(anchor: 'code-https-et-gestion-des-erreurs') %>){:target="_blank"}.


<h3 class="fr-mt-6w" id="volumetrie-indiquee-dans-le-header-et-actionnable"> 4. Volumétrie indiquée dans le header et actionnable</h3>

La gestion de la volumétrie est maintenue identique à la dernière évolution de la V.2 et expliquée dans cette [documentation](<%= developers_path(anchor: 'volumétrie') %>).


<h3 class="fr-mt-6w" id="une-route-specifique-pour-chaque-modalite-d-appel">5. Une route spécifique pour chaque modalité d'appel</h3>

**🚀 Avec la V.3 :** Désormais avec la V.3. chaque modalité d'appel a son propre endpoint, matérialisé ainsi dans l'URL d'appel :
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
Utiliser [le swagger](<%= api_particulier_developers_openapi_v3_path %>){:target="_blank"}.
              

<h3 class="fr-mt-6w" id="donnee-qualifiee-et-uniformisee-metier">6. Données uniformisées et documentées</h3>

**🚀 Avec la V.3 :** Nous avons profité de la refonte technique pour uniformiser la façon de traiter les données renvoyées entre les API et compléter significativement les documentations. Ces évolutions concernent plusieurs aspects :
- Normaliser et préciser les clés de certains champs qui définissent le même type d'information. Ainsi quelques règles sont maintenant largement utilisées sur toutes les API, par exemple :
   - {:.fr-text--sm .fr-mb-0} le statut (étudiant, bénéficaire d'une prestation, etc.) est désormais toujours nommé par une clé préfixée par `est_...` si c'est un booléen, comme par exemple `est_boursier` ou `est_beneficiaire` ;
   - {:.fr-text--sm .fr-mb-0} les dates de début et de fin de droit auront les clés `date_debut_droit` / `date_fin_droit` ;
   - {:.fr-text--sm .fr-mb-0} les clés se veulent les plus précises possibles, par exemple, dans l'API étudiant, : la clé `code_commune` en V.2. devient `code_cog_insee_commune` en V.3. pour éviter toute confusion avec le code postal. 
- Expliciter l'origine des données d'identité transmises dans les payloads et préciser si la donnée a été consolidée et comment. Par exemple : au travers d'un recoupement avec une pièce d'identité ou bien avec un répertoire ; 
- Uniformiser le style des clés pour faciliter votre lecture de la documentation. Le format choisi est désormais en "snake_case" , c'est-à-dire que les mots sont séparés par des `_`, par exemple `code_cog_insee_commune`.


**🤔 Pourquoi ?**
- Simplifier la compréhension et la lecture des données transmises ;
- Faciliter l'intégration de l'API.


<h3 class="fr-mt-6w" id="refonte-des-scopes">7. Refonte des scopes</h3>

**🚀 Avec la V.3 :** Les scopes sont repérables plus facilement car désormais la donnée accessible pour un scope est la donnée inclue dans la clé correspondante de la payload. Concrêtement, cela signifie que les scopes sont souvent des clés parentes, regroupant plusieurs données, toutes accessibles à partir du moment où le droit a été délivré. Dans la mesure du possible, le scope se trouve à la racine du tableau `data`. 
Ce changement est particulièrement visible sur l'[API statut étudiant boursier](<%= api_particulier_developers_openapi_v3_path %>#tag/Statut-etudiant-boursier){:target="_blank"}, où chaque clé à la racine du tableau est un scope. 

Dans certains cas où l'API délivre une liste d'objet, comme pour l'[API statut étudiant](<%= api_particulier_developers_openapi_v3_path %>#tag/Statut-etudiant){:target="_blank"}, un scope peut contenir des sous-scopes. Le scope parent active la délivrance de la liste d'objets, les sous-scopes activent la délivrance de certaines données concernant l'objet en lui-même.

###### Exemples des différentes typologies de scopes avec l'API Statut étudiant

<pre><code>{
 "data": {
  "identite": { <span style="color: blue; font-weight: bold;">// Scope classique avec plusieurs clés</span>
   "nom_naissance": "Moustaki",
   "prenom": "Georges",
   "date_naissance": "1992-11-29"
  },
  "admissions": [ <span style="color: blue; font-weight: bold;">// Scope parent car liste d'objets</span>
   {
    "date_debut": "2022-09-01", <span style="color: gray; font-weight: bold;">// Par défaut dans le scope parent</span>
    "date_fin": "2023-08-31", <span style="color: gray; font-weight: bold;">// Par défaut dans le scope parent</span>
    "est_inscrit": true, <span style="color: green; font-weight: bold;">// Sous-scope avec une seule clé</span>
    "regime_formation": { <span style="color: green; font-weight: bold;">// Sous-scope avec plusieurs clés</span>
     "libellé": "formation initiale",
     "code": "RF1"
    },
    "code_cog_insee_commune": "29085", <span style="color: green; font-weight: bold;">// Sous-scope avec une seule clé</span>
    "etablissement_etudes": { <span style="color: green; font-weight: bold;">// Sous-scope avec plusieurs clés</span>
     "uai": "0011402U",
     "nom": "EGC AIN BOURG EN BRESSE EC GESTION ET COMMERCE (01000)"
    }
   }
  ]
 },
 "links": {},
 "meta": {}
}
</code></pre>


{:.fr-highlight.fr-highlight--example}
> Avant : Les droits d'accès pouvaient couvrir une ou plusieurs clés dans la payload, il n'y avait pas de règles. Dans certains cas, un scope pouvait même indiquer un périmètre de particuliers concernés.

> ###### Exemple avec la payload V.2. de l'API Étudiant boursier :

<blockquote>
 <pre><code>{
  "data": { <span style="color: gray; font-weight: bold;">// Scope parent 1</span>
   "nom": "Moustaki", <span style="color: gray; font-weight: bold;">// Scope 2</span>
   "prenom": "Georges", <span style="color: gray; font-weight: bold;">// Scope 2</span>
   "prenom2": "Claude", <span style="color: gray; font-weight: bold;">// Scope 2</span>
   "date_naissance": "1992-11-29", <span style="color: gray; font-weight: bold;">// Scope 2</span>
   "lieu_naissance": "Poitiers", <span style="color: gray; font-weight: bold;">// Scope 2</span>
   "sexe": "M", <span style="color: gray; font-weight: bold;">// Scope 2</span>
   "boursier": true,
   "echelon_bourse": "6", <span style="color: gray; font-weight: bold;">// Scope 3</span>
   "email": "georges@moustaki.fr", <span style="color: gray; font-weight: bold;">// Scope 4</span>
   "date_de_rentree": "2019-09-01",
   "duree_versement": 12,
   "statut": 0, <span style="color: gray; font-weight: bold;">// Scope 5</span>
   "statut_libelle": "définitif", <span style="color: gray; font-weight: bold;">// Scope 5</span>
   "ville_etudes": "Brest",
   "etablissement": "Carnot"
  },
  "links": {},
  "meta": {}
 }</code></pre>
</blockquote>

**🤔 Pourquoi ?**
- Clarifier quelles informations sont disponibles pour chaque scope pour faciliter les demandes d'habilitation ;
- Supprimer les scopes qui couvraient une partie du périmètre car trop complexes à comprendre ;
- Créer de nouveaux scopes afin de répondre aux exigences de l'[article 4 de la loi informatique et libertés](https://www.legifrance.gouv.fr/loda/article_lc/LEGIARTI000037822953/){:target="_blank"} qui stipule que seules les données strictement nécessaires à la réalisation des missions peuvent être manipulées. La création de nouveaux scopes permet une meilleure granularité.

**🧰 Comment ?**
Sauf pour l'API Statut étudiant dont les scopes ont beaucoup changé, nous nous sommes assurés de transférer vos droits vers les nouveaux scopes.
- Si vous êtes utilisateur de l'API Statut étudiant, il vous faut faire une demande de modification de votre habilitation. Pour en savoir plus, consultez la [table de correspondance de cette API](#correspondance-api-statut-etudiant) ;
- Certaines API proposent de nouvelles données en V.3, pour vérifier les ajouts de scopes pour chaque API, vous pouvez utiliser la [table de correspondance](#table-correspondance). Un paragraphe "scopes" est ajouté lorsqu'il y a eu des évolutions.

<h3 class="fr-mt-6w" id="suppression-donnees-identite-via-france-connect">8. Suppression des données d'identité pour les appels via FranceConnect</h3>

**🚀 Avec la V.3 :** Lorsque vous utilisez les API avec FranceConnect, les données d'identité du particulier regroupées sous la clé `identite` ne sont pas prévue dans la payload. Cela concerne l'[API statut étudiant](#correspondance-api-statut-etudiant) et l' [API statut étudiant boursier](#correspondance-api-statut-etudiant-boursier). L'[API Quotient familial CAF &  MSA](#correspondance-api-quotient-familial-msa-caf) continuera de transmettre les données d'identité des allocataires, y compris avec l'appel via FranceConnect.

**🤔 Pourquoi ?**
- C'est un impératif de FranceConnect ; 
- FranceConnect est en possession de l'identité pivot de l'usager, ces données sont certifiées et parfois plus fiables que les données livrées par les API.

**🧰 Comment ?**
Pour l'API statut étudiant et statut étudiant boursier; comme pour toutes les autres API proposant la modalité d'appel via FranceConnect, si vous avez besoin des données d'identité, vous pouvez les récupérer directement via FranceConnect.
<br/>
<br/>

[Consulter le swagger V.3](<%= api_particulier_developers_openapi_v3_path %>){:target="_blank"}{:.fr-btn .fr-btn--lg fr-btn--icon-right fr-icon-arrow-right-fill}

<h2 class="fr-h2 fr-mt-4w" style="padding: 2px; margin-top: 10px; background-color : #fff9c4; display: inline-block"><a name="table-correspondance"></a>Table de correspondance de chaque API</h2>


<nav class="fr-summary fr-mb-3w" role="navigation" aria-labelledby="fr-summary-title">
 <ol class="fr-summary__list">
 <li>
   <a class="fr-summary__link fr-text--sm" href="#correspondance-api-quotient-familial-msa-caf">API Quotient familial CAF & MSA</a>
  </li>
  <li>
   <a class="fr-summary__link fr-text--sm" href="#correspondance-api-statut-etudiant">API Statut étudiant</a>
  </li>
  <li>
   <a class="fr-summary__link fr-text--sm" href="#correspondance-api-statut-etudiant-boursier">API Statut étudiant boursier</a>
  </li>
  <li>
   <a class="fr-summary__link fr-text--sm" href="#correspondance-api-statut-eleve-scolarise">API Statut élève scolarisé</a>
  </li>
  <li>
   <a class="fr-summary__link fr-text--sm" href="#correspondance-api-statut-demandeur-emploi">API Statut demandeur d'emploi</a>
  </li>
  <li>
   <a class="fr-summary__link fr-text--sm" href="#correspondance-api-paiements-france-travail">API Paiements versés par France Travail</a>
  </li>
  <li>
   <a class="fr-summary__link fr-text--sm" href="#correspondance-api-statut-rsa">API Statut revenu de solidarité active (RSA) </a>
  </li>
  <li>
   <a class="fr-summary__link fr-text--sm" href="#correspondance-api-statut-prime-activite">API Statut prime d'activité</a>
  </li>
  <li>
   <a class="fr-summary__link fr-text--sm" href="#correspondance-api-statut-aah">API Statut allocation adulte handicapé (AAH)</a>
  </li>
  <li>
   <a class="fr-summary__link fr-text--sm" href="#correspondance-api-statut-asf">API Statut allocation de soutien familial (ASF)</a>
  </li>
  <li>
   <a class="fr-summary__link fr-text--sm" href="#correspondance-api-statut-c2s">API Statut complémentaire santé solidaire (C2S)</a>
  </li>
 </ol>
</nav>


### <a name="correspondance-api-quotient-familial-msa-caf"></a> API Quotient familial CAF & MSA

[Swagger V.2](<%= api_particulier_developers_openapi_path %>#tag/Quotient-familial){:target="_blank"}{:.fr-btn .fr-btn--md fr-btn--icon-right fr-icon-arrow-right-fill .fr-btn--secondary}
[Swagger V.3](<%= api_particulier_developers_openapi_v3_path %>#tag/Quotient-familial-CAF-and-MSA){:target="_blank"}{:.fr-btn .fr-btn--md fr-btn--icon-right fr-icon-arrow-right-fill}


{:.fr-h6}
#### Synthèse de changements : 
- L'endpoint V.2 est divisé en deux endpoints en V.3, un pour la modalité d'appel par données d'identité, l'autre pour la modalité d'appel FranceConnect ;
- Certaines clés sont regroupées sous une clé parente ;
- Tous les noms de clés changent au format snake_case, avec un tiret du bas.
- Pour rappel, la version de l'API QF exploitant le numéro allocataire (version 1) ne sera pas disponible dans API Particulier V.3, et sera décommissionnée en octobre 2025 dans API Particulier V.2.

{:.fr-h6 .fr-mt-4w}
#### Champs de la payload ayant significativement changé :

{:.fr-table}
| **Champ V.2**                 | **Champ V.3 correspondant**          | **Description des changements**                                                                 |
|-----------------------------------|-------------------------------------|-------------------------------------------------------------------------------------------------|
| `quotientFamilial`                | `data.quotient_familial.valeur`     | **Regroupement dans une clé parente** `quotient_familial` et **renommage de la clé** `quotient_familial` en `valeur`. |
| `mois`<br/>`annee`        | `data.quotient_familial.mois`<br/>`data.quotient_familial.annee`      | **Regroupement dans une clé parente** `quotient_familial`.       |
| *(inexistants)*                            | `data.quotient_familial.mois_calcul` <br/>`data.quotient_familial.annee_calcul`      | **🎁 Nouvelle donnée :** ajout du mois et de l'année de calcul du quotient familial.     |
| `regime`                          | `data.quotient_familial.fournisseur`     | **Regroupement dans une clé parente** `quotient_familial` et **renommage de la clé** `regime` en `fournisseur`. Même si la donnée renvoyée est identique, la clé a été renommée car l'information MSA ou CAF n'indique pas nécessairement le régime de l'allocataire mais simplement le fournisseur du quotient familial. |
| `allocataires[].anneeDateDeNaissance`<br/>`allocataires[].moisDateDeNaissance`<br/>`allocataires[].jourDateDeNaissance`| `data.allocataires[].date_naissance` | **Fusion des trois champs (jour, mois année) dans une même clé** `date_naissance`.         |
| `enfants[].nomUsuel`              | `data.enfants[].nom_usage`          | **Renommage de clé** : Pas de changement autre que le renommage de `nomUsuel` en `nom_usage`. Après investigation auprès du fournisseur de donnée, il s'avère que le nom renvoyé est bien le nom d'usage tel que marqué sur l'acte d'état civil. |
| `enfants[].anneeDateDeNaissance`<br/>`enfants[].moisDateDeNaissance`<br/>`enfants[].jourDateDeNaissance`| `data.enfants[].date_naissance`| **Fusion des trois champs (jour, mois année) dans une même clé** `date_naissance`.         |
| `adresse.identite`                | `data.adresse.destinataire`         | **Renommage de la clé** `identite` en `destinataire`. |


### <a name="correspondance-api-statut-etudiant"></a> API Statut étudiant

[Swagger V.2](<%= api_particulier_developers_openapi_path %>#tag/Education-et-etudes/paths/~1api~1v2~1etudiants/get){:target="_blank"}{:.fr-btn .fr-btn--md fr-btn--icon-right fr-icon-arrow-right-fill .fr-btn--secondary}
[Swagger V.3](<%= api_particulier_developers_openapi_v3_path %>#tag/Statut-etudiant){:target="_blank"}{:.fr-btn .fr-btn--md fr-btn--icon-right fr-icon-arrow-right-fill}


{:.fr-h6}
#### Synthèse des changements : 
- L'endpoint V.2 est divisé en trois endpoints en V.3, un pour la modalité d'appel par données d'identité, l'autre pour la modalité d'appel FranceConnect, un pour l'appel par INE ;
- Afin de faciliter la compréhension de l'API, la clé `inscriptions` a été renommée en `admissions`. En effet, c'est bien la liste des admissions qui est délivrée pour chaque étudiant. Parmi elles, l'étudiant peut être allé jusqu'à l'inscription, qui est alors indiquée par la clé `est_inscrit: true` ;
- Certaines clés sont regroupées sous une clé parente ;
- Tous les noms de clés changent au format snake_case, avec un tiret du bas.

{:.fr-h6 .fr-mt-2w}
#### Scopes : 
Suite aux changements de structure de l'API, les scopes (droits d'accès) ont été largement modifiés. Les scopes de la version 2 n'existent plus. Les nouveaux périmètres d'accès découpent la payload de la façon suivante :
  - Un droit pour accéder aux données d'identité de la clé `identite` ;
  - Un droit général disponible par défaut pour accéder à la liste des admissions de la clé parente `admissions` ;
  - Trois sous-scopes permettant de délivrer l'accès à la donnée régime de formation `regime_formation`, à la commune d'études `code_cog_insee_commune` et à l'établissement d'études `etablissement_etudes`.

{:.fr-highlight .fr-highlight--caution}
> **⚠️ La nouvelle structure de scope impose de faire une demande de modification de l'habilitation :**
> Si vous ête utilisateur de la V.2 Statut étudiant, rendez-vous sur votre [compte utilisateur](<%= user_profile_path %>) pour demander une modification de votre habilitation. Cette demande de modification ne supprimera pas vos accès à la V.2. Elle vous permettra seulement de dévérouiller les accès à la V.3 statut étudiant.


{:.fr-h6 .fr-mt-4w}
#### Champs de la payload ayant significativement changé :

{:.fr-table}
| **Champ V.2**                      | **Champ V.3 correspondant**          | **Description des changements**                                                                 |
|-----------------------------------|-------------------------------------|-------------------------------------------------------------------------------------------------|
| `nom`                             | `data.identite.nom_naissance`      | **Regroupement dans une clé parente** `identite` et **renommage de clé** `nom` en `nom_naissance`car cette information est bien le nom de naissance tel qu'indiqué sur l'acte d'état civil. <br/> Cette clé n'est pas disponible pour l'API appelée avec FranceConnect. Pour accéder aux données d'identité, veuillez les récupérer via FranceConnect. |
| `prenom`<br/> `dateNaissance`   | `data.identite.prenom` <br/>  `data.identite.date_naissance`     | **Regroupement dans une clé parente**  `identite`.           |
| `inscriptions[]` | `data.admissions[]` | **Renommage de clé parente** `inscriptions` en `admissions`. |
| `inscriptions[].dateDebutInscription` | `data.admissions[].date_debut` | **Renommage de la clé** `dateDebutInscription` en `date_debut`. |
| `inscriptions[].dateFinInscription` | `data.admissions[].date_fin`   | **Renommage de la clé** `dateFinInscription` en `date_fin`. |
| `inscriptions[].statut`           | `data.admissions[].est_inscrit`    | **Renommage de la clé et changement de format** : Le champ `statut`, au format "string" en V2 correspond au champ `est_inscrit`, qui est un "booléen". |
| `inscriptions[].regime`           | `data.admissions[].regime_formation.libelle` et `data.admissions[].regime_formation.code` | **Renommage de la clé** `regime` en `regime_formation` qui devient une clé parente distribuant un libellé et un code. |
| `inscriptions[].codeCommune`       | `data.admissions[].code_cog_insee_commune` | **Renommage de la clé** `codeCommune` en `code_cog_insee_commune`. |
| `inscriptions[].etablissement` | `data.admissions[].etablissement_etudes` | **Renommage de la clé parente** `etablissement` en `etablissement_etudes`. |


### <a name="correspondance-api-statut-etudiant-boursier"></a> API Statut étudiant boursier

[Swagger V.2](<%= api_particulier_developers_openapi_path %>#tag/Education-et-etudes/paths/~1api~1v2~1etudiants-boursiers/get){:target="_blank"}{:.fr-btn .fr-btn--md fr-btn--icon-right fr-icon-arrow-right-fill .fr-btn--secondary}
[Swagger V.3](<%= api_particulier_developers_openapi_v3_path %>#tag/Statut-etudiant-boursier){:target="_blank"}{:.fr-btn .fr-btn--md fr-btn--icon-right fr-icon-arrow-right-fill}


{:.fr-h6}
#### Synthèse des changements : 
- L'endpoint V.2 est divisé en trois endpoints en V.3, un pour la modalité d'appel par données d'identité, l'autre pour la modalité d'appel FranceConnect, un pour l'appel par INE ;
- Certaines clés sont regroupées sous une clé parente ;
- Tous les noms de clés changent au format snake_case, avec un tiret du bas.


{:.fr-h6 .fr-mt-4w}
#### Champs de la payload ayant significativement changé :

{:.fr-table}
| **Champ V.2**                      | **Champ V.3 correspondant**          | **Description des changements**                                                                 |
|-----------------------------------|-------------------------------------|-------------------------------------------------------------------------------------------------|
| `nom`                             | `data.identite.nom`                | **Regroupement dans une clé parente** `identite`. Cette clé n'est pas disponible pour l'API appelée avec FranceConnect. Pour accéder aux données d'identité, veuillez les récupérer via FranceConnect.                                       |
| `prenom`<br/>`prenom2`                       | `data.identite.prenoms[0]`         | **Regroupement dans une clé parente** `identite` et **fusion des deux champs `prenom` et `prenom2` dans une même clé** `prenoms`. |
| `dateNaissance`                   | `data.identite.date_naissance`     | **Regroupement dans une clé parente** `identite`.                                       |
| `lieuNaissance`                   | `data.identite.nom_commune_naissance` | **Regroupement dans une clé parente** `identite` et **renommage de la clé** `lieuNaissance` en `nom_commune_naissance`. |
| `sexe`                            | `data.identite.sexe`               | **Regroupement dans une clé parente** `identite`.                                       |
| `boursier`                        | `data.est_boursier`                 | **Renommage de la clé** `boursier` en `est_boursier`.                                               |
| `echelonBourse`                   | `data.echelon_bourse.echelon`      | **Regroupement dans une clé parente** `echelon_bourse` et **renommage de la clé** en conséquence.                               |
| `dateDeRentree`                  | `data.periode_versement_bourse.date_rentree` | **Regroupement dans une clé parente** `periode_versement_bourse` et **renommage de clé** `dateDeRentree` en `date_rentree`. |
| `dureeVersement`                  | `data.periode_versement_bourse.duree` | **Regroupement dans une clé parente** `periode_versement_bourse` et **renommage de clé** `dureeVersement` en `duree`. |
| `statut` et `statutLibelle`               | `data.echelon_bourse .echelon_bourse_regionale_provisoire`                           | **Remplacement des clés `statut` et `Libelle`** par la clé `echelon_bourse_regionale_provisoire` qui est rattachée à la clé parente `echelon_bourse`. Après investigation auprès du fournisseur de la donnée, il s'est avéré que la clé statut définitif ou provisoire indiquait que l'échelon de bourse mentionné était confirmé ou non. De plus, ce champ n'est complété que pour les bourses régionales. Par conséquent la V.3 recontextualise ce champ au bon endroit dans la payload.                             |
| `villeEtudes`                     | `data.etablissement_etudes .nom_commune` | **Regroupement dans une clé parente** `etablissement_etudes` et **renommage de clé** `villeEtudes` en `nom_commune`. |
| `etablissement`                   | `data.etablissement_etudes .nom_etablissement` | **Regroupement dans une clé parente** `etablissement_etudes` et **renommage de clé** `etablissement` en `nom_etablissement`. |


### <a name="correspondance-api-statut-eleve-scolarise"></a> API Statut élève scolarisé


[Swagger V.2](<%= api_particulier_developers_openapi_path %>#tag/Education-et-etudes/paths/~1api~1v2~1scolarites/get){:target="_blank"}{:.fr-btn .fr-btn--md fr-btn--icon-right fr-icon-arrow-right-fill .fr-btn--secondary}
[Swagger V.3](<%= api_particulier_developers_openapi_v3_path %>#tag/Statut-eleve-scolarise){:target="_blank"}{:.fr-btn .fr-btn--md fr-btn--icon-right fr-icon-arrow-right-fill}


{:.fr-h6}
#### Synthèse des changements : 
- Suppression des données de bourse : le fournisseur de données ne renvoie plus le statut boursier ;
- Ajout de nouvelles données : Le module élémentaire de formation, ainsi que le ministère de tutelle de l'établissement sont désormais indiqués ;
- Certaines clés sont regroupées sous une clé parente ;
- Tous les noms de clés changent au format snake_case, avec un tiret du bas.

{:.fr-h6 .fr-mt-2w}
#### Scopes : 
- Un nouveau scope a été créé, permettant d'accéder à la donnée `identite` autrefois par défaut incluse lorsque l'API était demandée. **Ce scope sera par défaut distribué aux utilisateurs ayant déjà un accès l'API Statut élève V.2.**
- Un nouveau scope a été créé pour la nouvelle donnée `module_elementaire_formation`, **pour accéder à cette novuelle donnée, veuillez faire une demande de modification de votre habilitation depuis votre [compte utilisateur](<%= user_profile_path %>)**.


{:.fr-h6 .fr-mt-4w}
#### Champs de la payload ayant significativement changé :


{:.fr-table}
| **Champ V.2** | **Champ V.3 correspondant** | **Description des changements** |
|--------------|--------------------------|-------------------------------|
| `eleve` | `identite` | **Renommage de la clé parente** en `identite`. |
| `code_etablissement` | `etablissement.code_uai` | **Renommage de la clé en `code_uai` et regroupement dans une clé parente `etablissement`** |
| *(inexistant)*   | `etablissement.code_ministere_tutelle` | **🎁 Nouvelle donnée :** ajout du code du ministère de tutelle de l'établissement. |
| `est_boursier` | *(supprimé)*  | **❌ Suppression du champ.** |
| `niveau_bourse` | *(supprimé)*   | **❌ Suppression du champ.** |
| `status_eleve` | `statut_eleve` | **Renommage de la clé en `statut_eleve`.** |
| *(inexistant)* | `module_elementaire_formation` | **🎁 Nouvelle donnée :** ajout du code et du libellé du module élémentaire de formation de l'élève. |




### <a name="correspondance-api-statut-demandeur-emploi"></a> API Statut demandeur d'emploi

[Swagger V.2](<%= api_particulier_developers_openapi_path %>#tag/Demandeurs-d'emploi/paths/~1api~1v2~1situations-pole-emploi/get){:target="_blank"}{:.fr-btn .fr-btn--md fr-btn--icon-right fr-icon-arrow-right-fill .fr-btn--secondary}
[Swagger V.3](<%= api_particulier_developers_openapi_v3_path %>#tag/Statut-demandeurs-d'emploi){:target="_blank"}{:.fr-btn .fr-btn--md fr-btn--icon-right fr-icon-arrow-right-fill}



{:.fr-h6}
#### Synthèse des changements : 
- Certaines clés sont regroupées sous une clé parente ;
- Tous les noms de clés changent au format snake_case, avec un tiret du bas.

{:.fr-h6 .fr-mt-2w}
#### Scopes : 
Un nouveau scope a été créé, permettant d'accéder à la donnée `identifiant` autrefois par défaut incluse lorsque l'API était demandée. **Ce scope sera par défaut distribué aux utilisateurs ayant déjà un accès l'API Statut demandeur d'emploi en V.2.**

{:.fr-h6 .fr-mt-4w}
#### Champs de la payload ayant significativement changé :


{:.fr-table}
| **Champ V.2** | **Champ V.3 correspondant** | **Description des changements** |
|--------------|----------------------------|-------------------------------|
| `civilite` | `identite.civilite` | **Regroupement dans la clé parente** `identite`. |
| `nom` | `identite.nom_naissance` | **Renommage** en `nom_naissance` et **regroupement dans la clé parente** `identite`.|
| `nomUsage` | `identite.nom_usage` | **Regroupement dans la clé parente** `identite`. |
| `prenom` | `identite.prenom` | **Regroupement dans la clé parente** `identite`. |
| `sexe` | `identite.sexe` | **Regroupement dans la clé parente** `identite`. |
| `dateNaissance` | `identite.date_naissance` | **Formatage en date** et **regroupement dans la clé parente** `identite`. |
| `codeCertificationCNAV` | `inscription.code_certification_cnav` | **Regroupement dans la clé parente** `inscription`. |
| `codeCategorieInscription`<br/>`libelleCategorieInscription` | `inscription.categorie.code`<br/>`inscription.categorie.libelle` | **Regroupement dans la clé parente** `categorie` au sein de la clé `inscription`. |
| `dateInscription` | `inscription.date_debut` | **Renommage et regroupement dans la clé parente** `inscription`. |
| `dateCessationInscription` | `inscription.date_fin` | **Renommage et regroupement dans la clé parente** `inscription`. |
| `adresse.INSEECommune` | `adresse.code_cog_insee_commune` | **Renommage et regroupement dans la clé parente** `adresse`. |
| `adresse.codePostal`<br/>`adresse.ligneComplementAdresse`<br/>`adresse.ligneComplementDestinataire`<br/>`adresse.ligneComplementDistribution`<br/>`adresse.ligneNom`<br/>`adresse.ligneVoie`<br/>`adresse.localite` | `adresse.code_postal`<br/>`adresse.ligne_complement_adresse`<br/>`adresse.ligne_complement_destinataire`<br/>`adresse.ligne_complement_distribution`<br/>`adresse.ligne_nom`<br/>`adresse.ligne_voie`<br/>`adresse.localite` | **Regroupement dans la clé parente** `adresse`. |
| `email`<br/>`telephone`<br/>`telephone2` | `contact.email`<br/>`contact.telephone`<br/>`contact.telephone2` | **Regroupement dans la clé parente** `contact`. |



### <a name="correspondance-api-paiements-france-travail"></a> API Paiements versés par France Travail

[Swagger V.2](<%= api_particulier_developers_openapi_path %>#tag/Demandeurs-d'emploi/paths/~1api~1v2~1paiements-pole-emploi/get){:target="_blank"}{:.fr-btn .fr-btn--md fr-btn--icon-right fr-icon-arrow-right-fill .fr-btn--secondary}
[Swagger V.3](<%= api_particulier_developers_openapi_v3_path %>#tag/Paiements-verses-par-France-Travail){:target="_blank"}{:.fr-btn .fr-btn--md fr-btn--icon-right fr-icon-arrow-right-fill}


{:.fr-h6}
#### Synthèse des changements : 
- L'identifiant France Travail passé en paramètre d'appel n'est plus renvoyé dans la payload.
- Tous les noms de clés changent au format snake_case, avec un tiret du bas.


{:.fr-h6 .fr-mt-4w}
#### Champs de la payload ayant significativement changé :

{:.fr-table}
| **Champ V.2** | **Champ V.3 correspondant** | **Description des changements** |
|--------------|----------------------------|-------------------------------|
| `identifiant` | *(supprimé)*  | **❌ Suppression du champ :** Inutile car il s'agissait du paramètre d'appel saisi. |
| `date` | `date_versement` | **Renommage de la clé en `date_versement`.** |




### <a name="correspondance-api-statut-rsa"></a> API Statut revenu de solidarité active (RSA) 

[Swagger V.2](<%= api_particulier_developers_openapi_path %>#tag/Prestations-sociales/paths/~1api~1v2~1revenu-solidarite-active/get){:target="_blank"}{:.fr-btn .fr-btn--md fr-btn--icon-right fr-icon-arrow-right-fill .fr-btn--secondary}
[Swagger V.3](<%= api_particulier_developers_openapi_v3_path %>#tag/Statut-Revenu-Solidarite-Active-(RSA)){:target="_blank"}{:.fr-btn .fr-btn--md fr-btn--icon-right fr-icon-arrow-right-fill}

{:.fr-h6}
#### Synthèse des changements : 
- L'endpoint V.2 est divisé en deux endpoints en V.3, un pour la modalité d'appel par données d'identité, l'autre pour la modalité d'appel FranceConnect ;
- Suppression de la date de fin car cette donnée était calculée et présentait le risque de ne pas être juste dans toutes les situations ;
- Tous les noms de clés changent au format snake_case, avec un tiret du bas.


{:.fr-h6 .fr-mt-4w}
#### Champs de la payload ayant significativement changé :


{:.fr-table}
| **Champ V.2** | **Champ V.3 correspondant** | **Description des changements** |
|--------------|--------------------------|-------------------------------|
| `status` | `est_beneficiaire` | **Renommage de la clé** `status` en `est_beneficiaire` et **passage au format en booléen**. |
| `majoration` | `avec_majoration` | **Renommage de la clé** `majoration` en `avec_majoration`. |
| `dateDebut` | `date_debut_droit` | **Renommage de la clé** `dateDebut` en `date_debut_droit`. |
| `dateFin` | *(supprimé)* | **❌ Suppression de la clé** `dateFin`. Cette information était calculée par API Particulier en V.2 par rapport à la date de début. Or la date de début de prestation est la date de première attribution du droit et non du renouvellement du droit donc la date de fin calculée pouvait être fausse.|




### <a name="correspondance-api-statut-prime-activite"></a> API Statut prime d'activité  

[Swagger V.2](<%= api_particulier_developers_openapi_path %>#tag/Prestations-sociales/paths/~1api~1v2~1prime-activite/get){:target="_blank"}{:.fr-btn .fr-btn--md fr-btn--icon-right fr-icon-arrow-right-fill .fr-btn--secondary}
[Swagger V.3](<%= api_particulier_developers_openapi_v3_path %>#tag/Statut-Prime-Activite){:target="_blank"}{:.fr-btn .fr-btn--md fr-btn--icon-right fr-icon-arrow-right-fill}


{:.fr-h6}
#### Synthèse des changements : 
- L'endpoint V.2 est divisé en deux endpoints en V.3, un pour la modalité d'appel par données d'identité, l'autre pour la modalité d'appel FranceConnect ;
- Suppression de la date de fin car cette donnée était calculée et présentait le risque de ne pas être juste dans toutes les situations ;
- Tous les noms de clés changent au format snake_case, avec un tiret du bas.


{:.fr-h6 .fr-mt-4w}
#### Champs de la payload ayant significativement changé :


{:.fr-table}
| **Champ V.2** | **Champ V.3 correspondant** | **Description des changements** |
|--------------|--------------------------|-------------------------------|
| `status` | `est_beneficiaire` | **Renommage de la clé** `status` en `est_beneficiaire` et **passage au format en booléen**. |
| `majoration` | `avec_majoration` | **Renommage de la clé** `majoration` en `avec_majoration`. |
| `dateDebut` | `date_debut_droit` | **Renommage de la clé** `dateDebut` en `date_debut_droit`. |
| `dateFin` | *(supprimé)* | **❌ Suppression de la clé** `dateFin`. Cette information était calculée par API Particulier en V.2 par rapport à la date de début. Or la date de début de prestation est la date de première attribution du droit et non du renouvellement du droit donc la date de fin calculée pouvait être fausse. |


### <a name="correspondance-api-statut-aah"></a> API Statut allocation adulte handicapé (AAH) 


[Swagger V.2](<%= api_particulier_developers_openapi_path %>#tag/Prestations-sociales/paths/~1api~1v2~1allocation-adulte-handicape/get){:target="_blank"}{:.fr-btn .fr-btn--md fr-btn--icon-right fr-icon-arrow-right-fill .fr-btn--secondary}
[Swagger V.3](<%= api_particulier_developers_openapi_v3_path %>#tag/Statut-Allocation-Adulte-Handicape-(AAH)){:target="_blank"}{:.fr-btn .fr-btn--md fr-btn--icon-right fr-icon-arrow-right-fill}



{:.fr-h6}
#### Synthèse des changements : 
- L'endpoint V.2 est divisé en deux endpoints en V.3, un pour la modalité d'appel par données d'identité, l'autre pour la modalité d'appel FranceConnect ;
- Tous les noms de clés changent au format snake_case, avec un tiret du bas.


{:.fr-h6 .fr-mt-4w}
#### Champs de la payload ayant significativement changé :


{:.fr-table}
| **Champ V.2** | **Champ V.3 correspondant** | **Description des changements** |
|--------------|--------------------------|---------------------------------|
| `status`     | `est_beneficiaire`       | **Renommage de la clé** `status` en `est_beneficiaire`. |
| `dateDebut`  | `date_debut_droit`       | **Renommage de la clé** `dateDebut` en `date_debut_droit`. |




### <a name="correspondance-api-statut-asf"></a> API Statut allocation de soutien familial (ASF)

[Swagger V.2](<%= api_particulier_developers_openapi_path %>#tag/Prestations-sociales/paths/~1api~1v2~1allocation-soutien-familial/get){:target="_blank"}{:.fr-btn .fr-btn--md fr-btn--icon-right fr-icon-arrow-right-fill .fr-btn--secondary}
[Swagger V.3](<%= api_particulier_developers_openapi_v3_path %>#tag/Statut-Allocation-Soutien-Familial-(ASF)){:target="_blank"}{:.fr-btn .fr-btn--md fr-btn--icon-right fr-icon-arrow-right-fill}


{:.fr-h6}
#### Synthèse des changements : 
- L'endpoint V.2 est divisé en deux endpoints en V.3, un pour la modalité d'appel par données d'identité, l'autre pour la modalité d'appel FranceConnect ;
- Suppression de la date de fin car cette donnée était calculée et présentait le risque de ne pas être juste dans toutes les situations ;
- Tous les noms de clés changent au format snake_case, avec un tiret du bas.


{:.fr-h6 .fr-mt-4w}
#### Champs de la payload ayant significativement changé :


{:.fr-table}
| **Champ V.2** | **Champ V.3 correspondant** | **Description des changements** |
|--------------|--------------------------|-------------------------------|
| `status`     | `est_beneficiaire`       | **Renommage de la clé** `status` en `est_beneficiaire`. |
| `dateDebut`  | `date_debut_droit`       | **Renommage de la clé** `dateDebut` en `date_debut_droit`. |
| `dateFin`    | *(supprimé)*            | **❌ Suppression de la clé** `dateFin`. Cette information était calculée par API Particulier en V.2 par rapport à la date de début. Or la date de début de prestation est la date de première attribution du droit et non du renouvellement du droit donc la date de fin calculée pouvait être fausse. |



### <a name="correspondance-api-statut-c2s"></a> API Statut complémentaire santé solidaire (C2S) 

[Swagger V.2](<%= api_particulier_developers_openapi_path %>#tag/Prestations-sociales/paths/~1api~1v2~1complementaire-sante-solidaire/get){:target="_blank"}{:.fr-btn .fr-btn--md fr-btn--icon-right fr-icon-arrow-right-fill .fr-btn--secondary}
[Swagger V.3](<%= api_particulier_developers_openapi_v3_path %>#tag/Statut-Complementaire-Sante-Solidaire-(C2S)){:target="_blank"}{:.fr-btn .fr-btn--md fr-btn--icon-right fr-icon-arrow-right-fill}


{:.fr-h6}
#### Synthèse des changements : 
- L'endpoint V.2 est divisé en deux endpoints en V.3, un pour la modalité d'appel par données d'identité, l'autre pour la modalité d'appel FranceConnect ;
- La clé `status` est divisée en deux clés distinctes pour faciliter la compréhension du statut bénéficiaire et du statut majoré ou non ; 
- Suppression de la date de fin car cette donnée était calculée et présentait le risque de ne pas être juste dans toutes les situations ;
- Tous les noms de clés changent au format snake_case, avec un tiret du bas.


{:.fr-h6 .fr-mt-4w}
#### Champs de la payload ayant significativement changé :


{:.fr-table}
| **Champ V.2** | **Champ V.3 correspondant** | **Description des changements** |
|--------------|--------------------------|-------------------------------|
| `status`      | `est_beneficiaire` <br/> `avec_participation`       | **Division du champ `status` en deux clés booléènnes distinctes** : `est_beneficiaire` et `avec_participation`. |
| `dateDebut`   | `date_debut_droit`       | **Renommage de la clé** `dateDebut` en `date_debut_droit`. |
| `dateFin`     |*(supprimé)*               | **❌ Suppression de la clé** `dateFin`. Cette information était calculée par API Particulier en V.2 par rapport à la date de début. Or la date de début de prestation est la date de première attribution du droit et non du renouvellement du droit donc la date de fin calculée pouvait être fausse. |

<br/>
<br/>

[Consulter le swagger V.3](<%= api_particulier_developers_openapi_v3_path %>){:.fr-btn .fr-btn--lg fr-btn--icon-right fr-icon-arrow-right-fill}

</div>