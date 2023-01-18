Mercredi 14 décembre 2022 - Publication

# Le futur des _"non-diffusibles"_
![Image de présentation de l'article sur le numéro de TVA intracommunautaire](<%= image_path('api_entreprise/blog/non-diffusible-image-principale.png') %>)


## Qu'est qu'une unité légale ou un établissement non-diffusible ?
On parle de "non-diffusibles" pour certaines entités enregistrées au répertoire Sirene de l'Insee. Ce statut a un impact sur la diffusion des informations les concernant.
Parmi les entités présentes et appelables par API Entreprise, certaines, très majoritairement des personnes physiques, ont explicitement demandé de ne pas figurer en diffusion commerciale, en vertu de l’[article A123-96 du Code du Commerce](https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000031043097/){:target="_blank"}. Cela signifie que **leurs données ne sont pas publiques** et que seuls des organismes habilités et des administrations peuvent accéder aux informations.

{:.fr-highlight}
**ℹ️ Cas très particuliers** : Certaines entités ne sont pas diffusibles pour d'autres raisons que la non-diffusion commerciale. C'est par exemple le cas des établissements de gestion de paye de la fonction publique immatriculés pour les seuls besoins de certaines administrations (les impôts, les URSSAF, la DGCP …) et donc uniquement accessibles à ces administrations fiscales. C'est aussi le cas des unités de la Défense nationale, accessibles sur autorisation du Ministère de la Défense, conformément à l’[article A 123-95 du Code du commerce](https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000020165032/2010-07-02){:target="_blank"}. **Ces unités ne sont pas diffusées par l'API Entreprise**.


## Bientôt de nouvelles données publiques en V.4 🎢 <br>et quelques-unes en moins côté personne morale

Pour se conformer au RGPD et au [décret n° 2022-1014 du 19 juillet 2022](https://www.legifrance.gouv.fr/jorf/id/JORFTEXT000046061058){:target="_blank"}, l'Insee va sortir une nouvelle version de la base Sirene. Cette évolution concerne deux aspects&nbsp;: 
1. Auparavant, seules les personnes physiques pouvaient opter pour le statut "non-diffusible"; avec les nouvelles modalités, **les personnes morales pourront également réclamer une diffusion partielle** de leurs données.
2. Auparavant, aucune donnée des unités légales et établissements "non-diffusibles" était diffusable publiquement, bientôt, **certaines informations seront disponibles et en diffusion libre**, comme par exemple : les numéros SIREN et SIRET, l'activité principale exercée, la catégorie juridique ou encore la tranche d’effectifs…

{:.fr-quote }
L'Insee précise « _Ce sont ainsi des données concernant plus de **2,8 millions d’établissements et 1,9 million d’unités légales qui seront désormais accessibles à tous**._ » 
[Lettre Sirene open data actualité n°13](https://www.insee.fr/fr/information/6525081){:target="_blank"}

<br>
📅 La sortie de cette nouvelle version est prévue pour le 21 mars 2023 d'après la [Lettre Siren open data actualuté n*14](https://www.insee.fr/fr/information/6683782){:target="_blank"}.

{:.fr-h5}
### Les données dont le statut de diffusion va changer :

**🧑‍⚕️ Pour les personnes physiques ayant actuellement le statut "non-diffusible"** et celles qui opteront par la suite pour la "diffusion partielle", voici les données qui seront désormais **diffusables**&nbsp;:
- SIREN
- SIRET
- Commune (code et libellé)
- Pays (code et libellé)
- Les variables économiques : activité principale exercée, tranche d’effectif, catégorie d’entreprise, etc.
- l'état administratif, permettant de savoir si l'unité légale est active ou cessée ; l'établissement, actif ou fermé.

<br>

**🏢 Pour les personnes morales qui choisiront le nouveau statut de "diffusion partielle"**, voici les données qui seront _a contrario_ désormais **confidentielles**🔐&nbsp;: 
- le sigle
- le numéro + la voie de l'adresse postale

<br>

## Les "non-diffusibles" sur API Entreprise

{:.fr-h5}
### Distinguer les API diffusibles dans le catalogue

API Entreprise met à disposition des administrations habilitées deux types d'API en ce qui concerne les données issues de l'Insee et du répertoire Sirene&nbsp;: 
- les API avec la mention "diffusible", soit **uniquement** les données des unités légales diffusibles.
- les API sans cette mention, permettant alors d'accéder à **toutes les unités légales**, y compris les "non-diffusibles" (_qui deviendront les "diffusion partielle", une fois qu'API Entreprise aura intégré la nouvelle version de la base Sirene_).


![Capture d'écran du catalogue montrant les deux types d'API disponibles](<%= image_path('api_entreprise/blog/non-diffusible-catalogue-deux-types-d-api.png') %>){:width="600px" :border="2px"}


{:.fr-table}
| **Toutes les unités légales** | **Uniquement les diffusibles** |
|-------------------------------|------------------------------------|
| [API Données établissement - Insee](<%= endpoint_path(uid: 'insee/etablissements') %>)         | [API Données établissement diffusible - Insee](<%= endpoint_path(uid: 'insee/etablissements_diffusibles') %>)   |
| [API Données unité légale - Insee](<%= endpoint_path(uid: 'insee/unites_legales') %>)          |[API Données unité légale diffusible - Insee](<%= endpoint_path(uid: 'insee/unites_legales_diffusibles') %>)    |
| [API Données siège social - Insee](<%= endpoint_path(uid: 'insee/siege_social') %>)          | [API Données siège social diffusible - Insee](<%= endpoint_path(uid: 'insee/siege_social_diffusibles') %>)    |
| [API Adresse établissement - Insee](<%= endpoint_path(uid: 'insee/adresse_etablissements') %>)         | [API Adresse établissement diffusible - Insee](<%= endpoint_path(uid: 'insee/adresse_etablissements_diffusibles') %>)  |


{:.fr-h5}
### Utiliser la bonne API pour son cas d'usage

Les API de l'API Entreprise sont souvent utilisées de deux façons&nbsp;:
- Pour **pré-remplir les démarches en ligne** avec des données publiques et ainsi accélerer la saisie pour les entreprises/associations ;
- Pour donner un **accès en back-office** aux agents habilités afin de faciliter et accélerer le traitement des démarches des entreprises/associations.

{:.fr-table}
|   | <span class='fr-badge fr-badge--sm fr-badge--new'>Préremplissage</span>  | <span class='fr-badge fr-badge--sm fr-badge--green-archipel fr-badge--new'>Back-office sécurisé</span> |
|-------------------------------|:------------------------------------:|:----------------------------:|
| **API avec les "diffusibles"**<br/><span class='fr-badge fr-badge--sm fr-badge--grey fr'>Données publiques</span><br><br>  [API Données établissement diffusible - Insee](<%= endpoint_path(uid: 'insee/etablissements_diffusibles') %>)<br/>[API Données unité légale diffusible - Insee](<%= endpoint_path(uid: 'insee/unites_legales_diffusibles') %>)<br/>[API Données siège social diffusible - Insee](<%= endpoint_path(uid: 'insee/siege_social_diffusibles') %>)<br/>[API Adresse établissement diffusible - Insee](<%= endpoint_path(uid: 'insee/adresse_etablissements_diffusibles') %>)  |  <span style="color:#1f8d49" class="fr-icon-checkbox-circle-fill" aria-hidden="true"></span><br>Ces API sont adaptées pour du pré-remplissage car ne contiennent que des données publiques. | <span style="color:#1f8d49" class="fr-icon-checkbox-circle-line" aria-hidden="true"></span><br>Il n'y a pas de contre-indication légale à utiliser cette API en back-office, en revanche vos agents habilités n'auront pas les données des "non-diffusibles".
| **API avec les "diffusibles" et "non-diffusibles"**<br><span class='fr-badge fr-badge--sm fr-badge--white fr'>Données publiques **et protégées**</span><br><br/>  [API Données établissement - Insee](<%= endpoint_path(uid: 'insee/etablissements') %>)<br/>[API Données unité légale - Insee](<%= endpoint_path(uid: 'insee/unites_legales') %>)<br/>[API Données siège social - Insee](<%= endpoint_path(uid: 'insee/siege_social') %>)<br/>[API Adresse établissement - Insee](<%= endpoint_path(uid: 'insee/adresse_etablissements') %>) |   <span style="color:#d64d00" class="fr-icon-close-circle-line" aria-hidden="true"></span><br> ⚠️ À ne pas utiliser pour du préremplissage sauf si vous vous engagez à tenir compte du statut de diffusion le plus récent de l’entité appelée (avec la clé `diffusable_commercialement`) et donc à ne pas faire usage des données d’une entité “non-diffusible” pour du préremplissage. | <span style="color:#1f8d49" class="fr-icon-checkbox-circle-fill" aria-hidden="true"></span><br>Ces API permettront à vos agents habilités d'obtenir des informations sur toutes les entreprises.|

{:.fr-h5}
### Tenir compte du statut de diffusion
 
Parmi les clés renvoyées par les API retournant les entités "non-diffusibles", il y a un champ `diffusable_commercialement` qui indique si l'entreprise est "diffusible" ou non. Vous pouvez donc filtrer les entités selon qu'elles sont diffusibles ou non-diffusibles.

{:.fr-highlight}
Cette clé est actuellement **uniquement disponible pour les API renvoyant les "non-diffusibles".** Lorsqu'API Entreprise aura intégré la nouvelle version de la base Sirene, cette variable sera également disponible dans les API ayant la mention "diffusible" pour les entités en "diffusion partielle".


-----


[Toutes les API Insee du catalogue API Entreprise](https://entreprise.api.gouv.fr/catalogue?Endpoint%5Bquery%5D=diffusible){:.fr-btn .fr-btn--secondary fr-btn--icon-right fr-icon-arrow-right-fill}

