# Ronaldo or Messi?

A live feedback app: students scan a QR code, choose **Cristiano Ronaldo** or **Lionel Messi**, give 1 to 5 stars and an optional comment. The projector screen shows each player's photo, average rating, vote count and comments in real time.

- Front end: Flutter web (two screens: `#/` rate form, `#/wall` live results)
- Back end: Supabase (table `player_feedback`, Row Level Security, Realtime)
- Hosting: GitHub Pages, built by GitHub Actions on every push to `main`

Database: `supabase/setup.sql`. The Supabase URL and public key are in `lib/config.dart` (the public key is safe to publish; never put a secret key here).

Photos (bundled in `assets/images`, details in `credits.json`): Ardfern (Ronaldo) and Bryan Berlin (Messi), CC BY-SA 4.0, via Wikimedia Commons.

Run locally: `flutter run -d chrome`

Fonts (bundled): Roboto, Noto Emoji and Noto Sans Arabic (SIL Open Font License), so emoji and Kurdish / Arabic comments display without any outside website.
