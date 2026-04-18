// Canonical template for Fixtures/ApiTestCollection.cs
// Contract: exactly this content, with %%ROOT_NAMESPACE%% substituted.

namespace %%ROOT_NAMESPACE%%.Fixtures
{
    [CollectionDefinition("ApiTests")]
    public class ApiTestCollection : ICollectionFixture<ApiTestFixture>
    {
    }
}
