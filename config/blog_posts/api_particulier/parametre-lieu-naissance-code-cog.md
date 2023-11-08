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
- Le parcours 1 nécessite peu de développement informatique, l'expérience usager est correcte, même si elle fait reposer sur l'usager la contrainte de retrouver son code COG ; 
- Le parcours 2 est d'un niveau d'intégration plus complexe, l'expérience usager est privéligiée.

### Parcours 1 : l'usager retrouve son code COG grâce à sa carte vitale



### Parcours 2 : l'usager complète simplement son lieu de naissance