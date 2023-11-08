Mercredi 8 novembre 2023 - Publication

# Comment aider les usagers à renseigner leur lieu de naissance par code COG ?
![Image de présentation de l'article sur le numéro de TVA intracommunautaire](<%= image_path('api_entreprise/blog/non-diffusible-image-principale.png') %>)

{:.fr-highlight}
**Qu'est que le code COG ?**
Le code COG (Code Officiel Géographique) est un code permettant de repérer notamment les communes et les territoires étrangers. Ce code est différent du code postal et peut évoluer dans le temps. C'est pourquoi, le code COG demandé pour identifier un particulier est le **code COG de naissance** de la commune de naissance ou du pays de naissance si le particulier est né à l'étranger.
*Pour en savoir plus :* [Code COG - Insee.fr](https://www.insee.fr/fr/information/2560452){:target="_blank"} et [Codification des pays et territoires étrangers - Insee.fr](https://www.insee.fr/fr/information/2028273){:target="_blank"}.

<br>

## Inconnu des usagers, le code COG démandé pour appeler plusieurs API

Contrairement aux personnes gravitant dans la sphère administrative, **les usagers ne connaissent pas leur code COG de naissance**. Ils sont d'ailleurs susceptibles de le confondre avec leur code postal qui est complètement différent.

**Pourtant, une majorité des API du bouquet API Particulier nécessitent la saisie du code COG en paramètre d'appel pour identifier le particulier** :

- [API Quotient familial CAF & MSA](https://particulier.api.gouv.fr/catalogue/cnaf-msa/quotient_familial_v2#parameters_details) - _Code COG obligatoire_
- [API Complémentaire Santé solidaire](https://particulier.api.gouv.fr/catalogue/cnaf_msa/complementaire_sante_solidaire#parameters_details) - _Code COG obligatoire_
- [API Statut étudiant](https://particulier.api.gouv.fr/catalogue/mesri/statut_etudiant#parameters_details) - _Code COG facultatif_
- [API Statut étudiant boursier](https://particulier.api.gouv.fr/catalogue/cnous/statut_etudiant_boursier#parameters_details) - _Code COG facultatif_


## Comment faciliter la saisie de ce code inconnu ?

L'utilisation du code COG comme référence pour appeler les API est peu susceptible d'évoluer. En intégrant ces API dans vos démarches, il est donc nécessaire de bien concevoir le parcours d'un usager ne passant pas par FranceConnect afin que la saisie de son code COG de naissance ne pose pas de problème.

{:.fr-highlight.fr-highlight--caution}
> **Premièrement, il faut vraiment éviter de proposer un champ "Code COG" brut, sans explication**. Ce champ a de forte chance de ne pas être compris par l'usager et d'être mal complété. Ce n'est pas anodin pour votre démarche car cela peut avoir les conséquences suivantes :
> - L'usager fait demi-tour car l'interface ne fonctionne pas ; 
> - Peu probable mais possible, l'usager renseigne un autre code COG et ces informations correpondent à l'identité d'un autre individu. Même si, bien sûr, votre interface ne divulgue en aucun cas les informations de l'API sans que l'identification de l'usager n'ait été certifiée, cela est susceptible d'entrainer une confusion auprès des agents habilités qui traiteront le dossier.


**Dans ce guide, nous vous proposons donc deux parcours différents conçus pour faciliter le renseignement de ce paramètre d'appel** : 
- **Le parcours 1** nécessite peu de développement informatique, l'expérience usager est correcte, même si elle fait reposer sur l'usager la contrainte de retrouver son code COG ; 
- **Le parcours 2** est d'un niveau d'intégration plus complexe, l'expérience usager est privéligiée.

## 1️⃣ Parcours 1 : l'usager retrouve son code COG grâce à sa carte vitale

{:.fr-h5}
#### Le code COG, une partie du numéro de sécurité sociale :

Le code COG est compris dans le numéro d'inscription au répertoire ([NIR](https://www.insee.fr/fr/metadonnees/definition/c1409)), dît "numéro de sécurité sociale" dont voici un exemple : `1 85 05 78 006 084 36`. Ce numéro est référencé dans le répertoire national d’identification des personnes physiques ([RNIPP](https://www.insee.fr/fr/information/5019311){:target="_blank"}). Il concerne toutes les personnes nées sur le territoire français, ainsi que «&nbsp;_en tant que de besoin [...] les personnes nées à l'étranger_&nbsp;» tel qu'explicité dans [ce décrêt](https://www.legifrance.gouv.fr/loda/article_lc/LEGIARTI000006769674/2008-06-01){:target="_blank"}.
Le code COG correspond aux 6, 7, 8, 9 et 10<sup>èmes</sup> chiffres du numéro de sécurité sociale, soit dans ce même exemple : `78 006`.

⚠️ **Certains particuliers n'ont pas de numéro de sécurité sociale :**
- Seule une partie des étudiants étrangers sont inscrits à la sécurité sociale, seulement s'ils en font la démarche sur [etudiant-etranger.ameli.fr](https://etudiant-etranger.ameli.fr/#/){:target="_blank"}. Beaucoup d'étudiants européens ne font pas cette démarche car ils ont la carte européenne d'assurance maladie. Pour en savoir plus, [service-public.fr](https://www.service-public.fr/particuliers/vosdroits/F36499/1?idFicheParent=F675#1){:target="_blank"}.
- Les personnes étrangères n'ont pas de numéro de sécurité sociale tant qu'elles n'ont pas effectué les [démarches nécessaires].

**Cependant, pour la majorité des cas, le numéro de sécurité sociale figure sur :**
- **sur la carte Vitale**, qui est attribuée à tous les ayant droits de plus de 15 ans français ou résidant en France, accessible dès 12 ans ; 
- **sur l'attestation de droits** (attestation Vitale) et sur les bulletins de salaires.

{:.fr-h5}
#### Exemple d'interface fictive du parcours 1

Le parcours 1 propose donc de s'appuyer sur le numéro de sécurité sociale pour permettre aux usagers de retrouver par eux-même leur code COG de naissance.


1. **Demander son code COG de naissance à l'usager** :

{:.fr-highlight.fr-highlight--example}
> 💡 **Bonnes pratiques** : 
> - Nommer ce champ "Code COG de votre lieu de naissance" et montrer un exemple du format attendu.
> - Rendre accessible, à côté du champ de saisie, un tutoriel pour que l'usager retrouve son code COG.

![Capture d'écran du catalogue montrant les deux types d'API disponibles](<%= image_path('api_particulier/blog/lieu-naissance-code-cog-carte-vitale-1.png') %>){:width="600px" :border="2px"}


2. **Mettre à disposition le tutoriel suivant pour l'aider à retrouver son code COG** :

<div class="fr-container--fluid">
 <div class="fr-grid-row fr-grid-row--gutters">
  <div class="fr-col-md-6 fr-col-12">
   <img src="<%= image_path('api_particulier/blog/lieu-naissance-code-cog-carte-vitale-2.png') %>" class="fr-responsive-img" alt="[Maquette du tutoriel pour récupérer le code COG à partir de la carte Vitale]" />
        <!-- L’alternative de l’image (attribut alt) doit toujours être présent, sa valeur peut-être vide ou non selon votre contexte -->
  </div> 
  <div class="fr-col-12 fr-col-md-6">
   <h4 class="fr-h6">Tutoriel à mettre à disposition des usagers</h4>
   <p class="fr-text--bold">
    Comment retrouver mon code COG ?
   </p>
   <p>
    Le code COG de votre lieu de naissance est un identifiant géographique administratif. ⚠️ Ce code est différent du code postal.
   </p>
   <ul>
     <li>
      Si vous êtes né en France, les deux premiers chiffres correspondent à votre département de naissance. Les trois suivants codifient votre commune de naissance.
     </li>
     <li>
      Si vous êtes né à l’étranger, les deux premiers chiffres sont 99, les trois suivants codifient votre pays de naissance.
     </li>
    </ul>
   <p class="fr-text--bold">
    À partir de votre numéro de sécurité sociale, sur votre carte Vitale :
   </p>
   <p>
    Votre code COG de naissance correspond aux 6, 7, 8, 9 et 10ème chiffres de votre numéro de sécurité sociale.Exemple : Pour ce numéro de sécurité sociale fictif 1 85 05 78 006 084 36,  le code COG est 78 006.
   </p>
   <p class="fr-text--bold">
    Vous n’avez pas de carte Vitale ?
   </p>
   <p>
    Si vous êtes assuré à la sécurité sociale française, votre numéro de sécurité sociale figure sur votre attestation de droit disponible sur ameli.fr (https://assure.ameli.fr). Si vous êtes salarié, il figure également sur vos bulletins de salaires.
   </p>
   <p>
    Si vous êtes né à l’étranger, vous pouvez trouver le code COG de votre pays de naissance dans cette liste de l’Insee : https://www.insee.fr/fr/information/2028273.
   </p>
  </div>
 </div>
</div>
<div class="fr-download fr-mt-4w fr-mb-1v fr-ml-2w">
 <p>
  <a href="<%= image_path('api_particulier/blog/lieu-naissance-code-cog-carte-vitale-3.png') %>" download class="fr-download__link">Télécharger l'image de la carte Vitale et du code COG
   <span class="fr-download__detail">PNG – 16 ko</span>
  </a>
 </p>
</div>
<br/>

## 2️⃣ Parcours 2 : l'usager complète simplement son lieu de naissance
