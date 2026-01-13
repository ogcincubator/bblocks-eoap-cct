
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
  "@context": "https://ogcincubator.github.io/bblocks-eoap-cct/build/annotated/cct/cwl-to-ogcprocess/context.jsonld",
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
            ogcproc:input _:N9b570d691a92443ca5810809d1ea1d23 ;
            ogcproc:output _:N7e5e3440145a44419f37bb2c650daf5d ;
            cwl:baseCommand "\"echo\""^^rdf:JSON ;
            cwl:input _:N9b570d691a92443ca5810809d1ea1d23 ;
            cwl:output _:N7e5e3440145a44419f37bb2c650daf5d ;
            cwl:requirements [ cwl:types [ cwl:import <https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml> ] ;
                    ns1:type <file:///github/workspace/SchemaDefRequirement> ],
                [ ns1:type <file:///github/workspace/InlineJavascriptRequirement> ] ;
            cwl:stdout "echo_output.txt"^^xsd:string ;
            ns1:type <file:///github/workspace/CommandLineTool> ],
        [ rdfs:label "OGC BBox Processing Workflow"^^xsd:string ;
            dct:identifier <file:///github/workspace/bbox-workflow> ;
            ogcproc:input _:N2aa0e2b2048d40efadd4056fe2da99ff ;
            ogcproc:output _:Nb7d959c183c64ad589323871e9c2573a ;
            rdfs:comment "Workflow that processes OGC BBox input and generates output"^^xsd:string ;
            cwl:input _:N2aa0e2b2048d40efadd4056fe2da99ff ;
            cwl:output _:Nb7d959c183c64ad589323871e9c2573a ;
            cwl:requirements [ ns1:type <file:///github/workspace/InlineJavascriptRequirement> ],
                [ cwl:types [ cwl:import <https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml> ] ;
                    ns1:type <file:///github/workspace/SchemaDefRequirement> ] ;
            cwl:steps [ cwl:echo_step [ cwl:in [ cwl:aoi "aoi" ] ;
                            cwl:out ( "echo_output" ) ;
                            cwl:run <file:///github/workspace/#clt> ] ] ;
            ns1:type <file:///github/workspace/Workflow> ] .

_:N0123d86b40ba4ca693dd762dc38e8bbb rdfs:label "Echo output"^^xsd:string ;
    dct:identifier <file:///github/workspace/echo_output> ;
    rdfs:comment "Echoed BBox information"^^xsd:string ;
    cwl:outputSource <file:///github/workspace/echo_step/echo_output> ;
    cwl:type <file:///github/workspace/File> .

_:N63da9710aec54c399896bb16368533a7 rdfs:label "Area of interest"^^xsd:string ;
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
    cwl:type <https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml#BBox> .

_:N6456c3df4272487db91edcd2db86f725 rdfs:label "Area of interest"^^xsd:string ;
    dct:identifier <file:///github/workspace/aoi> ;
    ogcproc:itemsType "number"^^xsd:string ;
    ogcproc:maxItems 6 ;
    ogcproc:minItems 4 ;
    ogcproc:schemaType "array"^^xsd:string ;
    rdfs:comment "Area of interest defined as a bounding box"^^xsd:string ;
    rdfs:seeAlso geo:BoundingBox ;
    cwl:type <https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml#BBox> .

_:Na9e5bd2930c54eb2a4f7726083accf83 cwl:aoi _:N63da9710aec54c399896bb16368533a7 .

_:Nc3899f595b3b46b2a175179c94076d04 cwl:echo_output [ cwl:type <file:///github/workspace/stdout> ] .

_:N2aa0e2b2048d40efadd4056fe2da99ff a ogcproc:InputDescription ;
    rdf:first _:N6456c3df4272487db91edcd2db86f725 ;
    rdf:rest () .

_:N7e5e3440145a44419f37bb2c650daf5d a ogcproc:OutputDescription ;
    rdf:first _:Nc3899f595b3b46b2a175179c94076d04 ;
    rdf:rest () .

_:N9b570d691a92443ca5810809d1ea1d23 a ogcproc:InputDescription ;
    rdf:first _:Na9e5bd2930c54eb2a4f7726083accf83 ;
    rdf:rest () .

_:Nb7d959c183c64ad589323871e9c2573a a ogcproc:OutputDescription ;
    rdf:first _:N0123d86b40ba4ca693dd762dc38e8bbb ;
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
  "@context": "https://ogcincubator.github.io/bblocks-eoap-cct/build/annotated/cct/cwl-to-ogcprocess/context.jsonld",
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
            ogcproc:input _:N10a204cfdccf42de9168cf90df510acc ;
            ogcproc:output _:N116ac412478740239fd49bf54cd9730e ;
            cwl:baseCommand "\"echo\""^^rdf:JSON ;
            cwl:input _:N10a204cfdccf42de9168cf90df510acc ;
            cwl:output _:N116ac412478740239fd49bf54cd9730e ;
            cwl:requirements [ ns1:type <file:///github/workspace/InlineJavascriptRequirement> ],
                [ cwl:types [ cwl:import <https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml> ] ;
                    ns1:type <file:///github/workspace/SchemaDefRequirement> ] ;
            cwl:stdout "echo_output.txt"^^xsd:string ;
            ns1:type <file:///github/workspace/CommandLineTool> ],
        [ rdfs:label "GeoJSON Feature Processing Workflow"^^xsd:string ;
            dct:identifier <file:///github/workspace/feature-workflow> ;
            ogcproc:input _:N8368fb5c1f094f7d82d78c4476652309 ;
            ogcproc:output _:Ncd53c2517b8e41f9bf2c8c85c9db0113 ;
            rdfs:comment "Workflow that processes GeoJSON Feature input and generates output"^^xsd:string ;
            cwl:input _:N8368fb5c1f094f7d82d78c4476652309 ;
            cwl:output _:Ncd53c2517b8e41f9bf2c8c85c9db0113 ;
            cwl:requirements [ ns1:type <file:///github/workspace/InlineJavascriptRequirement> ],
                [ cwl:types [ cwl:import <https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml> ] ;
                    ns1:type <file:///github/workspace/SchemaDefRequirement> ] ;
            cwl:steps [ cwl:echo_step [ cwl:in [ cwl:aoi "aoi" ] ;
                            cwl:out ( "echo_output" ) ;
                            cwl:run <file:///github/workspace/#clt> ] ] ;
            ns1:type <file:///github/workspace/Workflow> ] .

_:N04f4f1f84d7f496da5ec6f7eecf7b1a6 cwl:echo_output [ cwl:type <file:///github/workspace/stdout> ] .

_:N222da70f427644afb6327f2c1a3d7aee rdfs:label "Area of interest"^^xsd:string ;
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

_:N529c2d30383d4e46a85d9b9acc834e12 rdfs:label "Area of interest"^^xsd:string ;
    dct:format <https://www.iana.org/assignments/media-types/application/geo+json> ;
    dct:identifier <file:///github/workspace/aoi> ;
    ogcproc:schemaType "object"^^xsd:string ;
    rdfs:comment "Area of interest defined in GeoJSON format"^^xsd:string ;
    rdfs:seeAlso <https://purl.org/geojson/vocab#Feature> ;
    cwl:type <https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml#Feature> .

_:N5f6c6fa523294b5c91fbe18d12100684 cwl:aoi _:N222da70f427644afb6327f2c1a3d7aee .

_:Nf75554450d784a6fbb60de6cdafba1b6 rdfs:label "Echo output"^^xsd:string ;
    dct:identifier <file:///github/workspace/echo_output> ;
    rdfs:comment "Echoed GeoJSON Feature information"^^xsd:string ;
    cwl:outputSource <file:///github/workspace/echo_step/echo_output> ;
    cwl:type <file:///github/workspace/File> .

_:N10a204cfdccf42de9168cf90df510acc a ogcproc:InputDescription ;
    rdf:first _:N5f6c6fa523294b5c91fbe18d12100684 ;
    rdf:rest () .

_:N116ac412478740239fd49bf54cd9730e a ogcproc:OutputDescription ;
    rdf:first _:N04f4f1f84d7f496da5ec6f7eecf7b1a6 ;
    rdf:rest () .

_:N8368fb5c1f094f7d82d78c4476652309 a ogcproc:InputDescription ;
    rdf:first _:N529c2d30383d4e46a85d9b9acc834e12 ;
    rdf:rest () .

_:Ncd53c2517b8e41f9bf2c8c85c9db0113 a ogcproc:OutputDescription ;
    rdf:first _:Nf75554450d784a6fbb60de6cdafba1b6 ;
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
  "@context": "https://ogcincubator.github.io/bblocks-eoap-cct/build/annotated/cct/cwl-to-ogcprocess/context.jsonld",
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
            ogcproc:input _:N34aa56a769ba478e9d8c058efca042a1 ;
            ogcproc:output _:Ndc21e7c9d2ad4523805c9b545f7e70d6 ;
            cwl:baseCommand "\"echo\""^^rdf:JSON ;
            cwl:input _:N34aa56a769ba478e9d8c058efca042a1 ;
            cwl:output _:Ndc21e7c9d2ad4523805c9b545f7e70d6 ;
            cwl:requirements [ ns1:type <file:///github/workspace/InlineJavascriptRequirement> ],
                [ cwl:types [ cwl:import <https://raw.githubusercontent.com/eoap/schemas/main/stac.yaml> ] ;
                    ns1:type <file:///github/workspace/SchemaDefRequirement> ] ;
            cwl:stdout "result.txt"^^xsd:string ;
            ns1:type <file:///github/workspace/CommandLineTool> ],
        [ rdfs:label "STAC Item Processing Workflow"^^xsd:string ;
            dct:identifier <file:///github/workspace/item-workflow> ;
            ogcproc:input _:Nd3d43df611ff494493cc15556d3f66a4 ;
            ogcproc:output _:N7c3706de92c042f09c2db2f02e7c364b ;
            rdfs:comment "Workflow that processes STAC Item input and generates output"^^xsd:string ;
            cwl:input _:Nd3d43df611ff494493cc15556d3f66a4 ;
            cwl:output _:N7c3706de92c042f09c2db2f02e7c364b ;
            cwl:requirements [ cwl:types [ cwl:import <https://raw.githubusercontent.com/eoap/schemas/main/stac.yaml> ] ;
                    ns1:type <file:///github/workspace/SchemaDefRequirement> ],
                [ ns1:type <file:///github/workspace/InlineJavascriptRequirement> ] ;
            cwl:steps [ cwl:process_step [ cwl:in [ cwl:stac_item "stac_item" ] ;
                            cwl:out ( "result" ) ;
                            cwl:run <file:///github/workspace/#clt> ] ] ;
            ns1:type <file:///github/workspace/Workflow> ] .

_:N203219d91f9e4caaaea9c8cd30f2dd0d cwl:valueFrom """${
  return "STAC Item ID: " + inputs.stac_item.id;
}
"""^^xsd:string .

_:N40ee3b52b6c74e1db91e417033779493 cwl:stac_item [ rdfs:label "STAC Item"^^xsd:string ;
            dct:format <https://www.iana.org/assignments/media-types/application/json> ;
            ogcproc:schemaType "object"^^xsd:string ;
            rdfs:comment "STAC Item representing a geospatial asset"^^xsd:string ;
            rdfs:seeAlso <https://stacspec.org/#item-spec> ;
            cwl:inputBinding _:N203219d91f9e4caaaea9c8cd30f2dd0d ;
            cwl:type <https://raw.githubusercontent.com/eoap/schemas/main/stac.yaml#Item> ] .

_:N4fecfbf2542944ce884fc8eab2fb6417 rdfs:label "Process result"^^xsd:string ;
    dct:identifier <file:///github/workspace/result> ;
    rdfs:comment "Processed STAC Item information"^^xsd:string ;
    cwl:outputSource <file:///github/workspace/process_step/result> ;
    cwl:type <file:///github/workspace/File> .

_:N852008ea85bb47b3849b2cbd36e6c38b cwl:type <file:///github/workspace/stdout> .

_:N9b185f2baa234cfc9e89df350b12a376 rdfs:label "STAC Item"^^xsd:string ;
    dct:format <https://www.iana.org/assignments/media-types/application/json> ;
    dct:identifier <file:///github/workspace/stac_item> ;
    ogcproc:schemaType "object"^^xsd:string ;
    rdfs:comment "STAC Item representing a geospatial asset"^^xsd:string ;
    rdfs:seeAlso <https://stacspec.org/#item-spec> ;
    cwl:type <https://raw.githubusercontent.com/eoap/schemas/main/stac.yaml#Item> .

_:Ncaf4c7a632ed4a588c3ae6e062a95224 cwl:result _:N852008ea85bb47b3849b2cbd36e6c38b .

_:N34aa56a769ba478e9d8c058efca042a1 a ogcproc:InputDescription ;
    rdf:first _:N40ee3b52b6c74e1db91e417033779493 ;
    rdf:rest () .

_:N7c3706de92c042f09c2db2f02e7c364b a ogcproc:OutputDescription ;
    rdf:first _:N4fecfbf2542944ce884fc8eab2fb6417 ;
    rdf:rest () .

_:Nd3d43df611ff494493cc15556d3f66a4 a ogcproc:InputDescription ;
    rdf:first _:N9b185f2baa234cfc9e89df350b12a376 ;
    rdf:rest () .

_:Ndc21e7c9d2ad4523805c9b545f7e70d6 a ogcproc:OutputDescription ;
    rdf:first _:Ncaf4c7a632ed4a588c3ae6e062a95224 ;
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
  "@context": "https://ogcincubator.github.io/bblocks-eoap-cct/build/annotated/cct/cwl-to-ogcprocess/context.jsonld",
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
    cwl:graph [ rdfs:label "Water bodies detection based on NDWI and otsu threshold"^^xsd:string ;
            dct:identifier <file:///github/workspace/water-bodies> ;
            ogcproc:input _:N770b149b9d87482fbc36a9f392331ac2 ;
            ogcproc:output _:Nbd7eb32de03149b9b13c1908de74a20b ;
            rdfs:comment "Water bodies detection based on NDWI and otsu threshold applied to Sentinel-2 COG STAC items"^^xsd:string ;
            cwl:input _:N770b149b9d87482fbc36a9f392331ac2 ;
            cwl:output _:Nbd7eb32de03149b9b13c1908de74a20b ;
            cwl:requirements [ ns1:type <file:///github/workspace/ScatterFeatureRequirement> ],
                [ ns1:type <file:///github/workspace/SubworkflowFeatureRequirement> ],
                [ cwl:types [ cwl:import <https://raw.githubusercontent.com/eoap/schemas/main/stac.yaml> ] ;
                    ns1:type <file:///github/workspace/SchemaDefRequirement> ] ;
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
        [ dct:identifier <file:///github/workspace/crop> ;
            ogcproc:input _:N2b771978d48343e9a74c6396abf3cfc4 ;
            ogcproc:output _:N349569651688402db101fc0fef7b3bb7 ;
            cwl:arguments () ;
            cwl:baseCommand "[\"python\",\"-m\",\"app\"]"^^rdf:JSON ;
            cwl:hints [ cwl:DockerRequirement [ cwl:dockerPull "cr.terradue.com/earthquake-monitoring/crop:latest"^^xsd:string ] ] ;
            cwl:input _:N2b771978d48343e9a74c6396abf3cfc4 ;
            cwl:output _:N349569651688402db101fc0fef7b3bb7 ;
            cwl:requirements [ cwl:EnvVarRequirement [ cwl:envDef [ cwl:PATH "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" ;
                                    cwl:PYTHONPATH "/app" ] ] ;
                    cwl:InlineJavascriptRequirement [ ] ;
                    cwl:ResourceRequirement [ cwl:coresMax 1 ;
                            cwl:ramMax 512 ] ] ;
            ns1:type <file:///github/workspace/CommandLineTool> ],
        [ dct:identifier <file:///github/workspace/norm_diff> ;
            ogcproc:input _:Nbcce4f2d169a459fb5b5450fa81bda1b ;
            ogcproc:output _:Nb2782d9823d041d4a6d52b0a9e6ae60a ;
            cwl:arguments () ;
            cwl:baseCommand "[\"python\",\"-m\",\"app\"]"^^rdf:JSON ;
            cwl:hints [ cwl:DockerRequirement [ cwl:dockerPull "cr.terradue.com/earthquake-monitoring/norm_diff:latest"^^xsd:string ] ] ;
            cwl:input _:Nbcce4f2d169a459fb5b5450fa81bda1b ;
            cwl:output _:Nb2782d9823d041d4a6d52b0a9e6ae60a ;
            cwl:requirements [ cwl:EnvVarRequirement [ cwl:envDef [ cwl:PATH "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" ;
                                    cwl:PYTHONPATH "/app" ] ] ;
                    cwl:InlineJavascriptRequirement [ ] ;
                    cwl:ResourceRequirement [ cwl:coresMax 1 ;
                            cwl:ramMax 512 ] ] ;
            ns1:type <file:///github/workspace/CommandLineTool> ],
        [ dct:identifier <file:///github/workspace/otsu> ;
            ogcproc:input _:N29d9e9503516429580cfca5bdc85888f ;
            ogcproc:output _:N0ccded199132450e8e50bfe25832a08a ;
            cwl:arguments () ;
            cwl:baseCommand "[\"python\",\"-m\",\"app\"]"^^rdf:JSON ;
            cwl:hints [ cwl:DockerRequirement [ cwl:dockerPull "cr.terradue.com/earthquake-monitoring/otsu:latest"^^xsd:string ] ] ;
            cwl:input _:N29d9e9503516429580cfca5bdc85888f ;
            cwl:output _:N0ccded199132450e8e50bfe25832a08a ;
            cwl:requirements [ cwl:EnvVarRequirement [ cwl:envDef [ cwl:PATH "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" ;
                                    cwl:PYTHONPATH "/app" ] ] ;
                    cwl:InlineJavascriptRequirement [ ] ;
                    cwl:ResourceRequirement [ cwl:coresMax 1 ;
                            cwl:ramMax 512 ] ] ;
            ns1:type <file:///github/workspace/CommandLineTool> ],
        [ rdfs:label "Water body detection based on NDWI and otsu threshold"^^xsd:string ;
            dct:identifier <file:///github/workspace/detect_water_body> ;
            ogcproc:input _:N563c03302abc4f9b8caaecf98021c4cf ;
            ogcproc:output _:Na9d39125805643e09ea4bd42effeaa2c ;
            rdfs:comment "Water body detection based on NDWI and otsu threshold"^^xsd:string ;
            cwl:input _:N563c03302abc4f9b8caaecf98021c4cf ;
            cwl:output _:Na9d39125805643e09ea4bd42effeaa2c ;
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
        [ dct:identifier <file:///github/workspace/stac> ;
            ogcproc:input _:Na28fe05711dd4903ac84c8749022b431 ;
            ogcproc:output _:N8bf9e2ad31b64aa1a2b8f0054ef8c5ca ;
            cwl:arguments () ;
            cwl:baseCommand "[\"python\",\"-m\",\"app\"]"^^rdf:JSON ;
            cwl:hints [ cwl:DockerRequirement [ cwl:dockerPull "cr.terradue.com/earthquake-monitoring/stac:latest"^^xsd:string ] ] ;
            cwl:input _:Na28fe05711dd4903ac84c8749022b431 ;
            cwl:output _:N8bf9e2ad31b64aa1a2b8f0054ef8c5ca ;
            cwl:requirements [ cwl:EnvVarRequirement [ cwl:envDef [ cwl:PATH "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" ;
                                    cwl:PYTHONPATH "/app" ] ] ;
                    cwl:InlineJavascriptRequirement [ ] ;
                    cwl:ResourceRequirement [ cwl:coresMax 1 ;
                            cwl:ramMax 512 ] ] ;
            ns1:type <file:///github/workspace/CommandLineTool> ] ;
    cwl:namespaces "{\"s\":\"https://schema.org/\"}"^^rdf:JSON ;
    cwl:schemas "http://schema.org/version/9.0/schemaorg-current-http.rdf" ;
    ns2:softwareVersion "1.4.1" .

_:N0c06dd9d798a424a8a396830c506aa41 cwl:binary_mask_item [ cwl:outputBinding [ cwl:glob "*.tif"^^xsd:string ] ;
            cwl:type <file:///github/workspace/File> ] .

_:N0c825bb4a6b74ad6b50d1dcd813accaa cwl:prefix "--epsg"^^xsd:string .

_:N0feb7fa893c54aabb7d8a33bafd7f0ec cwl:glob "."^^xsd:string .

_:N1352d756793c4f93a41b9cdcfc34d58d rdfs:comment "EPSG code"^^xsd:string ;
    cwl:default "\"EPSG:4326\""^^rdf:JSON ;
    cwl:type <file:///github/workspace/string> .

_:N229e9727dcf14a4d9084cf9b6bbdaee8 cwl:outputBinding _:N0feb7fa893c54aabb7d8a33bafd7f0ec ;
    cwl:type <file:///github/workspace/Directory> .

_:N253e78e4cfe243eb85afc43afae2b75b cwl:inputBinding [ cwl:prefix "--input-item"^^xsd:string ] ;
    cwl:type <file:///github/workspace/string> .

_:N29587e2601b54a4faa92b811a0ae57fd dct:identifier <file:///github/workspace/detected_water_body> ;
    cwl:outputSource <file:///github/workspace/node_otsu/binary_mask_item> ;
    cwl:type <file:///github/workspace/File> .

_:N2ef3beadf3c54a5e84ee1997547e14f4 rdfs:comment "area of interest as a bounding box"^^xsd:string ;
    cwl:type <file:///github/workspace/string> .

_:N314a62cedd4441158ed14bb8e5d95f79 cwl:prefix "--water-body"^^xsd:string .

_:N377581efd5fb41a789a8c5ef77071398 cwl:inputBinding _:N314a62cedd4441158ed14bb8e5d95f79 ;
    cwl:items <file:///github/workspace/File> ;
    cwl:type <file:///github/workspace/array> .

_:N392e05b7ddfa47c990f7a6d5991ce425 cwl:stac_catalog _:N229e9727dcf14a4d9084cf9b6bbdaee8 .

_:N42e7e64895a5440689b02235999d1060 cwl:inputBinding [ cwl:prefix "--input-item"^^xsd:string ] ;
    cwl:items <file:///github/workspace/string> ;
    cwl:type <file:///github/workspace/array> .

_:N476048a222e8404da4ecd1e373340e09 cwl:inputBinding [ cwl:prefix "--aoi"^^xsd:string ] ;
    cwl:type <file:///github/workspace/string> .

_:N5175c230705b4e2595512c243ae743a2 cwl:raster [ cwl:inputBinding [ cwl:position "1"^^xsd:int ] ;
            cwl:type <file:///github/workspace/File> ] .

_:N5fa14acb128c49fc9b08051086207524 rdfs:label "Sentinel-2 STAC items"^^xsd:string ;
    rdfs:comment "list of Sentinel-2 COG STAC items"^^xsd:string ;
    cwl:type <file:///github/workspace/string[]> .

_:N606e7c41550a4793b427efc10571b56b cwl:inputBinding _:N0c825bb4a6b74ad6b50d1dcd813accaa ;
    cwl:type <file:///github/workspace/string> .

_:N6387b3c5e1ee4e0c85de6ec8f47ab930 cwl:position "1"^^xsd:int .

_:N64c73293d4ef430a83c668d53cf42529 cwl:prefix "--band"^^xsd:string .

_:N666a2c25f8d644348014b590d7fc6772 rdfs:label "area of interest"^^xsd:string ;
    rdfs:comment "area of interest as a bounding box"^^xsd:string ;
    cwl:type <file:///github/workspace/string> .

_:N673bbd2fc3bb48b992b9fd7ff0605486 cwl:type _:N377581efd5fb41a789a8c5ef77071398 .

_:N704cf0bb36834a009ee131c596789196 cwl:item [ cwl:type _:N42e7e64895a5440689b02235999d1060 ] ;
    cwl:rasters _:N673bbd2fc3bb48b992b9fd7ff0605486 .

_:N793f89d9bf1640159d05c2f60591724f cwl:rasters [ cwl:inputBinding _:N6387b3c5e1ee4e0c85de6ec8f47ab930 ;
            cwl:type <file:///github/workspace/File[]> ] .

_:N80a14e5e120645a6b9198ae1e8270483 cwl:outputBinding [ cwl:glob "*.tif"^^xsd:string ] ;
    cwl:type <file:///github/workspace/File> .

_:N84ee5e6d52924ad79d0f488afff216bf cwl:inputBinding _:N64c73293d4ef430a83c668d53cf42529 ;
    cwl:type <file:///github/workspace/string> .

_:N97b7062025904b8385f14ebf6f4bfdca cwl:aoi _:N476048a222e8404da4ecd1e373340e09 ;
    cwl:band _:N84ee5e6d52924ad79d0f488afff216bf ;
    cwl:epsg _:N606e7c41550a4793b427efc10571b56b ;
    cwl:item _:N253e78e4cfe243eb85afc43afae2b75b .

_:N98905b983bdf4e029c7489ed2ea812e2 cwl:cropped [ cwl:outputBinding [ cwl:glob "*.tif"^^xsd:string ] ;
            cwl:type <file:///github/workspace/File> ] .

_:N9d5ef109547349f7ac6e09770faaff68 cwl:aoi _:N2ef3beadf3c54a5e84ee1997547e14f4 ;
    cwl:bands [ rdfs:comment "bands used for the NDWI"^^xsd:string ;
            cwl:type <file:///github/workspace/string[]> ] ;
    cwl:epsg _:N1352d756793c4f93a41b9cdcfc34d58d ;
    cwl:item [ rdfs:comment "STAC item"^^xsd:string ;
            cwl:type <file:///github/workspace/string> ] .

_:Nac98413eb72247bd8750a07ff2b753f1 cwl:ndwi _:N80a14e5e120645a6b9198ae1e8270483 .

_:Nbea88fe5307f41caa469645bd6c04c43 cwl:aoi _:N666a2c25f8d644348014b590d7fc6772 ;
    cwl:bands [ rdfs:label "bands used for the NDWI"^^xsd:string ;
            rdfs:comment "bands used for the NDWI"^^xsd:string ;
            cwl:default "[\"green\",\"nir\"]"^^rdf:JSON ;
            cwl:type <file:///github/workspace/string[]> ] ;
    cwl:epsg [ rdfs:label "EPSG code"^^xsd:string ;
            rdfs:comment "EPSG code"^^xsd:string ;
            cwl:default "\"EPSG:4326\""^^rdf:JSON ;
            cwl:type <file:///github/workspace/string> ] ;
    cwl:stac_items _:N5fa14acb128c49fc9b08051086207524 .

_:Ne56868a03f7f4a8f8a0bd5c118c86f3f dct:identifier <file:///github/workspace/stac_catalog> ;
    cwl:outputSource <file:///github/workspace/node_stac/stac_catalog> ;
    cwl:type <file:///github/workspace/Directory> .

_:N0ccded199132450e8e50bfe25832a08a a ogcproc:OutputDescription ;
    rdf:first _:N0c06dd9d798a424a8a396830c506aa41 ;
    rdf:rest () .

_:N29d9e9503516429580cfca5bdc85888f a ogcproc:InputDescription ;
    rdf:first _:N5175c230705b4e2595512c243ae743a2 ;
    rdf:rest () .

_:N2b771978d48343e9a74c6396abf3cfc4 a ogcproc:InputDescription ;
    rdf:first _:N97b7062025904b8385f14ebf6f4bfdca ;
    rdf:rest () .

_:N349569651688402db101fc0fef7b3bb7 a ogcproc:OutputDescription ;
    rdf:first _:N98905b983bdf4e029c7489ed2ea812e2 ;
    rdf:rest () .

_:N563c03302abc4f9b8caaecf98021c4cf a ogcproc:InputDescription ;
    rdf:first _:N9d5ef109547349f7ac6e09770faaff68 ;
    rdf:rest () .

_:N770b149b9d87482fbc36a9f392331ac2 a ogcproc:InputDescription ;
    rdf:first _:Nbea88fe5307f41caa469645bd6c04c43 ;
    rdf:rest () .

_:N8bf9e2ad31b64aa1a2b8f0054ef8c5ca a ogcproc:OutputDescription ;
    rdf:first _:N392e05b7ddfa47c990f7a6d5991ce425 ;
    rdf:rest () .

_:Na28fe05711dd4903ac84c8749022b431 a ogcproc:InputDescription ;
    rdf:first _:N704cf0bb36834a009ee131c596789196 ;
    rdf:rest () .

_:Na9d39125805643e09ea4bd42effeaa2c a ogcproc:OutputDescription ;
    rdf:first _:N29587e2601b54a4faa92b811a0ae57fd ;
    rdf:rest () .

_:Nb2782d9823d041d4a6d52b0a9e6ae60a a ogcproc:OutputDescription ;
    rdf:first _:Nac98413eb72247bd8750a07ff2b753f1 ;
    rdf:rest () .

_:Nbcce4f2d169a459fb5b5450fa81bda1b a ogcproc:InputDescription ;
    rdf:first _:N793f89d9bf1640159d05c2f60591724f ;
    rdf:rest () .

_:Nbd7eb32de03149b9b13c1908de74a20b a ogcproc:OutputDescription ;
    rdf:first _:Ne56868a03f7f4a8f8a0bd5c118c86f3f ;
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
  "@context": "https://ogcincubator.github.io/bblocks-eoap-cct/build/annotated/cct/cwl-to-ogcprocess/context.jsonld",
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
@prefix ns1: <rdf:> .
@prefix ns2: <s:> .
@prefix ogcproc: <http://www.opengis.net/def/ogcapi/processes/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

[] cwl:cwlVersion <file:///github/workspace/v1.0> ;
    cwl:graph [ rdfs:label "Mangrove Biomass Workflow"^^xsd:string ;
            dct:identifier <file:///github/workspace/mangrove-workflow> ;
            ogcproc:input _:N6c9029e443d142d4b2464dbd66dc29bd ;
            ogcproc:output _:Ned2f4f9e4d724c2499649965b7de1c41 ;
            rdfs:comment """Workflow for Mangrove Biomass Analysis
  
This workflow orchestrates the mangrove biomass estimation process using
Sentinel-2 imagery. It wraps the mangrove_workflow.cwl tool to provide
a reusable workflow for analyzing different study areas.
"""^^xsd:string ;
            cwl:input _:N6c9029e443d142d4b2464dbd66dc29bd ;
            cwl:output _:Ned2f4f9e4d724c2499649965b7de1c41 ;
            cwl:requirements [ cwl:InlineJavascriptRequirement [ ] ;
                    cwl:ScatterFeatureRequirement [ ] ;
                    cwl:SchemaDefRequirement [ cwl:types [ cwl:import <https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml> ],
                                [ cwl:import <https://raw.githubusercontent.com/eoap/schemas/main/stac.yaml> ] ] ;
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
            ns1:type <file:///github/workspace/Workflow> ],
        [ dct:identifier <file:///github/workspace/parse_aoi> ;
            ogcproc:input _:N7e719b086bd447859820ddf851d87074 ;
            ogcproc:output _:N15287461e7ea4757832fdce740e9956a ;
            cwl:arguments ( "--" ) ;
            cwl:baseCommand "\"echo\""^^rdf:JSON ;
            cwl:hints [ cwl:DockerRequirement [ cwl:dockerPull "alpine:3.22.2"^^xsd:string ] ] ;
            cwl:input _:N7e719b086bd447859820ddf851d87074 ;
            cwl:output _:N15287461e7ea4757832fdce740e9956a ;
            cwl:requirements [ cwl:InlineJavascriptRequirement [ ] ;
                    cwl:ResourceRequirement [ cwl:coresMax 1 ;
                            cwl:ramMax 512 ] ;
                    cwl:SchemaDefRequirement [ cwl:types [ cwl:import <https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml> ] ] ] ;
            ns1:type <file:///github/workspace/CommandLineTool> ],
        [ dct:identifier <file:///github/workspace/mangrove_cli> ;
            ogcproc:input _:Nff252f9daff94db08660c890b43bc480 ;
            ogcproc:output _:Naaef9b28061e4d27a97de437c2338b67 ;
            cwl:arguments ( "--" ) ;
            cwl:baseCommand "\"/app/cwl/bin/mangrove_workflow_for_cwl\""^^rdf:JSON ;
            cwl:hints [ cwl:DockerRequirement [ cwl:dockerPull "ghcr.io/geolabs/kindgrove/mangrove-cwl:v0.0.1-rc7"^^xsd:string ] ] ;
            cwl:input _:Nff252f9daff94db08660c890b43bc480 ;
            cwl:output _:Naaef9b28061e4d27a97de437c2338b67 ;
            cwl:requirements [ cwl:InlineJavascriptRequirement [ ] ;
                    cwl:ResourceRequirement [ cwl:coresMax 1 ;
                            cwl:ramMax 512 ] ] ;
            ns1:type <file:///github/workspace/CommandLineTool> ] ;
    cwl:namespaces "{\"s\":\"https://schema.org/\"}"^^rdf:JSON ;
    cwl:schemas "http://schema.org/version/9.0/schemaorg-current-http.rdf" ;
    ns2:author [ ns1:type ns2:Person ;
            ns2:name "Cameron Sajedi" ] ;
    ns2:codeRepository "https://github.com/starling-foundries/KindGrove" ;
    ns2:contributor [ ns1:type ns2:Person ;
            ns2:identifier "https://orcid.org/0000-0002-9617-8641" ;
            ns2:name "Gérald Fenoy" ] ;
    ns2:keywords "OSPD",
        "biomass",
        "mangrove" ;
    ns2:license "https://github.com/starling-foundries/KindGrove?tab=MIT-1-ov-file#readme" ;
    ns2:softwareVersion "0.0.1" .

_:N00540dab2a8640e6804f33e043b04184 cwl:inputBinding [ cwl:prefix "--days_back"^^xsd:string ] ;
    cwl:type <file:///github/workspace/int> .

_:N065f607dbde74cdead66fc7fbd8cbda5 cwl:outputEval "$(inputs.aoi.bbox[2])"^^xsd:string .

_:N069a84705c7f43b882ff0592beec8fb8 cwl:outputBinding [ cwl:outputEval "$(inputs.aoi.bbox[0])"^^xsd:string ] ;
    cwl:type <file:///github/workspace/float> .

_:N10ae29c7452a443ea486a832a4695230 cwl:east [ cwl:outputBinding _:N065f607dbde74cdead66fc7fbd8cbda5 ;
            cwl:type <file:///github/workspace/float> ] ;
    cwl:north [ cwl:outputBinding [ cwl:outputEval "$(inputs.aoi.bbox[3])"^^xsd:string ] ;
            cwl:type <file:///github/workspace/float> ] ;
    cwl:output_dir [ cwl:outputBinding [ cwl:outputEval "$(\"outputs\")"^^xsd:string ] ;
            cwl:type <file:///github/workspace/string> ] ;
    cwl:south [ cwl:outputBinding [ cwl:outputEval "$(inputs.aoi.bbox[1])"^^xsd:string ] ;
            cwl:type <file:///github/workspace/float> ] ;
    cwl:west _:N069a84705c7f43b882ff0592beec8fb8 .

_:N115fc48e3c814a12be8249e8def7ef45 cwl:stac [ cwl:outputSource <file:///github/workspace/step_1/result> ;
            cwl:type <file:///github/workspace/Directory> ] .

_:N1261ed64baf64e489c115422aa39a3d6 cwl:inputBinding [ cwl:prefix "--east"^^xsd:string ] ;
    cwl:type <file:///github/workspace/float> .

_:N17f86ce0971d4d0aaa5782b922e2834b cwl:cloud_cover_max [ cwl:inputBinding [ cwl:prefix "--cloud_cover_max"^^xsd:string ] ;
            cwl:type <file:///github/workspace/float> ] ;
    cwl:days_back _:N00540dab2a8640e6804f33e043b04184 ;
    cwl:east _:N1261ed64baf64e489c115422aa39a3d6 ;
    cwl:north [ cwl:inputBinding [ cwl:prefix "--north"^^xsd:string ] ;
            cwl:type <file:///github/workspace/float> ] ;
    cwl:output_dir [ cwl:inputBinding [ cwl:prefix "--output_dir"^^xsd:string ] ;
            cwl:type <file:///github/workspace/string> ] ;
    cwl:south [ cwl:inputBinding [ cwl:prefix "--south"^^xsd:string ] ;
            cwl:type <file:///github/workspace/float> ] ;
    cwl:west [ cwl:inputBinding [ cwl:prefix "--west"^^xsd:string ] ;
            cwl:type <file:///github/workspace/float> ] .

_:N32a6960e5bf34d5bbf0ac7516acaa9f3 rdfs:label "Area of Interest"^^xsd:string ;
    ogcproc:itemsType "number"^^xsd:string ;
    ogcproc:maxItems 6 ;
    ogcproc:minItems 4 ;
    ogcproc:schemaType "array"^^xsd:string ;
    rdfs:comment "Area of interest as a bounding box"^^xsd:string ;
    rdfs:seeAlso geo:BoundingBox ;
    cwl:type <https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml#BBox> .

_:N7bcb926c02b6446c86bf29093e670374 cwl:aoi _:N32a6960e5bf34d5bbf0ac7516acaa9f3 ;
    cwl:cloud_cover_max [ rdfs:label "Maximum Cloud Cover"^^xsd:string ;
            rdfs:comment "Maximum acceptable cloud cover percentage (0-100)"^^xsd:string ;
            cwl:type <file:///github/workspace/float> ] ;
    cwl:days_back [ rdfs:label "Days Back"^^xsd:string ;
            rdfs:comment "Number of days to search backwards from current date"^^xsd:string ;
            cwl:type <file:///github/workspace/int> ] .

_:Nca1d9738a1334766b6a05e55d36e349e cwl:aoi [ rdfs:label "Area of interest"^^xsd:string ;
            ogcproc:itemsType "number"^^xsd:string ;
            ogcproc:maxItems 6 ;
            ogcproc:minItems 4 ;
            ogcproc:schemaType "array"^^xsd:string ;
            rdfs:comment "Area of interest defined as a bounding box"^^xsd:string ;
            rdfs:seeAlso geo:BoundingBox ;
            cwl:type <https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml#BBox> ] .

_:Ncded18d6e4a34ffe96bdc4181ccd2e6d cwl:glob "outputs"^^xsd:string .

_:Ndb6ca1751ee8421badfb3b1dc002e484 cwl:outputBinding _:Ncded18d6e4a34ffe96bdc4181ccd2e6d ;
    cwl:type <file:///github/workspace/Directory> .

_:Nf17f6f5adf0944f890bd36c4424deb28 cwl:result _:Ndb6ca1751ee8421badfb3b1dc002e484 .

_:N15287461e7ea4757832fdce740e9956a a ogcproc:OutputDescription ;
    rdf:first _:N10ae29c7452a443ea486a832a4695230 ;
    rdf:rest () .

_:N6c9029e443d142d4b2464dbd66dc29bd a ogcproc:InputDescription ;
    rdf:first _:N7bcb926c02b6446c86bf29093e670374 ;
    rdf:rest () .

_:N7e719b086bd447859820ddf851d87074 a ogcproc:InputDescription ;
    rdf:first _:Nca1d9738a1334766b6a05e55d36e349e ;
    rdf:rest () .

_:Naaef9b28061e4d27a97de437c2338b67 a ogcproc:OutputDescription ;
    rdf:first _:Nf17f6f5adf0944f890bd36c4424deb28 ;
    rdf:rest () .

_:Ned2f4f9e4d724c2499649965b7de1c41 a ogcproc:OutputDescription ;
    rdf:first _:N115fc48e3c814a12be8249e8def7ef45 ;
    rdf:rest () .

_:Nff252f9daff94db08660c890b43bc480 a ogcproc:InputDescription ;
    rdf:first _:N17f86ce0971d4d0aaa5782b922e2834b ;
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
  "@context": "https://ogcincubator.github.io/bblocks-eoap-cct/build/annotated/cct/cwl-to-ogcprocess/context.jsonld",
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
    cwl:graph [ rdfs:label "Compute CVI"^^xsd:string ;
            dct:identifier <file:///github/workspace/compute-cvi-tool> ;
            ogcproc:input _:N16e72c2d09c7440fb42a38dc858e974d ;
            ogcproc:output _:N848b68d4d22842d99852a624121434f2 ;
            rdfs:comment "Computes final Coastal Vulnerability Index from all parameters"^^xsd:string ;
            cwl:baseCommand "[\"python3\",\"/app/steps/compute_cvi.py\"]"^^rdf:JSON ;
            cwl:hints [ cwl:DockerRequirement [ cwl:dockerPull "ghcr.io/hartis-org/cvi-workflow:latest"^^xsd:string ] ] ;
            cwl:input _:N16e72c2d09c7440fb42a38dc858e974d ;
            cwl:output _:N848b68d4d22842d99852a624121434f2 ;
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
            ogcproc:input _:N437355b85ca74f9e8014e21a8e9276b5 ;
            ogcproc:output _:Nfb8a0cb53602446b8cc0bea91efb9c78 ;
            rdfs:comment """This workflow computes the Coastal Vulnerability Index (CVI) for Mediterranean coastal areas.
It processes coastline data, generates transects, computes various coastal parameters
(landcover, slope, erosion, elevation), and calculates the final CVI values.
"""^^xsd:string ;
            cwl:input _:N437355b85ca74f9e8014e21a8e9276b5 ;
            cwl:output _:Nfb8a0cb53602446b8cc0bea91efb9c78 ;
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
        [ rdfs:label "Download input data"^^xsd:string ;
            dct:identifier <file:///github/workspace/eodag_search> ;
            ogcproc:input _:Nf64e6c514e254ebfbd206e227e2972c6 ;
            ogcproc:output _:N38a604baf4954e5892fc3d0b0fc539cc ;
            rdfs:comment "Downloads STAC item assets using EODAG"^^xsd:string ;
            cwl:arguments ( [ cwl:prefix "--output-dir"^^xsd:string ;
                        cwl:valueFrom "$(runtime.outdir)"^^xsd:string ] ) ;
            cwl:baseCommand "[\"eodag\",\"download\"]"^^rdf:JSON ;
            cwl:hints [ cwl:DockerRequirement [ cwl:dockerPull "ghcr.io/cs-si/eodag:v3.10.x"^^xsd:string ] ] ;
            cwl:input _:Nf64e6c514e254ebfbd206e227e2972c6 ;
            cwl:output _:N38a604baf4954e5892fc3d0b0fc539cc ;
            cwl:requirements [ cwl:InlineJavascriptRequirement [ ] ;
                    cwl:NetworkAccess [ cwl:networkAccess true ] ] ;
            ns1:type <file:///github/workspace/CommandLineTool> ;
            ns2:softwareVersion "latest" ],
        [ rdfs:label "Setup Environment"^^xsd:string ;
            dct:identifier <file:///github/workspace/setup-env-tool> ;
            ogcproc:input _:Ne214710d3dc64ac9b90f51ebe0e2bb32 ;
            ogcproc:output _:Nbf18f8369f884e2ba7bc509ac805e58c ;
            rdfs:comment "Validates configuration and initializes the working environment"^^xsd:string ;
            cwl:baseCommand "[\"python3\",\"/app/steps/setup_env.py\"]"^^rdf:JSON ;
            cwl:hints [ cwl:DockerRequirement [ cwl:dockerPull "ghcr.io/hartis-org/cvi-workflow:latest"^^xsd:string ] ] ;
            cwl:input _:Ne214710d3dc64ac9b90f51ebe0e2bb32 ;
            cwl:output _:Nbf18f8369f884e2ba7bc509ac805e58c ;
            cwl:requirements [ cwl:InitialWorkDirRequirement [ cwl:listing [ cwl:entry "$({class: 'Directory', listing: []})" ;
                                    cwl:entryname "$(inputs.output_dir)" ;
                                    cwl:writable true ],
                                "$(inputs.config_json)" ] ;
                    cwl:InlineJavascriptRequirement [ ] ] ;
            ns1:type <file:///github/workspace/CommandLineTool> ],
        [ rdfs:label "Compute Parameter"^^xsd:string ;
            dct:identifier <file:///github/workspace/compute-parameter-tool> ;
            ogcproc:input _:N42f493bcf0a648f986f54dda93a44104 ;
            ogcproc:output _:Nca73609e92c140c482617d8630b53d39 ;
            rdfs:comment "Computes a CVI parameter (landcover, slope, erosion, or elevation) for transects"^^xsd:string ;
            cwl:baseCommand "[\"python3\"]"^^rdf:JSON ;
            cwl:hints [ cwl:DockerRequirement [ cwl:dockerPull "ghcr.io/hartis-org/cvi-workflow:latest"^^xsd:string ] ] ;
            cwl:input _:N42f493bcf0a648f986f54dda93a44104 ;
            cwl:output _:Nca73609e92c140c482617d8630b53d39 ;
            cwl:requirements [ cwl:InitialWorkDirRequirement [ cwl:listing [ cwl:entry "$({class: 'Directory', listing: []})" ;
                                    cwl:entryname "$(inputs.output_dir)" ;
                                    cwl:writable true ],
                                [ cwl:entry "$(inputs.transects_geojson)" ],
                                [ cwl:entry "$(inputs.tokens_env)" ],
                                [ cwl:entry "$(inputs.config_json)" ] ] ;
                    cwl:InlineJavascriptRequirement [ ] ] ;
            ns1:type <file:///github/workspace/CommandLineTool> ],
        [ rdfs:label "Extract Coastline"^^xsd:string ;
            dct:identifier <file:///github/workspace/extract-coastline-tool> ;
            ogcproc:input _:N6ae86cd17d954567814ec40c43f73561 ;
            ogcproc:output _:N530568e62d454e40b68c717c129167cf ;
            rdfs:comment "Extracts coastline geometry from Mediterranean AOIs"^^xsd:string ;
            cwl:baseCommand "[\"python3\",\"/app/steps/extract_coastline.py\"]"^^rdf:JSON ;
            cwl:hints [ cwl:DockerRequirement [ cwl:dockerPull "ghcr.io/hartis-org/cvi-workflow:latest"^^xsd:string ] ] ;
            cwl:input _:N6ae86cd17d954567814ec40c43f73561 ;
            cwl:output _:N530568e62d454e40b68c717c129167cf ;
            cwl:requirements [ cwl:InitialWorkDirRequirement [ cwl:listing [ cwl:entry "$({class: 'Directory', listing: []})" ;
                                    cwl:entryname "$(inputs.output_dir)" ;
                                    cwl:writable true ],
                                "$(inputs.med_aois_csv)" ] ;
                    cwl:InlineJavascriptRequirement [ ] ] ;
            ns1:type <file:///github/workspace/CommandLineTool> ],
        [ rdfs:label "Generate Transects"^^xsd:string ;
            dct:identifier <file:///github/workspace/generate-transects-tool> ;
            ogcproc:input _:Nc4edbbdde4a84a6c8ad20b6f5004e84b ;
            ogcproc:output _:N4f25ccc724c74e0d923d83cf867a79fe ;
            rdfs:comment "Generates perpendicular transects along the coastline"^^xsd:string ;
            cwl:baseCommand "[\"python3\",\"/app/steps/generate_transects.py\"]"^^rdf:JSON ;
            cwl:hints [ cwl:DockerRequirement [ cwl:dockerPull "ghcr.io/hartis-org/cvi-workflow:latest"^^xsd:string ] ] ;
            cwl:input _:Nc4edbbdde4a84a6c8ad20b6f5004e84b ;
            cwl:output _:N4f25ccc724c74e0d923d83cf867a79fe ;
            cwl:requirements [ cwl:InitialWorkDirRequirement [ cwl:listing [ cwl:entry "$({class: 'Directory', listing: []})" ;
                                    cwl:entryname "$(inputs.output_dir)" ;
                                    cwl:writable true ],
                                "$(inputs.coastline_gpkg)" ] ;
                    cwl:InlineJavascriptRequirement [ ] ] ;
            ns1:type <file:///github/workspace/CommandLineTool> ] ;
    cwl:namespaces "{\"s\":\"https://schema.org/\"}"^^rdf:JSON ;
    cwl:schemas ( "http://schema.org/version/latest/schemaorg-current-http.rdf" ) .

_:N00226c33e6fe438e94fa1831d8704eef rdfs:label "Validated configuration"^^xsd:string ;
    rdfs:comment "Validated configuration JSON file"^^xsd:string ;
    cwl:outputSource <file:///github/workspace/setup_env/config_validated> ;
    cwl:type <file:///github/workspace/File> .

_:N0079bc302b0249128d2fd624bad21180 cwl:position "1"^^xsd:int .

_:N02e06ca2ff0d4fa495659c4a36f7766c cwl:config_json [ rdfs:comment "Configuration JSON file"^^xsd:string ;
            cwl:inputBinding [ cwl:position "5"^^xsd:int ] ;
            cwl:type <file:///github/workspace/File> ] ;
    cwl:output_dir [ rdfs:comment "Output directory path"^^xsd:string ;
            cwl:inputBinding [ cwl:position "6"^^xsd:int ] ;
            cwl:type <file:///github/workspace/string> ] ;
    cwl:transects_elevation [ rdfs:comment "Transects with elevation data"^^xsd:string ;
            cwl:inputBinding [ cwl:position "4"^^xsd:int ] ;
            cwl:type <file:///github/workspace/File> ] ;
    cwl:transects_erosion [ rdfs:comment "Transects with erosion data"^^xsd:string ;
            cwl:inputBinding [ cwl:position "3"^^xsd:int ] ;
            cwl:type <file:///github/workspace/File> ] ;
    cwl:transects_landcover [ rdfs:comment "Transects with landcover data"^^xsd:string ;
            cwl:inputBinding [ cwl:position "1"^^xsd:int ] ;
            cwl:type <file:///github/workspace/File> ] ;
    cwl:transects_slope [ rdfs:comment "Transects with slope data"^^xsd:string ;
            cwl:inputBinding [ cwl:position "2"^^xsd:int ] ;
            cwl:type <file:///github/workspace/File> ] .

_:N048587aab7864a2fa1b44f5e2716bd1f cwl:coastline_gpkg [ rdfs:comment "Extracted coastline GeoPackage"^^xsd:string ;
            cwl:outputBinding [ cwl:glob "$(inputs.output_dir)/coastline.gpkg"^^xsd:string ] ;
            cwl:type <file:///github/workspace/File> ] .

_:N05d79e1ede9a41d7823908504d04e1ff rdfs:comment "Output directory path"^^xsd:string ;
    cwl:inputBinding [ cwl:position "4"^^xsd:int ] ;
    cwl:type <file:///github/workspace/string> .

_:N0b453174f4754e82af22f72a734c4722 rdfs:label "Generated transects"^^xsd:string ;
    rdfs:comment "Perpendicular transects generated along the coastline"^^xsd:string ;
    cwl:outputSource <file:///github/workspace/generate_transects/transects_geojson> ;
    cwl:type <file:///github/workspace/File> .

_:N1c3e497b6daf4a1aa24c43f831632300 rdfs:comment "Coastline GeoPackage"^^xsd:string ;
    cwl:inputBinding [ cwl:position "1"^^xsd:int ] ;
    cwl:type <file:///github/workspace/File> .

_:N21fc6035db5240cab6eb2da4f26f163e rdfs:comment "Generated transects GeoJSON"^^xsd:string ;
    cwl:outputBinding [ cwl:glob "$(inputs.output_dir)/transects.geojson"^^xsd:string ] ;
    cwl:type <file:///github/workspace/File> .

_:N25017f05a90c44be9c67609549a94c10 rdfs:label "AOIs STAC item URL"^^xsd:string ;
    rdfs:comment "URL of the STAC item containing the Mediterranean AOIs CSV file"^^xsd:string ;
    cwl:default "\"https://eocatalog.p2.csgroup.space/collections/cvi-workflow-resources/items/mediterranean-coastal-aois\""^^rdf:JSON ;
    cwl:type <file:///github/workspace/string> .

_:N2e9e265e5fd94c579c6c685ceff8f4bb rdfs:label "Transects with landcover data"^^xsd:string ;
    rdfs:comment "Transects enriched with landcover information"^^xsd:string ;
    cwl:outputSource <file:///github/workspace/compute_landcover/result> ;
    cwl:type <file:///github/workspace/File> .

_:N308db1e00ae44c1c8a0f7db1eb72ab39 rdfs:label "Transects with elevation data"^^xsd:string ;
    rdfs:comment "Transects enriched with elevation information"^^xsd:string ;
    cwl:outputSource <file:///github/workspace/compute_elevation/result> ;
    cwl:type <file:///github/workspace/File> .

_:N33f1f9fda5f14b62bdbf2df1603e2611 rdfs:label "Tokens STAC item URL"^^xsd:string ;
    rdfs:comment "URL of the STAC item containing the authentication tokens file"^^xsd:string ;
    cwl:default "\"https://eocatalog.p2.csgroup.space/collections/cvi-workflow-resources/items/cvi-authentication-template\""^^rdf:JSON ;
    cwl:type <file:///github/workspace/string> .

_:N39d8ac2996c1452c8788e8dda0d39be7 rdfs:comment "Output directory path"^^xsd:string ;
    cwl:inputBinding [ cwl:position "2"^^xsd:int ] ;
    cwl:type <file:///github/workspace/string> .

_:N46c825eba9ba481986a1e0903c990e4a cwl:glob "$(inputs.output_dir)/*.geojson"^^xsd:string .

_:N4d3d8cf74de74f12a352f8cb8e1352ef cwl:config_json [ rdfs:comment "Configuration JSON file"^^xsd:string ;
            cwl:inputBinding [ cwl:position "3"^^xsd:int ] ;
            cwl:type <file:///github/workspace/File> ] ;
    cwl:output_dir _:N05d79e1ede9a41d7823908504d04e1ff ;
    cwl:script [ rdfs:comment "Python script path for parameter computation"^^xsd:string ;
            cwl:inputBinding [ cwl:position "0"^^xsd:int ] ;
            cwl:type <file:///github/workspace/string> ] ;
    cwl:tokens_env [ rdfs:comment "Authentication tokens file"^^xsd:string ;
            cwl:inputBinding [ cwl:position "2"^^xsd:int ] ;
            cwl:type <file:///github/workspace/File> ] ;
    cwl:transects_geojson [ rdfs:comment "Transects GeoJSON file"^^xsd:string ;
            cwl:inputBinding [ cwl:position "1"^^xsd:int ] ;
            cwl:type <file:///github/workspace/File> ] .

_:N5084f6b3679d4f23bdd88702334176aa rdfs:comment "Transects enriched with parameter data"^^xsd:string ;
    cwl:outputBinding _:N46c825eba9ba481986a1e0903c990e4a ;
    cwl:type <file:///github/workspace/File> .

_:N55cbcadb536a40f5b6393c1f31c3f65e cwl:result _:N5084f6b3679d4f23bdd88702334176aa .

_:N59d3ee9129124db692f9ca0fab4ec9d8 cwl:stac_item_url [ rdfs:comment "URL of the STAC item to download"^^xsd:string ;
            cwl:inputBinding [ cwl:prefix "--stac-item"^^xsd:string ] ;
            cwl:type <file:///github/workspace/string> ] .

_:N5eb238102c6e4fa58ef18c7d28acd2fd cwl:aois_stac_item_url _:N25017f05a90c44be9c67609549a94c10 ;
    cwl:config_stac_item_url [ rdfs:label "Configuration STAC item URL"^^xsd:string ;
            rdfs:comment "URL of the STAC item containing the configuration JSON file"^^xsd:string ;
            cwl:default "\"https://eocatalog.p2.csgroup.space/collections/cvi-workflow-resources/items/cvi-scoring-configuration\""^^rdf:JSON ;
            cwl:type <file:///github/workspace/string> ] ;
    cwl:tokens_stac_item_url _:N33f1f9fda5f14b62bdbf2df1603e2611 .

_:N66e65bc9f52c44938eaca3b49693f601 rdfs:label "Coastline GeoPackage"^^xsd:string ;
    rdfs:comment "Extracted coastline geometry in GeoPackage format"^^xsd:string ;
    cwl:outputSource <file:///github/workspace/extract_coastline/coastline_gpkg> ;
    cwl:type <file:///github/workspace/File> .

_:N715d866a6656436196b9f1bf176b5548 cwl:position "2"^^xsd:int .

_:N7c5f9aaa2eac4e88b5e76d4e057735f6 cwl:glob "$(inputs.output_dir)/config_validated.json"^^xsd:string .

_:N83740929c39344e28518648d64391943 cwl:glob "$(inputs.output_dir)/transects_with_cvi_equal.geojson"^^xsd:string .

_:N83f5cac4d31c4e1c9198925ac0534940 rdfs:comment "Mediterranean areas of interest CSV"^^xsd:string ;
    cwl:inputBinding _:N0079bc302b0249128d2fd624bad21180 ;
    cwl:type <file:///github/workspace/File> .

_:N8e3af61bf58a4d898055066c920d4d47 rdfs:comment "Configuration JSON file"^^xsd:string ;
    cwl:inputBinding [ cwl:position "1"^^xsd:int ] ;
    cwl:type <file:///github/workspace/File> .

_:N8f37d7df14f34cd0aefa3d0903099a43 cwl:coastline_gpkg _:N66e65bc9f52c44938eaca3b49693f601 ;
    cwl:cvi_geojson [ rdfs:label "CVI results"^^xsd:string ;
            rdfs:comment "Final Coastal Vulnerability Index values for all transects"^^xsd:string ;
            cwl:outputSource <file:///github/workspace/compute_cvi/out_geojson> ;
            cwl:type <file:///github/workspace/File> ] ;
    cwl:transects_elevation _:N308db1e00ae44c1c8a0f7db1eb72ab39 ;
    cwl:transects_erosion [ rdfs:label "Transects with erosion data"^^xsd:string ;
            rdfs:comment "Transects enriched with erosion information"^^xsd:string ;
            cwl:outputSource <file:///github/workspace/compute_erosion/result> ;
            cwl:type <file:///github/workspace/File> ] ;
    cwl:transects_geojson _:N0b453174f4754e82af22f72a734c4722 ;
    cwl:transects_landcover _:N2e9e265e5fd94c579c6c685ceff8f4bb ;
    cwl:transects_slope [ rdfs:label "Transects with slope data"^^xsd:string ;
            rdfs:comment "Transects enriched with slope information"^^xsd:string ;
            cwl:outputSource <file:///github/workspace/compute_slope/result> ;
            cwl:type <file:///github/workspace/File> ] ;
    cwl:validated_config _:N00226c33e6fe438e94fa1831d8704eef .

_:N931ff805afd14a519f33bb25807ce060 cwl:position "2"^^xsd:int .

_:N958ae0cdae664328b051fc1e9280b111 cwl:out_geojson [ rdfs:comment "Final CVI results GeoJSON"^^xsd:string ;
            cwl:outputBinding _:N83740929c39344e28518648d64391943 ;
            cwl:type <file:///github/workspace/File> ] .

_:N992987ff9be84f7fab3849a403879821 cwl:config_validated [ rdfs:comment "Validated configuration file"^^xsd:string ;
            cwl:outputBinding _:N7c5f9aaa2eac4e88b5e76d4e057735f6 ;
            cwl:type <file:///github/workspace/File> ] .

_:N99cd59f386674d36999e6c197ed4d8df cwl:med_aois_csv _:N83f5cac4d31c4e1c9198925ac0534940 ;
    cwl:output_dir [ rdfs:comment "Output directory path"^^xsd:string ;
            cwl:inputBinding _:N715d866a6656436196b9f1bf176b5548 ;
            cwl:type <file:///github/workspace/string> ] .

_:Na3a35f9df13d42d19a77c7bfdffa7c6a cwl:config_json _:N8e3af61bf58a4d898055066c920d4d47 ;
    cwl:output_dir _:N39d8ac2996c1452c8788e8dda0d39be7 .

_:Na53f353bb5de4d929bb438a25daefe54 cwl:coastline_gpkg _:N1c3e497b6daf4a1aa24c43f831632300 ;
    cwl:output_dir [ rdfs:comment "Output directory path"^^xsd:string ;
            cwl:inputBinding _:N931ff805afd14a519f33bb25807ce060 ;
            cwl:type <file:///github/workspace/string> ] .

_:Nc8b088f738e74348b2c92872611265cb cwl:transects_geojson _:N21fc6035db5240cab6eb2da4f26f163e .

_:Nda901be8baed48fcb0b0fa59d5a0efab rdfs:comment "Directory containing downloaded STAC item assets"^^xsd:string ;
    cwl:outputBinding [ cwl:glob "$(runtime.outdir)/*"^^xsd:string ] ;
    cwl:type <file:///github/workspace/Directory> .

_:Nebb9bff16418465ca62847371eaec755 cwl:data_output_dir _:Nda901be8baed48fcb0b0fa59d5a0efab .

_:N16e72c2d09c7440fb42a38dc858e974d a ogcproc:InputDescription ;
    rdf:first _:N02e06ca2ff0d4fa495659c4a36f7766c ;
    rdf:rest () .

_:N38a604baf4954e5892fc3d0b0fc539cc a ogcproc:OutputDescription ;
    rdf:first _:Nebb9bff16418465ca62847371eaec755 ;
    rdf:rest () .

_:N42f493bcf0a648f986f54dda93a44104 a ogcproc:InputDescription ;
    rdf:first _:N4d3d8cf74de74f12a352f8cb8e1352ef ;
    rdf:rest () .

_:N437355b85ca74f9e8014e21a8e9276b5 a ogcproc:InputDescription ;
    rdf:first _:N5eb238102c6e4fa58ef18c7d28acd2fd ;
    rdf:rest () .

_:N4f25ccc724c74e0d923d83cf867a79fe a ogcproc:OutputDescription ;
    rdf:first _:Nc8b088f738e74348b2c92872611265cb ;
    rdf:rest () .

_:N530568e62d454e40b68c717c129167cf a ogcproc:OutputDescription ;
    rdf:first _:N048587aab7864a2fa1b44f5e2716bd1f ;
    rdf:rest () .

_:N6ae86cd17d954567814ec40c43f73561 a ogcproc:InputDescription ;
    rdf:first _:N99cd59f386674d36999e6c197ed4d8df ;
    rdf:rest () .

_:N848b68d4d22842d99852a624121434f2 a ogcproc:OutputDescription ;
    rdf:first _:N958ae0cdae664328b051fc1e9280b111 ;
    rdf:rest () .

_:Nbf18f8369f884e2ba7bc509ac805e58c a ogcproc:OutputDescription ;
    rdf:first _:N992987ff9be84f7fab3849a403879821 ;
    rdf:rest () .

_:Nc4edbbdde4a84a6c8ad20b6f5004e84b a ogcproc:InputDescription ;
    rdf:first _:Na53f353bb5de4d929bb438a25daefe54 ;
    rdf:rest () .

_:Nca73609e92c140c482617d8630b53d39 a ogcproc:OutputDescription ;
    rdf:first _:N55cbcadb536a40f5b6393c1f31c3f65e ;
    rdf:rest () .

_:Ne214710d3dc64ac9b90f51ebe0e2bb32 a ogcproc:InputDescription ;
    rdf:first _:Na3a35f9df13d42d19a77c7bfdffa7c6a ;
    rdf:rest () .

_:Nf64e6c514e254ebfbd206e227e2972c6 a ogcproc:InputDescription ;
    rdf:first _:N59d3ee9129124db692f9ca0fab4ec9d8 ;
    rdf:rest () .

_:Nfb8a0cb53602446b8cc0bea91efb9c78 a ogcproc:OutputDescription ;
    rdf:first _:N8f37d7df14f34cd0aefa3d0903099a43 ;
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

* YAML version: [schema.yaml](https://ogcincubator.github.io/bblocks-eoap-cct/build/annotated/cct/cwl-to-ogcprocess/schema.json)
* JSON version: [schema.json](https://ogcincubator.github.io/bblocks-eoap-cct/build/annotated/cct/cwl-to-ogcprocess/schema.yaml)


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
[context.jsonld](https://ogcincubator.github.io/bblocks-eoap-cct/build/annotated/cct/cwl-to-ogcprocess/context.jsonld)

## Sources

* [Common Workflow Language (CWL) Specification](https://www.commonwl.org/v1.2/)
* [OGC API - Processes Part 1: Core](https://docs.ogc.org/is/18-062r2/18-062r2.html)
* [OGC Best Practice for Earth Observation Application Package](https://docs.ogc.org/bp/20-089r1.html)
* [Earth Observation Application Package (EOAP) CWL Custom Types](https://github.com/eoap/schemas)

# For developers

The source code for this Building Block can be found in the following repository:

* URL: [https://github.com/ogcincubator/bblocks-eoap-cct](https://github.com/ogcincubator/bblocks-eoap-cct)
* Path: `_sources/cwl-to-ogcprocess`

