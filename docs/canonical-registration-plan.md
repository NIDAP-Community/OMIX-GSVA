# Canonical adapter registration plan

This file is a follow-up plan, not a change to canonical OMIX and not release
authorization.

After this deployment repository is accepted, open a separate OMIX pull
request that:

1. adds the following entry to
   `modules/OMIX-GSVA/module.yml` `deployment_adapters`:

   ```yaml
   - platform: Code Ocean
     repository: https://github.com/NIDAP-Community/OMIX-GSVA
   ```

2. adds a supplementary Code Ocean deployment link to
   `modules/OMIX-GSVA/README.md`;
3. runs `Rscript tests/test-monorepo-layout.R`; and
4. does not change GSVA scientific behavior, module version, interface
   version, or release status.

Do not make the registration claim until the repository location and adapter
boundary have been reviewed. Code Ocean validation and release remain separate
records after registration.
