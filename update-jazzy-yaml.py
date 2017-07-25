import yaml
import os

def list_index_dict_with_name(l, name):
    for index, entry in enumerate(l):
        if entry['name'] == name:
            return index
    return None

def walk_dir(name, into_groups):
    groups = into_groups
    for root, directories, files in os.walk(name):
        for file in files:
            if file.endswith(".swift"):
                file = file.split(".swift")[0]
                components = root.split("/")
                category = " ".join(components)

                index = list_index_dict_with_name(groups, category)

                if index is not None:
                    groups[index]['children'].append(file)
                else:
                    groups.append({'name': category, 'children': [file]})
    return groups

import shutil

print("Writing .jazzy-base.yaml to .jazzy.yaml")
shutil.copy(".jazzy-base.yaml", ".jazzy.yaml")

print("Generating directory representation")
path_hierarchy_app = walk_dir("JenkinsiOS", [])
path_hierarchy_all = walk_dir("JenkinsiOSTodayExtension", path_hierarchy_app)

with open('.jazzy.yaml', 'a') as f:
    print("Writing representation to .jazzy.yaml")
    yaml.dump({'custom_categories': path_hierarchy_all}, f, default_flow_style=False)
