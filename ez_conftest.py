#!/usr/bin/env python3
import re
import argparse
import json
import asyncio
import sys


async def run_conftest(data: str):
    proc = await asyncio.create_subprocess_shell(
        "conftest test -",
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE,
        stdin=asyncio.subprocess.PIPE,
    )
    proc.stdin.write(data.encode("utf-8"))  # type:ignore
    proc.stdin.close()  # type:ignore
    exitcode = await proc.wait()
    stdout, stderr = await proc.communicate()
    print(stdout.decode("utf-8"))
    if exitcode > 0:
        print(stderr.decode('utf-8'))
    sys.exit(exitcode)


async def run(cmd):
    proc = await asyncio.create_subprocess_shell(
        cmd, stdout=asyncio.subprocess.PIPE, stderr=asyncio.subprocess.PIPE
    )

    stdout, _ = await proc.communicate()
    text = stdout.decode("utf-8")
    try:
        return json.loads(text)
    except Exception:
        lines = [j for j in [i.strip() for i in text.split("\n")] if j]

        space = re.compile(r"\s+")
        ret = {
            "type": cmd,
            "data": [j for j in [space.split(i) for i in lines] if j],
        }
        return ret


async def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--command", "-c", nargs="+", type=str)
    args = parser.parse_args()
    input_map = {}
    for c in args.command:
        data = await run(c)
        if 'type' in data and 'data' in data:
            input_map[data["type"]] = data["data"]
        else:
            input_map[c] = data

    await run_conftest(json.dumps(input_map))


if __name__ == "__main__":
    asyncio.run(main())
