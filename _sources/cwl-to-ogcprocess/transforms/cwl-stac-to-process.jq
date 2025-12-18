# Map CWL STAC custom types to OGC API Processes schemas
# Supports both CommandLineTool and Workflow (with $graph)

# Helper function to extract the root element
def getRootElement:
  if has("$graph") then
    ."$graph"[0]
  else
    .
  end;

def mapSTACType:
  if . | contains("stac.yaml#Item") then
    {
      type: "object",
      required: ["type", "stac_version", "id", "geometry", "bbox", "properties", "links", "assets"],
      properties: {
        type: { type: "string", enum: ["Feature"] },
        stac_version: { type: "string" },
        id: { type: "string" },
        geometry: { type: "object" },
        bbox: { type: "array", items: { type: "number" } },
        properties: { type: "object" },
        links: { type: "array" },
        assets: { type: "object" }
      }
    }
  elif . | contains("stac.yaml#Catalog") then
    {
      type: "object",
      required: ["type", "stac_version", "id", "description", "links"],
      properties: {
        type: { type: "string", enum: ["Catalog"] },
        stac_version: { type: "string" },
        id: { type: "string" },
        title: { type: "string" },
        description: { type: "string" },
        links: { type: "array" }
      }
    }
  elif . | contains("stac.yaml#Collection") then
    {
      type: "object",
      required: ["type", "stac_version", "id", "description", "license", "extent", "links"],
      properties: {
        type: { type: "string", enum: ["Collection"] },
        stac_version: { type: "string" },
        id: { type: "string" },
        title: { type: "string" },
        description: { type: "string" },
        license: { type: "string" },
        extent: { type: "object" },
        links: { type: "array" }
      }
    }
  else
    { type: "object" }
  end;

getRootElement as $root |
{
  id: ($root.id // (if ($root.baseCommand | type) == "array" then $root.baseCommand[0] else $root.baseCommand end) // "stac-process"),
  version: "1.0.0",
  title: ($root.label // "STAC Process"),
  description: ($root.doc // "Process using STAC custom types"),
  
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
                if ($inputType | type) == "string" and ($inputType | contains("stac.yaml#")) then
                  $inputType | mapSTACType
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
                if ($inputType | type) == "string" and ($inputType | contains("stac.yaml#")) then
                  $inputType | mapSTACType
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
                if ($outputType | type) == "string" and ($outputType | contains("stac.yaml#")) then
                  $outputType | mapSTACType
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
                if ($outputType | type) == "string" and ($outputType | contains("stac.yaml#")) then
                  $outputType | mapSTACType
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
