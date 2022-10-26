Mercredi 26 octobre 2022 - Publication

# Obtenez le N°TVA intracommunautaire français d'une entreprise à partir de son SIREN

![Image de présentation de l'article sur le numéro de TVA intracommunautaire](<%= image_path('api_entreprise/blog/num-tva-intra.png') %>)

{:.fr-highlight}
**Qu'est qu'un numéro de TVA intracommunautaire ?**
Le numéro de TVA intracommunautaire est un identifiant unique attribué aux entreprises concernées par la TVA et domiciliées au sein de l'Union européenne. Le numéro est délivré par l'administration fiscale du pays de domiciliation de l'entreprise au moment de son immatriculation ou de sa déclaration d'activité. La structure du numéro est différente selon les pays de l'UE.
*Pour en savoir plus :* [entreprendre.service-public.fr](https://entreprendre.service-public.fr/vosdroits/F23570){:target="_blank"} et [economie.gouv.fr](https://www.economie.gouv.fr/entreprises/activite-entreprise-numero-tva-intracommunautaire){:target="_blank"}.

<br>

## Pré-remplir le n°TVA français à partir d'un SIREN

Le catalogue de l'API Entreprise s'est enrichi d'une nouvelle [API N°TVA intracommunautaire français](<%= endpoint_path(uid: 'commission_europeenne/numero_tva') %>). Cette API vous permet de retrouver le numéro de TVA intracommunautaire **français** à partir d'un numéro de SIREN. En intégrant cette API, vous pourrez donc pré-remplir automatiquement le numéro de TVA français d'une entreprise dans vos démarches à destination des entreprises inscrites au répertoire Sirene.

⚠️ **Exceptions :** Une unité légale répertoriée en France peut avoir un numéro de TVA au format d'un autre pays européen si son siège était historiquement à l’étranger et avait commencé à déclarer ses impôts dans ce pays. Dans ce cas, l’unité légale garde le numéro de TVA qui lui a été délivré par ce pays européen. Ce numéro de TVA étranger n’est pas délivré par cette API.


## Une information certifiée en V.3

Contrairement à l'information auparavant délivrée en version 2, le numéro de TVA intracomunautaire délivré par cette API est **certifié car vérifié auprès du [site officiel de la Commission Européenne](https://ec.europa.eu/taxation_customs/vies/#/vat-validation){:target="_blank"}**.

Dans la majorité des cas, il est assez simple de déduire le numéro de TVA à partir du numéro de SIREN. Il existe en effet une règle de calcul (détaillée dans cet [article Wikipédia](https://fr.wikipedia.org/wiki/Code_Insee#Num%C3%A9ro_de_TVA_intracommunautaire)) ; de fait, la structure d'un numéro de TVA français est toujours constituée du code FR et de 11 chiffres (une clé informatique déductible de 2 chiffres suivie du numéro SIREN de l'entreprise). 
En revanche, comme expliqué précédemment, toutes les entreprises inscrites au répertoire Sirene et assujetties à la TVA n'ont pas forcément un numéro français. C'est pourquoi, il est indispensable de **vérifier systématiquement** le numéro calculé.

Lors de la conception de la V.3, API Entreprise a décidé de ne plus délivrer le numéro de TVA intracommunautaire par le biais de l'API de l'Insee car cette donnée ne provient pas de ce fournisseur. De plus, en version 2, le numéro de TVA délivré n'était pas vérifié auprès du service VIES de la Commission européenne.

## Il est impossible de déduire un numéro de TVA étranger à partir d'un SIREN

L'API Entreprise ne peut pas délivrer le numéro de TVA d'une entreprise si celui-ci est d'un format différent du format français _FR + 11 chiffres_.

{:.fr-highlight.fr-highlight--caution}
Cette impossibilité est également valable pour tous les sites tiers : **aucun site n'est en mesure de déduire un numéro de TVA étranger avec un SIREN**. 

⚠️ Dans le cas où l’API Entreprise ne délivre pas de numéro de TVA pour un SIREN alors que vous l'avez obtenu par un site tiers, il est fort probable que ce numéro de TVA soit invalide. 
Si vous avez un doute, vous pouvez vérifier vous-même le numéro de TVA à partir du [service VIES](https://ec.europa.eu/taxation_customs/vies/#/vat-validation){:target="_blank"}.

## Cas d'usages

API Entreprise a pour mission de simplifier les démarches des entreprises, en rendant accessibles leurs données administratives aux acteurs publics. 

Dans le cadre des candidatures aux marchés publics, le numéro de TVA intracommunautaire est demandé aux entreprises étrangères en tant qu'identifiant unique. *Ce cas d'usage n'est pas couvert par l'API Entreprise* car l'API délivre des informations à partir d'un numéro de SIREN ou de SIRET.

Collectivités, administrations centrales, **quelles sont les démarches où vous demandez à une entreprise inscrite au répertoire Sirene de vous fournir son numéro de TVA français ?**

[Partagez-nous vos cas d'usage](https://form.typeform.com/to/MXv9b011){:.fr-btn .fr-btn--secondary}{:target="_blank"}

