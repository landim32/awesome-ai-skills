// Canonical template for Fixtures/ApiTestFixture.cs (Default: Generic JWT Bearer)
// Contract: this file is the source of truth for the skill's default fixture output.
// Variations (NAuth, OAuth2, API key) are documented as diffs in SKILL.md §Auth Presets.
//
// Fast-fail invariant (FR-016, SC-012): any value still equal to a "REPLACE_VIA_ENV_*"
// placeholder after ConfigurationBuilder resolution MUST throw a descriptive exception
// naming the missing environment variable.

using Flurl;
using Flurl.Http;
using Microsoft.Extensions.Configuration;

namespace %%ROOT_NAMESPACE%%.Fixtures
{
    public class ApiTestFixture : IAsyncLifetime
    {
        public string BaseUrl { get; private set; } = string.Empty;
        public string AuthToken { get; private set; } = string.Empty;

        private IConfiguration _configuration = null!;

        public async Task InitializeAsync()
        {
            _configuration = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.Test.json", optional: false)
                .AddEnvironmentVariables()
                .Build();

            BaseUrl = RequireConfig("ApiBaseUrl");
            var authBaseUrl = RequireConfig("Auth:BaseUrl");
            var email = RequireConfig("Auth:Email");
            var password = RequireConfig("Auth:Password");
            var loginEndpoint = _configuration["Auth:LoginEndpoint"] ?? "/auth/login";

            try
            {
                var response = await new Url(authBaseUrl)
                    .AppendPathSegment(loginEndpoint)
                    .PostJsonAsync(new { email, password })
                    .ReceiveJson<LoginResponse>();

                AuthToken = response?.Token ?? string.Empty;

                if (string.IsNullOrWhiteSpace(AuthToken))
                {
                    throw new Exception(
                        $"Login at {authBaseUrl}{loginEndpoint} returned no token. " +
                        "Verify Auth__Email / Auth__Password env vars and the auth service is running.");
                }
            }
            catch (FlurlHttpException ex)
            {
                throw new Exception(
                    $"Failed to authenticate for API tests. Status: {ex.StatusCode}. " +
                    $"Ensure the auth API is running at {authBaseUrl} and credentials are correct.", ex);
            }
        }

        public Task DisposeAsync() => Task.CompletedTask;

        public IFlurlRequest CreateAuthenticatedRequest(string path)
        {
            return new Url(BaseUrl)
                .AppendPathSegment(path)
                .WithOAuthBearerToken(AuthToken);
        }

        public IFlurlRequest CreateAnonymousRequest(string path)
        {
            return new Url(BaseUrl)
                .AppendPathSegment(path);
        }

        private string RequireConfig(string key)
        {
            var value = _configuration[key]
                ?? throw new Exception($"Missing required config key '{key}'.");

            if (value.StartsWith("REPLACE_VIA_ENV_"))
            {
                var envVar = value.Substring("REPLACE_VIA_ENV_".Length);
                throw new Exception(
                    $"Config key '{key}' still holds the placeholder. " +
                    $"Export environment variable '{envVar}' before running the tests " +
                    $"(e.g., on bash: export {envVar}=<value>; on PowerShell: $env:{envVar} = '<value>').");
            }

            return value;
        }

        private class LoginResponse
        {
            public string Token { get; set; } = string.Empty;
            public bool Success { get; set; }
        }
    }
}
