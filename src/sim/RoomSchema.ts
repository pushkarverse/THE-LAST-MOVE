export const roomSchema = {
  type: "object",
  properties: {
    id: { type: "string" },
    grid: {
      type: "object",
      properties: {
        w: { type: "integer", minimum: 1 },
        h: { type: "integer", minimum: 1 }
      },
      required: ["w", "h"]
    },
    player_start: {
      type: "object",
      properties: { x: { type: "integer" }, y: { type: "integer" } },
      required: ["x", "y"]
    },
    walls: {
      type: "array",
      items: {
        type: "object",
        properties: { x: { type: "integer" }, y: { type: "integer" } },
        required: ["x", "y"]
      }
    },
    exits: {
      type: "array",
      items: {
        type: "object",
        properties: {
          x: { type: "integer" },
          y: { type: "integer" },
          is_real: { type: "boolean" },
          has_shadow: { type: "boolean" }
        },
        required: ["x", "y", "is_real"]
      }
    },
    last_move: {
      type: "object",
      properties: {
        rule: { type: "string" },
        window_ms: { type: "integer", minimum: 100 },
        tell: {
          type: "object",
          properties: {
            type: { type: "string" },
            start_ms: { type: "integer", minimum: 0 }
          },
          required: ["type", "start_ms"]
        }
      },
      required: ["rule", "window_ms", "tell"]
    }
  },
  required: ["id", "grid", "player_start", "walls", "exits", "last_move"]
};
