# Changelog

Notable changes to the `blankcut` CLI, newest first.

`blankcut upgrade --check` fetches this file and prints the entries newer than
the build you are running, so **this is how a developer or a coding agent finds
out a capability exists.** A feature that ships without a line here is a feature
nobody discovers. Keep entries short and phrased as what you can now *do*.

Format: one `## vX.Y.Z` heading per release, matching the git tag, and **nothing
else on that line** — put the date on its own line underneath. Entries under
`## Unreleased` roll into the next tag.

That constraint is load-bearing, not style. The parser that reads this file ships
inside every already-installed binary, and the one in v0.16.0 and earlier splits
the heading on its first `-` to drop a prerelease suffix — which, on a heading
like `## v0.16.0 — 2026-09-23`, lands inside the *date*. It then fails to parse
the version and announces **nothing** for that release. v0.15.0 and v0.16.0 were
both invisible this way until 2026-09-23. The parser now reads only the first
field of a heading, but the binaries already installed in the field never will,
so keep the heading bare regardless.

## Unreleased

## v0.27.1

*Released 2026-10-30.*

- **`blankcut scan` lists what only the running app has.** A finding the daily re-scan found that
  the last build doesn't have, usually a vulnerability published since that build, now shows its
  package, the version to upgrade to, its CVE ids and its fix-by date, instead of only a count. A
  finding in both is listed once, under the last build.

## v0.27.0

*Released 2026-10-28.*

- **`blankcut scan` shows a fix-by date for each package.** A critical or high finding gets one
  three days after the platform first sees it. A build that adds a finding still stops at once in
  block mode; one that was already in the running app ships until its date, then stops the next
  build if it is neither fixed nor waived. Past the date, `scan` says `OVERDUE since <date>`.

## v0.26.1

*Released 2026-10-28.*

- `blankcut validate` (and onboarding) now recognises an app whose `package.json`, `go.mod` or
  Python manifest sits beside its `Dockerfile` in a subfolder, such as `client/`, instead of only
  at the repository root. Such an app used to be held for manual review.

## v0.26.0

*Released 2026-10-28.*

- If you are removed from an organization, the CLI keys you hold for it stop working straight
  away, and the CLI says that is why. An owner can invite you back; then run `blankcut login`.
- Blank Cut admins: the key `blankcut login` gives you lasts 24 hours. When it runs out, the CLI
  offers to sign you in again on the spot, and `blankcut whoami` shows when it expires.

## v0.25.1

*Released 2026-10-28.*

- `blankcut promote --help` and `blankcut deprovision --help` say what each command does for your
  app, and where to see what happens next.

## v0.25.0

*Released 2026-10-28.*

- **`blankcut status` says what a waiting deploy needs from you.** Pending changes are listed in
  plain terms: a deploy waiting on a secret names the key and the command that sets it, a first
  deploy waiting on its first green build says so, and a change on the platform's side says there
  is nothing for you to do.
- After fixing a failed first build, push the fix: the next green build carries the deploy
  through, without running `blankcut promote` again.
- `blankcut promote --dry-run` lists the secrets the app reads and how to set any that are missing.

## v0.24.0

*Released 2026-10-26.*

- **`blankcut whoami`** shows which organization this CLI is signed in to. Every command acts for
  that organization: its projects, including ones created after you signed in, and its plan for
  billing. To act for another organization, run `blankcut login` again and choose it.
- `blankcut promote` no longer offers `--tenant`, `--billing`, `--operator` or `--ssm-path`. Which
  organization a project belongs to, how it is billed and where its secrets live all come from
  your account, and the service now refuses those flags from a customer key.
- Blank Cut admins: `blankcut onboard --org <tenant>` onboards a repo for a client organization.
  Signed in to `blank-cut` as an admin, your key now reaches every organization's projects, which
  `blankcut whoami` confirms. It is checked live against your admin role.

## v0.23.7

