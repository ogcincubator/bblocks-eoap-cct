#!/bin/bash
# Convert CWL YAML files to JSON for transforms
echo "Converting CWL files to JSON..."
for cwl_file in _sources/cwl-to-ogcprocess/examples/*.cwl; do
  if [ -f "$cwl_file" ]; then
    json_file="${cwl_file%.cwl}.json"
    echo "  Converting $cwl_file -> $json_file"
    python3 -c "import yaml, json, sys; json.dump(yaml.safe_load(open('$cwl_file')), open('$json_file', 'w'), indent=2)" 2>/dev/null || \
    yq eval -o=json "$cwl_file" > "$json_file" 2>/dev/null || \
    echo "    Warning: Could not convert $cwl_file (install python3 with pyyaml or yq)"
  fi
done
