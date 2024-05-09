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
        static string GetValueFromQuery(System.Collections.Specialized.NameValueCollection query, string key, string defaultValue)
        {
            string value = query[key];
            return !string.IsNullOrEmpty(value) ? value : defaultValue;
        }

        [Function("shipper")]
        [BlobOutput("appcat/org={org}/repo={repo}/branch={branch}/pr={pr}/commit={commit}/committer={committer}/{DateTime.Now:yyyyMMddHHmmss}.json", Connection = "AzureWebJobsStorage")]
        public static async Task<string> Ship([HttpTrigger(AuthorizationLevel.Anonymous, "put")] HttpRequestData req,
            FunctionContext executionContext)
        {
            ILogger log = executionContext.GetLogger("Shipper");
            string requestBody = await req.ReadAsStringAsync();
            System.Collections.Specialized.NameValueCollection query = HttpUtility.ParseQueryString(req.Url.Query);
            string org = GetValueFromQuery(query, "org", "00");
            string repo = GetValueFromQuery(query, "repo", "00");
            string branch = GetValueFromQuery(query, "branch", "00");
            string pr = GetValueFromQuery(query, "pr", "00");
            string commit = GetValueFromQuery(query, "commit", "00");
            string committer = GetValueFromQuery(query, "committer", "00");
         
            log.LogInformation("C# HTTP trigger function processed a request.");

            return requestBody;
        }
    }
}