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

