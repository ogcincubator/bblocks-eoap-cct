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

