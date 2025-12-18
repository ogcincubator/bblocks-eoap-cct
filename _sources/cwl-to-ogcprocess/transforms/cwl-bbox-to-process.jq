# Map CWL OGC BBox custom type to OGC API Processes schemas
# Supports both CommandLineTool and Workflow (with $graph)

# Helper function to extract the root element
def getRootElement:
  if has("$graph") then
    ."$graph"[0]
  else
    .
  end;

def mapBBoxType:
  if (. | contains("ogc.yaml#BBox")) or (. | contains("bbox")) then
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
    { type: "object" }
  end;

getRootElement as $root |
{
  id: ($root.id // (if ($root.baseCommand | type) == "array" then $root.baseCommand[0] else $root.baseCommand end) // "bbox-process"),
  version: "1.0.0",
  title: ($root.label // "BBox Process"),
  description: ($root.doc // "Process using OGC BoundingBox custom type"),
  
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
                if ($inputType | type) == "string" and ($inputType | contains("ogc.yaml#BBox")) then
                  $inputType | mapBBoxType
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
                if ($inputType | type) == "string" and ($inputType | contains("ogc.yaml#BBox")) then
                  $inputType | mapBBoxType
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
                if ($outputType | type) == "string" and ($outputType | contains("ogc.yaml#BBox")) then
                  $outputType | mapBBoxType
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
                if ($outputType | type) == "string" and ($outputType | contains("ogc.yaml#BBox")) then
                  $outputType | mapBBoxType
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
