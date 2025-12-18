
# eaop-cct:STAC (Schema)

`eoap.cct.stac` *v1.0*

CWL custom types for STAC Catalogs, Items, and Collections

[*Status*](http://www.opengis.net/def/status): Under development

## Description

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

## Examples

### STAC Item
#### yaml
```yaml
type: Feature
stac_version: "1.0.0"
id: S2A_MSIL2A_20231201T103421
geometry:
  type: Polygon
  coordinates:
    - - [-5.0, 51.0]
      - [-4.0, 51.0]
      - [-4.0, 52.0]
      - [-5.0, 52.0]
      - [-5.0, 51.0]
bbox: [-5.0, 51.0, -4.0, 52.0]
properties:
  datetime: "2023-12-01T10:34:21Z"
  platform: sentinel-2a
links:
  - rel: self
    href: https://example.com/items/S2A_MSIL2A_20231201T103421.json
    type: application/json
assets:
  thumbnail:
    href: https://example.com/thumbnails/S2A_MSIL2A_20231201T103421.jpg
    type: image/jpeg
    roles: [thumbnail]

```


### STAC Catalog
#### yaml
```yaml
type: Catalog
stac_version: "1.0.0"
id: sentinel-2-catalog
title: Sentinel-2 Data Catalog
description: Catalog of Sentinel-2 satellite imagery
links:
  - rel: self
    href: https://example.com/catalogs/sentinel-2/catalog.json
    type: application/json
  - rel: root
    href: https://example.com/catalog.json
    type: application/json

```

## Schema

```yaml
$ref: https://raw.githubusercontent.com/eoap/schemas/refs/heads/main/stac.yaml
x-jsonld-extra-terms:
  Catalog: https://stac-extensions.github.io/Catalog
  Collection: https://stac-extensions.github.io/Collection
  Item: https://stac-extensions.github.io/Item
  Asset: https://stac-extensions.github.io/Asset
  Link: https://stac-extensions.github.io/Link
  stac_version: https://stac-extensions.github.io/version
  stac_extensions: https://stac-extensions.github.io/extensions
  assets: https://stac-extensions.github.io/assets
  links:
    x-jsonld-id: https://stac-extensions.github.io/links
    x-jsonld-container: '@list'
  providers:
    x-jsonld-id: https://schema.org/provider
    x-jsonld-container: '@list'
x-jsonld-vocab: https://www.opengis.net/def/metamodel/ogc-na/
x-jsonld-prefixes:
  stac: https://stac-extensions.github.io/
  schema: https://schema.org/
  dct: http://purl.org/dc/terms/
  cwl: https://w3id.org/cwl/cwl#
  eoap: https://eoap.github.io/schemas/cwl/

```

Links to the schema:

* YAML version: [schema.yaml](https://geolabs.github.io/bblocks-eoap-cct/build/annotated/cct/stac/schema.json)
* JSON version: [schema.json](https://geolabs.github.io/bblocks-eoap-cct/build/annotated/cct/stac/schema.yaml)


# JSON-LD Context

```jsonld
{
  "@context": {
    "@vocab": "https://www.opengis.net/def/metamodel/ogc-na/",
    "Catalog": "stac:Catalog",
    "Collection": "stac:Collection",
    "Item": "stac:Item",
    "Asset": "stac:Asset",
    "Link": "stac:Link",
    "stac_version": "stac:version",
    "stac_extensions": "stac:extensions",
    "assets": "stac:assets",
    "links": {
      "@id": "stac:links",
      "@container": "@list"
    },
    "providers": {
      "@id": "schema:provider",
      "@container": "@list"
    },
    "stac": "https://stac-extensions.github.io/",
    "schema": "https://schema.org/",
    "dct": "http://purl.org/dc/terms/",
    "cwl": "https://w3id.org/cwl/cwl#",
    "eoap": "https://eoap.github.io/schemas/cwl/",
    "@version": 1.1
  }
}
```

You can find the full JSON-LD context here:
[context.jsonld](https://geolabs.github.io/bblocks-eoap-cct/build/annotated/cct/stac/context.jsonld)

## Sources

* [STAC Specification v1.0.0](https://github.com/radiantearth/stac-spec)
* [OGC Best Practice for Earth Observation Application Package](https://docs.ogc.org/bp/20-089r1.html)
* [EOAP CWL Custom Types - STAC](https://raw.githubusercontent.com/eoap/schemas/refs/heads/main/stac.yaml)

# For developers

The source code for this Building Block can be found in the following repository:

* URL: [https://github.com/GeoLabs/bblocks-eoap-cct](https://github.com/GeoLabs/bblocks-eoap-cct)
* Path: `_sources/stac`

