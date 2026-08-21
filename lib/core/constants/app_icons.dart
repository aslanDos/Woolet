import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

enum IconGroup {
  finance('Finance'),
  food('Food'),
  emoji('Emoji'),
  buildings('Buildings'),
  education('Education'),
  beauty('Beauty'),
  health('Health'),
  shopping('Shopping'),
  home('Home'),
  utilities('Utilities'),
  sport('Sport'),
  transport('Transport'),
  travel('Travel'),
  nature('Nature'),
  work('Work'),
  entertainment('Entertainment'),
  pets('Pets'),
  other('Other');

  const IconGroup(this.label);

  final String label;
}

enum AppIcon {
  banknote('banknote', LucideIcons.banknote, .finance),
  creditCard('credit_card', LucideIcons.credit_card, .finance),
  circleDollarSign(
    'circle_dollar_sign',
    LucideIcons.circle_dollar_sign,
    .finance,
  ),
  landmark('landmark', LucideIcons.landmark, .finance),
  trendingUp('trending_up', LucideIcons.trending_up, .finance),
  wallet('wallet', LucideIcons.wallet, .finance),
  coins('coins', LucideIcons.coins, .finance),
  receipt('receipt', LucideIcons.receipt, .finance),
  piggyBank('piggy_bank', LucideIcons.piggy_bank, .finance),
  badgeDollarSign('badge_dollar_sign', LucideIcons.badge_dollar_sign, .finance),
  handCoins('hand_coins', LucideIcons.hand_coins, .finance),
  chartPie('chart_pie', LucideIcons.chart_pie, .finance),
  vault('vault', LucideIcons.vault, .finance),

  groceries('groceries', LucideIcons.shopping_cart, .food),
  cafe('cafe', LucideIcons.utensils, .food),
  coffee('coffee', LucideIcons.coffee, .food),
  pizza('pizza', LucideIcons.pizza, .food),
  sandwich('sandwich', LucideIcons.sandwich, .food),
  apple('apple', LucideIcons.apple, .food),
  cake('cake', LucideIcons.cake_slice, .food),
  cookie('cookie', LucideIcons.cookie, .food),
  soup('soup', LucideIcons.soup, .food),
  beef('beef', LucideIcons.beef, .food),
  iceCream('ice_cream', LucideIcons.ice_cream_cone, .food),
  wine('wine', LucideIcons.wine, .food),
  beer('beer', LucideIcons.beer, .food),
  milk('milk', LucideIcons.milk, .food),
  popcorn('popcorn', LucideIcons.popcorn, .food),
  candy('candy', LucideIcons.candy, .food),
  citrus('citrus', LucideIcons.citrus, .food),
  cherry('cherry', LucideIcons.cherry, .food),
  carrot('carrot', LucideIcons.carrot, .food),
  wheat('wheat', LucideIcons.wheat, .food),
  drumstick('drumstick', LucideIcons.drumstick, .food),
  fish('fish', LucideIcons.fish, .food),
  egg('egg', LucideIcons.egg, .food),
  dining('dining', LucideIcons.utensils_crossed, .food),

  smile('smile', LucideIcons.smile, .emoji),
  laugh('laugh', LucideIcons.laugh, .emoji),
  baby('baby', LucideIcons.baby, .emoji),
  heart('heart', LucideIcons.heart, .emoji),
  party('party', LucideIcons.party_popper, .emoji),

  building('building', LucideIcons.building_2, .buildings),
  factory('factory', LucideIcons.factory, .buildings),
  store('store', LucideIcons.store, .buildings),
  school('school', LucideIcons.school, .buildings),
  church('church', LucideIcons.church, .buildings),
  hotel('hotel', LucideIcons.hotel, .buildings),

  book('book', LucideIcons.book_open, .education),
  graduation('graduation', LucideIcons.graduation_cap, .education),
  library('library', LucideIcons.library, .education),
  notebook('notebook', LucideIcons.notebook_pen, .education),
  pencil('pencil', LucideIcons.pencil, .education),
  ruler('ruler', LucideIcons.ruler, .education),
  backpack('backpack', LucideIcons.backpack, .education),

  pharmacy('pharmacy', LucideIcons.pill, .beauty),
  sparkles('sparkles', LucideIcons.sparkles, .beauty),
  flower('flower', LucideIcons.flower_2, .beauty),
  scissors('scissors', LucideIcons.scissors, .beauty),
  shirt('shirt', LucideIcons.shirt, .beauty),
  spray('spray', LucideIcons.spray_can, .beauty),

  stethoscope('stethoscope', LucideIcons.stethoscope, .health),
  hospital('hospital', LucideIcons.hospital, .health),
  ambulance('ambulance', LucideIcons.ambulance, .health),
  medicalCross('medical_cross', LucideIcons.cross, .health),
  heartPulse('heart_pulse', LucideIcons.heart_pulse, .health),
  syringe('syringe', LucideIcons.syringe, .health),
  bandage('bandage', LucideIcons.bandage, .health),
  bone('bone', LucideIcons.bone, .health),
  brain('brain', LucideIcons.brain, .health),
  eye('eye', LucideIcons.eye, .health),
  glasses('glasses', LucideIcons.glasses, .health),
  accessibility('accessibility', LucideIcons.accessibility, .health),