*Released 2026-10-26.*

- A static site scaffolded by `blankcut init` no longer ships a known HIGH in its file server. The
  scaffolded `Dockerfile` installs `serve` with `compression` 1.8.2 instead of the 1.8.1 that serve
  pins, which leaked a zlib stream when a client disconnected mid-response. If your repo's
  `Dockerfile` still has `npm install -g serve@14`, copy the new `serve` lines from a fresh scaffold.

## v0.23.6

*Released 2026-10-24.*

- `blankcut promote --repo` on a repo Blank Cut hasn't registered yet now tells you to run
  `blankcut onboard` first, instead of only answering "not authorized". `promote` deploys apps that
  are already registered; `onboard` is what registers a new one.

## v0.23.5

*Released 2026-10-24.*

- The `Dockerfile` that `blankcut init` scaffolds now refreshes its OS packages whenever Alpine
  publishes fixes. Before, the build cache reused the `apk upgrade` step from the first build, so
  fixes Alpine had already published kept showing up as findings. One line fixes an existing
  Dockerfile, and the scaffolded `CLAUDE.md` says which; run `blankcut sync` to pick that up.

## v0.23.4

*Released 2026-10-24.*

- Errors print once. A refused request used to print its message, the command's whole flag list,
  then the message again; now it prints the message alone. A mistyped command, flag or argument
  says `Run 'blankcut <command> --help' for usage.` instead of printing the flag list.
- The company is written **Blank Cut** everywhere the CLI speaks: `--help`, the installer's
  Homebrew description, and the `CLAUDE.md` and `README.md` it scaffolds. The command is still
  `blankcut`, and nothing about how any command behaves changed. Run `blankcut sync` in a repo to
  pick up the new `CLAUDE.md` wording.

## v0.23.3

*Released 2026-10-20.*

- `blankcut validate` no longer requires a `docs/` directory or a `tsconfig.json`. Nothing that
  builds, deploys or runs your app reads either file, so a working app no longer fails for lacking
  them. Every check left is something the platform depends on.

## v0.23.2

*Released 2026-10-20.*

- `blankcut validate` no longer fails Python and Go repos for having no `tsconfig.json`: that
  check now applies to Node projects only, so `validate --fix` stops adding a `tsconfig.json` to
  repos that don't use TypeScript.
- Help text matches what the commands do. `onboard` says its setup PR carries the platform layout
  and that the build workflow comes with the first `promote`; `provision` says Redis on Rough Cut
  is a paid add-on rather than unavailable; `context image` says it reports the image the app runs
  from and whether it is pinned by digest.
- `blankcut domains release` prints its one sentence without the flag list under it.

## v0.23.1

*Released 2026-10-18.*

- `blankcut domains release` no longer unlocks a domain or prints its transfer code: moving a domain
  to another registrar is done in Meerkat by a signed-in owner (Domains → the domain → Transfer out),
  and the command now says so. A transfer code is all another registrar needs to take a domain, so
  it isn't handed to a terminal, an agent or a CI job. Buying, transferring in, attaching and DNS
  records are unchanged.

## v0.23.0

*Released 2026-10-17.*

- `blankcut domains` buys, moves and connects custom domains. `search <name>` shows availability and
  the yearly price; `buy <domain> --app <app>` registers one at cost on your organization's card,
  showing the price and asking first; `transfer check|dns|start` moves a domain you own elsewhere,
  copying its DNS over first so the site and email keep working. A domain is attached to its app
  automatically once its certificate is issued -- `attach` / `detach` switch it (`attach` also
  connects a domain registered somewhere else) and `status` shows how far along it is.
- `blankcut domains records` lists, sets and removes DNS records for domains Blank Cut hosts.
  `auto-renew on|off`, `release` (prints the transfer code to move a domain to another registrar),
  `verify-email` and `contact set` (the registrant, needed before a first purchase) manage the
  registration. Buying, transferring, releasing, auto-renew and the contact need the organization
  owner's key.

