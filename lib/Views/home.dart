import 'package:flutter/material.dart';
import 'product_detail.dart';
import 'package:untitled/Controllers/apiService.dart';
import 'package:untitled/Controllers/getData.dart';
import 'package:flutter/gestures.dart';

class HomeScreen extends StatefulWidget {
  final String initialCategory;

  const HomeScreen({super.key, required this.initialCategory});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String token = '';
  List<dynamic> products = [];
  List<dynamic> newProducts = [];
  var productList = [];
  var newProductList = [];
  
  String selectedCategory = '';

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.initialCategory;
    fetchAndSetProducts(selectedCategory);
  }

  Future<void> fetchAndSetProducts(String keyword) async {
    try {
      final encodedKeyword = Uri.encodeQueryComponent(keyword);
      final url = 'https://api.ebay.com/buy/browse/v1/item_summary/search?q=$encodedKeyword&limit=30';
      final newUrl = 'https://api.ebay.com/buy/browse/v1/item_summary/search?q=$encodedKeyword&limit=30&sort=newlyListed';
      final authToken = await fetchToken();
      productList = await getData(authToken, url);
      newProductList = await getData(authToken, newUrl);

      setState(() {
        token = authToken;
        products = productList;
        newProducts = newProductList;
      });
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Categories"),
        backgroundColor: Colors.orange,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => FilterSheet(
                  onApplyFilters: (filters) {
                    setState(() {
                      List<dynamic> products_filter = [];
                      List<dynamic> new_products_filter = [];

                      for (Map<String, dynamic> product in productList){
                        double price = double.parse(product['price']['value']);
                        String title = product['title'];
                        List<dynamic> categories = product['categories'];

                        String filterCategory = filters['category'];
                        List<dynamic> filterColors = filters['colors'];

                        if ((filters['minPrice'] != 0.0 || filters['maxPrice'] != 500.0) && (price >= filters['minPrice'] && price <= filters['maxPrice'])){
                          products_filter.add(product);
                          continue;
                        }

                        if(filterColors.isNotEmpty){
                          for (String color in filterColors){
                            if(title.toLowerCase().contains(color.toString().toLowerCase())){
                              products_filter.add(product);
                              continue;
                            }
                          }
                        }

                        if(filterCategory.isNotEmpty && title.toLowerCase().contains(filterCategory.toLowerCase())){
                          products_filter.add(product);
                          continue;
                        }

                        if(categories.isNotEmpty && filterCategory.isNotEmpty){
                          for (Map<String, dynamic> category in categories){
                            if(category['categoryName'].toString().toLowerCase().contains(filterCategory.toLowerCase())){
                              products_filter.add(product);
                              continue;
                            }
                          }
                        }
                      }
                      products = products_filter;

                      for (Map<String, dynamic> product in newProductList){
                        double price = double.parse(product['price']['value']);
                        String title = product['title'];
                        List<dynamic> categories = product['categories'];

                        String filterCategory = filters['category'];
                        List<dynamic> filterColors = filters['colors'];

                        if ((filters['minPrice'] != 0.0 || filters['maxPrice'] != 500.0) && (price >= filters['minPrice'] && price <= filters['maxPrice'])){
                          new_products_filter.add(product);
                          continue;
                        }

                        if(filterColors.isNotEmpty){
                          for (String color in filterColors){
                            if(title.toLowerCase().contains(color.toString().toLowerCase())){
                              new_products_filter.add(product);
                              continue;
                            }
                          }
                        }

                        if(filterCategory.isNotEmpty && title.toLowerCase().contains(filterCategory.toLowerCase())){
                          new_products_filter.add(product);
                          continue;
                        }

                        if(categories.isNotEmpty && filterCategory.isNotEmpty){
                          for (Map<String, dynamic> category in categories){
                            if(category['categoryName'].toString().toLowerCase().contains(filterCategory.toLowerCase())){
                              new_products_filter.add(product);
                              continue;
                            }
                          }
                        }
                      }
                      newProducts = new_products_filter;
                    });
        
                    Navigator.pop(context);
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: products.isEmpty
          ? const Center(child: Text('No products available.'))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView(
                children: [
                  // Category buttons
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedCategory = 'clothes';
                              fetchAndSetProducts(selectedCategory);
                            });
                          },
                          child: const Text("Clothing"),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedCategory = 'books';
                              fetchAndSetProducts(selectedCategory);
                            });
                          },
                          child: const Text("Books"),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedCategory = 'electronics';
                              fetchAndSetProducts(selectedCategory);
                            });
                          },
                          child: const Text("Electronics"),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedCategory = 'home';
                              fetchAndSetProducts(selectedCategory);
                            });
                          },
                          child: const Text("Home"),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/categories');
                          },
                          child: const Text("View All"),
                        ),
                      ],
                    ),
                  ),
                  // Top Offers Section
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Top Offers",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Products section
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: products.isEmpty ? 0 : products.length,
                      itemBuilder: (context, index) {
                        return ProductCard(product: products[index], productList: products,);
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "New",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // New products section
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: newProducts.isEmpty ? 0 : newProducts.length,
                      itemBuilder: (context, index) {
                        return ProductCard(product: newProducts[index], productList: newProducts,);
                      },
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/favorites');
          }
          if (index == 2) {
            Navigator.pushNamed(context, '/my_bag');
          }
          if (index == 3) {
            Navigator.pushNamed(context, '/profile');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'My Bag',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Map product;
  final List<dynamic> productList; 

  const ProductCard({Key? key, required this.product, required this.productList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetail(
              productId: product['itemId'],
              productList: productList,
            ),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: product['image'] != null && product['image']['imageUrl'] != null
                    ? DecorationImage(
                        image: NetworkImage(product['image']['imageUrl']),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['title'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product['price']['value']}',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

class FilterSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;

  const FilterSheet({Key? key, required this.onApplyFilters}) : super(key: key);

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  double minPrice = 0;
  double maxPrice = 500;
  List<String> selectedColors = [];
  String selectedCategory = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
      ),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8, // Max 80% height
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Filters",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Price Range Filter
              const Text("Price range"),
              RangeSlider(
                values: RangeValues(minPrice, maxPrice),
                min: 0,
                max: 500,
                divisions: 10,
                labels: RangeLabels(
                  '\$${minPrice.toInt()}',
                  '\$${maxPrice.toInt()}',
                ),
                onChanged: (RangeValues values) {
                  setState(() {
                    minPrice = values.start;
                    maxPrice = values.end;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Colors Filter
              const Text("Colors"),
              Wrap(
                spacing: 8.0,
                children: ['Black', 'White', 'Red', 'Blue', 'Green']
                    .map((color) => FilterChip(
                          label: Text(color),
                          selected: selectedColors.contains(color),
                          onSelected: (isSelected) {
                            setState(() {
                              isSelected
                                  ? selectedColors.add(color)
                                  : selectedColors.remove(color);
                            });
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              // Category Filter
              const Text("Category"),
              Wrap(
                spacing: 8.0,
                children: ['All', 'Women', 'Men', 'Boys', 'Girls']
                    .map((category) => ChoiceChip(
                          label: Text(category),
                          selected: selectedCategory == category,
                          onSelected: (isSelected) {
                            setState(() {
                              selectedCategory = isSelected ? category : '';
                            });
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              // Apply and Discard Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close without applying filters
                    },
                    child: const Text("Discard"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      widget.onApplyFilters({
                        'minPrice': minPrice,
                        'maxPrice': maxPrice,
                        'colors': selectedColors,
                        'category': selectedCategory,
                      });
                    },
                    child: const Text("Apply"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
