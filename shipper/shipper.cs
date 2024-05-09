using System.Web;
using System.Threading.Tasks;
using System.IO;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace appcatdl
{
    public static class Shipper
    {
        [Function("shipper")]
        [BlobOutput("appcat/{org}/{repo}/{branch}/{pr}/{commit}/{committer}/{DateTime.Now:yyyyMMddHHmmss}.json", Connection = "AzureWebJobsStorage")]
        public static async Task<string> Ship([HttpTrigger(AuthorizationLevel.Anonymous, "put")] HttpRequestData req,
            ILogger log,
            FunctionContext executionContext)
        {
            string requestBody = await req.ReadAsStringAsync();
            var query = HttpUtility.ParseQueryString(req.Url.Query);
            var org = query["org"] ?? "00";
            var repo = query["repo"] ?? "00";
            var branch = query["branch"] ?? "00";
            var pr = query["pr"] ?? "00";
            var commit = query["commit"] ?? "00";
            var committer = query["committer"] ?? "00";

            log.LogInformation("C# HTTP trigger function processed a request.");

            return requestBody;
        }
    }
}