## v0.22.2

*Released 2026-10-17.*

- `blankcut promote --app` now preserves a registered monorepo app’s identity and rebuilds only its configured image through the build broker. Run from a clean checkout matching the repository’s current `main`; `--dry-run` shows the exact image and Dockerfile. Unknown or ambiguous image mappings and infrastructure overrides are refused before a build starts. Existing ingress, secrets, and other community images stay in place. The build uses the workflow’s existing `APP_NAME` broker identity, which may differ from both the community app and its image.

## v0.22.1

*Released 2026-10-14.*

- `blankcut scan waivers approve|reject|revoke` now records the decision on the waiver's review ticket
  in Meerkat, resolves it, and tells the person who asked -- as a decision made in Meerkat always did.
- `blankcut scan waive` / `scan waivers` print the server's reason on a refusal without the flag list
  under it, and `--json` output includes `requestedVia`.

## v0.22.0

*Released 2026-10-14.*

- The CLI now defaults to the Meerkat API at `https://api.blankcut.com`. `blankcut configure`
  needs only `--api-key`, and in CI `BLANKCUT_API_KEY` alone is enough (`BLANKCUT_ENDPOINT` is
  optional). Existing configs that name `https://agent.blankcut.com` keep working unchanged.

## v0.21.0

*Released 2026-10-14.*

- `blankcut scan waive --vuln <id> --pkg <pkg> --reason "..."` asks the Blank Cut team to waive a
  scan finding you cannot fix yet -- one vulnerability in one package, exactly as `blankcut scan`
  reports it. Coding agents can file these too. Nothing changes until the team approves it, and the
  team is notified. `blankcut scan waivers` lists the app's waivers and where each one stands.
- Blank Cut team: after `blankcut login` into the platform organization, `blankcut scan waivers
  --pending` is the review queue across apps, `blankcut scan waivers approve|reject|revoke <id>`
  decides one, and `blankcut scan waive ... --approve` waives in one step.

## v0.20.1

*Released 2026-10-14.*

- `blankcut scan` names one version to upgrade each package to -- the lowest fix on
  the release line you are on that clears every finding in the package -- instead of
  the scanner's full list of fixed releases across every line (which read like
  `5.0.7, 1.1.16, 2.1.2 | 5.0.8, 3.0.3, ...`). The Meerkat Security panel shows the
  same version. `--json` still carries the full lists.

## v0.20.0

*Released 2026-10-05.*

- `blankcut scan` lists your app's image vulnerabilities -- every finding with a
  published fix, grouped by the package upgrade that clears it, split into OS
  packages (move the base image) and app dependencies (bump the lockfile), for
  both the last build and the images running now. JSON when piped, so a coding
  agent can read it and make the upgrades. Waivers and help from the Blank Cut
  team are requested from the app's Security panel in Meerkat.

## v0.19.1 — 2026-09-30

- `blankcut sync` writes the same CLAUDE.md block the platform now distributes: install
  instructions that need no GitHub login (the public installer or Homebrew). v0.19.0 carried the
  previous text, so running `sync` with it rolled a platform-refreshed repo back to the old
  instructions, and `sync --check` reported those repos as out of date. Run `blankcut upgrade`,
  then `blankcut sync`.

## v0.19.0

*Released 2026-09-27.*

- **Install and upgrade without a GitHub login.** `blankcut upgrade` and the
  installer now read from the public releases repository first, verify the
  download's checksum (and its signature when `cosign` is installed), and only
  fall back to the private repository through `gh` when no public release
  exists. Homebrew: `brew install blankcut/tap/blankcut`. Or, anywhere with curl:
  `curl -fsSL https://raw.githubusercontent.com/Blankcut/blankcut-cli-releases/main/install.sh | bash`.
- **Every download now carries its license** (`LICENSE`) and the licenses of the
  open-source libraries compiled into it (`THIRD_PARTY_NOTICES.md`).

