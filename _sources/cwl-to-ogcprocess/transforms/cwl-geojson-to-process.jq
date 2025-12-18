# Map CWL GeoJSON custom types to OGC API Processes schemas
# Extracts GeoJSON type references and maps them to proper schema definitions
# Supports both CommandLineTool and Workflow (with $graph)

# Helper function to extract the root element (handles both CommandLineTool and $graph[0] Workflow)
def getRootElement:
  if has("$graph") then
    ."$graph"[0]
  else
    .
  end;

# Helper function to map GeoJSON type to schema
def mapGeoJSONType:
  if . | contains("geojson.yaml#Point") then
    {
      type: "object",
      required: ["type", "coordinates"],
      properties: {
        type: { type: "string", enum: ["Point"] },
        coordinates: {
          type: "array",
          items: { type: "number" },
          minItems: 2,
          maxItems: 3
        }
      }
    }
  elif . | contains("geojson.yaml#Polygon") then
    {
      type: "object",
      required: ["type", "coordinates"],
      properties: {
        type: { type: "string", enum: ["Polygon"] },
        coordinates: {
          type: "array",
          items: {
            type: "array",
            items: {
              type: "array",
              items: { type: "number" }
            }
          }
        }
      }
    }
  elif . | contains("geojson.yaml#Feature") then
    {
      type: "object",
      required: ["type", "geometry", "properties"],
      properties: {
        type: { type: "string", enum: ["Feature"] },
        geometry: { type: "object" },
        properties: { type: "object" },
        id: { oneOf: [{ type: "string" }, { type: "number" }] }
      }
    }
  elif . | contains("geojson.yaml#FeatureCollection") then
    {
      type: "object",
      required: ["type", "features"],
      properties: {
        type: { type: "string", enum: ["FeatureCollection"] },
        features: {
          type: "array",
          items: { type: "object" }
        }
      }
    }
  else
    { type: "object" }
  end;

# Main transform
getRootElement as $root |
{
  id: ($root.id // (if ($root.baseCommand | type) == "array" then $root.baseCommand[0] else $root.baseCommand end) // "geojson-process"),
  version: "1.0.0",
  title: ($root.label // "GeoJSON Process"),
  description: ($root.doc // "Process using GeoJSON custom types"),
  
  inputs: (
    if $root.inputs then
      # Check if inputs is an array (Workflow style) or object (CommandLineTool style)
      if ($root.inputs | type) == "array" then
        # Workflow style: inputs is an array with id fields
        $root.inputs | map(
          .type as $inputType |
          {
            key: .id,
            value: {
              title: (.label // .id),
              description: (.doc // ""),
              schema: (
                if ($inputType | type) == "string" and ($inputType | contains("geojson.yaml#")) then
                  $inputType | mapGeoJSONType
                else
                  { type: "string" }
                end
              ),
              minOccurs: 1,
              maxOccurs: 1
            }
          }
        ) | from_entries
      else
        # CommandLineTool style: inputs is an object
        $root.inputs | to_entries | map(
          .value.type as $inputType |
          {
            key: .key,
            value: {
              title: (.value.label // .key),
              description: (.value.doc // ""),
              schema: (
                if ($inputType | type) == "string" and ($inputType | contains("geojson.yaml#")) then
                  $inputType | mapGeoJSONType
                else
                  { type: "string" }
                end
              ),
              minOccurs: 1,
              maxOccurs: 1
            }
          }
        ) | from_entries
      end
    else
      {}
    end
  ),
  
  outputs: (
    if $root.outputs then
      # Check if outputs is an array (Workflow style) or object (CommandLineTool style)
      if ($root.outputs | type) == "array" then
        # Workflow style: outputs is an array with id fields
        $root.outputs | map(
          .type as $outputType |
          {
            key: .id,
            value: {
              title: (.label // .id),
              description: (.doc // ""),
              schema: (
                if ($outputType | type) == "string" and ($outputType | contains("geojson.yaml#")) then
                  $outputType | mapGeoJSONType
                elif $outputType == "stdout" or $outputType == "File" then
                  { type: "string" }
                else
                  { type: "string" }
                end
              )
            }
          }
        ) | from_entries
      else
        # CommandLineTool style: outputs is an object
        $root.outputs | to_entries | map(
          .value.type as $outputType |
          {
            key: .key,
            value: {
              title: (.value.label // .key),
              description: (.value.doc // ""),
              schema: (
                if ($outputType | type) == "string" and ($outputType | contains("geojson.yaml#")) then
                  $outputType | mapGeoJSONType
                elif $outputType == "stdout" then
                  { type: "string" }
                else
                  { type: "string" }
                end
              )
            }
          }
        ) | from_entries
      end
    else
      {}
    end
  ),
  
  jobControlOptions: ["async-execute", "sync-execute"],
  outputTransmission: ["value", "reference"]
}
