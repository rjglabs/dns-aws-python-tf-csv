"""
parse_dns_csvs.py

Reads all DNS record CSVs in the records/ directory, filters out rows
where 'enabled' is not 'yes', and outputs a JSON object for use with
Terraform or other automation. The 'enabled' column is not included in
the output. This allows legacy/placeholder records to remain in the CSV
but not be processed by downstream tools.

- Only rows with enabled == 'yes' (case-insensitive) are included.
- The 'enabled' column is removed from the output.
- All record types listed in record_types are processed if their CSV exists.
- Logs actions to parse_dns_csvs.log and to the console if interactive.
"""

import csv
import datetime
import json
import os
import sys
from typing import Any, Dict, List

base = os.path.dirname(__file__)
log_path = os.path.join(base, "parse_dns_csvs.log")


def write_log(message: str) -> None:
    timestamped = f"[{datetime.datetime.now().isoformat()}] {message}"
    try:
        with open(log_path, "a", encoding="utf-8") as logf:
            logf.write(timestamped + "\n")
    except (IOError, OSError, PermissionError) as e:
        # Only catch specific file-related exceptions
        # Print to stderr if we can't write to log file
        print(
            f"Warning: Could not write to log file {log_path}: {e}",
            file=sys.stderr,
        )
    # Print to console if interactive
    if sys.stdout.isatty():
        print(timestamped)


# Ensure log file is .gitignored
try:
    gitignore_path = os.path.join(base, ".gitignore")
    rel_log = os.path.basename(log_path)
    if os.path.exists(gitignore_path):
        with open(gitignore_path, "r", encoding="utf-8") as f:
            content = f.read()
        if rel_log not in content:
            with open(gitignore_path, "a", encoding="utf-8") as f:
                f.write(rel_log + "\n")
            write_log(f"Added {rel_log} to .gitignore.")
    else:
        with open(gitignore_path, "w", encoding="utf-8") as f:
            f.write(rel_log + "\n")
        write_log(f"Created .gitignore and added {rel_log}.")
except Exception:
    write_log("Failed to update .gitignore.")

write_log("Script started.")

# Map logical record type names to their CSV filenames
record_types = {
    "a_records": "a_records.csv",
    "aaaa_records": "aaaa_records.csv",
    "cname_records": "cname_records.csv",
    "mx_records": "mx_records.csv",
    "ns_records": "ns_records.csv",
    "srv_records": "srv_records.csv",
    "ptr_records": "ptr_records.csv",
    "caa_records": "caa_records.csv",
    "spf_records": "spf_records.csv",
    "dmarc_records": "dmarc_records.csv",
    "txt_records": "txt_records.csv",
    "a_alias_records": "a_alias_records.csv",
}

result: Dict[str, List[Dict[str, Any]]] = {}
for dtype, fname in record_types.items():
    path = os.path.join(base, "records", fname)
    if not os.path.exists(path):
        write_log(f"CSV not found: {fname}, skipping.")
        continue  # Skip missing CSVs
    write_log(f"Processing {fname} ...")
    with open(path, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        filtered: List[Dict[str, str]] = []
        for row in reader:
            # Only include rows where enabled == 'yes' (case-insensitive)
            if row.get("enabled", "").strip().lower() == "yes":
                # Remove 'enabled' column from output
                filtered.append(
                    {k: v for k, v in row.items() if k != "enabled"}
                )
        write_log(f"{len(filtered)} records enabled in {fname}.")
        result[dtype] = filtered

write_log("Script completed successfully.")

# Output the filtered records as JSON
json.dump(result, sys.stdout)
