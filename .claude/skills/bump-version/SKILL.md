---
name: bump-version
description: Bump an API endpoint fiche from one version to the next (e.g. v3 → v4) in the admin_api_entreprise catalog. Use when the user mentions "bump version", "nouvelle version", "v4", "ajouter une fiche v4", or needs to create a new versioned endpoint entry while keeping the previous one as legacy. Applies to both API Entreprise and API Particulier endpoint YAML files in config/endpoints/.
---

# Bump Version

Create a new version of an API endpoint fiche while preserving the previous version as legacy.

## Workflow

1. **Identify the source fiche** — Read the current YAML file in `config/endpoints/api_entreprise/` or `config/endpoints/api_particulier/`.

2. **Understand the changes** — Ask the user for a PR or issue URL as référence (e.g. siade PR, Linear issue). Read it to understand what the new version adds/modifies. Reference it in the commit message.

3. **Apply the pattern** — See [references/pattern.md](references/pattern.md) for the full before/after structure. In short:
   - The main entry keeps its `uid`, gets the bumped `path` (e.g. `/vN/...`), a new `historique`, `new_version: true`, and YAML anchors on all shared fields.
   - A new legacy entry is added with `uid` suffixed `_vN-1`, `new_endpoint_uids` pointing to main, `position + 1`, and YAML aliases for shared fields.

4. **Validate** — Run the relevant endpoint spec:
   ```bash
   bundle exec rspec spec/models/api_entreprise/endpoint_spec.rb
   bundle exec rspec spec/models/api_particulier/endpoint_spec.rb
   ```

5. **Verify loading** — Confirm both entries load:
   ```bash
   bundle exec rails runner "
     klass = APIParticulier::Endpoint  # or APIEntreprise::Endpoint
     klass.all.select { |e| e.uid.include?('provider') }.each { |e| puts e.uid }
   "
   ```

## Important

- Always add `new_version: true` on the main (vN) entry to tag it as a new version (see commit `6db066885a`).
- Never change the main `uid` — it ensures continuity for consumers.
- Always preserve the original `historique` on the legacy entry.
- Anchor naming convention: short provider/resource prefix (e.g. `&cnous_`, `&insee_etablissements_`).
- Reference commit: `65f338cc47ea00518687842714a65cf4aadf81bb`.
