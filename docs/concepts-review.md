# CI/CD Laboratory Concepts Review

## Part A - Short Answer

25. Continuous Integration automatically checks new code by formatting, analyzing, and testing it whenever changes are pushed. Continuous Delivery extends that by preparing a usable build artifact after checks pass. In this pipeline, the analyze and test jobs are CI, while the debug and release APK build jobs are CD.

26. The test job uses `needs: analyze` so tests only run after formatting and static analysis pass. If that dependency were removed, tests could run at the same time as analysis, which wastes runner time when the code already has formatting or analyzer errors.

27. The keystore is never committed because it contains the private signing key for the Android app. If it were exposed, another person could sign APKs as if they came from the real developer or app owner.

28. The `if: github.ref == 'refs/heads/main' && github.event_name == 'push'` condition prevents signed release builds from running on pull requests or development branches. It limits release APK creation to direct pushes on `main`.

29. `cache: true` lets the Flutter GitHub Action reuse downloaded Flutter SDK files between workflow runs. This reduces setup time and makes repeated CI runs faster for developers.

## Part B - Analysis

30. If a teammate pushes code that breaks one widget test, the analyze job runs first. If analysis passes, the test job starts, the unit tests may pass, and the widget test command fails. The debug and release build jobs do not run because they depend on the test job, so the teammate should read the failed widget test log, fix the code or test, run `flutter test` locally, and push the fix.

31. Local testing is useful, but it is not enough for team projects because people can forget steps, use different tool versions, or accidentally push untested changes. CI/CD gives the team one shared automated quality gate that runs the same checks every time. It also creates a record of which commit passed or failed, making problems easier to trace.

32. To support iOS builds, the pipeline needs a macOS runner such as `macos-latest` because iOS builds require Xcode. It would also need iOS signing setup, including Apple certificates, provisioning profiles, and GitHub Secrets for those credentials. The workflow would then add a job that runs Flutter dependencies and builds the iOS app or IPA on the macOS runner.
