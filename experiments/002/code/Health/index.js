module.exports = async function (context, req) {
    context.log('Health http trigger invoked');

    context.res = {
        status: 200
    };
}