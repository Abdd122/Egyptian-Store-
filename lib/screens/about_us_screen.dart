
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('من نحن'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset('assets/animations/teamwork_animation.json', height: 200),
            const SizedBox(height: 24),
            Text(
              'مرحباً بكم في متجر الأحلام',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'في متجر الأحلام، نؤمن بأن التسوق يجب أن يكون تجربة ممتعة ومصدر إلهام. انطلقنا من شغفنا بتقديم منتجات فريدة وعالية الجودة تجمع بين الأناقة والابتكار. نحن فريق من الخبراء والمبدعين الذين يعملون بلا كلل لاختيار أفضل ما في عالم الموضة، التكنولوجيا، ومستلزمات الحياة العصرية لنضعه بين يديكم.',
              style: TextStyle(fontSize: 16, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'قيمنا الأساسية',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const ValueCard(
              icon: Icons.high_quality,
              title: 'الجودة أولاً',
              description: 'نلتزم بتقديم منتجات لا مثيل لها في الجودة، تم اختيارها بعناية فائقة.',
            ),
            const ValueCard(
              icon: Icons.support_agent,
              title: 'خدمة عملاء استثنائية',
              description: 'فريقنا جاهز دائمًا لمساعدتكم وتقديم تجربة تسوق لا تُنسى.',
            ),
            const ValueCard(
              icon: Icons.lightbulb_outline,
              title: 'الابتكار والإبداع',
              description: 'نسعى دائمًا لتقديم كل ما هو جديد ومبتكر في عالم المنتجات.',
            ),
          ],
        ),
      ),
    );
  }
}

class ValueCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const ValueCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
