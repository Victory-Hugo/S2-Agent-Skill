---
name: python-code
description: 编写任何Python代码都需要遵循的规范格式。 
---

# Python Code Format

## Overview
Convert Python scripts into modules that work both as imports and as CLI tools. Ensure the output is Python code only and follows the dual-mode structure.

## Requirements Checklist
- Define a `run()` function (or semantically named equivalent) whose parameters cover all script inputs.
- Implement `main()` that uses `argparse` to parse the original CLI parameters and calls `run()`.
- Keep `if __name__ == "__main__": main()` so imports do not execute the main flow.
- Move all top-level execution, file reads, prints, and control flow into functions.
- Remove reliance on global state; `run()` must be callable directly without CLI context.
- Parameterize hardcoded paths and pass them into `run()`.

## Workflow
1. Identify all inputs in the original script (CLI args, constants, file paths, environment reads).
2. Turn those inputs into explicit parameters of `run()`.
3. Move side effects (I/O, logging, printing, file writes) into `run()` or helpers called by `run()`.
4. Map CLI arguments to `run()` parameters in `main()` using `argparse`.
5. Verify that importing the module does not trigger execution.

## Minimal Template
```python
import argparse
from typing import Optional

def run(input_path: str, output_path: str, flag: bool = False) -> int:
    # Implement main logic here; keep side effects inside this function.
    return 0

def main() -> None:
    parser = argparse.ArgumentParser(description="...")
    parser.add_argument("--input-path", required=True)
    parser.add_argument("--output-path", required=True)
    parser.add_argument("--flag", action="store_true")
    args = parser.parse_args()
    run(args.input_path, args.output_path, args.flag)

if __name__ == "__main__":
    main()
```

## Edge Cases
- If the script has multiple modes, use `argparse` subparsers and route to different `run_*` functions, but still keep a single `main()` entry point.
- If the script reads files at import time, move that logic into `run()` or helper functions.
