#!/usr/bin/env python3
import os
import json

homelab_ip = os.getenv("HOMELAB_IP")
ansible_user = os.getenv("ANSIBLE_USER")

inventory = {
    "homelab": {
        "hosts": [homelab_ip],
        "vars": {
            "ansible_user": ansible_user
        }
    },
    "_meta": {
        "hostvars": {}
    }
}

print(json.dumps(inventory))
