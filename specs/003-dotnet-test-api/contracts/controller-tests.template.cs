// Canonical skeleton for Controllers/<Name>ControllerTests.cs
// Substitutions:
//   %%ROOT_NAMESPACE%%   → <Solution>.ApiTests
//   %%CONTROLLER_NAME%%  → e.g., "Order" for OrderController
//   %%BASE_PATH%%        → e.g., "/order"
//
// Rules:
//  - Class decorated with [Collection("ApiTests")]
//  - Constructor receives ApiTestFixture via DI
//  - Each [Fact] method name follows <Method>_<Condition>_ShouldReturn<Expected>
//  - Asserts use FluentAssertions (.Should()...), never Assert.Equal / Assert.True
//  - Authorized endpoints get BOTH an authenticated happy-path test AND an anonymous 401 test
//  - Complex payloads come from TestDataHelper.Create* — never inline with ≥ 2 fields

using FluentAssertions;
using Flurl.Http;
using %%ROOT_NAMESPACE%%.Fixtures;
using %%ROOT_NAMESPACE%%.Helpers;

namespace %%ROOT_NAMESPACE%%.Controllers
{
    [Collection("ApiTests")]
    public class %%CONTROLLER_NAME%%ControllerTests
    {
        private readonly ApiTestFixture _fixture;

        public %%CONTROLLER_NAME%%ControllerTests(ApiTestFixture fixture)
        {
            _fixture = fixture;
        }

        // ---- Anonymous 401 — for [Authorize] endpoints ----

        [Fact]
        public async Task Get_WithoutAuth_ShouldReturn401()
        {
            var response = await _fixture.CreateAnonymousRequest("%%BASE_PATH%%/getById/1")
                .AllowAnyHttpStatus()
                .GetAsync();

            response.StatusCode.Should().Be(401);
        }

        // ---- Authenticated happy path ----

        [Fact]
        public async Task Search_WithAuth_ShouldReturnOk()
        {
            var param = TestDataHelper.Create%%CONTROLLER_NAME%%SearchParam();

            var response = await _fixture.CreateAuthenticatedRequest("%%BASE_PATH%%/search")
                .AllowAnyHttpStatus()
                .PostJsonAsync(param);

            response.StatusCode.Should().Be(200);
        }

        // ---- Add one [Fact] per public endpoint of the controller ----
        // Name pattern: <Method>_<Condition>_ShouldReturn<Expected>
        //   e.g., GetById_WithAuth_ShouldNotReturn401
        //         Update_WithInvalidBody_ShouldReturn400
        //         Delete_WithoutAuth_ShouldReturn401
    }
}
