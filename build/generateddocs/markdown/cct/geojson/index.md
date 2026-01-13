
# eaop-cct:GeoJSON (Schema)

`eoap.cct.geojson` *v1.0*

CWL custom types for GeoJSON geometries, features, and feature collections

[*Status*](http://www.opengis.net/def/status): Under development

## Description

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

## Examples

### GeoJSON Point
#### yaml
```yaml
type: Point
coordinates: [125.6, 10.1]

```


### GeoJSON Feature
#### yaml
```yaml
type: Feature
id: point-1
geometry:
  type: Point
  coordinates: [125.6, 10.1]
properties:
  name: Sample Point
  description: A point feature example

```


### GeoJSON Polygon
#### yaml
```yaml
type: Polygon
coordinates:
  - - [100.0, 0.0]
    - [101.0, 0.0]
    - [101.0, 1.0]
    - [100.0, 1.0]
    - [100.0, 0.0]
bbox: [100.0, 0.0, 101.0, 1.0]

```

## Schema

```yaml
$ref: https://raw.githubusercontent.com/eoap/schemas/refs/heads/main/geojson.yaml
x-jsonld-extra-terms:
  Point: https://purl.org/geojson/vocab#Point
  LineString: https://purl.org/geojson/vocab#LineString
  Polygon: https://purl.org/geojson/vocab#Polygon
  MultiPoint: https://purl.org/geojson/vocab#MultiPoint
  MultiLineString: https://purl.org/geojson/vocab#MultiLineString
  MultiPolygon: https://purl.org/geojson/vocab#MultiPolygon
  GeometryCollection: https://purl.org/geojson/vocab#GeometryCollection
  Feature: https://purl.org/geojson/vocab#Feature
  FeatureCollection: https://purl.org/geojson/vocab#FeatureCollection
  geometry: https://purl.org/geojson/vocab#geometry
  coordinates: https://purl.org/geojson/vocab#coordinates
  properties: https://purl.org/geojson/vocab#properties
  features: https://purl.org/geojson/vocab#features
  bbox: https://purl.org/geojson/vocab#bbox
x-jsonld-vocab: https://www.opengis.net/def/metamodel/ogc-na/
x-jsonld-prefixes:
  geojson: https://purl.org/geojson/vocab#
  schema: https://schema.org/
  dct: http://purl.org/dc/terms/
  cwl: https://w3id.org/cwl/cwl#
  eoap: https://eoap.github.io/schemas/cwl/

```

Links to the schema:

* YAML version: [schema.yaml](https://ogcincubator.github.io/bblocks-eoap-cct/build/annotated/cct/geojson/schema.json)
* JSON version: [schema.json](https://ogcincubator.github.io/bblocks-eoap-cct/build/annotated/cct/geojson/schema.yaml)


# JSON-LD Context

```jsonld
{
  "@context": {
    "@vocab": "https://www.opengis.net/def/metamodel/ogc-na/",
    "Point": "geojson:Point",
    "LineString": "geojson:LineString",
    "Polygon": "geojson:Polygon",
    "MultiPoint": "geojson:MultiPoint",
    "MultiLineString": "geojson:MultiLineString",
    "MultiPolygon": "geojson:MultiPolygon",
    "GeometryCollection": "geojson:GeometryCollection",
    "Feature": "geojson:Feature",
    "FeatureCollection": "geojson:FeatureCollection",
    "geometry": "geojson:geometry",
    "coordinates": "geojson:coordinates",
    "properties": "geojson:properties",
    "features": "geojson:features",
    "bbox": "geojson:bbox",
    "geojson": "https://purl.org/geojson/vocab#",
    "schema": "https://schema.org/",
    "dct": "http://purl.org/dc/terms/",
    "cwl": "https://w3id.org/cwl/cwl#",
    "eoap": "https://eoap.github.io/schemas/cwl/",
    "@version": 1.1
  }
}
```

You can find the full JSON-LD context here:
[context.jsonld](https://ogcincubator.github.io/bblocks-eoap-cct/build/annotated/cct/geojson/context.jsonld)

## Sources

* [GeoJSON Format Specification (RFC 7946)](https://datatracker.ietf.org/doc/html/rfc7946)
* [OGC API - Processes Part 1 - Table 13](https://docs.ogc.org/DRAFTS/18-062r3.html#_921c9ed7-3bf5-8c1d-a5be-f1ca4d0d5351)
* [EOAP CWL Custom Types - GeoJSON](https://raw.githubusercontent.com/eoap/schemas/refs/heads/main/geojson.yaml)

# For developers

The source code for this Building Block can be found in the following repository:

* URL: [https://github.com/ogcincubator/bblocks-eoap-cct](https://github.com/ogcincubator/bblocks-eoap-cct)
* Path: `_sources/geojson`

