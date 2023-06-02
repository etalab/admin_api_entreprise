Vendredi 02 juin 2023 - Publication
<p class="fr-badge fr-badge--green-menthe">💡 Bonne pratique</p>

# Inciter à la mise à jour des référentiels sources
![Image de présentation de l'article sur le numéro de TVA intracommunautaire](<%= image_path('api_entreprise/blog/references-sites-modification-donnees.png') %>)

{:.fr-highlight}
> **La mise à jour des données, une situation fréquente pour vos usagers**
> API Entreprise permet d'interroger les répertoires principaux des données des entreprises et des associations, tels que le [répertoire Sirene](<%= endpoints_path(APIEntreprise_Endpoint: { query: 'insee' }) %>) ou le [RNA](<%= endpoints_path(APIEntreprise_Endpoint: { query: 'rna' }) %>). 
> Il peut arriver que ces répertoires ne soient pas toujours représentatifs de la dernière situation de l'entreprise ou de l'association. Dans ce cas, le pré-remplissage par le biais de l'API Entreprise peut être erroné et l'usager aura alors le souhait de modifier ces informations.

<br>

{:.fr-h3}
## Comment proposer la mise à jour des informations de vos usagers ?

**La mise à jour d'une information peut être faite directement sur votre démarche en ligne, en permettant à vos usagers d'éditer le champ eronné**. Cette fonctionnalité leur permettra de terminer la démarche. En revanche, si l'usager réalise d'autres démarches, il aura besoin d'effectuer cette manipulation pour chacune d'entre elles car l'information corrigée ne sera pas transmise aux répertoires de référence.

**C'est pourquoi, il peut être utile de proposer à vos usagers des liens vers les démarches permettant la mise à jour de leurs données.** Une fois la déclaration effectuée, les délais de prise en compte dans les répertoires sont généralement de 2 à 4 semaines. Il est donc préférable de proposer les deux modalités de modification : une édition dans votre service en ligne et une redirection vers les sites permettant la mise à jour des répertoires.

<div class="fr-container--fluid">
 <div class="fr-grid-row fr-grid-row--gutters">
  <div class="fr-col-md-6 fr-col-12">
   <img src="<%= image_path('api_entreprise/blog/references-sites-modification-donnees-exemple-maquette.png') %>" class="fr-responsive-img" alt="[À MODIFIER | vide ou texte alternatif de l’image]" />
        <!-- L’alternative de l’image (attribut alt) doit toujours être présent, sa valeur peut-être vide ou non selon votre contexte -->
  </div> 
  <div class="fr-col-12 fr-col-md-6">
   <p class="fr-text--bold">
    Ci-contre, un exemple d'interface qui reprend les bonnes pratiques suivantes :
   </p>
   <ul>
    <li>
     ✅ Un champ pré-rempli avec les données de l'API Entreprise ;
    </li>
    <li>
     ✅ Un bouton ou un champ de saisie actif permettant à l'usager de rectifier l'information ;
    </li>
    <li>
     ✅ Un lien vers le site permettant de déclarer la modification au répertoire de référence.
    </li>  
   </ul> 
  </div>
 </div>
</div>


<br>

{:.fr-h3}
## Ajouter des liens vers les sites permettant la modification

Les divers services en ligne à destination des entreprises et des associations sont actuellement en cours de refonte pour mettre à disposition un guichet unique où toutes les démarches pourront être réalisées. À ce jour, **tout n'est pas encore stabilisé et le parcours utilisateur pour modifier durablement les informations reste complexe**. En attendant la mise à disposition des guichets uniques, API Entreprise vous recommande déjà certains liens susceptibles d'aider vos usagers.

<br>

{:.fr-h5}
### Pour les entreprises : le portail e-procédures de l'Inpi recommandé

📌 **Pour la mise à jour des données d'une entreprise**, API Entreprise vous recommande de communiquer le lien suivant à vos usagers : 
**[https://procedures.inpi.fr/?/](https://procedures.inpi.fr/?/){:target="_blank"}{:.fr-link}**.

Après un test du parcours utilisateur, ce site :
- est le plus direct vers les démarches de modifications d'informations, même si, l'utilisateur devra tout de même naviguer sur différents sites dont le [guichet-entreprises.fr](https://account.guichet-entreprises.fr/session/new){:target="_blank"} ;
- est recommandé par [Service-public.fr](https://www.service-public.fr/particuliers/vosdroits/R61572){:target="_blank"}.
<br>

{:.fr-highlight}
> **Qu'en est-il du site du guichet unique [formalites.entreprises.gouv.fr](https://formalites.entreprises.gouv.fr/){:target="_blank"} ?**
> Ce site, destiné à remplacer la totalité des plateformes à destination des entreprises, reste à ce jour une page unique retransférant l'usager vers le portail e-procédures de l'Inpi. Étant donné que le parcours actuel est long, nous ne recommandons pas pour l'instant d'afficher ce lien. Toutefois, il est fort probable que cette page devienne la référence.

<br>

{:.fr-h5}
## Pour les associations : Le Compte Asso

Si le site [Le Compte Asso](https://lecompteasso.associations.gouv.fr){:target="_blank"} ne permet pas encore de modifier directement les informations de l'association, il recense en revanche la totalité des procédures :

📌 **Pour la majorité des déclarations**, nous vous recommandons d'indiquer le lien suivant : 
**[https://lecompteasso.associations.gouv.fr/declarer-un-changement-de-situation-de-mon-association/](https://lecompteasso.associations.gouv.fr/declarer-un-changement-de-situation-de-mon-association/){:target="_blank"}{:.fr-link}**.
Ce guide permettra à vos usagers de savoir auprès de qui les changements doivent être déclarés. En effet, pour certaines procédures, les associations doivent informer le greffe des associations ET le centre de formalités des entreprises (CFE).

📌 **Spécifiquement pour la modification des statuts**, le lien suivant peut-être affiché : 
**[https://www.service-public.fr/particuliers/vosdroits/R37933](https://www.service-public.fr/particuliers/vosdroits/R37933){:target="_blank"}{:.fr-link}**

<br>

{:.fr-h5}
### Pour la modification du code APE : une procédure spécifique

À ce jour, pour les entreprises comme pour les associations, la demande de changement du code APE se fait au travers d'une démarche spécifique, détaillée dans [cette fiche pratique de l'Insee](https://www.insee.fr/fr/information/2015441#titre-bloc-3){:target="_blank"} et en remplissant [un formulaire de l'Insee](https://www.insee.fr/fr/information/6435934){:target="_blank"}.

📌 **Spécifiquement pour la modification du code APE**, vous pouvez donc afficher le lien suivant : 
**[https://www.insee.fr/fr/information/6435934](https://www.insee.fr/fr/information/6435934){:target="_blank"}{:.fr-link}**
<br>

-----


[Catalogue API Entreprise](https://entreprise.api.gouv.fr/catalogue?Endpoint%5Bquery%5D=diffusible){:.fr-btn .fr-btn--secondary fr-btn--icon-right fr-icon-arrow-right-fill}

