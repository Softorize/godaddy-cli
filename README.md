# godaddy-cli

A minimal, dependency-free CLI for the GoDaddy REST API. Pure bash + `curl` + `python3` (stdlib only).

```bash
godaddy domains list
godaddy dns set example.com A @ 1.2.3.4 --ttl 600
godaddy dns add example.com TXT _verify "abc123"
godaddy domain availability foo.com bar.com
```

---

## ⚠️ Read this first: GoDaddy API access is gated

In early 2024, GoDaddy restricted public API access. To get working API keys, your account must meet **at least one** of:

- **50 or more domains** registered on the account, **or**
- **$1,000+ annual spend** with GoDaddy

Below either threshold, your keys still generate at [developer.godaddy.com/keys](https://developer.godaddy.com/keys), but most endpoints (DNS records, domain operations) return `403 Forbidden`. This affects **every** GoDaddy CLI and library equally — it's an account-level restriction, not a tool limitation.

If you don't qualify, consider Cloudflare for DNS (free, unrestricted API) or move DNS to another provider while keeping registration at GoDaddy.

Run `godaddy auth-check` after configuring keys to verify your account has API access.

---

## Install

**One-liner (recommended):**

```bash
curl -fsSL https://raw.githubusercontent.com/softorize/godaddy-cli/main/install.sh | bash
```

**Manual:**

```bash
git clone https://github.com/softorize/godaddy-cli.git
cd godaddy-cli
install -m 0755 godaddy ~/.local/bin/godaddy
```

Make sure `~/.local/bin` is on your `PATH`.

## Configure

1. Generate a production API key + secret at [developer.godaddy.com/keys](https://developer.godaddy.com/keys).
2. Drop them in `~/.godaddy/credentials`:

```bash
mkdir -p ~/.godaddy
cat > ~/.godaddy/credentials <<'EOF'
GODADDY_KEY=your-key-here
GODADDY_SECRET=your-secret-here
GODADDY_ENV=prod
EOF
chmod 600 ~/.godaddy/credentials
```

`GODADDY_ENV=ote` switches to the OTE (sandbox) environment — `api.ote-godaddy.com` — which has its own separate keys.

3. Verify:

```bash
godaddy auth-check
```

A `403 Forbidden` here means your account is below the gating threshold (see top of README).

## Commands

```
godaddy whoami                          Show env + masked key
godaddy auth-check                      Verify keys work

godaddy domains list                    List all domains
godaddy domain get <domain>             Show full record
godaddy domain renew <domain>           Renew (1 year)
godaddy domain availability <d> [...]   Check availability

godaddy dns list <domain> [type] [name]                List records (filters optional)
godaddy dns get <domain> <type> <name>                 Get specific record(s)
godaddy dns set <domain> <type> <name> <value> [--ttl N] [--priority N] [--weight N] [--port N]   Replace records
godaddy dns add <domain> <type> <name> <value> [--ttl N] [--priority N] [--weight N] [--port N]   Append a record
godaddy dns delete <domain> <type> <name>              Delete records

godaddy raw <METHOD> <path> [curl args...]             Direct API call
```

## Examples

```bash
# List all your domains and pluck just the names
godaddy domains list | jq -r '.[].domain'

# Point apex A record to a new IP
godaddy dns set example.com A @ 203.0.113.42 --ttl 600

# Add a TXT record for domain verification (does NOT replace existing TXT)
godaddy dns add example.com TXT _acme-challenge "abc123"

# Set up inbound email (MX records need a priority; defaults to 10)
godaddy dns set example.com MX @ mx1.forwardemail.net --priority 10
godaddy dns add example.com MX @ mx2.forwardemail.net --priority 20

# SRV record (priority + weight + port)
godaddy dns set example.com SRV _sip._tcp sip.example.com --priority 10 --weight 5 --port 5060

# Check 3 names at once
godaddy domain availability foo.com bar.io baz.dev

# Raw call to any endpoint
godaddy raw GET '/v1/domains/suggest?query=cannabis&limit=5'
```

## How `dns set` vs `dns add` differ

- **`set`** — `PUT`s the new value, replacing all existing records of that `<type>/<name>`. Use this when you want exactly one record (e.g. a single A record on the apex).
- **`add`** — fetches existing records, appends the new one, then `PUT`s the merged list back. Use this when you want multiple records of the same type (e.g. several `TXT` records, MX fanout).

GoDaddy's API has no native "append" endpoint; `dns add` simulates it.

## Record types that need extra fields

`MX` and `SRV` records carry more than just `data` + `ttl`:

- **`MX`** — requires a **priority**. Pass `--priority N`; if omitted it defaults to `10`.
- **`SRV`** — requires **priority**, **weight**, and **port**. Pass `--priority N --weight N --port N`.

These fields are ignored for record types that don't use them, so plain `A`/`CNAME`/`TXT` calls are unchanged.

## Security

- The credentials file should be mode `0600` (the install steps above set this).
- Don't commit `~/.godaddy/` to git.
- Use OTE keys (`GODADDY_ENV=ote`) for testing destructive operations.

## Contributing

PRs welcome. Run [`shellcheck`](https://github.com/koalaman/shellcheck) before pushing — CI runs it on every PR.

## License

MIT. See [LICENSE](LICENSE).

## Disclaimer

Not affiliated with GoDaddy. "GoDaddy" is a trademark of GoDaddy Operating Company, LLC.
