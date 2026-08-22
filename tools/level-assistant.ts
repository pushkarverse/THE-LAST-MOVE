import fs from 'fs';
import path from 'path';
import Ajv from 'ajv';

import 'dotenv/config';
import Groq from 'groq-sdk';

async function generateRoomJson(prompt: string): Promise<any> {
  console.log(`[AI] Generating room based on prompt: "${prompt}"...`);
  
  if (!process.env.GROQ_API_KEY) {
    throw new Error("GROQ_API_KEY environment variable is missing.");
  }
  
  const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });
  
  const MODELS = [
    "openai/gpt-oss-120b",
    "openai/gpt-oss-20b",
    "qwen/qwen3.6-27b",
    "groq/compound-mini",
    "allam-2-7b"
  ];

  let text: string | undefined = undefined;

  for (const model of MODELS) {
    try {
      console.log(`[AI] Attempting generation with model: ${model}...`);
      const chatCompletion = await groq.chat.completions.create({
        messages: [
          {
            role: "system",
            content: `You are an AI Level Designer for THE LAST MOVE.
Generate a JSON room matching this description.

Rules:
1. The room must be a valid JSON object.
2. Provide 'id' as a string (e.g. '1-99').
3. 'grid' must have 'w' and 'h' (numbers).
4. 'player_start' must have 'x' and 'y' (numbers).
5. 'walls' is an array of {x, y} objects.
6. 'exits' is an array of {x, y, is_real, has_shadow} objects.
7. 'last_move' must contain 'rule', 'window_ms', and 'tell' (which contains 'type' and 'start_ms'). It can optionally have a 'mutations' array of strings.

Only output the raw JSON object, without any markdown formatting or \`\`\`json wrappers.`
          },
          {
            role: "user",
            content: prompt
          }
        ],
        model: model,
        response_format: { type: "json_object" }
      });

      text = chatCompletion.choices[0]?.message?.content || undefined;
      if (text) {
        break; // Success!
      }
    } catch (err: any) {
      console.warn(`[AI] Model ${model} failed: ${err.message || err}`);
    }
  }

  if (!text) {
    throw new Error("All models failed or returned empty responses.");
  }
  
  return JSON.parse(text);
}

const ajv = new Ajv();
const schema = {
  type: "object",
  properties: {
    id: { type: "string" },
    grid: { type: "object", properties: { w: { type: "number" }, h: { type: "number" } }, required: ["w", "h"] },
    player_start: { type: "object", properties: { x: { type: "number" }, y: { type: "number" } }, required: ["x", "y"] },
    walls: { type: "array", items: { type: "object" } },
    exits: { type: "array", items: { type: "object" } },
    last_move: { type: "object", required: ["rule", "window_ms", "tell"] }
  },
  required: ["id", "grid", "player_start", "walls", "exits", "last_move"]
};

const validate = ajv.compile(schema);

async function main() {
  const prompt = process.argv[2];
  if (!prompt) {
    console.error("Usage: npx tsx tools/level-assistant.ts <prompt>");
    process.exit(1);
  }

  const roomData = await generateRoomJson(prompt);

  console.log("[Pipeline] Validating generated JSON against schema...");
  const valid = validate(roomData);

  if (!valid) {
    console.error("[Pipeline] Validation Failed! The AI generated malformed JSON.");
    console.error(validate.errors);
    process.exit(1);
  }

  const outputPath = path.join(process.cwd(), 'public', 'rooms', `${roomData.id}.json`);
  fs.writeFileSync(outputPath, JSON.stringify(roomData, null, 2));

  console.log(`[Pipeline] Success! Validated room saved to: ${outputPath}`);
}

main().catch(console.error);
