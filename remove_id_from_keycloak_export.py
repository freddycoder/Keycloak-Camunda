# A python script to remove every id from a keycloak export file
# Only keep the first Id and name it the name of the realm

import json
import sys

if len(sys.argv) != 3:
    print("Usage: python remove_id_from_keycloak_export.py <file-in> <file-out>")
    sys.exit(1)

with open(sys.argv[1]) as f:
    data = json.load(f)

# Remove all ids recursively
def remove_id(d):
    if isinstance(d, dict):
        # Do a for loop to avoid RuntimeError: dictionary changed size during iteration
        for k in list(d.keys()):
            if k == "id":
                del d[k]
            else:
                remove_id(d[k])
    elif isinstance(d, list):
        for v in d:
            remove_id(v)

remove_id(data)

# Rename the first id to the realm name
data["id"] = data["realm"]

with open(sys.argv[2], "w") as f:
    json.dump(data, f, indent=4)

