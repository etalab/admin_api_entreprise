Mercredi 8 novembre 2023 - Publication

# Aider les usagers à renseigner leur lieu de naissance par code COG
![Image de présentation de l'article sur le numéro de TVA intracommunautaire](<%= image_path('api_particulier/blog/lieu-naissance-code-cog-en-tete.png') %>)

{:.fr-highlight}
**Qu'est que le code COG ?**
Le code COG (Code Officiel Géographique) est un code permettant de repérer notamment les communes et les territoires étrangers. Ce code est différent du code postal et peut évoluer dans le temps. C'est pourquoi, le code COG demandé pour identifier un particulier est le **code COG de naissance** de la commune de naissance ou du pays de naissance si le particulier est né à l'étranger.
*Pour en savoir plus : [Code COG - Insee.fr](https://www.insee.fr/fr/information/2560452){:target="_blank"} et [Codification des pays et territoires étrangers - Insee.fr](https://www.insee.fr/fr/information/2028273){:target="_blank"}*.

<nav class="fr-summary" role="navigation" aria-labelledby="fr-summary-title">
 <p class="fr-summary__title" id="fr-summary-title">Sommaire</p>
 <ol class="fr-summary__list">
  <li>
   <a class="fr-summary__link" href="#code-cog-inconnu">Inconnu des usagers, le code COG démandé par plusieurs API</a>
  </li>
  <li>
   <a class="fr-summary__link" href="#ne-pas-faire">❌ Ne pas faire : un champ "Code COG" sans explication</a>
  </li>
  <li>
   <a class="fr-summary__link" href="#option-1">✅ Option 1 : Saisie du code COG par l'usager, accompagné d'un tutoriel</a>
  </li>
  <li>
   <a class="fr-summary__link" href="#option-2">✅ Option 2 : Année et lieu de naissance saisis par l'usager, code code déduit en arrière-plan</a>
  </li>
 </ol>
</nav>

<br/>

## <a name="code-cog-inconnu"></a>Inconnu des usagers, le code COG démandé par plusieurs API

{:.fr-text--lg}
Contrairement aux personnes gravitant dans la sphère administrative, **les usagers ne connaissent pas leur code COG de naissance**. Ils sont d'ailleurs susceptibles de le confondre avec leur code postal qui est complètement différent.

**Pourtant, une majorité des API du bouquet API Particulier nécessitent la saisie du code COG en paramètre d'appel pour identifier le particulier** :

- [API Quotient familial CAF & MSA](https://particulier.api.gouv.fr/catalogue/cnaf-msa/quotient_familial_v2#parameters_details) - _Code COG obligatoire_
- [API Complémentaire Santé solidaire](https://particulier.api.gouv.fr/catalogue/cnaf_msa/complementaire_sante_solidaire#parameters_details) - _Code COG obligatoire_
- [API Statut étudiant](https://particulier.api.gouv.fr/catalogue/mesri/statut_etudiant#parameters_details) - _Code COG facultatif_

L'utilisation du code COG comme référence pour appeler les API est peu susceptible d'évoluer. En intégrant ces API dans vos démarches, il est donc nécessaire de bien concevoir le parcours d'un usager ne passant pas par FranceConnect afin que la saisie de son code COG de naissance ne pose pas de problème.

## <a name="ne-pas-faire"></a>❌ Ne pas faire : un champ "Code COG" sans explication

{:.fr-text--lg}
Il faut éviter de proposer un champ "Code COG" brut, sans explication. Ce champ pourrait être incompris par l'usager et donc être mal complété. 

Ce n'est pas anodin pour votre démarche car cela peut avoir les conséquences suivantes :
- L'usager fait demi-tour car l'interface ne fonctionne pas ; 
- L'usager renseigne un autre code COG, et ces informations correpondent à l'identité d'un autre individu. Même si, bien sûr, ce cas est peu probable et que votre interface ne divulgue en aucun cas les informations de l'API sans que l'identification de l'usager n'ait été certifiée, cela est susceptible d'entrainer une confusion auprès des agents habilités qui traiteront le dossier.

**Dans ce guide, nous vous proposons donc deux parcours différents conçus pour faciliter le renseignement de ce paramètre d'appel** : 
- **[Le parcours 1](#option-1)** nécessite peu de développement informatique, l'expérience usager est correcte, même si elle fait reposer sur l'usager la contrainte de retrouver son code COG ; 
- **[Le parcours 2](#option-2)** est d'un niveau d'intégration plus complexe, l'expérience usager est privéligiée.


## <a name="option-1"></a> ✅ Option 1 : Saisie du code COG par l'usager, accompagné d'un tutoriel

{:.fr-h5}
#### Le code COG, une partie du numéro de sécurité sociale :

Le code COG est compris dans le numéro d'inscription au répertoire ([NIR](https://www.insee.fr/fr/metadonnees/definition/c1409)), dît "numéro de sécurité sociale" dont voici un exemple : `1 85 05 78 006 084 36`. Ce numéro est référencé dans le répertoire national d’identification des personnes physiques ([RNIPP](https://www.insee.fr/fr/information/5019311){:target="_blank"}). Il concerne toutes les personnes nées sur le territoire français, ainsi que «&nbsp;_en tant que de besoin [...] les personnes nées à l'étranger_&nbsp;» tel qu'explicité dans [ce décret](https://www.legifrance.gouv.fr/loda/article_lc/LEGIARTI000006769674/2008-06-01){:target="_blank"}.
Le code COG correspond aux 6, 7, 8, 9 et 10<sup>èmes</sup> chiffres du numéro de sécurité sociale, soit dans ce même exemple : `78 006`.

⚠️ **Certains particuliers n'ont pas de numéro de sécurité sociale :**
- Seule une partie des étudiants étrangers sont inscrits à la sécurité sociale, seulement s'ils en font la démarche sur [etudiant-etranger.ameli.fr](https://etudiant-etranger.ameli.fr/#/){:target="_blank"}. Beaucoup d'étudiants européens ne font pas cette démarche car ils ont la carte européenne d'assurance maladie. Pour en savoir plus, [service-public.fr](https://www.service-public.fr/particuliers/vosdroits/F36499/1?idFicheParent=F675#1){:target="_blank"}.
- Les personnes étrangères n'ont pas de numéro de sécurité sociale tant qu'elles n'ont pas effectué les [démarches nécessaires].

**Cependant, pour la majorité des cas, le numéro de sécurité sociale figure sur :**
- **la carte Vitale**, qui est attribuée à tous les ayant droits de plus de 15 ans français ou résidant en France, accessible dès 12 ans ; 
- **l'attestation de droits** (attestation Vitale) et sur les bulletins de salaires.

Et pour les personnes nées à l'étranger, le code COG est trouvable dans [cette liste de l'Insee](https://www.insee.fr/fr/information/2028273){:target="_blank"}. 

{:.fr-h5}
#### Exemple d'interface recommandée

{:.fr-text--lg}
Le parcours 1 propose donc de s'appuyer sur le numéro de sécurité sociale pour permettre aux usagers de retrouver par eux-même leur code COG de naissance et de le renseigner.


{:.fr-highlight}
> 💡 **Caractéristiques** : 
> - Proposer un champ "Code COG de votre lieu de naissance" et montrer un exemple du format attendu.
> - Rendre accessible, à côté du champ de saisie, un tutoriel pour que l'usager retrouve son code COG.


<div class="fr-container--fluid">
 <div class="fr-grid-row fr-grid-row--gutters">
  <div class="fr-col-md-6 fr-col-12">
   <img src="<%= image_path('api_particulier/blog/lieu-naissance-code-cog-carte-vitale-1.png') %>" class="fr-responsive-img" alt="[Maquette du champ COG à partir de la carte vitale]"/>
  </div> 
  <div class="fr-col-12 fr-col-md-6">
   <img src="<%= image_path('api_particulier/blog/lieu-naissance-code-cog-carte-vitale-2.png') %>" class="fr-responsive-img" alt="[Maquette du tutoriel pour récupérer le code COG à partir de la carte Vitale]"/>
  </div>
 </div>
</div>
<section class="fr-accordion">
 <h3 class="fr-accordion__title">
  <button class="fr-accordion__btn" aria-expanded="false" aria-controls="accordion-1">
   Pour reproduire le turoriel : copier/coller le texte
  </button>
 </h3>
 <div class="fr-collapse" id="accordion-1">
  
  **Comment retrouver mon code COG ?**
  
  Le code COG de votre lieu de naissance est un identifiant géographique administratif. ⚠️ Ce code est différent du code postal.
  - **Si vous êtes né en France**, les deux premiers chiffres correspondent à votre département de naissance. Les trois suivants codifient votre commune de naissance.
  - **Si vous êtes né à l’étranger**, les deux premiers chiffres sont 99, les trois suivants codifient votre pays de naissance.

  **À partir de votre numéro de sécurité sociale, sur votre carte Vitale :**
  Votre code COG de naissance correspond aux 6, 7, 8, 9 et 10ème chiffres de votre numéro de sécurité sociale. Exemple : Pour ce numéro de sécurité sociale fictif 1 85 05 78 006 084 36,  le code COG est 78 006.
   
  **Vous n’avez pas de carte Vitale ?**
  Si vous êtes assuré à la sécurité sociale française, votre numéro de sécurité sociale figure sur votre attestation de droit disponible sur ameli.fr [https://assure.ameli.fr](https://assure.ameli.fr){:target="_blank"}. Si vous êtes salarié, il figure également sur vos bulletins de salaires.<br/>
  Si vous êtes né à l’étranger, vous pouvez trouver le code COG de votre pays de naissance dans cette liste de l’Insee : [https://www.insee.fr/fr/information/2028273](https://www.insee.fr/fr/information/2028273){:target="_blank"}.
 </div>
</section>
<div class="fr-download fr-mt-4w fr-mb-1v fr-ml-2w">
 <p>
  <a href="<%= image_path('api_particulier/blog/lieu-naissance-code-cog-carte-vitale-3.png') %>" download class="fr-download__link">Pour reproduire le tutoriel : télécharger l'image de la carte Vitale et du code COG
   <span class="fr-download__detail">PNG – 16 ko</span>
  </a>
 </p>
</div>
<br/>

## <a name="option-2"></a>✅ Option 2 : Année et lieu de naissance saisis par l'usager, code code déduit en arrière-plan

{:.fr-text--lg}
Dans cette seconde option, le renseignement du code COG pour appeler l'API est totalement transparent pour l'usager, qui n'aura qu'à compléter sa date et son lieu de naissance. 

{:.fr-h5}
### Exemple d'interface recommandée :

<div class="fr-container--fluid">
 <div class="fr-grid-row fr-grid-row--gutters">
  <div class="fr-col-md-6 fr-col-12">
   <img src="<%= image_path('api_particulier/blog/lieu-naissance-code-cog-backoffice-1.png') %>" class="fr-responsive-img" alt="[Maquette saisie date et lieu de naissance]"/>
  </div> 
  <div class="fr-col-12 fr-col-md-6">
   <img src="<%= image_path('api_particulier/blog/lieu-naissance-code-cog-backoffice-3.png') %>" class="fr-responsive-img" alt="[Maquette saisie date et lieu de naissance, autocompléteur ouvert]"/>
  </div>
 </div>
</div>

{:.fr-highlight}
> **💡 Caractéristiques** : 
> - **Retrouver le code COG en arrière-plan, à partir des informations saisies par l'usager** : une fois que l'année et le lieu de naissance ont été complétés par l'usager et que celui-ci clique pour passer à l'étape suivante, les informations obtenues (*nom de la commune* & *code département de naissance* ou *pays de naissance* ; *année de naissance*) sont traitées en arrière-plan pour être converties en code COG.
> - **Rendre l'année de naissance obligatoire**, car elle est indispensable pour retrouver le code COG. En revanche, le jour et le mois de naissance restent facultatifs.
> - **Séparer les champs "lieu de naissance" des particuliers nés en France et ceux nés à l'étranger**. En effet, un champ commun risque de mettre en difficulté les usagers nés à l'étranger qui vont peut-être saisir leur commune de naissance à l'étranger. L'auto-compléteur ne pourra pas gérer une telle complexité.
> - **Proposer un auto-compléteur**, pour permettre à l'usager de saisir son code postal ou sa commune en toutes lettres. Afficher systématiquement le code postal, le nom de la commune et le département pour s'assurer que l'usager sélectionnera la bonne commune de naissance.


{:.fr-h5}
### Certaines difficultés à considérer :

Le Code COG et le nom d'une commune peut varier dans le temps pour cause de fusion, migration ou autre opération intervenant à l'échelle territoriale. Voici une [liste d'exemples de cas singuliers](https://github.com/skelz0r/identite_pivot_code_insee_naissance_lookup/blob/main/spec/examples.csv){:target="_blank"} où le code COG peut-être difficile à déduire.

Ces difficultés sont quasi inexistantes pour :
-  l'[API Statut étudiant](https://particulier.api.gouv.fr/catalogue/mesri/statut_etudiant#parameters_details), simplement parce que la majorité des particuliers concernés sont jeunes, leur code COG est donc facile à retrouver
- les personnes nées à l'étranger car les codes COG des pays étrangers n'ont jamais varié.

{:.fr-h5}
### Des outils déjà disponibles pour vous aider à intégrer cette solution :

- **📍 Une Webapp pour retrouver le code COG**
  Cette [webapp](https://github.com/skelz0r/identite_pivot_code_insee_naissance_lookup){:target="_blank"}, gérée par l'équipe API Particulier, permet de retrouver le code COG à partir des informations *nom de la commune* & *code département de naissance* ou *pays de naissance* ; *année de naissance*.
- **📍 Les autocompléteurs, déjà disponibles sur data.gouv.fr**
  TODO








