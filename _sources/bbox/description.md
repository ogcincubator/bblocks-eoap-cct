This building block defines a CWL custom type for OGC bounding boxes. The BoundingBox type represents spatial extents using coordinate arrays and optional coordinate reference system (CRS) specifications, conforming to OGC API standards.

## Relationship to OGC API - Processes

When used in process descriptions, bounding boxes map to the bbox schema (inline):

```json
{
  "id": "area_of_interest",
  "title": "Area of Interest",
  "schema": {
    "type": "object",
    "required": ["bbox"],
    "properties": {
      "bbox": {
        "type": "array",
        "items": {"type": "number"},
        "minItems": 4,
        "maxItems": 6
      },
      "crs": {
        "type": "string",
        "enum": ["CRS84", "CRS84h"],
        "default": "CRS84"
      }
    }
  }
}
```

Another example using Table 13 from OGC API - Processes - Part 1: Core:

```json
{
  "id": "area_of_interest",
  "title": "Area of Interest",
  "description": "Spatial extent for processing operations",
  "schema": {
    "allOf": [
      {
        "format": "ogc-bbox"
      },
      {
        "$ref": "https://schemas.opengis.net/ogcapi/processes/part1/1.0/openapi/schemas/bbox.yaml"
      }
    ]
  },
  "example": {
    "bbox": [-5.0, 51.0, -4.0, 52.0],
    "crs": "CRS84"
  }
}
```

This approach leverages the standard OGC API - Processes bbox schema while adding the `ogc-bbox` format hint for enhanced validation and tooling support.


## Usage in CWL Workflows

To use the OGC BoundingBox custom type in a CWL workflow:

```yaml
cwlVersion: v1.0
class: CommandLineTool

requirements:
  SchemaDefRequirement:
    types:
      - $import: https://eoap.github.io/schemas/cwl/bbox.yaml

inputs:
  area_of_interest:
    type: eoap:bbox#BBox
    doc: "Spatial extent for processing"
    inputBinding:
      position: 1
      valueFrom: $(self.bbox.join(','))

  elevation_range:
    type: eoap:bbox#BBox3D
    doc: "3D spatial extent with elevation"
    inputBinding:
      position: 2
```
