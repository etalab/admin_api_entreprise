Mercredi 14 février 2025 - Publication

# Liens capitalistiques d'une entreprise

## Comprendre les informations des liasses fiscales

Les **liasses fiscales** permettent d’extraire des informations capitalistiques clés sur une entreprise. Elles contiennent des données déclarées aux impôts par les sociétés soumises à l'impôt sur les sociétés (IS) et offrent une **vision précise de la répartition du capital et des participations**.

Ces informations sont **accessibles via l'API Liasses Fiscales** du portail [API Entreprise](https://entreprise.api.gouv.fr/catalogue/dgfip/liasses_fiscales){:target="_blank"}, permettant aux administrations et organismes habilités de **valoriser ces données** pour divers cas d’usage métier.

{:.fr-highlight}
**ℹ️ La structure capitalistique d’une entreprise peut être précieuse** pour analyser la gouvernance, identifier les liens entre sociétés et évaluer les risques associés à certaines structures d’actionnariat.

---

## **Les informations clés des liasses fiscales** 📄

Les données capitalistiques sont principalement contenues dans deux déclarations fiscales :
- **2059-F** (*Structure du capital - Actionnaires*) → Permet d'identifier les **actionnaires**, aussi bien **personnes morales que personnes physiques**, et leur répartition dans le capital.
- **2059-G** (*Filiales et Participations*) → Permet d'identifier **les sociétés dans lesquelles l'entreprise détient une participation**.

### **Actionnaires : Qui détient l'entreprise ?**
L’imprimé **2059-F** contient les informations suivantes :
- **Actionnaires personnes morales** :
  - **SIREN de l’actionnaire** (code 2005724)
  - **Nom de l’actionnaire** (code 2005722)
  - **Forme juridique** (code 2008006)
  - **Pourcentage de détention** (code 2005726)
  - **Nombre de parts détenues** (code 2005725)
  - **Adresse** : numéro (2005727), voie (2005729), lieu-dit (2005730), code postal (2005731), ville (2005732), pays (2005733)

- **Actionnaires personnes physiques** :
  - **Nom de l’actionnaire** (code 2005734)
  - **Nom marital** (code 2005735)
  - **Date de naissance** (code 2005746)
  - **Pourcentage de détention** (code 2005738)
  - **Nombre de parts détenues** (code 2005737)
  - **Adresse** : numéro (2005739), voie (2005741), lieu-dit (2005742), code postal (2015508), ville (2015507), pays (2015509)

📌 **Cas d'usage** : Permet d’identifier **les actionnaires principaux**, repérer **les structures de contrôle**, et comprendre la **répartition du capital** entre entreprises et individus.

### **Participations : Dans quelles entreprises l’entreprise investit-elle ?**
L’imprimé **2059-G** liste les sociétés détenues avec :
- **SIREN de la filiale ou participation** (code 2005836)
- **Nom de la société détenue** (code 2005834)
- **Forme juridique** (code 2008007)
- **Pourcentage de détention** (code 2005844)
- **Pays d’implantation** (code 2005843)
- **Adresse** : numéro (2005837), voie (2005839), lieu-dit (2005840), code postal (2005841), ville (2005842), pays (2005843)

📌 **Cas d'usage** : Cartographier les **filiales et participations** d’une entreprise, analyser son **empreinte économique**, et repérer les **liens capitalistiques intra-groupes**.

---

## **Exploiter ces données avec l'API Liasses Fiscales**
L'[API Liasses Fiscales](https://entreprise.api.gouv.fr/catalogue/dgfip/liasses_fiscales){:target="_blank"} permet d’accéder à ces informations sous forme structurée.

Ci-dessous un exemple complet de l'extraction des informations en ruby en partant de la payload renvoyée par l'API Liasses fiscales

<script src="https://gist.github.com/skelz0r/220c7eb6f861d54ca673d352e2066b89.js"></script>

---

## **Quels usages métier ?**
Ces données peuvent être exploitées pour :
- **Cartographier les réseaux d’entreprises** (identification des structures de contrôle).
- **Analyser la gouvernance et la répartition du capital** (investisseurs, holdings…).
- **Faire des contrôles réglementaires et fiscaux** (vérification des bénéficiaires réels, lutte contre la fraude).
- **Compléter des analyses économiques et financières** en croisant avec d'autres API (ex : [API INSEE](https://entreprise.api.gouv.fr/catalogue/insee/unites_legales){:target="_blank"}, [API RNE](https://entreprise.api.gouv.fr/catalogue/rne/entreprises){:target="_blank"}).

---

### **Données déclaratives : attention à la qualité des informations**
Il est important de noter que les **adresses renseignées dans les liasses fiscales sont déclaratives**, ce qui peut engendrer des **erreurs ou incohérences** :
- Certaines entreprises **ne renseignent pas toutes les informations**, laissant des champs vides.
- Le **pays peut être inscrit dans la voie** par erreur, ou l’adresse peut être **partiellement renseignée**.
- Les **personnes physiques peuvent omettre certains détails** (ex : absence de numéro de rue, informations erronées sur la ville).

Ainsi, lors de l’exploitation des données d’adresse, il est recommandé de **croiser avec d’autres sources (ex : API INSEE, RNE) et de prévoir des contrôles de cohérence**.

---

## **Conclusion**
L’intégration des données des liasses fiscales via API Entreprise permet aux **administrations et acteurs habilités** d’exploiter **une information fiable et déclarative** pour mieux comprendre **les structures capitalistiques et les liens entre entreprises**.

💡 **Envie d’exploiter ces données ?** Découvrez l'[API Liasses Fiscales](https://entreprise.api.gouv.fr/catalogue/dgfip/liasses_fiscales){:target="_blank"} et testez-la dès maintenant !

---
[Toutes les API du catalogue API Entreprise](https://entreprise.api.gouv.fr/catalogue){:.fr-btn .fr-btn--secondary fr-btn--icon-right fr-icon-arrow-right-fill}
