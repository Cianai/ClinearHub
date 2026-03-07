---
name: workspace-provisioning
description: |
  Programmatic provisioning of pre-configured monday.com workspaces from versioned JSON
  configs for Cognito client accelerators. Use when discussing client onboarding workspace
  setup, industry accelerator templates, monday.com board provisioning, workspace cloning,
  or workspace validation. Triggers for /provision-workspace, /clone-workspace, /validate-workspace,
  or questions about Cognito's "Build for, then with" methodology and client workspace delivery.
  Requires monday.com MCP connector (OAuth).
---

# Workspace Provisioning

Programmatic provisioning of pre-configured monday.com workspaces from versioned JSON accelerator configs. Part of Cognito Management Consultants' "Build for, then with" methodology — clients receive a fully structured monday.com workspace tailored to their industry vertical (Construction, Manufacturing, Professional Services) on day one of engagement.

## Architecture

```
Accelerator Config (JSON)          monday.com Workspace
references/                        ┌─────────────────────┐
├── construction-accelerator.json  │  Boards              │
├── manufacturing-accelerator.json │  ├── Board A         │
└── professional-services-         │  │   ├── Columns     │
    accelerator.json               │  │   ├── Groups      │
                                   │  │   └── Relations   │
  /provision-workspace ──────────► │  ├── Board B         │
                                   │  │   ├── Columns     │
  Pass 1: create_board (all)       │  │   ├── Groups      │
  Pass 2: create_column (all)      │  │   └── Relations   │
  Pass 3: create_group (all)       │  ├── ...             │
  Pass 4: board_relation (wiring)  │  │                   │
  Pass 5: create_dashboard +       │  Dashboard           │
          create_widget (widgets)  │  ├── BATTERY widget  │
                                   │  ├── NUMBER widget   │
  /validate-workspace ◄──────────► │  └── CHART widget    │
                                   │                      │
                                   │  Manual follow-up:   │
                                   │  - Automations       │
                                   │  - AI Blocks         │
                                   │  - Customer Portal   │
                                   └─────────────────────┘
```

## Methodology: "Build for, then with"

Cognito delivers client engagements in two phases:

1. **Build for** — Cognito provisions the workspace using an industry accelerator config. The client receives a working system with boards, columns, groups, and relations pre-configured. No blank-canvas onboarding.
2. **Build with** — Cognito works alongside the client to customize automations, dashboards, AI Blocks, views, and integrations to their specific processes. This phase requires the monday.com UI and cannot be fully automated.

The accelerator configs encode the "build for" phase as versioned, repeatable JSON. Each vertical captures industry best practices distilled from Cognito's consulting engagements.

## Hybrid Approach: Programmatic + Manual

**Programmatic (via MCP):**
- Board creation (`create_board` mutation)
- Column creation (`create_column` mutation — text, numbers, date, status, dropdown, long_text, link, email, phone, tags)
- Group creation (`create_group` mutation)
- Board relation columns (`create_column` with `board_relation` type, wiring boards together)
- Dashboard creation (`create_dashboard` mutation — `kind` must be uppercase: `PRIVATE` or `PUBLIC`)
- Widget creation (`create_widget` mutation — types: `BATTERY`, `NUMBER`, `CHART`, `CALENDAR`, `GANTT`)

**Manual (requires monday.com UI):**
- Automations — status change notifications, date reminders, assignment rules
- AI Blocks — intelligent column formulas, lead scoring, content generation
- Customer Portal — client-facing views with restricted access
- Campaigns — email sequences tied to board segments
- Views — Kanban, Timeline, Chart, Calendar (board views are UI-configured)
- Integrations — Gmail, Google Calendar, Slack, Stripe connections

## Provisioning Order

Order matters because later steps depend on earlier outputs:

