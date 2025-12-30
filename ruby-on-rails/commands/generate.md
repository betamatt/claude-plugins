---
name: generate
description: Smart Rails generator wrapper with production-ready defaults
argument-hint: <generator> <name> [attributes...]
allowed-tools: ["Read", "Write", "Edit", "Bash", "Grep", "Glob"]
---

# Rails Generate Command

Execute Rails generators with production-best-practice defaults and guidance.

## Usage

```
/rails:generate <generator> <name> [attributes...]
```

## Examples

```
/rails:generate model User email:string name:string
/rails:generate controller Orders index show create
/rails:generate migration AddStatusToOrders status:string:index
/rails:generate scaffold Product name:string price:decimal
```

## Generator Types

### Model Generator
```bash
bin/rails generate model <Name> [field:type...]
```

Apply these defaults:
- Add `null: false` for required fields in migration
- Add indexes for foreign keys automatically
- Suggest appropriate validations

### Controller Generator
```bash
bin/rails generate controller <Name> [actions...]
```

Apply these patterns:
- Use resourceful routes when appropriate
- Include strong parameters boilerplate
- Set up proper before_actions

### Migration Generator
```bash
bin/rails generate migration <MigrationName> [field:type...]
```

Production patterns:
- Use `algorithm: :concurrently` for index additions
- Add `disable_ddl_transaction!` when needed
- Include rollback safety

### Scaffold Generator
```bash
bin/rails generate scaffold <Name> [field:type...]
```

Enhance with:
- Turbo Stream responses
- Proper flash messages
- API-ready JSON responses

## Process

1. Parse the generator command and arguments
2. Run the Rails generator
3. Review generated files
4. Apply production enhancements:
   - Add missing indexes for foreign keys
   - Add `null: false` constraints for required fields
   - Enhance controller with proper error handling
   - Add Turbo Stream support if appropriate
5. Show what was generated and any enhancements made

## Important

- Always check if database migration is needed
- Verify model validations match database constraints
- Ensure routes are properly configured
- For models with associations, suggest the inverse association

## Output

After generation:
1. List all files created/modified
2. Show any enhancements applied
3. Suggest next steps (run migration, add associations, write tests)
