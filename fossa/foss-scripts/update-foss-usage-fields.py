import sys
import yaml

def process_yaml(primary_file, secondary_file=None, output_file=None):
    with open(primary_file, 'r') as file:
        primary_data = yaml.safe_load(file)
    if secondary_file:
        with open(secondary_file, 'r') as file:
            secondary_data = yaml.safe_load(file)
    else:
        secondary_data = {}
    update_dependencies(primary_data, secondary_data)
    if output_file:
        with open(output_file, 'w') as file:
            yaml.dump(primary_data, file, default_flow_style=False, sort_keys=False)
    elif not secondary_file:
        for primary_dependency in primary_data.get('dependencies', []):
            print(primary_dependency.get('ID'))

'''
In primary dependencies file if stako_comment is "Copyleft license found."
and usage is "Use as is", look for the dependency in the secondary dependencies file
and copy it's usage info into the output dependencies file if different than "Use as is".
'''

def update_dependencies(primary_data, secondary_data):
    for primary_dependency in primary_data.get('dependencies', []):
        bazaar_info = primary_dependency.get('bazaar', {})
        if 'stako_comment' in bazaar_info and bazaar_info['stako_comment'] == "Copyleft license found.":
            if 'mimer' in primary_dependency:
                mimer_info = primary_dependency['mimer']
                if 'usage' in mimer_info and mimer_info['usage'] == "Use as is":
                    print(f"Dependency {primary_dependency.get('ID')} stako_comment is 'Copyleft license found.' and usage is 'Use as is'")
                    primary_id = primary_dependency.get('ID')
                    dependency_found = False
                    for secondary_dependency in secondary_data.get('dependencies', []):
                        if secondary_dependency.get('ID') == primary_id:
                            dependency_found = True
                            secondary_mimer = secondary_dependency.get('mimer', {})
                            primary_mimer = primary_dependency.setdefault('mimer', {})
                            if 'usage' in secondary_mimer and secondary_mimer['usage'] == "Use as is":
                                print(f"WARNING! No usage information set in secondary file, please update dependency usage manually")
                            else:
                                print(f"Usage info found in secondary file as: \"{secondary_mimer['usage']}\"")
                                primary_mimer['usage'] = secondary_mimer['usage']
                            break  # Stop searching for this dependency once found
                    if not dependency_found:
                        print(f"WARNING! Dependency not found in the secondary file, please update dependency usage manually")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python update_yaml.py <primary_input_yaml_file> [<secondary_input_yaml_file>] [<output_yaml_file>]")
        sys.exit(1)
    primary_file = sys.argv[1]
    secondary_file = sys.argv[2] if len(sys.argv) > 2 else None
    output_file = sys.argv[3] if len(sys.argv) > 3 else None
    process_yaml(primary_file, secondary_file, output_file)