1. **Boards first** — All boards created in a single pass. Each `create_board` returns a board ID needed for subsequent steps.
2. **Columns second** — Columns added to each board by ID. Standard column types: `text`, `numbers`, `date`, `status`, `dropdown`, `long_text`, `link`, `email`, `phone`, `tags`.
3. **Groups third** — Named groups replace the default "New Group" on each board. Groups define workflow stages and organizational categories.
4. **Board relations fourth** — `board_relation` columns require both the source and target board IDs, so all boards must exist first. These create the cross-board links that tie the workspace together.
5. **Dashboard + widgets fifth** — `create_dashboard` with all board IDs, then `create_widget` calls to populate it. Widget types: `BATTERY` (status progress), `NUMBER` (counters), `CHART` (pie/bar), `CALENDAR`, `GANTT`.

## MCP Tool

All provisioning uses `all_monday_api` with raw GraphQL mutations. There are no dedicated `create_board` or `create_column` MCP tools — everything goes through the general-purpose GraphQL endpoint.

### Key Mutations

**Create board:**
```graphql
mutation { create_board(board_name: "Projects", board_kind: private) { id } }
```

**Create column:**
```graphql
mutation { create_column(board_id: 12345, title: "Project Value", column_type: numbers) { id } }
```

**Create group:**
```graphql
mutation { create_group(board_id: 12345, group_name: "Active Projects") { id } }
```

**Create board relation:**
```graphql
mutation { create_column(board_id: 12345, title: "Related Diary Entries", column_type: board_relation, defaults: "{\"boardIds\":[67890]}") { id } }
```

**Create dashboard (kind MUST be uppercase):**
```graphql
mutation { create_dashboard(workspace_id: 5939270, name: "Overview", kind: PRIVATE, board_ids: [12345, 67890]) { id } }
```

**Create widget (use GraphQL variables for settings JSON):**
```graphql
mutation CreateWidget($settings: JSON!) {
  create_widget(parent: {kind: DASHBOARD, id: "DASH_ID"}, kind: BATTERY, name: "Progress", settings: $settings) { id }
}
# Variables: {"settings": {"battery_data": {"status_column_ids_per_board": {"12345": ["status"]}}}}
```

Widget settings by type:
- `BATTERY`: `{"battery_data": {"status_column_ids_per_board": {"BOARD_ID": ["status_col_id"]}}}`
- `NUMBER`: `{"counter_data": {"calculation_type": "count", "column_ids_per_board": {"BOARD_ID": []}, "counter_type": "sum"}}`
- `CHART`: `{"graph_type": "pie", "x_axis_columns": {"BOARD_ID": ["col_id"]}, "y_axis_columns": {"BOARD_ID": ["col_id"]}}`

**Delete dashboard (returns boolean, no selection set):**
```graphql
mutation { delete_dashboard(id: "DASH_ID") }
```

**Duplicate board (for /clone-workspace):**
```graphql
mutation { duplicate_board(board_id: 12345, duplicate_type: duplicate_board_with_structure) { board { id } } }
```

### PoC Validation Results

| Operation | Status | Notes |
|-----------|--------|-------|
| `create_board` | Works | Returns board ID, `board_kind`: `public`, `private`, `share` |
| `create_column` (text) | Works | Standard text column |
| `create_column` (numbers) | Works | Numeric values, currency formatting in UI |
| `create_column` (date) | Works | Date picker |
| `create_column` (status) | Works | Status labels configured in UI post-creation |
| `create_column` (dropdown) | Works | Dropdown values configured in UI post-creation |
| `create_column` (long_text) | Works | Rich text area |
| `create_column` (link) | Works | URL field |
| `create_column` (email) | Works | Email field |
| `create_column` (phone) | Works | Phone field |
| `create_column` (tags) | Works | Freeform tags |
| `create_column` (board_relation) | Works | Cross-board linking with `defaults` JSON |
| `create_group` | Works | Named group, appears in board |
| `create_dashboard` | Works | `kind` MUST be uppercase (`PRIVATE`/`PUBLIC`) — lowercase causes internal server error |
| `create_widget` (BATTERY) | Works | Status progress bar — needs `status_column_ids_per_board` |
| `create_widget` (NUMBER) | Works | Counter — needs `counter_data` with `calculation_type`, `counter_type: "sum"` |
| `create_widget` (CHART) | Works | Pie/bar chart — needs `graph_type`, `x_axis_columns`, `y_axis_columns` |
| `delete_dashboard` | Works | Returns boolean — no selection set, uses `id` not `dashboard_id` |
| `duplicate_board` | Works | Duplicates structure without items |

