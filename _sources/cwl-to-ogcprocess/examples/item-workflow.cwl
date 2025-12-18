# Copyright 2025 Terradue
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

cwlVersion: v1.2

$graph:
- class: Workflow
  id: item-workflow
  label: "STAC Item Processing Workflow"
  doc: "Workflow that processes STAC Item input and generates output"
  
  requirements:
    - class: InlineJavascriptRequirement
    - class: SchemaDefRequirement
      types:
      - $import: https://raw.githubusercontent.com/eoap/schemas/main/stac.yaml
  
  inputs:
    - id: stac_item
      type: https://raw.githubusercontent.com/eoap/schemas/main/stac.yaml#Item
      label: "STAC Item"
      doc: "STAC Item representing a geospatial asset"
  
  outputs:
    - id: result
      type: File
      outputSource:
        - process_step/result
      label: "Process result"
      doc: "Processed STAC Item information"
  
  steps:
    process_step:
      run: "#clt"
      in:
        stac_item: stac_item
      out:
        - result

- class: CommandLineTool
  id: clt
  label: "Process STAC Item"
  baseCommand: echo
  
  requirements:
    - class: InlineJavascriptRequirement
    - class: SchemaDefRequirement
      types:
      - $import: https://raw.githubusercontent.com/eoap/schemas/main/stac.yaml
  
  inputs:
    stac_item:
      type: https://raw.githubusercontent.com/eoap/schemas/main/stac.yaml#Item
      label: "STAC Item"
      doc: "STAC Item representing a geospatial asset"
      inputBinding:
        valueFrom: |
          ${
            return "STAC Item ID: " + inputs.stac_item.id;
          }
  
  outputs:
    result:
      type: stdout
  
  stdout: result.txt
