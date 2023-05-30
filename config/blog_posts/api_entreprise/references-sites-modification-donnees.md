Mardi 30 mai 2023 - Publication
<p class="fr-badge fr-badge--green-menthe">💡 Bonne pratique</p>

# Les liens de mise à jour des données sources
![Image de présentation de l'article sur le numéro de TVA intracommunautaire](<%= image_path('api_entreprise/blog/references-sites-modification-donnees.png') %>)

{:.fr-highlight}
> **La mise à jour des données, une situation fréquente pour vos usagers**
> API Entreprise met à disposition des API permettant d'interroger les répertoires principaux des données des entreprises et des associations, tels que le répertoire Sirene ou le RNA. 
> Il peut arriver que ces répertoires ne soient pas toujours représentatifs de la dernière situation de l'entreprise ou de l'association. Dans ce cas, le pré-remplissage par le biais de l'API Entreprise peut être erroné et l'usager aura alors le souhait de modifier ces informations.

<br>

{:.fr-h3}
## Inciter à la mise à jour des référentiels sources 

L'utilisation des données disponibles dans l'API Entreprise facilite les démarches de vos usagers dans la plupart des cas. Cette simplification doit toutefois être accompagnée d'**un service résilient, en mesure de prendre en compte les situations qui ne seraient pas optimales**. Parmi ces situations, la mise à jour d'une donnée erronnée ou obsolète est un service qu'il faut proposer à vos usagers.

**Cette mise à jour peut être faite directement sur votre démarche en ligne, en permettant à vos usagers d'éditer le champ eronné**. Cette fonctionnalité leur permettra de terminer la démarche, en revanche, si l'usager réalise d'autres démarches, il aura besoin d'effectuer cette manipulation pour chacune d'entre elles car l'information corrigée ne sera pas transmise aux référentiels.

**C'est pourquoi, il peut être utile de proposer à vos usagers des liens vers les sites de référence pour mettre à jour leurs données.** Actuellement, API Entreprise ne vous recommande pas de permettre uniquement une modification des informations par ce biais car les délais de prise en compte dans les référentiels sont généralement de plusieurs semaines.

Pour résumer, l'interface idéale d'affichage d'une information serait la suivante : 
- Un champ pré-rempli avec les données de l'API Entreprise ;
- Un bouton ou un champ de saisie actif permettant à l'usager de rectifier l'information ;
- Un lien vers le site permettant de déclarer la modification au répertoire de référence.

<br>

{:.fr-h3}
## Ajouter des liens vers les sites permettant la modification

Les divers services en ligne à destination des entreprises et des associations sont en pleine refonte dans l'objectif de mettre à disposition un guichet unique où toutes les démarches pourront être réalisées. À ce jour, **tout n'est pas encore stabilisé et le parcours utilisateur pour modifier durablement les informations reste complexe**. En attendant la mise à disposition des guichets uniques, API Entreprise vous recommande déjà certains liens susceptibles d'aider vos usagers.

<br>

{:.fr-h5}
### Le portail e-procédures de l'Inpi recommandé pour les entreprises

📌 **À ce jour, 30 mai 2023, pour la mise à jour des données d'une entreprise**, API Entreprise vous recommande de communiquer le lien suivant à vos usagers : 
**[https://procedures.inpi.fr/?/](https://procedures.inpi.fr/?/){:target="_blank"}{:.fr-link}**.

Après un test du parcours utilisateur : 
- ce site semble le plus central ;
- il est le plus direct vers les démarches de modifications d'informations, même si, l'utilisateur devra tout de même naviguer sur différents sites dont le [guichet-entreprises.fr](https://account.guichet-entreprises.fr/session/new){:target="_blank"} ;
- il est recommandé par [Service-public.fr](https://www.service-public.fr/particuliers/vosdroits/R61572){:target="_blank"}.
<br>

{:.fr-highlight}
> **Qu'en est-il du site du guichet unique [formalites.entreprises.gouv.fr](https://formalites.entreprises.gouv.fr/){:target="_blank"} ?**
> Ce site, qui semble être destiné à remplacer la totalité des sites à destination des entreprises, reste à ce jour une page unique transférant l'usager vers le portail e-procédures de l'Inpi. Étant donné que le parcours actuel est long, nous ne recommandons pas d'afficher ce lien. Toutefois, il est fort probable que cette page devienne la référence ; nous publierons une actualité le moment venu.

<br>

{:.fr-h5}
## Mon compte asso, le site de référence pour les associations

Si le site Mon compte asso ne permet pas encore de modifier directement les informations de l'association, il recense en revanche la totalité des procédures :

📌 **Pour la majorité des déclarations**, nous vous recommandons d'indiquer le lien suivant : 
**[https://lecompteasso.associations.gouv.fr/declarer-un-changement-de-situation-de-mon-association/](https://lecompteasso.associations.gouv.fr/declarer-un-changement-de-situation-de-mon-association/){:target="_blank"}{:.fr-link}**.
Ce guide permettra à vos usagers de savoir auprès de qui les changements doivent être déclarés. En effet, pour certaines procédures, les associations doivent informer le greffe des associations ET le centre de formalités des entreprises (CFE).

📌 **Spécifiquement pour la modification des statuts**, le lien suivant peut-être affiché : 
**[https://www.service-public.fr/particuliers/vosdroits/R37933](https://www.service-public.fr/particuliers/vosdroits/R37933){:target="_blank"}{:.fr-link}**

<br>

{:.fr-h5}
### Une procédure spécifique pour la modification du code APE

À ce jour, pour les entreprises comme pour les associations, la demande de changement du code APE se fait au travers d'une démarche spécifique, détaillée dans [cette fiche pratique de l'Insee](https://www.insee.fr/fr/information/2015441#titre-bloc-3){:target="_blank"}. La modification se fait uniquement en remplissant [un formulaire de l'Insee](https://www.insee.fr/fr/information/6435934){:target="_blank"}.

📌 **Spécifiquement pour la modification du code APE**, vous pouvez donc afficher le lien suivant : 
**[https://www.insee.fr/fr/information/6435934](https://www.insee.fr/fr/information/6435934){:target="_blank"}{:.fr-link}**
<br>

-----


[Catalogue API Entreprise](https://entreprise.api.gouv.fr/catalogue?Endpoint%5Bquery%5D=diffusible){:.fr-btn .fr-btn--secondary fr-btn--icon-right fr-icon-arrow-right-fill}