## Config File Format

Accelerator configs live in `references/` as versioned JSON files. Each config defines a complete workspace for an industry vertical.

```json
{
  "name": "Vertical Accelerator",
  "version": "1.0.0",
  "vertical": "vertical-slug",
  "boards": [
    {
      "name": "Board Name",
      "kind": "private",
      "columns": [
        { "title": "Column Title", "type": "numbers" },
        { "title": "Status Column", "type": "status" },
        { "title": "Description", "type": "long_text" }
      ],
      "groups": [
        { "name": "Group One" },
        { "name": "Group Two" }
      ]
    }
  ],
  "relations": [
    {
      "from": "Board A",
      "to": "Board B",
      "title": "Related Items"
    }
  ],
  "manualSteps": [
    "Create dashboard: Overview Dashboard",
    "Set up automations: status change notifications",
    "Configure AI Blocks: lead scoring formula"
  ]
}
```

**Field reference:**
- `name` — Human-readable accelerator name
- `version` — Semantic version for config evolution tracking
- `vertical` — Slug matching the filename prefix (e.g., `construction`, `manufacturing`, `professional-services`)
- `boards[].name` — Board display name in monday.com
- `boards[].kind` — Board visibility: `private` (team only), `public` (workspace), `share` (external guests)
- `boards[].columns[].title` — Column header text
- `boards[].columns[].type` — monday.com column type ID (see PoC validation table)
- `boards[].groups[].name` — Group name (workflow stage or category)
- `relations[].from` / `relations[].to` — Board names (resolved to IDs during provisioning)
- `relations[].title` — Label for the board_relation column
- `manualSteps[]` — Checklist of post-provisioning UI tasks for the "build with" phase

## Available Accelerators

| Vertical | Config | Boards | Focus |
|----------|--------|--------|-------|
| Construction | `construction-accelerator.json` | 5 | Project tracking, site diary, snagging, safety, tenders |
| Manufacturing | `manufacturing-accelerator.json` | 5 | Production planning, QC, inventory, suppliers, dispatch |
| Professional Services | `professional-services-accelerator.json` | 3 | Client projects, time tracking, deliverables |

## Actions

### /provision-workspace — Provision a New Workspace

Create a fully structured monday.com workspace from an accelerator config.

1. Ask for: **client name**, **industry vertical** (construction / manufacturing / professional-services)
2. Read the corresponding accelerator config from `references/{vertical}-accelerator.json`
3. Confirm the provisioning plan with the user:
   - List boards to create, column counts, group counts, relation count
   - Estimate: "This will make ~N API calls"
   - List manual steps that will be needed after provisioning
4. **Pass 1 — Create boards:**
   - For each board in config: `all_monday_api` with `create_board` mutation
   - Store the returned board ID mapped to the board name
   - Prefix each board name with the client name: `"{Client} - {Board Name}"`
