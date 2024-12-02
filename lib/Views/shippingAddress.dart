import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/Controllers/databaseHelper.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:untitled/Views/create_account.dart';

class ShippingAddress extends StatefulWidget {
  const ShippingAddress({super.key});

  @override
  _ShippingAddress createState() => _ShippingAddress();
}

class _ShippingAddress extends State<ShippingAddress> {
  final user = FirebaseAuth.instance.currentUser;
  String userId = "0";
  final DBHelper dbHelper = DBHelper();

  late String autoincrementIndex;

  int selectedAddress = 0;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getAutoIncrementIndex();
  }

  void getAutoIncrementIndex() async {
    autoincrementIndex = await dbHelper.autoIncrement('deliveryAddress');
  }

  void updateSelectedAddress(Map<String, dynamic> newAddress) {
    setState(() {
      selectedAddress = int.parse(newAddress['id']) - 1;
    });

    dbHelper.updateData("users/$userId", {
      'deliveryAddress.id': newAddress['id'],
      'deliveryAddress.country': newAddress['country'],
      'deliveryAddress.city': newAddress['city'],
      'deliveryAddress.street': newAddress['street'],
      'deliveryAddress.name': newAddress['name'],
    });

    setState(() {
      selectedAddress = 0;
    });
  }

  void deleteAddress(Map<String, dynamic> newCard) {
    print("ADDRESS:");
    print(newCard);
    dbHelper.deleteData("deliveryAddress/${newCard['id']}");
    setState(() {});
  }

  void createCard() {
    dbHelper.updateData("users/$userId", {
      'deliveryAddress.id': autoincrementIndex,
      'deliveryAddress.country': _countryController.text,
      'deliveryAddress.city': _cityController.text,
      'deliveryAddress.street': _streetController.text,
      'deliveryAddress.name': _nameController.text,
    });
    dbHelper.addData("deliveryAddress/$autoincrementIndex", {
      'id': autoincrementIndex,
      'country': _countryController.text,
      'city': _cityController.text,
      'userId': userId,
      'street': _streetController.text,
      'name': _nameController.text,
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      Navigator.pop(
        context,
        MaterialPageRoute(
          builder: (context) => CreateAccount(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Addressess'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop()),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(7.0),
        child: Column(
          children: [
            dbHelper.getData(
                path: 'users',
                columnFilter: 'email',
                filterValue: user?.email,
                itemBuilder: (users) {
                  var user = users[0];
                  userId = user['id'];

                  var deliveryAddress =
                  user['deliveryAddress'] ?? null as Map<String, dynamic>;

                  print(deliveryAddress);

                  return Expanded(
                    child: dbHelper.getData(
                        path: 'deliveryAddress',
                        columnFilter: 'userId',
                        filterValue: userId,
                        itemBuilder: (addressess) {
                          var deliveryAddressess = [deliveryAddress];

                          print(deliveryAddress);

                          for (int i = 0; i < addressess.length; i++) {
                            print(addressess[i]["id"] != deliveryAddress["id"]);
                            if (addressess[i]["id"] != deliveryAddress["id"]) {
                              deliveryAddressess.add(addressess[i]);
                            }
                          }

                          print(deliveryAddressess);

                          getAutoIncrementIndex();
                          // autoincrementIndex = await dbHelper.autoIncrement('paymentMethods');

                          return ListView.builder(
                            itemCount: deliveryAddressess.length,
                            itemBuilder: (context, index) {
                              return AddressCard(
                                deliveryAddress: deliveryAddressess[index],
                                chosen: (index == selectedAddress),
                                onSelected: () => updateSelectedAddress(
                                    deliveryAddressess[index]),
                                onDeleted: () =>
                                    deleteAddress(deliveryAddressess[index]),
                              );
                            },
                          );
                        }),
                  );
                }),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/plus.svg',
                  width: 40,
                  height: 40,
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Center(
                                  child: Text(
                                    'Add New Card',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  decoration: const InputDecoration(
                                      labelText: 'Address Owner'),
                                  controller: _nameController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter the address owner name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  decoration: const InputDecoration(
                                      labelText: 'Street Name'),
                                  controller: _streetController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter the street name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  decoration: const InputDecoration(
                                      labelText: 'City Name'),
                                  controller: _cityController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter the city name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  decoration: const InputDecoration(
                                      labelText: 'Country Name'),
                                  controller: _countryController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter the country name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      createCard();
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  child: const Text('Save'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddressCard extends StatefulWidget {
  final Map<String, dynamic> deliveryAddress;
  final bool chosen;
  final VoidCallback onSelected;
  final VoidCallback onDeleted;

  const AddressCard(
      {super.key,
        required this.deliveryAddress,
        required this.chosen,
        required this.onSelected,
        required this.onDeleted});

  @override
  _AddressCard createState() => _AddressCard();
}

class _AddressCard extends State<AddressCard> {
  late bool isChecked;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double
              .infinity, // Hace que el ancho se ajuste al máximo disponible.
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.deliveryAddress['name']),
                  const SizedBox(height: 8),
                  Text(widget.deliveryAddress['street']),
                  const SizedBox(height: 8),
                  Text(
                      "${widget.deliveryAddress['city']}, ${widget.deliveryAddress['country']}"),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Checkbox(
                value: widget.chosen,
                onChanged: (bool? newValue) {
                  if (newValue == true) {
                    widget.onSelected();
                  }
                },
              ),
              const Text("Use as shipping address")
            ]),
            Row(children: [
              widget.chosen == false
                  ? Checkbox(
                value: widget.chosen,
                onChanged: (bool? newValue) {
                  if (newValue == true) {
                    widget.onDeleted();
                  }
                },
              )
                  : const SizedBox.shrink(),
              widget.chosen == false ? const Text("Delete") : const Text("")
            ])
          ],
        ),
        const SizedBox(height: 10)
      ],
    );
  }
}