## v0.18.1

*Released 2026-09-27.*

- **`blankcut login` says whether GitHub is connected.** With no projects yet,
  it now tells you the Blank Cut GitHub App is already connected for your
  organization — or that connecting it is the first thing to do — instead of
  generic advice. (Needs the matching console release; until then you see the
  generic text.)
- **`blankcut upgrade` hands a Homebrew-managed install back to Homebrew**
  (`brew upgrade blankcut`) instead of overwriting a file Homebrew owns.

## v0.18.0

*Released 2026-09-27.*

- **`blankcut onboard` connects a repo you already have.** Run it inside the
  repo (or pass `--repo`): it registers the app to your organization and opens a
  setup pull request with the Dockerfile, build workflow, `.env.example` and
  `CLAUDE.md`. It does not deploy — merge the PR, then `blankcut promote --app
  <name>`. The Blank Cut GitHub App must be installed on the repo's account by
  your organization; onboard says so plainly if it is not.
- **`blankcut login` points a new workspace at both ways in** — `onboard` for an
  existing repo, `provision` for a new one — and no longer claims a card is
  needed to start (it is not, during the trial).
- **`provision` says the starter deploys itself** once its first image builds,
  and how to watch it, instead of telling you to promote it by hand.

## v0.17.1

*Released 2026-09-26.*

- **`blankcut upgrade` no longer reports a successful install as a failure.** It
  printed `install failed (nothing was changed)` after writing the new binary,
  because the install script ended with a command whose output was piped to
  `head` — that closed the pipe, and the resulting status became the script's
  own. The script now verifies by printing the installed version, and `upgrade`
  fetches it to a file instead of piping it into bash, so a dropped connection
  can no longer execute a half-downloaded installer either. If the installer
  does fail, `upgrade` now checks what is actually on disk before telling you
  nothing changed.

## v0.17.0

*Released 2026-09-23.*

- **`blankcut upgrade --check` lists what is new again.** It printed the version
  comparison and then stopped: the "New since your version" list was empty for
  v0.15.0 and v0.16.0 alike, because the heading parser split on the first `-` in
  `## v0.16.0 — 2026-09-23` and landed inside the date. Two releases announced
  nothing, one of them `blankcut schedule`. Dates now live on their own line and
  the parser reads only the first field of a heading.
