This building block defines CWL custom types for STAC (SpatioTemporal Asset Catalog) metadata structures. These types enable Common Workflow Language workflows to handle Earth Observation product manifests as inputs and outputs, following the patterns described in the OGC Best Practice for Earth Observation Application Package (OGC 20-089r1).

## Relationship to OGC Best Practice 20-089r1

These types implement the STAC manifest approach described in section 6.2.3 "Staging Input and Output EO Products" of the OGC Best Practice for Earth Observation Application Package.

### Input Staging Pattern

Workflows can reference input data using STAC Catalogs or Items:

```yaml
inputs:
  input_scenes:
    type: eoap:stac#Catalog
    doc: "STAC catalog containing input scenes"
```

The workflow execution environment resolves the STAC references and stages the actual data files for processing.

### Output Staging Pattern

Workflows can produce STAC metadata describing output products:

```yaml
outputs:
  output_catalog:
    type: eoap:stac#Catalog
    outputBinding:
      glob: results/catalog.json
```

## Relationship to OGC API - Processes

When deployed as an OGC API - Processes service, these STAC custom types map to complex object schemas in the process description. The process description references STAC schemas to indicate that inputs/outputs conform to STAC specifications.

### Example Process Description

```json
{
  "id": "ndvi-processor",
  "inputs": {
    "scenes": {
      "title": "Input Scenes",
      "schema": {
        "$ref": "https://schemas.stacspec.org/v1.0.0/item-spec/json-schema/item.json"
      }
    }
  },
  "outputs": {
    "result_catalog": {
      "title": "Result Catalog",
      "schema": {
        "$ref": "https://schemas.stacspec.org/v1.0.0/catalog-spec/json-schema/catalog.json"
      }
    }
  }
}
```

## Usage in CWL Workflows

To use STAC custom types in a CWL workflow:

```yaml
cwlVersion: v1.0
class: CommandLineTool

requirements:
  SchemaDefRequirement:
    types:
      - $import: https://eoap.github.io/schemas/cwl/stac.yaml

inputs:
  input_item:
    type: eoap:stac#Item
    doc: "STAC Item describing the input scene"
    inputBinding:
      position: 1
      valueFrom: $(self.assets.data.href)

outputs:
  output_catalog:
    type: eoap:stac#Catalog
    doc: "STAC Catalog of processed results"
    outputBinding:
      glob: results/catalog.json
```
