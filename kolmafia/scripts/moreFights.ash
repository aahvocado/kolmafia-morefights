/*
  Version 1.1
    by dextrial

  todo:
    - Calculate the Universe
    - School of Hard Knocks Diploma
    - Rotten tomato
    - check if LED clock is already in camp
 */

string[] extraFightsList = {
  "Shot of Kardashian Gin",
  "5-hour acrimony",
  "Phonus Balonus",
  "beery blood",
  "slap and slap again",
  "used beer",
  "shot of flower schnapps",

  "angst burger",
  "devil dog",
  "gunpowder burrito",
  "fettucini épines Inconnu",
  "nailswurst",
  "flower petal pie",

  "cuppa Cruel tea",
  "Five Second Energy™",
  "Purple Beast energy drink",
  "watered-down Red Minotaur",
  "can of Red Minotaur",
  "Hatorade",
};

int amount_consummable(item it) {
  boolean ignoreBooze = it.inebriety == 0;
  boolean ignoreFood = it.fullness == 0;
  boolean ignoreSpleen = it.spleen == 0;

  int inebrietyAvailable = inebriety_limit() - my_inebriety();
  if (!ignoreBooze && it.inebriety > inebrietyAvailable) {
    return 0;
  }

  int fullnessAvailable = fullness_limit() - my_fullness();
  if (!ignoreFood && it.fullness > fullnessAvailable) {
    return 0;
  }

  int spleenAvailable = spleen_limit() - my_spleen_use();
  if (!ignoreSpleen && it.spleen > spleenAvailable) {
    return 0;
  }

  int spleenAmount = ignoreSpleen ? 0 : truncate(spleenAvailable / it.spleen);
  if (!ignoreSpleen) {
    return spleenAmount;
  }

  int drinkableAmount = ignoreBooze ? 0 : truncate(inebrietyAvailable / it.inebriety);
  int edibleAmount = ignoreFood ? 0 : truncate(fullnessAvailable / it.fullness);

  if (ignoreBooze) {
    return edibleAmount;
  } else if (ignoreFood) {
    return drinkableAmount;
  }

  // some weird case where it requires both drunkenness and fullness
  return min(edibleAmount, drinkableAmount);
}
// primary `get_suggested_amount()`
int get_suggested_amount(int available, int limit, int used) {
  int suggested = limit - used;
  if (suggested > available) {
    return available;
  }
  return suggested;
}
int get_suggested_amount(item it, int limit, int used) {
  int available = available_amount(it);
  return get_suggested_amount(available, limit, used);
}
int get_suggested_amount(string itemname, int limit, int used) {
  item it = to_item(itemname);
  return get_suggested_amount(it, limit, used);
}
//
int print_other_sources() {
  int suggested = 0;

  if (have_familiar($familiar[Robortender]) && my_adventures() > 10) {
    print('• you could spend time with your Robortender - faster if you equip toggle switch (bounce)!', 'green');
    suggested += 1;
  }

  if (have_familiar($familiar[Artistic Goth Kid]) && my_adventures() > 5) {
    print('• you could spend time with your Artistic Goth Kid - faster if you equip little wooden mannequin!', 'green');
    suggested += 1;
  }

  return suggested;
}
// primary `print_suggested_amount()`
int print_suggested_amount(item it, int limit, int used, boolean forceSuggest, string fightGainText) {
  string actionname = 'use';
  if (it.inebriety > 0 && it.fullness > 0) {
    actionname = 'eat/drink';
  } else if (it.inebriety > 0) {
    actionname = 'drink';
  } else if (it.fullness > 0) {
    actionname = 'eat';
  } else if (it.spleen > 0) {
    actionname = 'chew';
  } else {
    actionname = 'use';
  }

  int suggested = get_suggested_amount(it, limit, used);
  if (suggested > 0) {
    print('• you could ' + actionname + ' ' + suggested + ' ' + it.name + ' ' + fightGainText, 'green');
  }

  int possible = limit - used;
  if (forceSuggest && suggested <= 0 && possible > 0) {
    print('• you don\'t have any, but you can ' + actionname + ' ' + possible + ' ' + it.name, 'green');
    return possible;
  }

  return suggested;
}
int print_suggested_amount(item it, int limit, int used, boolean forceSuggest) {
  boolean hasPVPtext = index_of(it.notes.to_lower_case(), 'pvp fight') >= 0;
  if (hasPVPtext) {
    string fightGainText = '(' + it.notes + ')';
    return print_suggested_amount(it, limit, used, forceSuggest, fightGainText);
  }

  return print_suggested_amount(it, limit, used, forceSuggest, '');
}
int print_suggested_amount(item it, int limit, string propertyname, boolean forceSuggest, string fightGainText) {
  string property = get_property(propertyname);
  if (property == 'false') {
    return print_suggested_amount(it, limit, 0, forceSuggest, fightGainText);
  } else if (property == 'true') {
    return print_suggested_amount(it, limit, 1, forceSuggest, fightGainText);
  } else {
    return print_suggested_amount(it, limit, property.to_int(), forceSuggest, fightGainText);
  }
}
int print_suggested_amount(item it, int limit, string propertyname, boolean forceSuggest) {
  return print_suggested_amount(it, limit, propertyname, forceSuggest, '');
}
int print_suggested_amount(string itemname, int limit, string propertyname, boolean forceSuggest, string fightGainText) {
  item it = to_item(itemname);
  return print_suggested_amount(it, limit, propertyname, forceSuggest, fightGainText);
}
int print_suggested_amount(string itemname, int limit, string propertyname, boolean forceSuggest) {
  item it = to_item(itemname);
  return print_suggested_amount(it, limit, propertyname, forceSuggest);
}
int print_suggested_amount(string itemname, int limit, string propertyname) {
  return print_suggested_amount(itemname, limit, propertyname, false);
}
int print_suggested_amount(item it, int limit, string propertyname) {
  return print_suggested_amount(it, limit, propertyname, false);
}
int print_suggested_amount(item it, int limit, int used) {
  return print_suggested_amount(it, limit, used, false);
}
void main() {
  print('Time for more PVP fights!', 'purple');
  int totalsuggestions = 0;

  boolean canCheatDeck = (15 - get_property("_deckCardsDrawn").to_int()) >= 5;
  boolean hasUsedClubs = contains_text(get_property("_deckCardsSeen"), 'Clubs');
  if (canCheatDeck && !hasUsedClubs) {
    totalsuggestions += 1;
    print('• you could ' + '"cheat Clubs"', 'green');
  }

  boolean hasSparred = get_property("_daycareFights").to_boolean();
  if (!hasSparred) {
    totalsuggestions += 1;
    print('• you could spar at the Boxing Daycare (+x PvP fights)', 'green');
  }

  totalsuggestions += print_suggested_amount("CSA fire-starting kit", 1, "_fireStartingKitUsed", true, '(+3 PvP fights)');
  totalsuggestions += print_suggested_amount("Meteorite-Ade", 3, "_meteoriteAdesUsed", false, '(+3 PvP fights)');
  totalsuggestions += print_suggested_amount("Daily Affirmation: Keep Free Hate in your Heart", 1, "_affirmationHateUsed", false, '(+3 PvP fights)');
  totalsuggestions += print_suggested_amount("Jerks' Health™ Magazine", 5, "_jerksHealthMagazinesUsed", false, '(+5 PvP fights)');
  totalsuggestions += print_suggested_amount("confusing LED clock", 1, "_confusingLEDClockUsed", false,, '(+5 PvP fights, -5 adventures)');

  foreach idx, consummablename in extraFightsList {
    item consummableItem = to_item(consummablename);
    totalsuggestions += print_suggested_amount(consummableItem, amount_consummable(consummableItem), 0);
  }

  totalsuggestions += print_other_sources();

  if (totalsuggestions == 0) {
    print('...looks like there might not be any fight granting thing available for you :(', 'purple');
  }
}