- **`blankcut context storage` now actually prints the storage section.** The
  subcommand shipped in v0.15.0 fetching the right data and then discarding it —
  the response type had no field for it — so it printed an app name and nothing
  else. It now reports where the app's files live and the two rules that fail at
  runtime rather than at deploy time: set no AWS credentials (an explicit one
  wins over the pod's identity, which has no access), and start every key with
  `STORAGE_PREFIX`. It also says plainly when the access identity is still being
  created, since promoting before then deploys an app that cannot reach its files.

## v0.16.0

*Released 2026-09-23.*

- **Every image the platform builds is now scanned before it is pushed, and your
  build output tells you what it found.** The Actions log prints
  `Image scan: recorded - 0 critical, 3 high, 7 medium` followed by one line per
  finding — `HIGH <package> <installed> -> <fixed> (<CVE>)` — and writes the same
  list to the run summary. Every count is a finding that **has a published fix**;
  advisories with nothing to upgrade to are excluded, so each line is something
  you can act on. A `blocked` verdict means the image was built and **not
  pushed**, so that commit cannot deploy; an `error` verdict means the image was
  not checked, which is unknown rather than clean.

  `blankcut sync` pulls the matching guidance into your repo's `CLAUDE.md` — how
  to read the output, and the order to try fixes in (refresh the lockfile, then
  raise a capped floor, then override a transitive pin). It calls out the caret
  trap that catches people most often: `^0.0.6` means `>=0.0.6 <0.0.7`, so a fix
  published in `0.0.18` is unreachable until you widen the range yourself.

- **`init` now scaffolds a Dockerfile that patches its own base image.** The
  generated final stage runs `apk upgrade` and removes `npm` after it is used to
  install `serve`. Measured across the deployed fleet on 2026-09-16, those two
  lines account for most of what a scanner finds in a freshly built app image
  and none of it is anything an app author wrote: stale Alpine packages
  (`libexpat` alone appeared 23 times across four apps, `libcrypto3`/`libssl3` in
  nearly every one) plus npm's own dependency tree, which is needed for one
  install line and never again at runtime. A rebuild is the entire fix.

  Existing apps do not pick this up automatically — the Dockerfile lives in your
  repo. Compare it against a fresh `blankcut init` in a scratch directory if your
  build is reporting OS-package findings you did not introduce.

  Node stays on 22 deliberately. `node:22-alpine` and `node:24-alpine` sit on the
  same Alpine, so `apk upgrade` closes the OS gap either way; moving a Node major
  underneath a running app is a decision to make on purpose, not a side effect of
  a security patch.

## v0.15.0

*Released 2026-09-14.*

- `blankcut schedule` — run one of your app's own endpoints on a recurring
  schedule (`schedule add|list|rm`). You write the endpoint; the platform calls
  it over the cluster's internal network with the app's `BLANKCUT_CRON_SECRET`
  as a bearer token, so it does not have to be public. At most one run every
  5 minutes, and a per-app limit `schedule list` prints. Changes apply
  automatically — the platform re-renders the job it would have generated and
  deploys it only if the change matches byte for byte.

- `init` now says plainly that it has not deployed anything, and prints the
  exact next steps. A merged `init` PR is not a deployment — `promote` is the
  step that generates the build workflow and the deploy config.

- **A failed brokered build now tells you whose fault it is.** When the platform's
  build account has no capacity, `/build/{id}/start` answers
  `build_capacity_unavailable` and says the limit is platform-side rather than a
  generic "failed to start build" — and the generated CI workflow prints the
  response body instead of dying as a bare `exit 22`. A build that fails for
  reasons outside your repo now says so in the Actions log.
- **`blankcut context storage` tells you how your app reaches its files.** Managed
  Storage is keyless — the pod carries an IAM role scoped to its own prefix — and
  nothing said so, so the natural guess was an S3 client holding an access key.
  That is the one thing that cannot work: explicit credentials win over the pod's
  identity in every AWS SDK, so adding them breaks storage silently. The new
  section reports the bucket, both prefixes, and the requirement, and says
  `provisioning` rather than `ready` while the app's identity is still being made.
- **`blankcut storage add` now repairs a half-finished provision.** It used to
  answer "already provisioned" whenever the bucket existed, even if the identity
  that reaches it had failed — leaving an app billed for storage it could not use
  and no command that would fix it. Re-running it is now the fix.

## v0.14.0

- **Signing in no longer signs you out somewhere else.** An organization used to
  hold exactly one live API key, so `blankcut login` from a second machine
  silently revoked the first, and `keys refresh` evicted everyone else in the
  org. Your laptop, your other laptop and CI can now each hold their own key.
- **`blankcut login` names the key after the machine it came from**, so the
  console lists "eders-macbook" rather than another "Unnamed key" — which is
  what you need when you are trying to work out which key belonged to a laptop
  you just lost. The person approving the login sees the machine claiming it too.
- Use `--device-name` where the hostname is noise: a CI runner called
  `runner-7f3a9b` is better listed as `CI`, and a container's hostname is a
  random string that will mean nothing next month.

## v0.13.0

- **`blankcut context routes`** lists every route in this app, what guards it,
  and which tables it touches — read it before adding a route, so the new one
  is guarded like its neighbours. Routes whose guard could not be traced are
  reported as `guard not determined`, which means exactly that: it is not a
  claim that the route is unauthenticated, and it should not be "fixed".
- **`blankcut context conventions`** reports the patterns this repository
  actually uses — how routes are guarded, how it reaches its database, whether
  environment variables carry a fallback — each with the count behind it, so
  you can tell a house style from something one file did once. Derived from the
  code at the current commit, so it cannot be stale.
- Both print a readable table in a terminal and JSON when piped, like the rest
  of `context`, and both state how many files were read and how many could not
  be parsed — because "no unauthenticated routes" and "found no routes" look
  identical otherwise.

## v0.12.0

- **`blankcut login`** signs this machine in without you ever handling a key.
  It prints a short code and opens your browser; you approve it there, and the
  CLI collects the API key itself. Nothing is displayed, copied, or pasted — so
  the key cannot land in your shell history, a screenshot, or an agent
  transcript. Use `--no-browser` on a server or in a container. It replaces
  `blankcut configure` for everyday use; `configure` stays for the case where
  somebody handed you a key. Agents and CI should keep using
  `BLANKCUT_API_KEY` + `BLANKCUT_ENDPOINT`, since neither can approve a browser
  prompt.

## v0.11.1

- `blankcut sync` now writes the platform block that explains **`blankcut
  provision`** — what it creates, that it bills from the moment it exists, and
  what a refusal means. Upgrade before running `sync`: a v0.11.0 binary carries
  the older block and will rewrite a current one backwards, and `sync --check`
  on that build reports an up-to-date repo as stale.

## v0.11.0

- `blankcut provision` now works with your **own** workspace API key. Creating a
  project used to require an operator credential no customer has, so every new
  project had to go through the portal. New projects are attributed to your key's
  organization automatically; a key cannot create projects for anyone else's.
  Your Blank Cut administrator enables this per deployment — until they do, the
  command tells you so and points you at the portal.
- `blankcut provision --installation-id` is now optional. The GitHub App
  installation is looked up from `--owner`, so you no longer have to go and find
  a number GitHub never showed you. Pass it only if you are told to.

## v0.10.0

- `blankcut sync` now writes guidance telling coding agents to run
  `blankcut context` before writing code that touches infrastructure, and what
  the answers mean — that the memory limit is enforced rather than advisory,
  that a connection pool is multiplied by every replica of every workload, and
  that a secret can be stored without reaching the running pod. Run
  `blankcut sync` in a repo to pick it up.
- Your API key now covers **every project in your workspace, including ones you
  create later**. It used to be frozen to the projects that existed the moment
  it was issued, so a new project was invisible to a key you already had — and
  the only fix was regenerating, which stopped your teammates' keys working.
- `blankcut keys refresh` replaces the key this machine is using with a fresh
  one and writes it straight into your config. Use it if a key may have been
  exposed, or on a schedule. It covers the same projects; it cannot widen
  access, and it does not work on a project's CI key (rotate that with
  `blankcut keys provision`, which also updates the repository secret).
