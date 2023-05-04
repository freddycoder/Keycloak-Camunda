import { INestApplication, Logger } from "@nestjs/common";
import { Client, logger } from "camunda-external-task-client-js";
import { SESClient, SendEmailCommand } from "@aws-sdk/client-ses";
import { ConfigService } from "@nestjs/config";

export const startCamundaWorker = (app: INestApplication) => {
    // Get the configuration of the camunda worker
    const camundaWorkerConfig = app.get(ConfigService);
    // configuration for the Client:
    //  - 'baseUrl': url to the Process Engine
    //  - 'logger': utility to automatically log important events
    const config = { baseUrl: camundaWorkerConfig.get('camunda.url'), use: logger };

    // create a Client instance with custom configuration
    const client = new Client(config);

    // susbscribe to the topic: 'sendEmailSummary'
    client.subscribe("sendEmailSummary", async function({ task, taskService }) {
        // Put your business logic
        Logger.verbose("sendEmailSummary task received");

        // Send email summary using aws ses
        await sendEmailSummary(camundaWorkerConfig);

        // complete the task
        await taskService.complete(task);
    });
}

// A function to send email summary using aws ses
async function sendEmailSummary(config: ConfigService) {
    // A sample to send a email using aws ses
    try {
        const client = new SESClient({ 
            region: config.get('aws_ses.region'),
            credentials: config.get('aws_ses.useCredentials') === 'true' ? {
                accessKeyId: config.get('aws_ses.accessKeyId') ?? '',
                secretAccessKey: config.get('aws_ses.secretAccessKey') ?? ''
            } : undefined
        })

        await client.send(createSendEmailCommand(
            config.get("aws_ses.to") ?? "",
            config.get("aws_ses.from") ?? "", 
            )
        )
    }
    catch (err) {
        Logger.error(err);
    }
}

const createSendEmailCommand = (toAddresses: string, fromAddress: string) => {
    return new SendEmailCommand({
        Destination: {
            ToAddresses: toAddresses.split(';')
        },
        Message: {
            Body: {
                Text: {
                    Data: "This is the message body in text format.",
                    Charset: "UTF-8"
                },
            },
            Subject: {
                Data: "Test email",
                Charset: "UTF-8"
            },
        },
        Source: fromAddress,
    });
}