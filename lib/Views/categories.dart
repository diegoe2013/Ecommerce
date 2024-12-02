import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'home.dart';

class Category extends StatelessWidget {
  final List<Map<String, String>> categories = [
    {"name": "Clothing", "image": "assets/images/Clothing.svg"},
    {"name": "Shoes", "image": "assets/images/Shoes.svg"},
    {"name": "Bags", "image": "assets/images/bags.svg"},
    {"name": "Lingerie", "image": "assets/images/Lingeries.svg"},
    {"name": "Watch", "image": "assets/images/Watch.svg"},
    {"name": "Hoodies", "image": "assets/images/Hoodies.svg"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Categories"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two items per row
            crossAxisSpacing: 10, // Horizontal spacing
            mainAxisSpacing: 10, // Vertical spacing
            childAspectRatio: 1.1, // Adjust aspect ratio for images
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return CategoryCard(
              name: categories[index]['name']!,
              image: categories[index]['image']!,
            );
          },
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String name;
  final String image;

  const CategoryCard({
    Key? key,
    required this.name,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(initialCategory: name.toLowerCase()),
          ),
        );
        // Navigator.pushNamed(context, '/home');
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
                child: SvgPicture.asset(
                  image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

