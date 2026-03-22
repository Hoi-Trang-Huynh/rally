---
name: slang
description: Regenerate i18n translation code from JSON files
---

After modifying any translation JSON files in `lib/i18n/`, regenerate the Dart code:

```bash
dart run slang
```

This updates generated files in `lib/i18n/generated/`. Always regenerate after adding or changing translation keys.
