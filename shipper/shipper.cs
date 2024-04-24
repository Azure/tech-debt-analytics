using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;

namespace appcatdl
{
    public class shipper
    {
        private readonly ILogger<shipper> _logger;

        public shipper(ILogger<shipper> logger)
        {
            _logger = logger;
        }

        [Function("shipper")]
        [BlobOutput("appcat/{org}/{repo}/{branch}/{pr}/{commit}/{committer}/{DateTime.Now:yyyyMMddHHmmss}.json", Connection = "AzureWebJobsStorage")]
        public async Task<string> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "put")] HttpRequestData req,
            FunctionContext context)
        {
            var org = req.Url.Query["org"] ?? "00";
            var repo = req.Url.Query["repo"] ?? "00";
            var branch = req.Url.Query["branch"] ?? "00";
            var pr = req.Url.Query["pr"] ?? "00";
            var commit = req.Url.Query["commit"] ?? "00";
            var committer = req.Url.Query["committer"] ?? "00";

            string requestBody;
            using (StreamReader reader = new StreamReader(req.Body))
            {
                requestBody = await reader.ReadToEndAsync();
            }

            _logger.LogInformation("C# HTTP trigger function processed a request.");

            return requestBody;
        }
    }
}