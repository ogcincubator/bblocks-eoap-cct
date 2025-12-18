This building block defines CWL custom types for GeoJSON data structures, enabling Common Workflow Language workflows to handle geospatial vector data. These types provide a bridge between CWL workflow definitions and OGC API - Processes input/output schemas as defined in Table 13 of the OGC API - Processes Part 1 specification.

## Relationship to OGC API - Processes

These custom types map directly to the schemas defined in Table 13 of OGC API - Processes Part 1 (OGC 18-062r3). When a CWL workflow is deployed as an OGC API - Processes service, these types are automatically converted to the appropriate JSON Schema definitions in the process description.

A CWL input defined as:

```yaml
inputs:
  area_of_interest:
    type: eoap:geojson#Feature
    doc: "Area of interest for processing"
```

Maps to an OGC API - Processes input schema:

```json
{
  "id": "area_of_interest",
  "title": "Area of interest for processing",
  "schema": {
    "allOf":{
      {
        "format": "geojson-feature"
      },
      {
        "$ref": "https://geojson.org/schema/Feature.json"
      }
    }
  }
}
```

## Usage in CWL Workflows

To use these custom types in a CWL workflow:

```yaml
cwlVersion: v1.0
class: Workflow

requirements:
  SchemaDefRequirement:
    types:
      - $import: https://eoap.github.io/schemas/cwl/geojson.yaml

inputs:
  input_feature:
    type: eoap:geojson#Feature
    inputBinding:
      position: 1

outputs:
  output_collection:
    type: eoap:geojson#FeatureCollection
    outputBinding:
      glob: result.json
```
