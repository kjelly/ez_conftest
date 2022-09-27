#!/usr/bin/env python3
import json
import re


def main():
    with open("/etc/ssh/sshd_config") as ftr:
        content = ftr.read()
    space = re.compile(r"\s")
    lines = [
        j
        for j in [
            i.strip() for i in content.split("\n") if not i.strip().startswith("#")
        ]
        if j
    ]
    ret = {
        "type": "sshd_config",
        "data": [j for j in [space.split(i) for i in lines] if j],
    }

    print(json.dumps(ret, indent=4))


if __name__ == "__main__":
    main()
