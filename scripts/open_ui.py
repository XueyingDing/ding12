"""Launch the built-in DuckDB browser UI against the project database.

Usage (with the virtual environment active):
    python scripts/open_ui.py

This opens a local web UI (http://localhost:4213) where you can browse every
seed, staging view, intermediate view, and mart table, run SQL, and see results
as tables/charts. Press Ctrl+C in the terminal to stop it.

Works identically on macOS, Linux, and Windows.
"""

import os

import duckdb

DB_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), "ding12.duckdb")

if not os.path.exists(DB_PATH):
    raise SystemExit(
        f"Database not found at {DB_PATH}\n"
        "Run `dbt seed` and `dbt build` first so the tables exist."
    )

con = duckdb.connect(DB_PATH)
con.execute("CALL start_ui()")  # installs/loads the ui extension and opens a browser

print("\nDuckDB UI is running at http://localhost:4213")
print("Browse the tables under the 'ding12' database in the left sidebar.")
print("Press Ctrl+C here to stop.\n")

try:
    # Keep the process alive so the UI server keeps serving.
    import threading

    threading.Event().wait()
except KeyboardInterrupt:
    print("\nStopping DuckDB UI. Bye!")