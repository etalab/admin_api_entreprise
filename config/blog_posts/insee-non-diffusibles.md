Mercredi 14 décembre 2022 - Publication

# Le futur des _"non-diffusibles"_
![Image de présentation de l'article sur le numéro de TVA intracommunautaire](<%= image_path('api_entreprise/blog/non-diffusible-image-principale.png') %>)

{:.fr-highlight}
**Qu'est qu'une unité légale non-diffusible ?**
On parle de "non-diffusibles" dans le cadre des entreprises et associations enregistrées au répertoire Sirene de l'Insee. Ce statut à un impact sur la diffusion des informations les concernant.
Parmi les entités présentes et appelables par API Entreprise, certaines, très majoritairement des personnes physiques, ont explicitement demandé de ne pas figurer en diffusion commerciale, en vertu de l’[article A123-96 du Code du Commerce](https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000031043097/){:target="_blank"}. Cela signifie que **leurs données ne sont pas publiques** et que seuls des organismes habilités et des administrations peuvent accéder aux informations.
<br>


## Bientôt de nouvelles données publiques en V.4 🎢... <br>et quelques-unes en moins côté personne morale 🛬

Conformément au RGPD et suite au [décret n° 2022-1014 du 19 juillet 2022](https://www.legifrance.gouv.fr/jorf/id/JORFTEXT000046061058){:target="_blank"}, certaines données des unités légales et établissements "non-diffusibles" du répertoire Sirene seront disponibles, comme par exemple : les numéros SIREN et SIRET, l'activité principale exercée, la catégorie juridique ou encore la tranche d’effectifs…

{:.fr-quote }
« _Ce sont ainsi des données concernant plus de **2,8 millions d’établissements et 1,9 million d’unités légales qui seront désormais accessibles à tous**._ » 
Insee, [Lettre Sirene open data actualité n°13](https://www.insee.fr/fr/information/6525081){:target="_blank"}

<br>
Jusqu'ici, aucune donnée sur les non-diffusibles n'était publique. Concrêtement, voici les données

## Les "non-diffusibles" sur API Entreprise

{:.h-4}
### Comment distinguer les API avec non-diffusibles ?

API Entreprise met à disposition des administrations habilitées deux types d'API en ce qui concerne les données du répertoire Sirene&nbsp;: 
- les API avec la mention "diffusible", soit **uniquement** les données des unités légales diffusibles.
- les API sans cette mention, permettant alors d'accéder à **toutes les unités légales**, y compris les non-diffusibles.


![Capture d'écran du catalogue montrant les deux types d'API disponibles](<%= image_path('api_entreprise/blog/non-diffusible-catalogue-deux-types-d-api.png') %>){:width="600px" :border="2px"}


{:.fr-table}
| **Toutes les unités légales** | **Uniquement les diffusibles** |
|-------------------------------|------------------------------------|
| [API Données établissement - Insee](<%= endpoint_path(uid: 'insee/etablissements') %>)         | [API Données établissement diffusible - Insee](<%= endpoint_path(uid: 'insee/etablissements_diffusibles') %>)   |
| [API Données unité légale - Insee](<%= endpoint_path(uid: 'insee/unites_legales') %>)          |[API Données unité légale diffusible - Insee](<%= endpoint_path(uid: 'insee/unites_legales_diffusibles') %>)    |
| [API Données siège social - Insee](<%= endpoint_path(uid: 'insee/siege_social') %>)          | [API Données siège social diffusible - Insee](<%= endpoint_path(uid: 'insee/siege_social_diffusibles') %>)    |
| [API Adresse établissement - Insee](<%= endpoint_path(uid: 'insee/adresse_etablissements') %>)         | [API Adresse établissement diffusible - Insee](<%= endpoint_path(uid: 'insee/adresse_etablissements_diffusibles') %>)  |

{:.h-4}
### Quel type d'API pour quel usage ?

Les API de l'API Entreprise sont généralement utilisées de deux façons&nbsp;:
- Pour **pré-remplir les démarches en ligne** avec des données publiques et ainsi accélerer la saisie pour les entreprises/associations ;
- Pour donner un **accès en back-office** aux des agents habilités afin de faciliter et accélerer le traitement des démarches des entreprises/associations.

{:.fr-table}
|   | <span class='fr-badge fr-badge--sm fr-badge--new'>Préremplissage</span>  | <span class='fr-badge fr-badge--sm fr-badge--green-archipel fr-badge--new'>Back-office sécurisé</span> |
|-------------------------------|:------------------------------------:|:----------------------------:|
| **API avec les "diffusibles"**<br/><span class='fr-badge fr-badge--sm fr-badge--grey fr'>Données publiques</span><br><br>  [API Données établissement diffusible - Insee](<%= endpoint_path(uid: 'insee/etablissements_diffusibles') %>)<br/>[API Données unité légale diffusible - Insee](<%= endpoint_path(uid: 'insee/unites_legales_diffusibles') %>)<br/>[API Données siège social diffusible - Insee](<%= endpoint_path(uid: 'insee/siege_social_diffusibles') %>)<br/>[API Adresse établissement diffusible - Insee](<%= endpoint_path(uid: 'insee/adresse_etablissements_diffusibles') %>)  |  <span style="color:#1f8d49" class="fr-icon-checkbox-circle-fill" aria-hidden="true"></span><br>Ces API sont adaptées pour du pré-remplissage car ne contiennent que des données publiques. | <span style="color:#1f8d49" class="fr-icon-checkbox-circle-line" aria-hidden="true"></span><br>Il n'y a pas de contre-indication légale à utiliser cette API en back-office, en revanche vos agents habilités n'auront pas les données des "non-diffusibles".
| **API avec les "diffusibles" et "non-diffusibles"**<br><span class='fr-badge fr-badge--sm fr-badge--white fr'>Données publiques **et protégées**</span><br><br/>  [API Données établissement - Insee](<%= endpoint_path(uid: 'insee/etablissements') %>)<br/>[API Données unité légale - Insee](<%= endpoint_path(uid: 'insee/unites_legales') %>)<br/>[API Données siège social - Insee](<%= endpoint_path(uid: 'insee/siege_social') %>)<br/>[API Adresse établissement - Insee](<%= endpoint_path(uid: 'insee/adresse_etablissements') %>) |   <span style="color:#d64d00" class="fr-icon-close-circle-line" aria-hidden="true"></span><br> ⚠️ À ne pas utiliser pour du préremplissage sauf si vous vous engagez à tenir compte du statut de diffusion le plus récent de l’entité appelée (avec la clé `Diffusable commercialement`) et donc à ne pas faire usage des données d’une entité “non-diffusible” pour du préremplissage. | <span style="color:#1f8d49" class="fr-icon-checkbox-circle-fill" aria-hidden="true"></span><br>Ces API permettront à vos agents habilités d'obtenir des informations sur toutes les entreprises.|

{:.fr-h6}
### Comment tenir compte du statut de diffusion ?
 
Parmi les clés renvoyées par les API ayant les non-diffusibles, il y a un champ `Diffusable commercialement` qui indique si l'entreprise est diffusible ou non. Vous pouvez donc filtrer les unités légales selon qu'elles sont diffusibles ou non-diffusibles.

{:.fr-highlight}
Cette clé est actuellement **uniquement disponible pour les API renvoyant les non-diffusibles.**
