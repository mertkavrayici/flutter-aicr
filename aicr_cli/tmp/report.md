# AICR Review Report

- Repo: **flutter-aicr**
- Created: `2025-12-29T10:33:30.260110`
- Run: `aicr_1766993610262`
- Diff hash: `sha256:a5254a268fad86e46a9f11c5848164fe425e0161527714fe33697e6d43b00e0a`
- AI enabled: `false`
- File count: `7`

## Summary

- Status: **warn**
- Rule results: pass `1`, warn `2`, fail `0`

## Findings

### Quality

- 💡 **UI changes may benefit from golden tests**
  - Location: `lib/features/dashboard/presentation/bloc/dashboard_bloc.dart`
  - TR: UI bileşenlerinde değişiklik var. Golden test veya widget test ile kritik ekranları sabitlemeyi düşünebilirsin.
  - EN: UI components changed. Consider adding golden/widget tests to lock down critical screens.

### Testing

- ⚠️ **BLoC changes should include tests**
  - Location: `lib/features/dashboard/presentation/bloc/dashboard_bloc.dart`
  - TR: BLoC dosyalarında değişiklik var ancak test değişikliği tespit edilmedi.
  - EN: BLoC files changed but no test change was detected.


## Changed files

- `modified` `lib/features/dashboard/domain/use_cases/get_dashboard_summary_uc.dart`
- `modified` `lib/features/dashboard/presentation/bloc/dashboard_bloc.dart`
- `modified` `lib/features/dashboard/presentation/components/dashboard_header.dart`
- `modified` `lib/features/dashboard/presentation/components/dashboard_shell.dart`
- `modified` `lib/features/dashboard/presentation/components/summary_stat_card.dart`
- `modified` `lib/features/dashboard/presentation/pages/dashboard_page.dart`
- `modified` `lib/features/transactions/data/seeding/transaction_seeder.dart`