5. **Pass 2 — Create columns:**
   - For each board, iterate through its columns
   - `all_monday_api` with `create_column` mutation using the stored board ID
   - Log any failures (continue on error — don't abort entire provisioning)
6. **Pass 3 — Create groups:**
   - For each board, iterate through its groups
   - `all_monday_api` with `create_group` mutation using the stored board ID
   - Delete the default "New Group" if all custom groups created successfully
7. **Pass 4 — Wire board relations:**
   - For each relation in config, resolve `from` and `to` board names to stored IDs
   - `all_monday_api` with `create_column` mutation using `board_relation` type and `defaults` JSON
8. **Pass 5 — Create dashboard + widgets:**
   - `all_monday_api` with `create_dashboard` mutation: all board IDs, `kind: PRIVATE`, workspace ID
   - Store the returned dashboard ID
   - For each board, create a BATTERY widget (status progress) pointing at the board's primary status column
   - Optionally create NUMBER widgets (item counts) and CHART widgets (status breakdown)
   - Use GraphQL variables for widget `settings` JSON (avoids escaping issues)
9. Present provisioning summary:
   - Boards created (name + ID)
   - Columns created per board
   - Groups created per board
   - Relations wired
   - Dashboard + widget count
   - Any failures encountered
10. Present the manual steps checklist from the config
11. Offer to create a Linear issue (Cognito project) tracking the "build with" phase

### /clone-workspace — Clone from Template Board

Alternative provisioning path when a template board already exists in monday.com.

1. Ask for: **client name**, **source board ID** (or board name to look up)
2. If board name given: `all_monday_api` query to find the board ID
3. Confirm the clone plan with the user
4. `all_monday_api` with `duplicate_board` mutation:
   ```graphql
   mutation {
     duplicate_board(
       board_id: {source_id},
       duplicate_type: duplicate_board_with_structure,
       board_name: "{Client} - {Board Name}"
     ) {
       board { id name }
     }
   }
   ```
5. `duplicate_type` options:
   - `duplicate_board_with_structure` — columns + groups, no items (default for client provisioning)
   - `duplicate_board_with_pulses` — columns + groups + items (for demo workspaces with sample data)
6. Present the cloned board details
7. Note: cloning copies a single board — for multi-board accelerators, use `/provision-workspace` instead

### /validate-workspace — Validate Against Config

Check that a provisioned workspace matches the expected accelerator config.

1. Ask for: **client name** (or board name prefix), **industry vertical**
2. Read the corresponding accelerator config from `references/{vertical}-accelerator.json`
3. For each board in config:
   - `all_monday_api` query to find the board by name pattern: `"{Client} - {Board Name}"`
   - If board not found: flag as **MISSING**
   - If board found: fetch columns and groups via `get_board_schema` or `all_monday_api`
4. For each expected column on each board:
   - Check if a column with matching title exists
   - Check if the column type matches
   - Flag any **MISSING** or **TYPE MISMATCH** columns
5. For each expected group on each board:
   - Check if a group with matching name exists
   - Flag any **MISSING** groups
6. For each expected relation:
   - Check if a `board_relation` column exists on the `from` board linking to the `to` board
   - Flag any **MISSING** relations
7. Present validation report:
   ```
   Workspace Validation: {Client} ({Vertical})
   Config version: {version}

   Board: {Client} - Projects ............ PASS
     Columns: 8/8 ........................ PASS
     Groups: 3/3 ......................... PASS

   Board: {Client} - Site Diary .......... PASS
     Columns: 6/7 ........................ WARN (missing: Weather)
     Groups: 2/2 ......................... PASS

   Relations: 3/3 ........................ PASS

   Overall: 1 warning, 0 errors
   ```
8. If issues found, offer to fix them by running the missing provisioning steps

## Error Handling

- **Rate limiting:** monday.com API has rate limits. If a 429 is returned, wait and retry. Space mutations 200ms apart for large workspaces.
- **Partial failure:** Log failures per-step and continue. Present a summary of what succeeded and what needs manual retry.
- **Board name collision:** If a board with the same name already exists, warn the user and ask whether to skip, rename, or overwrite.
- **Column type unsupported:** If a column type in the config is not supported by the API, log it as a manual step instead of failing.

## Cross-Skill References

- **crm-management** — Provisioned workspaces may include CRM-adjacent boards (e.g., client projects, quotes). CRM boards are managed separately via crm-management skill.
- **business-development** — Client onboarding starts with a signed deal in the CRM pipeline, which triggers workspace provisioning.
- **customer-ops** — Post-provisioning support tickets are tracked via customer-ops skill.
- **small-team-finance** — Quotes & Invoices boards in accelerators follow the same schema as the CRM Quotes & Invoices board.
- **notion-hub** — Client workspace configs can be documented in Notion for internal reference.
