import { INestApplication } from "@nestjs/common";
import { Client, logger } from "camunda-external-task-client-js";

export const startCamundaWorker = (app: INestApplication) => {
    // configuration for the Client:
    //  - 'baseUrl': url to the Process Engine
    //  - 'logger': utility to automatically log important events
    const config = { baseUrl: "http://localhost:32002/engine-rest", use: logger };

    // create a Client instance with custom configuration
    const client = new Client(config);

    // susbscribe to the topic: 'sendEmailSummary'
    client.subscribe("sendEmailSummary", async function({ task, taskService }) {
        // Put your business logic
        logger.success("sendEmailSummary task received");
        // complete the task
        await taskService.complete(task);
    });
}
