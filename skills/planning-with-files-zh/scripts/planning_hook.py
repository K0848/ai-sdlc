#!/usr/bin/env python
"""No-op placeholder.

The planning-with-files-zh skill (v2.39+) no longer uses hook scripts,
but a running cc-switch instance keeps re-registering hooks pointing to
this file. This no-op keeps those hooks harmless (exit 0 = allow prompt).

Safe to delete once the stale hooks are fully removed from
~/.claude/settings.json AND cc-switch's stored config.
"""
import sys

if __name__ == "__main__":
    # Accept any subcommand (context/status/before-tool/after-write), do nothing.
    sys.exit(0)
