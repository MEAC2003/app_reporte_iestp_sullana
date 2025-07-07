import 'package:flutter/material.dart';
import 'package:app_reporte_iestp_sullana/utils/utils.dart';

class ReportsStatsRow extends StatelessWidget {
  final int resueltos;
  final int sinAtender;
  final int enProceso;
  final int enEspera;

  const ReportsStatsRow({
    super.key,
    required this.resueltos,
    required this.sinAtender,
    required this.enProceso,
    required this.enEspera,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: _StatCard(
                title: 'Reportes resueltos',
                value: resueltos.toString(),
                icon: Icons.check_circle,
              ),
            ),
            SizedBox(width: AppSize.defaultPadding),
            Expanded(
              child: _StatCard(
                title: 'Reportes sin atender',
                value: sinAtender.toString(),
                icon: Icons.report_problem,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSize.defaultPadding),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: _StatCard(
                title: 'Reportes en proceso',
                value: enProceso.toString(),
                icon: Icons.sync,
              ),
            ),
            SizedBox(width: AppSize.defaultPadding),
            Expanded(
              child: _StatCard(
                title: 'Reportes en espera',
                value: enEspera.toString(),
                icon: Icons.hourglass_empty,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primarySkyBlue,
      borderRadius: BorderRadius.circular(AppSize.defaultRadius * 2),
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.3),
      child: Container(
        width: 130,
        constraints: BoxConstraints(minHeight: 100, maxHeight: 120),
        padding: EdgeInsets.all(AppSize.defaultPadding * 0.8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: AppSize.defaultIconSize * 0.6,
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: AppStyles.h3p5(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 2),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.h5(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ).copyWith(letterSpacing: -0.5),
            ),
          ],
        ),
      ),
    );
  }
}
