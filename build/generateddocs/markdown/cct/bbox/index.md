
# eaop-cct:OGC-BoundingBox (Schema)

`eoap.cct.bbox` *v1.0*

CWL custom type for OGC bounding box with coordinate reference system

[*Status*](http://www.opengis.net/def/status): Under development

## Description

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

## Examples

### 2D BBox (CRS84)
#### yaml
```yaml
bbox: [-5.0, 51.0, -4.0, 52.0]
crs: CRS84

```


### 3D BBox (CRS84h)
#### yaml
```yaml
bbox: [-5.0, 51.0, 100.0, -4.0, 52.0, 500.0]
crs: CRS84h

```

## Schema

```yaml
$ref: https://raw.githubusercontent.com/eoap/schemas/refs/heads/main/ogc.yaml
x-jsonld-extra-terms:
  BBox: http://www.opengis.net/ont/geosparql#BoundingBox
  bbox:
    x-jsonld-id: http://www.opengis.net/ont/geosparql#asWKT
    x-jsonld-type: '@json'
  crs:
    x-jsonld-id: http://www.opengis.net/ont/geosparql#crs
    x-jsonld-type: '@id'
  CRS84: http://www.opengis.net/def/crs/OGC/1.3/CRS84
  CRS84h: http://www.opengis.net/def/crs/OGC/0/CRS84h
x-jsonld-vocab: https://www.opengis.net/def/metamodel/ogc-na/
x-jsonld-prefixes:
  geo: http://www.opengis.net/ont/geosparql#
  ogc: http://www.opengis.net/def/
  dct: http://purl.org/dc/terms/
  cwl: https://w3id.org/cwl/cwl#
  eoap: https://eoap.github.io/schemas/cwl/

```

Links to the schema:

* YAML version: [schema.yaml](https://geolabs.github.io/bblocks-eoap-cct/build/annotated/cct/bbox/schema.json)
* JSON version: [schema.json](https://geolabs.github.io/bblocks-eoap-cct/build/annotated/cct/bbox/schema.yaml)


# JSON-LD Context

```jsonld
{
  "@context": {
    "@vocab": "https://www.opengis.net/def/metamodel/ogc-na/",
    "BBox": "geo:BoundingBox",
    "bbox": {
      "@id": "geo:asWKT",
      "@type": "@json"
    },
    "crs": {
      "@id": "geo:crs",
      "@type": "@id"
    },
    "CRS84": "ogc:crs/OGC/1.3/CRS84",
    "CRS84h": "ogc:crs/OGC/0/CRS84h",
    "geo": "http://www.opengis.net/ont/geosparql#",
    "ogc": "http://www.opengis.net/def/",
    "dct": "http://purl.org/dc/terms/",
    "cwl": "https://w3id.org/cwl/cwl#",
    "eoap": "https://eoap.github.io/schemas/cwl/",
    "@version": 1.1
  }
}
```

You can find the full JSON-LD context here:
[context.jsonld](https://geolabs.github.io/bblocks-eoap-cct/build/annotated/cct/bbox/context.jsonld)

## Sources

* [OGC API - Features Part 1 - Bounding Box](https://docs.ogc.org/is/17-069r4/17-069r4.html#_parameter_bbox)
* [OGC API - Processes Part 1 - Table 13](https://docs.ogc.org/DRAFTS/18-062r3.html#_921c9ed7-3bf5-8c1d-a5be-f1ca4d0d5351)
* [CRS84 Definition](http://www.opengis.net/def/crs/OGC/1.3/CRS84)
* [EOAP CWL Custom Types - OGC BBox](https://raw.githubusercontent.com/eoap/schemas/refs/heads/main/ogc.yaml)

# For developers

The source code for this Building Block can be found in the following repository:

* URL: [https://github.com/GeoLabs/bblocks-eoap-cct](https://github.com/GeoLabs/bblocks-eoap-cct)
* Path: `_sources/bbox`

