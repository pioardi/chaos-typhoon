let appInsights = require("applicationinsights");
const instrumentationKey = process.env.APPINSIGHTS_INSTRUMENTATIONKEY
appInsights.setup(instrumentationKey)
appInsights.defaultClient.setAutoPopulateAzureProperties(true);
//appInsights.defaultClient.setDistributedTracingMode(true)
//appInsights.defaultClient.setAutoCollectPerformance(false)
appInsights.start();
const client = appInsights.defaultClient


const httpTrigger = async function (context, req) {
    context.log('JavaScript HTTP trigger function processed a request.');
    context.log('Received order number: ' + req.body.id);

    const responseMessage = "Received order with id " + req.body.id

    client.trackMetric({name: "OrderReceived", value: 1});
    context.res = {
        // status: 200, /* Defaults to 200 */
        body: responseMessage
    };
}

// Default export wrapped with Application Insights FaaS context propagation
module.exports = async function contextPropagatingHttpTrigger(context, req) {
    // Start an AI Correlation Context using the provided Function context
    const correlationContext = appInsights.startOperation(context, req);

    // Wrap the Function runtime with correlationContext
    return appInsights.wrapWithCorrelationContext(async () => {
        const startTime = Date.now(); // Start trackRequest timer

        // Run the Function
        await httpTrigger(context, req);

        // Track Request on completion
        appInsights.defaultClient.trackRequest({
            name: context.req.method + " " + context.req.url,
            resultCode: context.res.status,
            success: true,
            url: req.url,
            duration: Date.now() - startTime,
            id: correlationContext.operation.parentId,
        });
        appInsights.defaultClient.flush();
    }, correlationContext)();
};