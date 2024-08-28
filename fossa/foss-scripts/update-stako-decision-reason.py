import sys
import yaml

def update_dependencies(yaml_file):
    # Read the YAML file
    with open(yaml_file, 'r') as file:
        data = yaml.safe_load(file)

    # Create a copy of the data to work with
    updated_data = data.copy()

    # Check each dependency in the 'dependencies' list
    for dependency in updated_data.get('dependencies', []):
        bazaar = dependency.get('bazaar', {})
        stako = bazaar.get('stako', "")

        # Check if stako is ESW3 or ESW4
        if stako in ["ESW3", "ESW4"]:
            stako_decision_reason = bazaar.get('stako_decision_reason', "")

            # Check if stako_decision_reason is 'automatic'
            if stako_decision_reason == "automatic":
                print(f"Dependency {dependency.get('ID')} stako_decision_reason updated")

                # Update the stako_decision_reason
                bazaar['stako_decision_reason'] = "to keep aligned with primary dependency"

    # Write the updated data back to the original YAML file
    with open(yaml_file, 'w') as file:
        yaml.dump(updated_data, file, default_flow_style=False, sort_keys=False)

if __name__ == "__main__":
    # Check if the script is called with the correct number of arguments
    if len(sys.argv) != 2:
        print("Usage: python script.py <yaml_file>")
        sys.exit(1)

    # Get the YAML file name from the arguments
    yaml_file = sys.argv[1]

    # Update the dependencies
    update_dependencies(yaml_file)
