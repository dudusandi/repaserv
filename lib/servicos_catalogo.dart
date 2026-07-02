import 'package:flutter/material.dart';

class AppServico {
  const AppServico({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
}

const todosServicos = [
  AppServico(
    label: 'Elétrica',
    subtitle: 'Fiação, tomadas, disjuntores e iluminação',
    icon: Icons.bolt_rounded,
    color: Color(0xFFE6B88A),
  ),
  AppServico(
    label: 'Hidráulica',
    subtitle: 'Vazamentos, registros, canos e torneiras',
    icon: Icons.water_drop_rounded,
    color: Color(0xFF9BB5C2),
  ),
  AppServico(
    label: 'Construção e Reforma',
    subtitle: 'Obras, reparos, alvenaria e acabamentos',
    icon: Icons.construction_rounded,
    color: Color(0xFFA8B5A0),
  ),
  AppServico(
    label: 'Pintura',
    subtitle: 'Paredes, retoques, texturas e detalhes',
    icon: Icons.format_paint_rounded,
    color: Color(0xFFD4A5A5),
  ),
  AppServico(
    label: 'Marcenaria e Móveis',
    subtitle: 'Montagem, ajuste e reparo de móveis',
    icon: Icons.chair_rounded,
    color: Color(0xFFB8A68A),
  ),
  AppServico(
    label: 'Vidraçaria',
    subtitle: 'Box, janelas, espelhos e vidros',
    icon: Icons.window_rounded,
    color: Color(0xFFB0CBD8),
  ),
  AppServico(
    label: 'Serralheria',
    subtitle: 'Grades, portas, soldas e estruturas metálicas',
    icon: Icons.hardware_rounded,
    color: Color(0xFF8FA991),
  ),
  AppServico(
    label: 'Climatização',
    subtitle: 'Ar-condicionado, manutenção e instalação',
    icon: Icons.ac_unit_rounded,
    color: Color(0xFF9BB5C2),
  ),
  AppServico(
    label: 'Eletrodomésticos',
    subtitle: 'Máquinas, geladeiras, fogões e pequenos reparos',
    icon: Icons.kitchen_rounded,
    color: Color(0xFFD4A5A5),
  ),
  AppServico(
    label: 'Limpeza',
    subtitle: 'Limpeza padrão, pesada e pós-obra',
    icon: Icons.auto_awesome_rounded,
    color: Color(0xFF8FA991),
  ),
  AppServico(
    label: 'Jardinagem',
    subtitle: 'Poda, manutenção e cuidados com áreas verdes',
    icon: Icons.local_florist_rounded,
    color: Color(0xFFA8B5A0),
  ),
  AppServico(
    label: 'Piscinas',
    subtitle: 'Limpeza, manutenção e tratamento da água',
    icon: Icons.pool_rounded,
    color: Color(0xFF9BB5C2),
  ),
  AppServico(
    label: 'Segurança Eletrônica',
    subtitle: 'Câmeras, alarmes, sensores e cercas',
    icon: Icons.security_rounded,
    color: Color(0xFFB8A68A),
  ),
  AppServico(
    label: 'Portões e Interfones',
    subtitle: 'Motores, fechaduras, interfones e controles',
    icon: Icons.doorbell_rounded,
    color: Color(0xFFE6B88A),
  ),
  AppServico(
    label: 'Internet e Redes',
    subtitle: 'Wi-Fi, cabeamento, roteadores e sinal',
    icon: Icons.router_rounded,
    color: Color(0xFFB0CBD8),
  ),
  AppServico(
    label: 'Chaveiro',
    subtitle: 'Abertura, cópias, fechaduras e emergência',
    icon: Icons.key_rounded,
    color: Color(0xFFD4A5A5),
  ),
  AppServico(
    label: 'Impermeabilização',
    subtitle: 'Infiltrações, lajes, telhados e áreas molhadas',
    icon: Icons.water_damage_rounded,
    color: Color(0xFF8FA991),
  ),
];

const servicosDestaque = [
  AppServico(
    label: 'Hidráulica',
    subtitle: 'Vazamentos, canos e hidráulica',
    icon: Icons.water_drop_rounded,
    color: Color(0xFF9BB5C2),
  ),
  AppServico(
    label: 'Elétrica',
    subtitle: 'Fios, luzes e energia',
    icon: Icons.bolt_rounded,
    color: Color(0xFFE6B88A),
  ),
  AppServico(
    label: 'Limpeza',
    subtitle: 'Limpeza padrão ou completa',
    icon: Icons.auto_awesome_rounded,
    color: Color(0xFF8FA991),
  ),
  AppServico(
    label: 'Pintura',
    subtitle: 'Pintura geral e detalhes',
    icon: Icons.format_paint_rounded,
    color: Color(0xFFD4A5A5),
  ),
];