  shopping('shopping', LucideIcons.shopping_bag, .shopping),
  shoppingBasket('shopping_basket', LucideIcons.shopping_basket, .shopping),
  package('package', LucideIcons.package, .shopping),
  tag('tag', LucideIcons.tag, .shopping),
  tags('tags', LucideIcons.tags, .shopping),
  barcode('barcode', LucideIcons.barcode, .shopping),
  discount('discount', LucideIcons.percent, .shopping),
  jewelry('jewelry', LucideIcons.gem, .shopping),
  watch('watch', LucideIcons.watch, .shopping),
  handbag('handbag', LucideIcons.handbag, .shopping),

  home('home', LucideIcons.house, .home),
  key('key', LucideIcons.key_round, .home),
  bed('bed', LucideIcons.bed_double, .home),
  armchair('armchair', LucideIcons.armchair, .home),
  lamp('lamp', LucideIcons.lamp, .home),
  washingMachine('washing_machine', LucideIcons.washing_machine, .home),
  bath('bath', LucideIcons.bath, .home),
  cookingPot('cooking_pot', LucideIcons.cooking_pot, .home),

  lightbulb('lightbulb', LucideIcons.lightbulb, .utilities),
  wifi('wifi', LucideIcons.wifi, .utilities),
  phone('phone', LucideIcons.phone, .utilities),
  powerLine('power_line', LucideIcons.utility_pole, .utilities),
  power('power', LucideIcons.circle_power, .utilities),
  heater('heater', LucideIcons.heater, .utilities),
  cooling('cooling', LucideIcons.snowflake, .utilities),
  fan('fan', LucideIcons.fan, .utilities),
  trash('trash', LucideIcons.trash_2, .utilities),
  recycle('recycle', LucideIcons.recycle, .utilities),

  dumbbell('dumbbell', LucideIcons.dumbbell, .sport),
  trophy('trophy', LucideIcons.trophy, .sport),
  medal('medal', LucideIcons.medal, .sport),
  bike('bike', LucideIcons.bike, .sport),
  volleyball('volleyball', LucideIcons.volleyball, .sport),
  goal('goal', LucideIcons.goal, .sport),
  activity('activity', LucideIcons.activity, .sport),

  fuel('fuel', LucideIcons.fuel, .transport),
  taxi('taxi', LucideIcons.car_taxi_front, .transport),
  car('car', LucideIcons.car_front, .transport),
  bus('bus', LucideIcons.bus_front, .transport),
  train('train', LucideIcons.train_front, .transport),
  plane('plane', LucideIcons.plane, .transport),
  ship('ship', LucideIcons.ship, .transport),
  parking('parking', LucideIcons.parking_meter, .transport),

  luggage('luggage', LucideIcons.luggage, .travel),
  compass('compass', LucideIcons.compass, .travel),
  globe('globe', LucideIcons.globe, .travel),
  earth('earth', LucideIcons.earth, .travel),
  map('map', LucideIcons.map, .travel),
  mapPinned('map_pinned', LucideIcons.map_pinned, .travel),
  route('route', LucideIcons.route, .travel),
  cableCar('cable_car', LucideIcons.cable_car, .travel),
  planeTakeoff('plane_takeoff', LucideIcons.plane_takeoff, .travel),
  umbrella('umbrella', LucideIcons.umbrella, .travel),
  sailboat('sailboat', LucideIcons.sailboat, .travel),

  leaf('leaf', LucideIcons.leaf, .nature),
  pineTree('pine_tree', LucideIcons.tree_pine, .nature),
  trees('trees', LucideIcons.trees, .nature),
  natureFlower('nature_flower', LucideIcons.flower, .nature),
  sun('sun', LucideIcons.sun, .nature),
  mountain('mountain', LucideIcons.mountain, .nature),
  tent('tent', LucideIcons.tent, .nature),
  waves('waves', LucideIcons.waves, .nature),

  briefcase('briefcase', LucideIcons.briefcase_business, .work),
  laptop('laptop', LucideIcons.laptop, .work),
  monitor('monitor', LucideIcons.monitor, .work),
  smartphone('smartphone', LucideIcons.smartphone, .work),
  printer('printer', LucideIcons.printer, .work),
  file('file', LucideIcons.file_text, .work),
  tools('tools', LucideIcons.wrench, .work),
  hammer('hammer', LucideIcons.hammer, .work),

  entertainment('entertainment', LucideIcons.gamepad_2, .entertainment),
  movie('movie', LucideIcons.clapperboard, .entertainment),
  film('film', LucideIcons.film, .entertainment),
  music('music', LucideIcons.music, .entertainment),
  headphones('headphones', LucideIcons.headphones, .entertainment),
  ticket('ticket', LucideIcons.ticket, .entertainment),
  camera('camera', LucideIcons.camera, .entertainment),

  dog('dog', LucideIcons.dog, .pets),
  cat('cat', LucideIcons.cat, .pets),
  paw('paw', LucideIcons.paw_print, .pets),

  gift('gift', LucideIcons.gift, .other),
  handHeart('hand_heart', LucideIcons.hand_heart, .other);

  const AppIcon(this.code, this.icon, this.group);

  final String code;
  final IconData icon;
  final IconGroup group;

  static AppIcon fromCode(String code) {
    return values.firstWhere(
      (appIcon) => appIcon.code == code,
      orElse: () => AppIcon.wallet,
    );
  }
}
