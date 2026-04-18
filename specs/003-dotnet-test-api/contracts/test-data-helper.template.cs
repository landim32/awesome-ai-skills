// Canonical shell for Helpers/TestDataHelper.cs
// At boot (US1), this file is created with JUST the shell below.
// Factory methods are appended on-demand when a controller is added (US2, Q5).
//
// Naming: Create<DtoName>(...) — one method per DTO type used across the test suite.
// No orphan factories: every method present MUST be referenced by at least one
// Controllers/*Tests.cs file (SC-006).

%%OPTIONAL_USINGS_FOR_DETECTED_DTO_PROJECT%%

namespace %%ROOT_NAMESPACE%%.Helpers
{
    public static class TestDataHelper
    {
        // Factories are added on-demand. Keep this file sorted alphabetically by
        // factory name for readability.
    }
}
