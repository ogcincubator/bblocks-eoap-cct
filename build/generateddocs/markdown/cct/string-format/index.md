
# eaop-cct:String-Format (Schema)

`eoap.cct.string-format` *v1.0*

CWL custom types for standard string formats (date, datetime, URI, email, etc.)

[*Status*](http://www.opengis.net/def/status): Under development

## Description

This building block defines CWL custom types for standard string formats conforming to JSON Schema and OpenAPI specifications. These types enable workflows to validate and document string inputs/outputs with specific format constraints.

## Relationship to OGC API - Processes

When CWL workflows using these string format types are deployed as OGC API - Processes services, the format constraints map to JSON Schema format keywords in the process description (extending the Table 13).

### Example Mapping

**CWL Input:**
```yaml
inputs:
  start_date:
    type: eoap:string-format#DateTime
    doc: "Processing start date and time"
```

**OGC Process Description:**
```json
{
  "inputs": {
    "start_date": {
      "title": "Processing start date and time",
      "schema": {
        "type": "string",
        "format": "date-time"
      }
    }
  }
}
```

## Usage in CWL Workflows

To use string format custom types in a CWL workflow:

```yaml
cwlVersion: v1.0
class: Workflow

requirements:
  SchemaDefRequirement:
    types:
      - $import: https://eoap.github.io/schemas/cwl/string-format.yaml

inputs:
  observation_time:
    type: eoap:string-format#DateTime
    doc: "Time of observation"
    inputBinding:
      prefix: --time
  
  data_url:
    type: eoap:string-format#URI
    doc: "URL to input data"
    inputBinding:
      prefix: --url
  
  processing_duration:
    type: eoap:string-format#Duration
    doc: "Maximum processing duration"
    inputBinding:
      prefix: --timeout

  contact_email:
    type: eoap:string-format#Email
    doc: "Contact email for notifications"
    inputBinding:
      prefix: --notify
```


## Examples

### Date value
#### yaml
```yaml
value: "2023-12-17"

```


### DateTime value
#### yaml
```yaml
value: "2023-12-17T10:30:00Z"

```


### Time value
#### yaml
```yaml
value: "10:30:00"

```


### Duration value
#### yaml
```yaml
value: "PT30M"

```


### URI value
#### yaml
```yaml
value: "https://example.com/data/products"

```


### URIReference value
#### yaml
```yaml
value: "/relative/path"

```


### URITemplate value
#### yaml
```yaml
value: "https://api.example.com/collections/{id}/items{?limit,bbox}"

```


### IRI value
#### yaml
```yaml
value: "https://例え.jp/データ"

```


### Email value
#### yaml
```yaml
value: "user@example.com"

```


### IDNEmail value
#### yaml
```yaml
value: "用户@例え.jp"

```


### Hostname value
#### yaml
```yaml
value: "api.example.com"

```


### IDNHostname value
#### yaml
```yaml
value: "例え.jp"

```


### IPv4 value
#### yaml
```yaml
value: "192.168.1.1"

```


### IPv6 value
#### yaml
```yaml
value: "2001:0db8:85a3:0000:0000:8a2e:0370:7334"

```


### JsonPointer value
#### yaml
```yaml
value: "/properties/name"

```


### RelativeJsonPointer value
#### yaml
```yaml
value: "0/name"

```


### UUID value
#### yaml
```yaml
value: "123e4567-e89b-12d3-a456-426614174000"

```

## Schema

```yaml
$ref: https://raw.githubusercontent.com/eoap/schemas/refs/heads/main/string_format.yaml
x-jsonld-extra-terms:
  Date: http://www.w3.org/2001/XMLSchema#date
  DateTime: http://www.w3.org/2001/XMLSchema#dateTime
  Time: http://www.w3.org/2001/XMLSchema#time
  Duration: http://www.w3.org/2001/XMLSchema#duration
  URI: http://www.w3.org/2001/XMLSchema#anyURI
  Email: https://schema.org/email
  UUID: https://schema.org/identifier
x-jsonld-vocab: https://www.opengis.net/def/metamodel/ogc-na/
x-jsonld-prefixes:
  xsd: http://www.w3.org/2001/XMLSchema#
  schema: https://schema.org/
  dct: http://purl.org/dc/terms/
  cwl: https://w3id.org/cwl/cwl#
  eoap: https://eoap.github.io/schemas/cwl/

```

Links to the schema:

* YAML version: [schema.yaml](https://geolabs.github.io/bblocks-eoap-cct/build/annotated/cct/string-format/schema.json)
* JSON version: [schema.json](https://geolabs.github.io/bblocks-eoap-cct/build/annotated/cct/string-format/schema.yaml)


# JSON-LD Context

```jsonld
{
  "@context": {
    "@vocab": "https://www.opengis.net/def/metamodel/ogc-na/",
    "Date": "xsd:date",
    "DateTime": "xsd:dateTime",
    "Time": "xsd:time",
    "Duration": "xsd:duration",
    "URI": "xsd:anyURI",
    "Email": "schema:email",
    "UUID": "schema:identifier",
    "xsd": "http://www.w3.org/2001/XMLSchema#",
    "schema": "https://schema.org/",
    "dct": "http://purl.org/dc/terms/",
    "cwl": "https://w3id.org/cwl/cwl#",
    "eoap": "https://eoap.github.io/schemas/cwl/",
    "@version": 1.1
  }
}
```

You can find the full JSON-LD context here:
[context.jsonld](https://geolabs.github.io/bblocks-eoap-cct/build/annotated/cct/string-format/context.jsonld)

## Sources

* [JSON Schema Validation - String Formats](https://json-schema.org/understanding-json-schema/reference/string.html#format)
* [OpenAPI 3.0 - Data Types](https://swagger.io/docs/specification/v3_0/data-models/data-types/)
* [RFC 1123 - Requirements for Internet Hosts - Application and Support](https://tools.ietf.org/html/rfc1123)
* [RFC 3339 - Date and Time on the Internet](https://tools.ietf.org/html/rfc3339)
* [RFC 3986 - Uniform Resource Identifier (URI)](https://tools.ietf.org/html/rfc3986)
* [RFC 3987 - Internationalized Resource Identifiers (IRIs)](https://tools.ietf.org/html/rfc3987)
* [RFC 4122 - A Universally Unique IDentifier (UUID) URN Namespace](https://tools.ietf.org/html/rfc4122)
* [RFC 4291 - IP Version 6 Addressing Architecture](https://tools.ietf.org/html/rfc4291)
* [RFC 5321 - Simple Mail Transfer Protocol](https://tools.ietf.org/html/rfc5321)
* [RFC 5890 - Internationalized Domain Names for Applications (IDNA): Definitions and Document Framework](https://tools.ietf.org/html/rfc5890)
* [RFC 6531 - Internationalized Email Headers](https://tools.ietf.org/html/rfc6531)
* [RFC 6570 - A Uniform Resource Name (URN) Namespace for UUIDs](https://tools.ietf.org/html/rfc6570)
* [RFC 6901 - JSON Pointer](https://tools.ietf.org/html/rfc6901)
* [OGC API - Processes Part 1 - Table 13](https://docs.ogc.org/DRAFTS/18-062r3.html#_921c9ed7-3bf5-8c1d-a5be-f1ca4d0d5351)
* [EOAP CWL Custom Types - String Formats](https://raw.githubusercontent.com/eoap/schemas/refs/heads/main/string_format.yaml)

# For developers

The source code for this Building Block can be found in the following repository:

* URL: [https://github.com/GeoLabs/bblocks-eoap-cct](https://github.com/GeoLabs/bblocks-eoap-cct)
* Path: `_sources/string-format`

