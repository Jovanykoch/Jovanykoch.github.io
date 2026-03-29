#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import annotations
from datetime import datetime, timezone
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
INFILE = ROOT / "rules" / "direct.txt"
OUTFILE = ROOT / "rules" / "direct-domain-set.list"

DOMAIN_RE = re.compile(r"^[a-z0-9.-]+$")

def is_valid_domain(d: str) -> bool:
    if not d:
        return False
    if d.startswith("."):
        return False
    if " " in d or "\t" in d:
        return False
    if len(d) > 253:
        return False
    if d.startswith("-") or d.endswith("-"):
        return False
    if ".." in d:
        return False
    if not DOMAIN_RE.match(d):
        return False

    labels = d.split(".")
    if len(labels) < 2:
        return False

    for lab in labels:
        if not (1 <= len(lab) <= 63):
            return False
        if lab.startswith("-") or lab.endswith("-"):
            return False
        if not any(ch.isalnum() for ch in lab):
            return False

    return True

def normalize(line: str) -> str | None:
    s = line.strip()
    if not s:
        return None
    if s.startswith("#") or s.startswith("//") or s.startswith(";"):
        return None
    for sep in (" #", "\t#", " //", "\t//", " ;", "\t;"):
        if sep in s:
            s = s.split(sep, 1)[0].strip()

    s = s.strip().lower()
    if not s:
        return None
    if s.endswith("."):
        s = s[:-1]
    if not is_valid_domain(s):
        return None
    return s

def main() -> int:
    if not INFILE.exists():
        print(f"ERROR: {INFILE} not found", file=sys.stderr)
        return 2

    domains: set[str] = set()
    total = 0

    with INFILE.open("r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            total += 1
            d = normalize(line)
            if d is None:
                continue
            domains.add(d)

    out = sorted(domains)
    gen_time = datetime.now(timezone.utc).replace(microsecond=0).isoformat()

    header = [
        "# Surge DOMAIN-SET (exact domains, one per line)",
        "# Generated from: rules/direct.txt",
        f"# Generated at (UTC): {gen_time}",
        f"# Input lines: {total}",
        f"# Output domains: {len(out)}",
        "#",
    ]

    OUTFILE.parent.mkdir(parents=True, exist_ok=True)
    OUTFILE.write_text("\n".join(header + out) + "\n", encoding="utf-8")

    print(f"OK: wrote {OUTFILE} ({len(out)} domains)")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
