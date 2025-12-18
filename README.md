# EOAP CWL Custom Types Building Blocks

## Overview

This repository contains OGC Building Blocks for CWL (Common Workflow Language) Custom Types used in Earth Observation Application Packages (EOAP). These custom types enable seamless integration between CWL workflow definitions and OGC API - Processes service descriptions.

## Purpose

The primary goal of these building blocks is to provide a standardized mapping between:

1. **CWL workflow specifications** - How workflows define their inputs and outputs
2. **OGC API - Processes descriptions** - How process services advertise their parameters
3. **Data formats** - Standard geospatial and temporal data representations

## Mapping to OGC API - Processes Table 13

[OGC API - Processes Part 1](https://docs.ogc.org/DRAFTS/18-062r3.html) defines in Table 13 the schemas for describing process inputs and outputs. The CWL Custom Types in this repository provide CWL-native representations that map directly to these schemas.

### OGC API - Processes - Part 1: Core Schema Categories

OGC API - Processes - Part 1: Core defines several categories of input/output schemas:

1. **Literal data types**: Strings, numbers, booleans with format constraints
2. **Bounding boxes**: Spatial extents with CRS
3. **Complex objects**: GeoJSON, STAC, and other structured data
4. **References**: URLs to external resources

### Mapping Examples

#### GeoJSON Feature

**CWL Definition:**
```yaml
inputs:
  area_of_interest:
    type: eoap:geojson#Feature
    doc: "Area of interest for processing"
```

**OGC Process Description (Table 13):**
```json
{
  "area_of_interest": {
    "title": "Area of interest for processing",
    "schema": {
      "allOf": [
        {
          "format": "geojson-feature"
        }
        {
        "$ref": "https://geojson.org/schema/Feature.json"
        }
      ]
    }
  }
}
```

#### STAC Item

**CWL Definition:**
```yaml
inputs:
  input_scene:
    type: eoap:stac#Item
    doc: "Input satellite scene"
```

**OGC Process Description (Table 13):**
```json
{
  "input_scene":{
    "title": "Input satellite scene",
    "schema": {
      "allOf": [
        {
          "format": "stac-item"
        }
        {
        "$ref": "https://schemas.stacspec.org/v1.0.0/item-spec/json-schema/item.json"
        }
      ]
    }
  }
}
```

#### BoundingBox

**CWL Definition:**
```yaml
inputs:
  spatial_extent:
    type: eoap:bbox#BBox
    doc: "Spatial extent for processing"
```

**OGC Process Description (Table 13):**
```json
{
  "spatial_extent": {
    "title": "Spatial extent for processing",
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
}
```

#### DateTime String Format

**CWL Definition:**
```yaml
inputs:
  observation_time:
    type: eoap:string-format#DateTime
    doc: "Time of observation"
```

**OGC Process Description (Table 13):**
```json
{
  "observation_time": {
    "title": "Time of observation",
    "schema": {
      "type": "string",
      "format": "date-time"
    }
  }
}
```

## Building Block Structure

Each building block includes:

- **schema.yaml**: JSON Schema definition (reference to the original YAML format schemas)
- **bblock.json**: Metadata describing the building block
- **context.jsonld**: JSON-LD context for semantic mapping
- **examples.yaml**: Example instances demonstrating usage
- **description.md**: Brief documentation

## Available Building Blocks

### 1. GeoJSON Custom Types (`eoap.cct.geojson`)

Provides CWL types for:
- Point, LineString, Polygon geometries
- MultiPoint, MultiLineString, MultiPolygon
- Feature and FeatureCollection
- GeometryCollection
- Link (for OGC API Features)

**Use case**: Define spatial inputs/outputs using standard GeoJSON format

**Reference**: [RFC 7946 - The GeoJSON Format](https://datatracker.ietf.org/doc/html/rfc7946)

### 2. STAC Custom Types (`eoap.cct.stac`)

Provides CWL types for:
- STAC Catalog - organizing collections
- STAC Item - individual EO scenes/products
- STAC Collection - aggregate metadata
- Asset, Link, Provider types

**Use case**: Reference and describe Earth Observation data using STAC manifests

**Reference**: [STAC Specification v1.0.0](https://github.com/radiantearth/stac-spec)

### 3. OGC BoundingBox (`eoap.cct.bbox`)

Provides CWL types for:
- 2D bounding boxes (4 coordinates)
- 3D bounding boxes (6 coordinates)
- CRS specification (CRS84, CRS84h)

**Use case**: Define spatial extents for filtering or describing coverage

**Reference**: [OGC API - Features Part 1](https://docs.ogc.org/is/17-069r4/17-069r4.html)

### 4. String Format Types (`eoap.cct.string-format`)

Provides CWL types for validated strings:
- Date, DateTime, Time, Duration
- URI, URIReference, URITemplate
- Email, Hostname, IPv4, IPv6
- UUID, JsonPointer

**Use case**: Ensure string inputs/outputs conform to expected formats

**Reference**: [JSON Schema String Formats](https://json-schema.org/understanding-json-schema/reference/string.html#format)

## Integration Workflow

### 1. CWL Workflow Definition

Define a workflow using custom types:

```yaml
cwlVersion: v1.0
class: CommandLineTool

requirements:
  SchemaDefRequirement:
    types:
      - $import: https://eoap.github.io/schemas/cwl/geojson.yaml
      - $import: https://eoap.github.io/schemas/cwl/stac.yaml
      - $import: https://eoap.github.io/schemas/cwl/bbox.yaml

inputs:
  area_of_interest:
    type: eoap:geojson#Feature
  input_scene:
    type: eoap:stac#Item
  spatial_extent:
    type: eoap:bbox#BBox

outputs:
  result_catalog:
    type: eoap:stac#Catalog
```

### 2. Deployment to OGC API - Processes

When the CWL workflow is deployed as an OGC API - Processes service:

1. CWL custom types are analyzed
2. Corresponding JSON Schema references are generated
3. Process description is created following Table 13 patterns
4. Service advertises capabilities via OpenAPI

### 3. Process Description Generation

The deployment system generates:

```json
{
  "id": "eo-processor",
  "version": "1.0.0",
  "inputs": {
    "area_of_interest": {
      "title": "Area of Interest",
      "schema": {
        "allOf": [
          {
            "format": "geojson-feature"
          },
          {
            "$ref": "https://geojson.org/schema/Feature.json"
          }
        ]
      }
    },
    "input_scene": {
      "title": "Input Scene",
      "schema": {
        "allOf": [
          {
            "format": "stac-item"
          },
          {
            "$ref": "https://schemas.stacspec.org/v1.0.0/item-spec/json-schema/item.json"
          }
        ]
      }
    },
    "spatial_extent": {
      "title": "Spatial Extent",
      "schema": {
        "type": "object",
        "required": ["bbox"],
        "properties": {
          "bbox": {"type": "array", "items": {"type": "number"}, "minItems": 4},
          "crs": {"type": "string", "enum": ["CRS84", "CRS84h"], "default": "CRS84"}
        }
      }
    }
  },
  "outputs": {
    "result_catalog": {
      "title": "Result Catalog",
      "schema": {
        "allOf": [
          {
            "format": "stac-catalog"
          },
          {
            "$ref": "https://schemas.stacspec.org/v1.0.0/item-spec/json-schema/catalog.json"
          }
        ]
      }
    }
  }
}
```

## Benefits

1. **Type Safety**: Workflows specify exact data types expected
2. **Validation**: Inputs can be validated before execution
3. **Documentation**: Types serve as self-documentation
4. **Interoperability**: Standard types ensure consistent interpretation
5. **Automatic Mapping**: Deployment tools can automatically generate process descriptions
6. **Standards Compliance**: Both CWL and OGC standards are followed

## Relationship to OGC Best Practice 20-089r1

These building blocks implement patterns described in [OGC Best Practice for Earth Observation Application Package (20-089r1)](https://docs.ogc.org/bp/20-089r1.html), particularly:

- **Section 6.2.3**: Staging Input and Output EO Products using STAC
- **Section 7**: Process description and execution patterns
- **Annex A**: Examples of CWL workflows with EO-specific types

## Implementation Notes

### Inline vs. Referenced Schemas

Current implementations often use **inline schemas** in process descriptions for simplicity. However, the building blocks are designed to support both:

- **Inline**: Schema definition embedded directly in process description
- **Referenced**: Schema referenced via `$ref` to canonical locations

### Future Extensions

These building blocks can be extended to support:
- Additional STAC extensions (EO, SAR, etc.)
- More complex geometries
- Custom domain-specific types
- Validation rules and constraints

## References

### Specifications

- [OGC API - Processes Part 1: Core](https://docs.ogc.org/is/18-062r2/18-062r2.html)
- [OGC API - Processes Part 2: Deploy, Replace, Undeploy](https://docs.ogc.org/DRAFTS/20-044.html)
- [OGC Best Practice for Earth Observation Application Package](https://docs.ogc.org/bp/20-089r1.html)
- [Common Workflow Language v1.0](https://www.commonwl.org/v1.0/)
- [GeoJSON Format (RFC 7946)](https://datatracker.ietf.org/doc/html/rfc7946)
- [STAC Specification v1.0.0](https://github.com/radiantearth/stac-spec)

### Code Repositories

- [EOAP Schemas](https://github.com/eoap/schemas)
- [OGC Building Blocks](https://github.com/opengeospatial/bblocks)

## Contributing

Contributions are welcome! Please see the EOAP Schemas repository for guidelines on proposing new custom types or enhancements.

## License

Apache License 2.0 - See LICENSE file for details
