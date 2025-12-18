# Map CWL String Format custom types to OGC API Processes schemas
# Supports both CommandLineTool and Workflow (with $graph)

# Helper function to extract the root element
def getRootElement:
  if has("$graph") then
    ."$graph"[0]
  else
    .
  end;

def mapStringFormatType:
  if (. | contains("string_format.yaml#DateTime")) or (. | contains("DateTime")) then
    {
      type: "object",
      required: ["value"],
      properties: {
        value: {
          type: "string",
          format: "date-time",
          description: "ISO 8601 datetime"
        }
      }
    }
  elif (. | contains("string_format.yaml#Date")) or (. | contains("Date")) then
    {
      type: "object",
      required: ["value"],
      properties: {
        value: {
          type: "string",
          format: "date",
          description: "ISO 8601 date"
        }
      }
    }
  elif (. | contains("string_format.yaml#URI")) or (. | contains("URI")) then
    {
      type: "object",
      required: ["value"],
      properties: {
        value: {
          type: "string",
          format: "uri",
          description: "URI"
        }
      }
    }
  elif (. | contains("string_format.yaml#Email")) or (. | contains("Email")) then
    {
      type: "object",
      required: ["value"],
      properties: {
        value: {
          type: "string",
          format: "email",
          description: "Email address"
        }
      }
    }
  elif (. | contains("string_format.yaml#UUID")) or (. | contains("UUID")) then
    {
      type: "object",
      required: ["value"],
      properties: {
        value: {
          type: "string",
          format: "uuid",
          description: "UUID"
        }
      }
    }
  elif (. | contains("string_format.yaml#Duration")) or (. | contains("Duration")) then
    {
      type: "object",
      required: ["value"],
      properties: {
        value: {
          type: "string",
          format: "duration",
          description: "ISO 8601 duration"
        }
      }
    }
  else
    {
      type: "object",
      properties: {
        value: { type: "string" }
      }
    }
  end;

getRootElement as $root |
{
  id: ($root.id // (if ($root.baseCommand | type) == "array" then $root.baseCommand[0] else $root.baseCommand end) // "string-format-process"),
  version: "1.0.0",
  title: ($root.label // "String Format Process"),
  description: ($root.doc // "Process using String Format custom types"),
  
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
                if ($inputType | type) == "string" and ($inputType | contains("string_format.yaml#")) then
                  $inputType | mapStringFormatType
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
                if ($inputType | type) == "string" and ($inputType | contains("string_format.yaml#")) then
                  $inputType | mapStringFormatType
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
                if ($outputType | type) == "string" and ($outputType | contains("string_format.yaml#")) then
                  $outputType | mapStringFormatType
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
                if ($outputType | type) == "string" and ($outputType | contains("string_format.yaml#")) then
                  $outputType | mapStringFormatType
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
