# Unified transform: CWL CommandLineTool/Workflow to OGC API Processes processDescription
# Supports all EOAP custom types: BBox, GeoJSON, STAC, and String Formats

# Helper function to extract the root element (first Workflow in $graph, or the document itself)
def getRootElement:
  if has("$graph") then
    # Find the first Workflow in the $graph array
    (."$graph" | map(select(.class == "Workflow")) | first) // ."$graph"[0]
  else
    .
  end;

# Map BBox custom type to OGC schema
def mapBBoxType:
  if (. | type) == "string" and ((. | contains("bbox.yaml#BBox")) or (. | contains("ogc.yaml#BBox"))) then
    {
      type: "object",
      required: ["bbox"],
      properties: {
        bbox: {
          type: "array",
          items: { type: "number" },
          oneOf: [
            { minItems: 4, maxItems: 4, description: "2D bbox" },
            { minItems: 6, maxItems: 6, description: "3D bbox" }
          ]
        },
        crs: {
          type: "string",
          enum: ["CRS84", "CRS84h"],
          default: "CRS84"
        }
      }
    }
  else
    null
  end;

# Map GeoJSON custom types to OGC schemas
def mapGeoJSONType:
  if (. | type) == "string" then
    if (. | contains("geojson.yaml#")) then
      if (. | contains("Point")) then
        { 
          type: "object",
          required: ["type", "coordinates"],
          properties: {
            type: { type: "string", enum: ["Point"] },
            coordinates: { 
              type: "array",
              minItems: 2,
              maxItems: 3,
              items: { type: "number" }
            }
          },
          format: "geojson-geometry"
        }
      elif (. | contains("Feature")) then
        {
          type: "object",
          required: ["type", "geometry", "properties"],
          properties: {
            type: { type: "string", enum: ["Feature"] },
            geometry: { type: "object" },
            properties: { type: "object" }
          },
          format: "geojson-feature"
        }
      elif (. | contains("FeatureCollection")) then
        {
          type: "object",
          required: ["type", "features"],
          properties: {
            type: { type: "string", enum: ["FeatureCollection"] },
            features: { 
              type: "array",
              items: { type: "object" }
            }
          },
          format: "geojson-feature-collection"
        }
      else
        { type: "object", format: "geojson-geometry" }
      end
    else
      null
    end
  else
    null
  end;

# Map STAC custom types to OGC schemas  
def mapSTACType:
  if (. | type) == "string" and (. | contains("stac.yaml#")) then
    if (. | contains("Item")) then
      {
        type: "object",
        required: ["type", "stac_version", "id", "geometry", "properties", "links", "assets"],
        properties: {
          type: { type: "string", enum: ["Feature"] },
          stac_version: { type: "string" },
          id: { type: "string" },
          geometry: { type: "object" },
          properties: { type: "object" },
          links: { type: "array" },
          assets: { type: "object" }
        },
        format: "stac-item"
      }
    elif (. | contains("Collection")) then
      {
        type: "object",
        required: ["type", "stac_version", "id", "description", "license", "extent", "links"],
        format: "stac-collection"
      }
    elif (. | contains("Catalog")) then
      {
        type: "object",
        required: ["type", "stac_version", "id", "description", "links"],
        format: "stac-catalog"
      }
    else
      { type: "object", format: "stac" }
    end
  else
    null
  end;

# Map string format custom types to OGC schemas
def mapStringFormatType:
  if (. | type) == "string" and (. | contains("string-format.yaml#")) then
    if (. | contains("DateTime")) then
      { type: "string", format: "date-time" }
    elif (. | contains("Date")) then
      { type: "string", format: "date" }
    elif (. | contains("Time")) then
      { type: "string", format: "time" }
    elif (. | contains("Duration")) then
      { type: "string", format: "duration" }
    elif (. | contains("URI")) then
      { type: "string", format: "uri" }
    elif (. | contains("Email")) then
      { type: "string", format: "email" }
    elif (. | contains("UUID")) then
      { type: "string", format: "uuid" }
    elif (. | contains("IPv4")) then
      { type: "string", format: "ipv4" }
    elif (. | contains("IPv6")) then
      { type: "string", format: "ipv6" }
    elif (. | contains("Hostname")) then
      { type: "string", format: "hostname" }
    else
      { type: "string" }
    end
  else
    null
  end;

# Map CWL File type to OGC schema
def mapFileType:
  if . == "File" or . == "stdout" or . == "stderr" then
    {
      type: "string",
      contentMediaType: "application/octet-stream"
    }
  else
    null
  end;

# Map CWL Directory type to OGC schema
def mapDirectoryType:
  if . == "Directory" then
    {
      type: "string",
      contentMediaType: "application/x-directory"
    }
  else
    null
  end;

# Unified type mapper - tries all type mappings
def mapType:
  . as $type |
  # Check if it's an array type (e.g., "string[]", "int[]", etc.)
  if ($type | type) == "string" and ($type | endswith("[]")) then
    # Extract base type by removing "[]" suffix
    ($type | sub("\\[\\]$"; "")) as $baseType |
    {
      type: "array",
      items: ($baseType | mapType)
    }
  else
    (mapBBoxType // mapGeoJSONType // mapSTACType // mapStringFormatType // mapFileType // mapDirectoryType // 
     if ($type | type) == "string" then
       if $type == "string" then { type: "string" }
       elif $type == "int" or $type == "long" then { type: "integer" }
       elif $type == "float" or $type == "double" then { type: "number" }
       elif $type == "boolean" then { type: "boolean" }
       else { type: "string" }
       end
     else
       { type: "object" }
     end
    )
  end;

# Process inputs
def processInputs:
  if . then
    if (. | type) == "array" then
      # Workflow style: inputs is an array with id fields
      map(
        .type as $inputType |
        {
          key: .id,
          value: {
            title: (.label // .id),
            description: (.doc // ""),
            schema: ($inputType | mapType),
            minOccurs: 1,
            maxOccurs: 1
          }
        }
      ) | from_entries
    else
      # CommandLineTool style: inputs is an object
      to_entries | map(
        .value.type as $inputType |
        {
          key: .key,
          value: {
            title: (.value.label // .key),
            description: (.value.doc // ""),
            schema: ($inputType | mapType),
            minOccurs: 1,
            maxOccurs: 1
          }
        }
      ) | from_entries
    end
  else
    {}
  end;

# Process outputs
def processOutputs:
  if . then
    if (. | type) == "array" then
      # Workflow style: outputs is an array with id fields
      map(
        .type as $outputType |
        {
          key: .id,
          value: {
            title: (.label // .id),
            description: (.doc // ""),
            schema: ($outputType | mapType)
          }
        }
      ) | from_entries
    else
      # CommandLineTool style: outputs is an object
      to_entries | map(
        .value.type as $outputType |
        {
          key: .key,
          value: {
            title: (.value.label // .key),
            description: (.value.doc // ""),
            schema: ($outputType | mapType)
          }
        }
      ) | from_entries
    end
  else
    {}
  end;

# Main transformation
getRootElement as $root |
{
  id: ($root.id // (if ($root.baseCommand | type) == "array" then $root.baseCommand[0] else $root.baseCommand end) // "cwl-process"),
  version: "1.0.0",
  title: ($root.label // "CWL Process"),
  description: ($root.doc // "Process converted from CWL"),
  
  inputs: ($root.inputs | processInputs),
  outputs: ($root.outputs | processOutputs),
  
  jobControlOptions: ["async-execute", "sync-execute"],
  outputTransmission: ["value", "reference"]
}
