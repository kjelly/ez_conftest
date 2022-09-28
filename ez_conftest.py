#!/usr/bin/env python3
import os
import re
import argparse
import json
import asyncio
import sys


async def get_rego_resource(path: str) -> dict:
    cmd = f"opa eval -d {path} 'data.main.resource' -f values"
    proc = await asyncio.create_subprocess_shell(
        cmd,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE,
        cwd=".",
    )
    exitcode = await proc.wait()
    stdout, stderr = await proc.communicate()
    if exitcode > 0:
        print(stderr.decode("utf-8"))
    return json.loads(stdout.decode("utf-8"))[0]


async def run_conftest(data: str, policy: str):
    proc = await asyncio.create_subprocess_shell(
        f"conftest test -p {policy} -",
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
        print(stderr.decode("utf-8"))
    sys.exit(exitcode)


async def run(cmd: str, cwd: str):
    proc = await asyncio.create_subprocess_shell(
        cmd, stdout=asyncio.subprocess.PIPE, stderr=asyncio.subprocess.PIPE,
        cwd=cwd,
    )

    stdout, stderr = await proc.communicate()
    exitcode = await proc.wait()
    if exitcode > 0:
        print(stderr.decode("utf-8"))
    text = stdout.decode("utf-8")
    return text


def handle_output(data: str, format: str):
    if format == "json":
        return json.loads(data)
    if format == "simple":
        lines = [j for j in [i.strip() for i in data.split("\n")] if j]
        space = re.compile(r"\s+")
        return [j for j in [space.split(i) for i in lines] if j]
    return data


async def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--command", "-c", nargs="+", type=str)
    parser.add_argument("--policy", "-p", type=str, default="policy")
    args = parser.parse_args()
    input_map = {}
    for f in os.listdir(args.policy):
        if f.endswith(".rego"):
            resource = await get_rego_resource(f"{args.policy}/{f}")
            if resource["kind"] == "command":
                if isinstance(resource["command"], list):
                    for i in resource["command"]:
                        stdout = await run(i, args.policy)
                        input_map[i] = handle_output(stdout, resource["format"])
                elif isinstance(resource["command"], str):
                    stdout = await run(resource["command"], args.policy)
                    input_map[resource["command"]] = handle_output(
                        stdout, resource["format"]
                    )

    await run_conftest(json.dumps(input_map), args.policy)


if __name__ == "__main__":
    asyncio.run(main())
