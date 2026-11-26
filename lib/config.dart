import 'package:flutter/material.dart';

// Supabase connection settings (Project Settings -> API).
// ONLY the Project URL and the public (anon / publishable) key belong here.
// NEVER put the service_role key or the database password in the app.
const supabaseUrl = 'https://sfgqvndpwrviecnvjzwi.supabase.co';
const supabaseAnonKey = 'sb_publishable_wsp5BRl8iap91pp3HIGFIg_ytP3yd9Y';

/// One player who can be rated. [name] must match the CHECK in setup.sql.
class Player {
  const Player(this.name, this.photo, this.color);
  final String name;
  final String photo; // bundled in assets/images (no internet needed)
  final Color color; // national team colour
}

const players = [
  Player('Cristiano Ronaldo', 'assets/images/ronaldo.jpg', Color(0xFFE5484D)),
  Player('Lionel Messi', 'assets/images/messi.jpg', Color(0xFF6CB8F0)),
];

/// Photo credits (the photos are CC BY-SA 4.0 from Wikimedia Commons).
const photoCredits = 'Photos: Ardfern (Ronaldo) and Bryan Berlin (Messi), '
    'CC BY-SA 4.0, via Wikimedia Commons. Cropped.';
