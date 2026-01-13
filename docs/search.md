# Recherche dans le catalogue

La recherche dans le catalogue des endpoints (API Entreprise et API Particulier) est une recherche client-side implémentée avec Stimulus.

## Fonctionnement général

La recherche se déclenche à partir de 3 caractères saisis. Elle est insensible à la casse et aux accents.

## Sources de correspondance

Un endpoint est visible si **au moins une** des trois sources matche.

### 1. Texte searchable (recherche exacte)

Concaténation de : titre + description + noms des fournisseurs.

**La recherche est une correspondance de sous-chaîne exacte** (espaces compris).

| Recherche | Texte | Match ? |
|-----------|-------|---------|
| `quotient familial` | "...quotient familial CAF..." | ✅ Oui |
| `familial quotient` | "...quotient familial CAF..." | ❌ Non (ordre différent) |
| `quot fam` | "...quotient familial CAF..." | ❌ Non (pas de sous-chaîne "quot fam") |
| `insee` | "...données INSEE..." | ✅ Oui |

### 2. Mots-clés (tous les mots doivent matcher)

Keywords définis dans le YAML : `["quotient", "famille", "CAF", "adresse"]`

**Chaque mot** de la recherche doit être contenu dans **au moins un** keyword. Si un seul mot ne matche rien → pas de correspondance.

| Recherche | Mots extraits | Match ? | Explication |
|-----------|---------------|---------|-------------|
| `quotient` | [quotient] | ✅ Oui | "quotient" ⊂ keyword "quotient" |
| `quo` | [quo] | ✅ Oui | "quo" ⊂ keyword "quotient" |
| `caf adresse` | [caf, adresse] | ✅ Oui | "caf" ⊂ "CAF", "adresse" ⊂ "adresse" |
| `caf siret` | [caf, siret] | ❌ Non | "siret" ne matche aucun keyword |
| `quotient familial` | [quotient, familial] | ❌ Non | "familial" ≠ "famille" (pas de substring) |
| `fam` | [fam] | ✅ Oui | "fam" ⊂ "famille" |

### 3. Clés d'attributs (un seul mot suffit)

Clés extraites du schéma OpenAPI :
```
[
  { key: "adresse", display: "Adresse" },
  { key: "adresse->code_postal", display: "Adresse → Code postal" },
  { key: "adresse->commune", display: "Adresse → Commune" },
  { key: "allocataires", display: "Allocataires" }
]
```

**Un seul mot** de la recherche suffit pour matcher. Retourne toutes les clés qui matchent au moins un mot.

| Recherche | Mots extraits | Match ? | Clés affichées |
|-----------|---------------|---------|----------------|
| `adresse` | [adresse] | ✅ Oui | Adresse, Adresse → Code postal, Adresse → Commune |
| `postal` | [postal] | ✅ Oui | Adresse → Code postal |
| `code postal` | [code, postal] | ✅ Oui | Adresse → Code postal (matche "code" et "postal") |
| `adresse siret` | [adresse, siret] | ✅ Oui | Adresse, Adresse → Code postal, Adresse → Commune |
| `xyz` | [xyz] | ❌ Non | Aucune clé ne contient "xyz" |

## Différences clés entre keywords et attributs

| Aspect | Keywords | Clés d'attributs |
|--------|----------|------------------|
| Logique multi-mots | **ET** (tous doivent matcher) | **OU** (un seul suffit) |
| Conséquence | Plus restrictif | Plus permissif |
| Cas d'usage | Recherche intentionnelle | Découverte de données |

## Mise en surbrillance

Le titre et la description affichent le texte recherché en surbrillance. La surbrillance utilise la **chaîne complète** (pas les mots séparés).

| Recherche | Titre original | Résultat |
|-----------|----------------|----------|
| `quotient` | "Quotient familial" | "**Quotient** familial" |
| `quot fam` | "Quotient familial" | "Quotient familial" (pas de highlight, pas de match exact) |

## URL

Le paramètre `?s=query` est synchronisé pour permettre le partage de liens.

## Fichiers concernés

- `app/assets/javascripts/controllers/search_catalogue_controller.js` : logique de recherche
- `app/helpers/endpoint_helper.rb` : extraction des clés d'attributs
- `app/views/*/endpoints/_endpoint.html.erb` : data attributes et zones d'affichage
