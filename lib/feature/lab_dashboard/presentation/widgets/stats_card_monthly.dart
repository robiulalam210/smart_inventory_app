import 'package:google_fonts/google_fonts.dart';

import '../../../../core/configs/configs.dart';

class StatsCardMonthly extends StatelessWidget {
  final String title;
  final String count;
  final Color color;
  final String icon;

  const StatsCardMonthly({
    super.key,
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      margin: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 8.0 : 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: isMobile ? 12 : 16,
                      fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: isMobile ? 24 : 30,
                        height: isMobile ? 24 : 30,
                        decoration: BoxDecoration(
                          color: color.withAlpha(128),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          icon,
                          color: Colors.white,
                          width: isMobile ? 24 : 30,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          count.toString(),
                          maxLines: 2,
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: color,
                            fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                            fontSize: isMobile ? 14 : 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: -40,
              right: -40,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}