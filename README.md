# Gyan Setu (ज्ञान सेतु)

**Major project:** Ideate and implement a system to enhance the quality of education in rural areas.

Gyan Setu is a Flutter mobile app. Every screen works in **English and Hindi**, and you can switch between them at any time with the EN | हि toggle. All content works offline because it is bundled as JSON datasets.

## Features → project requirements

| Requirement | Where in the app |
|---|---|
| Study materials & mentor access | **Learn** tab (12 courses, 36 recorded classes, notes in both languages, quizzes) and **Mentors** (7 mentors, book a session, ask a doubt) |
| Monitoring skill progress | **Progress** tab: 7 skill areas, weekly activity, streak, badges, certificates |
| Bridge the digital divide | **Digital Literacy**: skills checklist, digital courses, cyber-safety tips, 1930 helpline, low-data mode |
| Grants, loans & incentives | **Grants & Loans**: 10 real government schemes, filters, eligibility checker, loan EMI calculator |
| Connectivity for disadvantaged users | **Connectivity**: nearby Wi-Fi/CSC points, sponsored data packs, device-bank application, PM-WANI/BharatNet/PM eVIDYA |
| Employment opportunities | **Jobs & Skills**: jobs and trainings with apply, plus an auto-generated resume |
| Research & development | **Research & Ideas**: community research projects, surveys, idea board |
| Access to material resources | **Resources**: borrow books, tablets, kits and lab slots, plus free e-libraries (DIKSHA, SWAYAM, ePathshala, NDL, NPTEL) |
| Communication skills | **Speak Better**: English–Hindi phrasebook, vocabulary flashcards, spoken-English courses |

## Datasets (`assets/data/`)
- `courses.json`: categories, courses, recorded-class lessons (curated Hindi YouTube class links), notes and quizzes
- `mentors.json`, `schemes.json`, `jobs.json`, `connectivity.json`, `research.json`, `resources.json`, `communication.json`

Schemes, programs and e-libraries link to their real official portals. Job listings, hotspots and mentors are illustrative demo data.

## Project structure
```
lib/
  main.dart                 app entry, theme, language
  core/
    strings.dart            all UI text (EN + HI)
    app_state.dart          user state + offline persistence (shared_preferences)
    data_repository.dart    loads JSON datasets
    theme.dart, widgets.dart
  screens/
    onboarding, home_shell, home, learn/ (courses, lesson, quiz),
    mentors, progress, digital_literacy, schemes, connectivity,
    jobs (+ resume), research, resources, communication,
    opportunities, profile
```

## Tests and CI
- `flutter test` runs 23 automated tests (`test/`: state, datasets, logic, localization, app flow).
- `.github/workflows/flutter_ci.yml` runs analyze, test and the release APK build on every push and pull request.

## Run
```bash
flutter pub get
flutter run            # on an Android device/emulator
flutter build apk      # build an APK
```