- A key that has been replaced now says so, instead of reporting the same
  "invalid key" as a typo.

## v0.9.0

- `blankcut storage add --app <APP>` gives an app somewhere to keep files —
  images, video, uploads, anything it needs to serve or hold onto. Files go in
  one of two places: `public`, which gets a stable public URL, or `private`,
  reachable only through a time-limited link the app generates. The app reads
  and writes both using its own identity, so there are no access keys to copy,
  paste or leak. Deploy afterwards so the running app picks it up.
- `blankcut storage status --app <APP>` shows how much of the app's storage
  limit is in use, and `blankcut storage rm --app <APP> --yes` deletes the
  app's files permanently.
- `blankcut context` reports the real environment your app runs in — the
  resource envelope and scaling limits it actually gets, which secret keys reach
  the running pod (and which are stored but do not), the database engine,
  version, connection limit and schema, and recent traffic and error rates. Run
  it before writing code against this app, so the code targets what exists
  rather than a guess. Subcommands narrow it: `context env`, `secrets`, `data`,
  `image`, `runtime`.
  Nothing is cached locally — every run fetches current state or fails — and each
  response says how fresh each part of it is. Output is JSON automatically when
  piped, so an agent gets machine-readable data and a person gets a readable
  table from the same command.
- `blankcut diagnose` explains why a deployment is unhealthy, rather than
  reporting the raw pod counts and warnings that `blankcut status` gives you.
