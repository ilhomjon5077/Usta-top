import 'package:flutter/material.dart';

import '../models/usta.dart';


const kategoriyalar = <Kategoriya>[
  Kategoriya('santexnik', 'Santexnik', Icons.plumbing),
  Kategoriya('elektrik', 'Elektrik', Icons.electrical_services),
  Kategoriya('duradgor', 'Duradgor', Icons.carpenter),
  Kategoriya('boyoqchi', "Bo'yoqchi", Icons.format_paint_outlined),
  Kategoriya('konditsioner', 'Konditsioner', Icons.ac_unit),
  Kategoriya('payvandchi', 'Payvandchi', Icons.local_fire_department_outlined),
  Kategoriya('kafelchi', 'Kafelchi', Icons.grid_view_rounded),
  Kategoriya('mebelchi', 'Mebelchi', Icons.chair_outlined),
];

/// Namuna ustalar olib tashlandi: ro'yxatda faqat ilovada o'zi ro'yxatdan
/// o'tgan haqiqiy ustalar ko'rinadi.
const namunaUstalar = <Usta>[];
