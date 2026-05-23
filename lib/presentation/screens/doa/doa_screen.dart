import 'dart:ui';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';

class DoaScreen extends ConsumerStatefulWidget {
  const DoaScreen({super.key});

  @override
  ConsumerState<DoaScreen> createState() => _DoaScreenState();
}

class _DoaScreenState extends ConsumerState<DoaScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final gradients = theme.extension<GradientColors>()!;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradients.appBarGradient,
            ),
            border: Border(
              bottom: BorderSide(color: gradients.appBarBorder, width: 1.5),
            ),
          ),
        ),
        elevation: 0,
        titleSpacing: 16,
        title: Text(
          'tab_dua'.tr(),
          style: TextStyle(
            color: cs.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          // Background
          Positioned.fill(child: _buildBackground(context)),
          // Content
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
            children: [
              // How it works
              _buildInfoSection(
                icon: Icons.calculate_outlined,
                title: 'daily_amal_info_how_title'.tr(),
                content: 'daily_amal_info_how_body'.tr(),
              ),
              const SizedBox(height: 20),

              // Morning-Evening Adhkar Section (Expandable)
              _buildExpandableDuaSection(),
              const SizedBox(height: 18),

              // Miswak section
              _buildSectionHeader(
                icon: Icons.brush,
                title: 'daily_amal_info_miswak_section'.tr(),
              ),
              const SizedBox(height: 12),
              _buildHadithCard(
                hadith: 'daily_amal_info_miswak_hadith1_text'.tr(),
                reference: 'daily_amal_info_miswak_hadith1_ref'.tr(),
              ),
              const SizedBox(height: 12),
              _buildHadithCard(
                hadith: 'daily_amal_info_miswak_hadith2_text'.tr(),
                reference: 'daily_amal_info_miswak_hadith2_ref'.tr(),
              ),
              const SizedBox(height: 18),

              // Surah section
              _buildSectionHeader(
                icon: Icons.menu_book,
                title: 'daily_amal_info_surah_section'.tr(),
              ),
              const SizedBox(height: 12),
              _buildHadithCard(
                hadith: 'daily_amal_info_surah_hadith1_text'.tr(),
                reference: 'daily_amal_info_surah_hadith1_ref'.tr(),
              ),
              const SizedBox(height: 12),
              _buildHadithCard(
                hadith: 'daily_amal_info_surah_hadith2_text'.tr(),
                reference: 'daily_amal_info_surah_hadith2_ref'.tr(),
              ),
              const SizedBox(height: 12),
              _buildHadithCard(
                hadith: 'daily_amal_info_surah_hadith3_text'.tr(),
                reference: 'daily_amal_info_surah_hadith3_ref'.tr(),
              ),
              const SizedBox(height: 18),

              // Dua section
              _buildSectionHeader(
                icon: Icons.favorite,
                title: 'daily_amal_info_dua_section'.tr(),
              ),
              const SizedBox(height: 12),
              _buildHadithCard(
                hadith: 'daily_amal_info_dua_hadith1_text'.tr(),
                reference: 'daily_amal_info_dua_hadith1_ref'.tr(),
              ),
              const SizedBox(height: 12),
              _buildHadithCard(
                hadith: 'daily_amal_info_dua_hadith2_text'.tr(),
                reference: 'daily_amal_info_dua_hadith2_ref'.tr(),
              ),
              const SizedBox(height: 12),
              _buildHadithCard(
                hadith: 'daily_amal_info_dua_hadith3_text'.tr(),
                reference: 'daily_amal_info_dua_hadith3_ref'.tr(),
              ),
              const SizedBox(height: 18),

              // Nafal prayer section
              _buildSectionHeader(
                icon: Icons.mosque,
                title: 'daily_amal_info_nafl_section'.tr(),
              ),
              const SizedBox(height: 12),
              _buildHadithCard(
                hadith: 'daily_amal_info_nafl_hadith1_text'.tr(),
                reference: 'daily_amal_info_nafl_hadith1_ref'.tr(),
              ),
              const SizedBox(height: 12),
              _buildHadithCard(
                hadith: 'daily_amal_info_nafl_hadith2_text'.tr(),
                reference: 'daily_amal_info_nafl_hadith2_ref'.tr(),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Background ───
  Widget _buildBackground(BuildContext context) {
    final theme = Theme.of(context);
    final gradients = theme.extension<GradientColors>()!;
    final isDark = theme.brightness == Brightness.dark;
    const gold = Color(0xFFD4AF37);

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradients.backgroundGradient,
            ),
          ),
        ),
        Positioned(
          top: -140,
          right: -120,
          child: _glowBlob(size: 280, opacity: isDark ? 0.14 : 0.07),
        ),
        Positioned(
          bottom: -160,
          left: -140,
          child: _glowBlob(size: 320, opacity: isDark ? 0.10 : 0.05),
        ),
      ],
    );
  }

  Widget _glowBlob({required double size, required double opacity}) {
    const gold = Color(0xFFD4AF37);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [gold.withOpacity(opacity), Colors.transparent],
        ),
      ),
    );
  }

  // ─── Info Section ───
  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    final cs = Theme.of(context).colorScheme;

    return buildPremiumCard(
      context: context,
      radius: 18,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: cs.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: cs.primary,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 14,
                height: 1.7,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Section Header ───
  Widget _buildSectionHeader({required IconData icon, required String title}) {
    final cs = Theme.of(context).colorScheme;

    return buildPremiumCard(
      context: context,
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(
                context,
              ).extension<GradientColors>()!.onPrimaryText,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: cs.primary,
                fontSize: 16.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Hadith Card ───
  Widget _buildHadithCard({required String hadith, required String reference}) {
    final cs = Theme.of(context).colorScheme;

    return buildPremiumCard(
      context: context,
      radius: 18,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.format_quote_rounded,
                  color: cs.primary,
                  size: 14,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hadith,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 14,
                    height: 1.65,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.book_outlined,
                size: 18,
                color: cs.primary.withOpacity(0.75),
              ),
              const SizedBox(width: 5),
              Text(
                reference,
                style: TextStyle(
                  color: cs.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Expandable Morning-Evening Dua Section ───
  Widget _buildExpandableDuaSection() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return buildPremiumCard(
      context: context,
      radius: 18,
      padding: EdgeInsets.zero,
      child: Theme(
        data: theme.copyWith(dividerColor: cs.surface.withOpacity(0)),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.wb_twilight, color: cs.primary, size: 20),
          ),
          title: Text(
            'daily_amal_adhkar_title'.tr(),
            style: TextStyle(
              color: cs.primary,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'daily_amal_adhkar_subtitle'.tr(),
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
            ),
          ),
          iconColor: cs.primary,
          collapsedIconColor: cs.primary,
          children: [
            const SizedBox(height: 12),

            // Beautiful heading
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.primary.withOpacity(0.12),
                    cs.primary.withOpacity(0.04),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: cs.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Decorative top line
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                cs.primary.withOpacity(0),
                                cs.primary.withOpacity(0.4),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(
                          Icons.auto_awesome,
                          color: cs.primary.withOpacity(0.6),
                          size: 16,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                cs.primary.withValues(alpha: 0.4),
                                cs.primary.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Bismillah
                  Text(
                    'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: cs.primary,
                      fontSize: 18,
                      fontFamily: 'Amiri',
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Main title
                  Text(
                    'daily_amal_adhkar_main_title'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: cs.primary,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      height: 1.5,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Divider
                  Container(
                    width: 40,
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: cs.primary.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Author
                  Text(
                    'daily_amal_adhkar_author'.tr(),
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'daily_amal_adhkar_note'.tr(),
                    style: TextStyle(
                      color: cs.primary.withOpacity(0.3),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Decorative bottom line
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                cs.primary.withOpacity(0),
                                cs.primary.withOpacity(0.4),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(
                          Icons.auto_awesome,
                          color: cs.primary.withOpacity(0.6),
                          size: 16,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                cs.primary.withOpacity(0.4),
                                cs.primary.withOpacity(0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Dhikr 1: Ayatul Kursi
            _buildExpandableDuaCard(
              title: 'dhikr_morning_1_title'.tr(),
              arabic:
                  'اَللّٰهُ لَاۤ اِلٰهَ اِلَّا هُوَ ۚ اَلْحَيُّ الْقَيُّوْمُ ۚ لَا تَاْخُذُهٗ سِنَةٌ وَّلَا نَوْمٌ ۚ لَهٗ مَا فِي السَّمٰوٰتِ وَمَا فِي الْاَرْضِ ۗ مَنْ ذَا الَّذِيْ يَشْفَعُ عِنْدَهٗٓ اِلَّا بِاِذْنِهٖ ۗ يَعْلَمُ مَا بَيْنَ اَيْدِيْهِمْ وَمَا خَلْفَهُمْ ۚ وَلَا يُحِيْطُوْنَ بِشَيْءٍ مِّنْ عِلْمِهٖٓ اِلَّا بِمَا شَاۤءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمٰوٰتِ وَالْاَرْضَ ۚ وَلَا يَئُوْدُهٗ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيْمُ',
              pronunciation: 'dhikr_morning_1_pron'.tr(),
              meaning: 'dhikr_morning_1_meaning'.tr(),
              reference: 'dhikr_morning_1_ref'.tr(),
              fazilat: 'dhikr_morning_1_fazilat'.tr(),
              count: 'dhikr_morning_1_count'.tr(),
            ),
            const SizedBox(height: 14),

            // Dhikr 2: 3 Qul
            _buildExpandableDuaCard(
              title: 'dhikr_morning_2_title'.tr(),
              arabic:
                  'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ\nقُلْ هُوَ اللّٰهُ اَحَدٌ ۚ اَللّٰهُ الصَّمَدُ ۚ لَمْ يَلِدْ وَلَمْ يُوْلَدْ ۙ وَلَمْ يَكُنْ لَّهٗ كُفُوًا اَحَدٌ\n\nبِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ\nقُلْ اَعُوْذُ بِرَبِّ الْفَلَقِ ۙ مِنْ شَرِّ مَا خَلَقَ ۙ وَمِنْ شَرِّ غَاسِقٍ اِذَا وَقَبَ ۙ وَمِنْ شَرِّ النَّفّٰثٰتِ فِي الْعُقَدِ ۙ وَمِنْ شَرِّ حَاسِدٍ اِذَا حَسَدَ\n\nبِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ\nقُلْ اَعُوْذُ بِرَبِّ النَّاسِ ۙ مَلِكِ النَّاسِ ۙ اِلٰهِ النَّاسِ ۙ مِنْ شَرِّ الْوَسْوَاسِ  الْخَنَّاسِ ۖ الَّذِيْ يُوَسْوِسُ فِيْ صُدُوْرِ النَّاسِ ۙ مِنَ الْجِنَّةِ وَالنَّاسِ',
              pronunciation: 'dhikr_morning_2_pron'.tr(),
              meaning: 'dhikr_morning_2_meaning'.tr(),
              reference: 'dhikr_morning_2_ref'.tr(),
              fazilat: 'dhikr_morning_2_fazilat'.tr(),
              count: 'dhikr_morning_2_count'.tr(),
            ),
            const SizedBox(height: 14),

            // Dhikr 3
            _buildExpandableDuaCard(
              title: 'dhikr_morning_3_title'.tr(),
              arabic:
                  'حَسْبِيَ اللّٰهُ لَاۤ اِلٰهَ اِلَّا هُوَ ؕ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيْمِ',
              pronunciation: 'dhikr_morning_3_pron'.tr(),
              meaning: 'dhikr_morning_3_meaning'.tr(),
              reference: 'dhikr_morning_3_ref'.tr(),
              fazilat: 'dhikr_morning_3_fazilat'.tr(),
              count: 'dhikr_morning_3_count'.tr(),
            ),
            const SizedBox(height: 14),

            // Dhikr 4
            _buildExpandableDuaCard(
              title: 'dhikr_morning_4_title'.tr(),
              arabic:
                  'اَللّٰهُمَّ اَنْتَ رَبِّيْ لَاۤ اِلٰهَ اِلَّاۤ اَنْتَ ؕ خَلَقْتَنِيْ وَاَنَا عَبْدُكَ وَاَنَا عَلٰى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ ۚ اَعُوْذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ ۚ اَبُوْءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَاَبُوْءُ بِذَنْبِيْ فَاغْفِرْ لِيْ فَاِنَّهٗ لَا يَغْفِرُ الذُّنُوْبَ اِلَّاۤ اَنْتَ',
              pronunciation: 'dhikr_morning_4_pron'.tr(),
              meaning: 'dhikr_morning_4_meaning'.tr(),
              reference: 'dhikr_morning_4_ref'.tr(),
              fazilat: 'dhikr_morning_4_fazilat'.tr(),
              count: 'dhikr_morning_4_count'.tr(),
            ),
            const SizedBox(height: 14),

            // Dhikr 5
            _buildExpandableDuaCard(
              title: 'dhikr_morning_5_title'.tr(),
              arabic:
                  'بِسْمِ اللّٰهِ الَّذِيْ لَا يَضُرُّ مَعَ اسْمِهٖ شَيْءٌ فِي الْاَرْضِ وَلَا فِي السَّمَاۤءِ وَهُوَ السَّمِيْعُ الْعَلِيْمُ',
              pronunciation: 'dhikr_morning_5_pron'.tr(),
              meaning: 'dhikr_morning_5_meaning'.tr(),
              reference: 'dhikr_morning_5_ref'.tr(),
              fazilat: 'dhikr_morning_5_fazilat'.tr(),
              count: 'dhikr_morning_5_count'.tr(),
            ),
            const SizedBox(height: 14),

            // Dhikr 6
            _buildExpandableDuaCard(
              title: 'dhikr_morning_6_title'.tr(),
              arabic:
                  'لَاۤ اِلٰهَ اِلَّا اللّٰهُ وَحْدَهٗ لَا شَرِيْكَ لَهٗ ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلٰى كُلِّ شَيْءٍ قَدِيْرٌ',
              pronunciation: 'dhikr_morning_6_pron'.tr(),
              meaning: 'dhikr_morning_6_meaning'.tr(),
              reference: 'dhikr_morning_6_ref'.tr(),
              fazilat: 'dhikr_morning_6_fazilat'.tr(),
              count: 'dhikr_morning_6_count'.tr(),
            ),
            const SizedBox(height: 14),

            // Dhikr 7
            _buildExpandableDuaCard(
              title: 'dhikr_morning_7_title'.tr(),
              arabic: 'اَللّٰهُمَّ اَجِرْنِيْ مِنَ النَّارِ',
              pronunciation: 'dhikr_morning_7_pron'.tr(),
              meaning: 'dhikr_morning_7_meaning'.tr(),
              reference: 'dhikr_morning_7_ref'.tr(),
              fazilat: 'dhikr_morning_7_fazilat'.tr(),
              count: 'dhikr_morning_7_count'.tr(),
            ),
            const SizedBox(height: 14),

            // Dhikr 8
            _buildExpandableDuaCard(
              title: 'dhikr_morning_8_title'.tr(),
              arabic:
                  'اَللّٰهُمَّ اِنِّيْۤ اَسْاَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْاٰخِرَةِ ، اَللّٰهُمَّ اِنِّيْۤ اَسْاَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِيْ دِيْنِيْ وَدُنْيَايَ وَاَهْلِيْ وَمَالِيْ ، اَللّٰهُمَّ اسْتُرْ عَوْرٰتِيْ وَاٰمِنْ رَوْعٰتِيْ ، اَللّٰهُمَّ احْفَظْنِيْ مِنْ بَيْنِ يَدَيَّ وَمِنْ خَلْفِيْ وَعَنْ يَّمِيْنِيْ وَعَنْ شِمَالِيْ وَمِنْ فَوْقِيْ وَاَعُوْذُ بِعَظَمَتِكَ اَنْ اُغْتَالَ مِنْ تَحْتِيْ',
              pronunciation: 'dhikr_morning_8_pron'.tr(),
              meaning: 'dhikr_morning_8_meaning'.tr(),
              reference: 'dhikr_morning_8_ref'.tr(),
              fazilat: 'dhikr_morning_8_fazilat'.tr(),
              count: 'dhikr_morning_8_count'.tr(),
            ),
            const SizedBox(height: 14),

            // Dhikr 9
            _buildExpandableDuaCard(
              title: 'dhikr_morning_9_title'.tr(),
              arabic:
                  'اَللّٰهُمَّ اِنِّيْۤ اَصْبَحْتُ اُشْهِدُكَ وَاُشْهِدُ حَمَلَةَ عَرْشِكَ وَمَلٰٓئِكَتَكَ وَجَمِيْعَ خَلْقِكَ ، بِاَنَّكَ اَنْتَ اللّٰهُ لَاۤ اِلٰهَ اِلَّاۤ اَنْتَ وَحْدَكَ لَا شَرِيْكَ لَكَ وَاَنَّ مُحَمَّدًا عَبْدُكَ وَرَسُوْلُكَ',
              pronunciation: 'dhikr_morning_9_pron'.tr(),
              meaning: 'dhikr_morning_9_meaning'.tr(),
              reference: 'dhikr_morning_9_ref'.tr(),
              fazilat: 'dhikr_morning_9_fazilat'.tr(),
              count: 'dhikr_morning_9_count'.tr(),
            ),
            const SizedBox(height: 14),

            // Dhikr 10
            _buildExpandableDuaCard(
              title: 'dhikr_morning_10_title'.tr(),
              arabic:
                  'اَعُوْذُ بِكَلِمٰتِ اللّٰهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
              pronunciation: 'dhikr_morning_10_pron'.tr(),
              meaning: 'dhikr_morning_10_meaning'.tr(),
              reference: 'dhikr_morning_10_ref'.tr(),
              fazilat: 'dhikr_morning_10_fazilat'.tr(),
              count: 'dhikr_morning_10_count'.tr(),
            ),
            const SizedBox(height: 14),

            // Dhikr 11
            _buildExpandableDuaCard(
              title: 'dhikr_morning_11_title'.tr(),
              arabic:
                  'اَللّٰهُمَّ عَافِنِيْ فِيْ بَدَنِيْ ، اَللّٰهُمَّ عَافِنِيْ فِيْ سَمْعِيْ ، اَللّٰهُمَّ عَافِنِيْ فِيْ بَصَرِيْ ، لَاۤ اِلٰهَ اِلَّاۤ اَنْتَ ، اَللّٰهُمَّ اِنِّيْۤ اَعُوْذُ بِكَ مِنَ الْكُفْرِ وَالْفَقْرِ ، اَللّٰهُمَّ اِنِّيْۤ اَعُوْذُ بِكَ مِنْ عَذَابِ الْقَبْرِ ، لَاۤ اِلٰهَ اِلَّاۤ اَنْتَ',
              pronunciation: 'dhikr_morning_11_pron'.tr(),
              meaning: 'dhikr_morning_11_meaning'.tr(),
              reference: 'dhikr_morning_11_ref'.tr(),
              fazilat: 'dhikr_morning_11_fazilat'.tr(),
              count: 'dhikr_morning_11_count'.tr(),
            ),
            const SizedBox(height: 14),

            // Dhikr 12
            _buildExpandableDuaCard(
              title: 'dhikr_morning_12_title'.tr(),
              arabic:
                  'اَصْبَحْنَا وَاَصْبَحَ الْمُلْكُ لِلّٰهِ وَالْحَمْدُ لِلّٰهِ ، لَاۤ اِلٰهَ اِلَّا اللّٰهُ وَحْدَهٗ لَا شَرِيْكَ لَهٗ ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلٰى كُلِّ شَيْءٍ قَدِيْرٌ ، رَبِّ اَسْاَلُكَ خَيْرَ مَا فِيْ هٰذَا الْيَوْمِ وَخَيْرَ مَا بَعْدَهٗ ، وَاَعُوْذُ بِكَ مِنْ شَرِّ مَا فِيْ هٰذَا الْيَوْمِ وَشَرِّ مَا بَعْدَهٗ ، رَبِّ اَعُوْذُ بِكَ مِنَ الْكَسَلِ وَسُوْٓءِ الْكِبَرِ ، رَبِّ اَعُوْذُ بِكَ مِنْ عَذَابٍ فِي النَّارِ وَعَذَابٍ فِي الْقَبْرِ',
              pronunciation: 'dhikr_morning_12_pron'.tr(),
              meaning: 'dhikr_morning_12_meaning'.tr(),
              reference: 'dhikr_morning_12_ref'.tr(),
              fazilat: 'dhikr_morning_12_fazilat'.tr(),
              count: 'dhikr_morning_12_count'.tr(),
            ),
            const SizedBox(height: 14),

            // Dhikr 13
            _buildExpandableDuaCard(
              title: 'dhikr_morning_13_title'.tr(),
              arabic: 'سُبْحَانَ اللّٰهِ وَبِحَمْدِهٖ',
              pronunciation: 'dhikr_morning_13_pron'.tr(),
              meaning: 'dhikr_morning_13_meaning'.tr(),
              reference: 'dhikr_morning_13_ref'.tr(),
              fazilat: 'dhikr_morning_13_fazilat'.tr(),
              count: 'dhikr_morning_13_count'.tr(),
            ),
            const SizedBox(height: 14),

            // Dhikr 14
            _buildExpandableDuaCard(
              title: 'dhikr_morning_14_title'.tr(),
              arabic:
                  'اَللّٰهُمَّ فَاطِرَ السَّمٰوٰتِ وَالْاَرْضِ عَالِمَ الْغَيْبِ وَالشَّهَادَةِ لَاۤ اِلٰهَ اِلَّاۤ اَنْتَ رَبَّ كُلِّ شَيْءٍ وَّمَلِيْكَهٗ ، اَعُوْذُ بِكَ مِنْ شَرِّ نَفْسِيْ وَمِنْ شَرِّ الشَّيْطٰنِ وَشِرْكِهٖ وَاَنْ اَقْتَرِفَ عَلٰى نَفْسِيْ سُوْٓءًا اَوْ اَجُرَّهٗۤ اِلٰى مُسْلِمٍ',
              pronunciation: 'dhikr_morning_14_pron'.tr(),
              meaning: 'dhikr_morning_14_meaning'.tr(),
              reference: 'dhikr_morning_14_ref'.tr(),
              fazilat: 'dhikr_morning_14_fazilat'.tr(),
              count: 'dhikr_morning_14_count'.tr(),
            ),
            const SizedBox(height: 14),

            // Dhikr 15
            _buildExpandableDuaCard(
              title: 'dhikr_morning_15_title'.tr(),
              arabic:
                  'يَا حَيُّ يَا قَيُّوْمُ بِرَحْمَتِكَ اَسْتَغِيْثُ ، اَصْلِحْ لِيْ شَاْنِيْ كُلَّهٗ وَلَا تَكِلْنِيْۤ اِلٰى نَفْسِيْ طَرْفَةَ عَيْنٍ',
              pronunciation: 'dhikr_morning_15_pron'.tr(),
              meaning: 'dhikr_morning_15_meaning'.tr(),
              reference: 'dhikr_morning_15_ref'.tr(),
              fazilat: 'dhikr_morning_15_fazilat'.tr(),
              count: 'dhikr_morning_15_count'.tr(),
            ),
            const SizedBox(height: 14),

            // Dhikr 16
            _buildExpandableDuaCard(
              title: 'dhikr_morning_16_title'.tr(),
              arabic:
                  'اَللّٰهُمَّ مَاۤ اَصْبَحَ بِيْ مِنْ نِّعْمَةٍ اَوْ بِاَحَدٍ مِّنْ خَلْقِكَ فَمِنْكَ وَحْدَكَ لَا شَرِيْكَ لَكَ ، فَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ',
              pronunciation: 'dhikr_morning_16_pron'.tr(),
              meaning: 'dhikr_morning_16_meaning'.tr(),
              reference: 'dhikr_morning_16_ref'.tr(),
              fazilat: 'dhikr_morning_16_fazilat'.tr(),
              count: 'dhikr_morning_16_count'.tr(),
            ),
            const SizedBox(height: 14),

            // Dhikr 17
            _buildExpandableDuaCard(
              title: 'dhikr_morning_17_title'.tr(),
              arabic:
                  'سُبْحَانَ اللّٰهِ وَبِحَمْدِهٖ عَدَدَ خَلْقِهٖ وَرِضَا نَفْسِهٖ وَزِنَةَ عَرْشِهٖ وَمِدَادَ كَلِمٰتِهٖ',
              pronunciation: 'dhikr_morning_17_pron'.tr(),
              meaning: 'dhikr_morning_17_meaning'.tr(),
              reference: 'dhikr_morning_17_ref'.tr(),
              fazilat: 'dhikr_morning_17_fazilat'.tr(),
              count: 'dhikr_morning_17_count'.tr(),
            ),
            const SizedBox(height: 14),

            // Dhikr 18
            _buildExpandableDuaCard(
              title: 'dhikr_morning_18_title'.tr(),
              arabic:
                  'اَللّٰهُمَّ اِنِّيْۤ اَسْاَلُكَ عِلْمًا نَّافِعًا وَّرِزْقًا طَيِّبًا وَّعَمَلًا مُّتَقَبَّلًا',
              pronunciation: 'dhikr_morning_18_pron'.tr(),
              meaning: 'dhikr_morning_18_meaning'.tr(),
              reference: 'dhikr_morning_18_ref'.tr(),
              fazilat: 'dhikr_morning_18_fazilat'.tr(),
              count: 'dhikr_morning_18_count'.tr(),
            ),
            const SizedBox(height: 14),

            // Dhikr 19
            _buildExpandableDuaCard(
              title: 'dhikr_morning_19_title'.tr(),
              arabic:
                  'اَصْبَحْنَا عَلٰى فِطْرَةِ الْاِسْلَامِ وَعَلٰى كَلِمَةِ الْاِخْلَاصِ وَعَلٰى دِيْنِ نَبِيِّنَا مُحَمَّدٍ صَلَّى اللّٰهُ عَلَيْهِ وَسَلَّمَ وَعَلٰى مِلَّةِ اَبِيْنَاۤ اِبْرٰهِيْمَ حَنِيْفًا مُّسْلِمًا وَّمَا كَانَ مِنَ الْمُشْرِكِيْنَ',
              pronunciation: 'dhikr_morning_19_pron'.tr(),
              meaning: 'dhikr_morning_19_meaning'.tr(),
              reference: 'dhikr_morning_19_ref'.tr(),
              fazilat: 'dhikr_morning_19_fazilat'.tr(),
              count: 'dhikr_morning_19_count'.tr(),
            ),
            const SizedBox(height: 14),

            // Dhikr 20
            _buildExpandableDuaCard(
              title: 'dhikr_morning_20_title'.tr(),
              arabic:
                  'رَضِيْتُ بِاللّٰهِ رَبًّا وَّبِالْاِسْلَامِ دِيْنًا وَّبِمُحَمَّدٍ نَبِيًّا',
              pronunciation: 'dhikr_morning_20_pron'.tr(),
              meaning: 'dhikr_morning_20_meaning'.tr(),
              reference: 'dhikr_morning_20_ref'.tr(),
              fazilat: 'dhikr_morning_20_fazilat'.tr(),
              count: 'dhikr_morning_20_count'.tr(),
            ),
            const SizedBox(height: 14),

            // Dhikr 21
            _buildExpandableDuaCard(
              title: 'dhikr_morning_21_title'.tr(),
              arabic:
                  'اَللّٰهُمَّ بِكَ اَصْبَحْنَا وَبِكَ اَمْسَيْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوْتُ وَاِلَيْكَ النُّشُوْرُ',
              pronunciation: 'dhikr_morning_21_pron'.tr(),
              meaning: 'dhikr_morning_21_meaning'.tr(),
              reference: 'dhikr_morning_21_ref'.tr(),
              fazilat: 'dhikr_morning_21_fazilat'.tr(),
              count: 'dhikr_morning_21_count'.tr(),
            ),
            const SizedBox(height: 14),

            // Dhikr 22
            _buildExpandableDuaCard(
              title: 'dhikr_morning_22_title'.tr(),
              arabic:
                  'سُبْحَانَ اللّٰهِ\nاَلْحَمْدُ لِلّٰهِ\nاَللّٰهُ اَكْبَرُ',
              pronunciation: 'dhikr_morning_22_pron'.tr(),
              meaning: 'dhikr_morning_22_meaning'.tr(),
              reference: 'dhikr_morning_22_ref'.tr(),
              fazilat: 'dhikr_morning_22_fazilat'.tr(),
              count: 'dhikr_morning_22_count'.tr(),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Expandable Dua Card ───
  Widget _buildExpandableDuaCard({
    required String title,
    required String arabic,
    required String pronunciation,
    required String meaning,
    required String reference,
    required String fazilat,
    required String count,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: Icon(Icons.format_quote, color: cs.primary, size: 20),
          title: Text(
            title,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count,
              style: TextStyle(
                color: cs.primary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          iconColor: cs.primary,
          collapsedIconColor: cs.primary,
          children: [
            // Arabic Text
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outline.withOpacity(0.15)),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'arabic'.tr(),
                          style: TextStyle(
                            color: cs.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      arabic,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 20,
                        fontFamily: 'NotoNaskhArabic',
                        height: 2.0,
                        locale: const Locale('ar'),
                        fontFeatures: const [
                          FontFeature.enable('liga'),
                          FontFeature.enable('kern'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Pronunciation
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cs.outline.withValues(alpha: 0.10)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.record_voice_over,
                        color: cs.tertiary,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'pronunciation'.tr(),
                        style: TextStyle(
                          color: cs.tertiary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pronunciation,
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 14,
                      height: 1.7,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Meaning
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cs.outline.withOpacity(0.10)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.translate, color: cs.secondary, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'meaning'.tr(),
                        style: TextStyle(
                          color: cs.secondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    meaning,
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 14,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Fazilat
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cs.primary.withOpacity(0.15)),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: cs.primary, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'virtue'.tr(),
                        style: TextStyle(
                          color: cs.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    fazilat,
                    style: TextStyle(
                      color: cs.onSurfaceVariant.withOpacity(0.90),
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Reference
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 16,
                    color: cs.onSurfaceVariant.withOpacity(0.75),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    reference,
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
