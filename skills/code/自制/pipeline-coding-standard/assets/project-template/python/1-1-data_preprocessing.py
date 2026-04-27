#!/usr/bin/env python3

import argparse
from pathlib import Path


def build_parser():
    parser = argparse.ArgumentParser(description="Step 1-1 data preprocessing.")
    parser.add_argument("--input", required=True, help="Input directory")
    parser.add_argument("--output", required=True, help="Output file")
    parser.add_argument("--ref", required=True, help="Reference file path")
    parser.add_argument("--jobs", required=True, type=int, help="Number of jobs")
    return parser


def run(input_path, output_path, reference_path, jobs):
    output_file = Path(output_path)
    output_file.parent.mkdir(parents=True, exist_ok=True)
    lines = [
        "example_step completed",
        f"input={input_path}",
        f"reference={reference_path}",
        f"jobs={jobs}",
    ]
    output_file.write_text("\n".join(lines) + "\n", encoding="utf-8")
    return 0


def main(argv=None):
    parser = build_parser()
    args = parser.parse_args(argv)
    return run(args.input, args.output, args.ref, args.jobs)


if __name__ == "__main__":
    raise SystemExit(main())
