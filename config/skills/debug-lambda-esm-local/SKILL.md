---
name: debug-lambda-esm-local
description: Set up local debugging for ESM-based AWS Lambda functions using tsx and VS Code
---

When a user wants to debug an AWS Lambda function locally in a Node.js project using ES Modules (`type: "module"`), `ts-node` often fails. Use `tsx` instead.

Follow these steps to set up local debugging for VS Code:

### 1. Create a `local.ts` script
Create a file at the root of the project to import the Lambda handler and invoke it with mock data:

```typescript
import handler from "./src/app.js"; // adjust path as needed
import type { APIGatewayProxyEvent, Context } from "aws-lambda";

const mockEvent: Partial<APIGatewayProxyEvent> = {
  headers: {
    "X-Example-Header": "mock-value"
  },
  queryStringParameters: {
    param1: "value1"
  },
};

const mockContext: Partial<Context> = {
  awsRequestId: "mock-request-id",
  functionName: "local-debug-function",
};

async function run() {
  console.log("🚀 Invoking lambda locally...\n");
  try {
    const result = await handler(
      mockEvent as APIGatewayProxyEvent,
      mockContext as Context
    );
    console.log("✅ Lambda Response:\n", JSON.stringify(result, null, 2));
  } catch (error) {
    console.error("❌ Lambda Error:\n", error);
  }
}

run();
```

### 2. Configure VS Code Launch
Create or update `.vscode/launch.json` to use `tsx` via `npx`. This avoids global installation issues and handles ESM natively:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug Lambda Local",
      "type": "node",
      "request": "launch",
      "runtimeExecutable": "npx",
      "runtimeArgs": ["tsx", "${workspaceFolder}/local.ts"],
      "console": "integratedTerminal",
      "skipFiles": ["<node_internals>/**", "**/node_modules/**"]
    }
  ]
}
```

### 3. Instruct the User
Tell the user they can now open the "Run and Debug" panel in VS Code (F5), select "Debug Lambda Local", and place breakpoints directly in their handler code.
