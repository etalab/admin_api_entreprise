Mercredi 14 décembre 2022 - Publication

# Les _"non-diffusibles"_ et leur utilisation sur&nbsp;API&nbsp;Entreprise

![Image de présentation de l'article sur le numéro de TVA intracommunautaire](<%= image_path('api_entreprise/blog/non-diffusible-image-principale.png') %>)

{:.fr-highlight}
**Qu'est qu'une unité légale non-diffusible ?**
Parmi les entités présentes dans le répertoire Sirene de l'Insee et appelables par API Entreprise, certaines, très majoritairement des personnes physiques, ont explicitement demandé de ne pas figurer en diffusion commerciale, en vertu de l’[article A123-96 du Code du Commerce](https://www.legifrance.gouv.fr/codes/article_lc/LEGIARTI000031043097/){:target="_blank"}. Cela signifie que **leurs données ne sont pas publiques** et que seuls des organismes habilités et des administrations peuvent accéder aux informations.
ℹ️ Les unités de la Défense nationale font également partie des “non-diffusibles” mais ne sont accessibles que sur autorisation du Ministère de la Défense.

<br>

## Comment distinguer les API avec non-diffusibles et celles sans ?

API Entreprise met à disposition deux types d'API en ce qui concerne les données du répertoire Sirene&nbsp;: 
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


## Quel type d'API pour quel usage ?


{:.fr-table}
|   | <span class='fr-badge fr-badge--sm fr-badge--new'>Préremplissage</span>  | <span class='fr-badge fr-badge--sm fr-badge--green-archipel fr-badge--new'>Back-office sécurisé</span> |
|-------------------------------|:------------------------------------:|:----------------------------:|
| **API avec les "diffusibles"**<br/><span class='fr-badge fr-badge--sm fr-badge--grey fr'>Données publiques</span><br><br>  [API Données établissement diffusible - Insee](<%= endpoint_path(uid: 'insee/etablissements_diffusibles') %>)<br/>[API Données unité légale diffusible - Insee](<%= endpoint_path(uid: 'insee/unites_legales_diffusibles') %>)<br/>[API Données siège social diffusible - Insee](<%= endpoint_path(uid: 'insee/siege_social_diffusibles') %>)<br/>[API Adresse établissement diffusible - Insee](<%= endpoint_path(uid: 'insee/adresse_etablissements_diffusibles') %>)  |  <span style="color:#1f8d49" class="fr-icon-checkbox-circle-fill" aria-hidden="true"></span><br>Ces API sont adaptées pour du pré-remplissage car ne contiennent que des données publiques. | <span style="color:#1f8d49" class="fr-icon-checkbox-circle-line" aria-hidden="true"></span><br>Il n'y a pas de contre-indication légale à utiliser cette API en back-office, en revanche vos agents habilités n'auront pas les données des "non-diffusibles".
| **API avec les "diffusibles" et "non-diffusibles"**<br><span class='fr-badge fr-badge--sm fr-badge--white fr'>Données publiques **et protégées**</span><br><br/>  [API Données établissement - Insee](<%= endpoint_path(uid: 'insee/etablissements') %>)<br/>[API Données unité légale - Insee](<%= endpoint_path(uid: 'insee/unites_legales') %>)<br/>[API Données siège social - Insee](<%= endpoint_path(uid: 'insee/siege_social') %>)<br/>[API Adresse établissement - Insee](<%= endpoint_path(uid: 'insee/adresse_etablissements') %>) |   <span style="color:#d64d00" class="fr-icon-close-circle-line" aria-hidden="true"></span><br> ⚠️ À ne pas utiliser pour du préremplissage sauf si vous vous engagez à tenir compte du statut de diffusion le plus récent de l’entité appelée et donc à ne pas faire usage des données d’une entité “non-diffusible” pour du préremplissage. | <span style="color:#1f8d49" class="fr-icon-checkbox-circle-fill" aria-hidden="true"></span><br>Ces API permettront à vos agents habilités d'obtenir des informations sur toutes les entreprises.|

## Bientôt de nouvelles données en V.4

[Partagez-nous vos cas d'usage](https://form.typeform.com/to/MXv9b011){:.fr-btn .fr-btn--secondary}{:target="_blank"}

