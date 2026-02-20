# Version Bump Pattern — Reference

Reference commit: `65f338cc47ea00518687842714a65cf4aadf81bb` (INSEE Sirene vN-1 → vN example).

## File locations

- API Entreprise: `config/endpoints/api_entreprise/`
- API Particulier: `config/endpoints/api_particulier/`

Each YAML file contains one or more endpoint entries (array of hashes).

## Before / After structure

### Before (single vN-1 entry)

```yaml
- uid: 'provider/resource'
  opening: protected
  old_endpoint_uids:
    - 'provider/vN-2/resource'
  path: '/vN-1/provider/resource/...'
  position: 400
  ping_url: 'https://...'
  perimeter:
    entity_type_description: |+
      ...
    geographical_scope_description: |+
      ...
    updating_rules_description: |+
      ...
  parameters_details:
    description: |+
      ...
  data:
    description: |+
      ...
  provider_uids:
    - 'provider'
  keywords: []
  call_id:
    - FranceConnect
  parameters:
    - FranceConnect
  faq:
    - q: Question
      a: Answer
  historique: |+
    ...
```

### After (vN entry + vN-1 legacy entry)

```yaml
# ── vN (main entry, keeps the original uid) ──
- uid: 'provider/resource'
  opening: protected
  new_version: true
  old_endpoint_uids:
    - 'provider/resource_vN-1'          # points to new legacy uid
  path: '/vN/provider/resource/...'     # bumped path
  position: 400
  ping_url: &provider_ping_url 'https://...'   # anchor
  historique: |+                                 # NEW historique for vN
    **Ce que change cette nouvelle version de l'API par rapport à la précédente :**
    <description of what changed>

    **Ce qui ne change pas :**
    <what stays the same>
  perimeter: &provider_perimeter
    entity_type_description: &provider_entity_type |+
      ...
    geographical_scope_description: &provider_geo |+
      ...
    updating_rules_description: &provider_updating |+
      ...
  parameters_details: &provider_parameters_details
    description: |+
      ...
  data: &provider_data
    description: |+
      ...
  provider_uids: &provider_provider_uids
    - 'provider'
  keywords: &provider_keywords []
  call_id: &provider_call_id
    - FranceConnect
  parameters: &provider_parameters
    - FranceConnect
  faq: &provider_faq
    - q: Question
      a: Answer

# ── vN-1 (legacy entry, new suffixed uid) ──
- uid: 'provider/resource_vN-1'
  opening: protected
  new_endpoint_uids:
    - 'provider/resource'               # points to vN
  old_endpoint_uids:
    - 'provider/vN-2/resource'          # preserved from original
  path: '/vN-1/provider/resource/...'   # unchanged
  position: 401                         # main position + 1
  ping_url: *provider_ping_url          # alias
  perimeter: *provider_perimeter
  parameters_details: *provider_parameters_details
  data: *provider_data
  provider_uids: *provider_provider_uids
  keywords: *provider_keywords
  call_id: *provider_call_id
  parameters: *provider_parameters
  faq: *provider_faq
  historique: |+                         # original vN-1 historique preserved
    ...
```

## Key rules

1. **new_version tag**: the vN entry MUST have `new_version: true` to flag it as a new version.
2. **uid stays**: the main uid does NOT change — continuity for existing consumers.
3. **old_endpoint_uids on vN**: always points to the `_vN-1` suffixed uid.
4. **new_endpoint_uids on vN-1**: always points back to the main uid.
5. **old_endpoint_uids on vN-1**: preserved from the original (e.g. vN-2 link).
6. **position**: vN-1 gets `position + 1` so it sorts after vN.
7. **YAML anchors** (`&name`): added on ALL shared fields in the vN entry.
8. **YAML aliases** (`*name`): used in the vN-1 entry for all shared fields.
9. **historique**: vN gets a new one; vN-1 keeps the original.
10. **path**: only the vN entry gets the bumped path.
11. **Anchor naming**: use a short prefix based on provider/resource (e.g. `&cnous_`, `&insee_etablissements_`).

## Validation

After editing, run:

```bash
bundle exec rspec spec/models/api_entreprise/endpoint_spec.rb   # for API Entreprise
bundle exec rspec spec/models/api_particulier/endpoint_spec.rb   # for API Particulier
```

Both endpoints must load without error.
