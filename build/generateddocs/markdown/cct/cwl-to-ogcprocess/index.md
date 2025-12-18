
# CWL to OGC API Processes Profile (Model)

`eoap.cct.cwl-to-ogcprocess` *v1.0*

Profile for converting CWL CommandLineTool and Workflow definitions to OGC API Processes processDescriptions

[*Status*](http://www.opengis.net/def/status): Under development

## Description

This building block provides a comprehensive transformation profile that converts Common Workflow Language (CWL) definitions into OGC API - Processes processDescription schemas. It supports both CommandLineTool and Workflow classes, along with all EOAP custom types.

## Purpose

The CWL to OGC API Processes profile enables:

1. **Automatic conversion**: Transform CWL workflow definitions into OGC-compliant process descriptions
2. **Type mapping**: Map CWL types (including custom types) to JSON Schema format
3. **Metadata preservation**: Maintain documentation, labels, and descriptions from CWL
4. **Standards compliance**: Generate processDescriptions conforming to OGC API - Processes Part 1

## Supported CWL Types

### Standard CWL Types
- Primitive types: `string`, `int`, `long`, `float`, `double`, `boolean`
- File types: `File`, `Directory`, `stdout`, `stderr`

### EOAP Custom Types

#### BBox Types
- `bbox.yaml#BBox` - 2D bounding box
- `bbox.yaml#BBox3D` - 3D bounding box with elevation
- Maps to OGC bbox schema with CRS support

#### GeoJSON Types
- `geojson.yaml#Point` - GeoJSON Point geometry
- `geojson.yaml#Feature` - GeoJSON Feature
- `geojson.yaml#FeatureCollection` - GeoJSON FeatureCollection
- Maps to GeoJSON format with appropriate schemas

#### STAC Types
- `stac.yaml#Item` - STAC Item
- `stac.yaml#Collection` - STAC Collection
- `stac.yaml#Catalog` - STAC Catalog
- Maps to STAC format specifications

#### String Format Types
- `string-format.yaml#DateTime` - ISO 8601 date-time
- `string-format.yaml#Date` - ISO 8601 date
- `string-format.yaml#Time` - Time of day
- `string-format.yaml#Duration` - ISO 8601 duration
- `string-format.yaml#URI` - Uniform Resource Identifier
- `string-format.yaml#Email` - Email address
- `string-format.yaml#UUID` - Universally Unique Identifier
- `string-format.yaml#IPv4` - IPv4 address
- `string-format.yaml#IPv6` - IPv6 address
- `string-format.yaml#Hostname` - DNS hostname

## Transformation Process

The transformation follows these steps:

1. **Extract root element**: Handle both direct CWL documents and those with `$graph` structure
2. **Process metadata**: Extract id, title, description from CWL document
3. **Map inputs**: Convert CWL inputs to OGC process inputs with appropriate schemas
4. **Map outputs**: Convert CWL outputs to OGC process outputs with appropriate schemas
5. **Add execution options**: Include jobControlOptions and outputTransmission modes


## Examples

### BBox Workflow
#### yaml
```yaml
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
  id: bbox-workflow
  label: "OGC BBox Processing Workflow"
  doc: "Workflow that processes OGC BBox input and generates output"
  
  requirements:
    - class: InlineJavascriptRequirement
    - class: SchemaDefRequirement
      types:
      - $import: https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml
  
  inputs:
    - id: aoi
      type: https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml#BBox
      label: "Area of interest"
      doc: "Area of interest defined as a bounding box"
  
  outputs:
    - id: echo_output
      type: File
      outputSource:
        - echo_step/echo_output
      label: "Echo output"
      doc: "Echoed BBox information"
  
  steps:
    echo_step:
      run: "#clt"
      in:
        aoi: aoi
      out:
        - echo_output

- class: CommandLineTool
  id: clt
  label: "Echo OGC BBox"
  baseCommand: echo
  
  requirements:
    - class: InlineJavascriptRequirement
    - class: SchemaDefRequirement
      types:
      - $import: https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml
  
  inputs:
    aoi:
      type: https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml#BBox
      label: "Area of interest"
      doc: "Area of interest defined as a bounding box"
      inputBinding:
        valueFrom: |
          ${
            // Validate the length of bbox to be either 4 or 6
            var bboxLength = inputs.aoi.bbox.length;
            if (bboxLength !== 4 && bboxLength !== 6) {
              throw "Invalid bbox length: bbox must have either 4 or 6 elements.";
            }
            // Convert bbox array to a space-separated string for echo
            return inputs.aoi.bbox.join(' ') + " CRS: " + inputs.aoi.crs;
          }
  
  outputs:
    echo_output:
      type: stdout
  
  stdout: echo_output.txt

```

#### json
```json
{
  "cwlVersion": "v1.2",
  "$graph": [
    {
      "class": "Workflow",
      "id": "bbox-workflow",
      "label": "OGC BBox Processing Workflow",
      "doc": "Workflow that processes OGC BBox input and generates output",
      "requirements": [
        {
          "class": "InlineJavascriptRequirement"
        },
        {
          "class": "SchemaDefRequirement",
          "types": [
            {
              "$import": "https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml"
            }
          ]
        }
      ],
      "inputs": [
        {
          "id": "aoi",
          "type": "https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml#BBox",
          "label": "Area of interest",
          "doc": "Area of interest defined as a bounding box"
        }
      ],
      "outputs": [
        {
          "id": "echo_output",
          "type": "File",
          "outputSource": [
            "echo_step/echo_output"
          ],
          "label": "Echo output",
          "doc": "Echoed BBox information"
        }
      ],
      "steps": {
        "echo_step": {
          "run": "#clt",
          "in": {
            "aoi": "aoi"
          },
          "out": [
            "echo_output"
          ]
        }
      }
    },
    {
      "class": "CommandLineTool",
      "id": "clt",
      "label": "Echo OGC BBox",
      "baseCommand": "echo",
      "requirements": [
        {
          "class": "InlineJavascriptRequirement"
        },
        {
          "class": "SchemaDefRequirement",
          "types": [
            {
              "$import": "https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml"
            }
          ]
        }
      ],
      "inputs": {
        "aoi": {
          "type": "https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml#BBox",
          "label": "Area of interest",
          "doc": "Area of interest defined as a bounding box",
          "inputBinding": {
            "valueFrom": "${\n  // Validate the length of bbox to be either 4 or 6\n  var bboxLength = inputs.aoi.bbox.length;\n  if (bboxLength !== 4 && bboxLength !== 6) {\n    throw \"Invalid bbox length: bbox must have either 4 or 6 elements.\";\n  }\n  // Convert bbox array to a space-separated string for echo\n  return inputs.aoi.bbox.join(' ') + \" CRS: \" + inputs.aoi.crs;\n}\n"
          }
        }
      },
      "outputs": {
        "echo_output": {
          "type": "stdout"
        }
      },
      "stdout": "echo_output.txt"
    }
  ]
}

```

#### jsonld
```jsonld
{
  "@context": "https://geolabs.github.io/bblocks-eoap-cct/build/annotated/cct/cwl-to-ogcprocess/context.jsonld",
  "cwlVersion": "v1.2",
  "$graph": [
    {
      "class": "Workflow",
      "id": "bbox-workflow",
      "label": "OGC BBox Processing Workflow",
      "doc": "Workflow that processes OGC BBox input and generates output",
      "requirements": [
        {
          "class": "InlineJavascriptRequirement"
        },
        {
          "class": "SchemaDefRequirement",
          "types": [
            {
              "$import": "https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml"
            }
          ]
        }
      ],
      "inputs": [
        {
          "id": "aoi",
          "type": "https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml#BBox",
          "label": "Area of interest",
          "doc": "Area of interest defined as a bounding box"
        }
      ],
      "outputs": [
        {
          "id": "echo_output",
          "type": "File",
          "outputSource": [
            "echo_step/echo_output"
          ],
          "label": "Echo output",
          "doc": "Echoed BBox information"
        }
      ],
      "steps": {
        "echo_step": {
          "run": "#clt",
          "in": {
            "aoi": "aoi"
          },
          "out": [
            "echo_output"
          ]
        }
      }
    },
    {
      "class": "CommandLineTool",
      "id": "clt",
      "label": "Echo OGC BBox",
      "baseCommand": "echo",
      "requirements": [
        {
          "class": "InlineJavascriptRequirement"
        },
        {
          "class": "SchemaDefRequirement",
          "types": [
            {
              "$import": "https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml"
            }
          ]
        }
      ],
      "inputs": {
        "aoi": {
          "type": "https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml#BBox",
          "label": "Area of interest",
          "doc": "Area of interest defined as a bounding box",
          "inputBinding": {
            "valueFrom": "${\n  // Validate the length of bbox to be either 4 or 6\n  var bboxLength = inputs.aoi.bbox.length;\n  if (bboxLength !== 4 && bboxLength !== 6) {\n    throw \"Invalid bbox length: bbox must have either 4 or 6 elements.\";\n  }\n  // Convert bbox array to a space-separated string for echo\n  return inputs.aoi.bbox.join(' ') + \" CRS: \" + inputs.aoi.crs;\n}\n"
          }
        }
      },
      "outputs": {
        "echo_output": {
          "type": "stdout"
        }
      },
      "stdout": "echo_output.txt"
    }
  ]
}
```

#### ttl
```ttl
@prefix cwl: <https://w3id.org/cwl/cwl#> .
@prefix dct: <http://purl.org/dc/terms/> .
@prefix geo: <http://www.opengis.net/ont/geosparql#> .
@prefix ns1: <rdf:> .
@prefix ogcproc: <http://www.opengis.net/def/ogcapi/processes/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

[] cwl:cwlVersion <file:///github/workspace/v1.2> ;
    cwl:graph [ rdfs:label "Echo OGC BBox"^^xsd:string ;
            dct:identifier <file:///github/workspace/clt> ;
            ogcproc:input _:N918ff8aa5f5b4077b2a113a3c4419c66 ;
            ogcproc:output _:N23f28c41835540b6867578826ea57f19 ;
            cwl:baseCommand "\"echo\""^^rdf:JSON ;
            cwl:input _:N918ff8aa5f5b4077b2a113a3c4419c66 ;
            cwl:output _:N23f28c41835540b6867578826ea57f19 ;
            cwl:requirements [ ns1:type <file:///github/workspace/InlineJavascriptRequirement> ],
                [ cwl:types [ cwl:import <https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml> ] ;
                    ns1:type <file:///github/workspace/SchemaDefRequirement> ] ;
            cwl:stdout "echo_output.txt"^^xsd:string ;
            ns1:type <file:///github/workspace/CommandLineTool> ],
        [ rdfs:label "OGC BBox Processing Workflow"^^xsd:string ;
            dct:identifier <file:///github/workspace/bbox-workflow> ;
            ogcproc:input _:Na6e468c76d08461c9153ce59b3a95a5e ;
            ogcproc:output _:N1d8c6926db324222922718737682f815 ;
            rdfs:comment "Workflow that processes OGC BBox input and generates output"^^xsd:string ;
            cwl:input _:Na6e468c76d08461c9153ce59b3a95a5e ;
            cwl:output _:N1d8c6926db324222922718737682f815 ;
            cwl:requirements [ cwl:types [ cwl:import <https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml> ] ;
                    ns1:type <file:///github/workspace/SchemaDefRequirement> ],
                [ ns1:type <file:///github/workspace/InlineJavascriptRequirement> ] ;
            cwl:steps [ cwl:echo_step [ cwl:in [ cwl:aoi "aoi" ] ;
                            cwl:out ( "echo_output" ) ;
                            cwl:run <file:///github/workspace/#clt> ] ] ;
            ns1:type <file:///github/workspace/Workflow> ] .

_:N2ef283060df34ccbbbc9a20a4de88be2 cwl:aoi [ rdfs:label "Area of interest"^^xsd:string ;
            ogcproc:itemsType "number"^^xsd:string ;
            ogcproc:maxItems 6 ;
            ogcproc:minItems 4 ;
            ogcproc:schemaType "array"^^xsd:string ;
            rdfs:comment "Area of interest defined as a bounding box"^^xsd:string ;
            rdfs:seeAlso geo:BoundingBox ;
            cwl:inputBinding [ cwl:valueFrom """${
  // Validate the length of bbox to be either 4 or 6
  var bboxLength = inputs.aoi.bbox.length;
  if (bboxLength !== 4 && bboxLength !== 6) {
    throw "Invalid bbox length: bbox must have either 4 or 6 elements.";
  }
  // Convert bbox array to a space-separated string for echo
  return inputs.aoi.bbox.join(' ') + " CRS: " + inputs.aoi.crs;
}
"""^^xsd:string ] ;
            cwl:type <https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml#BBox> ] .

_:N51819f1fe53045fbaa45ea905e03f182 cwl:echo_output [ cwl:type <file:///github/workspace/stdout> ] .

_:N8e43ce6f56a34818a16be5fc76be64e6 rdfs:label "Echo output"^^xsd:string ;
    dct:identifier <file:///github/workspace/echo_output> ;
    rdfs:comment "Echoed BBox information"^^xsd:string ;
    cwl:outputSource <file:///github/workspace/echo_step/echo_output> ;
    cwl:type <file:///github/workspace/File> .

_:Nff2ddb3123c24035a35b4c9980d59436 rdfs:label "Area of interest"^^xsd:string ;
    dct:identifier <file:///github/workspace/aoi> ;
    ogcproc:itemsType "number"^^xsd:string ;
    ogcproc:maxItems 6 ;
    ogcproc:minItems 4 ;
    ogcproc:schemaType "array"^^xsd:string ;
    rdfs:comment "Area of interest defined as a bounding box"^^xsd:string ;
    rdfs:seeAlso geo:BoundingBox ;
    cwl:type <https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml#BBox> .

_:N1d8c6926db324222922718737682f815 a ogcproc:OutputDescription ;
    rdf:first _:N8e43ce6f56a34818a16be5fc76be64e6 ;
    rdf:rest () .

_:N23f28c41835540b6867578826ea57f19 a ogcproc:OutputDescription ;
    rdf:first _:N51819f1fe53045fbaa45ea905e03f182 ;
    rdf:rest () .

_:N918ff8aa5f5b4077b2a113a3c4419c66 a ogcproc:InputDescription ;
    rdf:first _:N2ef283060df34ccbbbc9a20a4de88be2 ;
    rdf:rest () .

_:Na6e468c76d08461c9153ce59b3a95a5e a ogcproc:InputDescription ;
    rdf:first _:Nff2ddb3123c24035a35b4c9980d59436 ;
    rdf:rest () .


```


### GeoJSON Feature Workflow
#### yaml
```yaml
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
  id: feature-workflow
  label: "GeoJSON Feature Processing Workflow"
  doc: "Workflow that processes GeoJSON Feature input and generates output"
  
  requirements:
    - class: InlineJavascriptRequirement
    - class: SchemaDefRequirement
      types:
      - $import: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml
  
  inputs:
    - id: aoi
      type: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml#Feature
      label: "Area of interest"
      doc: "Area of interest defined in GeoJSON format"
  
  outputs:
    - id: echo_output
      type: File
      outputSource:
        - echo_step/echo_output
      label: "Echo output"
      doc: "Echoed GeoJSON Feature information"
  
  steps:
    echo_step:
      run: "#clt"
      in:
        aoi: aoi
      out:
        - echo_output

- class: CommandLineTool
  id: clt
  label: "Echo GeoJSON Feature"
  baseCommand: echo
  
  requirements:
    - class: InlineJavascriptRequirement
    - class: SchemaDefRequirement
      types:
      - $import: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml
  
  inputs:
    aoi:
      type: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml#Feature
      label: "Area of interest"
      doc: "Area of interest defined in GeoJSON format"
      inputBinding:
        valueFrom: |
          ${
            // Validate if type is 'Feature'
            if (inputs.aoi.type !== 'Feature') {
              throw "Invalid GeoJSON type: expected 'Feature', got '" + inputs.aoi.type + "'";
            }
            // get the Feature geometry type
            return "Feature with id '" + inputs.aoi.id + "' is of type: " + inputs.aoi.geometry.type;
          }
  
  outputs:
    echo_output:
      type: stdout
  
  stdout: echo_output.txt

```

#### json
```json
{
  "cwlVersion": "v1.2",
  "$graph": [
    {
      "class": "Workflow",
      "id": "feature-workflow",
      "label": "GeoJSON Feature Processing Workflow",
      "doc": "Workflow that processes GeoJSON Feature input and generates output",
      "requirements": [
        {
          "class": "InlineJavascriptRequirement"
        },
        {
          "class": "SchemaDefRequirement",
          "types": [
            {
              "$import": "https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml"
            }
          ]
        }
      ],
      "inputs": [
        {
          "id": "aoi",
          "type": "https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml#Feature",
          "label": "Area of interest",
          "doc": "Area of interest defined in GeoJSON format"
        }
      ],
      "outputs": [
        {
          "id": "echo_output",
          "type": "File",
          "outputSource": [
            "echo_step/echo_output"
          ],
          "label": "Echo output",
          "doc": "Echoed GeoJSON Feature information"
        }
      ],
      "steps": {
        "echo_step": {
          "run": "#clt",
          "in": {
            "aoi": "aoi"
          },
          "out": [
            "echo_output"
          ]
        }
      }
    },
    {
      "class": "CommandLineTool",
      "id": "clt",
      "label": "Echo GeoJSON Feature",
      "baseCommand": "echo",
      "requirements": [
        {
          "class": "InlineJavascriptRequirement"
        },
        {
          "class": "SchemaDefRequirement",
          "types": [
            {
              "$import": "https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml"
            }
          ]
        }
      ],
      "inputs": {
        "aoi": {
          "type": "https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml#Feature",
          "label": "Area of interest",
          "doc": "Area of interest defined in GeoJSON format",
          "inputBinding": {
            "valueFrom": "${\n  // Validate if type is 'Feature'\n  if (inputs.aoi.type !== 'Feature') {\n    throw \"Invalid GeoJSON type: expected 'Feature', got '\" + inputs.aoi.type + \"'\";\n  }\n  // get the Feature geometry type\n  return \"Feature with id '\" + inputs.aoi.id + \"' is of type: \" + inputs.aoi.geometry.type;\n}\n"
          }
        }
      },
      "outputs": {
        "echo_output": {
          "type": "stdout"
        }
      },
      "stdout": "echo_output.txt"
    }
  ]
}

```

#### jsonld
```jsonld
{
  "@context": "https://geolabs.github.io/bblocks-eoap-cct/build/annotated/cct/cwl-to-ogcprocess/context.jsonld",
  "cwlVersion": "v1.2",
  "$graph": [
    {
      "class": "Workflow",
      "id": "feature-workflow",
      "label": "GeoJSON Feature Processing Workflow",
      "doc": "Workflow that processes GeoJSON Feature input and generates output",
      "requirements": [
        {
          "class": "InlineJavascriptRequirement"
        },
        {
          "class": "SchemaDefRequirement",
          "types": [
            {
              "$import": "https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml"
            }
          ]
        }
      ],
      "inputs": [
        {
          "id": "aoi",
          "type": "https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml#Feature",
          "label": "Area of interest",
          "doc": "Area of interest defined in GeoJSON format"
        }
      ],
      "outputs": [
        {
          "id": "echo_output",
          "type": "File",
          "outputSource": [
            "echo_step/echo_output"
          ],
          "label": "Echo output",
          "doc": "Echoed GeoJSON Feature information"
        }
      ],
      "steps": {
        "echo_step": {
          "run": "#clt",
          "in": {
            "aoi": "aoi"
          },
          "out": [
            "echo_output"
          ]
        }
      }
    },
    {
      "class": "CommandLineTool",
      "id": "clt",
      "label": "Echo GeoJSON Feature",
      "baseCommand": "echo",
      "requirements": [
        {
          "class": "InlineJavascriptRequirement"
        },
        {
          "class": "SchemaDefRequirement",
          "types": [
            {
              "$import": "https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml"
            }
          ]
        }
      ],
      "inputs": {
        "aoi": {
          "type": "https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml#Feature",
          "label": "Area of interest",
          "doc": "Area of interest defined in GeoJSON format",
          "inputBinding": {
            "valueFrom": "${\n  // Validate if type is 'Feature'\n  if (inputs.aoi.type !== 'Feature') {\n    throw \"Invalid GeoJSON type: expected 'Feature', got '\" + inputs.aoi.type + \"'\";\n  }\n  // get the Feature geometry type\n  return \"Feature with id '\" + inputs.aoi.id + \"' is of type: \" + inputs.aoi.geometry.type;\n}\n"
          }
        }
      },
      "outputs": {
        "echo_output": {
          "type": "stdout"
        }
      },
      "stdout": "echo_output.txt"
    }
  ]
}
```

#### ttl
```ttl
@prefix cwl: <https://w3id.org/cwl/cwl#> .
@prefix dct: <http://purl.org/dc/terms/> .
@prefix ns1: <rdf:> .
@prefix ogcproc: <http://www.opengis.net/def/ogcapi/processes/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

[] cwl:cwlVersion <file:///github/workspace/v1.2> ;
    cwl:graph [ rdfs:label "Echo GeoJSON Feature"^^xsd:string ;
            dct:identifier <file:///github/workspace/clt> ;
            ogcproc:input _:Nb3ba4bc271404733b6fe1025f9f3695f ;
            ogcproc:output _:N3bc624f5d6364fa08ed084bd679eaf47 ;
            cwl:baseCommand "\"echo\""^^rdf:JSON ;
            cwl:input _:Nb3ba4bc271404733b6fe1025f9f3695f ;
            cwl:output _:N3bc624f5d6364fa08ed084bd679eaf47 ;
            cwl:requirements [ ns1:type <file:///github/workspace/InlineJavascriptRequirement> ],
                [ cwl:types [ cwl:import <https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml> ] ;
                    ns1:type <file:///github/workspace/SchemaDefRequirement> ] ;
            cwl:stdout "echo_output.txt"^^xsd:string ;
            ns1:type <file:///github/workspace/CommandLineTool> ],
        [ rdfs:label "GeoJSON Feature Processing Workflow"^^xsd:string ;
            dct:identifier <file:///github/workspace/feature-workflow> ;
            ogcproc:input _:N0f879c478bd74508834e78a45b5166ee ;
            ogcproc:output _:N58185ee233984825aeb66ab30a94522d ;
            rdfs:comment "Workflow that processes GeoJSON Feature input and generates output"^^xsd:string ;
            cwl:input _:N0f879c478bd74508834e78a45b5166ee ;
            cwl:output _:N58185ee233984825aeb66ab30a94522d ;
            cwl:requirements [ ns1:type <file:///github/workspace/InlineJavascriptRequirement> ],
                [ cwl:types [ cwl:import <https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml> ] ;
                    ns1:type <file:///github/workspace/SchemaDefRequirement> ] ;
            cwl:steps [ cwl:echo_step [ cwl:in [ cwl:aoi "aoi" ] ;
                            cwl:out ( "echo_output" ) ;
                            cwl:run <file:///github/workspace/#clt> ] ] ;
            ns1:type <file:///github/workspace/Workflow> ] .

_:N012100b1314948e2a19a33fa7318d2d3 rdfs:label "Area of interest"^^xsd:string ;
    dct:format <https://www.iana.org/assignments/media-types/application/geo+json> ;
    ogcproc:schemaType "object"^^xsd:string ;
    rdfs:comment "Area of interest defined in GeoJSON format"^^xsd:string ;
    rdfs:seeAlso <https://purl.org/geojson/vocab#Feature> ;
    cwl:inputBinding [ cwl:valueFrom """${
  // Validate if type is 'Feature'
  if (inputs.aoi.type !== 'Feature') {
    throw "Invalid GeoJSON type: expected 'Feature', got '" + inputs.aoi.type + "'";
  }
  // get the Feature geometry type
  return "Feature with id '" + inputs.aoi.id + "' is of type: " + inputs.aoi.geometry.type;
}
"""^^xsd:string ] ;
    cwl:type <https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml#Feature> .

_:N36f1b521b2984066870805ea18d00e16 rdfs:label "Area of interest"^^xsd:string ;
    dct:format <https://www.iana.org/assignments/media-types/application/geo+json> ;
    dct:identifier <file:///github/workspace/aoi> ;
    ogcproc:schemaType "object"^^xsd:string ;
    rdfs:comment "Area of interest defined in GeoJSON format"^^xsd:string ;
    rdfs:seeAlso <https://purl.org/geojson/vocab#Feature> ;
    cwl:type <https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml#Feature> .

_:N4eae8ab58dc04127a2652f52dbbc51e0 cwl:echo_output [ cwl:type <file:///github/workspace/stdout> ] .

_:N7ec615905a9e4273b18b2cc6a4349131 cwl:aoi _:N012100b1314948e2a19a33fa7318d2d3 .

_:Nf526bf7c784f4c3ea7347985fafd1632 rdfs:label "Echo output"^^xsd:string ;
    dct:identifier <file:///github/workspace/echo_output> ;
    rdfs:comment "Echoed GeoJSON Feature information"^^xsd:string ;
    cwl:outputSource <file:///github/workspace/echo_step/echo_output> ;
    cwl:type <file:///github/workspace/File> .

_:N0f879c478bd74508834e78a45b5166ee a ogcproc:InputDescription ;
    rdf:first _:N36f1b521b2984066870805ea18d00e16 ;
    rdf:rest () .

_:N3bc624f5d6364fa08ed084bd679eaf47 a ogcproc:OutputDescription ;
    rdf:first _:N4eae8ab58dc04127a2652f52dbbc51e0 ;
    rdf:rest () .

_:N58185ee233984825aeb66ab30a94522d a ogcproc:OutputDescription ;
    rdf:first _:Nf526bf7c784f4c3ea7347985fafd1632 ;
    rdf:rest () .

_:Nb3ba4bc271404733b6fe1025f9f3695f a ogcproc:InputDescription ;
    rdf:first _:N7ec615905a9e4273b18b2cc6a4349131 ;
    rdf:rest () .


```


### STAC Item Workflow
#### yaml
```yaml
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

```

#### json
```json
{
  "cwlVersion": "v1.2",
  "$graph": [
    {
      "class": "Workflow",
      "id": "item-workflow",
      "label": "STAC Item Processing Workflow",
      "doc": "Workflow that processes STAC Item input and generates output",
      "requirements": [
        {
          "class": "InlineJavascriptRequirement"
        },
        {
          "class": "SchemaDefRequirement",
          "types": [
            {
              "$import": "https://raw.githubusercontent.com/eoap/schemas/main/stac.yaml"
            }
          ]
        }
      ],
      "inputs": [
        {
          "id": "stac_item",
          "type": "https://raw.githubusercontent.com/eoap/schemas/main/stac.yaml#Item",
          "label": "STAC Item",
          "doc": "STAC Item representing a geospatial asset"
        }
      ],
      "outputs": [
        {
          "id": "result",
          "type": "File",
          "outputSource": [
            "process_step/result"
          ],
          "label": "Process result",
          "doc": "Processed STAC Item information"
        }
      ],
      "steps": {
        "process_step": {
          "run": "#clt",
          "in": {
            "stac_item": "stac_item"
          },
          "out": [
            "result"
          ]
        }
      }
    },
    {
      "class": "CommandLineTool",
      "id": "clt",
      "label": "Process STAC Item",
      "baseCommand": "echo",
      "requirements": [
        {
          "class": "InlineJavascriptRequirement"
        },
        {
          "class": "SchemaDefRequirement",
          "types": [
            {
              "$import": "https://raw.githubusercontent.com/eoap/schemas/main/stac.yaml"
            }
          ]
        }
      ],
      "inputs": {
        "stac_item": {
          "type": "https://raw.githubusercontent.com/eoap/schemas/main/stac.yaml#Item",
          "label": "STAC Item",
          "doc": "STAC Item representing a geospatial asset",
          "inputBinding": {
            "valueFrom": "${\n  return \"STAC Item ID: \" + inputs.stac_item.id;\n}\n"
          }
        }
      },
      "outputs": {
        "result": {
          "type": "stdout"
        }
      },
      "stdout": "result.txt"
    }
  ]
}

```

#### jsonld
```jsonld
{
  "@context": "https://geolabs.github.io/bblocks-eoap-cct/build/annotated/cct/cwl-to-ogcprocess/context.jsonld",
  "cwlVersion": "v1.2",
  "$graph": [
    {
      "class": "Workflow",
      "id": "item-workflow",
      "label": "STAC Item Processing Workflow",
      "doc": "Workflow that processes STAC Item input and generates output",
      "requirements": [
        {
          "class": "InlineJavascriptRequirement"
        },
        {
          "class": "SchemaDefRequirement",
          "types": [
            {
              "$import": "https://raw.githubusercontent.com/eoap/schemas/main/stac.yaml"
            }
          ]
        }
      ],
      "inputs": [
        {
          "id": "stac_item",
          "type": "https://raw.githubusercontent.com/eoap/schemas/main/stac.yaml#Item",
          "label": "STAC Item",
          "doc": "STAC Item representing a geospatial asset"
        }
      ],
      "outputs": [
        {
          "id": "result",
          "type": "File",
          "outputSource": [
            "process_step/result"
          ],
          "label": "Process result",
          "doc": "Processed STAC Item information"
        }
      ],
      "steps": {
        "process_step": {
          "run": "#clt",
          "in": {
            "stac_item": "stac_item"
          },
          "out": [
            "result"
          ]
        }
      }
    },
    {
      "class": "CommandLineTool",
      "id": "clt",
      "label": "Process STAC Item",
      "baseCommand": "echo",
      "requirements": [
        {
          "class": "InlineJavascriptRequirement"
        },
        {
          "class": "SchemaDefRequirement",
          "types": [
            {
              "$import": "https://raw.githubusercontent.com/eoap/schemas/main/stac.yaml"
            }
          ]
        }
      ],
      "inputs": {
        "stac_item": {
          "type": "https://raw.githubusercontent.com/eoap/schemas/main/stac.yaml#Item",
          "label": "STAC Item",
          "doc": "STAC Item representing a geospatial asset",
          "inputBinding": {
            "valueFrom": "${\n  return \"STAC Item ID: \" + inputs.stac_item.id;\n}\n"
          }
        }
      },
      "outputs": {
        "result": {
          "type": "stdout"
        }
      },
      "stdout": "result.txt"
    }
  ]
}
```

#### ttl
```ttl
@prefix cwl: <https://w3id.org/cwl/cwl#> .
@prefix dct: <http://purl.org/dc/terms/> .
@prefix ns1: <rdf:> .
@prefix ogcproc: <http://www.opengis.net/def/ogcapi/processes/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

[] cwl:cwlVersion <file:///github/workspace/v1.2> ;
    cwl:graph [ rdfs:label "Process STAC Item"^^xsd:string ;
            dct:identifier <file:///github/workspace/clt> ;
            ogcproc:input _:N78020cef75184d139bade65a0e05bffa ;
            ogcproc:output _:N78b1baa316584a18b5657920b36129ad ;
            cwl:baseCommand "\"echo\""^^rdf:JSON ;
            cwl:input _:N78020cef75184d139bade65a0e05bffa ;
            cwl:output _:N78b1baa316584a18b5657920b36129ad ;
            cwl:requirements [ cwl:types [ cwl:import <https://raw.githubusercontent.com/eoap/schemas/main/stac.yaml> ] ;
                    ns1:type <file:///github/workspace/SchemaDefRequirement> ],
                [ ns1:type <file:///github/workspace/InlineJavascriptRequirement> ] ;
            cwl:stdout "result.txt"^^xsd:string ;
            ns1:type <file:///github/workspace/CommandLineTool> ],
        [ rdfs:label "STAC Item Processing Workflow"^^xsd:string ;
            dct:identifier <file:///github/workspace/item-workflow> ;
            ogcproc:input _:Nc14b3670ceaf4c26ba1f6d123c3851b0 ;
            ogcproc:output _:N98e373180ea54c78bcc105bd510b3c56 ;
            rdfs:comment "Workflow that processes STAC Item input and generates output"^^xsd:string ;
            cwl:input _:Nc14b3670ceaf4c26ba1f6d123c3851b0 ;
            cwl:output _:N98e373180ea54c78bcc105bd510b3c56 ;
            cwl:requirements [ ns1:type <file:///github/workspace/InlineJavascriptRequirement> ],
                [ cwl:types [ cwl:import <https://raw.githubusercontent.com/eoap/schemas/main/stac.yaml> ] ;
                    ns1:type <file:///github/workspace/SchemaDefRequirement> ] ;
            cwl:steps [ cwl:process_step [ cwl:in [ cwl:stac_item "stac_item" ] ;
                            cwl:out ( "result" ) ;
                            cwl:run <file:///github/workspace/#clt> ] ] ;
            ns1:type <file:///github/workspace/Workflow> ] .

_:N1cab67d67df9412a839381c97cc06b87 cwl:result [ cwl:type <file:///github/workspace/stdout> ] .

_:N2ed8861608604a3580432d8698931578 cwl:stac_item [ rdfs:label "STAC Item"^^xsd:string ;
            dct:format <https://www.iana.org/assignments/media-types/application/json> ;
            ogcproc:schemaType "object"^^xsd:string ;
            rdfs:comment "STAC Item representing a geospatial asset"^^xsd:string ;
            rdfs:seeAlso <https://stacspec.org/#item-spec> ;
            cwl:inputBinding [ cwl:valueFrom """${
  return "STAC Item ID: " + inputs.stac_item.id;
}
"""^^xsd:string ] ;
            cwl:type <https://raw.githubusercontent.com/eoap/schemas/main/stac.yaml#Item> ] .

_:N46517589c0a541ce9b1d074de6efa936 rdfs:label "Process result"^^xsd:string ;
    dct:identifier <file:///github/workspace/result> ;
    rdfs:comment "Processed STAC Item information"^^xsd:string ;
    cwl:outputSource <file:///github/workspace/process_step/result> ;
    cwl:type <file:///github/workspace/File> .

_:Nac714017df834f139702b1fa1abd8dff rdfs:label "STAC Item"^^xsd:string ;
    dct:format <https://www.iana.org/assignments/media-types/application/json> ;
    dct:identifier <file:///github/workspace/stac_item> ;
    ogcproc:schemaType "object"^^xsd:string ;
    rdfs:comment "STAC Item representing a geospatial asset"^^xsd:string ;
    rdfs:seeAlso <https://stacspec.org/#item-spec> ;
    cwl:type <https://raw.githubusercontent.com/eoap/schemas/main/stac.yaml#Item> .

_:N78020cef75184d139bade65a0e05bffa a ogcproc:InputDescription ;
    rdf:first _:N2ed8861608604a3580432d8698931578 ;
    rdf:rest () .

_:N78b1baa316584a18b5657920b36129ad a ogcproc:OutputDescription ;
    rdf:first _:N1cab67d67df9412a839381c97cc06b87 ;
    rdf:rest () .

_:N98e373180ea54c78bcc105bd510b3c56 a ogcproc:OutputDescription ;
    rdf:first _:N46517589c0a541ce9b1d074de6efa936 ;
    rdf:rest () .

_:Nc14b3670ceaf4c26ba1f6d123c3851b0 a ogcproc:InputDescription ;
    rdf:first _:Nac714017df834f139702b1fa1abd8dff ;
    rdf:rest () .


```


### Water Bodies Detection Workflow
#### yaml
```yaml
cwlVersion: v1.0
$namespaces:
  s: https://schema.org/
s:softwareVersion: 1.4.1
schemas:
  - http://schema.org/version/9.0/schemaorg-current-http.rdf
$graph:
  - class: Workflow
    id: water-bodies
    label: Water bodies detection based on NDWI and otsu threshold
    doc: Water bodies detection based on NDWI and otsu threshold applied to Sentinel-2 COG STAC items
    requirements:
      - class: ScatterFeatureRequirement
      - class: SubworkflowFeatureRequirement
      - class: SchemaDefRequirement
        types:
        - $import: https://raw.githubusercontent.com/eoap/schemas/main/stac.yaml
    inputs:
      aoi:
        label: area of interest
        doc: area of interest as a bounding box
        type: string
      epsg:
        label: EPSG code
        doc: EPSG code
        type: string
        default: "EPSG:4326"
      stac_items:
        label: Sentinel-2 STAC items
        doc: list of Sentinel-2 COG STAC items
        type: string[]
      bands:
        label: bands used for the NDWI
        doc: bands used for the NDWI
        type: string[]
        default: ["green", "nir"]
    outputs:
      - id: stac_catalog
        outputSource:
          - node_stac/stac_catalog
        type: Directory
    steps:
      node_water_bodies:
        run: "#detect_water_body"
        in:
          item: stac_items
          aoi: aoi
          epsg: epsg
          bands: bands
        out:
          - detected_water_body
        scatter: item
        scatterMethod: dotproduct
      node_stac:
        run: "#stac"
        in:
          item: stac_items
          rasters:
            source: node_water_bodies/detected_water_body
        out:
          - stac_catalog
  - class: Workflow
    id: detect_water_body
    label: Water body detection based on NDWI and otsu threshold
    doc: Water body detection based on NDWI and otsu threshold
    requirements:
      - class: ScatterFeatureRequirement
    inputs:
      aoi:
        doc: area of interest as a bounding box
        type: string
      epsg:
        doc: EPSG code
        type: string
        default: "EPSG:4326"
      bands:
        doc: bands used for the NDWI
        type: string[]
      item:
        doc: STAC item
        type: string
    outputs:
      - id: detected_water_body
        outputSource:
          - node_otsu/binary_mask_item
        type: File
    steps:
      node_crop:
        run: "#crop"
        in:
          item: item
          aoi: aoi
          epsg: epsg
          band: bands
        out:
          - cropped
        scatter: band
        scatterMethod: dotproduct
      node_normalized_difference:
        run: "#norm_diff"
        in:
          rasters:
            source: node_crop/cropped
        out:
          - ndwi
      node_otsu:
        run: "#otsu"
        in:
          raster:
            source: node_normalized_difference/ndwi
        out:
          - binary_mask_item
  - class: CommandLineTool
    id: crop
    requirements:
      InlineJavascriptRequirement: {}
      EnvVarRequirement:
        envDef:
          PATH: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
          PYTHONPATH: /app
      ResourceRequirement:
        coresMax: 1
        ramMax: 512
    hints:
      DockerRequirement:
        dockerPull: cr.terradue.com/earthquake-monitoring/crop:latest
    baseCommand: ["python", "-m", "app"]
    arguments: []
    inputs:
      item:
        type: string
        inputBinding:
          prefix: --input-item
      aoi:
        type: string
        inputBinding:
          prefix: --aoi
      epsg:
        type: string
        inputBinding:
          prefix: --epsg
      band:
        type: string
        inputBinding:
          prefix: --band
    outputs:
      cropped:
        outputBinding:
          glob: '*.tif'
        type: File
  - class: CommandLineTool
    id: norm_diff
    requirements:
      InlineJavascriptRequirement: {}
      EnvVarRequirement:
        envDef:
          PATH: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
          PYTHONPATH: /app
      ResourceRequirement:
        coresMax: 1
        ramMax: 512
    hints:
      DockerRequirement:
        dockerPull: cr.terradue.com/earthquake-monitoring/norm_diff:latest
    baseCommand: ["python", "-m", "app"]
    arguments: []
    inputs:
      rasters:
        type: File[]
        inputBinding:
          position: 1
    outputs:
      ndwi:
        outputBinding:
          glob: '*.tif'
        type: File
  - class: CommandLineTool
    id: otsu
    requirements:
      InlineJavascriptRequirement: {}
      EnvVarRequirement:
        envDef:
          PATH: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
          PYTHONPATH: /app
      ResourceRequirement:
        coresMax: 1
        ramMax: 512
    hints:
      DockerRequirement:
        dockerPull: cr.terradue.com/earthquake-monitoring/otsu:latest
    baseCommand: ["python", "-m", "app"]
    arguments: []
    inputs:
      raster:
        type: File
        inputBinding:
          position: 1
    outputs:
      binary_mask_item:
        outputBinding:
          glob: '*.tif'
        type: File
  - class: CommandLineTool
    id: stac
    requirements:
      InlineJavascriptRequirement: {}
      EnvVarRequirement:
        envDef:
          PATH: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
          PYTHONPATH: /app
      ResourceRequirement:
        coresMax: 1
        ramMax: 512
    hints:
      DockerRequirement:
        dockerPull: cr.terradue.com/earthquake-monitoring/stac:latest
    baseCommand: ["python", "-m", "app"]
    arguments: []
    inputs:
      item:
        type:
          type: array
          items: string
          inputBinding:
            prefix: --input-item
      rasters:
        type:
          type: array
          items: File
          inputBinding:
            prefix: --water-body
    outputs:
      stac_catalog:
        outputBinding:
          glob: .
        type: Directory

```

#### json
```json
{
  "cwlVersion": "v1.0",
  "$namespaces": {
    "s": "https://schema.org/"
  },
  "s:softwareVersion": "1.4.1",
  "schemas": [
    "http://schema.org/version/9.0/schemaorg-current-http.rdf"
  ],
  "$graph": [
    {
      "class": "Workflow",
      "id": "water-bodies",
      "label": "Water bodies detection based on NDWI and otsu threshold",
      "doc": "Water bodies detection based on NDWI and otsu threshold applied to Sentinel-2 COG STAC items",
      "requirements": [
        {
          "class": "ScatterFeatureRequirement"
        },
        {
          "class": "SubworkflowFeatureRequirement"
        },
        {
          "class": "SchemaDefRequirement",
          "types": [
            {
              "$import": "https://raw.githubusercontent.com/eoap/schemas/main/stac.yaml"
            }
          ]
        }
      ],
      "inputs": {
        "aoi": {
          "label": "area of interest",
          "doc": "area of interest as a bounding box",
          "type": "string"
        },
        "epsg": {
          "label": "EPSG code",
          "doc": "EPSG code",
          "type": "string",
          "default": "EPSG:4326"
        },
        "stac_items": {
          "label": "Sentinel-2 STAC items",
          "doc": "list of Sentinel-2 COG STAC items",
          "type": "string[]"
        },
        "bands": {
          "label": "bands used for the NDWI",
          "doc": "bands used for the NDWI",
          "type": "string[]",
          "default": [
            "green",
            "nir"
          ]
        }
      },
      "outputs": [
        {
          "id": "stac_catalog",
          "outputSource": [
            "node_stac/stac_catalog"
          ],
          "type": "Directory"
        }
      ],
      "steps": {
        "node_water_bodies": {
          "run": "#detect_water_body",
          "in": {
            "item": "stac_items",
            "aoi": "aoi",
            "epsg": "epsg",
            "bands": "bands"
          },
          "out": [
            "detected_water_body"
          ],
          "scatter": "item",
          "scatterMethod": "dotproduct"
        },
        "node_stac": {
          "run": "#stac",
          "in": {
            "item": "stac_items",
            "rasters": {
              "source": "node_water_bodies/detected_water_body"
            }
          },
          "out": [
            "stac_catalog"
          ]
        }
      }
    },
    {
      "class": "Workflow",
      "id": "detect_water_body",
      "label": "Water body detection based on NDWI and otsu threshold",
      "doc": "Water body detection based on NDWI and otsu threshold",
      "requirements": [
        {
          "class": "ScatterFeatureRequirement"
        }
      ],
      "inputs": {
        "aoi": {
          "doc": "area of interest as a bounding box",
          "type": "string"
        },
        "epsg": {
          "doc": "EPSG code",
          "type": "string",
          "default": "EPSG:4326"
        },
        "bands": {
          "doc": "bands used for the NDWI",
          "type": "string[]"
        },
        "item": {
          "doc": "STAC item",
          "type": "string"
        }
      },
      "outputs": [
        {
          "id": "detected_water_body",
          "outputSource": [
            "node_otsu/binary_mask_item"
          ],
          "type": "File"
        }
      ],
      "steps": {
        "node_crop": {
          "run": "#crop",
          "in": {
            "item": "item",
            "aoi": "aoi",
            "epsg": "epsg",
            "band": "bands"
          },
          "out": [
            "cropped"
          ],
          "scatter": "band",
          "scatterMethod": "dotproduct"
        },
        "node_normalized_difference": {
          "run": "#norm_diff",
          "in": {
            "rasters": {
              "source": "node_crop/cropped"
            }
          },
          "out": [
            "ndwi"
          ]
        },
        "node_otsu": {
          "run": "#otsu",
          "in": {
            "raster": {
              "source": "node_normalized_difference/ndwi"
            }
          },
          "out": [
            "binary_mask_item"
          ]
        }
      }
    },
    {
      "class": "CommandLineTool",
      "id": "crop",
      "requirements": {
        "InlineJavascriptRequirement": {},
        "EnvVarRequirement": {
          "envDef": {
            "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
            "PYTHONPATH": "/app"
          }
        },
        "ResourceRequirement": {
          "coresMax": 1,
          "ramMax": 512
        }
      },
      "hints": {
        "DockerRequirement": {
          "dockerPull": "cr.terradue.com/earthquake-monitoring/crop:latest"
        }
      },
      "baseCommand": [
        "python",
        "-m",
        "app"
      ],
      "arguments": [],
      "inputs": {
        "item": {
          "type": "string",
          "inputBinding": {
            "prefix": "--input-item"
          }
        },
        "aoi": {
          "type": "string",
          "inputBinding": {
            "prefix": "--aoi"
          }
        },
        "epsg": {
          "type": "string",
          "inputBinding": {
            "prefix": "--epsg"
          }
        },
        "band": {
          "type": "string",
          "inputBinding": {
            "prefix": "--band"
          }
        }
      },
      "outputs": {
        "cropped": {
          "outputBinding": {
            "glob": "*.tif"
          },
          "type": "File"
        }
      }
    },
    {
      "class": "CommandLineTool",
      "id": "norm_diff",
      "requirements": {
        "InlineJavascriptRequirement": {},
        "EnvVarRequirement": {
          "envDef": {
            "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
            "PYTHONPATH": "/app"
          }
        },
        "ResourceRequirement": {
          "coresMax": 1,
          "ramMax": 512
        }
      },
      "hints": {
        "DockerRequirement": {
          "dockerPull": "cr.terradue.com/earthquake-monitoring/norm_diff:latest"
        }
      },
      "baseCommand": [
        "python",
        "-m",
        "app"
      ],
      "arguments": [],
      "inputs": {
        "rasters": {
          "type": "File[]",
          "inputBinding": {
            "position": 1
          }
        }
      },
      "outputs": {
        "ndwi": {
          "outputBinding": {
            "glob": "*.tif"
          },
          "type": "File"
        }
      }
    },
    {
      "class": "CommandLineTool",
      "id": "otsu",
      "requirements": {
        "InlineJavascriptRequirement": {},
        "EnvVarRequirement": {
          "envDef": {
            "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
            "PYTHONPATH": "/app"
          }
        },
        "ResourceRequirement": {
          "coresMax": 1,
          "ramMax": 512
        }
      },
      "hints": {
        "DockerRequirement": {
          "dockerPull": "cr.terradue.com/earthquake-monitoring/otsu:latest"
        }
      },
      "baseCommand": [
        "python",
        "-m",
        "app"
      ],
      "arguments": [],
      "inputs": {
        "raster": {
          "type": "File",
          "inputBinding": {
            "position": 1
          }
        }
      },
      "outputs": {
        "binary_mask_item": {
          "outputBinding": {
            "glob": "*.tif"
          },
          "type": "File"
        }
      }
    },
    {
      "class": "CommandLineTool",
      "id": "stac",
      "requirements": {
        "InlineJavascriptRequirement": {},
        "EnvVarRequirement": {
          "envDef": {
            "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
            "PYTHONPATH": "/app"
          }
        },
        "ResourceRequirement": {
          "coresMax": 1,
          "ramMax": 512
        }
      },
      "hints": {
        "DockerRequirement": {
          "dockerPull": "cr.terradue.com/earthquake-monitoring/stac:latest"
        }
      },
      "baseCommand": [
        "python",
        "-m",
        "app"
      ],
      "arguments": [],
      "inputs": {
        "item": {
          "type": {
            "type": "array",
            "items": "string",
            "inputBinding": {
              "prefix": "--input-item"
            }
          }
        },
        "rasters": {
          "type": {
            "type": "array",
            "items": "File",
            "inputBinding": {
              "prefix": "--water-body"
            }
          }
        }
      },
      "outputs": {
        "stac_catalog": {
          "outputBinding": {
            "glob": "."
          },
          "type": "Directory"
        }
      }
    }
  ]
}

```

#### jsonld
```jsonld
{
  "@context": "https://geolabs.github.io/bblocks-eoap-cct/build/annotated/cct/cwl-to-ogcprocess/context.jsonld",
  "cwlVersion": "v1.0",
  "$namespaces": {
    "s": "https://schema.org/"
  },
  "s:softwareVersion": "1.4.1",
  "schemas": [
    "http://schema.org/version/9.0/schemaorg-current-http.rdf"
  ],
  "$graph": [
    {
      "class": "Workflow",
      "id": "water-bodies",
      "label": "Water bodies detection based on NDWI and otsu threshold",
      "doc": "Water bodies detection based on NDWI and otsu threshold applied to Sentinel-2 COG STAC items",
      "requirements": [
        {
          "class": "ScatterFeatureRequirement"
        },
        {
          "class": "SubworkflowFeatureRequirement"
        },
        {
          "class": "SchemaDefRequirement",
          "types": [
            {
              "$import": "https://raw.githubusercontent.com/eoap/schemas/main/stac.yaml"
            }
          ]
        }
      ],
      "inputs": {
        "aoi": {
          "label": "area of interest",
          "doc": "area of interest as a bounding box",
          "type": "string"
        },
        "epsg": {
          "label": "EPSG code",
          "doc": "EPSG code",
          "type": "string",
          "default": "EPSG:4326"
        },
        "stac_items": {
          "label": "Sentinel-2 STAC items",
          "doc": "list of Sentinel-2 COG STAC items",
          "type": "string[]"
        },
        "bands": {
          "label": "bands used for the NDWI",
          "doc": "bands used for the NDWI",
          "type": "string[]",
          "default": [
            "green",
            "nir"
          ]
        }
      },
      "outputs": [
        {
          "id": "stac_catalog",
          "outputSource": [
            "node_stac/stac_catalog"
          ],
          "type": "Directory"
        }
      ],
      "steps": {
        "node_water_bodies": {
          "run": "#detect_water_body",
          "in": {
            "item": "stac_items",
            "aoi": "aoi",
            "epsg": "epsg",
            "bands": "bands"
          },
          "out": [
            "detected_water_body"
          ],
          "scatter": "item",
          "scatterMethod": "dotproduct"
        },
        "node_stac": {
          "run": "#stac",
          "in": {
            "item": "stac_items",
            "rasters": {
              "source": "node_water_bodies/detected_water_body"
            }
          },
          "out": [
            "stac_catalog"
          ]
        }
      }
    },
    {
      "class": "Workflow",
      "id": "detect_water_body",
      "label": "Water body detection based on NDWI and otsu threshold",
      "doc": "Water body detection based on NDWI and otsu threshold",
      "requirements": [
        {
          "class": "ScatterFeatureRequirement"
        }
      ],
      "inputs": {
        "aoi": {
          "doc": "area of interest as a bounding box",
          "type": "string"
        },
        "epsg": {
          "doc": "EPSG code",
          "type": "string",
          "default": "EPSG:4326"
        },
        "bands": {
          "doc": "bands used for the NDWI",
          "type": "string[]"
        },
        "item": {
          "doc": "STAC item",
          "type": "string"
        }
      },
      "outputs": [
        {
          "id": "detected_water_body",
          "outputSource": [
            "node_otsu/binary_mask_item"
          ],
          "type": "File"
        }
      ],
      "steps": {
        "node_crop": {
          "run": "#crop",
          "in": {
            "item": "item",
            "aoi": "aoi",
            "epsg": "epsg",
            "band": "bands"
          },
          "out": [
            "cropped"
          ],
          "scatter": "band",
          "scatterMethod": "dotproduct"
        },
        "node_normalized_difference": {
          "run": "#norm_diff",
          "in": {
            "rasters": {
              "source": "node_crop/cropped"
            }
          },
          "out": [
            "ndwi"
          ]
        },
        "node_otsu": {
          "run": "#otsu",
          "in": {
            "raster": {
              "source": "node_normalized_difference/ndwi"
            }
          },
          "out": [
            "binary_mask_item"
          ]
        }
      }
    },
    {
      "class": "CommandLineTool",
      "id": "crop",
      "requirements": {
        "InlineJavascriptRequirement": {},
        "EnvVarRequirement": {
          "envDef": {
            "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
            "PYTHONPATH": "/app"
          }
        },
        "ResourceRequirement": {
          "coresMax": 1,
          "ramMax": 512
        }
      },
      "hints": {
        "DockerRequirement": {
          "dockerPull": "cr.terradue.com/earthquake-monitoring/crop:latest"
        }
      },
      "baseCommand": [
        "python",
        "-m",
        "app"
      ],
      "arguments": [],
      "inputs": {
        "item": {
          "type": "string",
          "inputBinding": {
            "prefix": "--input-item"
          }
        },
        "aoi": {
          "type": "string",
          "inputBinding": {
            "prefix": "--aoi"
          }
        },
        "epsg": {
          "type": "string",
          "inputBinding": {
            "prefix": "--epsg"
          }
        },
        "band": {
          "type": "string",
          "inputBinding": {
            "prefix": "--band"
          }
        }
      },
      "outputs": {
        "cropped": {
          "outputBinding": {
            "glob": "*.tif"
          },
          "type": "File"
        }
      }
    },
    {
      "class": "CommandLineTool",
      "id": "norm_diff",
      "requirements": {
        "InlineJavascriptRequirement": {},
        "EnvVarRequirement": {
          "envDef": {
            "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
            "PYTHONPATH": "/app"
          }
        },
        "ResourceRequirement": {
          "coresMax": 1,
          "ramMax": 512
        }
      },
      "hints": {
        "DockerRequirement": {
          "dockerPull": "cr.terradue.com/earthquake-monitoring/norm_diff:latest"
        }
      },
      "baseCommand": [
        "python",
        "-m",
        "app"
      ],
      "arguments": [],
      "inputs": {
        "rasters": {
          "type": "File[]",
          "inputBinding": {
            "position": 1
          }
        }
      },
      "outputs": {
        "ndwi": {
          "outputBinding": {
            "glob": "*.tif"
          },
          "type": "File"
        }
      }
    },
    {
      "class": "CommandLineTool",
      "id": "otsu",
      "requirements": {
        "InlineJavascriptRequirement": {},
        "EnvVarRequirement": {
          "envDef": {
            "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
            "PYTHONPATH": "/app"
          }
        },
        "ResourceRequirement": {
          "coresMax": 1,
          "ramMax": 512
        }
      },
      "hints": {
        "DockerRequirement": {
          "dockerPull": "cr.terradue.com/earthquake-monitoring/otsu:latest"
        }
      },
      "baseCommand": [
        "python",
        "-m",
        "app"
      ],
      "arguments": [],
      "inputs": {
        "raster": {
          "type": "File",
          "inputBinding": {
            "position": 1
          }
        }
      },
      "outputs": {
        "binary_mask_item": {
          "outputBinding": {
            "glob": "*.tif"
          },
          "type": "File"
        }
      }
    },
    {
      "class": "CommandLineTool",
      "id": "stac",
      "requirements": {
        "InlineJavascriptRequirement": {},
        "EnvVarRequirement": {
          "envDef": {
            "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
            "PYTHONPATH": "/app"
          }
        },
        "ResourceRequirement": {
          "coresMax": 1,
          "ramMax": 512
        }
      },
      "hints": {
        "DockerRequirement": {
          "dockerPull": "cr.terradue.com/earthquake-monitoring/stac:latest"
        }
      },
      "baseCommand": [
        "python",
        "-m",
        "app"
      ],
      "arguments": [],
      "inputs": {
        "item": {
          "type": {
            "type": "array",
            "items": "string",
            "inputBinding": {
              "prefix": "--input-item"
            }
          }
        },
        "rasters": {
          "type": {
            "type": "array",
            "items": "File",
            "inputBinding": {
              "prefix": "--water-body"
            }
          }
        }
      },
      "outputs": {
        "stac_catalog": {
          "outputBinding": {
            "glob": "."
          },
          "type": "Directory"
        }
      }
    }
  ]
}
```

#### ttl
```ttl
@prefix cwl: <https://w3id.org/cwl/cwl#> .
@prefix dct: <http://purl.org/dc/terms/> .
@prefix ns1: <rdf:> .
@prefix ns2: <s:> .
@prefix ogcproc: <http://www.opengis.net/def/ogcapi/processes/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

[] cwl:cwlVersion <file:///github/workspace/v1.0> ;
    cwl:graph [ rdfs:label "Water body detection based on NDWI and otsu threshold"^^xsd:string ;
            dct:identifier <file:///github/workspace/detect_water_body> ;
            ogcproc:input _:N3917e8f248c5418eb7864d4f71368d3d ;
            ogcproc:output _:N7969cf65452447af86c1cba27685f88c ;
            rdfs:comment "Water body detection based on NDWI and otsu threshold"^^xsd:string ;
            cwl:input _:N3917e8f248c5418eb7864d4f71368d3d ;
            cwl:output _:N7969cf65452447af86c1cba27685f88c ;
            cwl:requirements [ ns1:type <file:///github/workspace/ScatterFeatureRequirement> ] ;
            cwl:steps [ cwl:node_crop [ cwl:in [ cwl:aoi "aoi" ;
                                    cwl:band "bands" ;
                                    cwl:epsg "epsg" ;
                                    cwl:item "item" ] ;
                            cwl:out ( "cropped" ) ;
                            cwl:run <file:///github/workspace/#crop> ;
                            cwl:scatter ( "band" ) ;
                            cwl:scatterMethod <file:///github/workspace/dotproduct> ] ;
                    cwl:node_normalized_difference [ cwl:in [ cwl:rasters [ cwl:source <file:///github/workspace/node_crop/cropped> ] ] ;
                            cwl:out ( "ndwi" ) ;
                            cwl:run <file:///github/workspace/#norm_diff> ] ;
                    cwl:node_otsu [ cwl:in [ cwl:raster [ cwl:source <file:///github/workspace/node_normalized_difference/ndwi> ] ] ;
                            cwl:out ( "binary_mask_item" ) ;
                            cwl:run <file:///github/workspace/#otsu> ] ] ;
            ns1:type <file:///github/workspace/Workflow> ],
        [ rdfs:label "Water bodies detection based on NDWI and otsu threshold"^^xsd:string ;
            dct:identifier <file:///github/workspace/water-bodies> ;
            ogcproc:input _:Ne23ed50c61594efaab050d226ecbbba6 ;
            ogcproc:output _:N80f430af93e5496d8294357289e0543f ;
            rdfs:comment "Water bodies detection based on NDWI and otsu threshold applied to Sentinel-2 COG STAC items"^^xsd:string ;
            cwl:input _:Ne23ed50c61594efaab050d226ecbbba6 ;
            cwl:output _:N80f430af93e5496d8294357289e0543f ;
            cwl:requirements [ ns1:type <file:///github/workspace/ScatterFeatureRequirement> ],
                [ cwl:types [ cwl:import <https://raw.githubusercontent.com/eoap/schemas/main/stac.yaml> ] ;
                    ns1:type <file:///github/workspace/SchemaDefRequirement> ],
                [ ns1:type <file:///github/workspace/SubworkflowFeatureRequirement> ] ;
            cwl:steps [ cwl:node_stac [ cwl:in [ cwl:item "stac_items" ;
                                    cwl:rasters [ cwl:source <file:///github/workspace/node_water_bodies/detected_water_body> ] ] ;
                            cwl:out ( "stac_catalog" ) ;
                            cwl:run <file:///github/workspace/#stac> ] ;
                    cwl:node_water_bodies [ cwl:in [ cwl:aoi "aoi" ;
                                    cwl:bands "bands" ;
                                    cwl:epsg "epsg" ;
                                    cwl:item "stac_items" ] ;
                            cwl:out ( "detected_water_body" ) ;
                            cwl:run <file:///github/workspace/#detect_water_body> ;
                            cwl:scatter ( "item" ) ;
                            cwl:scatterMethod <file:///github/workspace/dotproduct> ] ] ;
            ns1:type <file:///github/workspace/Workflow> ],
        [ dct:identifier <file:///github/workspace/otsu> ;
            ogcproc:input _:Naa397ebf3abc46f8a4485340f7dd57f6 ;
            ogcproc:output _:Nb099e2757de14741bfdc048b07bfcc70 ;
            cwl:arguments () ;
            cwl:baseCommand "[\"python\",\"-m\",\"app\"]"^^rdf:JSON ;
            cwl:hints [ cwl:DockerRequirement [ cwl:dockerPull "cr.terradue.com/earthquake-monitoring/otsu:latest"^^xsd:string ] ] ;
            cwl:input _:Naa397ebf3abc46f8a4485340f7dd57f6 ;
            cwl:output _:Nb099e2757de14741bfdc048b07bfcc70 ;
            cwl:requirements [ cwl:EnvVarRequirement [ cwl:envDef [ cwl:PATH "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" ;
                                    cwl:PYTHONPATH "/app" ] ] ;
                    cwl:InlineJavascriptRequirement [ ] ;
                    cwl:ResourceRequirement [ cwl:coresMax 1 ;
                            cwl:ramMax 512 ] ] ;
            ns1:type <file:///github/workspace/CommandLineTool> ],
        [ dct:identifier <file:///github/workspace/stac> ;
            ogcproc:input _:Ne03905699a1845309d9ffce193e3e3dc ;
            ogcproc:output _:Nbfc43a54839845b6bf123d8e43291b65 ;
            cwl:arguments () ;
            cwl:baseCommand "[\"python\",\"-m\",\"app\"]"^^rdf:JSON ;
            cwl:hints [ cwl:DockerRequirement [ cwl:dockerPull "cr.terradue.com/earthquake-monitoring/stac:latest"^^xsd:string ] ] ;
            cwl:input _:Ne03905699a1845309d9ffce193e3e3dc ;
            cwl:output _:Nbfc43a54839845b6bf123d8e43291b65 ;
            cwl:requirements [ cwl:EnvVarRequirement [ cwl:envDef [ cwl:PATH "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" ;
                                    cwl:PYTHONPATH "/app" ] ] ;
                    cwl:InlineJavascriptRequirement [ ] ;
                    cwl:ResourceRequirement [ cwl:coresMax 1 ;
                            cwl:ramMax 512 ] ] ;
            ns1:type <file:///github/workspace/CommandLineTool> ],
        [ dct:identifier <file:///github/workspace/norm_diff> ;
            ogcproc:input _:N19a81b482c974c198cbe57ff263260e1 ;
            ogcproc:output _:N1a238dddcd7b410088e70f7a88b40ee7 ;
            cwl:arguments () ;
            cwl:baseCommand "[\"python\",\"-m\",\"app\"]"^^rdf:JSON ;
            cwl:hints [ cwl:DockerRequirement [ cwl:dockerPull "cr.terradue.com/earthquake-monitoring/norm_diff:latest"^^xsd:string ] ] ;
            cwl:input _:N19a81b482c974c198cbe57ff263260e1 ;
            cwl:output _:N1a238dddcd7b410088e70f7a88b40ee7 ;
            cwl:requirements [ cwl:EnvVarRequirement [ cwl:envDef [ cwl:PATH "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" ;
                                    cwl:PYTHONPATH "/app" ] ] ;
                    cwl:InlineJavascriptRequirement [ ] ;
                    cwl:ResourceRequirement [ cwl:coresMax 1 ;
                            cwl:ramMax 512 ] ] ;
            ns1:type <file:///github/workspace/CommandLineTool> ],
        [ dct:identifier <file:///github/workspace/crop> ;
            ogcproc:input _:N456679cb776f4915b3ab641a4ac169d8 ;
            ogcproc:output _:N6af66f4e61ad4b3ca8e9b55f6542adb2 ;
            cwl:arguments () ;
            cwl:baseCommand "[\"python\",\"-m\",\"app\"]"^^rdf:JSON ;
            cwl:hints [ cwl:DockerRequirement [ cwl:dockerPull "cr.terradue.com/earthquake-monitoring/crop:latest"^^xsd:string ] ] ;
            cwl:input _:N456679cb776f4915b3ab641a4ac169d8 ;
            cwl:output _:N6af66f4e61ad4b3ca8e9b55f6542adb2 ;
            cwl:requirements [ cwl:EnvVarRequirement [ cwl:envDef [ cwl:PATH "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" ;
                                    cwl:PYTHONPATH "/app" ] ] ;
                    cwl:InlineJavascriptRequirement [ ] ;
                    cwl:ResourceRequirement [ cwl:coresMax 1 ;
                            cwl:ramMax 512 ] ] ;
            ns1:type <file:///github/workspace/CommandLineTool> ] ;
    cwl:namespaces "{\"s\":\"https://schema.org/\"}"^^rdf:JSON ;
    cwl:schemas "http://schema.org/version/9.0/schemaorg-current-http.rdf" ;
    ns2:softwareVersion "1.4.1" .

_:N01780a006f644b5da0e7d6b738a57718 rdfs:comment "EPSG code"^^xsd:string ;
    cwl:default "\"EPSG:4326\""^^rdf:JSON ;
    cwl:type <file:///github/workspace/string> .

_:N01dff208193d48ffb4c2c5628ae8c3d3 cwl:inputBinding [ cwl:prefix "--input-item"^^xsd:string ] ;
    cwl:items <file:///github/workspace/string> ;
    cwl:type <file:///github/workspace/array> .

_:N026e90b0e07f4bceb65a0aac797d5a30 cwl:rasters [ cwl:inputBinding [ cwl:position "1"^^xsd:int ] ;
            cwl:type <file:///github/workspace/File[]> ] .

_:N06fb16c394de4db583aef34e16d9b45c cwl:glob "*.tif"^^xsd:string .

_:N0c2e421ad5aa4c1585f8c2b13d916bc5 rdfs:label "bands used for the NDWI"^^xsd:string ;
    rdfs:comment "bands used for the NDWI"^^xsd:string ;
    cwl:default "[\"green\",\"nir\"]"^^rdf:JSON ;
    cwl:type <file:///github/workspace/string[]> .

_:N1353631f048045d1ae4232e64a65a9f9 cwl:stac_catalog [ cwl:outputBinding [ cwl:glob "."^^xsd:string ] ;
            cwl:type <file:///github/workspace/Directory> ] .

_:N16b35f79369e4213b4e12f6fb9b77582 cwl:glob "*.tif"^^xsd:string .

_:N173a4fd6d5e048cc80ab6f02935ebf03 rdfs:comment "bands used for the NDWI"^^xsd:string ;
    cwl:type <file:///github/workspace/string[]> .

_:N18bc00985fc74c53b9ada473dee7f020 cwl:outputBinding _:N06fb16c394de4db583aef34e16d9b45c ;
    cwl:type <file:///github/workspace/File> .

_:N19eca5e9997e4aee99f82add07432d6e cwl:binary_mask_item [ cwl:outputBinding _:N16b35f79369e4213b4e12f6fb9b77582 ;
            cwl:type <file:///github/workspace/File> ] .

_:N1d2f3176f8d147b4964b88ee5f9516c1 cwl:inputBinding [ cwl:prefix "--epsg"^^xsd:string ] ;
    cwl:type <file:///github/workspace/string> .

_:N207055ce8c874a4aa3b56d0364b505cd cwl:inputBinding [ cwl:prefix "--water-body"^^xsd:string ] ;
    cwl:items <file:///github/workspace/File> ;
    cwl:type <file:///github/workspace/array> .

_:N29951b65ed844f95a5be8851e463d030 cwl:raster [ cwl:inputBinding [ cwl:position "1"^^xsd:int ] ;
            cwl:type <file:///github/workspace/File> ] .

_:N3054afbeb39d43ccbbc5caa7f6989072 rdfs:label "EPSG code"^^xsd:string ;
    rdfs:comment "EPSG code"^^xsd:string ;
    cwl:default "\"EPSG:4326\""^^rdf:JSON ;
    cwl:type <file:///github/workspace/string> .

_:N392dc008c73f4b30a922a3ff71ca20a0 cwl:inputBinding [ cwl:prefix "--aoi"^^xsd:string ] ;
    cwl:type <file:///github/workspace/string> .

_:N392e9ef604a649878729b559437e6222 cwl:type _:N207055ce8c874a4aa3b56d0364b505cd .

_:N3ac5ee6a1c6f4c2bb89fdd98885414ec cwl:aoi [ rdfs:label "area of interest"^^xsd:string ;
            rdfs:comment "area of interest as a bounding box"^^xsd:string ;
            cwl:type <file:///github/workspace/string> ] ;
    cwl:bands _:N0c2e421ad5aa4c1585f8c2b13d916bc5 ;
    cwl:epsg _:N3054afbeb39d43ccbbc5caa7f6989072 ;
    cwl:stac_items [ rdfs:label "Sentinel-2 STAC items"^^xsd:string ;
            rdfs:comment "list of Sentinel-2 COG STAC items"^^xsd:string ;
            cwl:type <file:///github/workspace/string[]> ] .

_:N40320750b1334d03b7215c3aeb519dec dct:identifier <file:///github/workspace/detected_water_body> ;
    cwl:outputSource <file:///github/workspace/node_otsu/binary_mask_item> ;
    cwl:type <file:///github/workspace/File> .

_:N4465ea05b0034674a5cb3daa9bd19a81 cwl:outputBinding [ cwl:glob "*.tif"^^xsd:string ] ;
    cwl:type <file:///github/workspace/File> .

_:N4fb355739b35490e9888501963923e28 cwl:inputBinding [ cwl:prefix "--input-item"^^xsd:string ] ;
    cwl:type <file:///github/workspace/string> .

_:N585092e5a09f43659be856f3a40871b8 cwl:item [ cwl:type _:N01dff208193d48ffb4c2c5628ae8c3d3 ] ;
    cwl:rasters _:N392e9ef604a649878729b559437e6222 .

_:N6ecdc2bc0059425d9bcacb9f2b939c1e cwl:ndwi _:N18bc00985fc74c53b9ada473dee7f020 .

_:N9999555f4af64e2b81a8c6287dc40dcc cwl:aoi _:N392dc008c73f4b30a922a3ff71ca20a0 ;
    cwl:band [ cwl:inputBinding [ cwl:prefix "--band"^^xsd:string ] ;
            cwl:type <file:///github/workspace/string> ] ;
    cwl:epsg _:N1d2f3176f8d147b4964b88ee5f9516c1 ;
    cwl:item _:N4fb355739b35490e9888501963923e28 .

_:N9f577632be544fa28ee5c078e5604170 dct:identifier <file:///github/workspace/stac_catalog> ;
    cwl:outputSource <file:///github/workspace/node_stac/stac_catalog> ;
    cwl:type <file:///github/workspace/Directory> .

_:Na011951a30954578b0936e1f0d64574e cwl:aoi [ rdfs:comment "area of interest as a bounding box"^^xsd:string ;
            cwl:type <file:///github/workspace/string> ] ;
    cwl:bands _:N173a4fd6d5e048cc80ab6f02935ebf03 ;
    cwl:epsg _:N01780a006f644b5da0e7d6b738a57718 ;
    cwl:item [ rdfs:comment "STAC item"^^xsd:string ;
            cwl:type <file:///github/workspace/string> ] .

_:Nd310422558844bbcaa87979859eb597b cwl:cropped _:N4465ea05b0034674a5cb3daa9bd19a81 .

_:N19a81b482c974c198cbe57ff263260e1 a ogcproc:InputDescription ;
    rdf:first _:N026e90b0e07f4bceb65a0aac797d5a30 ;
    rdf:rest () .

_:N1a238dddcd7b410088e70f7a88b40ee7 a ogcproc:OutputDescription ;
    rdf:first _:N6ecdc2bc0059425d9bcacb9f2b939c1e ;
    rdf:rest () .

_:N3917e8f248c5418eb7864d4f71368d3d a ogcproc:InputDescription ;
    rdf:first _:Na011951a30954578b0936e1f0d64574e ;
    rdf:rest () .

_:N456679cb776f4915b3ab641a4ac169d8 a ogcproc:InputDescription ;
    rdf:first _:N9999555f4af64e2b81a8c6287dc40dcc ;
    rdf:rest () .

_:N6af66f4e61ad4b3ca8e9b55f6542adb2 a ogcproc:OutputDescription ;
    rdf:first _:Nd310422558844bbcaa87979859eb597b ;
    rdf:rest () .

_:N7969cf65452447af86c1cba27685f88c a ogcproc:OutputDescription ;
    rdf:first _:N40320750b1334d03b7215c3aeb519dec ;
    rdf:rest () .

_:N80f430af93e5496d8294357289e0543f a ogcproc:OutputDescription ;
    rdf:first _:N9f577632be544fa28ee5c078e5604170 ;
    rdf:rest () .

_:Naa397ebf3abc46f8a4485340f7dd57f6 a ogcproc:InputDescription ;
    rdf:first _:N29951b65ed844f95a5be8851e463d030 ;
    rdf:rest () .

_:Nb099e2757de14741bfdc048b07bfcc70 a ogcproc:OutputDescription ;
    rdf:first _:N19eca5e9997e4aee99f82add07432d6e ;
    rdf:rest () .

_:Nbfc43a54839845b6bf123d8e43291b65 a ogcproc:OutputDescription ;
    rdf:first _:N1353631f048045d1ae4232e64a65a9f9 ;
    rdf:rest () .

_:Ne03905699a1845309d9ffce193e3e3dc a ogcproc:InputDescription ;
    rdf:first _:N585092e5a09f43659be856f3a40871b8 ;
    rdf:rest () .

_:Ne23ed50c61594efaab050d226ecbbba6 a ogcproc:InputDescription ;
    rdf:first _:N3ac5ee6a1c6f4c2bb89fdd98885414ec ;
    rdf:rest () .


```


### Mangrove Workflow OSPD 2025
#### yaml
```yaml
#!/usr/bin/env cwl-runner

$graph:

  - class: CommandLineTool
    id: parse_aoi
    baseCommand: echo
    arguments:
    - --
    requirements:
      InlineJavascriptRequirement: {}
      SchemaDefRequirement:
        types:
          - $import: https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml
      ResourceRequirement:
        coresMax: 1
        ramMax: 512

    hints:
      DockerRequirement:
        dockerPull: alpine:3.22.2

    inputs:
      aoi:
        type: https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml#BBox
        label: "Area of interest"
        doc: "Area of interest defined as a bounding box"
    outputs:
      west:
        type: float
        outputBinding:
          outputEval: $(inputs.aoi.bbox[0])
      south:
        type: float
        outputBinding:
          outputEval: $(inputs.aoi.bbox[1])
      east:
        type: float
        outputBinding:
          outputEval: $(inputs.aoi.bbox[2])
      north:
        type: float
        outputBinding:
          outputEval: $(inputs.aoi.bbox[3])
      output_dir:
        type: string
        outputBinding:
          outputEval: $("outputs")

  - class: Workflow
    id: mangrove-workflow
    label: Mangrove Biomass Workflow
    doc: |
      Workflow for Mangrove Biomass Analysis
        
      This workflow orchestrates the mangrove biomass estimation process using
      Sentinel-2 imagery. It wraps the mangrove_workflow.cwl tool to provide
      a reusable workflow for analyzing different study areas.
    requirements:
      StepInputExpressionRequirement: {}
      ScatterFeatureRequirement: {}
      SubworkflowFeatureRequirement: {}
      InlineJavascriptRequirement: {}
      SchemaDefRequirement:
        types:
          - $import: https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml
          - $import: https://raw.githubusercontent.com/eoap/schemas/main/stac.yaml
    inputs:
      cloud_cover_max:
        label: Maximum Cloud Cover
        doc: Maximum acceptable cloud cover percentage (0-100)
        type: float
      days_back:
        label: Days Back
        doc: Number of days to search backwards from current date
        type: int
      aoi:
        label: Area of Interest
        doc: Area of interest as a bounding box
        type: https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml#BBox

    outputs:
      stac:
        type: Directory
        outputSource:
          - step_1/result
    steps:
      parse_aoi:
        run: '#parse_aoi'
        in:
          aoi: aoi
        out:
          - west
          - south
          - east
          - north
          - output_dir
      step_1:
        in:
          cloud_cover_max: cloud_cover_max
          days_back: days_back
          south: parse_aoi/south
          west: parse_aoi/west
          east: parse_aoi/east
          north: parse_aoi/north
          output_dir: parse_aoi/output_dir
        run: '#mangrove_cli'
        out:
          - result

  # The content below defines the mangrove_cli CommandLineTool
  # It results from the mangrove_workflow_for_cwl.cwl jupyter 
  # notebook conversion using the ipython2cwl tool.
  - id: mangrove_cli
    arguments:
    - --
    baseCommand: /app/cwl/bin/mangrove_workflow_for_cwl
    class: CommandLineTool
    requirements:
      InlineJavascriptRequirement: {}
      ResourceRequirement:
        coresMax: 1
        ramMax: 512

    hints:
      DockerRequirement:
        dockerPull: ghcr.io/geolabs/kindgrove/mangrove-cwl:v0.0.1-rc7

    inputs:
      cloud_cover_max:
        inputBinding:
          prefix: --cloud_cover_max
        type: float
      days_back:
        inputBinding:
          prefix: --days_back
        type: int
      east:
        inputBinding: 
          prefix: --east
        type: float
      north:
        inputBinding:
          prefix: --north
        type: float
      south:
        inputBinding:
          prefix: --south
        type: float
      west:
        inputBinding:
          prefix: --west
        type: float
      output_dir:
        inputBinding:
          prefix: --output_dir
        type: string
    outputs:
      result:
        type: Directory
        outputBinding:
          glob: outputs

$namespaces:
  s: https://schema.org/
cwlVersion: v1.0
s:softwareVersion: 0.0.1

s:author:
  - class: s:Person
    s:name: Cameron Sajedi

s:contributor:
  - class: s:Person
    s:name: Gérald Fenoy
    s:identifier: "https://orcid.org/0000-0002-9617-8641"

s:keywords:
  - OSPD
  - mangrove
  - biomass

s:codeRepository: "https://github.com/starling-foundries/KindGrove"
s:license: "https://github.com/starling-foundries/KindGrove?tab=MIT-1-ov-file#readme"

schemas:
- http://schema.org/version/9.0/schemaorg-current-http.rdf
```

#### json
```json
{
  "$graph": [
    {
      "class": "CommandLineTool",
      "id": "parse_aoi",
      "baseCommand": "echo",
      "arguments": [
        "--"
      ],
      "requirements": {
        "InlineJavascriptRequirement": {},
        "SchemaDefRequirement": {
          "types": [
            {
              "$import": "https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml"
            }
          ]
        },
        "ResourceRequirement": {
          "coresMax": 1,
          "ramMax": 512
        }
      },
      "hints": {
        "DockerRequirement": {
          "dockerPull": "alpine:3.22.2"
        }
      },
      "inputs": {
        "aoi": {
          "type": "https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml#BBox",
          "label": "Area of interest",
          "doc": "Area of interest defined as a bounding box"
        }
      },
      "outputs": {
        "west": {
          "type": "float",
          "outputBinding": {
            "outputEval": "$(inputs.aoi.bbox[0])"
          }
        },
        "south": {
          "type": "float",
          "outputBinding": {
            "outputEval": "$(inputs.aoi.bbox[1])"
          }
        },
        "east": {
          "type": "float",
          "outputBinding": {
            "outputEval": "$(inputs.aoi.bbox[2])"
          }
        },
        "north": {
          "type": "float",
          "outputBinding": {
            "outputEval": "$(inputs.aoi.bbox[3])"
          }
        },
        "output_dir": {
          "type": "string",
          "outputBinding": {
            "outputEval": "$(\"outputs\")"
          }
        }
      }
    },
    {
      "class": "Workflow",
      "id": "mangrove-workflow",
      "label": "Mangrove Biomass Workflow",
      "doc": "Workflow for Mangrove Biomass Analysis\n  \nThis workflow orchestrates the mangrove biomass estimation process using\nSentinel-2 imagery. It wraps the mangrove_workflow.cwl tool to provide\na reusable workflow for analyzing different study areas.\n",
      "requirements": {
        "StepInputExpressionRequirement": {},
        "ScatterFeatureRequirement": {},
        "SubworkflowFeatureRequirement": {},
        "InlineJavascriptRequirement": {},
        "SchemaDefRequirement": {
          "types": [
            {
              "$import": "https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml"
            },
            {
              "$import": "https://raw.githubusercontent.com/eoap/schemas/main/stac.yaml"
            }
          ]
        }
      },
      "inputs": {
        "cloud_cover_max": {
          "label": "Maximum Cloud Cover",
          "doc": "Maximum acceptable cloud cover percentage (0-100)",
          "type": "float"
        },
        "days_back": {
          "label": "Days Back",
          "doc": "Number of days to search backwards from current date",
          "type": "int"
        },
        "aoi": {
          "label": "Area of Interest",
          "doc": "Area of interest as a bounding box",
          "type": "https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml#BBox"
        }
      },
      "outputs": {
        "stac": {
          "type": "Directory",
          "outputSource": [
            "step_1/result"
          ]
        }
      },
      "steps": {
        "parse_aoi": {
          "run": "#parse_aoi",
          "in": {
            "aoi": "aoi"
          },
          "out": [
            "west",
            "south",
            "east",
            "north",
            "output_dir"
          ]
        },
        "step_1": {
          "in": {
            "cloud_cover_max": "cloud_cover_max",
            "days_back": "days_back",
            "south": "parse_aoi/south",
            "west": "parse_aoi/west",
            "east": "parse_aoi/east",
            "north": "parse_aoi/north",
            "output_dir": "parse_aoi/output_dir"
          },
          "run": "#mangrove_cli",
          "out": [
            "result"
          ]
        }
      }
    },
    {
      "id": "mangrove_cli",
      "arguments": [
        "--"
      ],
      "baseCommand": "/app/cwl/bin/mangrove_workflow_for_cwl",
      "class": "CommandLineTool",
      "requirements": {
        "InlineJavascriptRequirement": {},
        "ResourceRequirement": {
          "coresMax": 1,
          "ramMax": 512
        }
      },
      "hints": {
        "DockerRequirement": {
          "dockerPull": "ghcr.io/geolabs/kindgrove/mangrove-cwl:v0.0.1-rc7"
        }
      },
      "inputs": {
        "cloud_cover_max": {
          "inputBinding": {
            "prefix": "--cloud_cover_max"
          },
          "type": "float"
        },
        "days_back": {
          "inputBinding": {
            "prefix": "--days_back"
          },
          "type": "int"
        },
        "east": {
          "inputBinding": {
            "prefix": "--east"
          },
          "type": "float"
        },
        "north": {
          "inputBinding": {
            "prefix": "--north"
          },
          "type": "float"
        },
        "south": {
          "inputBinding": {
            "prefix": "--south"
          },
          "type": "float"
        },
        "west": {
          "inputBinding": {
            "prefix": "--west"
          },
          "type": "float"
        },
        "output_dir": {
          "inputBinding": {
            "prefix": "--output_dir"
          },
          "type": "string"
        }
      },
      "outputs": {
        "result": {
          "type": "Directory",
          "outputBinding": {
            "glob": "outputs"
          }
        }
      }
    }
  ],
  "$namespaces": {
    "s": "https://schema.org/"
  },
  "cwlVersion": "v1.0",
  "s:softwareVersion": "0.0.1",
  "s:author": [
    {
      "class": "s:Person",
      "s:name": "Cameron Sajedi"
    }
  ],
  "s:contributor": [
    {
      "class": "s:Person",
      "s:name": "Gérald Fenoy",
      "s:identifier": "https://orcid.org/0000-0002-9617-8641"
    }
  ],
  "s:keywords": [
    "OSPD",
    "mangrove",
    "biomass"
  ],
  "s:codeRepository": "https://github.com/starling-foundries/KindGrove",
  "s:license": "https://github.com/starling-foundries/KindGrove?tab=MIT-1-ov-file#readme",
  "schemas": [
    "http://schema.org/version/9.0/schemaorg-current-http.rdf"
  ]
}

```

#### jsonld
```jsonld
{
  "@context": "https://geolabs.github.io/bblocks-eoap-cct/build/annotated/cct/cwl-to-ogcprocess/context.jsonld",
  "$graph": [
    {
      "class": "CommandLineTool",
      "id": "parse_aoi",
      "baseCommand": "echo",
      "arguments": [
        "--"
      ],
      "requirements": {
        "InlineJavascriptRequirement": {},
        "SchemaDefRequirement": {
          "types": [
            {
              "$import": "https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml"
            }
          ]
        },
        "ResourceRequirement": {
          "coresMax": 1,
          "ramMax": 512
        }
      },
      "hints": {
        "DockerRequirement": {
          "dockerPull": "alpine:3.22.2"
        }
      },
      "inputs": {
        "aoi": {
          "type": "https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml#BBox",
          "label": "Area of interest",
          "doc": "Area of interest defined as a bounding box"
        }
      },
      "outputs": {
        "west": {
          "type": "float",
          "outputBinding": {
            "outputEval": "$(inputs.aoi.bbox[0])"
          }
        },
        "south": {
          "type": "float",
          "outputBinding": {
            "outputEval": "$(inputs.aoi.bbox[1])"
          }
        },
        "east": {
          "type": "float",
          "outputBinding": {
            "outputEval": "$(inputs.aoi.bbox[2])"
          }
        },
        "north": {
          "type": "float",
          "outputBinding": {
            "outputEval": "$(inputs.aoi.bbox[3])"
          }
        },
        "output_dir": {
          "type": "string",
          "outputBinding": {
            "outputEval": "$(\"outputs\")"
          }
        }
      }
    },
    {
      "class": "Workflow",
      "id": "mangrove-workflow",
      "label": "Mangrove Biomass Workflow",
      "doc": "Workflow for Mangrove Biomass Analysis\n  \nThis workflow orchestrates the mangrove biomass estimation process using\nSentinel-2 imagery. It wraps the mangrove_workflow.cwl tool to provide\na reusable workflow for analyzing different study areas.\n",
      "requirements": {
        "StepInputExpressionRequirement": {},
        "ScatterFeatureRequirement": {},
        "SubworkflowFeatureRequirement": {},
        "InlineJavascriptRequirement": {},
        "SchemaDefRequirement": {
          "types": [
            {
              "$import": "https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml"
            },
            {
              "$import": "https://raw.githubusercontent.com/eoap/schemas/main/stac.yaml"
            }
          ]
        }
      },
      "inputs": {
        "cloud_cover_max": {
          "label": "Maximum Cloud Cover",
          "doc": "Maximum acceptable cloud cover percentage (0-100)",
          "type": "float"
        },
        "days_back": {
          "label": "Days Back",
          "doc": "Number of days to search backwards from current date",
          "type": "int"
        },
        "aoi": {
          "label": "Area of Interest",
          "doc": "Area of interest as a bounding box",
          "type": "https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml#BBox"
        }
      },
      "outputs": {
        "stac": {
          "type": "Directory",
          "outputSource": [
            "step_1/result"
          ]
        }
      },
      "steps": {
        "parse_aoi": {
          "run": "#parse_aoi",
          "in": {
            "aoi": "aoi"
          },
          "out": [
            "west",
            "south",
            "east",
            "north",
            "output_dir"
          ]
        },
        "step_1": {
          "in": {
            "cloud_cover_max": "cloud_cover_max",
            "days_back": "days_back",
            "south": "parse_aoi/south",
            "west": "parse_aoi/west",
            "east": "parse_aoi/east",
            "north": "parse_aoi/north",
            "output_dir": "parse_aoi/output_dir"
          },
          "run": "#mangrove_cli",
          "out": [
            "result"
          ]
        }
      }
    },
    {
      "id": "mangrove_cli",
      "arguments": [
        "--"
      ],
      "baseCommand": "/app/cwl/bin/mangrove_workflow_for_cwl",
      "class": "CommandLineTool",
      "requirements": {
        "InlineJavascriptRequirement": {},
        "ResourceRequirement": {
          "coresMax": 1,
          "ramMax": 512
        }
      },
      "hints": {
        "DockerRequirement": {
          "dockerPull": "ghcr.io/geolabs/kindgrove/mangrove-cwl:v0.0.1-rc7"
        }
      },
      "inputs": {
        "cloud_cover_max": {
          "inputBinding": {
            "prefix": "--cloud_cover_max"
          },
          "type": "float"
        },
        "days_back": {
          "inputBinding": {
            "prefix": "--days_back"
          },
          "type": "int"
        },
        "east": {
          "inputBinding": {
            "prefix": "--east"
          },
          "type": "float"
        },
        "north": {
          "inputBinding": {
            "prefix": "--north"
          },
          "type": "float"
        },
        "south": {
          "inputBinding": {
            "prefix": "--south"
          },
          "type": "float"
        },
        "west": {
          "inputBinding": {
            "prefix": "--west"
          },
          "type": "float"
        },
        "output_dir": {
          "inputBinding": {
            "prefix": "--output_dir"
          },
          "type": "string"
        }
      },
      "outputs": {
        "result": {
          "type": "Directory",
          "outputBinding": {
            "glob": "outputs"
          }
        }
      }
    }
  ],
  "$namespaces": {
    "s": "https://schema.org/"
  },
  "cwlVersion": "v1.0",
  "s:softwareVersion": "0.0.1",
  "s:author": [
    {
      "class": "s:Person",
      "s:name": "Cameron Sajedi"
    }
  ],
  "s:contributor": [
    {
      "class": "s:Person",
      "s:name": "G\u00e9rald Fenoy",
      "s:identifier": "https://orcid.org/0000-0002-9617-8641"
    }
  ],
  "s:keywords": [
    "OSPD",
    "mangrove",
    "biomass"
  ],
  "s:codeRepository": "https://github.com/starling-foundries/KindGrove",
  "s:license": "https://github.com/starling-foundries/KindGrove?tab=MIT-1-ov-file#readme",
  "schemas": [
    "http://schema.org/version/9.0/schemaorg-current-http.rdf"
  ]
}
```

#### ttl
```ttl
@prefix cwl: <https://w3id.org/cwl/cwl#> .
@prefix dct: <http://purl.org/dc/terms/> .
@prefix geo: <http://www.opengis.net/ont/geosparql#> .
@prefix ns1: <s:> .
@prefix ns2: <rdf:> .
@prefix ogcproc: <http://www.opengis.net/def/ogcapi/processes/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

[] cwl:cwlVersion <file:///github/workspace/v1.0> ;
    cwl:graph [ dct:identifier <file:///github/workspace/parse_aoi> ;
            ogcproc:input _:Nf5d5d694bb884a2394e9e5dce8ff8d45 ;
            ogcproc:output _:N03e9060013c34e5da2a266021544a430 ;
            cwl:arguments ( "--" ) ;
            cwl:baseCommand "\"echo\""^^rdf:JSON ;
            cwl:hints [ cwl:DockerRequirement [ cwl:dockerPull "alpine:3.22.2"^^xsd:string ] ] ;
            cwl:input _:Nf5d5d694bb884a2394e9e5dce8ff8d45 ;
            cwl:output _:N03e9060013c34e5da2a266021544a430 ;
            cwl:requirements [ cwl:InlineJavascriptRequirement [ ] ;
                    cwl:ResourceRequirement [ cwl:coresMax 1 ;
                            cwl:ramMax 512 ] ;
                    cwl:SchemaDefRequirement [ cwl:types [ cwl:import <https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml> ] ] ] ;
            ns2:type <file:///github/workspace/CommandLineTool> ],
        [ dct:identifier <file:///github/workspace/mangrove_cli> ;
            ogcproc:input _:Nd6941b6cfcd648dab4db1173e56e4567 ;
            ogcproc:output _:N49038c7da2824c119ccf86c71fd3d1ac ;
            cwl:arguments ( "--" ) ;
            cwl:baseCommand "\"/app/cwl/bin/mangrove_workflow_for_cwl\""^^rdf:JSON ;
            cwl:hints [ cwl:DockerRequirement [ cwl:dockerPull "ghcr.io/geolabs/kindgrove/mangrove-cwl:v0.0.1-rc7"^^xsd:string ] ] ;
            cwl:input _:Nd6941b6cfcd648dab4db1173e56e4567 ;
            cwl:output _:N49038c7da2824c119ccf86c71fd3d1ac ;
            cwl:requirements [ cwl:InlineJavascriptRequirement [ ] ;
                    cwl:ResourceRequirement [ cwl:coresMax 1 ;
                            cwl:ramMax 512 ] ] ;
            ns2:type <file:///github/workspace/CommandLineTool> ],
        [ rdfs:label "Mangrove Biomass Workflow"^^xsd:string ;
            dct:identifier <file:///github/workspace/mangrove-workflow> ;
            ogcproc:input _:Nf40e91469d214f6e9c17a47f99da6756 ;
            ogcproc:output _:N2dfe5fb1f1a74c6b80dfa2169976080b ;
            rdfs:comment """Workflow for Mangrove Biomass Analysis
  
This workflow orchestrates the mangrove biomass estimation process using
Sentinel-2 imagery. It wraps the mangrove_workflow.cwl tool to provide
a reusable workflow for analyzing different study areas.
"""^^xsd:string ;
            cwl:input _:Nf40e91469d214f6e9c17a47f99da6756 ;
            cwl:output _:N2dfe5fb1f1a74c6b80dfa2169976080b ;
            cwl:requirements [ cwl:InlineJavascriptRequirement [ ] ;
                    cwl:ScatterFeatureRequirement [ ] ;
                    cwl:SchemaDefRequirement [ cwl:types [ cwl:import <https://raw.githubusercontent.com/eoap/schemas/main/stac.yaml> ],
                                [ cwl:import <https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml> ] ] ;
                    cwl:StepInputExpressionRequirement [ ] ;
                    cwl:SubworkflowFeatureRequirement [ ] ] ;
            cwl:steps [ cwl:parse_aoi [ cwl:in [ cwl:aoi "aoi" ] ;
                            cwl:out ( "west" "south" "east" "north" "output_dir" ) ;
                            cwl:run <file:///github/workspace/#parse_aoi> ] ;
                    cwl:step_1 [ cwl:in [ cwl:cloud_cover_max "cloud_cover_max" ;
                                    cwl:days_back "days_back" ;
                                    cwl:east "parse_aoi/east" ;
                                    cwl:north "parse_aoi/north" ;
                                    cwl:output_dir "parse_aoi/output_dir" ;
                                    cwl:south "parse_aoi/south" ;
                                    cwl:west "parse_aoi/west" ] ;
                            cwl:out ( "result" ) ;
                            cwl:run <file:///github/workspace/#mangrove_cli> ] ] ;
            ns2:type <file:///github/workspace/Workflow> ] ;
    cwl:namespaces "{\"s\":\"https://schema.org/\"}"^^rdf:JSON ;
    cwl:schemas "http://schema.org/version/9.0/schemaorg-current-http.rdf" ;
    ns1:author [ ns2:type ns1:Person ;
            ns1:name "Cameron Sajedi" ] ;
    ns1:codeRepository "https://github.com/starling-foundries/KindGrove" ;
    ns1:contributor [ ns2:type ns1:Person ;
            ns1:identifier "https://orcid.org/0000-0002-9617-8641" ;
            ns1:name "Gérald Fenoy" ] ;
    ns1:keywords "OSPD",
        "biomass",
        "mangrove" ;
    ns1:license "https://github.com/starling-foundries/KindGrove?tab=MIT-1-ov-file#readme" ;
    ns1:softwareVersion "0.0.1" .

_:N0860f139664d423585d8aea575c6c044 cwl:outputEval "$(inputs.aoi.bbox[2])"^^xsd:string .

_:N1419faf3ec264e5fb132f09d512843be cwl:glob "outputs"^^xsd:string .

_:N15ca917121d94e55a2b7ec5a6ff464ac cwl:prefix "--west"^^xsd:string .

_:N1f0da69914c04129a3d5da533929310a cwl:aoi [ rdfs:label "Area of Interest"^^xsd:string ;
            ogcproc:itemsType "number"^^xsd:string ;
            ogcproc:maxItems 6 ;
            ogcproc:minItems 4 ;
            ogcproc:schemaType "array"^^xsd:string ;
            rdfs:comment "Area of interest as a bounding box"^^xsd:string ;
            rdfs:seeAlso geo:BoundingBox ;
            cwl:type <https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml#BBox> ] ;
    cwl:cloud_cover_max [ rdfs:label "Maximum Cloud Cover"^^xsd:string ;
            rdfs:comment "Maximum acceptable cloud cover percentage (0-100)"^^xsd:string ;
            cwl:type <file:///github/workspace/float> ] ;
    cwl:days_back [ rdfs:label "Days Back"^^xsd:string ;
            rdfs:comment "Number of days to search backwards from current date"^^xsd:string ;
            cwl:type <file:///github/workspace/int> ] .

_:N2291cb9eda7c42798ffc1d9c9d0f04bd cwl:inputBinding [ cwl:prefix "--south"^^xsd:string ] ;
    cwl:type <file:///github/workspace/float> .

_:N23d961bedc014f29be200bb5d3221b88 cwl:inputBinding [ cwl:prefix "--output_dir"^^xsd:string ] ;
    cwl:type <file:///github/workspace/string> .

_:N242216cdd7534e8daeba1d909ed4de2e cwl:aoi [ rdfs:label "Area of interest"^^xsd:string ;
            ogcproc:itemsType "number"^^xsd:string ;
            ogcproc:maxItems 6 ;
            ogcproc:minItems 4 ;
            ogcproc:schemaType "array"^^xsd:string ;
            rdfs:comment "Area of interest defined as a bounding box"^^xsd:string ;
            rdfs:seeAlso geo:BoundingBox ;
            cwl:type <https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml#BBox> ] .

_:N29d6d99489624e608e43dc5bcce181ce cwl:outputEval "$(\"outputs\")"^^xsd:string .

_:N2ebd5c95d447465e8e4c430571627e37 cwl:prefix "--east"^^xsd:string .

_:N30c864f5353a445394bd49b57e9549a5 cwl:outputBinding _:N1419faf3ec264e5fb132f09d512843be ;
    cwl:type <file:///github/workspace/Directory> .

_:N39339c5467be4f199597f2ff9f6bd619 cwl:prefix "--north"^^xsd:string .

_:N41820769fcf34776b6fa6a7107c7ff70 cwl:inputBinding _:N2ebd5c95d447465e8e4c430571627e37 ;
    cwl:type <file:///github/workspace/float> .

_:N53fd664769d249af8381b6d62a9dea66 cwl:outputBinding _:N0860f139664d423585d8aea575c6c044 ;
    cwl:type <file:///github/workspace/float> .

_:N57e3289c61f64fb68d16a631beb67557 cwl:outputBinding [ cwl:outputEval "$(inputs.aoi.bbox[3])"^^xsd:string ] ;
    cwl:type <file:///github/workspace/float> .

_:N59b6d7be64514891bc2e64221e7d8173 cwl:outputEval "$(inputs.aoi.bbox[0])"^^xsd:string .

_:N5a63d3d3e87a4e80affb425036b5670a cwl:outputBinding [ cwl:outputEval "$(inputs.aoi.bbox[1])"^^xsd:string ] ;
    cwl:type <file:///github/workspace/float> .

_:N659aff3a729744b4a34ee1972376b7d9 cwl:cloud_cover_max [ cwl:inputBinding [ cwl:prefix "--cloud_cover_max"^^xsd:string ] ;
            cwl:type <file:///github/workspace/float> ] ;
    cwl:days_back [ cwl:inputBinding [ cwl:prefix "--days_back"^^xsd:string ] ;
            cwl:type <file:///github/workspace/int> ] ;
    cwl:east _:N41820769fcf34776b6fa6a7107c7ff70 ;
    cwl:north [ cwl:inputBinding _:N39339c5467be4f199597f2ff9f6bd619 ;
            cwl:type <file:///github/workspace/float> ] ;
    cwl:output_dir _:N23d961bedc014f29be200bb5d3221b88 ;
    cwl:south _:N2291cb9eda7c42798ffc1d9c9d0f04bd ;
    cwl:west [ cwl:inputBinding _:N15ca917121d94e55a2b7ec5a6ff464ac ;
            cwl:type <file:///github/workspace/float> ] .

_:N69ce2c0f25f042b68216b23c3493f8d7 cwl:result _:N30c864f5353a445394bd49b57e9549a5 .

_:N76bed7a771334d18ac4ce82963f7ecc8 cwl:stac [ cwl:outputSource <file:///github/workspace/step_1/result> ;
            cwl:type <file:///github/workspace/Directory> ] .

_:N9b3cc93176c84e46923c0345ebf87f73 cwl:east _:N53fd664769d249af8381b6d62a9dea66 ;
    cwl:north _:N57e3289c61f64fb68d16a631beb67557 ;
    cwl:output_dir [ cwl:outputBinding _:N29d6d99489624e608e43dc5bcce181ce ;
            cwl:type <file:///github/workspace/string> ] ;
    cwl:south _:N5a63d3d3e87a4e80affb425036b5670a ;
    cwl:west [ cwl:outputBinding _:N59b6d7be64514891bc2e64221e7d8173 ;
            cwl:type <file:///github/workspace/float> ] .

_:N03e9060013c34e5da2a266021544a430 a ogcproc:OutputDescription ;
    rdf:first _:N9b3cc93176c84e46923c0345ebf87f73 ;
    rdf:rest () .

_:N2dfe5fb1f1a74c6b80dfa2169976080b a ogcproc:OutputDescription ;
    rdf:first _:N76bed7a771334d18ac4ce82963f7ecc8 ;
    rdf:rest () .

_:N49038c7da2824c119ccf86c71fd3d1ac a ogcproc:OutputDescription ;
    rdf:first _:N69ce2c0f25f042b68216b23c3493f8d7 ;
    rdf:rest () .

_:Nd6941b6cfcd648dab4db1173e56e4567 a ogcproc:InputDescription ;
    rdf:first _:N659aff3a729744b4a34ee1972376b7d9 ;
    rdf:rest () .

_:Nf40e91469d214f6e9c17a47f99da6756 a ogcproc:InputDescription ;
    rdf:first _:N1f0da69914c04129a3d5da533929310a ;
    rdf:rest () .

_:Nf5d5d694bb884a2394e9e5dce8ff8d45 a ogcproc:InputDescription ;
    rdf:first _:N242216cdd7534e8daeba1d909ed4de2e ;
    rdf:rest () .


```


### Hartis CVI Workflow OSPD 2025
#### yaml
```yaml
cwlVersion: v1.2

$namespaces:
  s: https://schema.org/

$schemas:
  - http://schema.org/version/latest/schemaorg-current-http.rdf

$graph:
  - class: Workflow
    id: cvi-workflow
    label: CVI Workflow (Dockerized)
    doc: |
      This workflow computes the Coastal Vulnerability Index (CVI) for Mediterranean coastal areas.
      It processes coastline data, generates transects, computes various coastal parameters
      (landcover, slope, erosion, elevation), and calculates the final CVI values.
    
    requirements:
      StepInputExpressionRequirement: {}
      InlineJavascriptRequirement: {}
    
    s:author:
      - class: s:Person
        s:name: HARTIS Organization
        s:url: https://github.com/hartis-org
    
    s:codeRepository: https://github.com/hartis-org/cvi-workflow
    s:dateCreated: "2024-01-01"
    s:license: https://opensource.org/licenses/MIT
    s:version: "1.0.0"
    s:keywords: CVI, coastal vulnerability, Mediterranean, earth observation
    
    inputs:
      config_stac_item_url:
        type: string
        label: Configuration STAC item URL
        doc: URL of the STAC item containing the configuration JSON file
        default: "https://eocatalog.p2.csgroup.space/collections/cvi-workflow-resources/items/cvi-scoring-configuration"
      
      aois_stac_item_url:
        type: string
        label: AOIs STAC item URL
        doc: URL of the STAC item containing the Mediterranean AOIs CSV file
        default: "https://eocatalog.p2.csgroup.space/collections/cvi-workflow-resources/items/mediterranean-coastal-aois"
      
      tokens_stac_item_url:
        type: string
        label: Tokens STAC item URL
        doc: URL of the STAC item containing the authentication tokens file
        default: "https://eocatalog.p2.csgroup.space/collections/cvi-workflow-resources/items/cvi-authentication-template"
    
    outputs:
      validated_config:
        type: File
        label: Validated configuration
        doc: Validated configuration JSON file
        outputSource: setup_env/config_validated
      
      coastline_gpkg:
        type: File
        label: Coastline GeoPackage
        doc: Extracted coastline geometry in GeoPackage format
        outputSource: extract_coastline/coastline_gpkg
      
      transects_geojson:
        type: File
        label: Generated transects
        doc: Perpendicular transects generated along the coastline
        outputSource: generate_transects/transects_geojson
      
      transects_landcover:
        type: File
        label: Transects with landcover data
        doc: Transects enriched with landcover information
        outputSource: compute_landcover/result
      
      transects_slope:
        type: File
        label: Transects with slope data
        doc: Transects enriched with slope information
        outputSource: compute_slope/result
      
      transects_erosion:
        type: File
        label: Transects with erosion data
        doc: Transects enriched with erosion information
        outputSource: compute_erosion/result
      
      transects_elevation:
        type: File
        label: Transects with elevation data
        doc: Transects enriched with elevation information
        outputSource: compute_elevation/result
      
      cvi_geojson:
        type: File
        label: CVI results
        doc: Final Coastal Vulnerability Index values for all transects
        outputSource: compute_cvi/out_geojson
    
    steps:
      node_eodag_download_config:
        label: Download configuration [EODAG]
        doc: Download the configuration JSON file from STAC item
        run: '#eodag_search'
        in:
          stac_item_url: config_stac_item_url
        out: [data_output_dir]
      
      node_eodag_download_aois:
        label: Download AOIs [EODAG]
        doc: Download the Mediterranean AOIs CSV from STAC item
        run: '#eodag_search'
        in:
          stac_item_url: aois_stac_item_url
        out: [data_output_dir]
      
      node_eodag_download_tokens:
        label: Download tokens [EODAG]
        doc: Download the authentication tokens file from STAC item
        run: '#eodag_search'
        in:
          stac_item_url: tokens_stac_item_url
        out: [data_output_dir]
      
      setup_env:
        label: Setup Environment
        run: "#setup-env-tool"
        in:
          config_json:
            source: node_eodag_download_config/data_output_dir
            valueFrom: $(self.listing.filter(function(f) { return f.basename.match(/.*\.json$/i); })[0])
          output_dir: { default: "output_data" }
        out: [config_validated]
      
      extract_coastline:
        label: Extract Coastline
        run: "#extract-coastline-tool"
        in:
          med_aois_csv:
            source: node_eodag_download_aois/data_output_dir
            valueFrom: $(self.listing.filter(function(f) { return f.basename.match(/.*\.csv$/i); })[0])
          output_dir: { default: "output_data" }
        out: [coastline_gpkg]
      
      generate_transects:
        label: Generate Transects
        run: "#generate-transects-tool"
        in:
          coastline_gpkg: extract_coastline/coastline_gpkg
          output_dir: { default: "output_data" }
        out: [transects_geojson]
      
      compute_landcover:
        label: Compute Landcover
        run: "#compute-parameter-tool"
        in:
          script: { default: "/app/steps/compute_landcover.py" }
          transects_geojson: generate_transects/transects_geojson
          tokens_env:
            source: node_eodag_download_tokens/data_output_dir
            valueFrom: $(self.listing.filter(function(f) { return f.basename.match(/.*\.env$/i); })[0])
          config_json: setup_env/config_validated
          output_dir: { default: "output_data" }
        out: [result]
      
      compute_slope:
        label: Compute Slope
        run: "#compute-parameter-tool"
        in:
          script: { default: "/app/steps/compute_slope.py" }
          transects_geojson: generate_transects/transects_geojson
          tokens_env:
            source: node_eodag_download_tokens/data_output_dir
            valueFrom: $(self.listing.filter(function(f) { return f.basename.match(/.*\.env$/i); })[0])
          config_json: setup_env/config_validated
          output_dir: { default: "output_data" }
        out: [result]
      
      compute_erosion:
        label: Compute Erosion
        run: "#compute-parameter-tool"
        in:
          script: { default: "/app/steps/compute_erosion.py" }
          transects_geojson: generate_transects/transects_geojson
          tokens_env:
            source: node_eodag_download_tokens/data_output_dir
            valueFrom: $(self.listing.filter(function(f) { return f.basename.match(/.*\.env$/i); })[0])
          config_json: setup_env/config_validated
          output_dir: { default: "output_data" }
        out: [result]
      
      compute_elevation:
        label: Compute Elevation
        run: "#compute-parameter-tool"
        in:
          script: { default: "/app/steps/compute_elevation.py" }
          transects_geojson: generate_transects/transects_geojson
          tokens_env:
            source: node_eodag_download_tokens/data_output_dir
            valueFrom: $(self.listing.filter(function(f) { return f.basename.match(/.*\.env$/i); })[0])
          config_json: setup_env/config_validated
          output_dir: { default: "output_data" }
        out: [result]
      
      compute_cvi:
        label: Compute CVI Index
        run: "#compute-cvi-tool"
        in:
          transects_landcover: compute_landcover/result
          transects_slope: compute_slope/result
          transects_erosion: compute_erosion/result
          transects_elevation: compute_elevation/result
          config_json: setup_env/config_validated
          output_dir: { default: "output_data" }
        out: [out_geojson]
  
  # CommandLineTool definitions
  - class: CommandLineTool
    id: setup-env-tool
    label: Setup Environment
    doc: Validates configuration and initializes the working environment
    
    baseCommand: [python3, /app/steps/setup_env.py]
    
    hints:
      DockerRequirement: &docker_image
        dockerPull: ghcr.io/hartis-org/cvi-workflow:latest
    
    requirements:
      InlineJavascriptRequirement: {}
      InitialWorkDirRequirement:
        listing:
          - $(inputs.config_json)
          - { entry: "$({class: 'Directory', listing: []})", entryname: $(inputs.output_dir), writable: true }
    
    inputs:
      config_json:
        type: File
        inputBinding:
          position: 1
        doc: Configuration JSON file
      
      output_dir:
        type: string
        inputBinding:
          position: 2
        doc: Output directory path
    
    outputs:
      config_validated:
        type: File
        outputBinding:
          glob: "$(inputs.output_dir)/config_validated.json"
        doc: Validated configuration file
  
  - class: CommandLineTool
    id: extract-coastline-tool
    label: Extract Coastline
    doc: Extracts coastline geometry from Mediterranean AOIs
    
    baseCommand: [python3, /app/steps/extract_coastline.py]
    
    hints:
      DockerRequirement: *docker_image
    
    requirements:
      InlineJavascriptRequirement: {}
      InitialWorkDirRequirement:
        listing:
          - $(inputs.med_aois_csv)
          - { entry: "$({class: 'Directory', listing: []})", entryname: $(inputs.output_dir), writable: true }
    
    inputs:
      med_aois_csv:
        type: File
        inputBinding:
          position: 1
        doc: Mediterranean areas of interest CSV
      
      output_dir:
        type: string
        inputBinding:
          position: 2
        doc: Output directory path
    
    outputs:
      coastline_gpkg:
        type: File
        outputBinding:
          glob: "$(inputs.output_dir)/coastline.gpkg"
        doc: Extracted coastline GeoPackage
  
  - class: CommandLineTool
    id: generate-transects-tool
    label: Generate Transects
    doc: Generates perpendicular transects along the coastline
    
    baseCommand: [python3, /app/steps/generate_transects.py]
    
    hints:
      DockerRequirement: *docker_image
    
    requirements:
      InlineJavascriptRequirement: {}
      InitialWorkDirRequirement:
        listing:
          - $(inputs.coastline_gpkg)
          - { entry: "$({class: 'Directory', listing: []})", entryname: $(inputs.output_dir), writable: true }
    
    inputs:
      coastline_gpkg:
        type: File
        inputBinding:
          position: 1
        doc: Coastline GeoPackage
      
      output_dir:
        type: string
        inputBinding:
          position: 2
        doc: Output directory path
    
    outputs:
      transects_geojson:
        type: File
        outputBinding:
          glob: "$(inputs.output_dir)/transects.geojson"
        doc: Generated transects GeoJSON
  
  - class: CommandLineTool
    id: compute-parameter-tool
    label: Compute Parameter
    doc: Computes a CVI parameter (landcover, slope, erosion, or elevation) for transects
    
    baseCommand: [python3]
    
    hints:
      DockerRequirement: *docker_image
    
    requirements:
      InlineJavascriptRequirement: {}
      InitialWorkDirRequirement:
        listing:
          - entry: $(inputs.transects_geojson)
          - entry: $(inputs.tokens_env)
          - entry: $(inputs.config_json)
          - entry: "$({class: 'Directory', listing: []})"
            entryname: $(inputs.output_dir)
            writable: true
    
    inputs:
      script:
        type: string
        inputBinding:
          position: 0
        doc: Python script path for parameter computation
      
      transects_geojson:
        type: File
        inputBinding:
          position: 1
        doc: Transects GeoJSON file
      
      tokens_env:
        type: File
        inputBinding:
          position: 2
        doc: Authentication tokens file
      
      config_json:
        type: File
        inputBinding:
          position: 3
        doc: Configuration JSON file
      
      output_dir:
        type: string
        inputBinding:
          position: 4
        doc: Output directory path
    
    outputs:
      result:
        type: File
        outputBinding:
          glob: "$(inputs.output_dir)/*.geojson"
        doc: Transects enriched with parameter data
  
  - class: CommandLineTool
    id: compute-cvi-tool
    label: Compute CVI
    doc: Computes final Coastal Vulnerability Index from all parameters
    
    baseCommand: [python3, /app/steps/compute_cvi.py]
    
    hints:
      DockerRequirement: *docker_image
    
    requirements:
      InlineJavascriptRequirement: {}
      InitialWorkDirRequirement:
        listing:
          - $(inputs.transects_landcover)
          - $(inputs.transects_slope)
          - $(inputs.transects_erosion)
          - $(inputs.transects_elevation)
          - $(inputs.config_json)
          - { entry: "$({class: 'Directory', listing: []})", entryname: $(inputs.output_dir), writable: true }
    
    inputs:
      transects_landcover:
        type: File
        inputBinding:
          position: 1
        doc: Transects with landcover data
      
      transects_slope:
        type: File
        inputBinding:
          position: 2
        doc: Transects with slope data
      
      transects_erosion:
        type: File
        inputBinding:
          position: 3
        doc: Transects with erosion data
      
      transects_elevation:
        type: File
        inputBinding:
          position: 4
        doc: Transects with elevation data
      
      config_json:
        type: File
        inputBinding:
          position: 5
        doc: Configuration JSON file
      
      output_dir:
        type: string
        inputBinding:
          position: 6
        doc: Output directory path
    
    outputs:
      out_geojson:
        type: File
        outputBinding:
          glob: "$(inputs.output_dir)/transects_with_cvi_equal.geojson"
        doc: Final CVI results GeoJSON

  - class: CommandLineTool
    id: eodag_search
    label: Download input data
    doc: Downloads STAC item assets using EODAG
    
    s:softwareVersion: latest
    
    hints:
      DockerRequirement:
        dockerPull: |-
          ghcr.io/cs-si/eodag:v3.10.x
    
    requirements:
      InlineJavascriptRequirement: {}
      NetworkAccess:
        networkAccess: true
    
    baseCommand: [eodag, download]
    
    arguments:
      - prefix: "--output-dir"
        valueFrom: $(runtime.outdir)
    
    inputs:
      stac_item_url:
        type: string
        inputBinding:
          prefix: "--stac-item"
        doc: URL of the STAC item to download
    
    outputs:
      data_output_dir:
        type: Directory
        outputBinding:
          glob: $(runtime.outdir)/*
        doc: Directory containing downloaded STAC item assets
```

#### json
```json
{
  "cwlVersion": "v1.2",
  "$namespaces": {
    "s": "https://schema.org/"
  },
  "$schemas": [
    "http://schema.org/version/latest/schemaorg-current-http.rdf"
  ],
  "$graph": [
    {
      "class": "Workflow",
      "id": "cvi-workflow",
      "label": "CVI Workflow (Dockerized)",
      "doc": "This workflow computes the Coastal Vulnerability Index (CVI) for Mediterranean coastal areas.\nIt processes coastline data, generates transects, computes various coastal parameters\n(landcover, slope, erosion, elevation), and calculates the final CVI values.\n",
      "requirements": {
        "StepInputExpressionRequirement": {},
        "InlineJavascriptRequirement": {}
      },
      "s:author": [
        {
          "class": "s:Person",
          "s:name": "HARTIS Organization",
          "s:url": "https://github.com/hartis-org"
        }
      ],
      "s:codeRepository": "https://github.com/hartis-org/cvi-workflow",
      "s:dateCreated": "2024-01-01",
      "s:license": "https://opensource.org/licenses/MIT",
      "s:version": "1.0.0",
      "s:keywords": "CVI, coastal vulnerability, Mediterranean, earth observation",
      "inputs": {
        "config_stac_item_url": {
          "type": "string",
          "label": "Configuration STAC item URL",
          "doc": "URL of the STAC item containing the configuration JSON file",
          "default": "https://eocatalog.p2.csgroup.space/collections/cvi-workflow-resources/items/cvi-scoring-configuration"
        },
        "aois_stac_item_url": {
          "type": "string",
          "label": "AOIs STAC item URL",
          "doc": "URL of the STAC item containing the Mediterranean AOIs CSV file",
          "default": "https://eocatalog.p2.csgroup.space/collections/cvi-workflow-resources/items/mediterranean-coastal-aois"
        },
        "tokens_stac_item_url": {
          "type": "string",
          "label": "Tokens STAC item URL",
          "doc": "URL of the STAC item containing the authentication tokens file",
          "default": "https://eocatalog.p2.csgroup.space/collections/cvi-workflow-resources/items/cvi-authentication-template"
        }
      },
      "outputs": {
        "validated_config": {
          "type": "File",
          "label": "Validated configuration",
          "doc": "Validated configuration JSON file",
          "outputSource": "setup_env/config_validated"
        },
        "coastline_gpkg": {
          "type": "File",
          "label": "Coastline GeoPackage",
          "doc": "Extracted coastline geometry in GeoPackage format",
          "outputSource": "extract_coastline/coastline_gpkg"
        },
        "transects_geojson": {
          "type": "File",
          "label": "Generated transects",
          "doc": "Perpendicular transects generated along the coastline",
          "outputSource": "generate_transects/transects_geojson"
        },
        "transects_landcover": {
          "type": "File",
          "label": "Transects with landcover data",
          "doc": "Transects enriched with landcover information",
          "outputSource": "compute_landcover/result"
        },
        "transects_slope": {
          "type": "File",
          "label": "Transects with slope data",
          "doc": "Transects enriched with slope information",
          "outputSource": "compute_slope/result"
        },
        "transects_erosion": {
          "type": "File",
          "label": "Transects with erosion data",
          "doc": "Transects enriched with erosion information",
          "outputSource": "compute_erosion/result"
        },
        "transects_elevation": {
          "type": "File",
          "label": "Transects with elevation data",
          "doc": "Transects enriched with elevation information",
          "outputSource": "compute_elevation/result"
        },
        "cvi_geojson": {
          "type": "File",
          "label": "CVI results",
          "doc": "Final Coastal Vulnerability Index values for all transects",
          "outputSource": "compute_cvi/out_geojson"
        }
      },
      "steps": {
        "node_eodag_download_config": {
          "label": "Download configuration [EODAG]",
          "doc": "Download the configuration JSON file from STAC item",
          "run": "#eodag_search",
          "in": {
            "stac_item_url": "config_stac_item_url"
          },
          "out": [
            "data_output_dir"
          ]
        },
        "node_eodag_download_aois": {
          "label": "Download AOIs [EODAG]",
          "doc": "Download the Mediterranean AOIs CSV from STAC item",
          "run": "#eodag_search",
          "in": {
            "stac_item_url": "aois_stac_item_url"
          },
          "out": [
            "data_output_dir"
          ]
        },
        "node_eodag_download_tokens": {
          "label": "Download tokens [EODAG]",
          "doc": "Download the authentication tokens file from STAC item",
          "run": "#eodag_search",
          "in": {
            "stac_item_url": "tokens_stac_item_url"
          },
          "out": [
            "data_output_dir"
          ]
        },
        "setup_env": {
          "label": "Setup Environment",
          "run": "#setup-env-tool",
          "in": {
            "config_json": {
              "source": "node_eodag_download_config/data_output_dir",
              "valueFrom": "$(self.listing.filter(function(f) { return f.basename.match(/.*\\.json$/i); })[0])"
            },
            "output_dir": {
              "default": "output_data"
            }
          },
          "out": [
            "config_validated"
          ]
        },
        "extract_coastline": {
          "label": "Extract Coastline",
          "run": "#extract-coastline-tool",
          "in": {
            "med_aois_csv": {
              "source": "node_eodag_download_aois/data_output_dir",
              "valueFrom": "$(self.listing.filter(function(f) { return f.basename.match(/.*\\.csv$/i); })[0])"
            },
            "output_dir": {
              "default": "output_data"
            }
          },
          "out": [
            "coastline_gpkg"
          ]
        },
        "generate_transects": {
          "label": "Generate Transects",
          "run": "#generate-transects-tool",
          "in": {
            "coastline_gpkg": "extract_coastline/coastline_gpkg",
            "output_dir": {
              "default": "output_data"
            }
          },
          "out": [
            "transects_geojson"
          ]
        },
        "compute_landcover": {
          "label": "Compute Landcover",
          "run": "#compute-parameter-tool",
          "in": {
            "script": {
              "default": "/app/steps/compute_landcover.py"
            },
            "transects_geojson": "generate_transects/transects_geojson",
            "tokens_env": {
              "source": "node_eodag_download_tokens/data_output_dir",
              "valueFrom": "$(self.listing.filter(function(f) { return f.basename.match(/.*\\.env$/i); })[0])"
            },
            "config_json": "setup_env/config_validated",
            "output_dir": {
              "default": "output_data"
            }
          },
          "out": [
            "result"
          ]
        },
        "compute_slope": {
          "label": "Compute Slope",
          "run": "#compute-parameter-tool",
          "in": {
            "script": {
              "default": "/app/steps/compute_slope.py"
            },
            "transects_geojson": "generate_transects/transects_geojson",
            "tokens_env": {
              "source": "node_eodag_download_tokens/data_output_dir",
              "valueFrom": "$(self.listing.filter(function(f) { return f.basename.match(/.*\\.env$/i); })[0])"
            },
            "config_json": "setup_env/config_validated",
            "output_dir": {
              "default": "output_data"
            }
          },
          "out": [
            "result"
          ]
        },
        "compute_erosion": {
          "label": "Compute Erosion",
          "run": "#compute-parameter-tool",
          "in": {
            "script": {
              "default": "/app/steps/compute_erosion.py"
            },
            "transects_geojson": "generate_transects/transects_geojson",
            "tokens_env": {
              "source": "node_eodag_download_tokens/data_output_dir",
              "valueFrom": "$(self.listing.filter(function(f) { return f.basename.match(/.*\\.env$/i); })[0])"
            },
            "config_json": "setup_env/config_validated",
            "output_dir": {
              "default": "output_data"
            }
          },
          "out": [
            "result"
          ]
        },
        "compute_elevation": {
          "label": "Compute Elevation",
          "run": "#compute-parameter-tool",
          "in": {
            "script": {
              "default": "/app/steps/compute_elevation.py"
            },
            "transects_geojson": "generate_transects/transects_geojson",
            "tokens_env": {
              "source": "node_eodag_download_tokens/data_output_dir",
              "valueFrom": "$(self.listing.filter(function(f) { return f.basename.match(/.*\\.env$/i); })[0])"
            },
            "config_json": "setup_env/config_validated",
            "output_dir": {
              "default": "output_data"
            }
          },
          "out": [
            "result"
          ]
        },
        "compute_cvi": {
          "label": "Compute CVI Index",
          "run": "#compute-cvi-tool",
          "in": {
            "transects_landcover": "compute_landcover/result",
            "transects_slope": "compute_slope/result",
            "transects_erosion": "compute_erosion/result",
            "transects_elevation": "compute_elevation/result",
            "config_json": "setup_env/config_validated",
            "output_dir": {
              "default": "output_data"
            }
          },
          "out": [
            "out_geojson"
          ]
        }
      }
    },
    {
      "class": "CommandLineTool",
      "id": "setup-env-tool",
      "label": "Setup Environment",
      "doc": "Validates configuration and initializes the working environment",
      "baseCommand": [
        "python3",
        "/app/steps/setup_env.py"
      ],
      "hints": {
        "DockerRequirement": {
          "dockerPull": "ghcr.io/hartis-org/cvi-workflow:latest"
        }
      },
      "requirements": {
        "InlineJavascriptRequirement": {},
        "InitialWorkDirRequirement": {
          "listing": [
            "$(inputs.config_json)",
            {
              "entry": "$({class: 'Directory', listing: []})",
              "entryname": "$(inputs.output_dir)",
              "writable": true
            }
          ]
        }
      },
      "inputs": {
        "config_json": {
          "type": "File",
          "inputBinding": {
            "position": 1
          },
          "doc": "Configuration JSON file"
        },
        "output_dir": {
          "type": "string",
          "inputBinding": {
            "position": 2
          },
          "doc": "Output directory path"
        }
      },
      "outputs": {
        "config_validated": {
          "type": "File",
          "outputBinding": {
            "glob": "$(inputs.output_dir)/config_validated.json"
          },
          "doc": "Validated configuration file"
        }
      }
    },
    {
      "class": "CommandLineTool",
      "id": "extract-coastline-tool",
      "label": "Extract Coastline",
      "doc": "Extracts coastline geometry from Mediterranean AOIs",
      "baseCommand": [
        "python3",
        "/app/steps/extract_coastline.py"
      ],
      "hints": {
        "DockerRequirement": {
          "dockerPull": "ghcr.io/hartis-org/cvi-workflow:latest"
        }
      },
      "requirements": {
        "InlineJavascriptRequirement": {},
        "InitialWorkDirRequirement": {
          "listing": [
            "$(inputs.med_aois_csv)",
            {
              "entry": "$({class: 'Directory', listing: []})",
              "entryname": "$(inputs.output_dir)",
              "writable": true
            }
          ]
        }
      },
      "inputs": {
        "med_aois_csv": {
          "type": "File",
          "inputBinding": {
            "position": 1
          },
          "doc": "Mediterranean areas of interest CSV"
        },
        "output_dir": {
          "type": "string",
          "inputBinding": {
            "position": 2
          },
          "doc": "Output directory path"
        }
      },
      "outputs": {
        "coastline_gpkg": {
          "type": "File",
          "outputBinding": {
            "glob": "$(inputs.output_dir)/coastline.gpkg"
          },
          "doc": "Extracted coastline GeoPackage"
        }
      }
    },
    {
      "class": "CommandLineTool",
      "id": "generate-transects-tool",
      "label": "Generate Transects",
      "doc": "Generates perpendicular transects along the coastline",
      "baseCommand": [
        "python3",
        "/app/steps/generate_transects.py"
      ],
      "hints": {
        "DockerRequirement": {
          "dockerPull": "ghcr.io/hartis-org/cvi-workflow:latest"
        }
      },
      "requirements": {
        "InlineJavascriptRequirement": {},
        "InitialWorkDirRequirement": {
          "listing": [
            "$(inputs.coastline_gpkg)",
            {
              "entry": "$({class: 'Directory', listing: []})",
              "entryname": "$(inputs.output_dir)",
              "writable": true
            }
          ]
        }
      },
      "inputs": {
        "coastline_gpkg": {
          "type": "File",
          "inputBinding": {
            "position": 1
          },
          "doc": "Coastline GeoPackage"
        },
        "output_dir": {
          "type": "string",
          "inputBinding": {
            "position": 2
          },
          "doc": "Output directory path"
        }
      },
      "outputs": {
        "transects_geojson": {
          "type": "File",
          "outputBinding": {
            "glob": "$(inputs.output_dir)/transects.geojson"
          },
          "doc": "Generated transects GeoJSON"
        }
      }
    },
    {
      "class": "CommandLineTool",
      "id": "compute-parameter-tool",
      "label": "Compute Parameter",
      "doc": "Computes a CVI parameter (landcover, slope, erosion, or elevation) for transects",
      "baseCommand": [
        "python3"
      ],
      "hints": {
        "DockerRequirement": {
          "dockerPull": "ghcr.io/hartis-org/cvi-workflow:latest"
        }
      },
      "requirements": {
        "InlineJavascriptRequirement": {},
        "InitialWorkDirRequirement": {
          "listing": [
            {
              "entry": "$(inputs.transects_geojson)"
            },
            {
              "entry": "$(inputs.tokens_env)"
            },
            {
              "entry": "$(inputs.config_json)"
            },
            {
              "entry": "$({class: 'Directory', listing: []})",
              "entryname": "$(inputs.output_dir)",
              "writable": true
            }
          ]
        }
      },
      "inputs": {
        "script": {
          "type": "string",
          "inputBinding": {
            "position": 0
          },
          "doc": "Python script path for parameter computation"
        },
        "transects_geojson": {
          "type": "File",
          "inputBinding": {
            "position": 1
          },
          "doc": "Transects GeoJSON file"
        },
        "tokens_env": {
          "type": "File",
          "inputBinding": {
            "position": 2
          },
          "doc": "Authentication tokens file"
        },
        "config_json": {
          "type": "File",
          "inputBinding": {
            "position": 3
          },
          "doc": "Configuration JSON file"
        },
        "output_dir": {
          "type": "string",
          "inputBinding": {
            "position": 4
          },
          "doc": "Output directory path"
        }
      },
      "outputs": {
        "result": {
          "type": "File",
          "outputBinding": {
            "glob": "$(inputs.output_dir)/*.geojson"
          },
          "doc": "Transects enriched with parameter data"
        }
      }
    },
    {
      "class": "CommandLineTool",
      "id": "compute-cvi-tool",
      "label": "Compute CVI",
      "doc": "Computes final Coastal Vulnerability Index from all parameters",
      "baseCommand": [
        "python3",
        "/app/steps/compute_cvi.py"
      ],
      "hints": {
        "DockerRequirement": {
          "dockerPull": "ghcr.io/hartis-org/cvi-workflow:latest"
        }
      },
      "requirements": {
        "InlineJavascriptRequirement": {},
        "InitialWorkDirRequirement": {
          "listing": [
            "$(inputs.transects_landcover)",
            "$(inputs.transects_slope)",
            "$(inputs.transects_erosion)",
            "$(inputs.transects_elevation)",
            "$(inputs.config_json)",
            {
              "entry": "$({class: 'Directory', listing: []})",
              "entryname": "$(inputs.output_dir)",
              "writable": true
            }
          ]
        }
      },
      "inputs": {
        "transects_landcover": {
          "type": "File",
          "inputBinding": {
            "position": 1
          },
          "doc": "Transects with landcover data"
        },
        "transects_slope": {
          "type": "File",
          "inputBinding": {
            "position": 2
          },
          "doc": "Transects with slope data"
        },
        "transects_erosion": {
          "type": "File",
          "inputBinding": {
            "position": 3
          },
          "doc": "Transects with erosion data"
        },
        "transects_elevation": {
          "type": "File",
          "inputBinding": {
            "position": 4
          },
          "doc": "Transects with elevation data"
        },
        "config_json": {
          "type": "File",
          "inputBinding": {
            "position": 5
          },
          "doc": "Configuration JSON file"
        },
        "output_dir": {
          "type": "string",
          "inputBinding": {
            "position": 6
          },
          "doc": "Output directory path"
        }
      },
      "outputs": {
        "out_geojson": {
          "type": "File",
          "outputBinding": {
            "glob": "$(inputs.output_dir)/transects_with_cvi_equal.geojson"
          },
          "doc": "Final CVI results GeoJSON"
        }
      }
    },
    {
      "class": "CommandLineTool",
      "id": "eodag_search",
      "label": "Download input data",
      "doc": "Downloads STAC item assets using EODAG",
      "s:softwareVersion": "latest",
      "hints": {
        "DockerRequirement": {
          "dockerPull": "ghcr.io/cs-si/eodag:v3.10.x"
        }
      },
      "requirements": {
        "InlineJavascriptRequirement": {},
        "NetworkAccess": {
          "networkAccess": true
        }
      },
      "baseCommand": [
        "eodag",
        "download"
      ],
      "arguments": [
        {
          "prefix": "--output-dir",
          "valueFrom": "$(runtime.outdir)"
        }
      ],
      "inputs": {
        "stac_item_url": {
          "type": "string",
          "inputBinding": {
            "prefix": "--stac-item"
          },
          "doc": "URL of the STAC item to download"
        }
      },
      "outputs": {
        "data_output_dir": {
          "type": "Directory",
          "outputBinding": {
            "glob": "$(runtime.outdir)/*"
          },
          "doc": "Directory containing downloaded STAC item assets"
        }
      }
    }
  ]
}

```

#### jsonld
```jsonld
{
  "@context": "https://geolabs.github.io/bblocks-eoap-cct/build/annotated/cct/cwl-to-ogcprocess/context.jsonld",
  "cwlVersion": "v1.2",
  "$namespaces": {
    "s": "https://schema.org/"
  },
  "$schemas": [
    "http://schema.org/version/latest/schemaorg-current-http.rdf"
  ],
  "$graph": [
    {
      "class": "Workflow",
      "id": "cvi-workflow",
      "label": "CVI Workflow (Dockerized)",
      "doc": "This workflow computes the Coastal Vulnerability Index (CVI) for Mediterranean coastal areas.\nIt processes coastline data, generates transects, computes various coastal parameters\n(landcover, slope, erosion, elevation), and calculates the final CVI values.\n",
      "requirements": {
        "StepInputExpressionRequirement": {},
        "InlineJavascriptRequirement": {}
      },
      "s:author": [
        {
          "class": "s:Person",
          "s:name": "HARTIS Organization",
          "s:url": "https://github.com/hartis-org"
        }
      ],
      "s:codeRepository": "https://github.com/hartis-org/cvi-workflow",
      "s:dateCreated": "2024-01-01",
      "s:license": "https://opensource.org/licenses/MIT",
      "s:version": "1.0.0",
      "s:keywords": "CVI, coastal vulnerability, Mediterranean, earth observation",
      "inputs": {
        "config_stac_item_url": {
          "type": "string",
          "label": "Configuration STAC item URL",
          "doc": "URL of the STAC item containing the configuration JSON file",
          "default": "https://eocatalog.p2.csgroup.space/collections/cvi-workflow-resources/items/cvi-scoring-configuration"
        },
        "aois_stac_item_url": {
          "type": "string",
          "label": "AOIs STAC item URL",
          "doc": "URL of the STAC item containing the Mediterranean AOIs CSV file",
          "default": "https://eocatalog.p2.csgroup.space/collections/cvi-workflow-resources/items/mediterranean-coastal-aois"
        },
        "tokens_stac_item_url": {
          "type": "string",
          "label": "Tokens STAC item URL",
          "doc": "URL of the STAC item containing the authentication tokens file",
          "default": "https://eocatalog.p2.csgroup.space/collections/cvi-workflow-resources/items/cvi-authentication-template"
        }
      },
      "outputs": {
        "validated_config": {
          "type": "File",
          "label": "Validated configuration",
          "doc": "Validated configuration JSON file",
          "outputSource": "setup_env/config_validated"
        },
        "coastline_gpkg": {
          "type": "File",
          "label": "Coastline GeoPackage",
          "doc": "Extracted coastline geometry in GeoPackage format",
          "outputSource": "extract_coastline/coastline_gpkg"
        },
        "transects_geojson": {
          "type": "File",
          "label": "Generated transects",
          "doc": "Perpendicular transects generated along the coastline",
          "outputSource": "generate_transects/transects_geojson"
        },
        "transects_landcover": {
          "type": "File",
          "label": "Transects with landcover data",
          "doc": "Transects enriched with landcover information",
          "outputSource": "compute_landcover/result"
        },
        "transects_slope": {
          "type": "File",
          "label": "Transects with slope data",
          "doc": "Transects enriched with slope information",
          "outputSource": "compute_slope/result"
        },
        "transects_erosion": {
          "type": "File",
          "label": "Transects with erosion data",
          "doc": "Transects enriched with erosion information",
          "outputSource": "compute_erosion/result"
        },
        "transects_elevation": {
          "type": "File",
          "label": "Transects with elevation data",
          "doc": "Transects enriched with elevation information",
          "outputSource": "compute_elevation/result"
        },
        "cvi_geojson": {
          "type": "File",
          "label": "CVI results",
          "doc": "Final Coastal Vulnerability Index values for all transects",
          "outputSource": "compute_cvi/out_geojson"
        }
      },
      "steps": {
        "node_eodag_download_config": {
          "label": "Download configuration [EODAG]",
          "doc": "Download the configuration JSON file from STAC item",
          "run": "#eodag_search",
          "in": {
            "stac_item_url": "config_stac_item_url"
          },
          "out": [
            "data_output_dir"
          ]
        },
        "node_eodag_download_aois": {
          "label": "Download AOIs [EODAG]",
          "doc": "Download the Mediterranean AOIs CSV from STAC item",
          "run": "#eodag_search",
          "in": {
            "stac_item_url": "aois_stac_item_url"
          },
          "out": [
            "data_output_dir"
          ]
        },
        "node_eodag_download_tokens": {
          "label": "Download tokens [EODAG]",
          "doc": "Download the authentication tokens file from STAC item",
          "run": "#eodag_search",
          "in": {
            "stac_item_url": "tokens_stac_item_url"
          },
          "out": [
            "data_output_dir"
          ]
        },
        "setup_env": {
          "label": "Setup Environment",
          "run": "#setup-env-tool",
          "in": {
            "config_json": {
              "source": "node_eodag_download_config/data_output_dir",
              "valueFrom": "$(self.listing.filter(function(f) { return f.basename.match(/.*\\.json$/i); })[0])"
            },
            "output_dir": {
              "default": "output_data"
            }
          },
          "out": [
            "config_validated"
          ]
        },
        "extract_coastline": {
          "label": "Extract Coastline",
          "run": "#extract-coastline-tool",
          "in": {
            "med_aois_csv": {
              "source": "node_eodag_download_aois/data_output_dir",
              "valueFrom": "$(self.listing.filter(function(f) { return f.basename.match(/.*\\.csv$/i); })[0])"
            },
            "output_dir": {
              "default": "output_data"
            }
          },
          "out": [
            "coastline_gpkg"
          ]
        },
        "generate_transects": {
          "label": "Generate Transects",
          "run": "#generate-transects-tool",
          "in": {
            "coastline_gpkg": "extract_coastline/coastline_gpkg",
            "output_dir": {
              "default": "output_data"
            }
          },
          "out": [
            "transects_geojson"
          ]
        },
        "compute_landcover": {
          "label": "Compute Landcover",
          "run": "#compute-parameter-tool",
          "in": {
            "script": {
              "default": "/app/steps/compute_landcover.py"
            },
            "transects_geojson": "generate_transects/transects_geojson",
            "tokens_env": {
              "source": "node_eodag_download_tokens/data_output_dir",
              "valueFrom": "$(self.listing.filter(function(f) { return f.basename.match(/.*\\.env$/i); })[0])"
            },
            "config_json": "setup_env/config_validated",
            "output_dir": {
              "default": "output_data"
            }
          },
          "out": [
            "result"
          ]
        },
        "compute_slope": {
          "label": "Compute Slope",
          "run": "#compute-parameter-tool",
          "in": {
            "script": {
              "default": "/app/steps/compute_slope.py"
            },
            "transects_geojson": "generate_transects/transects_geojson",
            "tokens_env": {
              "source": "node_eodag_download_tokens/data_output_dir",
              "valueFrom": "$(self.listing.filter(function(f) { return f.basename.match(/.*\\.env$/i); })[0])"
            },
            "config_json": "setup_env/config_validated",
            "output_dir": {
              "default": "output_data"
            }
          },
          "out": [
            "result"
          ]
        },
        "compute_erosion": {
          "label": "Compute Erosion",
          "run": "#compute-parameter-tool",
          "in": {
            "script": {
              "default": "/app/steps/compute_erosion.py"
            },
            "transects_geojson": "generate_transects/transects_geojson",
            "tokens_env": {
              "source": "node_eodag_download_tokens/data_output_dir",
              "valueFrom": "$(self.listing.filter(function(f) { return f.basename.match(/.*\\.env$/i); })[0])"
            },
            "config_json": "setup_env/config_validated",
            "output_dir": {
              "default": "output_data"
            }
          },
          "out": [
            "result"
          ]
        },
        "compute_elevation": {
          "label": "Compute Elevation",
          "run": "#compute-parameter-tool",
          "in": {
            "script": {
              "default": "/app/steps/compute_elevation.py"
            },
            "transects_geojson": "generate_transects/transects_geojson",
            "tokens_env": {
              "source": "node_eodag_download_tokens/data_output_dir",
              "valueFrom": "$(self.listing.filter(function(f) { return f.basename.match(/.*\\.env$/i); })[0])"
            },
            "config_json": "setup_env/config_validated",
            "output_dir": {
              "default": "output_data"
            }
          },
          "out": [
            "result"
          ]
        },
        "compute_cvi": {
          "label": "Compute CVI Index",
          "run": "#compute-cvi-tool",
          "in": {
            "transects_landcover": "compute_landcover/result",
            "transects_slope": "compute_slope/result",
            "transects_erosion": "compute_erosion/result",
            "transects_elevation": "compute_elevation/result",
            "config_json": "setup_env/config_validated",
            "output_dir": {
              "default": "output_data"
            }
          },
          "out": [
            "out_geojson"
          ]
        }
      }
    },
    {
      "class": "CommandLineTool",
      "id": "setup-env-tool",
      "label": "Setup Environment",
      "doc": "Validates configuration and initializes the working environment",
      "baseCommand": [
        "python3",
        "/app/steps/setup_env.py"
      ],
      "hints": {
        "DockerRequirement": {
          "dockerPull": "ghcr.io/hartis-org/cvi-workflow:latest"
        }
      },
      "requirements": {
        "InlineJavascriptRequirement": {},
        "InitialWorkDirRequirement": {
          "listing": [
            "$(inputs.config_json)",
            {
              "entry": "$({class: 'Directory', listing: []})",
              "entryname": "$(inputs.output_dir)",
              "writable": true
            }
          ]
        }
      },
      "inputs": {
        "config_json": {
          "type": "File",
          "inputBinding": {
            "position": 1
          },
          "doc": "Configuration JSON file"
        },
        "output_dir": {
          "type": "string",
          "inputBinding": {
            "position": 2
          },
          "doc": "Output directory path"
        }
      },
      "outputs": {
        "config_validated": {
          "type": "File",
          "outputBinding": {
            "glob": "$(inputs.output_dir)/config_validated.json"
          },
          "doc": "Validated configuration file"
        }
      }
    },
    {
      "class": "CommandLineTool",
      "id": "extract-coastline-tool",
      "label": "Extract Coastline",
      "doc": "Extracts coastline geometry from Mediterranean AOIs",
      "baseCommand": [
        "python3",
        "/app/steps/extract_coastline.py"
      ],
      "hints": {
        "DockerRequirement": {
          "dockerPull": "ghcr.io/hartis-org/cvi-workflow:latest"
        }
      },
      "requirements": {
        "InlineJavascriptRequirement": {},
        "InitialWorkDirRequirement": {
          "listing": [
            "$(inputs.med_aois_csv)",
            {
              "entry": "$({class: 'Directory', listing: []})",
              "entryname": "$(inputs.output_dir)",
              "writable": true
            }
          ]
        }
      },
      "inputs": {
        "med_aois_csv": {
          "type": "File",
          "inputBinding": {
            "position": 1
          },
          "doc": "Mediterranean areas of interest CSV"
        },
        "output_dir": {
          "type": "string",
          "inputBinding": {
            "position": 2
          },
          "doc": "Output directory path"
        }
      },
      "outputs": {
        "coastline_gpkg": {
          "type": "File",
          "outputBinding": {
            "glob": "$(inputs.output_dir)/coastline.gpkg"
          },
          "doc": "Extracted coastline GeoPackage"
        }
      }
    },
    {
      "class": "CommandLineTool",
      "id": "generate-transects-tool",
      "label": "Generate Transects",
      "doc": "Generates perpendicular transects along the coastline",
      "baseCommand": [
        "python3",
        "/app/steps/generate_transects.py"
      ],
      "hints": {
        "DockerRequirement": {
          "dockerPull": "ghcr.io/hartis-org/cvi-workflow:latest"
        }
      },
      "requirements": {
        "InlineJavascriptRequirement": {},
        "InitialWorkDirRequirement": {
          "listing": [
            "$(inputs.coastline_gpkg)",
            {
              "entry": "$({class: 'Directory', listing: []})",
              "entryname": "$(inputs.output_dir)",
              "writable": true
            }
          ]
        }
      },
      "inputs": {
        "coastline_gpkg": {
          "type": "File",
          "inputBinding": {
            "position": 1
          },
          "doc": "Coastline GeoPackage"
        },
        "output_dir": {
          "type": "string",
          "inputBinding": {
            "position": 2
          },
          "doc": "Output directory path"
        }
      },
      "outputs": {
        "transects_geojson": {
          "type": "File",
          "outputBinding": {
            "glob": "$(inputs.output_dir)/transects.geojson"
          },
          "doc": "Generated transects GeoJSON"
        }
      }
    },
    {
      "class": "CommandLineTool",
      "id": "compute-parameter-tool",
      "label": "Compute Parameter",
      "doc": "Computes a CVI parameter (landcover, slope, erosion, or elevation) for transects",
      "baseCommand": [
        "python3"
      ],
      "hints": {
        "DockerRequirement": {
          "dockerPull": "ghcr.io/hartis-org/cvi-workflow:latest"
        }
      },
      "requirements": {
        "InlineJavascriptRequirement": {},
        "InitialWorkDirRequirement": {
          "listing": [
            {
              "entry": "$(inputs.transects_geojson)"
            },
            {
              "entry": "$(inputs.tokens_env)"
            },
            {
              "entry": "$(inputs.config_json)"
            },
            {
              "entry": "$({class: 'Directory', listing: []})",
              "entryname": "$(inputs.output_dir)",
              "writable": true
            }
          ]
        }
      },
      "inputs": {
        "script": {
          "type": "string",
          "inputBinding": {
            "position": 0
          },
          "doc": "Python script path for parameter computation"
        },
        "transects_geojson": {
          "type": "File",
          "inputBinding": {
            "position": 1
          },
          "doc": "Transects GeoJSON file"
        },
        "tokens_env": {
          "type": "File",
          "inputBinding": {
            "position": 2
          },
          "doc": "Authentication tokens file"
        },
        "config_json": {
          "type": "File",
          "inputBinding": {
            "position": 3
          },
          "doc": "Configuration JSON file"
        },
        "output_dir": {
          "type": "string",
          "inputBinding": {
            "position": 4
          },
          "doc": "Output directory path"
        }
      },
      "outputs": {
        "result": {
          "type": "File",
          "outputBinding": {
            "glob": "$(inputs.output_dir)/*.geojson"
          },
          "doc": "Transects enriched with parameter data"
        }
      }
    },
    {
      "class": "CommandLineTool",
      "id": "compute-cvi-tool",
      "label": "Compute CVI",
      "doc": "Computes final Coastal Vulnerability Index from all parameters",
      "baseCommand": [
        "python3",
        "/app/steps/compute_cvi.py"
      ],
      "hints": {
        "DockerRequirement": {
          "dockerPull": "ghcr.io/hartis-org/cvi-workflow:latest"
        }
      },
      "requirements": {
        "InlineJavascriptRequirement": {},
        "InitialWorkDirRequirement": {
          "listing": [
            "$(inputs.transects_landcover)",
            "$(inputs.transects_slope)",
            "$(inputs.transects_erosion)",
            "$(inputs.transects_elevation)",
            "$(inputs.config_json)",
            {
              "entry": "$({class: 'Directory', listing: []})",
              "entryname": "$(inputs.output_dir)",
              "writable": true
            }
          ]
        }
      },
      "inputs": {
        "transects_landcover": {
          "type": "File",
          "inputBinding": {
            "position": 1
          },
          "doc": "Transects with landcover data"
        },
        "transects_slope": {
          "type": "File",
          "inputBinding": {
            "position": 2
          },
          "doc": "Transects with slope data"
        },
        "transects_erosion": {
          "type": "File",
          "inputBinding": {
            "position": 3
          },
          "doc": "Transects with erosion data"
        },
        "transects_elevation": {
          "type": "File",
          "inputBinding": {
            "position": 4
          },
          "doc": "Transects with elevation data"
        },
        "config_json": {
          "type": "File",
          "inputBinding": {
            "position": 5
          },
          "doc": "Configuration JSON file"
        },
        "output_dir": {
          "type": "string",
          "inputBinding": {
            "position": 6
          },
          "doc": "Output directory path"
        }
      },
      "outputs": {
        "out_geojson": {
          "type": "File",
          "outputBinding": {
            "glob": "$(inputs.output_dir)/transects_with_cvi_equal.geojson"
          },
          "doc": "Final CVI results GeoJSON"
        }
      }
    },
    {
      "class": "CommandLineTool",
      "id": "eodag_search",
      "label": "Download input data",
      "doc": "Downloads STAC item assets using EODAG",
      "s:softwareVersion": "latest",
      "hints": {
        "DockerRequirement": {
          "dockerPull": "ghcr.io/cs-si/eodag:v3.10.x"
        }
      },
      "requirements": {
        "InlineJavascriptRequirement": {},
        "NetworkAccess": {
          "networkAccess": true
        }
      },
      "baseCommand": [
        "eodag",
        "download"
      ],
      "arguments": [
        {
          "prefix": "--output-dir",
          "valueFrom": "$(runtime.outdir)"
        }
      ],
      "inputs": {
        "stac_item_url": {
          "type": "string",
          "inputBinding": {
            "prefix": "--stac-item"
          },
          "doc": "URL of the STAC item to download"
        }
      },
      "outputs": {
        "data_output_dir": {
          "type": "Directory",
          "outputBinding": {
            "glob": "$(runtime.outdir)/*"
          },
          "doc": "Directory containing downloaded STAC item assets"
        }
      }
    }
  ]
}
```

#### ttl
```ttl
@prefix cwl: <https://w3id.org/cwl/cwl#> .
@prefix dct: <http://purl.org/dc/terms/> .
@prefix ns1: <rdf:> .
@prefix ns2: <s:> .
@prefix ogcproc: <http://www.opengis.net/def/ogcapi/processes/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

[] cwl:cwlVersion <file:///github/workspace/v1.2> ;
    cwl:graph [ rdfs:label "Download input data"^^xsd:string ;
            dct:identifier <file:///github/workspace/eodag_search> ;
            ogcproc:input _:Nf5ec6ffc40d14d24ae8462516f0564e4 ;
            ogcproc:output _:Ne7636444d64d4a66a19fc94c20524f32 ;
            rdfs:comment "Downloads STAC item assets using EODAG"^^xsd:string ;
            cwl:arguments ( [ cwl:prefix "--output-dir"^^xsd:string ;
                        cwl:valueFrom "$(runtime.outdir)"^^xsd:string ] ) ;
            cwl:baseCommand "[\"eodag\",\"download\"]"^^rdf:JSON ;
            cwl:hints [ cwl:DockerRequirement [ cwl:dockerPull "ghcr.io/cs-si/eodag:v3.10.x"^^xsd:string ] ] ;
            cwl:input _:Nf5ec6ffc40d14d24ae8462516f0564e4 ;
            cwl:output _:Ne7636444d64d4a66a19fc94c20524f32 ;
            cwl:requirements [ cwl:InlineJavascriptRequirement [ ] ;
                    cwl:NetworkAccess [ cwl:networkAccess true ] ] ;
            ns1:type <file:///github/workspace/CommandLineTool> ;
            ns2:softwareVersion "latest" ],
        [ rdfs:label "Compute CVI"^^xsd:string ;
            dct:identifier <file:///github/workspace/compute-cvi-tool> ;
            ogcproc:input _:N97b6d11d25b84b889cab25fde26c9d1b ;
            ogcproc:output _:Ncc7c4492702d470f8216f62472804d63 ;
            rdfs:comment "Computes final Coastal Vulnerability Index from all parameters"^^xsd:string ;
            cwl:baseCommand "[\"python3\",\"/app/steps/compute_cvi.py\"]"^^rdf:JSON ;
            cwl:hints [ cwl:DockerRequirement [ cwl:dockerPull "ghcr.io/hartis-org/cvi-workflow:latest"^^xsd:string ] ] ;
            cwl:input _:N97b6d11d25b84b889cab25fde26c9d1b ;
            cwl:output _:Ncc7c4492702d470f8216f62472804d63 ;
            cwl:requirements [ cwl:InitialWorkDirRequirement [ cwl:listing [ cwl:entry "$({class: 'Directory', listing: []})" ;
                                    cwl:entryname "$(inputs.output_dir)" ;
                                    cwl:writable true ],
                                "$(inputs.config_json)",
                                "$(inputs.transects_elevation)",
                                "$(inputs.transects_erosion)",
                                "$(inputs.transects_landcover)",
                                "$(inputs.transects_slope)" ] ;
                    cwl:InlineJavascriptRequirement [ ] ] ;
            ns1:type <file:///github/workspace/CommandLineTool> ],
        [ rdfs:label "CVI Workflow (Dockerized)"^^xsd:string ;
            dct:identifier <file:///github/workspace/cvi-workflow> ;
            ogcproc:input _:N4d48305395d0469399a5e624b20556bd ;
            ogcproc:output _:Nf83dc1dd84a5498db7a9f1807cc297ca ;
            rdfs:comment """This workflow computes the Coastal Vulnerability Index (CVI) for Mediterranean coastal areas.
It processes coastline data, generates transects, computes various coastal parameters
(landcover, slope, erosion, elevation), and calculates the final CVI values.
"""^^xsd:string ;
            cwl:input _:N4d48305395d0469399a5e624b20556bd ;
            cwl:output _:Nf83dc1dd84a5498db7a9f1807cc297ca ;
            cwl:requirements [ cwl:InlineJavascriptRequirement [ ] ;
                    cwl:StepInputExpressionRequirement [ ] ] ;
            cwl:steps [ cwl:compute_cvi [ rdfs:label "Compute CVI Index"^^xsd:string ;
                            cwl:in [ cwl:config_json "setup_env/config_validated" ;
                                    cwl:output_dir [ cwl:default "\"output_data\""^^rdf:JSON ] ;
                                    cwl:transects_elevation "compute_elevation/result" ;
                                    cwl:transects_erosion "compute_erosion/result" ;
                                    cwl:transects_landcover "compute_landcover/result" ;
                                    cwl:transects_slope "compute_slope/result" ] ;
                            cwl:out ( "out_geojson" ) ;
                            cwl:run <file:///github/workspace/#compute-cvi-tool> ] ;
                    cwl:compute_elevation [ rdfs:label "Compute Elevation"^^xsd:string ;
                            cwl:in [ cwl:config_json "setup_env/config_validated" ;
                                    cwl:output_dir [ cwl:default "\"output_data\""^^rdf:JSON ] ;
                                    cwl:script [ cwl:default "\"/app/steps/compute_elevation.py\""^^rdf:JSON ] ;
                                    cwl:tokens_env [ cwl:source <file:///github/workspace/node_eodag_download_tokens/data_output_dir> ;
                                            cwl:valueFrom "$(self.listing.filter(function(f) { return f.basename.match(/.*\\.env$/i); })[0])"^^xsd:string ] ;
                                    cwl:transects_geojson "generate_transects/transects_geojson" ] ;
                            cwl:out ( "result" ) ;
                            cwl:run <file:///github/workspace/#compute-parameter-tool> ] ;
                    cwl:compute_erosion [ rdfs:label "Compute Erosion"^^xsd:string ;
                            cwl:in [ cwl:config_json "setup_env/config_validated" ;
                                    cwl:output_dir [ cwl:default "\"output_data\""^^rdf:JSON ] ;
                                    cwl:script [ cwl:default "\"/app/steps/compute_erosion.py\""^^rdf:JSON ] ;
                                    cwl:tokens_env [ cwl:source <file:///github/workspace/node_eodag_download_tokens/data_output_dir> ;
                                            cwl:valueFrom "$(self.listing.filter(function(f) { return f.basename.match(/.*\\.env$/i); })[0])"^^xsd:string ] ;
                                    cwl:transects_geojson "generate_transects/transects_geojson" ] ;
                            cwl:out ( "result" ) ;
                            cwl:run <file:///github/workspace/#compute-parameter-tool> ] ;
                    cwl:compute_landcover [ rdfs:label "Compute Landcover"^^xsd:string ;
                            cwl:in [ cwl:config_json "setup_env/config_validated" ;
                                    cwl:output_dir [ cwl:default "\"output_data\""^^rdf:JSON ] ;
                                    cwl:script [ cwl:default "\"/app/steps/compute_landcover.py\""^^rdf:JSON ] ;
                                    cwl:tokens_env [ cwl:source <file:///github/workspace/node_eodag_download_tokens/data_output_dir> ;
                                            cwl:valueFrom "$(self.listing.filter(function(f) { return f.basename.match(/.*\\.env$/i); })[0])"^^xsd:string ] ;
                                    cwl:transects_geojson "generate_transects/transects_geojson" ] ;
                            cwl:out ( "result" ) ;
                            cwl:run <file:///github/workspace/#compute-parameter-tool> ] ;
                    cwl:compute_slope [ rdfs:label "Compute Slope"^^xsd:string ;
                            cwl:in [ cwl:config_json "setup_env/config_validated" ;
                                    cwl:output_dir [ cwl:default "\"output_data\""^^rdf:JSON ] ;
                                    cwl:script [ cwl:default "\"/app/steps/compute_slope.py\""^^rdf:JSON ] ;
                                    cwl:tokens_env [ cwl:source <file:///github/workspace/node_eodag_download_tokens/data_output_dir> ;
                                            cwl:valueFrom "$(self.listing.filter(function(f) { return f.basename.match(/.*\\.env$/i); })[0])"^^xsd:string ] ;
                                    cwl:transects_geojson "generate_transects/transects_geojson" ] ;
                            cwl:out ( "result" ) ;
                            cwl:run <file:///github/workspace/#compute-parameter-tool> ] ;
                    cwl:extract_coastline [ rdfs:label "Extract Coastline"^^xsd:string ;
                            cwl:in [ cwl:med_aois_csv [ cwl:source <file:///github/workspace/node_eodag_download_aois/data_output_dir> ;
                                            cwl:valueFrom "$(self.listing.filter(function(f) { return f.basename.match(/.*\\.csv$/i); })[0])"^^xsd:string ] ;
                                    cwl:output_dir [ cwl:default "\"output_data\""^^rdf:JSON ] ] ;
                            cwl:out ( "coastline_gpkg" ) ;
                            cwl:run <file:///github/workspace/#extract-coastline-tool> ] ;
                    cwl:generate_transects [ rdfs:label "Generate Transects"^^xsd:string ;
                            cwl:in [ cwl:coastline_gpkg "extract_coastline/coastline_gpkg" ;
                                    cwl:output_dir [ cwl:default "\"output_data\""^^rdf:JSON ] ] ;
                            cwl:out ( "transects_geojson" ) ;
                            cwl:run <file:///github/workspace/#generate-transects-tool> ] ;
                    cwl:node_eodag_download_aois [ rdfs:label "Download AOIs [EODAG]"^^xsd:string ;
                            rdfs:comment "Download the Mediterranean AOIs CSV from STAC item"^^xsd:string ;
                            cwl:in [ cwl:stac_item_url "aois_stac_item_url" ] ;
                            cwl:out ( "data_output_dir" ) ;
                            cwl:run <file:///github/workspace/#eodag_search> ] ;
                    cwl:node_eodag_download_config [ rdfs:label "Download configuration [EODAG]"^^xsd:string ;
                            rdfs:comment "Download the configuration JSON file from STAC item"^^xsd:string ;
                            cwl:in [ cwl:stac_item_url "config_stac_item_url" ] ;
                            cwl:out ( "data_output_dir" ) ;
                            cwl:run <file:///github/workspace/#eodag_search> ] ;
                    cwl:node_eodag_download_tokens [ rdfs:label "Download tokens [EODAG]"^^xsd:string ;
                            rdfs:comment "Download the authentication tokens file from STAC item"^^xsd:string ;
                            cwl:in [ cwl:stac_item_url "tokens_stac_item_url" ] ;
                            cwl:out ( "data_output_dir" ) ;
                            cwl:run <file:///github/workspace/#eodag_search> ] ;
                    cwl:setup_env [ rdfs:label "Setup Environment"^^xsd:string ;
                            cwl:in [ cwl:config_json [ cwl:source <file:///github/workspace/node_eodag_download_config/data_output_dir> ;
                                            cwl:valueFrom "$(self.listing.filter(function(f) { return f.basename.match(/.*\\.json$/i); })[0])"^^xsd:string ] ;
                                    cwl:output_dir [ cwl:default "\"output_data\""^^rdf:JSON ] ] ;
                            cwl:out ( "config_validated" ) ;
                            cwl:run <file:///github/workspace/#setup-env-tool> ] ] ;
            ns1:type <file:///github/workspace/Workflow> ;
            ns2:author [ ns1:type ns2:Person ;
                    ns2:name "HARTIS Organization" ;
                    ns2:url "https://github.com/hartis-org" ] ;
            ns2:codeRepository "https://github.com/hartis-org/cvi-workflow" ;
            ns2:dateCreated "2024-01-01" ;
            ns2:keywords "CVI, coastal vulnerability, Mediterranean, earth observation" ;
            ns2:license "https://opensource.org/licenses/MIT" ;
            ns2:version "1.0.0" ],
        [ rdfs:label "Setup Environment"^^xsd:string ;
            dct:identifier <file:///github/workspace/setup-env-tool> ;
            ogcproc:input _:N605ab1e98cb141f3ae26fe3870be7eb9 ;
            ogcproc:output _:Neb9ebc6cf7524aa58358484c3af2c310 ;
            rdfs:comment "Validates configuration and initializes the working environment"^^xsd:string ;
            cwl:baseCommand "[\"python3\",\"/app/steps/setup_env.py\"]"^^rdf:JSON ;
            cwl:hints [ cwl:DockerRequirement [ cwl:dockerPull "ghcr.io/hartis-org/cvi-workflow:latest"^^xsd:string ] ] ;
            cwl:input _:N605ab1e98cb141f3ae26fe3870be7eb9 ;
            cwl:output _:Neb9ebc6cf7524aa58358484c3af2c310 ;
            cwl:requirements [ cwl:InitialWorkDirRequirement [ cwl:listing [ cwl:entry "$({class: 'Directory', listing: []})" ;
                                    cwl:entryname "$(inputs.output_dir)" ;
                                    cwl:writable true ],
                                "$(inputs.config_json)" ] ;
                    cwl:InlineJavascriptRequirement [ ] ] ;
            ns1:type <file:///github/workspace/CommandLineTool> ],
        [ rdfs:label "Generate Transects"^^xsd:string ;
            dct:identifier <file:///github/workspace/generate-transects-tool> ;
            ogcproc:input _:N1043302db592425f8fa9d55de737c1d7 ;
            ogcproc:output _:Nbaaf535724834816ad35bd40e5abe8b8 ;
            rdfs:comment "Generates perpendicular transects along the coastline"^^xsd:string ;
            cwl:baseCommand "[\"python3\",\"/app/steps/generate_transects.py\"]"^^rdf:JSON ;
            cwl:hints [ cwl:DockerRequirement [ cwl:dockerPull "ghcr.io/hartis-org/cvi-workflow:latest"^^xsd:string ] ] ;
            cwl:input _:N1043302db592425f8fa9d55de737c1d7 ;
            cwl:output _:Nbaaf535724834816ad35bd40e5abe8b8 ;
            cwl:requirements [ cwl:InitialWorkDirRequirement [ cwl:listing [ cwl:entry "$({class: 'Directory', listing: []})" ;
                                    cwl:entryname "$(inputs.output_dir)" ;
                                    cwl:writable true ],
                                "$(inputs.coastline_gpkg)" ] ;
                    cwl:InlineJavascriptRequirement [ ] ] ;
            ns1:type <file:///github/workspace/CommandLineTool> ],
        [ rdfs:label "Extract Coastline"^^xsd:string ;
            dct:identifier <file:///github/workspace/extract-coastline-tool> ;
            ogcproc:input _:N76011466cba84e75b94f87e19ef78d02 ;
            ogcproc:output _:N7c4a64c6ff45488a80f5d860f09e10dc ;
            rdfs:comment "Extracts coastline geometry from Mediterranean AOIs"^^xsd:string ;
            cwl:baseCommand "[\"python3\",\"/app/steps/extract_coastline.py\"]"^^rdf:JSON ;
            cwl:hints [ cwl:DockerRequirement [ cwl:dockerPull "ghcr.io/hartis-org/cvi-workflow:latest"^^xsd:string ] ] ;
            cwl:input _:N76011466cba84e75b94f87e19ef78d02 ;
            cwl:output _:N7c4a64c6ff45488a80f5d860f09e10dc ;
            cwl:requirements [ cwl:InitialWorkDirRequirement [ cwl:listing [ cwl:entry "$({class: 'Directory', listing: []})" ;
                                    cwl:entryname "$(inputs.output_dir)" ;
                                    cwl:writable true ],
                                "$(inputs.med_aois_csv)" ] ;
                    cwl:InlineJavascriptRequirement [ ] ] ;
            ns1:type <file:///github/workspace/CommandLineTool> ],
        [ rdfs:label "Compute Parameter"^^xsd:string ;
            dct:identifier <file:///github/workspace/compute-parameter-tool> ;
            ogcproc:input _:Ncc313451f4404e7ebe5dc59299f5edde ;
            ogcproc:output _:Nbddc187a178648ae90ee5d6614844ae6 ;
            rdfs:comment "Computes a CVI parameter (landcover, slope, erosion, or elevation) for transects"^^xsd:string ;
            cwl:baseCommand "[\"python3\"]"^^rdf:JSON ;
            cwl:hints [ cwl:DockerRequirement [ cwl:dockerPull "ghcr.io/hartis-org/cvi-workflow:latest"^^xsd:string ] ] ;
            cwl:input _:Ncc313451f4404e7ebe5dc59299f5edde ;
            cwl:output _:Nbddc187a178648ae90ee5d6614844ae6 ;
            cwl:requirements [ cwl:InitialWorkDirRequirement [ cwl:listing [ cwl:entry "$(inputs.config_json)" ],
                                [ cwl:entry "$(inputs.tokens_env)" ],
                                [ cwl:entry "$(inputs.transects_geojson)" ],
                                [ cwl:entry "$({class: 'Directory', listing: []})" ;
                                    cwl:entryname "$(inputs.output_dir)" ;
                                    cwl:writable true ] ] ;
                    cwl:InlineJavascriptRequirement [ ] ] ;
            ns1:type <file:///github/workspace/CommandLineTool> ] ;
    cwl:namespaces "{\"s\":\"https://schema.org/\"}"^^rdf:JSON ;
    cwl:schemas ( "http://schema.org/version/latest/schemaorg-current-http.rdf" ) .

_:N00afa96c66944648991382f63b3b2de0 cwl:glob "$(inputs.output_dir)/coastline.gpkg"^^xsd:string .

_:N016d1596201e4d55813802a27c65ed83 rdfs:comment "Mediterranean areas of interest CSV"^^xsd:string ;
    cwl:inputBinding [ cwl:position "1"^^xsd:int ] ;
    cwl:type <file:///github/workspace/File> .

_:N0338737842a34c659ffa009e20ef517c cwl:position "2"^^xsd:int .

_:N0a7d91949faf4c519e5b2bf24c810aff cwl:out_geojson [ rdfs:comment "Final CVI results GeoJSON"^^xsd:string ;
            cwl:outputBinding [ cwl:glob "$(inputs.output_dir)/transects_with_cvi_equal.geojson"^^xsd:string ] ;
            cwl:type <file:///github/workspace/File> ] .

_:N0ae5d7ba06ae4b51abcc8d5abc27aec9 cwl:position "4"^^xsd:int .

_:N1232c84a454f43ad903d0038dbccda8e rdfs:comment "Output directory path"^^xsd:string ;
    cwl:inputBinding [ cwl:position "2"^^xsd:int ] ;
    cwl:type <file:///github/workspace/string> .

_:N13f66a7797154fcdb91a06bb5544dbc4 cwl:transects_geojson [ rdfs:comment "Generated transects GeoJSON"^^xsd:string ;
            cwl:outputBinding [ cwl:glob "$(inputs.output_dir)/transects.geojson"^^xsd:string ] ;
            cwl:type <file:///github/workspace/File> ] .

_:N16fde73b089542e69247d85c05c726de rdfs:label "Configuration STAC item URL"^^xsd:string ;
    rdfs:comment "URL of the STAC item containing the configuration JSON file"^^xsd:string ;
    cwl:default "\"https://eocatalog.p2.csgroup.space/collections/cvi-workflow-resources/items/cvi-scoring-configuration\""^^rdf:JSON ;
    cwl:type <file:///github/workspace/string> .

_:N1d729686a27345d1bee7ab7de82a3ef6 cwl:coastline_gpkg [ rdfs:comment "Extracted coastline GeoPackage"^^xsd:string ;
            cwl:outputBinding _:N00afa96c66944648991382f63b3b2de0 ;
            cwl:type <file:///github/workspace/File> ] .

_:N1e91e574a24f41ec9dabebf187c5f8f1 rdfs:comment "Python script path for parameter computation"^^xsd:string ;
    cwl:inputBinding [ cwl:position "0"^^xsd:int ] ;
    cwl:type <file:///github/workspace/string> .

_:N20f3bccb4e7642b3bfad0a9a6d22b716 cwl:config_validated [ rdfs:comment "Validated configuration file"^^xsd:string ;
            cwl:outputBinding [ cwl:glob "$(inputs.output_dir)/config_validated.json"^^xsd:string ] ;
            cwl:type <file:///github/workspace/File> ] .

_:N2245a9de93e54a5c946878f6f721eca1 cwl:config_json [ rdfs:comment "Configuration JSON file"^^xsd:string ;
            cwl:inputBinding [ cwl:position "3"^^xsd:int ] ;
            cwl:type <file:///github/workspace/File> ] ;
    cwl:output_dir [ rdfs:comment "Output directory path"^^xsd:string ;
            cwl:inputBinding [ cwl:position "4"^^xsd:int ] ;
            cwl:type <file:///github/workspace/string> ] ;
    cwl:script _:N1e91e574a24f41ec9dabebf187c5f8f1 ;
    cwl:tokens_env [ rdfs:comment "Authentication tokens file"^^xsd:string ;
            cwl:inputBinding [ cwl:position "2"^^xsd:int ] ;
            cwl:type <file:///github/workspace/File> ] ;
    cwl:transects_geojson [ rdfs:comment "Transects GeoJSON file"^^xsd:string ;
            cwl:inputBinding [ cwl:position "1"^^xsd:int ] ;
            cwl:type <file:///github/workspace/File> ] .

_:N2a6a4eb71a8c4eca907cebfc5f082f1d rdfs:label "Coastline GeoPackage"^^xsd:string ;
    rdfs:comment "Extracted coastline geometry in GeoPackage format"^^xsd:string ;
    cwl:outputSource <file:///github/workspace/extract_coastline/coastline_gpkg> ;
    cwl:type <file:///github/workspace/File> .

_:N35a70288f53d4414a8e3bf9db246f302 rdfs:comment "Transects with elevation data"^^xsd:string ;
    cwl:inputBinding _:N0ae5d7ba06ae4b51abcc8d5abc27aec9 ;
    cwl:type <file:///github/workspace/File> .

_:N35e4bc4bf41b48008493c0242ff24325 cwl:coastline_gpkg [ rdfs:comment "Coastline GeoPackage"^^xsd:string ;
            cwl:inputBinding [ cwl:position "1"^^xsd:int ] ;
            cwl:type <file:///github/workspace/File> ] ;
    cwl:output_dir _:N1232c84a454f43ad903d0038dbccda8e .

_:N39ef8c3dbaa84b898b9de29fb4e07db1 rdfs:label "Transects with landcover data"^^xsd:string ;
    rdfs:comment "Transects enriched with landcover information"^^xsd:string ;
    cwl:outputSource <file:///github/workspace/compute_landcover/result> ;
    cwl:type <file:///github/workspace/File> .

_:N4341c7bb1bdf470ba7f796bda159d568 cwl:position "3"^^xsd:int .

_:N498ca5701bec4320a861461ab0d04744 cwl:position "2"^^xsd:int .

_:N4c8df3c45d7049668d965f94aba53320 rdfs:comment "Output directory path"^^xsd:string ;
    cwl:inputBinding [ cwl:position "2"^^xsd:int ] ;
    cwl:type <file:///github/workspace/string> .

_:N503912ffe61a447d8f0c4cb5cd70efbc rdfs:comment "Directory containing downloaded STAC item assets"^^xsd:string ;
    cwl:outputBinding [ cwl:glob "$(runtime.outdir)/*"^^xsd:string ] ;
    cwl:type <file:///github/workspace/Directory> .

_:N526d1c9a5f65480b89c0c106df6e430c rdfs:comment "Transects with landcover data"^^xsd:string ;
    cwl:inputBinding [ cwl:position "1"^^xsd:int ] ;
    cwl:type <file:///github/workspace/File> .

_:N53daf27ba9de43e19d0de962c4845390 cwl:result [ rdfs:comment "Transects enriched with parameter data"^^xsd:string ;
            cwl:outputBinding [ cwl:glob "$(inputs.output_dir)/*.geojson"^^xsd:string ] ;
            cwl:type <file:///github/workspace/File> ] .

_:N5f87c300842a443d8c627ee11856aaf7 rdfs:label "CVI results"^^xsd:string ;
    rdfs:comment "Final Coastal Vulnerability Index values for all transects"^^xsd:string ;
    cwl:outputSource <file:///github/workspace/compute_cvi/out_geojson> ;
    cwl:type <file:///github/workspace/File> .

_:N6339cf8bffc24eb89acd51cd95e5a66b rdfs:comment "URL of the STAC item to download"^^xsd:string ;
    cwl:inputBinding [ cwl:prefix "--stac-item"^^xsd:string ] ;
    cwl:type <file:///github/workspace/string> .

_:N63932637694543e0b517e0d3ca91c504 rdfs:label "Transects with elevation data"^^xsd:string ;
    rdfs:comment "Transects enriched with elevation information"^^xsd:string ;
    cwl:outputSource <file:///github/workspace/compute_elevation/result> ;
    cwl:type <file:///github/workspace/File> .

_:N874d6143554e4c4bba148faf2a68842a rdfs:label "Transects with slope data"^^xsd:string ;
    rdfs:comment "Transects enriched with slope information"^^xsd:string ;
    cwl:outputSource <file:///github/workspace/compute_slope/result> ;
    cwl:type <file:///github/workspace/File> .

_:N8c9bbaf1feba4bd18cfee10261aa0c87 rdfs:label "AOIs STAC item URL"^^xsd:string ;
    rdfs:comment "URL of the STAC item containing the Mediterranean AOIs CSV file"^^xsd:string ;
    cwl:default "\"https://eocatalog.p2.csgroup.space/collections/cvi-workflow-resources/items/mediterranean-coastal-aois\""^^rdf:JSON ;
    cwl:type <file:///github/workspace/string> .

_:N8df81a94273c4c08b29fc002c3c1b820 cwl:stac_item_url _:N6339cf8bffc24eb89acd51cd95e5a66b .

_:N9b9210dde43c431c8e9dec3fa6c95e1a rdfs:label "Generated transects"^^xsd:string ;
    rdfs:comment "Perpendicular transects generated along the coastline"^^xsd:string ;
    cwl:outputSource <file:///github/workspace/generate_transects/transects_geojson> ;
    cwl:type <file:///github/workspace/File> .

_:N9cb8e7e8225d46e084b69fb6182b96b1 rdfs:label "Validated configuration"^^xsd:string ;
    rdfs:comment "Validated configuration JSON file"^^xsd:string ;
    cwl:outputSource <file:///github/workspace/setup_env/config_validated> ;
    cwl:type <file:///github/workspace/File> .

_:N9e60ba27115d4206b86d04cf256556a5 cwl:config_json [ rdfs:comment "Configuration JSON file"^^xsd:string ;
            cwl:inputBinding [ cwl:position "5"^^xsd:int ] ;
            cwl:type <file:///github/workspace/File> ] ;
    cwl:output_dir [ rdfs:comment "Output directory path"^^xsd:string ;
            cwl:inputBinding [ cwl:position "6"^^xsd:int ] ;
            cwl:type <file:///github/workspace/string> ] ;
    cwl:transects_elevation _:N35a70288f53d4414a8e3bf9db246f302 ;
    cwl:transects_erosion [ rdfs:comment "Transects with erosion data"^^xsd:string ;
            cwl:inputBinding _:N4341c7bb1bdf470ba7f796bda159d568 ;
            cwl:type <file:///github/workspace/File> ] ;
    cwl:transects_landcover _:N526d1c9a5f65480b89c0c106df6e430c ;
    cwl:transects_slope [ rdfs:comment "Transects with slope data"^^xsd:string ;
            cwl:inputBinding _:N0338737842a34c659ffa009e20ef517c ;
            cwl:type <file:///github/workspace/File> ] .

_:N9ea4aa6c569542f8b88da2b5b7a8f66f rdfs:comment "Configuration JSON file"^^xsd:string ;
    cwl:inputBinding [ cwl:position "1"^^xsd:int ] ;
    cwl:type <file:///github/workspace/File> .

_:Na17c31d7daba41698e8d455a132ea16e cwl:coastline_gpkg _:N2a6a4eb71a8c4eca907cebfc5f082f1d ;
    cwl:cvi_geojson _:N5f87c300842a443d8c627ee11856aaf7 ;
    cwl:transects_elevation _:N63932637694543e0b517e0d3ca91c504 ;
    cwl:transects_erosion [ rdfs:label "Transects with erosion data"^^xsd:string ;
            rdfs:comment "Transects enriched with erosion information"^^xsd:string ;
            cwl:outputSource <file:///github/workspace/compute_erosion/result> ;
            cwl:type <file:///github/workspace/File> ] ;
    cwl:transects_geojson _:N9b9210dde43c431c8e9dec3fa6c95e1a ;
    cwl:transects_landcover _:N39ef8c3dbaa84b898b9de29fb4e07db1 ;
    cwl:transects_slope _:N874d6143554e4c4bba148faf2a68842a ;
    cwl:validated_config _:N9cb8e7e8225d46e084b69fb6182b96b1 .

_:Nb4fca5300fa849c3aa952665f3a51856 cwl:med_aois_csv _:N016d1596201e4d55813802a27c65ed83 ;
    cwl:output_dir _:N4c8df3c45d7049668d965f94aba53320 .

_:Nbeedf0e51d624e33976bb321c0d0ede3 rdfs:label "Tokens STAC item URL"^^xsd:string ;
    rdfs:comment "URL of the STAC item containing the authentication tokens file"^^xsd:string ;
    cwl:default "\"https://eocatalog.p2.csgroup.space/collections/cvi-workflow-resources/items/cvi-authentication-template\""^^rdf:JSON ;
    cwl:type <file:///github/workspace/string> .

_:Nbf9d4c7c4ca24c1e8071011c193be12a cwl:data_output_dir _:N503912ffe61a447d8f0c4cb5cd70efbc .

_:Ne52d826acea148558600a42e363cd00e rdfs:comment "Output directory path"^^xsd:string ;
    cwl:inputBinding _:N498ca5701bec4320a861461ab0d04744 ;
    cwl:type <file:///github/workspace/string> .

_:Ne899490fe7f8439a89bfd4adb60c1af5 cwl:config_json _:N9ea4aa6c569542f8b88da2b5b7a8f66f ;
    cwl:output_dir _:Ne52d826acea148558600a42e363cd00e .

_:Nf931336343854f1f8bd563200a4c2075 cwl:aois_stac_item_url _:N8c9bbaf1feba4bd18cfee10261aa0c87 ;
    cwl:config_stac_item_url _:N16fde73b089542e69247d85c05c726de ;
    cwl:tokens_stac_item_url _:Nbeedf0e51d624e33976bb321c0d0ede3 .

_:N1043302db592425f8fa9d55de737c1d7 a ogcproc:InputDescription ;
    rdf:first _:N35e4bc4bf41b48008493c0242ff24325 ;
    rdf:rest () .

_:N4d48305395d0469399a5e624b20556bd a ogcproc:InputDescription ;
    rdf:first _:Nf931336343854f1f8bd563200a4c2075 ;
    rdf:rest () .

_:N605ab1e98cb141f3ae26fe3870be7eb9 a ogcproc:InputDescription ;
    rdf:first _:Ne899490fe7f8439a89bfd4adb60c1af5 ;
    rdf:rest () .

_:N76011466cba84e75b94f87e19ef78d02 a ogcproc:InputDescription ;
    rdf:first _:Nb4fca5300fa849c3aa952665f3a51856 ;
    rdf:rest () .

_:N7c4a64c6ff45488a80f5d860f09e10dc a ogcproc:OutputDescription ;
    rdf:first _:N1d729686a27345d1bee7ab7de82a3ef6 ;
    rdf:rest () .

_:N97b6d11d25b84b889cab25fde26c9d1b a ogcproc:InputDescription ;
    rdf:first _:N9e60ba27115d4206b86d04cf256556a5 ;
    rdf:rest () .

_:Nbaaf535724834816ad35bd40e5abe8b8 a ogcproc:OutputDescription ;
    rdf:first _:N13f66a7797154fcdb91a06bb5544dbc4 ;
    rdf:rest () .

_:Nbddc187a178648ae90ee5d6614844ae6 a ogcproc:OutputDescription ;
    rdf:first _:N53daf27ba9de43e19d0de962c4845390 ;
    rdf:rest () .

_:Ncc313451f4404e7ebe5dc59299f5edde a ogcproc:InputDescription ;
    rdf:first _:N2245a9de93e54a5c946878f6f721eca1 ;
    rdf:rest () .

_:Ncc7c4492702d470f8216f62472804d63 a ogcproc:OutputDescription ;
    rdf:first _:N0a7d91949faf4c519e5b2bf24c810aff ;
    rdf:rest () .

_:Ne7636444d64d4a66a19fc94c20524f32 a ogcproc:OutputDescription ;
    rdf:first _:Nbf9d4c7c4ca24c1e8071011c193be12a ;
    rdf:rest () .

_:Neb9ebc6cf7524aa58358484c3af2c310 a ogcproc:OutputDescription ;
    rdf:first _:N20f3bccb4e7642b3bfad0a9a6d22b716 ;
    rdf:rest () .

_:Nf5ec6ffc40d14d24ae8462516f0564e4 a ogcproc:InputDescription ;
    rdf:first _:N8df81a94273c4c08b29fc002c3c1b820 ;
    rdf:rest () .

_:Nf83dc1dd84a5498db7a9f1807cc297ca a ogcproc:OutputDescription ;
    rdf:first _:Na17c31d7daba41698e8d455a132ea16e ;
    rdf:rest () .


```

## Schema

```yaml
$ref: https://raw.githubusercontent.com/common-workflow-language/cwl-v1.2/main/json-schema/cwl.yaml
x-jsonld-extra-terms:
  '@comment': Metadata and provenance
  cwlVersion:
    x-jsonld-id: https://w3id.org/cwl/cwl#cwlVersion
    x-jsonld-type: '@id'
  class:
    x-jsonld-id: rdf:type
    x-jsonld-type: '@id'
  $graph:
    x-jsonld-id: https://w3id.org/cwl/cwl#graph
    x-jsonld-container: '@graph'
  id:
    x-jsonld-id: http://purl.org/dc/terms/identifier
    x-jsonld-type: '@id'
  label:
    x-jsonld-id: http://www.w3.org/2000/01/rdf-schema#label
    x-jsonld-type: http://www.w3.org/2001/XMLSchema#string
  doc:
    x-jsonld-id: http://www.w3.org/2000/01/rdf-schema#comment
    x-jsonld-type: http://www.w3.org/2001/XMLSchema#string
  inputs:
    x-jsonld-id: https://w3id.org/cwl/cwl#input
    x-jsonld-container: '@list'
  outputs:
    x-jsonld-id: https://w3id.org/cwl/cwl#output
    x-jsonld-container: '@list'
  steps:
    x-jsonld-id: https://w3id.org/cwl/cwl#steps
    x-jsonld-type: '@id'
  requirements:
    x-jsonld-id: https://w3id.org/cwl/cwl#requirements
    x-jsonld-container: '@set'
  hints:
    x-jsonld-id: https://w3id.org/cwl/cwl#hints
    x-jsonld-container: '@set'
  type:
    x-jsonld-id: https://w3id.org/cwl/cwl#type
    x-jsonld-type: '@id'
  format:
    x-jsonld-id: https://w3id.org/cwl/cwl#format
    x-jsonld-type: '@id'
  default:
    x-jsonld-id: https://w3id.org/cwl/cwl#default
    x-jsonld-type: '@json'
  baseCommand:
    x-jsonld-id: https://w3id.org/cwl/cwl#baseCommand
    x-jsonld-type: '@json'
  arguments:
    x-jsonld-id: https://w3id.org/cwl/cwl#arguments
    x-jsonld-container: '@list'
  stdin:
    x-jsonld-id: https://w3id.org/cwl/cwl#stdin
    x-jsonld-type: http://www.w3.org/2001/XMLSchema#string
  stdout:
    x-jsonld-id: https://w3id.org/cwl/cwl#stdout
    x-jsonld-type: http://www.w3.org/2001/XMLSchema#string
  stderr:
    x-jsonld-id: https://w3id.org/cwl/cwl#stderr
    x-jsonld-type: http://www.w3.org/2001/XMLSchema#string
  run:
    x-jsonld-id: https://w3id.org/cwl/cwl#run
    x-jsonld-type: '@id'
  in:
    x-jsonld-id: https://w3id.org/cwl/cwl#in
    x-jsonld-type: '@id'
  out:
    x-jsonld-id: https://w3id.org/cwl/cwl#out
    x-jsonld-container: '@list'
  outputSource:
    x-jsonld-id: https://w3id.org/cwl/cwl#outputSource
    x-jsonld-type: '@id'
  source:
    x-jsonld-id: https://w3id.org/cwl/cwl#source
    x-jsonld-type: '@id'
  CommandLineTool: https://w3id.org/cwl/cwl#CommandLineTool
  Workflow: https://w3id.org/cwl/cwl#Workflow
  ExpressionTool: https://w3id.org/cwl/cwl#ExpressionTool
  'null': https://w3id.org/cwl/cwl#null
  boolean: http://www.w3.org/2001/XMLSchema#boolean
  int: http://www.w3.org/2001/XMLSchema#int
  long: http://www.w3.org/2001/XMLSchema#long
  float: http://www.w3.org/2001/XMLSchema#float
  double: http://www.w3.org/2001/XMLSchema#double
  string: http://www.w3.org/2001/XMLSchema#string
  File: https://w3id.org/cwl/cwl#File
  Directory: https://w3id.org/cwl/cwl#Directory
  array: https://w3id.org/cwl/cwl#array
  record: https://w3id.org/cwl/cwl#record
  enum: https://w3id.org/cwl/cwl#enum
  items:
    x-jsonld-id: https://w3id.org/cwl/cwl#items
    x-jsonld-type: '@id'
  fields:
    x-jsonld-id: https://w3id.org/cwl/cwl#fields
    x-jsonld-container: '@list'
  symbols:
    x-jsonld-id: https://w3id.org/cwl/cwl#symbols
    x-jsonld-container: '@list'
  path:
    x-jsonld-id: https://w3id.org/cwl/cwl#path
    x-jsonld-type: http://www.w3.org/2001/XMLSchema#string
  location:
    x-jsonld-id: https://w3id.org/cwl/cwl#location
    x-jsonld-type: '@id'
  basename:
    x-jsonld-id: https://schema.org/name
    x-jsonld-type: http://www.w3.org/2001/XMLSchema#string
  dirname:
    x-jsonld-id: https://w3id.org/cwl/cwl#dirname
    x-jsonld-type: http://www.w3.org/2001/XMLSchema#string
  nameroot:
    x-jsonld-id: https://w3id.org/cwl/cwl#nameroot
    x-jsonld-type: http://www.w3.org/2001/XMLSchema#string
  nameext:
    x-jsonld-id: https://w3id.org/cwl/cwl#nameext
    x-jsonld-type: http://www.w3.org/2001/XMLSchema#string
  checksum:
    x-jsonld-id: https://w3id.org/cwl/cwl#checksum
    x-jsonld-type: http://www.w3.org/2001/XMLSchema#string
  size:
    x-jsonld-id: https://schema.org/contentSize
    x-jsonld-type: http://www.w3.org/2001/XMLSchema#long
  secondaryFiles:
    x-jsonld-id: https://w3id.org/cwl/cwl#secondaryFiles
    x-jsonld-container: '@list'
  InlineJavascriptRequirement: https://w3id.org/cwl/cwl#InlineJavascriptRequirement
  SchemaDefRequirement: https://w3id.org/cwl/cwl#SchemaDefRequirement
  DockerRequirement: https://w3id.org/cwl/cwl#DockerRequirement
  SoftwareRequirement: https://w3id.org/cwl/cwl#SoftwareRequirement
  InitialWorkDirRequirement: https://w3id.org/cwl/cwl#InitialWorkDirRequirement
  EnvVarRequirement: https://w3id.org/cwl/cwl#EnvVarRequirement
  ShellCommandRequirement: https://w3id.org/cwl/cwl#ShellCommandRequirement
  ResourceRequirement: https://w3id.org/cwl/cwl#ResourceRequirement
  WorkReuse: https://w3id.org/cwl/cwl#WorkReuse
  NetworkAccess: https://w3id.org/cwl/cwl#NetworkAccess
  InplaceUpdateRequirement: https://w3id.org/cwl/cwl#InplaceUpdateRequirement
  ToolTimeLimit: https://w3id.org/cwl/cwl#ToolTimeLimit
  SubworkflowFeatureRequirement: https://w3id.org/cwl/cwl#SubworkflowFeatureRequirement
  ScatterFeatureRequirement: https://w3id.org/cwl/cwl#ScatterFeatureRequirement
  MultipleInputFeatureRequirement: https://w3id.org/cwl/cwl#MultipleInputFeatureRequirement
  StepInputExpressionRequirement: https://w3id.org/cwl/cwl#StepInputExpressionRequirement
  dockerPull:
    x-jsonld-id: https://w3id.org/cwl/cwl#dockerPull
    x-jsonld-type: http://www.w3.org/2001/XMLSchema#string
  dockerLoad:
    x-jsonld-id: https://w3id.org/cwl/cwl#dockerLoad
    x-jsonld-type: http://www.w3.org/2001/XMLSchema#string
  dockerFile:
    x-jsonld-id: https://w3id.org/cwl/cwl#dockerFile
    x-jsonld-type: http://www.w3.org/2001/XMLSchema#string
  dockerImport:
    x-jsonld-id: https://w3id.org/cwl/cwl#dockerImport
    x-jsonld-type: http://www.w3.org/2001/XMLSchema#string
  dockerImageId:
    x-jsonld-id: https://w3id.org/cwl/cwl#dockerImageId
    x-jsonld-type: http://www.w3.org/2001/XMLSchema#string
  dockerOutputDirectory:
    x-jsonld-id: https://w3id.org/cwl/cwl#dockerOutputDirectory
    x-jsonld-type: http://www.w3.org/2001/XMLSchema#string
  inputBinding:
    x-jsonld-id: https://w3id.org/cwl/cwl#inputBinding
    x-jsonld-type: '@id'
  position:
    x-jsonld-id: https://w3id.org/cwl/cwl#position
    x-jsonld-type: http://www.w3.org/2001/XMLSchema#int
  prefix:
    x-jsonld-id: https://w3id.org/cwl/cwl#prefix
    x-jsonld-type: http://www.w3.org/2001/XMLSchema#string
  separate:
    x-jsonld-id: https://w3id.org/cwl/cwl#separate
    x-jsonld-type: http://www.w3.org/2001/XMLSchema#boolean
  itemSeparator:
    x-jsonld-id: https://w3id.org/cwl/cwl#itemSeparator
    x-jsonld-type: http://www.w3.org/2001/XMLSchema#string
  valueFrom:
    x-jsonld-id: https://w3id.org/cwl/cwl#valueFrom
    x-jsonld-type: http://www.w3.org/2001/XMLSchema#string
  shellQuote:
    x-jsonld-id: https://w3id.org/cwl/cwl#shellQuote
    x-jsonld-type: http://www.w3.org/2001/XMLSchema#boolean
  loadContents:
    x-jsonld-id: https://w3id.org/cwl/cwl#loadContents
    x-jsonld-type: http://www.w3.org/2001/XMLSchema#boolean
  loadListing:
    x-jsonld-id: https://w3id.org/cwl/cwl#loadListing
    x-jsonld-type: '@id'
  outputBinding:
    x-jsonld-id: https://w3id.org/cwl/cwl#outputBinding
    x-jsonld-type: '@id'
  glob:
    x-jsonld-id: https://w3id.org/cwl/cwl#glob
    x-jsonld-type: http://www.w3.org/2001/XMLSchema#string
  outputEval:
    x-jsonld-id: https://w3id.org/cwl/cwl#outputEval
    x-jsonld-type: http://www.w3.org/2001/XMLSchema#string
  scatter:
    x-jsonld-id: https://w3id.org/cwl/cwl#scatter
    x-jsonld-container: '@list'
  scatterMethod:
    x-jsonld-id: https://w3id.org/cwl/cwl#scatterMethod
    x-jsonld-type: '@id'
  intent:
    x-jsonld-id: http://www.w3.org/ns/prov#wasInfluencedBy
    x-jsonld-type: '@id'
  $namespaces:
    x-jsonld-id: https://w3id.org/cwl/cwl#namespaces
    x-jsonld-type: '@json'
  $schemas:
    x-jsonld-id: https://w3id.org/cwl/cwl#schemas
    x-jsonld-container: '@list'
  $import:
    x-jsonld-id: https://w3id.org/cwl/cwl#import
    x-jsonld-type: '@id'
  $include:
    x-jsonld-id: https://w3id.org/cwl/cwl#include
    x-jsonld-type: '@id'
x-jsonld-vocab: https://w3id.org/cwl/cwl#
x-jsonld-prefixes:
  cwl: https://w3id.org/cwl/cwl#
  dct: http://purl.org/dc/terms/
  rdfs: http://www.w3.org/2000/01/rdf-schema#
  xsd: http://www.w3.org/2001/XMLSchema#
  schema: https://schema.org/
  prov: http://www.w3.org/ns/prov#
  ogcproc: http://www.opengis.net/def/ogcapi/processes/

```

Links to the schema:

* YAML version: [schema.yaml](https://geolabs.github.io/bblocks-eoap-cct/build/annotated/cct/cwl-to-ogcprocess/schema.json)
* JSON version: [schema.json](https://geolabs.github.io/bblocks-eoap-cct/build/annotated/cct/cwl-to-ogcprocess/schema.yaml)


# JSON-LD Context

```jsonld
{
  "@context": {
    "@vocab": "https://w3id.org/cwl/cwl#",
    "@comment": "Metadata and provenance",
    "cwlVersion": {
      "@id": "cwl:cwlVersion",
      "@type": "@id"
    },
    "class": {
      "@id": "rdf:type",
      "@type": "@id"
    },
    "$graph": {
      "@id": "cwl:graph",
      "@container": "@graph"
    },
    "id": {
      "@id": "dct:identifier",
      "@type": "@id"
    },
    "label": {
      "@id": "rdfs:label",
      "@type": "xsd:string"
    },
    "doc": {
      "@id": "rdfs:comment",
      "@type": "xsd:string"
    },
    "inputs": {
      "@id": "cwl:input",
      "@container": "@list"
    },
    "outputs": {
      "@id": "cwl:output",
      "@container": "@list"
    },
    "steps": {
      "@id": "cwl:steps",
      "@type": "@id"
    },
    "requirements": {
      "@id": "cwl:requirements",
      "@container": "@set"
    },
    "hints": {
      "@id": "cwl:hints",
      "@container": "@set"
    },
    "type": {
      "@id": "cwl:type",
      "@type": "@id"
    },
    "format": {
      "@id": "cwl:format",
      "@type": "@id"
    },
    "default": {
      "@id": "cwl:default",
      "@type": "@json"
    },
    "baseCommand": {
      "@id": "cwl:baseCommand",
      "@type": "@json"
    },
    "arguments": {
      "@id": "cwl:arguments",
      "@container": "@list"
    },
    "stdin": {
      "@id": "cwl:stdin",
      "@type": "xsd:string"
    },
    "stdout": {
      "@id": "cwl:stdout",
      "@type": "xsd:string"
    },
    "stderr": {
      "@id": "cwl:stderr",
      "@type": "xsd:string"
    },
    "run": {
      "@id": "cwl:run",
      "@type": "@id"
    },
    "in": {
      "@id": "cwl:in",
      "@type": "@id"
    },
    "out": {
      "@id": "cwl:out",
      "@container": "@list"
    },
    "outputSource": {
      "@id": "cwl:outputSource",
      "@type": "@id"
    },
    "source": {
      "@id": "cwl:source",
      "@type": "@id"
    },
    "CommandLineTool": "cwl:CommandLineTool",
    "Workflow": "cwl:Workflow",
    "ExpressionTool": "cwl:ExpressionTool",
    "null": "cwl:null",
    "boolean": "xsd:boolean",
    "int": "xsd:int",
    "long": "xsd:long",
    "float": "xsd:float",
    "double": "xsd:double",
    "string": "xsd:string",
    "File": "cwl:File",
    "Directory": "cwl:Directory",
    "array": "cwl:array",
    "record": "cwl:record",
    "enum": "cwl:enum",
    "items": {
      "@id": "cwl:items",
      "@type": "@id"
    },
    "fields": {
      "@id": "cwl:fields",
      "@container": "@list"
    },
    "symbols": {
      "@id": "cwl:symbols",
      "@container": "@list"
    },
    "path": {
      "@id": "cwl:path",
      "@type": "xsd:string"
    },
    "location": {
      "@id": "cwl:location",
      "@type": "@id"
    },
    "basename": {
      "@id": "schema:name",
      "@type": "xsd:string"
    },
    "dirname": {
      "@id": "cwl:dirname",
      "@type": "xsd:string"
    },
    "nameroot": {
      "@id": "cwl:nameroot",
      "@type": "xsd:string"
    },
    "nameext": {
      "@id": "cwl:nameext",
      "@type": "xsd:string"
    },
    "checksum": {
      "@id": "cwl:checksum",
      "@type": "xsd:string"
    },
    "size": {
      "@id": "schema:contentSize",
      "@type": "xsd:long"
    },
    "secondaryFiles": {
      "@id": "cwl:secondaryFiles",
      "@container": "@list"
    },
    "InlineJavascriptRequirement": "cwl:InlineJavascriptRequirement",
    "SchemaDefRequirement": "cwl:SchemaDefRequirement",
    "DockerRequirement": "cwl:DockerRequirement",
    "SoftwareRequirement": "cwl:SoftwareRequirement",
    "InitialWorkDirRequirement": "cwl:InitialWorkDirRequirement",
    "EnvVarRequirement": "cwl:EnvVarRequirement",
    "ShellCommandRequirement": "cwl:ShellCommandRequirement",
    "ResourceRequirement": "cwl:ResourceRequirement",
    "WorkReuse": "cwl:WorkReuse",
    "NetworkAccess": "cwl:NetworkAccess",
    "InplaceUpdateRequirement": "cwl:InplaceUpdateRequirement",
    "ToolTimeLimit": "cwl:ToolTimeLimit",
    "SubworkflowFeatureRequirement": "cwl:SubworkflowFeatureRequirement",
    "ScatterFeatureRequirement": "cwl:ScatterFeatureRequirement",
    "MultipleInputFeatureRequirement": "cwl:MultipleInputFeatureRequirement",
    "StepInputExpressionRequirement": "cwl:StepInputExpressionRequirement",
    "dockerPull": {
      "@id": "cwl:dockerPull",
      "@type": "xsd:string"
    },
    "dockerLoad": {
      "@id": "cwl:dockerLoad",
      "@type": "xsd:string"
    },
    "dockerFile": {
      "@id": "cwl:dockerFile",
      "@type": "xsd:string"
    },
    "dockerImport": {
      "@id": "cwl:dockerImport",
      "@type": "xsd:string"
    },
    "dockerImageId": {
      "@id": "cwl:dockerImageId",
      "@type": "xsd:string"
    },
    "dockerOutputDirectory": {
      "@id": "cwl:dockerOutputDirectory",
      "@type": "xsd:string"
    },
    "inputBinding": {
      "@id": "cwl:inputBinding",
      "@type": "@id"
    },
    "position": {
      "@id": "cwl:position",
      "@type": "xsd:int"
    },
    "prefix": {
      "@id": "cwl:prefix",
      "@type": "xsd:string"
    },
    "separate": {
      "@id": "cwl:separate",
      "@type": "xsd:boolean"
    },
    "itemSeparator": {
      "@id": "cwl:itemSeparator",
      "@type": "xsd:string"
    },
    "valueFrom": {
      "@id": "cwl:valueFrom",
      "@type": "xsd:string"
    },
    "shellQuote": {
      "@id": "cwl:shellQuote",
      "@type": "xsd:boolean"
    },
    "loadContents": {
      "@id": "cwl:loadContents",
      "@type": "xsd:boolean"
    },
    "loadListing": {
      "@id": "cwl:loadListing",
      "@type": "@id"
    },
    "outputBinding": {
      "@id": "cwl:outputBinding",
      "@type": "@id"
    },
    "glob": {
      "@id": "cwl:glob",
      "@type": "xsd:string"
    },
    "outputEval": {
      "@id": "cwl:outputEval",
      "@type": "xsd:string"
    },
    "scatter": {
      "@id": "cwl:scatter",
      "@container": "@list"
    },
    "scatterMethod": {
      "@id": "cwl:scatterMethod",
      "@type": "@id"
    },
    "intent": {
      "@id": "prov:wasInfluencedBy",
      "@type": "@id"
    },
    "$namespaces": {
      "@id": "cwl:namespaces",
      "@type": "@json"
    },
    "$schemas": {
      "@id": "cwl:schemas",
      "@container": "@list"
    },
    "$import": {
      "@id": "cwl:import",
      "@type": "@id"
    },
    "$include": {
      "@id": "cwl:include",
      "@type": "@id"
    },
    "cwl": "https://w3id.org/cwl/cwl#",
    "dct": "http://purl.org/dc/terms/",
    "rdfs": "http://www.w3.org/2000/01/rdf-schema#",
    "xsd": "http://www.w3.org/2001/XMLSchema#",
    "schema": "https://schema.org/",
    "prov": "http://www.w3.org/ns/prov#",
    "ogcproc": "http://www.opengis.net/def/ogcapi/processes/",
    "@version": 1.1
  }
}
```

You can find the full JSON-LD context here:
[context.jsonld](https://geolabs.github.io/bblocks-eoap-cct/build/annotated/cct/cwl-to-ogcprocess/context.jsonld)

## Sources

* [Common Workflow Language (CWL) Specification](https://www.commonwl.org/v1.2/)
* [OGC API - Processes Part 1: Core](https://docs.ogc.org/is/18-062r2/18-062r2.html)
* [OGC Best Practice for Earth Observation Application Package](https://docs.ogc.org/bp/20-089r1.html)
* [Earth Observation Application Package (EOAP) CWL Custom Types](https://github.com/eoap/schemas)

# For developers

The source code for this Building Block can be found in the following repository:

* URL: [https://github.com/GeoLabs/bblocks-eoap-cct](https://github.com/GeoLabs/bblocks-eoap-cct)
* Path: `_sources/cwl-to-ogcprocess`