- Both commands accept `--app`, and infer the app from the git remote when you
  omit it.
- `BLANKCUT_API_KEY` and `BLANKCUT_ENDPOINT` now genuinely work without a saved
  config, as the docs have always said. Previously every command required
  `~/.blankcut/config.json`, which made the documented CI and container workflow
  impossible.
- The CLI now tells the Agent Service which build it is (version, commit,
  os/arch) and which response shapes it understands, and the service answers
  with what it can speak. Nothing to run — it happens on every request. The
  point is forward compatibility: a future release can add a response shape
  without breaking the binary sitting on your laptop, because the service will
  only ever reply in a shape your build asked for.
- If your build is ever too old for the service to serve safely, you now get a
  clear "run `blankcut upgrade`" instead of a confusing parse failure.

## v0.8.1

- `blankcut upgrade` no longer reports success when the download failed. The
  install pipeline runs under `pipefail`, so a fetch error surfaces as a failed
  upgrade instead of a shell "command not found" (or, if `gh` ever stops writing
  its error to stdout, a clean exit that installed nothing).
- A 404 from the release repo is now explained rather than passed through.
  GitHub reports a private repo you cannot read as "not found", and
  `gh auth status` stays green, so the old message pointed nowhere. If your repo
  lives in your own GitHub organization, the CLI is not distributed to you yet —
  and your repo's `CLAUDE.md` is kept current by a pull request from Blank Cut,
  so you are not missing updates because of it.

## v0.8.0

- `blankcut redis enable|disable|reset --app <APP>` turns the managed Redis on
  or off for an app explicitly, instead of leaving it to repo analysis. `reset`
  hands the decision back to the analyzer.
- `blankcut promote --to-production --app <APP>` graduates a Rough Cut app to
  the production tier as part of the deploy: lifts the resource cap, allows a
  custom domain, restores the review gate, and moves billing to the platform
  rate. No migration or rebuild.
- `blankcut sync` refreshes the BlankCut-managed block in a repo's `CLAUDE.md`
  from your installed CLI, without touching anything else in the repo. Run it
  after `blankcut upgrade`; `--check` reports staleness for CI.
- `blankcut upgrade --check` now lists what changed since your build instead of
  only comparing version numbers, so you can see what you would gain before
  installing anything.
- The command list in every scaffolded `CLAUDE.md` and in the README is now
  generated from the CLI's own command tree, so it can no longer drift. It had
  drifted badly: `provision`, `deprovision`, `database` and `keys` were all
  shipped but documented nowhere an agent would look.

---

Entries below this line were reconstructed from git history when the changelog
was introduced, by finding the first tag containing each command. They record
when a command first shipped, not everything that changed in that release.

## v0.7.0

- `--tier sandbox` (aka `rough-cut`) on `blankcut provision` creates an app on
  the sandbox tier: no Redis, reduced footprint, seeded repo told which tier it
  is on.

## v0.6.2

- `blankcut database` manages an app's managed Postgres; `database add`
  provisions one for an app created without it.

## v0.5.6

- `blankcut deprovision` tears an app down: deletes its secrets and opens the
  removal MRs.

## v0.5.2

- `blankcut keys` manages an app's CI API key; `keys provision` mints an
  app-scoped key and sets it as a repo secret, so a repo's pipeline can call the
  platform without a shared key.

## v0.4.0

- `blankcut provision` creates a whole project: repo, opinionated starter with
  Supabase and Redis pre-wired, a `/health` endpoint, and the backing services.
- `blankcut upgrade` self-updates the CLI in place.
